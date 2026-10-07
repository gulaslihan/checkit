import 'checklist_item.dart';

class Checklist {
  final String id;
  final String title;
  final String? category;
  final List<ChecklistItem> items;
  final List<String> sharedWith;
  final String? ownerEmail;

  /// When true, list detail shows a 5-star rating control per item —
  /// independent of the checkbox/completion logic.
  final bool allowRating;

  /// When false, items have no checkbox at all — the list is purely for
  /// keeping/ordering items (e.g. a reference list).
  final bool isCheckable;

  /// When true, items can carry a due date/time and the list can be
  /// sorted by it.
  final bool allowDueDates;

  /// When true, items can carry a short free-text note.
  final bool allowNotes;

  /// Drives dashboard order — higher sorts first. Any collaborator can
  /// reorder (same trust model as reordering items in a shared list).
  final int sortIndex;

  /// Per-list display name for a collaborator's email (e.g. "Halası"
  /// instead of their raw email) — only meaningful within this list, set by
  /// the owner. Falls back to the raw email wherever unset.
  final Map<String, String> nicknames;

  /// Archived lists are hidden from the dashboard and pending-items view but
  /// stay fully intact — see the Arşiv screen. Set when a completed list is
  /// archived instead of reset/deleted (see [ListsNotifier.archiveList]).
  final bool archived;
  final DateTime? archivedAt;

  /// Display order for this list's sub-headings (see [ChecklistItem.subheading])
  /// — a heading isn't a separate stored entity, just a label items carry, so
  /// this is the only place its position is tracked. A newly-created heading
  /// is prepended (see [ListsNotifier.setItemsSubheading]); drag-reordering
  /// in list_detail_screen.dart writes this list directly.
  final List<String> subheadingOrder;

  const Checklist({
    required this.id,
    required this.title,
    this.category,
    this.items = const [],
    this.sharedWith = const [],
    this.allowRating = false,
    this.isCheckable = true,
    this.allowDueDates = false,
    this.allowNotes = false,
    this.ownerEmail,
    this.sortIndex = 0,
    this.nicknames = const {},
    this.archived = false,
    this.archivedAt,
    this.subheadingOrder = const [],
  });

  int get completedCount => items.where((i) => i.isDone).length;
  int get totalCount => items.length;
  bool get isShared => sharedWith.isNotEmpty;

  /// Everyone who can be assigned an item: the owner plus every collaborator.
  List<String> get assignableTo => [?ownerEmail, ...sharedWith];

  /// How this list refers to [email] — their nickname if the owner set one,
  /// otherwise the raw email. Doesn't handle "Siz" (that's `personLabel`'s job).
  String labelFor(String email) => nicknames[email] ?? email;

  Checklist copyWith({
    String? title,
    List<ChecklistItem>? items,
    List<String>? sharedWith,
    bool? allowRating,
    bool? isCheckable,
    bool? allowDueDates,
    bool? allowNotes,
    Map<String, String>? nicknames,
  }) {
    return Checklist(
      id: id,
      title: title ?? this.title,
      category: category,
      items: items ?? this.items,
      sharedWith: sharedWith ?? this.sharedWith,
      allowRating: allowRating ?? this.allowRating,
      isCheckable: isCheckable ?? this.isCheckable,
      allowDueDates: allowDueDates ?? this.allowDueDates,
      allowNotes: allowNotes ?? this.allowNotes,
      ownerEmail: ownerEmail,
      sortIndex: sortIndex,
      nicknames: nicknames ?? this.nicknames,
      archived: archived,
      archivedAt: archivedAt,
      subheadingOrder: subheadingOrder,
    );
  }
}
