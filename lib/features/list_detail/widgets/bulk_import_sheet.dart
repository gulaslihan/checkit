import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

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
          const Text('Yapıştırarak Toplu Ekle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text(
            'Notlarınızdan kopyaladığınız metni buraya yapıştırın — her satır ayrı bir madde olarak eklenir.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            minLines: 6,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText: 'Süt\nEkmek\nYumurta\n...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              child: const Text('Maddeleri Ekle'),
            ),
          ),
        ],
      ),
    );
  }
}
