const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, Timestamp } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();
const db = getFirestore();
const messaging = getMessaging();

// Looks [email] up in `users`, checks their [settingKey] preference (default
// on when unset) and stored FCM token, and sends if both are present.
async function sendPushIfEnabled(email, { settingKey, title, body, data }) {
  if (!email) return;
  const usersSnap = await db.collection("users").where("email", "==", email).limit(1).get();
  if (usersSnap.empty) return;
  const user = usersSnap.docs[0].data();
  if (settingKey && user[settingKey] === false) return;
  const token = user.fcmToken;
  if (!token) return;
  await messaging.send({ token, notification: { title, body }, data });
}

// A new invite was created — push the recipient, if they have the app
// installed and a stored FCM token (see lib/data/fcm_provider.dart).
exports.onInviteCreated = onDocumentCreated("invites/{inviteId}", async (event) => {
  const invite = event.data.data();
  if (!invite) return;

  await sendPushIfEnabled(invite.recipientEmail, {
    title: "Yeni davet",
    body: `${invite.ownerEmail} sizi "${invite.listTitle}" listesine davet etti.`,
    data: { type: "invite", listId: invite.listId },
  });
});

// A new connection (friend) request was created — same idea as
// onInviteCreated, just for the `connections` collection.
exports.onConnectionRequestCreated = onDocumentCreated("connections/{connectionId}", async (event) => {
  const connection = event.data.data();
  if (!connection || connection.status !== "pending") return;

  await sendPushIfEnabled(connection.recipientEmail, {
    title: "Yeni bağlantı isteği",
    body: `${connection.requesterEmail} sizinle bağlantı kurmak istiyor.`,
    data: { type: "connection_request" },
  });
});

// A list document changed — diff its `items` array to catch additions,
// completions, and (re)assignments, and push everyone who can see the list
// except whoever just made the change (see `lastModifiedBy`, set by
// lib/data/lists_provider.dart on the writes that matter here).
exports.onListUpdated = onDocumentUpdated("lists/{listId}", async (event) => {
  const before = event.data.before.data();
  const after = event.data.after.data();
  if (!before || !after) return;

  const listId = event.params.listId;
  const listTitle = after.title || "Liste";
  const actor = after.lastModifiedBy;
  const recipients = [after.ownerEmail, ...(after.sharedWith || [])].filter(
    (email) => email && email !== actor,
  );

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
            title: listTitle,
            body: `Yeni madde eklendi: ${item.text}`,
            data: { type: "item_added", listId },
          }),
        );
      }
      continue;
    }

    if (!prev.isDone && item.isDone) {
      for (const email of recipients) {
        pushes.push(
          sendPushIfEnabled(email, {
            settingKey: "onItemCompleted",
            title: listTitle,
            body: `"${item.text}" tamamlandı`,
            data: { type: "item_completed", listId },
          }),
        );
      }
    }

    if (item.assignedTo && item.assignedTo !== prev.assignedTo && item.assignedTo !== actor) {
      pushes.push(
        sendPushIfEnabled(item.assignedTo, {
          settingKey: "onTaskAssigned",
          title: listTitle,
          body: `Size bir görev atandı: ${item.text}`,
          data: { type: "task_assigned", listId },
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
            await messaging.send({
              token,
              notification: {
                title: list.title || "Liste",
                body: `"${item.text}" hâlâ tamamlanmadı`,
              },
              data: { type: "long_pending", listId: doc.id },
            });
          }
          mutated = true;
          return { ...item, notifiedLongPendingAt: Timestamp.now() };
        }),
      );

      if (mutated) await doc.ref.update({ items: newItems });
    }),
  );
});
