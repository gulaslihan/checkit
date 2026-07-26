import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/text_format.dart';
import '../models/checklist.dart';
import '../models/checklist_item.dart';
import '../models/checklist_type.dart';
import 'auth_provider.dart';

final listsProvider = StateNotifierProvider<ListsNotifier, List<Checklist>>((ref) {
  final user = ref.watch(authStateProvider).value;
  return ListsNotifier(uid: user?.uid, email: user?.email);
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
  };
}

List<Map<String, dynamic>> checklistItemsToMaps(List<ChecklistItem> items) => items.map(checklistItemToMap).toList();

/// Firestore-backed list store. Merges two live queries — lists you own and
/// lists shared with your email — since Firestore can't OR across different
/// fields without a composite index.
class ListsNotifier extends StateNotifier<List<Checklist>> {
  final String? uid;
  final String? email;

  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('lists');

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _ownedSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sharedSub;
  List<Checklist> _owned = [];
  List<Checklist> _shared = [];

  ListsNotifier({required this.uid, required this.email}) : super([]) {
    if (uid == null) return;
    _ownedSub = _collection.where('ownerId', isEqualTo: uid).snapshots().listen((snapshot) {
      _owned = snapshot.docs.map(_fromDoc).toList();
      _emit();
    });
    if (email != null) {
      _sharedSub = _collection.where('sharedWith', arrayContains: email).snapshots().listen((snapshot) {
        _shared = snapshot.docs.map(_fromDoc).toList();
        _emit();
      });
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
      type: (data['type'] as String?) == 'temporary' ? ChecklistType.temporary : ChecklistType.permanent,
      category: data['category'] as String?,
      allowRating: data['allowRating'] as bool? ?? false,
      isCheckable: data['isCheckable'] as bool? ?? true,
      allowDueDates: data['allowDueDates'] as bool? ?? false,
      allowNotes: data['allowNotes'] as bool? ?? false,
      ownerEmail: data['ownerEmail'] as String?,
      sortIndex: data['sortIndex'] as int? ?? 0,
      sharedWith: List<String>.from(data['sharedWith'] as List? ?? const []),
      nicknames: Map<String, String>.from(data['nicknames'] as Map? ?? const {}),
      items: (data['items'] as List? ?? const [])
          .map((raw) => checklistItemFromMap(Map<String, dynamic>.from(raw as Map)))
          .toList(),
    );
  }

  Future<void> createList({
    required String title,
    required ChecklistType type,
    String? category,
    List<String> initialItemTexts = const [],
    bool allowRating = false,
    bool isCheckable = true,
    bool allowDueDates = false,
    bool allowNotes = false,
  }) async {
    if (uid == null) return;
    final now = DateTime.now();
    final items = [
      for (var i = 0; i < initialItemTexts.length; i++)
        ChecklistItem(id: '${now.microsecondsSinceEpoch}-$i', text: initialItemTexts[i], createdAt: now),
    ];
    await _collection.add({
      'ownerId': uid,
      'ownerEmail': email,
      'title': capitalizeFirst(title.trim()),
      'type': type == ChecklistType.temporary ? 'temporary' : 'permanent',
      'category': category,
      'allowRating': allowRating,
      'isCheckable': isCheckable,
      'allowDueDates': allowDueDates,
      'allowNotes': allowNotes,
      'sharedWith': <String>[],
      'items': checklistItemsToMaps(items),
      'sortIndex': now.millisecondsSinceEpoch,
    });
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
    required ChecklistType type,
    String? category,
    required bool allowRating,
    required bool isCheckable,
    required bool allowDueDates,
    required bool allowNotes,
  }) {
    return _collection.doc(listId).update({
      'title': capitalizeFirst(title.trim()),
      'type': type == ChecklistType.temporary ? 'temporary' : 'permanent',
      'category': category,
      'allowRating': allowRating,
      'isCheckable': isCheckable,
      'allowDueDates': allowDueDates,
      'allowNotes': allowNotes,
      // Backfills lists created before ownerEmail existed on the document.
      'ownerEmail': email,
    });
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
    await _collection.add({
      'ownerId': uid,
      'ownerEmail': email,
      'title': '${original.title} (Kopya)',
      'type': original.type == ChecklistType.temporary ? 'temporary' : 'permanent',
      'category': original.category,
      'allowRating': original.allowRating,
      'isCheckable': original.isCheckable,
      'allowDueDates': original.allowDueDates,
      'allowNotes': original.allowNotes,
      'sharedWith': <String>[],
      'items': checklistItemsToMaps(newItems),
      'sortIndex': now.millisecondsSinceEpoch,
    });
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
    final trimmed = capitalizeFirst(text.trim());
    if (trimmed.isEmpty) return Future.value();
    final list = _findLocal(listId);
    if (list == null) return Future.value();
    final item = ChecklistItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: trimmed,
      createdAt: DateTime.now(),
    );
    return _collection.doc(listId).update({
      'items': checklistItemsToMaps([...list.items, item]),
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
          ChecklistItem(id: '${now.microsecondsSinceEpoch}-$i', text: capitalizeFirst(texts[i].trim()), createdAt: now),
    ];
    if (newItems.isEmpty) return Future.value();
    return _collection.doc(listId).update({
      'items': checklistItemsToMaps([...list.items, ...newItems]),
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

  Future<void> resetList(String listId) {
    final list = _findLocal(listId);
    if (list == null) return Future.value();
    return _collection.doc(listId).update({
      'items': checklistItemsToMaps([for (final item in list.items) item.copyWith(isDone: false)]),
    });
  }

  Future<void> addCollaborator(String listId, String person) {
    final trimmed = person.trim();
    if (trimmed.isEmpty) return Future.value();
    return _collection.doc(listId).update({
      'sharedWith': FieldValue.arrayUnion([trimmed]),
    });
  }

  /// Also clears the person's assignment from any items, so nothing points
  /// at a collaborator who's no longer on the list.
  Future<void> removeCollaborator(String listId, String person) {
    final list = _findLocal(listId);
    if (list == null) return Future.value();
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
      FieldPath(['nicknames', email]): trimmed.isEmpty ? FieldValue.delete() : trimmed,
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
              )
            : item,
    ];
    return _collection.doc(listId).update({
      'items': checklistItemsToMaps(newItems),
      'lastModifiedBy': email,
    });
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
                text: capitalizeFirst(text.trim()),
                isDone: item.isDone,
                assignedTo: item.assignedTo,
                createdAt: item.createdAt,
                rating: item.rating,
                note: (note ?? '').trim().isEmpty ? null : note!.trim(),
                dueDate: clearDueDate ? null : (dueDate ?? item.dueDate),
              )
            : item,
    ];
    return _collection.doc(listId).update({'items': checklistItemsToMaps(newItems)});
  }
}
