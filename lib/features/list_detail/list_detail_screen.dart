import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/error_feedback.dart';
import '../../core/utils/person_label.dart';
import '../../core/widgets/home_button.dart';
import '../../data/lists_provider.dart';
import '../../models/checklist.dart';
import '../../models/checklist_item.dart';
import '../../models/checklist_type.dart';
import '../sharing/share_screen.dart';
import 'widgets/add_item_bar.dart';
import 'widgets/bulk_import_sheet.dart';
import 'widgets/checklist_item_tile.dart';
import 'widgets/item_editor_sheet.dart';

/// Unchecked items keep their (reorderable) order at the top; checked items
/// sink to the bottom, in the order they were checked.
List<ChecklistItem> _sortedForDisplay(List<ChecklistItem> items) {
  final incomplete = items.where((item) => !item.isDone).toList();
  final complete = items.where((item) => item.isDone).toList();
  return [...incomplete, ...complete];
}

/// Re-sorts the not-yet-completed items by due date (soonest first,
/// undated items last) — a display-only transform, doesn't touch storage
/// order, so it can be toggled without disturbing manual drag order.
List<ChecklistItem> _sortedByDueDate(List<ChecklistItem> items) {
  final incomplete = items.where((item) => !item.isDone).toList()
    ..sort((a, b) {
      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });
  final complete = items.where((item) => item.isDone).toList();
  return [...incomplete, ...complete];
}

class ListDetailScreen extends ConsumerStatefulWidget {
  final String listId;

  const ListDetailScreen({super.key, required this.listId});

  @override
  ConsumerState<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends ConsumerState<ListDetailScreen> {
  String? _assigneeFilter;
  bool _selectionMode = false;
  bool _sortByDate = false;
  final Set<String> _selectedItemIds = {};

  void _toggleSelectionMode() {
    setState(() {
      _selectionMode = !_selectionMode;
      _selectedItemIds.clear();
    });
  }

  Future<void> _createListFromSelection(Checklist list, ListsNotifier notifier) async {
    final selectedTexts = list.items.where((i) => _selectedItemIds.contains(i.id)).map((i) => i.text).toList();
    if (selectedTexts.isEmpty) return;

    final controller = TextEditingController(text: '${list.title} (Seçilenler)');
    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Yeni Liste Adı'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Vazgeç')),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('Oluştur'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (title == null || title.isEmpty || !mounted) return;

    final succeeded = await runGuarded(
      context,
      () => notifier.createList(
        title: title,
        type: list.type,
        category: list.category,
        isCheckable: list.isCheckable,
        allowRating: list.allowRating,
        initialItemTexts: selectedTexts,
      ),
    );
    if (!succeeded) return;

    if (mounted) {
      setState(() {
        _selectionMode = false;
        _selectedItemIds.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"$title" oluşturuldu (${selectedTexts.length} madde)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lists = ref.watch(listsProvider);
    final matches = lists.where((l) => l.id == widget.listId);

    if (matches.isEmpty) {
      // The list was removed (e.g. a temporary list emptied out) — leave this screen.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    final list = matches.first;
    final isPermanent = list.type == ChecklistType.permanent;
    final notifier = ref.read(listsProvider.notifier);
    final allDisplayItems = _sortedForDisplay(list.items);
    final incompleteCount = list.items.where((i) => !i.isDone).length;

    final filterActive = _assigneeFilter != null;
    final assigneeFiltered = filterActive
        ? allDisplayItems.where((i) => i.assignedTo == _assigneeFilter).toList()
        : allDisplayItems;
    final displayItems = _sortByDate ? _sortedByDueDate(assigneeFiltered) : assigneeFiltered;
    final reorderEnabled = !filterActive && !_selectionMode && !_sortByDate;

    return Scaffold(
      appBar: AppBar(
        title: _selectionMode
            ? Text('${_selectedItemIds.length} seçildi')
            : Text(list.title, overflow: TextOverflow.ellipsis),
        leading: _selectionMode
            ? IconButton(icon: const Icon(Icons.close_rounded), onPressed: _toggleSelectionMode)
            : null,
        actions: _selectionMode
            ? [
                TextButton(
                  onPressed: _selectedItemIds.isEmpty ? null : () => _createListFromSelection(list, notifier),
                  child: const Text('Yeni Liste Oluştur'),
                ),
                const SizedBox(width: 8),
              ]
            : [
                IconButton(
                  tooltip: 'Paylaş',
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ShareScreen(listId: list.id)),
                    );
                  },
                ),
                PopupMenuButton<String>(
                  tooltip: 'Diğer işlemler',
                  onSelected: (value) {
                    switch (value) {
                      case 'reset':
                        runGuarded(context, () => notifier.resetList(list.id));
                        break;
                      case 'sort_date':
                        setState(() => _sortByDate = !_sortByDate);
                        break;
                      case 'select':
                        _toggleSelectionMode();
                        break;
                      case 'paste':
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                          builder: (_) => BulkImportSheet(
                            onImport: (lines) => runGuarded(context, () => notifier.addItems(list.id, lines)),
                          ),
                        );
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (isPermanent && list.isCheckable && list.completedCount > 0)
                      const PopupMenuItem(
                        value: 'reset',
                        child: _MenuRow(icon: Icons.refresh_rounded, label: 'Sıfırla'),
                      ),
                    if (list.allowDueDates)
                      PopupMenuItem(
                        value: 'sort_date',
                        child: _MenuRow(
                          icon: Icons.calendar_month_rounded,
                          label: _sortByDate ? 'Tarihe göre sıralamayı kapat' : 'Tarihe göre sırala',
                        ),
                      ),
                    if (list.items.isNotEmpty)
                      const PopupMenuItem(
                        value: 'select',
                        child: _MenuRow(icon: Icons.content_paste_go_rounded, label: 'Maddelerden liste oluştur'),
                      ),
                    const PopupMenuItem(
                      value: 'paste',
                      child: _MenuRow(icon: Icons.playlist_add_check_rounded, label: 'Yapıştırarak ekle'),
                    ),
                  ],
                ),
                const HomeButton(),
              ],
      ),
      body: Column(
        children: [
          if (list.isShared && !_selectionMode) _AssigneeFilterBar(
            people: list.assignableTo,
            nicknames: list.nicknames,
            selected: _assigneeFilter,
            onSelected: (person) => setState(() => _assigneeFilter = person),
          ),
          Expanded(
            child: displayItems.isEmpty
                ? const _EmptyItemsState()
                : !reorderEnabled
                ? ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    itemCount: displayItems.length,
                    itemBuilder: (context, index) =>
                        _buildTile(context, list, notifier, displayItems[index], null),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    buildDefaultDragHandles: false,
                    itemCount: displayItems.length,
                    onReorderItem: (oldIndex, newIndex) {
                      if (oldIndex >= incompleteCount) return;
                      final clampedNew = newIndex > incompleteCount ? incompleteCount : newIndex;
                      runGuarded(context, () => notifier.reorderItems(list.id, oldIndex, clampedNew));
                    },
                    itemBuilder: (context, index) {
                      final isIncomplete = index < incompleteCount;
                      return _buildTile(
                        context,
                        list,
                        notifier,
                        displayItems[index],
                        isIncomplete ? index : null,
                      );
                    },
                  ),
          ),
          if (!_selectionMode)
            AddItemBar(onAdd: (text) => runGuarded(context, () => notifier.addItem(list.id, text))),
        ],
      ),
    );
  }

