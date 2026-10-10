# CheckIt — Tester geri bildirim kaydı

Amaç: Google Play üretim başvurusunda (kapalı test anketi, "geri bildirim özeti ve nasıl toplandı" ile "testten öğrenilenlerle yapılan değişiklikler" soruları) kanıt olarak kullanmak. Rehber: Geri bildirimi kaydet, tekrarlayan temaları bul, başvuruda özetle.

**Nasıl toplanıyor:** Testerlar doğrudan Gülşen'e (birebir mesaj) yazıyor; ek olarak Play Store uygulama sayfasındaki özel geri bildirim (Console > İzle ve iyileştir > Puanlar ve yorumlar > Test geri bildirimi). Gelen her geri bildirim bu dosyaya eklenir.

**Nasıl kullanılır:** Yeni geri bildirim gelince Claude'a yapıştır; Claude aşağıdaki tabloya satır ekler (tarih, kaynak, ne dendi, karar, hangi sürümde çözüldü). Tester isimleri yazılmaz, "Tester A/B" gibi kısaltılır.

**Kaynak notu:** "Gülşen (test sırasında)" satırları geliştiricinin kendi kullanımında bulduğu şeylerdir; testerlardan geldiği yazılan satırlar (21-22 Eyl) tester mesajlarına dayanır. Başvuruda bu ayrım dürüstçe yansıtılmalı; hatalı attribution varsa düzelt.

**Durum etiketleri:** Çözüldü (yayında) · Çözüldü (1.0.1, incelemede) · Planlandı (backlog) · Hata değil (açıklandı) · Beklemede

