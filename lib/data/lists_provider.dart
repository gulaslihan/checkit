import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/text_format.dart';
import '../models/checklist.dart';
import '../models/checklist_item.dart';
import 'auth_provider.dart';
import 'locale_provider.dart';

final listsProvider = StateNotifierProvider<ListsNotifier, List<Checklist>>((ref) {
  final user = ref.watch(authStateProvider).value;
  final localeOverride = ref.watch(localeProvider);
  return ListsNotifier(uid: user?.uid, email: user?.email, localeOverride: localeOverride);
});

/// True until the first Firestore snapshot has come back for both the
/// "lists I own" and "lists shared with me" queries — screens should show a
/// loading state instead of an empty state while this is true, otherwise a
/// user with real data sees a false "you have nothing" flash on every cold
/// start or slow connection.
final listsLoadingProvider = Provider<bool>((ref) {
  ref.watch(listsProvider);
  return !ref.watch(listsProvider.notifier).hasLoadedInitialData;
});

/// Shared with `account_deletion.dart`, which needs to scrub a departing
/// user's `assignedTo` from other people's lists via its own raw batch
/// write — kept here (not duplicated) so both stay in sync if item fields change.
ChecklistItem checklistItemFromMap(Map<String, dynamic> map) {
  return ChecklistItem(
    id: map['id'] as String,
    text: map['text'] as String? ?? '',
    isDone: map['isDone'] as bool? ?? false,
    assignedTo: map['assignedTo'] as String?,
    createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    rating: map['rating'] as int? ?? 0,
    note: map['note'] as String?,
    dueDate: (map['dueDate'] as Timestamp?)?.toDate(),
    subheading: map['subheading'] as String?,
  );
}

Map<String, dynamic> checklistItemToMap(ChecklistItem item) {
  return {
    'id': item.id,
    'text': item.text,
    'isDone': item.isDone,
    'assignedTo': item.assignedTo,
    'createdAt': Timestamp.fromDate(item.createdAt),
    'rating': item.rating,
    'note': item.note,
    'dueDate': item.dueDate == null ? null : Timestamp.fromDate(item.dueDate!),
    'subheading': item.subheading,
  };
}

List<Map<String, dynamic>> checklistItemsToMaps(List<ChecklistItem> items) => items.map(checklistItemToMap).toList();

/// Firestore-backed list store. Merges two live queries — lists you own and
/// lists shared with your email — since Firestore can't OR across different
/// fields without a composite index.
class ListsNotifier extends StateNotifier<List<Checklist>> {
  final String? uid;
  final String? email;
  final Locale? localeOverride;

  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('lists');

  /// Whether freeform text the user types (list titles, item text, notes,
  /// nicknames) should get Turkish-aware capitalization (dotted İ) — based
  /// on the manual language override if set, otherwise the device's own
  /// reported language (no BuildContext available down here in the data
  /// layer, so [PlatformDispatcher] instead of [Localizations.localeOf]).
  bool get _turkish =>
      (localeOverride?.languageCode ?? PlatformDispatcher.instance.locale.languageCode) == 'tr';

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _ownedSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sharedSub;
  List<Checklist> _owned = [];
  List<Checklist> _shared = [];

  bool _ownedLoaded = false;
  bool _sharedLoaded = false;

  /// True once the first snapshot has arrived for both queries — see
  /// [listsLoadingProvider] for why screens should watch this.
  bool get hasLoadedInitialData => _ownedLoaded && _sharedLoaded;

  ListsNotifier({required this.uid, required this.email, required this.localeOverride}) : super([]) {
    if (uid == null) {
      _ownedLoaded = true;
      _sharedLoaded = true;
      return;
    }
    _ownedSub = _collection.where('ownerId', isEqualTo: uid).snapshots().listen((snapshot) {
      _owned = snapshot.docs.map(_fromDoc).toList();
      _ownedLoaded = true;
      _emit();
    });
    if (email != null) {
      _sharedSub = _collection.where('sharedWith', arrayContains: email).snapshots().listen((snapshot) {
        _shared = snapshot.docs.map(_fromDoc).toList();
        _sharedLoaded = true;
        _emit();
      });
    } else {
      _sharedLoaded = true;
    }
  }

