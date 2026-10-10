import 'package:cloud_functions/cloud_functions.dart';

/// Whether [email] already has a CheckIt account, via the `checkAccountExists`
/// Cloud Function (which only answers for an email you've just invited or sent
/// a connection request to). Returns null when the answer is unknown (network
/// error, function unreachable) — callers should treat that as "don't warn",
/// never as "no account".
Future<bool?> accountExists(String email) async {
  try {
    final result = await FirebaseFunctions.instance.httpsCallable('checkAccountExists').call<Map<String, dynamic>>({'email': email});
    return Map<String, dynamic>.from(result.data as Map)['exists'] as bool?;
  } catch (_) {
    return null;
  }
}
