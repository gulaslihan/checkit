import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/error_feedback.dart';
import '../../core/widgets/initials_avatar.dart';
import '../../data/lists_provider.dart';
import '../../data/notifications_provider.dart';
import '../../models/checklist.dart';
import '../create_list/create_list_screen.dart';
import '../invites/my_invites_screen.dart';
import '../list_detail/list_detail_screen.dart';
import '../pending_items/pending_items_screen.dart';
import '../profile/profile_screen.dart';
import 'widgets/edit_list_sheet.dart';
import 'widgets/list_card.dart';
import 'widgets/list_search_bar.dart';

final _searchQueryProvider = StateProvider<String>((ref) => '');

List<Checklist> _filterLists(List<Checklist> lists, String query) {
  if (query.trim().isEmpty) return lists;
  final q = query.trim().toLowerCase();
  return lists.where((list) {
    final titleMatch = list.title.toLowerCase().contains(q);
    final itemMatch = list.items.any((item) => item.text.toLowerCase().contains(q));
    return titleMatch || itemMatch;
  }).toList();
}

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  DateTime? _lastBackPress;

  void _handlePopInvoked(bool didPop, Object? result) {
    if (didPop) return;
    final now = DateTime.now();
    if (_lastBackPress != null && now.difference(_lastBackPress!) < const Duration(seconds: 2)) {
      SystemNavigator.pop();
      return;
    }
    _lastBackPress = now;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Çıkmak için tekrar geri tuşuna basın'), duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lists = ref.watch(listsProvider);
    final notifier = ref.read(listsProvider.notifier);
    final query = ref.watch(_searchQueryProvider);
    final sortedLists = [...lists]..sort((a, b) => b.sortIndex.compareTo(a.sortIndex));
    final visibleLists = _filterLists(sortedLists, query);
    final reorderEnabled = query.trim().isEmpty;
    final pendingInviteCount = ref.watch(notificationSummaryProvider).actionableCount;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _handlePopInvoked,
      child: Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('CheckIt', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            Text('Listelerim', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Davetlerim ve bildirimler',
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
            tooltip: 'Kişilere atanan bekleyen maddeler',
            icon: const Icon(Icons.assignment_ind_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PendingItemsScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Profil',
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
          Expanded(
            child: lists.isEmpty
                ? const _EmptyState()
                : visibleLists.isEmpty
                ? const _NoResultsState()
                : reorderEnabled
                ? ReorderableListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    itemCount: visibleLists.length,
                    onReorderItem: (oldIndex, newIndex) =>
                        runGuarded(context, () => notifier.reorderLists(visibleLists, oldIndex, newIndex)),
                    itemBuilder: (context, index) {
                      final list = visibleLists[index];
                      return Padding(
                        key: ValueKey(list.id),
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ListCard(
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
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                              ),
                              builder: (_) => EditListSheet(checklist: list),
                            );
                          },
                        ),
                      );
                    },
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    itemCount: visibleLists.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final list = visibleLists[index];
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
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                            ),
                            builder: (_) => EditListSheet(checklist: list),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateListScreen()),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Yeni Liste'),
      ),
      ),
    );
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
            Text('Sonuç bulunamadı', style: Theme.of(context).textTheme.titleMedium),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.checklist_rounded, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text('Henüz listeniz yok', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text(
              'Aşağıdaki + butonuyla ilk listenizi oluşturun',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
