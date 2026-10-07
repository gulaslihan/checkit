import '../../models/checklist.dart';

/// Shared by the dashboard and archive screens — matches a list if [query]
/// appears in its title or any item's text.
List<Checklist> filterLists(List<Checklist> lists, String query) {
  if (query.trim().isEmpty) return lists;
  final q = query.trim().toLowerCase();
  return lists.where((list) {
    final titleMatch = list.title.toLowerCase().contains(q);
    final itemMatch = list.items.any((item) => item.text.toLowerCase().contains(q));
    return titleMatch || itemMatch;
  }).toList();
}
