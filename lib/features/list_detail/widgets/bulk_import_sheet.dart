import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

class BulkImportSheet extends StatefulWidget {
  final ValueChanged<List<String>> onImport;

  const BulkImportSheet({super.key, required this.onImport});

  @override
  State<BulkImportSheet> createState() => _BulkImportSheetState();
}

class _BulkImportSheetState extends State<BulkImportSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final lines = _controller.text.split('\n');
    widget.onImport(lines);
    Navigator.of(context).pop();
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.bulkImportTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            l10n.bulkImportSubtitle,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            minLines: 6,
            maxLines: 10,
            decoration: InputDecoration(
              hintText: l10n.bulkImportHint,
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              child: Text(l10n.addItemsButton),
            ),
          ),
        ],
      ),
    );
  }
}
