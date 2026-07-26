import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/checklist_type.dart';

class TypeSelector extends StatelessWidget {
  final ChecklistType value;
  final ValueChanged<ChecklistType> onChanged;

  const TypeSelector({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TypeCard(
            title: 'Kalıcı',
            description: 'Tiklenen madde sona gider, "sıfırla" ile tekrar kullanılır',
            icon: Icons.replay_rounded,
            selected: value == ChecklistType.permanent,
            onTap: () => onChanged(ChecklistType.permanent),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TypeCard(
            title: 'Geçici',
            description: 'Son madde tiklenince liste tamamen silinir',
            icon: Icons.timelapse_rounded,
            selected: value == ChecklistType.temporary,
            onTap: () => onChanged(ChecklistType.temporary),
          ),
        ),
      ],
    );
  }
}

class _TypeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TypeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 1.5 : 1),
          boxShadow: selected ? AppTheme.softShadow : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: selected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
