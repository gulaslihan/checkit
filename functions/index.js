const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { initializeApp } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");
const { getFirestore, Timestamp, FieldValue } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const { GoogleGenAI, Type } = require("@google/genai");
// Auth lifecycle triggers only exist in the v1 API (v2 has blocking
// functions for sign-up/sign-in, but nothing for deletion).
const functionsV1 = require("firebase-functions/v1");

initializeApp();
const db = getFirestore();
const messaging = getMessaging();

// A user doc with no `language` field is someone who signed up before
// i18n existed — default them to Turkish (the app's original/only language
// until now) rather than English.
function languageOf(user) {
  return user.language === "en" ? "en" : "tr";
}

// Looks [email] up in `users`, checks their [settingKey] preference (default
// on when unset) and stored FCM token, and sends if both are present.
// [messages] is `(lang) => ({ title, body })` — resolved once the
// recipient's stored language is known, so callers describe both variants
// up front instead of guessing a language before the user doc is fetched.
//
// A send failure (most commonly a stale/uninstalled-app token) is caught
// here rather than left to propagate — callers routinely fire several of
// these into one `Promise.all` (e.g. onListUpdated pushing every
// collaborator), and one bad token throwing would reject the whole batch
// for everyone else too. An unregistered token also gets cleared so it
// isn't retried forever.
// [sound] true requests the platform's default notification sound — Android
// plays a sound automatically for most notifications, but iOS stays silent
// unless `apns.payload.aps.sound` is set explicitly, so this is needed for
// any push that should reliably make noise on both platforms.
async function sendPushIfEnabled(email, { settingKey, messages, data, sound }) {
  if (!email) return;
  const usersSnap = await db.collection("users").where("email", "==", email).limit(1).get();
  if (usersSnap.empty) return;
  const user = usersSnap.docs[0].data();
  if (settingKey && user[settingKey] === false) return;
  const token = user.fcmToken;
  if (!token) return;
  const { title, body } = messages(languageOf(user));
  try {
    await messaging.send({
      token,
      notification: { title, body },
      data,
      ...(sound
        ? {
            android: { notification: { sound: "default" } },
            apns: { payload: { aps: { sound: "default" } } },
          }
        : {}),
    });
  } catch (error) {
    console.error(`Push to ${email} failed: ${error.code || error.message}`);
    if (error.code === "messaging/registration-token-not-registered" || error.code === "messaging/invalid-registration-token") {
      await usersSnap.docs[0].ref.update({ fcmToken: FieldValue.delete() });
    }
  }
}

// A new invite was created — push the recipient, if they have the app
// installed and a stored FCM token (see lib/data/fcm_provider.dart).
exports.onInviteCreated = onDocumentCreated("invites/{inviteId}", async (event) => {
  const invite = event.data.data();
  if (!invite) return;

  await sendPushIfEnabled(invite.recipientEmail, {
    messages: (lang) =>
      lang === "en"
        ? { title: "New invite", body: `${invite.ownerEmail} invited you to "${invite.listTitle}".` }
        : { title: "Yeni davet", body: `${invite.ownerEmail} sizi "${invite.listTitle}" listesine davet etti.` },
    data: { type: "invite", listId: invite.listId },
    sound: true,
  });
});

// A new connection (friend) request was created — same idea as
// onInviteCreated, just for the `connections` collection.
exports.onConnectionRequestCreated = onDocumentCreated("connections/{connectionId}", async (event) => {
  const connection = event.data.data();
  if (!connection || connection.status !== "pending") return;

  await sendPushIfEnabled(connection.recipientEmail, {
    messages: (lang) =>
      lang === "en"
        ? { title: "New connection request", body: `${connection.requesterEmail} wants to connect with you.` }
        : { title: "Yeni bağlantı isteği", body: `${connection.requesterEmail} sizinle bağlantı kurmak istiyor.` },
    data: { type: "connection_request" },
  });
});

