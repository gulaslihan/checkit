import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/error_feedback.dart';
import '../../core/utils/list_search.dart';
import '../../core/widgets/initials_avatar.dart';
import '../../data/lists_provider.dart';
import '../../data/notifications_provider.dart';
import '../../data/subscription_provider.dart';
import '../../data/welcome_tips_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/checklist.dart';
import '../archive/archive_screen.dart';
import '../create_list/create_list_screen.dart';
import '../invites/my_invites_screen.dart';
import '../list_detail/list_detail_screen.dart';
import '../pending_items/pending_items_screen.dart';
import '../profile/profile_screen.dart';
import '../subscription/paywall_sheet.dart';
import 'widgets/edit_list_sheet.dart';
import 'widgets/list_card.dart';
import 'widgets/list_search_bar.dart';
import 'widgets/welcome_tips_card.dart';

final _searchQueryProvider = StateProvider<String>((ref) => '');

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  DateTime? _lastBackPress;
  final Set<String> _collapsedSections = {};

  // The dashboard's per-section ReorderableListViews are non-scrolling
  // (shrinkWrap + NeverScrollableScrollPhysics inside the outer scroll view),
  // so Flutter's built-in drag-to-edge auto-scroll never runs and dragging a
  // list toward the top/bottom edge didn't move the screen. Driven here by an
  // explicit pointer-position timer — same approach as the grouped list view
  // in list_detail_screen.dart.
  final _scrollKey = GlobalKey();
  final _scrollController = ScrollController();
  bool _dragActive = false;
  Offset? _lastPointerPosition;
  Timer? _autoScrollTimer;

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _stopAutoScroll() {
    _dragActive = false;
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  void _handlePointerMove(PointerMoveEvent event) {
    _lastPointerPosition = event.position;
    if (_dragActive) {
      _autoScrollTimer ??= Timer.periodic(const Duration(milliseconds: 16), (_) => _tickAutoScroll());
    }
  }

  void _tickAutoScroll() {
    if (!_dragActive || _lastPointerPosition == null || !_scrollController.hasClients) return;
    final box = _scrollKey.currentContext?.findRenderObject() as RenderBox?;
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
    final position = _scrollController.position;
    final newOffset = (position.pixels + delta).clamp(position.minScrollExtent, position.maxScrollExtent);
    if (newOffset != position.pixels) _scrollController.jumpTo(newOffset);
  }

  void _handlePopInvoked(bool didPop, Object? result) {
    if (didPop) return;
    final now = DateTime.now();
    if (_lastBackPress != null && now.difference(_lastBackPress!) < const Duration(seconds: 2)) {
      SystemNavigator.pop();
      return;
    }
    _lastBackPress = now;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.backPressToExit), duration: const Duration(seconds: 2)),
    );
  }

  Widget _card(BuildContext context, Checklist list) {
    return ListCard(
      checklist: list,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ListDetailScreen(listId: list.id)),
        );
      },
      onEdit: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) => EditListSheet(checklist: list),
        );
      },
    );
  }

  Widget _buildGroup(BuildContext context, ListsNotifier notifier, List<Checklist> group, bool reorderEnabled) {
    if (reorderEnabled) {
      return ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: group.length,
        onReorderStart: (_) => _dragActive = true,
        onReorderEnd: (_) => _stopAutoScroll(),
        onReorderItem: (oldIndex, newIndex) => runGuarded(context, () => notifier.reorderLists(group, oldIndex, newIndex)),
        itemBuilder: (context, index) {
          final list = group[index];
          return Padding(
            key: ValueKey(list.id),
            padding: const EdgeInsets.only(bottom: 12),
            child: _card(context, list),
          );
        },
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: group.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _card(context, group[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lists = ref.watch(listsProvider);
    final listsLoading = ref.watch(listsLoadingProvider);
    final notifier = ref.read(listsProvider.notifier);
    final query = ref.watch(_searchQueryProvider);
    final activeLists = lists.where((l) => !l.archived).toList();
    final sortedLists = [...activeLists]..sort((a, b) => b.sortIndex.compareTo(a.sortIndex));
    final visibleLists = filterLists(sortedLists, query);
    final myLists = visibleLists.where((l) => !l.isShared).toList();
    final sharedLists = visibleLists.where((l) => l.isShared).toList();
    final reorderEnabled = query.trim().isEmpty;
    final pendingInviteCount = ref.watch(notificationSummaryProvider).actionableCount;
    final shownSections = [
      if (myLists.isNotEmpty) 'mine',
      if (sharedLists.isNotEmpty) 'shared',
    ];
    final allSectionsCollapsed = shownSections.isNotEmpty && shownSections.every(_collapsedSections.contains);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _handlePopInvoked,
      child: Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'CHECKIT',
              style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w800, letterSpacing: 2),
            ),
            Text(l10n.myListsTitle, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            SizedBox(
              width: 36,
              height: 3,
              child: DecoratedBox(
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.all(Radius.circular(2))),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: l10n.invitesAndNotificationsTooltip,
            icon: Badge(
              label: Text('$pendingInviteCount'),
              isLabelVisible: pendingInviteCount > 0,
              child: const Icon(Icons.notifications_none_rounded),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MyInvitesScreen()),
              );
            },
          ),
          IconButton(
            tooltip: l10n.pendingTasksTooltip,
            icon: const Icon(Icons.assignment_ind_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PendingItemsScreen()),
              );
            },
          ),
          IconButton(
            tooltip: l10n.archiveTooltip,
            icon: const Icon(Icons.archive_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ArchiveScreen()),
              );
            },
          ),
          IconButton(
            tooltip: l10n.profileTooltip,
            icon: InitialsAvatar(name: FirebaseAuth.instance.currentUser?.email ?? '?', radius: 16),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: ListSearchBar(
              onChanged: (value) => ref.read(_searchQueryProvider.notifier).state = value,
            ),
          ),
          if (ref.watch(welcomeTipsVisibleProvider))
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: WelcomeTipsCard(onDismiss: () => ref.read(welcomeTipsVisibleProvider.notifier).dismiss()),
            ),
          Expanded(
            child: Listener(
              onPointerMove: _handlePointerMove,
              child: listsLoading
                ? const _LoadingState()
                : activeLists.isEmpty
                ? const _EmptyState()
                : visibleLists.isEmpty
                ? const _NoResultsState()
                : SingleChildScrollView(
                    key: _scrollKey,
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (myLists.isNotEmpty) ...[
                          _SectionHeader(
                            icon: Icons.person_rounded,
                            title: l10n.mineLabel,
                            count: myLists.length,
                            collapsed: _collapsedSections.contains('mine'),
                            onToggle: () => setState(() {
                              if (!_collapsedSections.remove('mine')) _collapsedSections.add('mine');
                            }),
                          ),
                          if (!_collapsedSections.contains('mine')) ...[
                            const SizedBox(height: 10),
                            _buildGroup(context, notifier, myLists, reorderEnabled),
                          ],
                        ],
                        if (sharedLists.isNotEmpty) ...[
                          if (myLists.isNotEmpty) const SizedBox(height: 24),
                          _SectionHeader(
                            icon: Icons.people_alt_rounded,
                            title: l10n.sharedLabel,
                            count: sharedLists.length,
                            collapsed: _collapsedSections.contains('shared'),
                            onToggle: () => setState(() {
                              if (!_collapsedSections.remove('shared')) _collapsedSections.add('shared');
                            }),
                          ),
                          if (!_collapsedSections.contains('shared')) ...[
                            const SizedBox(height: 10),
                            _buildGroup(context, notifier, sharedLists, reorderEnabled),
                          ],
                        ],
                        if (allSectionsCollapsed) ...[
                          const SizedBox(height: 24),
                          const _AllCollapsedFiller(),
                        ],
                      ],
                    ),
                  ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final subscription = ref.read(subscriptionProvider);
          if (!subscription.canCreateList) {
            showPaywallSheet(context, freeLimit: subscription.freeTotalListLimit);
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateListScreen()),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.newListButton),
      ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final bool collapsed;
  final VoidCallback onToggle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.count,
    required this.collapsed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(width: 6),
            Text('($count)', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
            const Spacer(),
            Icon(
              collapsed ? Icons.chevron_right_rounded : Icons.expand_more_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Fills the leftover space when every section is collapsed — otherwise the
/// screen is just a big blank area below the headers.
class _AllCollapsedFiller extends StatelessWidget {
  const _AllCollapsedFiller();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.45),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.local_florist_rounded, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.allCollapsedTitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.allCollapsedSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
  }
}

class _NoResultsState extends StatelessWidget {
  const _NoResultsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, size: 56, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.noResultsFound, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.checklist_rounded, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(l10n.noListsYetTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              l10n.noListsYetSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
