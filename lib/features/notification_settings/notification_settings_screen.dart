import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/error_feedback.dart';
import '../../core/widgets/home_button.dart';
import '../../data/notification_settings_provider.dart';
import 'widgets/notification_toggle_row.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Bildirim Ayarları'), actions: const [HomeButton()]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tarih/saat hatırlatmaları bu telefonda anında çalışır. Diğer ayarlar, uygulama Firebase üzerinden bildirim gönderdiğinde bu tercihlere göre karar verir.',
                    style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          NotificationToggleRow(
            icon: Icons.schedule_send_rounded,
            title: 'Tarih/saati gelen maddeler',
            subtitle: 'Bir maddeye eklediğiniz tarih/saat gelince bu telefonda hatırlatılsın',
            value: settings.onDueDate,
            onChanged: (v) => runGuarded(context, () => notifier.setDueDate(v)),
          ),
          NotificationToggleRow(
            icon: Icons.check_circle_outline_rounded,
            title: 'Madde tamamlandığında',
            subtitle: 'Paylaşımlı bir listede biri madde tikleyince haber verilsin',
            value: settings.onItemCompleted,
            onChanged: (v) => runGuarded(context, () => notifier.setItemCompleted(v)),
          ),
          NotificationToggleRow(
            icon: Icons.add_circle_outline_rounded,
            title: 'Yeni madde eklendiğinde',
            subtitle: 'Paylaşımlı bir listeye yeni madde eklenince haber verilsin',
            value: settings.onItemAdded,
            onChanged: (v) => runGuarded(context, () => notifier.setItemAdded(v)),
          ),
          NotificationToggleRow(
            icon: Icons.assignment_ind_outlined,
            title: 'Görev atandığında',
            subtitle: 'Size bir madde atandığında haber verilsin',
            value: settings.onTaskAssigned,
            onChanged: (v) => runGuarded(context, () => notifier.setTaskAssigned(v)),
          ),
          NotificationToggleRow(
            icon: Icons.schedule_rounded,
            title: 'Uzun süre bekleyen maddeler',
            subtitle: 'Bir madde uzun süredir tamamlanmadıysa hatırlatılsın',
            value: settings.onLongPending,
            onChanged: (v) => runGuarded(context, () => notifier.setLongPending(v)),
            extra: _ThresholdPicker(
              selectedDays: settings.longPendingDays,
              onSelected: (d) => runGuarded(context, () => notifier.setLongPendingDays(d)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThresholdPicker extends StatelessWidget {
  final int selectedDays;
  final ValueChanged<int> onSelected;

  const _ThresholdPicker({required this.selectedDays, required this.onSelected});

  static const _options = [1, 3, 7];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Kaç gün sonra:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(width: 10),
        ..._options.map((days) {
          final isSelected = days == selectedDays;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => onSelected(days),
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                ),
                child: Text(
                  days == 1 ? '1 gün' : '$days gün',
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