// Waits a few seconds, then re-reads [itemId] — if it's been un-checked
// again in the meantime (an accidental tap immediately undone), the
// completion push is skipped instead of notifying everyone about something
// that's no longer true.
async function sendCompletionPushIfStillDone(listId, itemId, email, opts) {
  await new Promise((resolve) => setTimeout(resolve, 8000));
  const doc = await db.collection("lists").doc(listId).get();
  const current = (doc.data()?.items || []).find((i) => i.id === itemId);
  if (!current || !current.isDone) return;
  await sendPushIfEnabled(email, opts);
}

// A list document changed — diff its `items` array to catch additions,
// completions, and (re)assignments, and push everyone who can see the list
// except whoever just made the change (see `lastModifiedBy`, set by
// lib/data/lists_provider.dart on the writes that matter here).
exports.onListUpdated = onDocumentUpdated("lists/{listId}", async (event) => {
  const before = event.data.before.data();
  const after = event.data.after.data();
  if (!before || !after) return;

  const listId = event.params.listId;
  const actor = after.lastModifiedBy;
  const recipients = [after.ownerEmail, ...(after.sharedWith || [])].filter(
    (email) => email && email !== actor,
  );
  const listTitle = (lang) => after.title || (lang === "en" ? "List" : "Liste");

  const beforeItems = new Map((before.items || []).map((item) => [item.id, item]));
  const afterItems = after.items || [];

  const pushes = [];
  for (const item of afterItems) {
    const prev = beforeItems.get(item.id);

    if (!prev) {
      for (const email of recipients) {
        pushes.push(
          sendPushIfEnabled(email, {
            settingKey: "onItemAdded",
            messages: (lang) => ({
              title: listTitle(lang),
              body: lang === "en" ? `New item added: ${item.text}` : `Yeni madde eklendi: ${item.text}`,
            }),
            data: { type: "item_added", listId },
          }),
        );
      }
      continue;
    }

    if (!prev.isDone && item.isDone) {
      for (const email of recipients) {
        pushes.push(
          sendCompletionPushIfStillDone(listId, item.id, email, {
            settingKey: "onItemCompleted",
            messages: (lang) => ({
              title: listTitle(lang),
              body: lang === "en" ? `"${item.text}" completed` : `"${item.text}" tamamlandı`,
            }),
            data: { type: "item_completed", listId },
          }),
        );
      }
    }

    if (item.assignedTo && item.assignedTo !== prev.assignedTo && item.assignedTo !== actor) {
      pushes.push(
        sendPushIfEnabled(item.assignedTo, {
          settingKey: "onTaskAssigned",
          messages: (lang) => ({
            title: listTitle(lang),
            body: lang === "en" ? `A task was assigned to you: ${item.text}` : `Size bir görev atandı: ${item.text}`,
          }),
          data: { type: "task_assigned", listId },
        }),
      );
    }
  }

  // Someone new in `sharedWith` means they just accepted an invite (see
  // InvitesNotifier.acceptInvite in lib/data/invites_provider.dart — it
  // writes this array directly, there's no separate "accepted" event to
  // hook into) — let the owner know, with sound since it's a rarer,
  // meaningful moment rather than routine list chatter.
  const beforeShared = new Set(before.sharedWith || []);
  const newlyShared = (after.sharedWith || []).filter((email) => !beforeShared.has(email));
  if (newlyShared.length > 0 && after.ownerEmail) {
    for (const email of newlyShared) {
      pushes.push(
        sendPushIfEnabled(after.ownerEmail, {
          messages: (lang) => ({
            title: listTitle(lang),
            body:
              lang === "en"
                ? `${email} accepted your invite to "${after.title}".`
                : `${email} "${after.title}" davetinizi kabul etti.`,
          }),
          data: { type: "invite_accepted", listId },
          sound: true,
        }),
      );
    }
  }

  await Promise.all(pushes);
});

