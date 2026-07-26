import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'widgets/legal_section.dart';

/// Draft privacy policy — not certified legal advice, review with a lawyer
/// before opening the app up to real (non-developer) users.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gizlilik Politikası')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Text(
            'Son güncelleme: 2026',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          SizedBox(height: 20),
          LegalSection(
            title: '1. Veri Sorumlusu',
            body:
                'CheckIt uygulaması ("Uygulama", "biz") kapsamında işlenen kişisel verileriniz bakımından veri '
                'sorumlusu, Uygulamanın geliştiricisidir. Kişisel verilerinizle ilgili sorularınız için '
                'support@checkitapp.com adresinden bize ulaşabilirsiniz.',
          ),
          LegalSection(
            title: '2. Toplanan Kişisel Veriler',
            body:
                '• Hesap bilgileri: e-posta adresiniz ve şifreniz (şifreniz Firebase Authentication tarafından '
                'güvenli şekilde saklanır, bize düz metin olarak ulaşmaz).\n'
                '• İçerik verileri: oluşturduğunuz listeler, madde metinleri, notlar ve tarihler.\n'
                '• Paylaşım verileri: bir listeyi veya bağlantı isteğini paylaştığınız kişilerin e-posta adresleri.\n'
                '• Kullanım verileri: bildirim tercihleriniz gibi uygulama içi ayarlar.',
          ),
          LegalSection(
            title: '3. Kişisel Verilerin İşlenme Amaçları',
            body:
                'Kişisel verileriniz; hesabınızın oluşturulması ve kimlik doğrulaması, listelerinizin '
                'kaydedilmesi ve cihazlar arasında senkronize edilmesi, paylaşım ve davet özelliklerinin '
                'çalışması, size bildirim gönderilmesi ve uygulamanın güvenliğinin sağlanması amaçlarıyla '
                'işlenmektedir.',
          ),
          LegalSection(
            title: '4. Saklama ve Aktarım',
            body:
                'Verileriniz, alt yüklenici olarak kullandığımız Google Firebase altyapısında saklanır. Bu '
                'altyapının sunucuları yurt dışında bulunabilir; bu durumda verileriniz, Uygulamayı kullanmaya '
                'başlamanızla verdiğiniz açık rıza kapsamında yurt dışına aktarılabilir. Verileriniz, '
                'yalnızca hizmetin sunulması için gerekli olan süre boyunca, hesabınızı silene kadar saklanır.',
          ),
          LegalSection(
            title: '5. KVKK Kapsamındaki Haklarınız',
            body:
                '6698 sayılı Kişisel Verilerin Korunması Kanunu\'nun 11. maddesi uyarınca; kişisel verilerinizin '
                'işlenip işlenmediğini öğrenme, işlenmişse buna ilişkin bilgi talep etme, işlenme amacını ve '
                'amacına uygun kullanılıp kullanılmadığını öğrenme, yurt içinde/yurt dışında aktarıldığı '
                '3. kişileri bilme, eksik/yanlış işlenmişse düzeltilmesini isteme, silinmesini/yok edilmesini '
                'isteme ve bu işlemlerin aktarıldığı 3. kişilere bildirilmesini isteme haklarına sahipsiniz. '
                'Bu haklarınızı support@checkitapp.com üzerinden veya uygulama içindeki "Hesabımı Sil" '
                'seçeneğiyle kullanabilirsiniz.',
          ),
          LegalSection(
            title: '6. Güvenlik',
            body:
                'Verileriniz, Firebase Authentication ile kimlik doğrulama ve Firestore güvenlik kurallarıyla '
                'korunmaktadır; bir listeye yalnızca sahibi ve açıkça paylaşılan kişiler erişebilir.',
          ),
          LegalSection(
            title: '7. Değişiklikler',
            body:
                'Bu Gizlilik Politikası zaman zaman güncellenebilir. Önemli değişikliklerde sizi uygulama '
                'içinden bilgilendirmeye çalışırız.',
          ),
        ],
      ),
    );
  }
}
