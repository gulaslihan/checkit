/// Capitalizes the first letter — Turkish-aware, since Dart's default
/// `toUpperCase()` turns "i" into "I" (dotless), not the correct "İ".
String capitalizeFirst(String text) {
  if (text.isEmpty) return text;
  final first = text[0] == 'i' ? 'İ' : text[0].toUpperCase();
  return first + text.substring(1);
}