// Once a day, nudge whoever's responsible for an item (its assignee, or the
// list owner if unassigned) that it's been sitting undone for a while.
// Re-notifies at most once per their own `longPendingDays` window, tracked
// via `notifiedLongPendingAt` on the item itself.
exports.checkLongPendingItems = onSchedule("every day 09:00", async () => {
  const listsSnap = await db.collection("lists").get();
  const now = Date.now();

  await Promise.all(
    listsSnap.docs.map(async (doc) => {
      const list = doc.data();
      const items = list.items || [];
      let mutated = false;

      const newItems = await Promise.all(
        items.map(async (item) => {
          if (item.isDone || !item.createdAt) return item;
          const recipient = item.assignedTo || list.ownerEmail;
          if (!recipient) return item;

          const usersSnap = await db.collection("users").where("email", "==", recipient).limit(1).get();
          if (usersSnap.empty) return item;
          const user = usersSnap.docs[0].data();
          if (user.onLongPending === false) return item;

          const thresholdMs = (user.longPendingDays || 3) * 86400000;
          const ageMs = now - item.createdAt.toMillis();
          const lastNotifiedMs = item.notifiedLongPendingAt ? item.notifiedLongPendingAt.toMillis() : 0;
          if (ageMs < thresholdMs || now - lastNotifiedMs < thresholdMs) return item;

          const token = user.fcmToken;
          if (token) {
            const lang = languageOf(user);
            try {
              await messaging.send({
                token,
                notification: {
                  title: list.title || (lang === "en" ? "List" : "Liste"),
                  body: lang === "en" ? `"${item.text}" is still not done` : `"${item.text}" hâlâ tamamlanmadı`,
                },
                data: { type: "long_pending", listId: doc.id },
              });
            } catch (error) {
              // Same reasoning as sendPushIfEnabled: don't let one stale
              // token abort this list's whole `notifiedLongPendingAt` write
              // below — that would leave every OTHER item in this list
              // un-marked too, and they'd all get re-notified again
              // tomorrow even though their pushes already succeeded.
              console.error(`Push to ${recipient} failed: ${error.code || error.message}`);
              if (error.code === "messaging/registration-token-not-registered" || error.code === "messaging/invalid-registration-token") {
                await usersSnap.docs[0].ref.update({ fcmToken: FieldValue.delete() });
              }
            }
          }
          mutated = true;
          return { ...item, notifiedLongPendingAt: Timestamp.now() };
        }),
      );

      if (mutated) await doc.ref.update({ items: newItems });
    }),
  );
});

// Once a month, nudges an owner if they have archived lists sitting for 60+
// days — the archive is meant to be reviewed occasionally, not become a
// second graveyard. Re-notifies at most once every ~25 days per list via
// `staleReminderSentAt`, mirroring `notifiedLongPendingAt` above.
exports.checkStaleArchivedLists = onSchedule("1 of month 09:00", async () => {
  const listsSnap = await db.collection("lists").where("archived", "==", true).get();
  const now = Date.now();
  const staleThresholdMs = 60 * 86400000;
  const reminderCooldownMs = 25 * 86400000;

  const staleRefsByOwner = new Map();
  for (const doc of listsSnap.docs) {
    const list = doc.data();
    if (!list.archivedAt || !list.ownerEmail) continue;
    if (now - list.archivedAt.toMillis() < staleThresholdMs) continue;
    const lastReminderMs = list.staleReminderSentAt ? list.staleReminderSentAt.toMillis() : 0;
    if (now - lastReminderMs < reminderCooldownMs) continue;

    if (!staleRefsByOwner.has(list.ownerEmail)) staleRefsByOwner.set(list.ownerEmail, []);
    staleRefsByOwner.get(list.ownerEmail).push(doc.ref);
  }

  await Promise.all(
    Array.from(staleRefsByOwner.entries()).map(async ([ownerEmail, refs]) => {
      await sendPushIfEnabled(ownerEmail, {
        messages: (lang) => ({
          title: lang === "en" ? "Archive cleanup" : "Arşiv temizliği",
          body:
            lang === "en"
              ? refs.length === 1
                ? "You have 1 list that's been sitting in your archive for a while — want to take a look?"
                : `You have ${refs.length} lists that have been sitting in your archive for a while — want to take a look?`
              : refs.length === 1
                ? "Arşivinizde uzun süredir bekleyen 1 liste var — göz atmak ister misiniz?"
                : `Arşivinizde uzun süredir bekleyen ${refs.length} liste var — göz atmak ister misiniz?`,
        }),
        data: { type: "stale_archive" },
      });
      await Promise.all(refs.map((ref) => ref.update({ staleReminderSentAt: Timestamp.now() })));
    }),
  );
});

