import 'checklist_item.dart';
import 'checklist_type.dart';

class Checklist {
  final String id;
  final String title;
  final ChecklistType type;
  final String? category;
  final List<ChecklistItem> items;
  final List<String> sharedWith;
  final String? ownerEmail;

  /// When true, list detail shows a 5-star rating control per item —
  /// independent of the checkbox/completion logic.
  final bool allowRating;

  /// When false, items have no checkbox at all — the list is purely for
  /// keeping/ordering items (e.g. a reference list), and `type`'s
  /// permanent/temporary tick behavior does not apply.
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

  const Checklist({
    required this.id,
    required this.title,
    required this.type,
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
      type: type,
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
    );
  }
}
