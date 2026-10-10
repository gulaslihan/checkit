import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/error_feedback.dart';
import '../../core/utils/text_format.dart';
import '../../core/widgets/home_button.dart';
import '../../core/widgets/voice_input_button.dart';
import '../../data/ai_list_generator.dart';
import '../../data/lists_provider.dart';
import '../../data/subscription_provider.dart';
import '../../l10n/app_localizations.dart';
import '../subscription/paywall_sheet.dart';
import 'widgets/ai_prompt_sheet.dart';
import 'widgets/category_selector.dart';
import 'widgets/settings_toggle.dart';

class CreateListScreen extends ConsumerStatefulWidget {
  /// Optional starting values — used by the first-run intro to hand over what
  /// the user picked. [aiPromptSeed] opens the AI sheet straight away with that
  /// sentence filled in.
  final String? initialTitle;
  final String? initialCategory;
  final String? aiPromptSeed;

  const CreateListScreen({super.key, this.initialTitle, this.initialCategory, this.aiPromptSeed});

  @override
  ConsumerState<CreateListScreen> createState() => _CreateListScreenState();
}

class _CreateListScreenState extends ConsumerState<CreateListScreen> {
  final _titleController = TextEditingController();
  String? _category;
  bool _allowRating = false;
  bool _isCheckable = true;
  bool _allowDueDates = false;
  bool _allowNotes = false;
  bool _notificationsEnabled = true;
  final _headingController = TextEditingController();
  final List<String> _headings = [];
  List<AiGeneratedItem> _aiItems = const [];

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialTitle ?? '';
    _category = widget.initialCategory;
    final seed = widget.aiPromptSeed;
    if (seed != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openAiPrompt(seed: seed);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _headingController.dispose();
    super.dispose();
  }

  void _addHeading() {
    // Same first-letter capitalization the list does when it saves the heading,
    // so the chip shows exactly what will be stored.
    final name = capitalizeFirst(
      _headingController.text.trim(),
      turkish: Localizations.localeOf(context).languageCode == 'tr',
    );
    if (name.isEmpty) return;
    final alreadyThere = _headings.any((h) => h.toLowerCase() == name.toLowerCase());
    setState(() {
      if (!alreadyThere) _headings.add(name);
      _headingController.clear();
    });
  }

  bool _blockedByPaywall() {
    final subscription = ref.read(subscriptionProvider);
    if (subscription.canCreateList) return false;
    showPaywallSheet(context, freeLimit: subscription.freeTotalListLimit);
    return true;
  }

  Future<void> _openAiPrompt({String? seed}) async {
    if (_blockedByPaywall()) return;
    final result = await showAiPromptSheet(context, initialPrompt: seed);
    if (result == null || !mounted) return;
    setState(() {
      _titleController.text = result.title;
      _category = result.category;
      _isCheckable = result.isCheckable;
      _allowRating = result.allowRating;
      _allowDueDates = result.allowDueDates;
      _allowNotes = result.allowNotes;
      _aiItems = result.items;
    });
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.listNameRequired)),
      );
      return;
    }
    if (_blockedByPaywall()) return;

    final succeeded = await runGuarded(
      context,
      () => ref.read(listsProvider.notifier).createList(
            title: title,
            category: _category,
            initialItemTexts: [for (final item in _aiItems) item.text],
            itemSubheadings: [for (final item in _aiItems) item.subheading],
            allowRating: _allowRating,
            isCheckable: _isCheckable,
            allowDueDates: _allowDueDates,
            allowNotes: _allowNotes,
            notificationsEnabled: _notificationsEnabled,
            subheadings: _headings,
          ),
    );
    if (succeeded && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newListButton), actions: const [HomeButton()]),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openAiPrompt,
              icon: const Icon(Icons.auto_awesome_rounded),
              label: Text(l10n.aiCreateButton, style: const TextStyle(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            maxLength: 80,
            decoration: InputDecoration(
              labelText: l10n.listNameLabel,
              suffixIcon: VoiceInputButton(controller: _titleController),
              hintText: l10n.listNameHint,
            ),
          ),
          const SizedBox(height: 24),
          SettingsToggle(
            icon: Icons.check_circle_outline_rounded,
            title: l10n.checkableToggleTitle,
            subtitle: l10n.checkableToggleSubtitle,
            value: _isCheckable,
            onChanged: (v) => setState(() => _isCheckable = v),
          ),
          const SizedBox(height: 12),
          SettingsToggle(
            icon: Icons.star_rounded,
            iconColor: const Color(0xFFF59E0B),
            title: l10n.starRatingToggleTitle,
            subtitle: l10n.starRatingToggleSubtitle,
            value: _allowRating,
            onChanged: (v) => setState(() => _allowRating = v),
          ),
          const SizedBox(height: 12),
          SettingsToggle(
            icon: Icons.schedule_rounded,
            iconColor: AppColors.secondary,
            title: l10n.dueDateToggleTitleGeneric,
            subtitle: l10n.dueDateToggleSubtitleGeneric,
            value: _allowDueDates,
            onChanged: (v) => setState(() => _allowDueDates = v),
          ),
          const SizedBox(height: 12),
          SettingsToggle(
            icon: Icons.notes_rounded,
            iconColor: AppColors.secondary,
            title: l10n.notesToggleTitle,
            subtitle: l10n.notesToggleSubtitle,
            value: _allowNotes,
            onChanged: (v) => setState(() => _allowNotes = v),
          ),
          const SizedBox(height: 12),
          SettingsToggle(
            icon: Icons.notifications_active_rounded,
            iconColor: AppColors.secondary,
            title: l10n.listNotificationsToggleTitle,
            subtitle: l10n.listNotificationsToggleSubtitle,
            value: _notificationsEnabled,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
          ),
          const SizedBox(height: 24),
          Text(l10n.categoryOptionalLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          CategorySelector(value: _category, onChanged: (c) => setState(() => _category = c)),
          const SizedBox(height: 24),
          Text(l10n.headingsOptionalLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(l10n.headingsOptionalHint, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _headingController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: 40,
                  buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                  decoration: InputDecoration(hintText: l10n.headingNameHint),
                  onSubmitted: (_) => _addHeading(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _addHeading, child: Text(l10n.addAction)),
            ],
          ),
          if (_headings.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final h in _headings)
                  InputChip(label: Text(h), onDeleted: () => setState(() => _headings.remove(h))),
              ],
            ),
          ],
          if (_aiItems.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(l10n.aiItemsPreviewLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            _AiItemsPreview(
              items: _aiItems,
              onRemove: (index) => setState(() {
                _aiItems = [..._aiItems]..removeAt(index);
              }),
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text(l10n.createListButton),
            ),
          ),
        ),
      ),
    );
  }
}

class _AiItemsPreview extends StatelessWidget {
  final List<AiGeneratedItem> items;
  final ValueChanged<int> onRemove;

  const _AiItemsPreview({required this.items, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rows = <Widget>[];
    String? lastHeading;
    for (var i = 0; i < items.length; i++) {
      final heading = items[i].subheading;
      if (heading != null && heading != lastHeading) {
        rows.add(Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 2),
          child: Text(
            heading,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textSecondary),
          ),
        ));
      }
      lastHeading = heading;
      rows.add(ListTile(
        dense: true,
        title: Text(items[i].text),
        trailing: IconButton(
          tooltip: l10n.removeTooltip,
          icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
          onPressed: () => onRemove(i),
        ),
      ));
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(children: rows),
    );
  }
}
