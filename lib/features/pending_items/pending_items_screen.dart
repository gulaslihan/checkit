import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/person_label.dart';
import '../../core/widgets/home_button.dart';
import '../../core/widgets/initials_avatar.dart';
import '../../data/lists_provider.dart';
import '../../models/checklist.dart';
import '../../models/checklist_item.dart';
import '../list_detail/list_detail_screen.dart';

class _PendingEntry {
  final Checklist list;
  final ChecklistItem item;
  const _PendingEntry(this.list, this.item);
}

enum _PendingFilter { mine, others }

class PendingItemsScreen extends ConsumerStatefulWidget {
  const PendingItemsScreen({super.key});

  @override
  ConsumerState<PendingItemsScreen> createState() => _PendingItemsScreenState();
}

class _PendingItemsScreenState extends ConsumerState<PendingItemsScreen> {
  _PendingFilter _filter = _PendingFilter.mine;

  @override
  Widget build(BuildContext context) {
    final lists = ref.watch(listsProvider);
    final myEmail = FirebaseAuth.instance.currentUser?.email;

    final entries = <_PendingEntry>[
      for (final list in lists)
        for (final item in list.items)
          if (!item.isDone && item.assignedTo != null) _PendingEntry(list, item),
    ];

    final filtered = entries.where((e) {
      final isMine = e.item.assignedTo == myEmail;
      return _filter == _PendingFilter.mine ? isMine : !isMine;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Bekleyen Maddeler'), actions: const [HomeButton()]),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: _FilterTab(
                    label: 'Bende',
                    selected: _filter == _PendingFilter.mine,
                    onTap: () => setState(() => _filter = _PendingFilter.mine),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FilterTab(
                    label: 'Başkalarında',
                    selected: _filter == _PendingFilter.others,
                    onTap: () => setState(() => _filter = _PendingFilter.others),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const _EmptyPending()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final entry = filtered[index];
                      return _PendingCard(entry: entry);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  final _PendingEntry entry;

  const _PendingCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.softShadow,
      ),
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ListDetailScreen(listId: entry.list.id)),
          );
        },
        leading: InitialsAvatar(name: entry.item.assignedTo!),
        title: Text(entry.item.text, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text('${entry.list.title} · ${personLabel(entry.item.assignedTo!)}'),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterTab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(color: selected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _EmptyPending extends StatelessWidget {
  const _EmptyPending();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.task_alt_rounded, size: 56, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text('Bekleyen madde yok', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
