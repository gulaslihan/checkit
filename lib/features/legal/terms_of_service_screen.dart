import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'widgets/legal_section.dart';

/// Draft terms of service — not certified legal advice, review with a
/// lawyer before opening the app up to real (non-developer) users.
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kullanım Şartları')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Text(
            'Son güncelleme: 2026',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          SizedBox(height: 20),
          LegalSection(
            title: '1. Hizmetin Tanımı',
            body:
                'CheckIt, kullanıcıların kişisel veya paylaşımlı liste ve görevler oluşturmasına, '
                'bunları takip etmesine ve başkalarıyla paylaşmasına olanak tanıyan bir mobil uygulamadır.',
          ),
          LegalSection(
            title: '2. Hesap Oluşturma',
            body:
                'Uygulamayı kullanabilmek için geçerli bir e-posta adresiyle hesap oluşturmanız ve '
                'e-postanızı doğrulamanız gerekir. Hesap bilgilerinizin gizliliğinden ve hesabınız '
                'üzerinden gerçekleşen işlemlerden siz sorumlusunuz.',
          ),
          LegalSection(
            title: '3. Kullanıcı İçeriği',
            body:
                'Oluşturduğunuz liste ve madde içerikleri size aittir. Bir listeyi başka bir kullanıcıyla '
                'paylaştığınızda, o kullanıcının içeriği görüntüleyebileceğini ve (izin verdiğiniz ölçüde) '
                'değiştirebileceğini kabul edersiniz. Paylaştığınız içeriğin doğruluğundan ve '
                'uygunluğundan siz sorumlusunuz.',
          ),
          LegalSection(
            title: '4. Yasak Kullanımlar',
            body:
                'Başkasının hesabına izinsiz erişmeye çalışmak, uygulamayı kötüye kullanmak, yanıltıcı '
                'bilgiyle hesap oluşturmak veya başkalarını rahatsız edici davetler/paylaşımlar '
                'göndermek yasaktır.',
          ),
          LegalSection(
            title: '5. Hizmetin Değişmesi veya Sona Ermesi',
            body:
                'Uygulama şu an geliştirme aşamasındadır; özellikler zaman zaman değişebilir. Hesabınızı '
                'istediğiniz zaman "Hesabımı Sil" seçeneğiyle kapatabilirsiniz.',
          ),
          LegalSection(
            title: '6. Sorumluluğun Sınırlandırılması',
            body:
                'Uygulama "olduğu gibi" sunulmaktadır. Veri kaybı, hizmet kesintisi veya kullanıcılar '
                'arasındaki anlaşmazlıklardan doğabilecek zararlardan makul özenin ötesinde sorumlu '
                'tutulamayız.',
          ),
          LegalSection(
            title: '7. Uygulanacak Hukuk',
            body: 'Bu şartlar Türkiye Cumhuriyeti kanunlarına tabidir.',
          ),
          LegalSection(
            title: '8. İletişim',
            body: 'Sorularınız için support@checkitapp.com adresinden bize ulaşabilirsiniz.',
          ),
        ],
      ),
    );
  }
}
