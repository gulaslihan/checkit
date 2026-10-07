/// Fixed category list shown when creating/editing a list — used only to
/// pick the list's icon (see category_icon.dart), not for filtering,
/// grouping, or anything else. The Turkish string IS the stored value in
/// Firestore's `category` field, so this list can't be reordered/renamed
/// without a data migration — see categoryDisplayName() for the
/// locale-aware label shown in the UI.
const List<String> listCategories = [
  'Market Alışverişi',
  'Kişisel Alışveriş',
  'Ev İşleri',
  'Günlük Rutinler',
  'Sağlıklı Yaşam',
  'Antrenman Programı',
  'Seyahat',
  'Valiz',
  'İş Seyahati',
  'Piknik Hazırlığı',
  'Özel Günler',
  'Davet',
  'Doğum Günü Hazırlığı',
  'Hediye Organizasyonu',
  'Kitap Listesi',
  'Film Listesi',
  'Çocuk',
  'İş',
  'Diğer',
];
