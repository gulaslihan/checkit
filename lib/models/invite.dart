class Invite {
  final String id;
  final String listId;
  final String listTitle;
  final String ownerId;
  final String ownerEmail;
  final String recipientEmail;
  final DateTime createdAt;

  const Invite({
    required this.id,
    required this.listId,
    required this.listTitle,
    required this.ownerId,
    required this.ownerEmail,
    required this.recipientEmail,
    required this.createdAt,
  });
}
