# CheckIt — Smoke Test Checklist

*Her yeni APK/derleme sonrası hızlıca gözden geçirilecek temel akışlar. Amaç derinlemesine test değil, "hiçbir şey kırılmamış" güvencesi.*

## 1. Kimlik Doğrulama
- [ ] Yeni hesap oluşturma (kayıt) çalışıyor
- [ ] KVKK onay kutusu işaretlenmeden kayıt olunamıyor
- [ ] E-posta doğrulama ekranı çıkıyor, doğrulama e-postası geliyor
- [ ] E-posta doğrulanınca otomatik ana sayfaya geçiyor
- [ ] Çıkış yapıp tekrar giriş yapılabiliyor
- [ ] Şifremi unuttum / şifre sıfırlama e-postası gönderiliyor
- [ ] Şifre göster/gizle ikonu çalışıyor
- [ ] Yanlış şifre/e-posta girilince anlamlı bir hata mesajı çıkıyor (İngilizce/teknik metin değil)

## 2. Ana Sayfa / Dashboard
- [ ] Listeler doğru şekilde listeleniyor (kalıcı/geçici etiketleriyle)
- [ ] Arama kutusu listeleri filtreliyor
- [ ] Listeler sürükle-bırak ile sıralanabiliyor
- [ ] Geri tuşuna bir kez basınca çıkılmıyor, iki kez basınca çıkılıyor (Android)
- [ ] Her ekranda sağ üstteki ev ikonu ana sayfaya dönüyor

## 3. Liste Oluşturma
- [ ] Yeni liste (kalıcı) oluşturulabiliyor
- [ ] Yeni liste (geçici) oluşturulabiliyor
- [ ] Kategori seçilince öneri maddeleri çıkıyor, seçilenler listeye ekleniyor
- [ ] Boş isimle oluşturma denenince uyarı çıkıyor
- [ ] Puanlama/not/tarih-saat gibi opsiyonel ayarlar açılıp kapatılabiliyor

## 4. Liste Detay / Madde Yönetimi
- [ ] Madde ekleme (yazarak) çalışıyor
- [ ] Madde ekleme (mikrofonla) çalışıyor
- [ ] Yapıştırarak toplu madde ekleme çalışıyor
- [ ] Madde işaretleme/kaldırma çalışıyor
- [ ] Geçici liste tüm maddeler işaretlenince silme onayı soruyor
- [ ] Madde silme + "Geri Al" aksiyonu çalışıyor
- [ ] Madde sürükle-bırak ile sıralanabiliyor (sadece işaretlenmemişler arasında)
- [ ] Madde düzenleme (metin/not/tarih) çalışıyor
- [ ] Madde birine atanabiliyor, atanan kişi filtrelenebiliyor
- [ ] Seçili maddelerden yeni liste oluşturma çalışıyor
- [ ] Listeyi sıfırlama (tüm maddeleri işaretsiz yapma) çalışıyor
- [ ] Kalıcı/geçici olmayan davranış farkı doğru (tur: sil/sıfırla)

## 5. Paylaşım
- [ ] E-posta ile davet gönderme çalışıyor, geçersiz e-postada uyarı çıkıyor
- [ ] Bağlantılardan hızlı seçip davet etme çalışıyor
- [ ] Aynı kişiye iki kez davet gönderilemiyor
- [ ] Listeyi görebilenler listesi doğru gösteriliyor
- [ ] Sahip, paylaşılan kişiye takma isim verebiliyor
- [ ] Sahip olmayan biri takma isim/davet butonlarını göremiyor
- [ ] Paylaşılan kişi kendini listeden çıkarabiliyor
- [ ] Sahip başka birini listeden çıkarabiliyor

## 6. Bağlantılar
- [ ] Bağlantı isteği gönderme çalışıyor
- [ ] Gelen isteği kabul/reddetme çalışıyor
- [ ] Bağlantı kaldırma çalışıyor
- [ ] Kendine istek gönderilemiyor, tekrar istek gönderilemiyor

## 7. Davetlerim
- [ ] Yeni davet burada görünüyor, kabul/reddet çalışıyor
- [ ] Bağlantı istekleri burada görünüyor
- [ ] Size atanan görevler burada görünüyor, tıklayınca ilgili listeye gidiyor
- [ ] Genel bildirim rozeti (badge) doğru sayıyı gösteriyor ve görülünce sıfırlanıyor

## 8. Bildirimler
- [ ] Bildirim ayarları ekranındaki her anahtar açılıp kapanabiliyor
- [ ] Tarih/saat eklenen bir madde için yerel bildirim doğru zamanda geliyor
- [ ] Davet edilince push bildirimi geliyor (uygulama arka planda/kapalıyken)
- [ ] Görev atanınca push bildirimi geliyor
- [ ] Madde eklenince/tamamlanınca push bildirimi geliyor
- [ ] Bağlantı isteğinde push bildirimi geliyor
- [ ] Uygulama açıkken gelen push, uygulama içinde de gösteriliyor
- [ ] Bildirime tıklayınca doğru ekrana yönlendiriyor

## 9. Hesap / Profil
- [ ] Profil ekranı doğru bilgiyi gösteriyor
- [ ] Hesap silme akışı (onay + gerekirse şifre tekrar girme) çalışıyor
- [ ] Hesap silinince ait olduğu listeler/davetler/bağlantılar da temizleniyor

## 10. KVKK / Yasal
- [ ] Gizlilik Politikası ekranı açılıyor ve okunabilir
- [ ] Kullanım Şartları ekranı açılıyor ve okunabilir

## 11. Genel / Hata Durumları
- [ ] İnternet yokken bir işlem yapılırsa (ör. madde ekleme) kullanıcıya anlamlı bir hata mesajı çıkıyor, sessizce kaybolmuyor
- [ ] Uygulama simgesi ve açılış ekranı (splash) doğru logoyu gösteriyor
- [ ] Farklı ekran boyutunda (küçük/büyük telefon) düzen bozulmuyor
