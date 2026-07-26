import '../models/checklist.dart';
import 'local_notifications.dart';

class _ActiveReminder {
  final String listTitle;
  final String itemText;
  final DateTime dueDate;
  const _ActiveReminder(this.listTitle, this.itemText, this.dueDate);
}

/// Which item ids currently have a reminder scheduled — tracked so we know
/// what to cancel once an item is done/deleted/reassigned/date-cleared.
Set<String> _scheduledItemIds = {};

/// Reconciles the device's scheduled due-date reminders against the current
/// list state: schedules (or reschedules, harmlessly overwriting) every
/// still-relevant item, cancels every previously-scheduled item that's no
/// longer relevant. Only reminds for items assigned to [myEmail] or
/// unassigned — a shared list's items assigned to other people don't buzz
/// your phone.
Future<void> syncDueDateReminders(List<Checklist> lists, {required bool enabled, required String? myEmail}) async {
  if (!enabled) {
    for (final id in _scheduledItemIds) {
      await cancelDueDateReminder(id);
    }
    _scheduledItemIds = {};
    return;
  }

  final active = <String, _ActiveReminder>{};
  for (final list in lists) {
    for (final item in list.items) {
      if (item.isDone) continue;
      if (item.dueDate == null) continue;
      if (item.assignedTo != null && item.assignedTo != myEmail) continue;
      if (item.dueDate!.isBefore(DateTime.now())) continue;
      active[item.id] = _ActiveReminder(list.title, item.text, item.dueDate!);
    }
  }

  for (final id in _scheduledItemIds) {
    if (!active.containsKey(id)) {
      await cancelDueDateReminder(id);
    }
  }

  for (final entry in active.entries) {
    await scheduleDueDateReminder(
      itemId: entry.key,
      listTitle: entry.value.listTitle,
      itemText: entry.value.itemText,
      dueDate: entry.value.dueDate,
    );
  }

  _scheduledItemIds = active.keys.toSet();
}
