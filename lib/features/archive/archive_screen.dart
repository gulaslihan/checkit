import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/list_search.dart';
import '../../core/widgets/home_button.dart';
import '../../data/lists_provider.dart';
import '../../l10n/app_localizations.dart';
import '../dashboard/widgets/edit_list_sheet.dart';
import '../dashboard/widgets/list_card.dart';
import '../dashboard/widgets/list_search_bar.dart';
import '../list_detail/list_detail_screen.dart';

/// Archived lists — hidden from the main dashboard but never deleted. See
/// [ListsNotifier.archiveList]/[unarchiveList] and the completion dialog in
/// list_detail_screen.dart that offers archiving whenever a list is
/// finished.
class ArchiveScreen extends ConsumerStatefulWidget {
  const ArchiveScreen({super.key});

  @override
  ConsumerState<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends ConsumerState<ArchiveScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lists = ref.watch(listsProvider);
    final loading = ref.watch(listsLoadingProvider);
    final archived = lists.where((l) => l.archived).toList()
      ..sort((a, b) => (b.archivedAt ?? DateTime(0)).compareTo(a.archivedAt ?? DateTime(0)));
    final visible = filterLists(archived, _query);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.archiveTooltip), actions: const [HomeButton()]),
      body: Column(
        children: [
          if (archived.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: ListSearchBar(
                hintText: l10n.searchArchiveHint,
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : archived.isEmpty
                ? const _EmptyArchive()
                : visible.isEmpty
                ? const _NoResults()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: visible.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final list = visible[index];
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
    );
  }
}

class _EmptyArchive extends StatelessWidget {
  const _EmptyArchive();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.archive_outlined, size: 56, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(l10n.archiveEmptyTitle, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(
              l10n.archiveEmptySubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults();

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
            Text(AppLocalizations.of(context)!.noResultsFound, style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
