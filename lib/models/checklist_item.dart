class ChecklistItem {
  final String id;
  final String text;
  final bool isDone;
  final String? assignedTo;
  final DateTime createdAt;

  /// 0 = no rating given, otherwise 1-5. Only shown when the parent
  /// list has `allowRating` enabled.
  final int rating;

  final String? note;
  final DateTime? dueDate;

  const ChecklistItem({
    required this.id,
    required this.text,
    this.isDone = false,
    this.assignedTo,
    required this.createdAt,
    this.rating = 0,
    this.note,
    this.dueDate,
  });

  ChecklistItem copyWith({String? text, bool? isDone, String? assignedTo, int? rating}) {
    return ChecklistItem(
      id: id,
      text: text ?? this.text,
      isDone: isDone ?? this.isDone,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt,
      rating: rating ?? this.rating,
      note: note,
      dueDate: dueDate,
    );
  }
}
