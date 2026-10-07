# CheckIt — İş Listesi (26 Temmuz 2026 itibarıyla)

*Bu bir anlık görüntü (statik). 3 haftalık ara boyunca bulduğunuz her şeyi not edin, döndüğünüzde Claude Code'a toplu olarak aktarırız.*

## Devam Eden

- **#39 — Push notification (FCM) kurulumu**: Davet ve görev atama bildirimleri test edildi, çalışıyor. Madde eklendi/tamamlandı, uzun süre bekleyen madde hatırlatması, bağlantı isteği bildirimleri henüz test edilmedi.

## Bekleyen (Öncelik sırasına göre değil, kategoriye göre)

### Store / Yayına Hazırlık
- **#35** — Store tanıtım metni ve sayfaları hazırlama *(taslak hazır, revize bekliyor)*
- **#36** — Gizlilik Politikası/Kullanım Şartları'nı canlı bir web adresinde yayınlama (website gerekiyor)
- **#37** — Play Store Veri Güvenliği formu / App Store Gizlilik Etiketi
- **#38** — Gerçek support e-postası kurma (website ile birlikte yapılması planlandı)
- **#40** — Google Play Console ve Apple Developer hesabı açma
- **#41** — Android release imzalama anahtarı (keystore) oluşturma
- **#42** — Farklı cihaz/ekran boyutlarında test *(şu an yaptığınız gerçek cihaz testi tam da bu)*

### Bildirimler
- **#24** — Davet e-postası (e-posta servisi kurulumu gerekiyor)
- **#53** — Bildirim spam koruması (hızlı art arda işaretlemede debounce)
- **#54** — Madde tamamlanma push'unu geciktir + geri alma kontrolü *(yanlışlıkla dokunup geri alınca yanlış bildirim gitme sorunu — test sırasında bulundu)*

### Liste/Madde Davranışı
- **#55** — Atanan maddeyi sadece sahip/atanan kişi tamamlayabilsin *(test sırasında bulundu)*
- **#49** — Kategori madde önerilerini tek tek revize et
- **#51** — Free-text alanlara karakter sınırı ekle (liste adı, madde metni, not, takma isim)

### Güvenlik / Sağlamlaştırma
- **#52** — Firestore kurallarında veri şekli/boyut doğrulaması

### Büyük/Uzun Vadeli
- **#47** — İngilizce dil desteği (i18n)
- **#50** — Premium/ücretli özellik sistemi (in-app purchase)

## Bu 3 Hafta İçin Öneriler

1. **Gerçek cihaz testinde şunlara özellikle dikkat edin** (bilinen zayıf noktalar):
   - Push bildirimleri farklı uygulama durumlarında (açık/arka planda/tamamen kapalı) doğru geliyor mu, bildirime tıklayınca doğru yere gidiyor mu
   - Madde işaretleme/geri alma sırasında bildirim davranışı (#54'ün tetiklendiği senaryo)
   - Kategori önerilerinin gerçek hayatta ne kadar işe yaradığı (#49 için veri toplayın)
2. **Tasarımsal gözlemler için**: beğenmediğiniz/değiştirmek istediğiniz her ekranın ekran görüntüsünü alıp not düşün — döndüğünüzde doğrudan üzerinden gideriz, "hatırlamaya çalışmaktan" çok daha hızlı olur.
3. **Bulduğunuz her şeyi tek bir yerde** (telefonunuzun Notlar uygulaması, ya da Claude'un telefon uygulamasında kendinize yazacağınız bir sohbet) biriktirin — 3 hafta sonra buraya toplu yapıştırırsınız, ben görev listesine dağıtırım.
4. Smoke test listesindeki maddeleri **her yeni davranış değişikliğinde** (özellikle #54/#55 gibi bulduğunuz şeyleri elle test ederken) elinizin altında tutun.

## Faydalı Linkler (Safari'den açılabilir, Claude hesabınızla)

- [Smoke Test Checklist](https://claude.ai/code/artifact/99bc6787-03e1-4a62-b875-48d63fd76823)
- [Store Tanıtım Metni Taslağı](https://claude.ai/code/artifact/278c53c2-5f4d-4b74-8208-74f762d2f420)
