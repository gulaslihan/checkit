import 'package:flutter/widgets.dart';

const _trMonthsShort = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
const _enMonthsShort = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/// e.g. "22 Tem, 14:30" / "22 Jul, 14:30" — hand-rolled (matching the app's
/// current language) so we don't need intl's locale data tables loaded just
/// for a month abbreviation.
String formatDueDate(BuildContext context, DateTime d) {
  final months = Localizations.localeOf(context).languageCode == 'tr' ? _trMonthsShort : _enMonthsShort;
  final day = d.day;
  final month = months[d.month - 1];
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '$day $month, $hh:$mm';
}
