import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class SuggestionChips extends StatelessWidget {
  final List<String> suggestions;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const SuggestionChips({
    super.key,
    required this.suggestions,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: suggestions.map((suggestion) {
        final isSelected = selected.contains(suggestion);
        return InkWell(
          onTap: () => onToggle(suggestion),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.secondary.withValues(alpha: 0.12) : AppColors.background,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(color: isSelected ? AppColors.secondary : AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                  size: 16,
                  color: isSelected ? AppColors.secondary : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  suggestion,
                  style: TextStyle(
                    color: isSelected ? AppColors.secondary : AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
