import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/error_feedback.dart';
import '../../core/widgets/home_button.dart';
import '../../data/category_suggestions.dart';
import '../../data/lists_provider.dart';
import '../../models/checklist_type.dart';
import 'widgets/category_selector.dart';
import 'widgets/settings_toggle.dart';
import 'widgets/suggestion_chips.dart';
import 'widgets/type_selector.dart';

class CreateListScreen extends ConsumerStatefulWidget {
  const CreateListScreen({super.key});

  @override
  ConsumerState<CreateListScreen> createState() => _CreateListScreenState();
}

class _CreateListScreenState extends ConsumerState<CreateListScreen> {
  final _titleController = TextEditingController();
  ChecklistType _type = ChecklistType.permanent;
  String? _category;
  final Set<String> _selectedSuggestions = {};
  bool _allowRating = false;
  bool _isCheckable = true;
  bool _allowDueDates = false;
  bool _allowNotes = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _onCategoryChanged(String? category) {
    setState(() {
      _category = category;
      _selectedSuggestions.clear();
    });
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir liste adı girin')),
      );
      return;
    }

    final succeeded = await runGuarded(
      context,
      () => ref.read(listsProvider.notifier).createList(
            title: title,
            type: _type,
            category: _category,
            initialItemTexts: _selectedSuggestions.toList(),
            allowRating: _allowRating,
            isCheckable: _isCheckable,
            allowDueDates: _allowDueDates,
            allowNotes: _allowNotes,
          ),
    );
    if (succeeded && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = _category != null ? categorySuggestions[_category] : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Liste'), actions: const [HomeButton()]),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          TextField(
            controller: _titleController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Liste adı',
              hintText: 'ör. Haftalık Market',
            ),
          ),
          const SizedBox(height: 24),
          SettingsToggle(
            icon: Icons.check_circle_outline_rounded,
            title: 'Tiklenebilir liste',
            subtitle: 'Kapatırsanız bu liste sadece madde tutmak/sıralamak için kullanılır',
            value: _isCheckable,
            onChanged: (v) => setState(() => _isCheckable = v),
          ),
          if (_isCheckable) ...[
            const SizedBox(height: 24),
            const Text('Liste tipi', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            TypeSelector(value: _type, onChanged: (t) => setState(() => _type = t)),
          ],
          const SizedBox(height: 24),
          const Text('Kategori (isteğe bağlı)', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          CategorySelector(value: _category, onChanged: _onCategoryChanged),
          if (suggestions != null) ...[
            const SizedBox(height: 24),
            const Text('Önerilen maddeler — eklemek istediklerinize dokunun', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            SuggestionChips(
              suggestions: suggestions,
              selected: _selectedSuggestions,
              onToggle: (s) => setState(() {
                if (!_selectedSuggestions.remove(s)) _selectedSuggestions.add(s);
              }),
            ),
          ],
          const SizedBox(height: 24),
          SettingsToggle(
            icon: Icons.star_rounded,
            iconColor: const Color(0xFFF59E0B),
            title: 'Yıldız puanlama',
            subtitle: 'Maddelere 1-5 yıldız verilebilsin',
            value: _allowRating,
            onChanged: (v) => setState(() => _allowRating = v),
          ),
          const SizedBox(height: 12),
          SettingsToggle(
            icon: Icons.schedule_rounded,
            iconColor: AppColors.secondary,
            title: 'Tarih/saat eklenebilir',
            subtitle: 'Maddelere tarih/saat eklenip tarihe göre sıralanabilsin',
            value: _allowDueDates,
            onChanged: (v) => setState(() => _allowDueDates = v),
          ),
          const SizedBox(height: 12),
          SettingsToggle(
            icon: Icons.notes_rounded,
            iconColor: AppColors.secondary,
            title: 'Not eklenebilir',
            subtitle: 'Maddelere kısa bir not eklenebilsin',
            value: _allowNotes,
            onChanged: (v) => setState(() => _allowNotes = v),
          ),
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
              child: const Text('Listeyi Oluştur'),
            ),
          ),
        ),
      ),
    );
  }
}
