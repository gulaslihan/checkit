import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/category_suggestions.dart';
import '../../dashboard/widgets/category_icon.dart';

class CategorySelector extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const CategorySelector({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: listCategories.map((category) {
        final selected = value == category;
        return InkWell(
          onTap: () => onChanged(selected ? null : category),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(color: selected ? AppColors.primary : AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(categoryIcon(category), size: 18, color: selected ? Colors.white : AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  category,
                  style: TextStyle(color: selected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
