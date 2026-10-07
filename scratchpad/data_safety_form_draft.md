# CheckIt — Play Console "Veri Güvenliği" (Data Safety) Formu Taslağı

*Hazırlanma tarihi: 20 Eylül 2026. Kodun/Firestore yapısının mevcut haline göre hazırlandı. Console'un ekran sırası/isimleri zamanla değişebilir — buradaki cevapları referans al, ekranı görünce birlikte teyit ederiz.*

---

## 1. "Uygulamanız kullanıcı verisi topluyor veya paylaşıyor mu?"

**Evet**

---

## 2. Toplanan veri türleri

Aşağıdaki kategorilerden SADECE işaretlenenler geçerli, geri kalan her kategori (Konum, Finansal bilgiler, Sağlık ve fitness, Mesajlar, Fotoğraf/video, Ses dosyaları, Kişiler, Takvim, Web tarama geçmişi, Uygulama etkinliği, Uygulama bilgisi ve performansı) için **"Hayır"**.

### Kişisel bilgiler
- **E-posta adresi** → Toplanıyor
- **Diğer bilgiler** (liste/madde metinleri, notlar, tarihler — kullanıcının oluşturduğu içerik) → Toplanıyor

### Cihaz veya diğer kimlikler
- **Cihaz kimliği** (FCM push bildirim token'ı) → Toplanıyor

---

## 3. Her veri türü için detay

### E-posta adresi
- **Toplanıyor mu?** Evet
- **Paylaşılıyor mu?** Hayır *(not: e-postan paylaştığın kişilere görünür, ama bu "3. taraf paylaşımı" değil — aynı uygulamanın kendi paylaşım özelliğinin normal parçası, Play bunu ayrı bir "veri paylaşımı" olarak saymıyor)*
- **İşlenme amacı:** Hesap yönetimi, Uygulama işlevselliği
- **Toplanması zorunlu mu?** Evet (hesap oluşturmak için şart)
- **Kullanıcı silebilir mi?** Evet (Profil → Hesabımı Sil)

### Diğer bilgiler (liste içeriği: madde metinleri, notlar, tarihler)
- **Toplanıyor mu?** Evet
- **Paylaşılıyor mu?** Hayır
- **İşlenme amacı:** Uygulama işlevselliği *(bu verinin toplanması uygulamanın temel işlevi — bir liste uygulaması listesiz olamaz)*
- **Toplanması zorunlu mu?** Evet
- **Kullanıcı silebilir mi?** Evet (madde/liste silme, hesap silme)

### Cihaz kimliği (FCM push token)
- **Toplanıyor mu?** Evet
- **Paylaşılıyor mu?** Hayır
- **İşlenme amacı:** Uygulama işlevselliği *(bildirim gönderebilmek için)*
- **Toplanması zorunlu mu?** Hayır (bildirimler ayarlardan kapatılabilir)
- **Kullanıcı silebilir mi?** Evet (hesap silme ile birlikte)

---

## 4. Güvenlik uygulamaları

- **Veri aktarım sırasında şifreleniyor mu?** Evet *(Firebase/Google Cloud altyapısı HTTPS/TLS kullanıyor)*
- **Kullanıcı veri silme talep edebiliyor mu?** Evet *(uygulama içi "Hesabımı Sil" özelliği — ayrıca bir web formu/e-posta talebi gerekmiyor)*
- **Bağımsız bir güvenlik denetiminden geçti mi?** Hayır *(dürüst cevap — küçük/bağımsız bir geliştirici projesi, resmi bir 3. taraf denetimi yaptırılmadı)*

---

## Notlar / gerekçe

- **Firebase/Google Cloud (Firestore, Auth, Cloud Functions, Vertex AI/Gemini) "3. taraf" olarak sayılmadı** — bunlar senin kendi projenin altyapısı, veriyi kendi amaçları için değil senin adına işliyorlar (Play'in "hizmet sağlayıcı" ayrımına giriyor, "veri paylaşımı" değil).
- **Yapay zeka özelliği** (kullanıcının yazdığı serbest metin prompt'un Gemini'ye gönderilmesi) ayrı bir kategori olarak yok — bu da "Diğer bilgiler" / uygulama işlevselliği kapsamında, çünkü aynı Google Cloud projesi içinde işleniyor.
- **Sesli komut özelliği** (mikrofon) için ayrı bir "Ses" kategorisi işaretlenmedi — ses, cihazın kendi konuşma tanıma sistemi üzerinden anlık olarak metne çevriliyor, CheckIt'in kendi sunucularına ham ses verisi hiç gönderilmiyor/saklanmıyor.
- **Analytics/reklam yok** — Firebase Analytics bu projede kapalı, reklam SDK'sı entegre değil. Bu yüzden "Uygulama etkinliği" ve "Uygulama bilgisi ve performansı" kategorileri boş bırakıldı.
- Play Billing (abonelik) devreye girince bu form güncellenmeli — "Finansal bilgiler" kategorisine satın alma geçmişi eklenmesi gerekecek. **Şimdilik atlanmadı, çünkü henüz gerçek bir satın alma akışı yok.**
