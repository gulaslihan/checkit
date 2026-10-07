import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_format.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/checklist_item.dart';

class ItemEditorResult {
  final String text;
  final String? note;
  final DateTime? dueDate;
  final bool clearDueDate;

  const ItemEditorResult({required this.text, this.note, this.dueDate, this.clearDueDate = false});
}

Future<void> showItemEditorSheet({
  required BuildContext context,
  required ChecklistItem item,
  required ValueChanged<ItemEditorResult> onSave,
  bool allowNotes = false,
  bool allowDueDates = false,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (sheetContext) => _ItemEditorContent(
      item: item,
      onSave: onSave,
      allowNotes: allowNotes,
      allowDueDates: allowDueDates,
    ),
  );
}

class _ItemEditorContent extends StatefulWidget {
  final ChecklistItem item;
  final ValueChanged<ItemEditorResult> onSave;
  final bool allowNotes;
  final bool allowDueDates;

  const _ItemEditorContent({
    required this.item,
    required this.onSave,
    required this.allowNotes,
    required this.allowDueDates,
  });

  @override
  State<_ItemEditorContent> createState() => _ItemEditorContentState();
}

class _ItemEditorContentState extends State<_ItemEditorContent> {
  late final TextEditingController _textController;
  late final TextEditingController _noteController;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.item.text);
    _noteController = TextEditingController(text: widget.item.note ?? '');
    _dueDate = widget.item.dueDate;
  }

  @override
  void dispose() {
    _textController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: _dueDate != null ? TimeOfDay.fromDateTime(_dueDate!) : const TimeOfDay(hour: 9, minute: 0),
    );
    if (!mounted) return;
    setState(() {
      _dueDate = DateTime(date.year, date.month, date.day, time?.hour ?? 9, time?.minute ?? 0);
    });
  }

  void _save() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    Navigator.of(context).pop();
    widget.onSave(ItemEditorResult(
      text: text,
      note: widget.allowNotes ? _noteController.text : widget.item.note,
      dueDate: widget.allowDueDates ? _dueDate : widget.item.dueDate,
      clearDueDate: widget.allowDueDates && _dueDate == null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
            Text(l10n.editItemTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 200,
              decoration: InputDecoration(labelText: l10n.itemLabel),
            ),
            if (widget.allowNotes) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                minLines: 2,
                maxLines: 4,
                maxLength: 400,
                decoration: InputDecoration(labelText: l10n.noteOptionalLabel),
              ),
            ],
            if (widget.allowDueDates) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDueDate,
                      icon: const Icon(Icons.schedule_rounded, size: 18),
                      label: Text(_dueDate == null ? l10n.addDueDateButton : formatDueDate(context, _dueDate!)),
                    ),
                  ),
                  if (_dueDate != null)
                    IconButton(
                      tooltip: l10n.removeDueDateTooltip,
                      icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                      onPressed: () => setState(() => _dueDate = null),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
                ),
                child: Text(l10n.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
