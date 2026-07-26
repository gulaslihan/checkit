class NotificationSettings {
  final bool onItemCompleted;
  final bool onItemAdded;
  final bool onTaskAssigned;
  final bool onLongPending;
  final int longPendingDays;

  /// Local (on-device) reminder when an item's due date/time arrives —
  /// doesn't need push/Cloud Functions, scheduled entirely on the phone.
  final bool onDueDate;

  const NotificationSettings({
    this.onItemCompleted = true,
    this.onItemAdded = true,
    this.onTaskAssigned = true,
    this.onLongPending = true,
    this.longPendingDays = 3,
    this.onDueDate = true,
  });

  NotificationSettings copyWith({
    bool? onItemCompleted,
    bool? onItemAdded,
    bool? onTaskAssigned,
    bool? onLongPending,
    int? longPendingDays,
    bool? onDueDate,
  }) {
    return NotificationSettings(
      onItemCompleted: onItemCompleted ?? this.onItemCompleted,
      onItemAdded: onItemAdded ?? this.onItemAdded,
      onTaskAssigned: onTaskAssigned ?? this.onTaskAssigned,
      onLongPending: onLongPending ?? this.onLongPending,
      longPendingDays: longPendingDays ?? this.longPendingDays,
      onDueDate: onDueDate ?? this.onDueDate,
    );
  }

  Map<String, dynamic> toMap() => {
        'onItemCompleted': onItemCompleted,
        'onItemAdded': onItemAdded,
        'onTaskAssigned': onTaskAssigned,
        'onLongPending': onLongPending,
        'longPendingDays': longPendingDays,
        'onDueDate': onDueDate,
      };

  factory NotificationSettings.fromMap(Map<String, dynamic> map) => NotificationSettings(
        onItemCompleted: map['onItemCompleted'] as bool? ?? true,
        onItemAdded: map['onItemAdded'] as bool? ?? true,
        onTaskAssigned: map['onTaskAssigned'] as bool? ?? true,
        onLongPending: map['onLongPending'] as bool? ?? true,
        longPendingDays: map['longPendingDays'] as int? ?? 3,
        onDueDate: map['onDueDate'] as bool? ?? true,
      );
}
