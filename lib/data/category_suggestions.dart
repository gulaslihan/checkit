/// Static starter-item suggestions shown when a category is picked while
/// creating a list. Not AI-generated — fixed lists for the MVP.
const List<String> listCategories = [
  'Alışveriş',
  'Seyahat',
  'Ev İşleri',
  'Çocuk',
  'Sağlıklı Yaşam',
  'İş',
  'Özel Günler',
  'Diğer',
];

const Map<String, List<String>> categorySuggestions = {
  'Alışveriş': [
    'Süt',
    'Ekmek',
    'Yumurta',
    'Peynir',
    'Meyve',
    'Sebze',
    'Deterjan',
    'Tuvalet kağıdı',
  ],
  'Seyahat': [
    'Uçak/otobüs bileti',
    'Otel rezervasyonu',
    'Pasaport / Kimlik',
    'Telefon şarj aleti',
    'Güneş gözlüğü',
    'Güneş kremi',
    'Seyahat sigortası',
    'İlaçlar',
  ],
  'Ev İşleri': [
    'Bulaşık',
    'Çöp',
    'Toz alma',
    'Cam silme',
    'Çamaşır',
    'Ütü',
  ],
  'Çocuk': [
    'Bebek bezi',
    'Mama',
    'Aşı takibi',
    'Okul malzemeleri',
    'Kıyafet',
    'Oyuncak',
  ],
  'Sağlıklı Yaşam': [
    'Su içmek',
    'Spor yapmak',
    'Vitamin',
    'Doktor randevusu',
    'Uyku düzeni',
  ],
  'İş': [
    'Toplantı notları',
    'E-postaları yanıtla',
    'Rapor hazırla',
    'Faturaları öde',
  ],
  'Özel Günler': [
    'Hediye al',
    'Davetiye gönder',
    'Pasta sipariş et',
    'Mekan ayarla',
    'Fotoğrafçı',
  ],
};