// An Auth account was deleted — remove its users/{uid} profile doc (email,
// FCM token, settings, quota counters). The app deletes the user's lists,
// invites and connections itself (lib/data/account_deletion.dart), but it
// can't delete this doc: firestore.rules deliberately has no delete rule for
// users, because a client-side delete would let anyone reset the permanent
// createdListCount quota without deleting their account. Running here, only
// after the account is really gone, covers every deletion path (normal,
// after re-authentication, or from the Firebase Console) and keeps the
// store/privacy-policy promise that deleting the account erases its data.
exports.onAuthUserDeleted = functionsV1.auth.user().onDelete(async (user) => {
  await db.collection("users").doc(user.uid).delete();
});

// Must match lib/data/category_suggestions.dart's `listCategories` exactly —
// these are the fixed category ids the app's icon lookup understands. Kept
// in Turkish regardless of the target language (see categoryDisplayName()
// in the Flutter app), since it's an internal id, not user-facing text.
const LIST_CATEGORIES = [
  "Market Alışverişi",
  "Kişisel Alışveriş",
  "Ev İşleri",
  "Günlük Rutinler",
  "Sağlıklı Yaşam",
  "Antrenman Programı",
  "Seyahat",
  "Valiz",
  "İş Seyahati",
  "Piknik Hazırlığı",
  "Özel Günler",
  "Davet",
  "Doğum Günü Hazırlığı",
  "Hediye Organizasyonu",
  "Kitap Listesi",
  "Film Listesi",
  "Çocuk",
  "İş",
  "Diğer",
];

const AI_DAILY_LIMIT = 5;

const AI_RESPONSE_SCHEMA = {
  type: Type.OBJECT,
  properties: {
    title: { type: Type.STRING, description: "Short, descriptive list title." },
    category: { type: Type.STRING, enum: LIST_CATEGORIES },
    isCheckable: { type: Type.BOOLEAN },
    allowRating: { type: Type.BOOLEAN },
    allowDueDates: { type: Type.BOOLEAN },
    allowNotes: { type: Type.BOOLEAN },
    items: {
      type: Type.ARRAY,
      items: {
        type: Type.OBJECT,
        properties: {
          text: { type: Type.STRING },
          subheading: { type: Type.STRING, nullable: true },
        },
        required: ["text"],
      },
    },
  },
  required: ["title", "category", "isCheckable", "allowRating", "allowDueDates", "allowNotes", "items"],
};

function aiSystemInstruction(languageName) {
  return `You are a checklist-generation assistant for CheckIt, a shared to-do list app. Given a
free-form description from the user, generate a complete, ready-to-use checklist as structured JSON.

Rules:
- Write all text (title, item text, subheadings) in ${languageName} — regardless of what language
  the user's own description is written in.
- title: short and descriptive.
- category: pick the single best-fitting value from the provided enum. These are internal category
  ids (kept in Turkish on purpose, they only drive which icon is shown) — pick loosely if unsure.
- isCheckable: true unless the list is purely a reference with nothing to actually check off.
- allowRating: true only if rating items 1-5 stars would make sense (e.g. restaurants, movies, books
  to review) — false for most task/checklist content.
- allowDueDates: true if items are naturally tied to specific times/dates (e.g. a multi-day
  itinerary, appointments). This only turns the feature ON — never invent specific dates or times
  yourself, the user fills those in afterward.
- allowNotes: true if items would benefit from an optional short free-text note.
- items: 3 to 20 concrete, actionable items.
- subheading: group items under a short subheading whenever the content naturally divides into
  sections — e.g. "Day 1" / "Day 2" for a multi-day trip — even if the user didn't explicitly ask
  for grouping. Leave it null for items that don't need one. Keep the natural reading order (e.g.
  all Day 1 items before Day 2).`;
}