  void _emit() {
    final merged = <String, Checklist>{};
    for (final list in _owned) {
      merged[list.id] = list;
    }
    for (final list in _shared) {
      merged[list.id] = list;
    }
    state = merged.values.toList();
  }

  @override
  void dispose() {
    _ownedSub?.cancel();
    _sharedSub?.cancel();
    super.dispose();
  }

  Checklist? _findLocal(String listId) {
    final matches = state.where((l) => l.id == listId);
    return matches.isEmpty ? null : matches.first;
  }

  Checklist _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Checklist(
      id: doc.id,
      title: data['title'] as String? ?? '',
      category: data['category'] as String?,
      allowRating: data['allowRating'] as bool? ?? false,
      isCheckable: data['isCheckable'] as bool? ?? true,
      allowDueDates: data['allowDueDates'] as bool? ?? false,
      allowNotes: data['allowNotes'] as bool? ?? false,
      notificationsEnabled: data['notificationsEnabled'] as bool? ?? true,
      ownerEmail: data['ownerEmail'] as String?,
      sortIndex: data['sortIndex'] as int? ?? 0,
      sharedWith: List<String>.from(data['sharedWith'] as List? ?? const []),
      nicknames: Map<String, String>.from(data['nicknames'] as Map? ?? const {}),
      items: (data['items'] as List? ?? const [])
          .map((raw) => checklistItemFromMap(Map<String, dynamic>.from(raw as Map)))
          .toList(),
      archived: data['archived'] as bool? ?? false,
      archivedAt: (data['archivedAt'] as Timestamp?)?.toDate(),
      subheadingOrder: List<String>.from(data['subheadingOrder'] as List? ?? const []),
    );
  }

  Future<void> createList({
    required String title,
    String? category,
    List<String> initialItemTexts = const [],
    /// Parallel to [initialItemTexts] (same length) — lets a caller (e.g. the
    /// AI list generator) group initial items under sub-headings right away
    /// instead of a separate follow-up write. Omit for the common case of an
    /// ungrouped flat list.
    List<String?>? itemSubheadings,
    bool allowRating = false,
    bool isCheckable = true,
    bool allowDueDates = false,
    bool allowNotes = false,
    bool notificationsEnabled = true,
  }) async {
    if (uid == null) return;
    final now = DateTime.now();
    final items = [
      for (var i = 0; i < initialItemTexts.length; i++)
        ChecklistItem(
          id: '${now.microsecondsSinceEpoch}-$i',
          text: initialItemTexts[i],
          createdAt: now,
          subheading: itemSubheadings != null && i < itemSubheadings.length ? itemSubheadings[i] : null,
        ),
    ];
    final subheadingOrder = <String>[];
    for (final heading in itemSubheadings ?? const <String?>[]) {
      if (heading != null && heading.isNotEmpty && !subheadingOrder.contains(heading)) {
        subheadingOrder.add(heading);
      }
    }
    final batch = FirebaseFirestore.instance.batch();
    batch.set(_collection.doc(), {
      'ownerId': uid,
      'ownerEmail': email,
      'title': capitalizeFirst(title.trim(), turkish: _turkish),
      'category': category,
      'allowRating': allowRating,
      'isCheckable': isCheckable,
      'allowDueDates': allowDueDates,
      'allowNotes': allowNotes,
      'notificationsEnabled': notificationsEnabled,
      'sharedWith': <String>[],
      'items': checklistItemsToMaps(items),
      'sortIndex': now.millisecondsSinceEpoch,
      'archived': false,
      'subheadingOrder': subheadingOrder,
    });
    _incrementCreatedListCount(batch);
    await batch.commit();
  }

  /// Every code path that creates a new `lists` doc (manual or AI — no
  /// distinction for the subscription quota) must pair it with this same
  /// +1 in the SAME batch — the Firestore rules require it (see
  /// firestore.rules' `canCreateList()`, which uses getAfter() to enforce
  /// the pairing) and reject a list-only write. `set(merge: true)` rather
  /// than `update()` so this also works the very first time, before a
  /// `users/{uid}` doc exists yet (e.g. language sync hasn't run).
  void _incrementCreatedListCount(WriteBatch batch) {
    if (uid == null) return;
    batch.set(
      FirebaseFirestore.instance.collection('users').doc(uid),
      {'createdListCount': FieldValue.increment(1)},
      SetOptions(merge: true),
    );
  }

  /// Reassigns sortIndex for every list in [currentOrder] after a drag —
  /// simplest way to keep a strict, gap-free order regardless of how many
  /// lists moved.
  Future<void> reorderLists(List<Checklist> currentOrder, int oldIndex, int newIndex) async {
    final reordered = [...currentOrder];
    final moved = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, moved);

    final batch = FirebaseFirestore.instance.batch();
    for (var i = 0; i < reordered.length; i++) {
      batch.update(_collection.doc(reordered[i].id), {'sortIndex': reordered.length - i});
    }
    await batch.commit();
  }

  Future<void> updateListMeta(
    String listId, {
    required String title,
    String? category,
    required bool allowRating,
    required bool isCheckable,
    required bool allowDueDates,
    required bool allowNotes,
    required bool notificationsEnabled,
  }) {
    return _collection.doc(listId).update({
      'title': capitalizeFirst(title.trim(), turkish: _turkish),
      'category': category,
      'allowRating': allowRating,
      'isCheckable': isCheckable,
      'allowDueDates': allowDueDates,
      'allowNotes': allowNotes,
      'notificationsEnabled': notificationsEnabled,
      // Backfills lists created before ownerEmail existed on the document.
      'ownerEmail': email,
    });
  }

  /// Archives a list — hidden from the dashboard/pending-items view but not
  /// deleted; see the Arşiv screen. Offered whenever a list becomes fully
  /// completed (see list_detail_screen.dart), or manually at any time.
  Future<void> archiveList(String listId) {
    return _collection.doc(listId).update({'archived': true, 'archivedAt': Timestamp.now()});
  }

  Future<void> unarchiveList(String listId) {
    return _collection.doc(listId).update({'archived': false, 'archivedAt': FieldValue.delete()});
  }

  Future<void> setItemRating(String listId, String itemId, int rating) {
    final list = _findLocal(listId);
    if (list == null) return Future.value();
    final items = [
      for (final item in list.items) item.id == itemId ? item.copyWith(rating: rating) : item,
    ];
    return _collection.doc(listId).update({'items': checklistItemsToMaps(items)});
  }

  Future<void> deleteList(String listId) => _collection.doc(listId).delete();

  /// Duplicates a list as a fresh, unchecked copy (e.g. reuse a shopping
  /// list as a template for next week).
  Future<void> duplicateList(String listId) async {
    final original = _findLocal(listId);
    if (original == null || uid == null) return;
    final now = DateTime.now();
    final newItems = [
      for (var i = 0; i < original.items.length; i++)
        ChecklistItem(id: '${now.microsecondsSinceEpoch}-$i', text: original.items[i].text, createdAt: now),
    ];
    final batch = FirebaseFirestore.instance.batch();
    batch.set(_collection.doc(), {
      'ownerId': uid,
      'ownerEmail': email,
      'title': '${original.title} (Kopya)',
      'category': original.category,
      'allowRating': original.allowRating,
      'isCheckable': original.isCheckable,
      'allowDueDates': original.allowDueDates,
      'allowNotes': original.allowNotes,
      'notificationsEnabled': original.notificationsEnabled,
      'sharedWith': <String>[],
      'items': checklistItemsToMaps(newItems),
      'sortIndex': now.millisecondsSinceEpoch,
      'archived': false,
    });
    _incrementCreatedListCount(batch);
    await batch.commit();
  }

  /// Toggles an item's done state. Whether a fully-checked temporary list
  /// gets deleted is decided by the UI (with a confirmation dialog) — this
  /// just flips the one item.
  Future<void> toggleItem(String listId, String itemId) {
    final list = _findLocal(listId);
    if (list == null) return Future.value();
    final newItems = [
      for (final item in list.items) item.id == itemId ? item.copyWith(isDone: !item.isDone) : item,
    ];
    return _collection.doc(listId).update({
      'items': checklistItemsToMaps(newItems),
      'lastModifiedBy': email,
    });
  }

  /// True when checking [itemId] on would leave every item on [listId] done.
  bool wouldCompleteList(String listId, String itemId) {
    final list = _findLocal(listId);
    if (list == null) return false;
    final target = list.items.where((i) => i.id == itemId);
    if (target.isEmpty || target.first.isDone) return false;
    return list.items.every((i) => i.id == itemId || i.isDone);
  }

  Future<void> addItem(String listId, String text) {
    final trimmed = capitalizeFirst(text.trim(), turkish: _turkish);
    if (trimmed.isEmpty) return Future.value();
    final list = _findLocal(listId);
    if (list == null) return Future.value();
    final item = ChecklistItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: trimmed,
      createdAt: DateTime.now(),
    );
    return _collection.doc(listId).update({
      'items': checklistItemsToMaps([item, ...list.items]),
      'lastModifiedBy': email,
    });
  }

  /// Bulk-adds one item per non-empty line — used by paste-to-import.
  Future<void> addItems(String listId, List<String> texts) {
    final list = _findLocal(listId);
    if (list == null) return Future.value();
    final now = DateTime.now();
    final newItems = [
      for (var i = 0; i < texts.length; i++)
        if (texts[i].trim().isNotEmpty)
          ChecklistItem(id: '${now.microsecondsSinceEpoch}-$i', text: capitalizeFirst(texts[i].trim(), turkish: _turkish), createdAt: now),
    ];
    if (newItems.isEmpty) return Future.value();
    return _collection.doc(listId).update({
      'items': checklistItemsToMaps([...newItems, ...list.items]),
      'lastModifiedBy': email,
    });
  }

  /// Reorders within the not-yet-completed items only — completed items stay
  /// pinned at the bottom regardless of [oldIndex]/[newIndex].
  Future<void> reorderItems(String listId, int oldIndex, int newIndex) {
    final list = _findLocal(listId);
    if (list == null) return Future.value();
    return _collection.doc(listId).update({'items': checklistItemsToMaps(_reordered(list.items, oldIndex, newIndex))});
  }

  List<ChecklistItem> _reordered(List<ChecklistItem> items, int oldIndex, int newIndex) {
    final incomplete = items.where((i) => !i.isDone).toList();
    final complete = items.where((i) => i.isDone).toList();
    if (oldIndex < 0 || oldIndex >= incomplete.length) return items;
    final target = newIndex.clamp(0, incomplete.length - 1);
    final moved = incomplete.removeAt(oldIndex);
    incomplete.insert(target, moved);
    return [...incomplete, ...complete];
  }

  /// Drags every item in [itemIds] together to sit as a block at the drop
  /// point, keeping their relative order — used when several items are
  /// selected and one of them is dragged. Completed items are untouched
  /// (always pinned at the bottom, same as [reorderItems]).
  Future<void> reorderItemsGroup(String listId, Set<String> itemIds, int oldIndex, int newIndex) {
    final list = _findLocal(listId);
    if (list == null) return Future.value();
    return _collection
        .doc(listId)
        .update({'items': checklistItemsToMaps(_reorderedGroup(list.items, itemIds, oldIndex, newIndex))});
  }

  List<ChecklistItem> _reorderedGroup(List<ChecklistItem> items, Set<String> itemIds, int oldIndex, int newIndex) {
    final incomplete = items.where((i) => !i.isDone).toList();
    final complete = items.where((i) => i.isDone).toList();
    if (oldIndex < 0 || oldIndex >= incomplete.length) return items;

    final moving = incomplete.where((i) => itemIds.contains(i.id)).toList();
    if (moving.isEmpty) return items;

    // What the dragged item would land next to per the single-item
    // convention, skipping past any other item that's also moving — that's
    // where the whole block should end up.
    final withoutDragged = [...incomplete]..removeAt(oldIndex);
    final clampedNew = newIndex.clamp(0, withoutDragged.length);
    String? anchorId;
    for (var i = clampedNew; i < withoutDragged.length; i++) {
      if (!itemIds.contains(withoutDragged[i].id)) {
        anchorId = withoutDragged[i].id;
        break;
      }
    }

    final remaining = incomplete.where((i) => !itemIds.contains(i.id)).toList();
    final insertAt = anchorId == null ? remaining.length : remaining.indexWhere((i) => i.id == anchorId);
    remaining.insertAll(insertAt < 0 ? remaining.length : insertAt, moving);

    return [...remaining, ...complete];
  }

  Future<void> restoreItem(String listId, ChecklistItem item) {
    final list = _findLocal(listId);
    if (list == null) return Future.value();
    return _collection.doc(listId).update({'items': checklistItemsToMaps([...list.items, item])});
  }

  Future<void> removeItem(String listId, String itemId) {
    final list = _findLocal(listId);
    if (list == null) return Future.value();
    return _collection.doc(listId).update({
      'items': checklistItemsToMaps(list.items.where((item) => item.id != itemId).toList()),
    });
  }

  /// Removes [itemIds] from [sourceListId] and prepends them (same id and
  /// creation time — this is a relocation, not a new item) onto
  /// [targetListId], in one atomic batch. Clears `assignedTo` when that
  /// person isn't a collaborator on the target list, so nothing points at
  /// someone who can't see it there.
  Future<void> moveItemsToList(String sourceListId, String targetListId, Set<String> itemIds) async {
    final source = _findLocal(sourceListId);
    final target = _findLocal(targetListId);
    if (source == null || target == null || itemIds.isEmpty) return;

    final moving = [
      for (final item in source.items)
        if (itemIds.contains(item.id))
          ChecklistItem(
            id: item.id,
            text: item.text,
            isDone: item.isDone,
            assignedTo: target.assignableTo.contains(item.assignedTo) ? item.assignedTo : null,
            createdAt: item.createdAt,
            rating: item.rating,
            note: item.note,
            dueDate: item.dueDate,
            subheading: item.subheading,
          ),
    ];
    if (moving.isEmpty) return;

    final remainingSource = source.items.where((item) => !itemIds.contains(item.id)).toList();

    final batch = FirebaseFirestore.instance.batch();
    batch.update(_collection.doc(sourceListId), {'items': checklistItemsToMaps(remainingSource)});
    batch.update(_collection.doc(targetListId), {
      'items': checklistItemsToMaps([...moving, ...target.items]),
      'lastModifiedBy': email,
    });
    await batch.commit();
  }

  /// Copies [itemIds] from [sourceListId] into [targetListId] as fresh items
  /// (new ids, `createdAt` reset to now — same convention as
  /// [duplicateList]) — [sourceListId] is left untouched.
  Future<void> copyItemsToList(String sourceListId, String targetListId, Set<String> itemIds) async {
    final source = _findLocal(sourceListId);
    final target = _findLocal(targetListId);
    if (source == null || target == null || itemIds.isEmpty) return;

    final now = DateTime.now();
    final toCopy = source.items.where((item) => itemIds.contains(item.id)).toList();
    final copied = [
      for (var i = 0; i < toCopy.length; i++)
        ChecklistItem(
          id: '${now.microsecondsSinceEpoch}-$i',
          text: toCopy[i].text,
          isDone: toCopy[i].isDone,
          assignedTo: target.assignableTo.contains(toCopy[i].assignedTo) ? toCopy[i].assignedTo : null,
          createdAt: now,
          rating: toCopy[i].rating,
          note: toCopy[i].note,
          dueDate: toCopy[i].dueDate,
          subheading: toCopy[i].subheading,
        ),
    ];
    if (copied.isEmpty) return;

    await _collection.doc(targetListId).update({
      'items': checklistItemsToMaps([...copied, ...target.items]),
      'lastModifiedBy': email,
    });
  }

  Future<void> resetList(String listId) {
    final list = _findLocal(listId);
    if (list == null) return Future.value();
    return _collection.doc(listId).update({
      'items': checklistItemsToMaps([for (final item in list.items) item.copyWith(isDone: false)]),
    });
  }

  /// Also clears the person's assignment from any items, so nothing points
  /// at a collaborator who's no longer on the list. Skips resending `items`
  /// entirely when nothing was assigned to them — a non-owner leaving (see
  /// the firestore.rules self-leave clause) is only allowed to touch
  /// `sharedWith`/`items`, and re-serializing an unchanged `items` array
  /// still risks Firestore treating it as a diff (e.g. Timestamp round-trip
  /// precision), so the common case avoids touching it at all.
  Future<void> removeCollaborator(String listId, String person) {
    final list = _findLocal(listId);
    if (list == null) return Future.value();
    if (!list.items.any((item) => item.assignedTo == person)) {
      return _collection.doc(listId).update({'sharedWith': FieldValue.arrayRemove([person])});
    }
    final newItems = [
      for (final item in list.items)
        item.assignedTo == person
            ? ChecklistItem(
                id: item.id,
                text: item.text,
                isDone: item.isDone,
                assignedTo: null,
                createdAt: item.createdAt,
                rating: item.rating,
                note: item.note,
                dueDate: item.dueDate,
                subheading: item.subheading,
              )
            : item,
    ];
    return _collection.doc(listId).update({
      'sharedWith': FieldValue.arrayRemove([person]),
      'items': checklistItemsToMaps(newItems),
    });
  }

  /// Sets or clears (pass null/empty) this list's nickname for [email] —
  /// owner-only, same as any other list-metadata field.
  ///
  /// Uses [FieldPath] rather than a dotted `'nicknames.$email'` string:
  /// emails contain dots themselves, and Firestore's dotted-string update
  /// syntax treats every dot as a nesting level — it would silently split
  /// "a.b@x.com" into nested maps instead of one literal key. FieldPath's
  /// segment list has no such ambiguity.
  Future<void> setNickname(String listId, String email, String? nickname) {
    final trimmed = (nickname ?? '').trim();
    return _collection.doc(listId).update({
      FieldPath(['nicknames', email]): trimmed.isEmpty ? FieldValue.delete() : capitalizeFirst(trimmed, turkish: _turkish),
    });
  }

  Future<void> assignItem(String listId, String itemId, String? assignee) {
    final list = _findLocal(listId);
    if (list == null) return Future.value();
    final newItems = [
      for (final item in list.items)
        item.id == itemId
            ? ChecklistItem(
                id: item.id,
                text: item.text,
                isDone: item.isDone,
                assignedTo: assignee,
                createdAt: item.createdAt,
                rating: item.rating,
                note: item.note,
                dueDate: item.dueDate,
                subheading: item.subheading,
              )
            : item,
    ];
    return _collection.doc(listId).update({
      'items': checklistItemsToMaps(newItems),
      'lastModifiedBy': email,
    });
  }

  /// Sets (or clears, when null/empty) the sub-heading for every item in
  /// [itemIds] in one write — used by the selection-mode "assign to
  /// heading" action, and to delete a heading entirely (call with null; see
  /// [renameSubheading] for renaming, which preserves position instead).
  ///
  /// Also keeps `subheadingOrder` in sync: a brand-new heading name is
  /// prepended (shows at the top — the alternative, leaving order to
  /// whatever position its first item happened to occupy, put new headings
  /// in unpredictable/low spots), and any heading left with zero items after
  /// this write is dropped from the order.
  Future<void> setItemsSubheading(String listId, Set<String> itemIds, String? subheading) {
    final list = _findLocal(listId);
    if (list == null || itemIds.isEmpty) return Future.value();
    final trimmed = (subheading ?? '').trim();
    final newValue = trimmed.isEmpty ? null : capitalizeFirst(trimmed, turkish: _turkish);
    final newItems = [
      for (final item in list.items)
        itemIds.contains(item.id)
            ? ChecklistItem(
                id: item.id,
                text: item.text,
                isDone: item.isDone,
                assignedTo: item.assignedTo,
                createdAt: item.createdAt,
                rating: item.rating,
                note: item.note,
                dueDate: item.dueDate,
                subheading: newValue,
              )
            : item,
    ];

    final remainingHeadings = newItems.map((i) => i.subheading?.trim()).whereType<String>().where((h) => h.isNotEmpty).toSet();
    var newOrder = list.subheadingOrder.where(remainingHeadings.contains).toList();
    if (newValue != null && !newOrder.contains(newValue)) {
      newOrder = [newValue, ...newOrder];
    }

    return _collection.doc(listId).update({
      'items': checklistItemsToMaps(newItems),
      'subheadingOrder': newOrder,
    });
  }

  /// Renames a heading in place — keeps its position in `subheadingOrder`,
  /// applied to every item currently carrying [oldName]. If [newName]
  /// collides with an existing heading, the two merge (the old slot is
  /// dropped; items just carry the already-existing name).
  Future<void> renameSubheading(String listId, String oldName, String newName) {
    final list = _findLocal(listId);
    if (list == null) return Future.value();
    final trimmedNew = capitalizeFirst(newName.trim(), turkish: _turkish);
    if (trimmedNew.isEmpty || trimmedNew == oldName) return Future.value();

    final newItems = [
      for (final item in list.items)
        item.subheading?.trim() == oldName
            ? ChecklistItem(
                id: item.id,
                text: item.text,
                isDone: item.isDone,
                assignedTo: item.assignedTo,
                createdAt: item.createdAt,
                rating: item.rating,
                note: item.note,
                dueDate: item.dueDate,
                subheading: trimmedNew,
              )
            : item,
    ];

    final mergesIntoExisting = list.subheadingOrder.contains(trimmedNew);
    final newOrder = <String>[
      for (final h in list.subheadingOrder)
        if (h != oldName)
          h
        else if (!mergesIntoExisting)
          trimmedNew,
    ];

    return _collection.doc(listId).update({
      'items': checklistItemsToMaps(newItems),
      'subheadingOrder': newOrder,
    });
  }

  /// Moves [heading] to sit immediately before/after [anchorHeading] within
  /// `subheadingOrder`. Name-based rather than index-based: the on-screen
  /// heading list can be a filtered subset of the full stored order (a
  /// heading with zero currently-incomplete items renders no section at
  /// all), so a raw index from that filtered view wouldn't line up with
  /// positions in the full order — same reasoning as
  /// [reorderItemRelativeTo] for items within a section.
  Future<void> reorderSubheadingRelativeTo(
    String listId,
    String heading, {
    required String? anchorHeading,
    required bool before,
  }) {
    final list = _findLocal(listId);
    if (list == null) return Future.value();
    final order = [...list.subheadingOrder];
    final draggedIndex = order.indexOf(heading);
    if (draggedIndex < 0) return Future.value();
    order.removeAt(draggedIndex);
    final anchorIndex = anchorHeading == null ? -1 : order.indexOf(anchorHeading);
    if (anchorIndex < 0) {
      order.add(heading);
    } else {
      order.insert(before ? anchorIndex : anchorIndex + 1, heading);
    }
    return _collection.doc(listId).update({'subheadingOrder': order});
  }

  /// Moves [draggedId] to sit immediately before/after [anchorId] within the
  /// not-yet-completed items — used by a section's own drag-reorder, where
  /// the visible list is a subset of the full item array (grouped by
  /// heading) so plain index math (see [reorderItems]) doesn't apply; an
  /// anchor already inside the same section keeps the move scoped to it.
  Future<void> reorderItemRelativeTo(String listId, String draggedId, {required String anchorId, required bool before}) {
    final list = _findLocal(listId);
    if (list == null) return Future.value();
    final incomplete = list.items.where((i) => !i.isDone).toList();
    final complete = list.items.where((i) => i.isDone).toList();
    final draggedIndex = incomplete.indexWhere((i) => i.id == draggedId);
    if (draggedIndex < 0) return Future.value();
    final dragged = incomplete.removeAt(draggedIndex);
    final anchorIndex = incomplete.indexWhere((i) => i.id == anchorId);
    if (anchorIndex < 0) {
      incomplete.add(dragged);
    } else {
      incomplete.insert(before ? anchorIndex : anchorIndex + 1, dragged);
    }
    return _collection.doc(listId).update({'items': checklistItemsToMaps([...incomplete, ...complete])});
  }

  /// Same as [reorderItemRelativeTo] but for a whole selected group at once
  /// (see [reorderItemsGroup] for the flat-list equivalent) — the group
  /// lands together immediately before/after [anchorId], which must not
  /// itself be one of [itemIds].
  Future<void> reorderItemsGroupRelativeTo(
    String listId,
    Set<String> itemIds, {
    required String? anchorId,
    required bool before,
  }) {
    final list = _findLocal(listId);
    if (list == null) return Future.value();
    final incomplete = list.items.where((i) => !i.isDone).toList();
    final complete = list.items.where((i) => i.isDone).toList();
    final moving = incomplete.where((i) => itemIds.contains(i.id)).toList();
    if (moving.isEmpty) return Future.value();
    final remaining = incomplete.where((i) => !itemIds.contains(i.id)).toList();
    int insertAt;
    if (anchorId == null) {
      insertAt = remaining.length;
    } else {
      final idx = remaining.indexWhere((i) => i.id == anchorId);
      insertAt = idx < 0 ? remaining.length : (before ? idx : idx + 1);
    }
    remaining.insertAll(insertAt, moving);
    return _collection.doc(listId).update({'items': checklistItemsToMaps([...remaining, ...complete])});
  }

  /// Edits an item's text/note/due date in one write. [dueDate] is only
  /// applied when [clearDueDate] is false, so callers can distinguish
  /// "leave unchanged" from "explicitly clear the date".
  Future<void> updateItemDetails(
    String listId,
    String itemId, {
    required String text,
    String? note,
    DateTime? dueDate,
    bool clearDueDate = false,
  }) {
    final list = _findLocal(listId);
    if (list == null) return Future.value();
    final newItems = [
      for (final item in list.items)
        item.id == itemId
            ? ChecklistItem(
                id: item.id,
                text: capitalizeFirst(text.trim(), turkish: _turkish),
                isDone: item.isDone,
                assignedTo: item.assignedTo,
                createdAt: item.createdAt,
                rating: item.rating,
                note: (note ?? '').trim().isEmpty ? null : capitalizeFirst(note!.trim(), turkish: _turkish),
                dueDate: clearDueDate ? null : (dueDate ?? item.dueDate),
                subheading: item.subheading,
              )
            : item,
    ];
    return _collection.doc(listId).update({'items': checklistItemsToMaps(newItems)});
  }
}
