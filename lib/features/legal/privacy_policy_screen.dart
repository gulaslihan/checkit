import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'widgets/legal_section.dart';

/// Draft privacy policy — not certified legal advice, review with a lawyer
/// before opening the app up to real (non-developer) users. English content
/// is a faithful translation of the Turkish original — same legal
/// substance (including the KVKK reference, which applies regardless of
/// display language), not a separate/adapted policy.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final turkish = Localizations.localeOf(context).languageCode == 'tr';
    return Scaffold(
      appBar: AppBar(title: Text(turkish ? 'Gizlilik Politikası' : 'Privacy Policy')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            turkish ? 'Son güncelleme: 2026' : 'Last updated: 2026',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          ...(turkish ? _trSections : _enSections).map(
            (s) => LegalSection(title: s.$1, body: s.$2),
          ),
        ],
      ),
    );
  }
}

const _trSections = <(String, String)>[
  (
    '1. Veri Sorumlusu',
    'CheckIt uygulaması ("Uygulama", "biz") kapsamında işlenen kişisel verileriniz bakımından veri '
        'sorumlusu, Uygulamanın geliştiricisidir. Kişisel verilerinizle ilgili sorularınız için '
        'info@velanalytics.com adresinden bize ulaşabilirsiniz.',
  ),
  (
    '2. Toplanan Kişisel Veriler',
    '• Hesap bilgileri: e-posta adresiniz ve şifreniz (şifreniz Firebase Authentication tarafından '
        'güvenli şekilde saklanır, bize düz metin olarak ulaşmaz).\n'
        '• İçerik verileri: oluşturduğunuz listeler, madde metinleri, notlar ve tarihler.\n'
        '• Paylaşım verileri: bir listeyi veya bağlantı isteğini paylaştığınız kişilerin e-posta adresleri.\n'
        '• Kullanım verileri: bildirim tercihleriniz gibi uygulama içi ayarlar.',
  ),
  (
    '3. Kişisel Verilerin İşlenme Amaçları',
    'Kişisel verileriniz; hesabınızın oluşturulması ve kimlik doğrulaması, listelerinizin '
        'kaydedilmesi ve cihazlar arasında senkronize edilmesi, paylaşım ve davet özelliklerinin '
        'çalışması, size bildirim gönderilmesi ve uygulamanın güvenliğinin sağlanması amaçlarıyla '
        'işlenmektedir.',
  ),
  (
    '4. Saklama ve Aktarım',
    'Verileriniz, alt yüklenici olarak kullandığımız Google Firebase altyapısında saklanır. Bu '
        'altyapının sunucuları yurt dışında bulunabilir; bu durumda verileriniz, Uygulamayı kullanmaya '
        'başlamanızla verdiğiniz açık rıza kapsamında yurt dışına aktarılabilir. Verileriniz, '
        'yalnızca hizmetin sunulması için gerekli olan süre boyunca, hesabınızı silene kadar saklanır.',
  ),
  (
    '5. KVKK Kapsamındaki Haklarınız',
    '6698 sayılı Kişisel Verilerin Korunması Kanunu\'nun 11. maddesi uyarınca; kişisel verilerinizin '
        'işlenip işlenmediğini öğrenme, işlenmişse buna ilişkin bilgi talep etme, işlenme amacını ve '
        'amacına uygun kullanılıp kullanılmadığını öğrenme, yurt içinde/yurt dışında aktarıldığı '
        '3. kişileri bilme, eksik/yanlış işlenmişse düzeltilmesini isteme, silinmesini/yok edilmesini '
        'isteme ve bu işlemlerin aktarıldığı 3. kişilere bildirilmesini isteme haklarına sahipsiniz. '
        'Bu haklarınızı info@velanalytics.com üzerinden veya uygulama içindeki "Hesabımı Sil" '
        'seçeneğiyle kullanabilirsiniz.',
  ),
  (
    '6. Güvenlik',
    'Verileriniz, Firebase Authentication ile kimlik doğrulama ve Firestore güvenlik kurallarıyla '
        'korunmaktadır; bir listeye yalnızca sahibi ve açıkça paylaşılan kişiler erişebilir.',
  ),
  (
    '7. Değişiklikler',
    'Bu Gizlilik Politikası zaman zaman güncellenebilir. Önemli değişikliklerde sizi uygulama '
        'içinden bilgilendirmeye çalışırız.',
  ),
];

const _enSections = <(String, String)>[
  (
    '1. Data Controller',
    'For personal data processed within the CheckIt application ("the App", "we"), the data '
        'controller is the developer of the App. For questions about your personal data, you can '
        'reach us at info@velanalytics.com.',
  ),
  (
    '2. Personal Data Collected',
    '• Account information: your email address and password (your password is stored securely by '
        'Firebase Authentication and never reaches us as plain text).\n'
        '• Content data: the lists, item text, notes, and dates you create.\n'
        '• Sharing data: the email addresses of people you share a list or connection request with.\n'
        '• Usage data: in-app settings such as your notification preferences.',
  ),
  (
    '3. Purposes of Processing Personal Data',
    'Your personal data is processed for the purposes of creating and authenticating your account, '
        'saving your lists and syncing them across devices, operating the sharing and invite features, '
        'sending you notifications, and keeping the App secure.',
  ),
  (
    '4. Storage and Transfer',
    'Your data is stored on the Google Firebase infrastructure we use as a subprocessor. This '
        'infrastructure\'s servers may be located outside your country; in that case, your data may be '
        'transferred abroad under the explicit consent you give by starting to use the App. Your data '
        'is retained only for as long as necessary to provide the service, until you delete your account.',
  ),
  (
    '5. Your Rights under KVKK (Turkish Data Protection Law)',
    'Under Article 11 of Turkish Law No. 6698 on the Protection of Personal Data (KVKK), you have '
        'the right to learn whether your personal data is being processed, to request information about '
        'it if so, to learn the purpose of processing and whether it\'s used accordingly, to know the '
        'third parties to whom it\'s transferred domestically or abroad, to request correction if it\'s '
        'processed incompletely or incorrectly, to request its deletion or destruction, and to request '
        'that these actions be notified to third parties to whom the data was transferred. You can '
        'exercise these rights via info@velanalytics.com or the "Delete My Account" option in the app.',
  ),
  (
    '6. Security',
    'Your data is protected via Firebase Authentication for identity verification and Firestore '
        'security rules — only a list\'s owner and the people it\'s explicitly shared with can access it.',
  ),
  (
    '7. Changes',
    'This Privacy Policy may be updated from time to time. We try to notify you from within the app '
        'about significant changes.',
  ),
];