  Widget _buildTile(
    BuildContext context,
    Checklist list,
    ListsNotifier notifier,
    ChecklistItem item,
    int? dragIndex,
  ) {
    return ChecklistItemTile(
      key: ValueKey(item.id),
      item: item,
      isCheckable: list.isCheckable,
      showRating: list.allowRating,
      showNote: list.allowNotes,
      showDueDate: list.allowDueDates,
      onRatingChanged: (r) => runGuarded(context, () => notifier.setItemRating(list.id, item.id, r)),
      collaborators: list.assignableTo,
      nicknames: list.nicknames,
      onAssigneeChanged: (a) => runGuarded(context, () => notifier.assignItem(list.id, item.id, a)),
      dragIndex: dragIndex,
      selectionMode: _selectionMode,
      selected: _selectedItemIds.contains(item.id),
      onSelectedChanged: (v) => setState(() {
        if (v) {
          _selectedItemIds.add(item.id);
        } else {
          _selectedItemIds.remove(item.id);
        }
      }),
      onEdit: () {
        showItemEditorSheet(
          context: context,
          item: item,
          allowNotes: list.allowNotes,
          allowDueDates: list.allowDueDates,
          onSave: (result) => runGuarded(
            context,
            () => notifier.updateItemDetails(
              list.id,
              item.id,
              text: result.text,
              note: result.note,
              dueDate: result.dueDate,
              clearDueDate: result.clearDueDate,
            ),
          ),
        );
      },
      onToggle: (_) async {
        final isLastForTemp = list.type == ChecklistType.temporary && notifier.wouldCompleteList(list.id, item.id);
        if (!isLastForTemp) {
          await runGuarded(context, () => notifier.toggleItem(list.id, item.id));
          return;
        }

        final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Liste tamamlandı'),
            content: Text('"${list.title}" listesindeki tüm maddeler tamamlanmış olacak. Listeyi silmek ister misiniz?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Listede kalsın'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Sil', style: TextStyle(color: AppColors.danger)),
              ),
            ],
          ),
        );
        if (!context.mounted) return;

        if (!await runGuarded(context, () => notifier.toggleItem(list.id, item.id))) return;
        if (shouldDelete == true && context.mounted) {
          final deleted = await runGuarded(context, () => notifier.deleteList(list.id));
          if (deleted && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('"${list.title}" silindi')),
            );
          }
        }
      },
      onDismissed: () async {
        if (!await runGuarded(context, () => notifier.removeItem(list.id, item.id))) return;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"${item.text}" silindi'),
              action: SnackBarAction(
                label: 'Geri Al',
                onPressed: () => runGuarded(context, () => notifier.restoreItem(list.id, item)),
              ),
            ),
          );
        }
      },
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MenuRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Text(label),
      ],
    );
  }
}

class _AssigneeFilterBar extends StatelessWidget {
  final List<String> people;
  final Map<String, String> nicknames;
  final String? selected;
  final ValueChanged<String?> onSelected;

  const _AssigneeFilterBar({
    required this.people,
    this.nicknames = const {},
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        children: [
          _chip(context, label: 'Tümü', isSelected: selected == null, onTap: () => onSelected(null)),
          const SizedBox(width: 8),
          for (final person in people) ...[
            _chip(
              context,
              label: personLabel(person) == 'Siz' ? 'Siz' : (nicknames[person] ?? person),
              isSelected: selected == person,
              onTap: () => onSelected(person),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, {required String label, required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class _EmptyItemsState extends StatelessWidget {
  const _EmptyItemsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.playlist_add_rounded, size: 56, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            const Text('Henüz madde yok', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            const Text(
              'Aşağıdan yazarak/mikrofonla ekleyin ya da yapıştırarak toplu aktarın',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
