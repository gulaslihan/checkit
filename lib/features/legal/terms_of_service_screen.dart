import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'widgets/legal_section.dart';

/// Draft terms of service — not certified legal advice, review with a
/// lawyer before opening the app up to real (non-developer) users. English
/// content is a faithful translation of the Turkish original, including the
/// governing-law clause (still Turkey, regardless of display language).
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final turkish = Localizations.localeOf(context).languageCode == 'tr';
    return Scaffold(
      appBar: AppBar(title: Text(turkish ? 'Kullanım Şartları' : 'Terms of Service')),
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
    '1. Hizmetin Tanımı',
    'CheckIt, kullanıcıların kişisel veya paylaşımlı liste ve görevler oluşturmasına, '
        'bunları takip etmesine ve başkalarıyla paylaşmasına olanak tanıyan bir mobil uygulamadır.',
  ),
  (
    '2. Hesap Oluşturma',
    'Uygulamayı kullanabilmek için geçerli bir e-posta adresiyle hesap oluşturmanız ve '
        'e-postanızı doğrulamanız gerekir. Hesap bilgilerinizin gizliliğinden ve hesabınız '
        'üzerinden gerçekleşen işlemlerden siz sorumlusunuz.',
  ),
  (
    '3. Kullanıcı İçeriği',
    'Oluşturduğunuz liste ve madde içerikleri size aittir. Bir listeyi başka bir kullanıcıyla '
        'paylaştığınızda, o kullanıcının içeriği görüntüleyebileceğini ve (izin verdiğiniz ölçüde) '
        'değiştirebileceğini kabul edersiniz. Paylaştığınız içeriğin doğruluğundan ve '
        'uygunluğundan siz sorumlusunuz.',
  ),
  (
    '4. Yasak Kullanımlar',
    'Başkasının hesabına izinsiz erişmeye çalışmak, uygulamayı kötüye kullanmak, yanıltıcı '
        'bilgiyle hesap oluşturmak veya başkalarını rahatsız edici davetler/paylaşımlar '
        'göndermek yasaktır.',
  ),
  (
    '5. Hizmetin Değişmesi veya Sona Ermesi',
    'Uygulama şu an geliştirme aşamasındadır; özellikler zaman zaman değişebilir. Hesabınızı '
        'istediğiniz zaman "Hesabımı Sil" seçeneğiyle kapatabilirsiniz.',
  ),
  (
    '6. Sorumluluğun Sınırlandırılması',
    'Uygulama "olduğu gibi" sunulmaktadır. Veri kaybı, hizmet kesintisi veya kullanıcılar '
        'arasındaki anlaşmazlıklardan doğabilecek zararlardan makul özenin ötesinde sorumlu '
        'tutulamayız.',
  ),
  ('7. Uygulanacak Hukuk', 'Bu şartlar Türkiye Cumhuriyeti kanunlarına tabidir.'),
  ('8. İletişim', 'Sorularınız için info@velanalytics.com adresinden bize ulaşabilirsiniz.'),
];

const _enSections = <(String, String)>[
  (
    '1. Description of the Service',
    'CheckIt is a mobile application that lets users create, track, and share personal or shared '
        'lists and tasks with others.',
  ),
  (
    '2. Creating an Account',
    'To use the App, you need to create an account with a valid email address and verify your '
        'email. You are responsible for the confidentiality of your account information and for any '
        'activity that occurs under your account.',
  ),
  (
    '3. User Content',
    'The lists and item content you create belong to you. When you share a list with another user, '
        'you agree that they can view the content and (to the extent you allow) modify it. You are '
        'responsible for the accuracy and appropriateness of the content you share.',
  ),
  (
    '4. Prohibited Uses',
    'It is prohibited to attempt unauthorized access to another person\'s account, misuse the App, '
        'create an account with misleading information, or send invites/shares that harass others.',
  ),
  (
    '5. Changes to or Termination of the Service',
    'The App is currently in development; features may change from time to time. You can close '
        'your account at any time via the "Delete My Account" option.',
  ),
  (
    '6. Limitation of Liability',
    'The App is provided "as is". We cannot be held liable beyond reasonable care for damages '
        'arising from data loss, service interruption, or disputes between users.',
  ),
  ('7. Governing Law', 'These terms are governed by the laws of the Republic of Turkey.'),
  ('8. Contact', 'For questions, you can reach us at info@velanalytics.com.'),
];
