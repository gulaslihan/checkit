class Connection {
  final String id;
  final String requesterId;
  final String requesterEmail;
  final String recipientEmail;
  final bool accepted;
  final DateTime createdAt;

  const Connection({
    required this.id,
    required this.requesterId,
    required this.requesterEmail,
    required this.recipientEmail,
    required this.accepted,
    required this.createdAt,
  });

  /// The other person's email, given your own — works whichever side you're on.
  String otherEmail(String myEmail) => requesterEmail.toLowerCase() == myEmail.toLowerCase() ? recipientEmail : requesterEmail;
}
