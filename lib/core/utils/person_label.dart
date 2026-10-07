import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';
import '../../models/checklist.dart';

/// Shows "Siz"/"You" instead of your own email wherever a person's name is
/// displayed.
String personLabel(BuildContext context, String email) {
  final me = FirebaseAuth.instance.currentUser?.email;
  if (me != null && email.toLowerCase() == me.toLowerCase()) return AppLocalizations.of(context)!.you;
  return email;
}

/// Same as [personLabel], but prefers the list's per-list nickname for
/// [email] over their raw email when neither is "you" — and when it IS you,
/// still surfaces your own nickname (as "Siz - İsim") so you can confirm
/// what others see you as, instead of always just showing "Siz".
String listPersonLabel(BuildContext context, Checklist list, String email) {
  final me = FirebaseAuth.instance.currentUser?.email;
  final l10n = AppLocalizations.of(context)!;
  if (me != null && email.toLowerCase() == me.toLowerCase()) {
    final nickname = list.nicknames[email];
    return nickname == null || nickname.isEmpty ? l10n.you : l10n.youWithNickname(nickname);
  }
  return list.labelFor(email);
}

/// Same idea as [listPersonLabel], but for call sites that only have a raw
/// nicknames map (not a full [Checklist]) — e.g. a single item tile that
/// doesn't otherwise need the list object.
String assigneeChipLabel(BuildContext context, String person, Map<String, String> nicknames) {
  final l10n = AppLocalizations.of(context)!;
  if (personLabel(context, person) != l10n.you) return nicknames[person] ?? person;
  final nickname = nicknames[person];
  return nickname == null || nickname.isEmpty ? l10n.you : l10n.youWithNickname(nickname);
}
