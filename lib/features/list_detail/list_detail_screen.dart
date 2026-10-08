import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/error_feedback.dart';
import '../../core/utils/person_label.dart';
import '../../core/widgets/home_button.dart';
import '../../data/lists_provider.dart';
import '../../data/notification_settings_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/checklist.dart';
import '../../models/checklist_item.dart';
import '../dashboard/widgets/list_search_bar.dart';
import '../sharing/share_screen.dart';
import 'widgets/add_item_bar.dart';
import 'widgets/bulk_import_sheet.dart';
import 'widgets/checklist_item_tile.dart';
import 'widgets/item_editor_sheet.dart';

/// manual = whatever order is stored (drag-reorderable); the rest are
/// display-only transforms that don't touch storage order.
enum ItemSort { manual, alphabetical, newest, oldest, dueDate }

/// What to do once every item on a list has been checked off — offered by
/// the completion dialog in [_ListDetailScreenState._buildTile].
enum _CompletionChoice { keep, reset, archive }

/// Unchecked items keep their order at the top (reorderable only in
/// [ItemSort.manual]); checked items sink to the bottom, in the order they
/// were checked.
List<ChecklistItem> _sortedForDisplay(
  List<ChecklistItem> items,
  ItemSort sort,
) {
  final incomplete = items.where((item) => !item.isDone).toList();
  final complete = items.where((item) => item.isDone).toList();
  switch (sort) {
    case ItemSort.manual:
      break;
    case ItemSort.alphabetical:
      incomplete.sort(
        (a, b) => a.text.toLowerCase().compareTo(b.text.toLowerCase()),
      );
      break;
    case ItemSort.newest:
      incomplete.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      break;
    case ItemSort.oldest:
      incomplete.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      break;
    case ItemSort.dueDate:
      incomplete.sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
      break;
  }
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
  ItemSort _sort = ItemSort.manual;
  String _itemQuery = '';
  final Set<String> _selectedItemIds = {};
  final Set<String> _collapsedHeadings = {};

  // Auto-scroll while dragging in the grouped (sub-heading) view — its
  // per-section ReorderableListViews are non-scrolling (shrinkWrap +
  // NeverScrollableScrollPhysics, nested inside the outer ListView below),
  // so Flutter's own built-in drag-to-edge auto-scroll never kicks in there
  // the way it does for the flat/ungrouped list. Driven by an explicit
  // pointer-position timer instead.
  final _groupedListKey = GlobalKey();
  final _groupedScrollController = ScrollController();
  bool _groupedDragActive = false;
  Offset? _lastPointerPosition;
  Timer? _groupedAutoScrollTimer;

  @override
  void dispose() {
    _groupedAutoScrollTimer?.cancel();
    _groupedScrollController.dispose();
    super.dispose();
  }

  void _onGroupedReorderStart(int _) => _groupedDragActive = true;

  void _onGroupedReorderEnd(int _) {
    _groupedDragActive = false;
    _groupedAutoScrollTimer?.cancel();
    _groupedAutoScrollTimer = null;
  }

  void _handleGroupedPointerMove(PointerMoveEvent event) {
    _lastPointerPosition = event.position;
    if (_groupedDragActive) {
      _groupedAutoScrollTimer ??= Timer.periodic(
        const Duration(milliseconds: 16),
        (_) => _tickGroupedAutoScroll(),
      );
    }
  }

  void _tickGroupedAutoScroll() {
    if (!_groupedDragActive ||
        _lastPointerPosition == null ||
        !_groupedScrollController.hasClients) {
      return;
    }
    final box =
        _groupedListKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final localY = box.globalToLocal(_lastPointerPosition!).dy;
    final height = box.size.height;
    const edgeZone = 80.0;
    const maxStep = 14.0;
    double delta = 0;
    if (localY < edgeZone && localY >= 0) {
      delta = -maxStep * (1 - localY / edgeZone);
    } else if (localY > height - edgeZone && localY <= height) {
      delta = maxStep * (1 - (height - localY) / edgeZone);
    }
    if (delta == 0) return;
    final position = _groupedScrollController.position;
    final newOffset = (position.pixels + delta).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (newOffset != position.pixels) {
      _groupedScrollController.jumpTo(newOffset);
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      _selectionMode = !_selectionMode;
      _selectedItemIds.clear();
    });
  }

  Future<void> _createListFromSelection(
    Checklist list,
    ListsNotifier notifier,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final selectedTexts = list.items
        .where((i) => _selectedItemIds.contains(i.id))
        .map((i) => i.text)
        .toList();
    if (selectedTexts.isEmpty) return;

    final controller = TextEditingController(
      text: l10n.newListFromSelectionDefaultTitle(list.title),
    );
    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.newListNameTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 80,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: Text(l10n.createAction),
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
        SnackBar(
          content: Text(
            l10n.newListCreatedWithCount(title, selectedTexts.length),
          ),
        ),
      );
    }
  }

  Future<void> _moveOrCopySelection(
    Checklist list,
    ListsNotifier notifier, {
    required bool isMove,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedItemIds.isEmpty) return;
    final otherLists = ref
        .read(listsProvider)
        .where((l) => l.id != list.id)
        .toList()
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    if (otherLists.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.noOtherListsToMoveOrCopy)));
      return;
    }

    final targetId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ListPickerSheet(
        title: isMove ? l10n.pickListToMoveTitle : l10n.pickListToCopyTitle,
        lists: otherLists,
      ),
    );
    if (targetId == null || !mounted) return;

    final count = _selectedItemIds.length;
    final targetTitle = otherLists.firstWhere((l) => l.id == targetId).title;
    final succeeded = await runGuarded(
      context,
      () => isMove
          ? notifier.moveItemsToList(list.id, targetId, _selectedItemIds)
          : notifier.copyItemsToList(list.id, targetId, _selectedItemIds),
    );
    if (!succeeded || !mounted) return;

    setState(() {
      _selectionMode = false;
      _selectedItemIds.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isMove
              ? l10n.itemsMovedToList(count, targetTitle)
              : l10n.itemsCopiedToList(count, targetTitle),
        ),
      ),
    );
  }

  Future<void> _assignHeadingToSelection(
    Checklist list,
    ListsNotifier notifier,
  ) async {
    if (_selectedItemIds.isEmpty) return;
    final existingHeadings = <String>[];
    for (final item in list.items) {
      final h = item.subheading?.trim();
      if (h != null && h.isNotEmpty && !existingHeadings.contains(h)) {
        existingHeadings.add(h);
      }
    }

    final result = await showModalBottomSheet<_HeadingChoice>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _HeadingPickerSheet(existingHeadings: existingHeadings),
    );
    if (result == null || !mounted) return;

    final succeeded = await runGuarded(
      context,
      () => notifier.setItemsSubheading(
        list.id,
        _selectedItemIds,
        result.clear ? null : result.name,
      ),
    );
    if (!succeeded || !mounted) return;

    setState(() {
      _selectionMode = false;
      _selectedItemIds.clear();
    });
  }

  Future<void> _renameHeading(
    Checklist list,
    ListsNotifier notifier,
    String heading,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: heading);
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.renameHeadingTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 40,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    controller.dispose();
    if (newName == null || newName.isEmpty || newName == heading || !mounted) {
      return;
    }
    setState(() {
      if (_collapsedHeadings.remove(heading)) _collapsedHeadings.add(newName);
    });
    await runGuarded(
      context,
      () => notifier.renameSubheading(list.id, heading, newName),
    );
  }

  Future<void> _removeHeading(
    Checklist list,
    ListsNotifier notifier,
    String heading,
  ) async {
    final ids = list.items
        .where((i) => i.subheading?.trim() == heading)
        .map((i) => i.id)
        .toSet();
    await runGuarded(
      context,
      () => notifier.setItemsSubheading(list.id, ids, null),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lists = ref.watch(listsProvider);
    final matches = lists.where((l) => l.id == widget.listId);

    if (matches.isEmpty) {
      // Still waiting on the first snapshot (e.g. app opened cold straight
      // into this screen from a push notification) — don't mistake "not
      // loaded yet" for "doesn't exist" and bounce the user back out.
      if (ref.watch(listsLoadingProvider)) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );
      }
      // Data has loaded and this id genuinely isn't in it (e.g. a temporary
      // list emptied out) — leave this screen.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    final list = matches.first;
    final notifier = ref.read(listsProvider.notifier);
    final allDisplayItems = _sortedForDisplay(list.items, _sort);
    final incompleteCount = list.items.where((i) => !i.isDone).length;

    final filterActive = _assigneeFilter != null;
    final assigneeFiltered = filterActive
        ? allDisplayItems.where((i) => i.assignedTo == _assigneeFilter).toList()
        : allDisplayItems;
    final searchActive = _itemQuery.trim().isNotEmpty;
    final displayItems = searchActive
        ? assigneeFiltered
              .where(
                (i) => i.text.toLowerCase().contains(
                  _itemQuery.trim().toLowerCase(),
                ),
              )
              .toList()
        : assigneeFiltered;
    final reorderEnabled =
        !filterActive && !searchActive && _sort == ItemSort.manual;
    final groupingActive =
        !filterActive &&
        !searchActive &&
        list.items.any(
          (i) => !i.isDone && (i.subheading?.trim().isNotEmpty ?? false),
        );

    return Scaffold(
      appBar: AppBar(
        title: _selectionMode
            ? Text(l10n.selectedCountLabel(_selectedItemIds.length))
            : _ListTitle(list.title),
        leading: _selectionMode
            ? IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: _toggleSelectionMode,
              )
            : null,
        actions: _selectionMode
            ? [
                PopupMenuButton<String>(
                  tooltip: l10n.selectedItemsMenuTooltip,
                  enabled: _selectedItemIds.isNotEmpty,
                  onSelected: (value) {
                    switch (value) {
                      case 'new_list':
                        _createListFromSelection(list, notifier);
                        break;
                      case 'move':
                        _moveOrCopySelection(list, notifier, isMove: true);
                        break;
                      case 'copy':
                        _moveOrCopySelection(list, notifier, isMove: false);
                        break;
                      case 'heading':
                        _assignHeadingToSelection(list, notifier);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'new_list',
                      child: _MenuRow(
                        icon: Icons.playlist_add_rounded,
                        label: l10n.createNewListMenuItem,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'move',
                      child: _MenuRow(
                        icon: Icons.drive_file_move_outline,
                        label: l10n.moveToOtherListMenuItem,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'copy',
                      child: _MenuRow(
                        icon: Icons.content_copy_rounded,
                        label: l10n.copyToOtherListMenuItem,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'heading',
                      child: _MenuRow(
                        icon: Icons.label_outline_rounded,
                        label: l10n.assignToHeadingMenuItem,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
              ]
            : [
                IconButton(
                  tooltip: l10n.shareTooltip,
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ShareScreen(listId: list.id),
                      ),
                    );
                  },
                ),
                PopupMenuButton<String>(
                  tooltip: l10n.moreActionsTooltip,
                  onSelected: (value) {
                    switch (value) {
                      case 'reset':
                        runGuarded(context, () => notifier.resetList(list.id));
                        break;
                      case 'sort_manual':
                        setState(() => _sort = ItemSort.manual);
                        break;
                      case 'sort_alpha':
                        setState(() => _sort = ItemSort.alphabetical);
                        break;
                      case 'sort_newest':
                        setState(() => _sort = ItemSort.newest);
                        break;
                      case 'sort_oldest':
                        setState(() => _sort = ItemSort.oldest);
                        break;
                      case 'sort_due':
                        setState(() => _sort = ItemSort.dueDate);
                        break;
                      case 'select':
                        _toggleSelectionMode();
                        break;
                      case 'paste':
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          builder: (_) => BulkImportSheet(
                            onImport: (lines) => runGuarded(
                              context,
                              () => notifier.addItems(list.id, lines),
                            ),
                          ),
                        );
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (list.isCheckable && list.completedCount > 0)
                      PopupMenuItem(
                        value: 'reset',
                        child: _MenuRow(
                          icon: Icons.refresh_rounded,
                          label: l10n.resetMenuItem,
                        ),
                      ),
                    PopupMenuItem(
                      value: 'sort_manual',
                      child: _MenuRow(
                        icon: Icons.drag_handle_rounded,
                        label: l10n.sortManualMenuItem,
                        checked: _sort == ItemSort.manual,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'sort_alpha',
                      child: _MenuRow(
                        icon: Icons.sort_by_alpha_rounded,
                        label: l10n.sortAlphaMenuItem,
                        checked: _sort == ItemSort.alphabetical,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'sort_newest',
                      child: _MenuRow(
                        icon: Icons.arrow_downward_rounded,
                        label: l10n.sortNewestMenuItem,
                        checked: _sort == ItemSort.newest,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'sort_oldest',
                      child: _MenuRow(
                        icon: Icons.arrow_upward_rounded,
                        label: l10n.sortOldestMenuItem,
                        checked: _sort == ItemSort.oldest,
                      ),
                    ),
                    if (list.allowDueDates)
                      PopupMenuItem(
                        value: 'sort_due',
                        child: _MenuRow(
                          icon: Icons.calendar_month_rounded,
                          label: l10n.sortDueDateMenuItem,
                          checked: _sort == ItemSort.dueDate,
                        ),
                      ),
                    if (list.items.isNotEmpty)
                      PopupMenuItem(
                        value: 'select',
                        child: _MenuRow(
                          icon: Icons.content_paste_go_rounded,
                          label: l10n.createListFromItemsMenuItem,
                        ),
                      ),
                    PopupMenuItem(
                      value: 'paste',
                      child: _MenuRow(
                        icon: Icons.playlist_add_check_rounded,
                        label: l10n.pasteToAddMenuItem,
                      ),
                    ),
                  ],
                ),
                const HomeButton(),
              ],
      ),
      body: Column(
        children: [
          if (list.items.length > 1 && !_selectionMode)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: ListSearchBar(
                hintText: l10n.searchItemsHint,
                onChanged: (value) => setState(() => _itemQuery = value),
              ),
            ),
          if (list.isShared && !_selectionMode)
            _AssigneeFilterBar(
              listId: list.id,
              people: list.assignableTo,
              nicknames: list.nicknames,
              items: list.items,
              selected: _assigneeFilter,
              onSelected: (person) => setState(() => _assigneeFilter = person),
            ),
          Expanded(
            child: displayItems.isEmpty
                ? const _EmptyItemsState()
                : groupingActive
                ? _buildGroupedBody(
                    context,
                    list,
                    notifier,
                    displayItems,
                    reorderEnabled: reorderEnabled,
                  )
                : !reorderEnabled
                ? ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    itemCount: displayItems.length,
                    itemBuilder: (context, index) => _buildTile(
                      context,
                      list,
                      notifier,
                      displayItems[index],
                      null,
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    buildDefaultDragHandles: false,
                    itemCount: displayItems.length,
                    onReorderItem: (oldIndex, newIndex) {
                      if (oldIndex >= incompleteCount) return;
                      final clampedNew = newIndex > incompleteCount
                          ? incompleteCount
                          : newIndex;
                      final draggedId = displayItems[oldIndex].id;
                      if (_selectionMode &&
                          _selectedItemIds.length > 1 &&
                          _selectedItemIds.contains(draggedId)) {
                        runGuarded(
                          context,
                          () => notifier.reorderItemsGroup(
                            list.id,
                            _selectedItemIds,
                            oldIndex,
                            clampedNew,
                          ),
                        );
                      } else {
                        runGuarded(
                          context,
                          () => notifier.reorderItems(
                            list.id,
                            oldIndex,
                            clampedNew,
                          ),
                        );
                      }
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
            AddItemBar(
              onAdd: (text) =>
                  runGuarded(context, () => notifier.addItem(list.id, text)),
            ),
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
    final l10n = AppLocalizations.of(context)!;
    final myEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    final isOwner =
        (list.ownerEmail ?? '').toLowerCase() == myEmail.toLowerCase();
    final canToggle =
        item.assignedTo == null ||
        isOwner ||
        item.assignedTo!.toLowerCase() == myEmail.toLowerCase();

    return ChecklistItemTile(
      key: ValueKey(item.id),
      item: item,
      isCheckable: list.isCheckable,
      canToggle: canToggle,
      soundEnabled: ref.watch(notificationSettingsProvider).completionSoundEnabled,
      showRating: list.allowRating,
      showNote: list.allowNotes,
      showDueDate: list.allowDueDates,
      onRatingChanged: (r) => runGuarded(
        context,
        () => notifier.setItemRating(list.id, item.id, r),
      ),
      collaborators: list.assignableTo,
      nicknames: list.nicknames,
      onAssigneeChanged: (a) =>
          runGuarded(context, () => notifier.assignItem(list.id, item.id, a)),
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
        final willComplete = notifier.wouldCompleteList(list.id, item.id);
        if (!await runGuarded(
          context,
          () => notifier.toggleItem(list.id, item.id),
        )) {
          return;
        }
        if (!willComplete || !context.mounted) return;

        // Reset/archive/delete are the owner's calls to make — a collaborator
        // just gets told what the owner can do, not offered buttons for
        // decisions that aren't really theirs (e.g. wiping everyone's
        // progress right after finishing the last item).
        if (!isOwner) {
          await showDialog<void>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: Text(l10n.listCompletedTitle),
              content: Text(l10n.listCompletedNonOwnerBody),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.okAction),
                ),
              ],
            ),
          );
          return;
        }

        final choice = await showDialog<_CompletionChoice>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.listCompletedTitle),
            content: Text(l10n.listCompletedOwnerBody(list.title)),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.of(dialogContext).pop(_CompletionChoice.keep),
                child: Text(l10n.keepAsIsAction),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(dialogContext).pop(_CompletionChoice.reset),
                child: Text(l10n.resetMenuItem),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(dialogContext).pop(_CompletionChoice.archive),
                child: Text(l10n.archiveButton),
              ),
            ],
          ),
        );
        if (!context.mounted ||
            choice == null ||
            choice == _CompletionChoice.keep) {
          return;
        }

        if (choice == _CompletionChoice.reset) {
          await runGuarded(context, () => notifier.resetList(list.id));
          return;
        }

        final archived = await runGuarded(
          context,
          () => notifier.archiveList(list.id),
        );
        if (archived && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.listArchived(list.title))),
          );
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        }
      },
      onDismissed: () async {
        if (!await runGuarded(
          context,
          () => notifier.removeItem(list.id, item.id),
        )) {
          return;
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.itemDeletedSnackbar(item.text)),
              action: SnackBarAction(
                label: l10n.undoAction,
                onPressed: () => runGuarded(
                  context,
                  () => notifier.restoreItem(list.id, item),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  /// Splits [displayItems] (already sorted/filtered) into one collapsible,
  /// drag-reorderable section per sub-heading (shown first — a heading is
  /// something you deliberately organized, so it surfaces above whatever's
  /// still ungrouped), an ungrouped block, and a flat "completed" tail —
  /// mirroring how the plain (ungrouped) view already pins done items at
  /// the bottom.
  Widget _buildGroupedBody(
    BuildContext context,
    Checklist list,
    ListsNotifier notifier,
    List<ChecklistItem> displayItems, {
    required bool reorderEnabled,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final byHeading = <String, List<ChecklistItem>>{};
    final ungrouped = <ChecklistItem>[];
    final complete = <ChecklistItem>[];

    for (final item in displayItems) {
      if (item.isDone) {
        complete.add(item);
        continue;
      }
      final h = item.subheading?.trim();
      if (h == null || h.isEmpty) {
        ungrouped.add(item);
      } else {
        (byHeading[h] ??= []).add(item);
      }
    }

    // `list.subheadingOrder` is authoritative; anything it's missing (older
    // data from before this field existed, or a stray write) is appended so
    // it still shows up rather than silently vanishing.
    final headingOrder = [
      for (final h in list.subheadingOrder)
        if (byHeading.containsKey(h)) h,
      for (final h in byHeading.keys)
        if (!list.subheadingOrder.contains(h)) h,
    ];

    return Listener(
      onPointerMove: _handleGroupedPointerMove,
      child: ListView(
        key: _groupedListKey,
        controller: _groupedScrollController,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        children: [
          if (headingOrder.isNotEmpty)
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: headingOrder.length,
              onReorderStart: _onGroupedReorderStart,
              onReorderEnd: _onGroupedReorderEnd,
              onReorderItem: (oldIndex, newIndex) {
                if (!reorderEnabled) return;
                final draggedHeading = headingOrder[oldIndex];
                final withoutDragged = [...headingOrder]..removeAt(oldIndex);
                final clampedNew = newIndex.clamp(0, withoutDragged.length);
                final beforeHeading = clampedNew < withoutDragged.length
                    ? withoutDragged[clampedNew]
                    : null;
                final anchorHeading =
                    beforeHeading ??
                    (withoutDragged.isNotEmpty ? withoutDragged.last : null);
                runGuarded(
                  context,
                  () => notifier.reorderSubheadingRelativeTo(
                    list.id,
                    draggedHeading,
                    anchorHeading: anchorHeading,
                    before: beforeHeading != null,
                  ),
                );
              },
              itemBuilder: (context, index) {
                final heading = headingOrder[index];
                final collapsed = _collapsedHeadings.contains(heading);
                return Column(
                  key: ValueKey('heading-$heading'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeadingHeader(
                      title: heading,
                      doneCount: list.items
                          .where(
                            (i) => i.subheading?.trim() == heading && i.isDone,
                          )
                          .length,
                      totalCount: list.items
                          .where((i) => i.subheading?.trim() == heading)
                          .length,
                      collapsed: collapsed,
                      dragIndex: reorderEnabled ? index : null,
                      onToggle: () => setState(() {
                        if (!_collapsedHeadings.remove(heading)) {
                          _collapsedHeadings.add(heading);
                        }
                      }),
                      onRename: () => _renameHeading(list, notifier, heading),
                      onRemove: () => _removeHeading(list, notifier, heading),
                    ),
                    if (!collapsed)
                      _buildSectionItems(
                        context,
                        list,
                        notifier,
                        byHeading[heading]!,
                        reorderEnabled: reorderEnabled,
                      ),
                  ],
                );
              },
            ),
          if (ungrouped.isNotEmpty) ...[
            if (headingOrder.isNotEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(4, 4, 0, 8),
                child: Divider(height: 1, color: AppColors.border),
              ),
            _buildSectionItems(
              context,
              list,
              notifier,
              ungrouped,
              reorderEnabled: reorderEnabled,
            ),
          ],
          if (complete.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 14, 0, 8),
              child: Text(
                l10n.completedSectionLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            _buildSectionItems(
              context,
              list,
              notifier,
              complete,
              reorderEnabled: false,
            ),
          ],
        ],
      ),
    );
  }

  /// One section's items, drag-reorderable within itself only — see
  /// [ListsNotifier.reorderItemRelativeTo]/[reorderItemsGroupRelativeTo] for
  /// why a section needs anchor-based reordering instead of the flat view's
  /// plain index math (a section's local index isn't the item's global
  /// position once items are split across sections).
  Widget _buildSectionItems(
    BuildContext context,
    Checklist list,
    ListsNotifier notifier,
    List<ChecklistItem> items, {
    required bool reorderEnabled,
  }) {
    if (!reorderEnabled) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) =>
            _buildTile(context, list, notifier, items[index], null),
      );
    }
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: items.length,
      onReorderStart: _onGroupedReorderStart,
      onReorderEnd: _onGroupedReorderEnd,
      onReorderItem: (oldIndex, newIndex) {
        final draggedId = items[oldIndex].id;
        final withoutDragged = [...items]..removeAt(oldIndex);
        final clampedNew = newIndex.clamp(0, withoutDragged.length);
        final isGroup =
            _selectionMode &&
            _selectedItemIds.length > 1 &&
            _selectedItemIds.contains(draggedId);

        // For a group drag, an item ahead in this section might also be
        // moving — skip past those to land on something that actually stays
        // put, otherwise the anchor lookup below fails (it's not in
        // ListsNotifier's remaining/incomplete list either) and silently
        // falls back to the very end of the WHOLE list, jumping the group
        // out of this section entirely.
        String? anchorId;
        var before = true;
        for (var i = clampedNew; i < withoutDragged.length; i++) {
          final candidate = withoutDragged[i];
          if (isGroup && _selectedItemIds.contains(candidate.id)) continue;
          anchorId = candidate.id;
          before = true;
          break;
        }
        if (anchorId == null) {
          for (var i = withoutDragged.length - 1; i >= 0; i--) {
            final candidate = withoutDragged[i];
            if (isGroup && _selectedItemIds.contains(candidate.id)) continue;
            anchorId = candidate.id;
            before = false;
            break;
          }
        }
        final resolvedAnchorId = anchorId;
        if (resolvedAnchorId == null) return;

        if (isGroup) {
          runGuarded(
            context,
            () => notifier.reorderItemsGroupRelativeTo(
              list.id,
              _selectedItemIds,
              anchorId: resolvedAnchorId,
              before: before,
            ),
          );
        } else {
          runGuarded(
            context,
            () => notifier.reorderItemRelativeTo(
              list.id,
              draggedId,
              anchorId: resolvedAnchorId,
              before: before,
            ),
          );
        }
      },
      itemBuilder: (context, index) =>
          _buildTile(context, list, notifier, items[index], index),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool checked;

  const _MenuRow({
    required this.icon,
    required this.label,
    this.checked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
        if (checked)
          const Icon(Icons.check_rounded, size: 18, color: AppColors.primary),
      ],
    );
  }
}