// Generates a ready-to-create list (title, feature toggles, category, items
// with optional sub-headings) from a free-form user description via Gemini.
// Rate-limited per user (see AI_DAILY_LIMIT) since each call has a real
// cost — the counter lives on `users/{uid}` and is only ever written here
// (Admin SDK bypasses Firestore rules), so a client can't reset its own quota.
exports.generateListWithAI = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign-in required.");
  }
  // The app already holds unverified users on the verify-email screen, but
  // that's client-side only — a direct call to this function would skip it.
  // Reads the account's real status (not the ID token's claim, which can lag
  // behind a just-completed verification by up to an hour).
  const authUser = await getAuth().getUser(request.auth.uid);
  if (!authUser.emailVerified) {
    throw new HttpsError("failed-precondition", "email-not-verified");
  }
  const prompt = String(request.data?.prompt || "").trim();
  if (!prompt) {
    throw new HttpsError("invalid-argument", "prompt is required.");
  }
  if (prompt.length > 500) {
    throw new HttpsError("invalid-argument", "prompt is too long.");
  }

  const uid = request.auth.uid;
  const userRef = db.collection("users").doc(uid);
  const userSnap = await userRef.get();
  const user = userSnap.data() || {};
  const language = user.language === "en" ? "en" : "tr";

  const cfgSnap = await db.collection("config").doc("appConfig").get();
  const cfg = cfgSnap.data() || {};

  // Defensive backstop for the free-tier lifetime list cap (see
  // firestore.rules' canCreateList(), the real enforcement point) — checked
  // here too so a free user who's already out of free lists doesn't burn a
  // real Gemini call generating content they can never save. Subscription
  // status/counter can only be set by Admin SDK, same as this whole doc.
  const isPremium = user.subscriptionActive === true;
  if (!isPremium) {
    const freeTotalListLimit = cfg.freeTotalListLimit ?? 5;
    const createdListCount = user.createdListCount || 0;
    if (createdListCount >= freeTotalListLimit) {
      throw new HttpsError("resource-exhausted", "free-limit-reached");
    }
  }

  const dailyLimit = cfg.premiumDailyAiListLimit ?? AI_DAILY_LIMIT;
  const today = new Date().toISOString().slice(0, 10);
  const usedToday = user.aiGenerationsDate === today ? user.aiGenerationsCount || 0 : 0;
  if (usedToday >= dailyLimit) {
    throw new HttpsError("resource-exhausted", "daily-limit-reached");
  }

  const ai = new GoogleGenAI({ vertexai: true, project: process.env.GCLOUD_PROJECT, location: "us-central1" });
  let response;
  try {
    response = await ai.models.generateContent({
      model: "gemini-2.5-flash",
      contents: prompt,
      config: {
        systemInstruction: aiSystemInstruction(language === "en" ? "English" : "Turkish"),
        responseMimeType: "application/json",
        responseSchema: AI_RESPONSE_SCHEMA,
      },
    });
  } catch (error) {
    console.error("generateListWithAI: Gemini call failed:", error);
    throw new HttpsError("internal", "generation-failed");
  }

  let parsed;
  try {
    parsed = JSON.parse(response.text);
  } catch (error) {
    console.error("generateListWithAI: could not parse Gemini output as JSON:", response.text);
    throw new HttpsError("internal", "generation-failed");
  }

  // Defensive clamping — never trust the model's output shape/limits blindly,
  // even with a response schema (still free-form content within each field).
  const fallbackTitle = language === "en" ? "New List" : "Yeni Liste";
  const title = String(parsed.title || "").trim().slice(0, 80) || fallbackTitle;
  const category = LIST_CATEGORIES.includes(parsed.category) ? parsed.category : null;
  const items = Array.isArray(parsed.items)
    ? parsed.items
        .filter((item) => item && typeof item.text === "string" && item.text.trim())
        .slice(0, 20)
        .map((item) => ({
          text: item.text.trim().slice(0, 200),
          subheading:
            typeof item.subheading === "string" && item.subheading.trim()
              ? item.subheading.trim().slice(0, 40)
              : null,
        }))
    : [];

  await userRef.set({ aiGenerationsDate: today, aiGenerationsCount: usedToday + 1 }, { merge: true });

  return {
    title,
    category,
    isCheckable: parsed.isCheckable !== false,
    allowRating: parsed.allowRating === true,
    allowDueDates: parsed.allowDueDates === true,
    allowNotes: parsed.allowNotes === true,
    items,
  };
});