| Tarih | Kaynak | Geri bildirim | Karar / yapılan değişiklik | Sürüm | Durum |
|---|---|---|---|---|---|
| 21 Eyl 2026 | Tester (birkaç kişi) | Kayıt sonrası doğrulama e-postası gelmiyor / spam klasörüne düşüyor | Firebase'in varsayılan göndericisi yerine kendi alan adımızdan (velanalytics.com) SendGrid ile e-posta gönderimi kuruldu, alan adı doğrulandı, gönderen adı ve konu düzeltildi | Sunucu tarafı (uygulama güncellemesi gerekmedi) | Çözüldü (yayında) |
| 22 Eyl 2026 | Tester A | Davetlerim ekranında yeşil "kabul et" tuşu çalışmıyor, kırmızı "reddet" çalışıyor | Neden: e-postası doğrulanmamış hesaplar daveti kabul edemiyor (güvenlik kuralı) ve uygulama genel bir "yetkiniz yok" gösteriyordu. Net uyarı mesajı eklendi: "Bu daveti kabul etmeden önce e-posta adresinizi doğrulamanız gerekiyor…" | 1.0.1 | Çözüldü (1.0.1, incelemede) |
| 22 Eyl 2026 | Tester A | Uygulama dili İngilizce ama "Paylaşma", "Kek ismarla" gibi Türkçe ifadeler görünüyor | Hata değil: bunlar kullanıcıların kendi yazdığı liste/madde adları, çeviriye tabi değil. Kod incelemesiyle doğrulandı | — | Hata değil (açıklandı) |
| Eyl 2026 | Tester B | Hotmail adresiyle giriş denemesinde "üye bulunamadı" | Hesap önce "Kayıt Ol" ile açılmamıştı; giriş akışı doğru çalışıyor. Giriş hata mesajı "Bu e-posta ile kayıtlı bir hesap bulunamadı." | — | Hata değil (açıklandı) |
| 23 Eyl 2026 | Gülşen (test sırasında) | Bir kullanıcı beni bağlantı kurmadan listeye ekledi, davet nasıl geldi? (davet ile bağlantı karışıklığı) | Sistem tasarlandığı gibi çalışıyor (bağlantı sadece isteğe bağlı kısayol). Karışıklığı gidermek için Davetlerim, Paylaş ve Bağlantılar ekranlarına açıklayıcı bilgi bantları ve dashboard'a karşılama ipuçları kartı eklendi | 1.0.1 | Çözüldü (1.0.1, incelemede) |
| 23 Eyl 2026 | Gülşen (test sırasında) | Bağlantılarım listesinde çarpıya yanlışlıkla basınca bağlantı anında siliniyor | Silmeden önce onay penceresi eklendi ("Bu bağlantı kaldırılsın mı?") | 1.0.1 | Çözüldü (1.0.1, incelemede) |
| 23 Eyl 2026 | Gülşen (test sırasında) | Davet edilen kişide CheckIt yoksa ne olacak, davet eden bunu bilmiyor | Davet eden kişiye "bu kişide hesap yok" uyarısı planlandı (kod yazılmadı) | — | Planlandı (backlog 7b) |
| 23 Eyl 2026 | Gülşen (test sırasında) | Tiklenebilir olmayan listelerde de madde bildirimi gidiyor; liste bazında bildirim kapatma isteniyor | Tiklenebilir olmayan listede bildirim kesilecek ve liste başına bildirim anahtarı eklenecek | — | Çözüldü (sunucu yayında 11 Eki; liste anahtarı 1.0.3) |
| Eki 2026 | Gülşen (iPhone testi) | iOS'ta uygulama ikonunun çevresinde beyaz çerçeve var | İkon iOS için yeniden hazırlandı | 1.0.1 (ortak kod/varlık) | Çözüldü, iPhone'da doğrulandı |
| Eki 2026 | Gülşen (iPhone testi) | iOS'ta sesli komutla madde ekledikten sonra yeni komutta eski madde alanda kalıyor | Sesli giriş eski sonuçları tekrar yazmayacak şekilde düzeltildi | 1.0.1 | Çözüldü, iPhone'da doğrulandı |
| Eki 2026 | Gülşen (iPhone testi) | iOS'ta liste düzenleme ekranındaki sağ üst çarpı basılamıyor | Kapat butonu dokunulabilir konuma alındı | 1.0.1 | Çözüldü, iPhone'da doğrulandı |
| Eki 2026 | Gülşen (iPhone testi) | Liste başlıkları tam görünmüyor, üç nokta ile kesiliyor | Uzun başlıklar iki satıra sığacak şekilde düzenlendi, başlık belirginleştirildi | 1.0.1 | Çözüldü, iPhone'da doğrulandı |
| Eki 2026 | Gülşen | Alt başlıklar maddesiz oluşturulabilsin, maddeler sonradan eklenebilsin | Orta ölçekli değişiklik, planlandı | — | Planlandı (backlog 20) |
| Eki 2026 | Gülşen (ürün incelemesi) | Hesap silmede şifre sonradan soruluyor; iptal edilirse veriler gitmiş ama hesap açık kalıyor; silince Profil ekranı açık kalıyor; hesap silinince kullanıcı profil kaydı kalıyor | Şifre artık en başta soruluyor ve doğrulanmadan hiçbir veri silinmiyor; silme sonrası ekran kapanıyor; profil kaydını silen sunucu fonksiyonu yayına alındı | 1.0.1 + sunucu | Çözüldü (sunucu yayında; web'de uçtan uca test edildi 10 Eki; uygulama 1.0.1 incelemede) |
| Eki 2026 | Gülşen (ürün incelemesi) | Yapay zeka özelliği doğrudan sunucuya çağrılarak kötüye kullanılabilir | Sunucuda doğrulanmış e-posta şartı eklendi | Sunucu tarafı | Çözüldü (yayında) |

## Henüz toplanmamış / sıradaki
- 10 Ekim 2026'dan itibaren başlayan ikinci 14 günlük kapalı testin geri bildirimleri aşağıya eklenecek.

## Başvuru anketi için özet notlar (güncel tut)
- Toplama yöntemi: testerlarla birebir mesajlaşma + Play özel geri bildirim.
- Tekrarlayan temalar: (1) e-posta doğrulama akışı kafa karıştırıcı/yetersiz bilgilendirme, (2) davet ile bağlantı ayrımının anlaşılması, (3) yanlışlıkla yapılan geri alınamaz işlemler (bağlantı silme).
- Test sırasında yayınlanan güncellemeler: sunucu tarafı e-posta düzeltmesi (Eyl 2026), 1.0.1 (Eki 2026).