class _AssigneeFilterBar extends StatelessWidget {
  final String listId;
  final List<String> people;
  final Map<String, String> nicknames;
  final List<ChecklistItem> items;
  final String? selected;
  final ValueChanged<String?> onSelected;

  const _AssigneeFilterBar({
    required this.listId,
    required this.people,
    this.nicknames = const {},
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: SingleChildScrollView(
        key: PageStorageKey<String>('assignee-filter-bar-$listId'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Row(
          children: [
            _chip(
              context,
              label: AppLocalizations.of(context)!.allFilterLabel,
              isSelected: selected == null,
              onTap: () => onSelected(null),
            ),
            const SizedBox(width: 8),
            for (final person in people) ...[
              _chip(
                context,
                label: assigneeChipLabel(context, person, nicknames),
                isSelected: selected == person,
                onTap: () => onSelected(person),
                progress: _progressFor(person),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }

  /// Completed/total ratio for items assigned to [person] — null (no bar)
  /// if they have no assigned items at all.
  double? _progressFor(String person) {
    final assigned = items.where((i) => i.assignedTo == person).toList();
    if (assigned.isEmpty) return null;
    return assigned.where((i) => i.isDone).length / assigned.length;
  }

  Widget _chip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    double? progress,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (progress != null) ...[
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 3,
                    backgroundColor: isSelected
                        ? Colors.white.withValues(alpha: 0.3)
                        : AppColors.background,
                    valueColor: AlwaysStoppedAnimation(
                      isSelected ? Colors.white : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ListPickerSheet extends StatelessWidget {
  final String title;
  final List<Checklist> lists;

  const _ListPickerSheet({required this.title, required this.lists});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: lists.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final l = lists[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.list_alt_rounded,
                      color: AppColors.primary,
                    ),
                    title: Text(l.title, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                      AppLocalizations.of(context)!.itemCount(l.totalCount),
                    ),
                    onTap: () => Navigator.of(context).pop(l.id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeadingHeader extends StatelessWidget {
  final String title;
  final int doneCount;
  final int totalCount;
  final bool collapsed;
  final VoidCallback onToggle;
  final VoidCallback onRename;
  final VoidCallback onRemove;

  /// Non-null when headings are drag-reorderable right now — shows a drag
  /// handle wired to this index in the outer ReorderableListView.
  final int? dragIndex;

  const _HeadingHeader({
    required this.title,
    required this.doneCount,
    required this.totalCount,
    required this.collapsed,
    required this.onToggle,
    required this.onRename,
    required this.onRemove,
    this.dragIndex,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 14, 0, 8),
        child: Row(
          children: [
            Icon(
              collapsed
                  ? Icons.chevron_right_rounded
                  : Icons.expand_more_rounded,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              '$doneCount/$totalCount',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            PopupMenuButton<String>(
              tooltip: AppLocalizations.of(context)!.headingActionsTooltip,
              icon: const Icon(
                Icons.more_vert_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
              onSelected: (value) {
                if (value == 'rename') onRename();
                if (value == 'remove') onRemove();
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'rename',
                  child: _MenuRow(
                    icon: Icons.edit_outlined,
                    label: AppLocalizations.of(context)!.renameAction,
                  ),
                ),
                PopupMenuItem(
                  value: 'remove',
                  child: _MenuRow(
                    icon: Icons.label_off_outlined,
                    label: AppLocalizations.of(context)!.removeHeadingAction,
                  ),
                ),
              ],
            ),
            if (dragIndex != null)
              ReorderableDragStartListener(
                index: dragIndex!,
                child: const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.drag_handle_rounded,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeadingChoice {
  final String? name;
  final bool clear;

  const _HeadingChoice({this.name, this.clear = false});
}

class _HeadingPickerSheet extends StatefulWidget {
  final List<String> existingHeadings;

  const _HeadingPickerSheet({required this.existingHeadings});

  @override
  State<_HeadingPickerSheet> createState() => _HeadingPickerSheetState();
}

class _HeadingPickerSheetState extends State<_HeadingPickerSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitNew() {
    final trimmed = _controller.text.trim();
    if (trimmed.isNotEmpty) {
      Navigator.of(context).pop(_HeadingChoice(name: trimmed));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          12 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.assignToHeadingMenuItem,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 12),
            if (widget.existingHeadings.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final h in widget.existingHeadings)
                    ActionChip(
                      label: Text(h),
                      onPressed: () =>
                          Navigator.of(context).pop(_HeadingChoice(name: h)),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: widget.existingHeadings.isEmpty,
                    maxLength: 40,
                    decoration: InputDecoration(
                      hintText: l10n.newHeadingNameHint,
                      counterText: '',
                    ),
                    onSubmitted: (_) => _submitNew(),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _submitNew,
                  child: Text(l10n.createAction),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () =>
                  Navigator.of(context).pop(const _HeadingChoice(clear: true)),
              icon: const Icon(Icons.label_off_outlined, size: 18),
              label: Text(l10n.noHeadingAction),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyItemsState extends StatelessWidget {
  const _EmptyItemsState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.playlist_add_rounded,
              size: 56,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noItemsYetTitle,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.noItemsYetSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// App bar title for a list. Short titles keep the normal app bar size;
/// longer ones drop to a smaller font and wrap onto a second line (which
/// still fits the standard toolbar height) instead of being cut off with
/// an ellipsis after ~18 characters on a phone.
class _ListTitle extends StatelessWidget {
  final String title;

  const _ListTitle(this.title);

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).appBarTheme.titleTextStyle ?? Theme.of(context).textTheme.titleLarge!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: title, style: base),
          maxLines: 1,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);
        final fits = !painter.didExceedMaxLines;
        painter.dispose();
        if (fits) return Text(title, maxLines: 1, style: base);
        return Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: base.copyWith(fontSize: 17, height: 1.2),
        );
      },
    );
  }
}
