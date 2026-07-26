import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/error_feedback.dart';
import '../../../data/lists_provider.dart';
import '../../../models/checklist.dart';
import '../../../models/checklist_type.dart';
import '../../create_list/widgets/category_selector.dart';
import '../../create_list/widgets/settings_toggle.dart';
import '../../create_list/widgets/type_selector.dart';

class EditListSheet extends ConsumerStatefulWidget {
  final Checklist checklist;

  const EditListSheet({super.key, required this.checklist});

  @override
  ConsumerState<EditListSheet> createState() => _EditListSheetState();
}

class _EditListSheetState extends ConsumerState<EditListSheet> {
  late final TextEditingController _titleController;
  late ChecklistType _type;
  String? _category;
  late bool _allowRating;
  late bool _isCheckable;
  late bool _allowDueDates;
  late bool _allowNotes;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.checklist.title);
    _type = widget.checklist.type;
    _category = widget.checklist.category;
    _allowRating = widget.checklist.allowRating;
    _isCheckable = widget.checklist.isCheckable;
    _allowDueDates = widget.checklist.allowDueDates;
    _allowNotes = widget.checklist.allowNotes;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    final succeeded = await runGuarded(
      context,
      () => ref.read(listsProvider.notifier).updateListMeta(
            widget.checklist.id,
            title: title,
            type: _type,
            category: _category,
            allowRating: _allowRating,
            isCheckable: _isCheckable,
            allowDueDates: _allowDueDates,
            allowNotes: _allowNotes,
          ),
    );
    if (succeeded && mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Listeyi sil'),
        content: Text('"${widget.checklist.title}" listesi kalıcı olarak silinecek. Emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sil', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final succeeded = await runGuarded(context, () => ref.read(listsProvider.notifier).deleteList(widget.checklist.id));
      if (succeeded && mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _duplicate() async {
    final succeeded =
        await runGuarded(context, () => ref.read(listsProvider.notifier).duplicateList(widget.checklist.id));
    if (!succeeded || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${widget.checklist.title}" kopyalandı')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Listeyi Düzenle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              IconButton(
                tooltip: 'Kapat',
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Liste adı'),
          ),
          const SizedBox(height: 20),
          SettingsToggle(
            icon: Icons.check_circle_outline_rounded,
            title: 'Tiklenebilir liste',
            subtitle: 'Kapatırsanız bu liste sadece madde tutmak/sıralamak için kullanılır',
            value: _isCheckable,
            onChanged: (v) => setState(() => _isCheckable = v),
          ),
          if (_isCheckable) ...[
            const SizedBox(height: 20),
            const Text('Liste tipi', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            TypeSelector(value: _type, onChanged: (t) => setState(() => _type = t)),
          ],
          const SizedBox(height: 20),
          const Text('Kategori', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          CategorySelector(value: _category, onChanged: (c) => setState(() => _category = c)),
          const SizedBox(height: 20),
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
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _duplicate,
              icon: const Icon(Icons.copy_all_rounded),
              label: const Text('Listeyi Kopyala'),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _confirmDelete,
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                  label: const Text('Sil', style: TextStyle(color: AppColors.danger)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.danger)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Kaydet'),
                ),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }
}
