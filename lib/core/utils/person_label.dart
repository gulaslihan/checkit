import 'package:firebase_auth/firebase_auth.dart';

import '../../models/checklist.dart';

/// Shows "Siz" instead of your own email wherever a person's name is displayed.
String personLabel(String email) {
  final me = FirebaseAuth.instance.currentUser?.email;
  if (me != null && email.toLowerCase() == me.toLowerCase()) return 'Siz';
  return email;
}

/// Same as [personLabel], but prefers the list's per-list nickname for
/// [email] over their raw email when neither is "you".
String listPersonLabel(Checklist list, String email) {
  final me = FirebaseAuth.instance.currentUser?.email;
  if (me != null && email.toLowerCase() == me.toLowerCase()) return 'Siz';
  return list.labelFor(email);
}
