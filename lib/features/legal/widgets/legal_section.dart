import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class LegalSection extends StatelessWidget {
  final String title;
  final String body;

  const LegalSection({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 6),
          Text(body, style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary, height: 1.5)),
        ],
      ),
    );
  }
}
