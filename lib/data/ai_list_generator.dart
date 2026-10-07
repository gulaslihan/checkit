import 'package:cloud_functions/cloud_functions.dart';

class AiGeneratedItem {
  final String text;
  final String? subheading;

  const AiGeneratedItem({required this.text, this.subheading});
}

class AiGeneratedList {
  final String title;
  final String? category;
  final bool isCheckable;
  final bool allowRating;
  final bool allowDueDates;
  final bool allowNotes;
  final List<AiGeneratedItem> items;

  const AiGeneratedList({
    required this.title,
    required this.category,
    required this.isCheckable,
    required this.allowRating,
    required this.allowDueDates,
    required this.allowNotes,
    required this.items,
  });
}

/// Thrown when the signed-in user has hit [AiGenerationError.dailyLimitReached]
/// or the call otherwise failed — callers show a localized message per [kind].
enum AiGenerationErrorKind { dailyLimitReached, freeLimitReached, generic }

class AiGenerationException implements Exception {
  final AiGenerationErrorKind kind;
  const AiGenerationException(this.kind);
}

/// Calls the `generateListWithAI` Cloud Function (see functions/index.js) —
/// turns a free-form description into a ready-to-create CheckIt list. The
/// function itself resolves the target language from `users/{uid}.language`
/// and enforces the daily rate limit server-side.
Future<AiGeneratedList> generateListWithAI(String prompt) async {
  try {
    final result = await FirebaseFunctions.instance.httpsCallable('generateListWithAI').call<Map<String, dynamic>>({
      'prompt': prompt,
    });
    final data = Map<String, dynamic>.from(result.data as Map);
    final items = (data['items'] as List? ?? const [])
        .map((raw) {
          final map = Map<String, dynamic>.from(raw as Map);
          return AiGeneratedItem(text: map['text'] as String, subheading: map['subheading'] as String?);
        })
        .toList();
    return AiGeneratedList(
      title: data['title'] as String,
      category: data['category'] as String?,
      isCheckable: data['isCheckable'] as bool? ?? true,
      allowRating: data['allowRating'] as bool? ?? false,
      allowDueDates: data['allowDueDates'] as bool? ?? false,
      allowNotes: data['allowNotes'] as bool? ?? false,
      items: items,
    );
  } on FirebaseFunctionsException catch (e) {
    if (e.code == 'resource-exhausted') {
      throw AiGenerationException(
        e.message == 'free-limit-reached' ? AiGenerationErrorKind.freeLimitReached : AiGenerationErrorKind.dailyLimitReached,
      );
    }
    throw const AiGenerationException(AiGenerationErrorKind.generic);
  }
}
