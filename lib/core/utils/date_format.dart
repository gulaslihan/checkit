const _trMonthsShort = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];

/// e.g. "22 Tem, 14:30" — hand-rolled so we don't need intl's locale data
/// tables loaded just for a month abbreviation.
String formatDueDate(DateTime d) {
  final day = d.day;
  final month = _trMonthsShort[d.month - 1];
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '$day $month, $hh:$mm';
}
