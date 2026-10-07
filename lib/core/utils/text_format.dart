/// Capitalizes the first letter — Turkish-aware when [turkish] is true,
/// since Dart's default `toUpperCase()` turns "i" into "I" (dotless), not
/// the correct "İ".
String capitalizeFirst(String text, {required bool turkish}) {
  if (text.isEmpty) return text;
  final first = turkish && text[0] == 'i' ? 'İ' : text[0].toUpperCase();
  return first + text.substring(1);
}
