// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'CheckIt';

  @override
  String get paywallTitle => 'Ücretsiz liste hakkın bitti';

  @override
  String paywallBody(int limit) {
    return '$limit ücretsiz listenin tamamını oluşturdun. Mevcut listelerine erişmeye, onları düzenlemeye ve paylaşmaya devam edebilirsin — ama yeni bir liste oluşturmak için Premium\'a geçmen gerekiyor.';
  }

  @override
  String get paywallComingSoon =>
      'Premium çok yakında geliyor — hazır olduğunda burada satın alabileceksin.';

  @override
  String get okButton => 'Tamam';

  @override
  String get errorGeneric => 'Bir şeyler ters gitti, lütfen tekrar deneyin.';

  @override
  String get errorPermissionDenied => 'Bu işlem için yetkiniz yok.';

  @override
  String get errorUnavailable =>
      'Bağlantı sorunu — internetinizi kontrol edip tekrar deneyin.';

  @override
  String get errorNotFound => 'Aradığınız kayıt bulunamadı.';

  @override
  String get errorInvalidEmail => 'E-posta adresi geçersiz görünüyor.';

  @override
  String get errorUserDisabled => 'Bu hesap devre dışı bırakılmış.';

  @override
  String get errorUserNotFound =>
      'Bu e-posta ile kayıtlı bir hesap bulunamadı.';

  @override
  String get errorWrongCredential => 'E-posta veya şifre hatalı.';

  @override
  String get errorEmailAlreadyInUse =>
      'Bu e-posta zaten kullanımda, giriş yapmayı deneyin.';

  @override
  String get errorWeakPassword => 'Şifre en az 6 karakter olmalı.';

  @override
  String get errorTooManyRequests =>
      'Çok fazla deneme yapıldı, biraz sonra tekrar deneyin.';

  @override
  String get errorOperationNotAllowed =>
      'E-posta/şifre girişi Firebase Console\'da henüz açılmamış.';

  @override
  String get errorNoSession => 'Oturum bulunamadı.';

  @override
  String get errorCannotAddSelf => 'Kendinizi ekleyemezsiniz.';

  @override
  String get errorConnectionAlreadySent =>
      'Bu kişiye zaten bir bağlantı isteği gönderilmiş.';

  @override
  String get errorCannotInviteSelf => 'Kendinizi davet edemezsiniz.';

  @override
  String get errorEmailNotVerified =>
      'Bu daveti kabul etmeden önce e-posta adresinizi doğrulamanız gerekiyor. Kayıt olurken gönderilen doğrulama e-postasındaki linke tıklayın (gelen kutunuzda yoksa spam/gereksiz klasörüne bakın).';

  @override
  String errorWithDetail(String detail) {
    return 'Bir sorun oluştu: $detail';
  }

  @override
  String get homeTooltip => 'Ana Sayfa';

  @override
  String get voiceInputTooltip => 'Sesli komut';

  @override
  String get resetPasswordEmailRequired =>
      'Şifre sıfırlama bağlantısı gönderebilmemiz için önce e-postanızı yazın.';

  @override
  String resetPasswordSent(String email) {
    return '$email adresine şifre sıfırlama bağlantısı gönderildi.';
  }

  @override
  String get emailPasswordRequired => 'E-posta ve şifre gerekli.';

  @override
  String get mustAcceptTerms =>
      'Devam etmek için Gizlilik Politikası ve Kullanım Şartları\'nı kabul etmelisiniz.';

  @override
  String get signInTab => 'Giriş Yap';

  @override
  String get signUpTab => 'Kayıt Ol';

  @override
  String get emailLabel => 'E-posta';

  @override
  String get passwordLabel => 'Şifre';

  @override
  String get forgotPassword => 'Şifremi unuttum';

  @override
  String get acceptTermsPrefix => 'Okudum, kabul ediyorum:';

  @override
  String get privacyPolicyTitle => 'Gizlilik Politikası';

  @override
  String get termsOfServiceTitle => 'Kullanım Şartları';

  @override
  String get andConnector => ' ve';

  @override
  String get notVerifiedYet =>
      'Henüz doğrulanmamış görünüyor — e-postanızdaki bağlantıya tıklayıp tekrar deneyin.';

  @override
  String get verificationResent => 'Doğrulama e-postası tekrar gönderildi.';

  @override
  String get verifyEmailTitle => 'E-postanızı doğrulayın';

  @override
  String verifyEmailBody(String email) {
    return '$email adresine bir doğrulama bağlantısı gönderdik. Devam edebilmeniz için o bağlantıya tıklamanız gerekiyor — bu, listelerinizi başkalarıyla güvenle paylaşabilmeniz için önemli.';
  }

  @override
  String get checkVerifiedButton => 'Doğruladım, kontrol et';

  @override
  String get resendEmailButton => 'E-postayı tekrar gönder';

  @override
  String get signOut => 'Çıkış yap';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get save => 'Kaydet';

  @override
  String get emailInvalid => 'Geçerli bir e-posta girin.';

  @override
  String get emailHint => 'ornek@eposta.com';

  @override
  String get pendingAcceptance => 'Kabul bekleniyor';

  @override
  String get cancelTooltip => 'İptal Et';

  @override
  String get alreadyInvited => 'Bu kişiye zaten davet gönderilmiş.';

  @override
  String inviteSentToEmail(String email) {
    return 'Davet gönderildi — $email kabul edince size haber gelecek.';
  }

  @override
  String nicknameDialogTitle(String person) {
    return '$person için takma ad';
  }

  @override
  String get nicknameHint => 'ör. Halası';

  @override
  String shareScreenTitle(String title) {
    return '\"$title\" Paylaş';
  }

  @override
  String get shareInfoBanner =>
      'Davet ettiğiniz kişinin aynı e-posta adresiyle bir CheckIt hesabı olması gerekir. Zil simgesinden daveti kabul edince listeye erişimi hemen açılır.';

  @override
  String get invitesScreenInfoBanner =>
      'Daveti kabul etmek sizi birinin listesine ekler. Bağlantılar ise sık davet ettiğiniz kişiler için sadece kısayoldur. Davet kabul etmek için e-postanızın doğrulanmış olması gerekir.';

  @override
  String get inviteByEmailLabel => 'E-posta ile Davet Et';

  @override
  String get inviteButton => 'Davet Et';

  @override
  String get quickPicksLabel => 'Bağlantılarınızdan seçin';

  @override
  String get ownerOnlyInviteNotice =>
      'Bu listeye yeni kişi davet etme yetkisi sadece listenin sahibinde.';

  @override
  String get pendingInvitesLabel => 'Bekleyen Davetler';

  @override
  String peopleWhoCanSeeList(int count) {
    return 'Bu listeyi görebilenler ($count)';
  }

  @override
  String ownerWithNickname(String nickname) {
    return 'Sahibi · Diğerleri \"$nickname\" olarak görüyor';
  }

  @override
  String get ownerLabel => 'Sahibi';

  @override
  String get editOwnNameTooltip => 'Kendi adını değiştir';

  @override
  String get giveNicknameTooltip => 'Takma ad ver';

  @override
  String get leaveListTooltip => 'Listeden Ayrıl';

  @override
  String get removeTooltip => 'Çıkar';

  @override
  String get connectionsScreenTitle => 'Bağlantılarım';

  @override
  String get connectionsInfoBanner =>
      'Bağlantılar isteğe bağlı bir kısayoldur: bağlantı kurunca o kişiyi e-posta yazmadan listeye davet edebilirsiniz. Bağlantı kurmadan da herkesi e-posta ile davet edebilirsiniz.';

  @override
  String get addConnectionLabel => 'Bağlantı Ekle';

  @override
  String get sendButton => 'Gönder';

  @override
  String get incomingRequestsLabel => 'Gelen İstekler';

  @override
  String get rejectTooltip => 'Reddet';

  @override
  String get acceptTooltip => 'Kabul Et';

  @override
  String get sentRequestsLabel => 'Gönderilen İstekler';

  @override
  String yourConnectionsLabel(int count) {
    return 'Bağlantılarınız ($count)';
  }

  @override
  String get noConnectionsYet => 'Henüz bağlantınız yok.';

  @override
  String get removeConnectionTooltip => 'Bağlantıyı kaldır';

  @override
  String connectionRequestSent(String email) {
    return 'Bağlantı isteği gönderildi — $email';
  }

  @override
  String get removeConnectionTitle => 'Bu bağlantı kaldırılsın mı?';

  @override
  String removeConnectionConfirm(String email) {
    return '$email bağlantılarınızdan kaldırılacak. Fikrinizi değiştirirseniz daha sonra tekrar istek gönderebilirsiniz.';
  }

  @override
  String get removeConnectionAction => 'Kaldır';

  @override
  String get listNotificationsToggleTitle => 'Bu liste için bildirim';

  @override
  String get listNotificationsToggleSubtitle =>
      'Bu listedeki yeni madde, tamamlama ve atamalar listeyi paylaşan herkese bildirim gönderir. Kapatırsan liste tamamen sessize alınır.';

  @override
  String get inviteSentTitle => 'Davet gönderildi';

  @override
  String get connectionRequestSentTitle => 'İstek gönderildi';

  @override
  String noAccountInviteBody(String email) {
    return '$email henüz CheckIt kullanmıyor. Davet onu bekliyor: uygulamayı indirip aynı e-postayla kayıt olması gerekir.';
  }

  @override
  String noAccountConnectionBody(String email) {
    return '$email henüz CheckIt kullanmıyor. İstek onu bekliyor: uygulamayı indirip aynı e-postayla kayıt olması gerekir.';
  }

  @override
  String get sortTooltip => 'Sırala';

  @override
  String get selectItemsMenuItem => 'Maddeleri seç';

  @override
  String get bulkAddMenuItem => 'Toplu madde ekle';

  @override
  String get selectAllAction => 'Tümünü seç';

  @override
  String get deselectAllAction => 'Seçimi kaldır';

  @override
  String get selectionMoveAction => 'Taşı';

  @override
  String get selectionCopyAction => 'Kopyala';

  @override
  String get selectionNewListAction => 'Yeni liste';

  @override
  String get selectionHeadingAction => 'Alt başlık';

  @override
  String get addHeadingTitle => 'Alt Başlık Ekle';

  @override
  String get addHeadingMenuItem => 'Alt başlık ekle';

  @override
  String addItemToHeadingTitle(String heading) {
    return '\"$heading\" başlığına madde ekle';
  }

  @override
  String get addItemToHeadingTooltip => 'Bu başlığa madde ekle';

  @override
  String get emptyHeadingBadge => 'boş';

  @override
  String get headingsOptionalLabel => 'Alt başlıklar (isteğe bağlı)';

  @override
  String get headingsOptionalHint =>
      'Maddelerinizi gruplamak için başlıkları şimdi belirleyin, maddeleri sonra ekleyin.';

  @override
  String get headingNameHint => 'Başlık adı';

  @override
  String get addAction => 'Ekle';

  @override
  String get keepScreenOnTitle => 'Liste açıkken ekranı açık tut';

  @override
  String get keepScreenOnSubtitle =>
      'Bir liste açıkken ekran kararmaz ve kilitlenmez. Daha fazla pil harcar.';

  @override
  String get onboardWelcomeTitle => 'Listeni oluştur, paylaş, tekrar kullan';

  @override
  String get onboardWelcomeSubtitle =>
      'Market, seyahat, ev işleri, yemek tarifi, organizasyon hazırlığı... tüm listeler tek yerde.';

  @override
  String get onboardPointCreate =>
      'Saniyeler içinde liste yap, maddeleri işaretle';

  @override
  String get onboardPointShare => 'E-postayla davet et, birlikte işaretleyin';

  @override
  String get onboardPointAssign => 'Maddeleri birine ata, bildirim al';

  @override
  String get onboardPointAi => 'İstersen yapay zeka sana bir liste hazırlasın';

  @override
  String get onboardNext => 'Devam';

  @override
  String get onboardSkip => 'Atla';

  @override
  String get onboardLater => 'Şimdilik atla';

  @override
  String get onboardChoiceTitle => 'İlk listen ne olacak?';

  @override
  String get onboardChoiceSubtitle => 'Birini seç, senin için hazırlayalım.';

  @override
  String get onboardKindShopping => 'Alışveriş';

  @override
  String get onboardKindTravel => 'Seyahat ve valiz';

  @override
  String get onboardKindHome => 'Ev işleri';

  @override
  String get onboardKindRecipe => 'Yemek tarifi';

  @override
  String get onboardKindEvent => 'Organizasyon ve hazırlık';

  @override
  String get onboardKindWork => 'İş ve projeler';

  @override
  String get onboardKindOther => 'Başka bir şey';

  @override
  String get onboardTitleShopping => 'Haftalık market';

  @override
  String get onboardTitleTravel => 'Hafta sonu gezisi';

  @override
  String get onboardTitleHome => 'Ev işleri';

  @override
  String get onboardTitleRecipe => 'Yemek tarifi';

  @override
  String get onboardTitleEvent => 'Parti hazırlığı';

  @override
  String get onboardTitleWork => 'Yeni proje';

  @override
  String get onboardTitleOther => 'Yapılacaklar';

  @override
  String get onboardPromptShopping => 'Haftalık market alışverişi listesi';

  @override
  String get onboardPromptTravel => 'Hafta sonu gezisi için valiz listesi';

  @override
  String get onboardPromptHome => 'Haftalık ev işleri listesi';

  @override
  String get onboardPromptRecipe => 'Akşam yemeği tarifi için malzeme listesi';

  @override
  String get onboardPromptEvent => 'Doğum günü partisi hazırlık listesi';

  @override
  String get onboardPromptWork =>
      'Yeni bir proje başlatmak için yapılacaklar listesi';

  @override
  String get onboardPromptOther => 'Bu hafta yapmam gerekenler';

  @override
  String get onboardStartTitle => 'İlk listeni hazırlayalım';

  @override
  String get onboardStartSubtitle => 'Nasıl başlamak istersin?';

  @override
  String get onboardManualTitle => 'Kendim oluşturayım';

  @override
  String get onboardManualSubtitle =>
      'Adı ve kategorisi hazır, yeni bir liste açılır.';

  @override
  String get onboardAiTitle => 'Yapay zeka hazırlasın';

  @override
  String get onboardAiSubtitle =>
      'Bir cümleyle anlat, hazır bir liste gelsin. Kaydetmeden önce düzenleyebilirsin.';

  @override
  String get removeCollaboratorTitle => 'Bu kişi çıkarılsın mı?';

  @override
  String removeCollaboratorConfirm(String person) {
    return '$person bu listeye erişimini kaybedecek ve ona atanmış maddelerin ataması kaldırılacak.';
  }

  @override
  String get resetListConfirmTitle => 'Liste sıfırlansın mı?';

  @override
  String get resetListConfirmBody =>
      'Tüm maddelerin işareti kaldırılacak. Bu, listeyi paylaşan herkes için geçerli olur.';

  @override
  String get confirmDeleteAccountTitle =>
      'Hesabınızı silmek istediğinize emin misiniz?';

  @override
  String get confirmDeleteAccountBody =>
      'Bu işlem geri alınamaz. Sahibi olduğunuz tüm listeler ve ilişkili tüm verileriniz kalıcı olarak silinecek, hesabınız kapatılacaktır.';

  @override
  String get deleteMyAccountButton => 'Hesabımı Sil';

  @override
  String get confirmPasswordTitle => 'Devam etmek için şifrenizi girin';

  @override
  String get confirmButton => 'Onayla';

  @override
  String get profileTitle => 'Profil';

  @override
  String get notificationSettingsButton => 'Bildirim Ayarları';

  @override
  String get signOutButton => 'Çıkış Yap';

  @override
  String get languageSettingLabel => 'Dil';

  @override
  String get systemLanguageOption => 'Sistem Dili';

  @override
  String get myInvitesTitle => 'Davetlerim';

  @override
  String get newInvitesLabel => 'Yeni Davetler';

  @override
  String get connectionRequestsLabel => 'Bağlantı İstekleri';

  @override
  String get assignedTasksLabel => 'Size Atanan Görevler';

  @override
  String assignedInListSubtitle(String listTitle) {
    return '$listTitle listesinde size atandı';
  }

  @override
  String get wantsToConnect => 'Bağlantı kurmak istiyor';

  @override
  String invitedYouToList(String ownerEmail) {
    return '$ownerEmail sizi davet etti';
  }

  @override
  String get noPendingItems => 'Bekleyen bir şeyiniz yok';

  @override
  String get notificationSettingsTitle => 'Bildirim Ayarları';

  @override
  String get completionSoundToggleTitle => 'Tamamlama sesi';

  @override
  String get completionSoundToggleSubtitle =>
      'Bir maddeyi tiklerken kısa bir ses çalsın (telefonun medya ses seviyesine bağlıdır, sessiz moddan etkilenmez)';

  @override
  String get notifSettingsInfoBanner =>
      'Tarih/saat hatırlatmaları bu telefonda anında çalışır. Diğer ayarlar, uygulama Firebase üzerinden bildirim gönderdiğinde bu tercihlere göre karar verir.';

  @override
  String get dueDateToggleTitle => 'Tarih/saati gelen maddeler';

  @override
  String get dueDateToggleSubtitle =>
      'Bir maddeye eklediğiniz tarih/saat gelince bu telefonda hatırlatılsın';

  @override
  String get itemCompletedToggleTitle => 'Madde tamamlandığında';

  @override
  String get itemCompletedToggleSubtitle =>
      'Paylaşımlı bir listede biri madde tikleyince haber verilsin';

  @override
  String get itemAddedToggleTitle => 'Yeni madde eklendiğinde';

  @override
  String get itemAddedToggleSubtitle =>
      'Paylaşımlı bir listeye yeni madde eklenince haber verilsin';

  @override
  String get taskAssignedToggleTitle => 'Görev atandığında';

  @override
  String get taskAssignedToggleSubtitle =>
      'Size bir madde atandığında haber verilsin';

  @override
  String get longPendingToggleTitle => 'Uzun süre bekleyen maddeler';

  @override
  String get longPendingToggleSubtitle =>
      'Bir madde uzun süredir tamamlanmadıysa hatırlatılsın';

  @override
  String get daysThresholdLabel => 'Kaç gün sonra:';

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gün',
    );
    return '$_temp0';
  }

  @override
  String get you => 'Siz';

  @override
  String youWithNickname(String nickname) {
    return 'Siz - $nickname';
  }

  @override
  String get pendingItemsTitle => 'Bekleyen Maddeler';

  @override
  String get filterMine => 'Bende';

  @override
  String get filterOthers => 'Diğer Kişilerde';

  @override
  String pendingItemSubtitle(String listTitle, String person) {
    return 'Liste Adı: $listTitle · $person';
  }

  @override
  String get noPendingItemsMessage => 'Bekleyen madde yok';

  @override
  String get editTooltip => 'Düzenle';

  @override
  String get assignToTitle => 'Kime atansın?';

  @override
  String get unassignedLabel => 'Atanmamış';

  @override
  String ownerPrefix(String owner) {
    return 'Sahibi: $owner';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count madde',
    );
    return '$_temp0';
  }

  @override
  String get editItemTitle => 'Maddeyi Düzenle';

  @override
  String get itemLabel => 'Madde';

  @override
  String get noteOptionalLabel => 'Not (isteğe bağlı)';

  @override
  String get addDueDateButton => 'Tarih/Saat Ekle';

  @override
  String get removeDueDateTooltip => 'Tarihi kaldır';

  @override
  String get backPressToExit => 'Çıkmak için tekrar geri tuşuna basın';

  @override
  String get myListsTitle => 'Listelerim';

  @override
  String get invitesAndNotificationsTooltip => 'Davetlerim ve bildirimler';

  @override
  String get pendingTasksTooltip => 'Kişilere atanan bekleyen maddeler';

  @override
  String get archiveTooltip => 'Arşiv';

  @override
  String get profileTooltip => 'Profil';

  @override
  String get newListButton => 'Yeni Liste';

  @override
  String get mineLabel => 'Bana ait';

  @override
  String get sharedLabel => 'Paylaşımlı';

  @override
  String get allCollapsedTitle => 'Her şey toplu duruyor.';

  @override
  String get allCollapsedSubtitle =>
      'Listelerinizi tekrar görmek için başlıklara dokunmanız yeterli.';

  @override
  String get noResultsFound => 'Sonuç bulunamadı';

  @override
  String get noListsYetTitle => 'Henüz listeniz yok';

  @override
  String get noListsYetSubtitle =>
      'Aşağıdaki + butonuyla ilk listenizi oluşturun';

  @override
  String get searchListsHint => 'Listelerde ara...';

  @override
  String get searchArchiveHint => 'Arşivde ara...';

  @override
  String get archiveEmptyTitle => 'Arşivde liste yok';

  @override
  String get archiveEmptySubtitle =>
      'Bir liste tamamlandığında \"Arşivle\" diyerek buraya taşıyabilirsiniz';

  @override
  String get deleteListTitle => 'Listeyi sil';

  @override
  String deleteListConfirm(String title) {
    return '\"$title\" listesi kalıcı olarak silinecek. Emin misiniz?';
  }

  @override
  String get deleteAction => 'Sil';

  @override
  String get leaveListTitle => 'Listeden ayrıl';

  @override
  String leaveListConfirm(String title) {
    return '\"$title\" listesinden ayrılacaksınız ve bir daha erişemeyeceksiniz. Emin misiniz?';
  }

  @override
  String get leaveAction => 'Ayrıl';

  @override
  String listDuplicated(String title) {
    return '\"$title\" kopyalandı';
  }

  @override
  String listUnarchived(String title) {
    return '\"$title\" arşivden çıkarıldı';
  }

  @override
  String listArchived(String title) {
    return '\"$title\" arşivlendi';
  }

  @override
  String get editListTitle => 'Listeyi Düzenle';

  @override
  String get closeTooltip => 'Kapat';

  @override
  String get listNameLabel => 'Liste adı';

  @override
  String get checkableToggleTitle => 'Tiklenebilir liste';

  @override
  String get checkableToggleSubtitle =>
      'Kapatırsanız bu liste sadece madde tutmak/sıralamak için kullanılır';

  @override
  String get starRatingToggleTitle => 'Yıldız puanlama';

  @override
  String get starRatingToggleSubtitle => 'Maddelere 1-5 yıldız verilebilsin';

  @override
  String get dueDateToggleTitleGeneric => 'Tarih/saat eklenebilir';

  @override
  String get dueDateToggleSubtitleGeneric =>
      'Maddelere tarih/saat eklenip tarihe göre sıralanabilsin';

  @override
  String get notesToggleTitle => 'Not eklenebilir';

  @override
  String get notesToggleSubtitle => 'Maddelere kısa bir not eklenebilsin';

  @override
  String get categoryLabel => 'Kategori';

  @override
  String get duplicateListButton => 'Listeyi Kopyala';

  @override
  String get unarchiveButton => 'Arşivden Çıkar';

  @override
  String get archiveButton => 'Arşivle';

  @override
  String get listNameRequired => 'Lütfen bir liste adı girin';

  @override
  String get listNameHint => 'ör. Haftalık Market';

  @override
  String get categoryOptionalLabel => 'Kategori (isteğe bağlı)';

  @override
  String get createListButton => 'Listeyi Oluştur';

  @override
  String get addItemHint => 'Yeni madde ekle...';

  @override
  String get bulkImportTitle => 'Toplu Madde Ekle';

  @override
  String get bulkImportSubtitle =>
      'Notlarınızdan kopyaladığınız metni buraya yapıştırın — her satır ayrı bir madde olarak eklenir.';

  @override
  String get bulkImportHint => 'Süt\nEkmek\nYumurta\n...';

  @override
  String get addItemsButton => 'Maddeleri Ekle';

  @override
  String selectedCountLabel(int count) {
    return '$count seçildi';
  }

  @override
  String get newListNameTitle => 'Yeni Liste Adı';

  @override
  String newListFromSelectionDefaultTitle(String title) {
    return '$title (Seçilenler)';
  }

  @override
  String get createAction => 'Oluştur';

  @override
  String newListCreatedWithCount(String title, int count) {
    return '\"$title\" oluşturuldu ($count madde)';
  }

  @override
  String get noOtherListsToMoveOrCopy =>
      'Taşınacak/kopyalanacak başka bir listeniz yok.';

  @override
  String get pickListToMoveTitle => 'Hangi listeye taşınsın?';

  @override
  String get pickListToCopyTitle => 'Hangi listeye kopyalansın?';

  @override
  String itemsMovedToList(int count, String title) {
    return '$count madde \"$title\" listesine taşındı';
  }

  @override
  String itemsCopiedToList(int count, String title) {
    return '$count madde \"$title\" listesine kopyalandı';
  }

  @override
  String get renameHeadingTitle => 'Alt Başlığı Yeniden Adlandır';

  @override
  String get assignToHeadingMenuItem => 'Alt Başlığa Ata';

  @override
  String get shareTooltip => 'Paylaş';

  @override
  String get moreActionsTooltip => 'Diğer işlemler';

  @override
  String get resetMenuItem => 'Sıfırla';

  @override
  String get sortManualMenuItem => 'Elle sırala';

  @override
  String get sortAlphaMenuItem => 'Alfabetik sırala';

  @override
  String get sortNewestMenuItem => 'Yeni eklenen üstte';

  @override
  String get sortOldestMenuItem => 'Eski eklenen üstte';

  @override
  String get sortDueDateMenuItem => 'Tarihe göre sırala';

  @override
  String get searchItemsHint => 'Maddelerde ara...';

  @override
  String get listCompletedTitle => 'Liste tamamlandı 🎉';

  @override
  String get listCompletedNonOwnerBody =>
      'Listedeki tüm maddeler tamamlandı. Liste sahibi listeyi sıfırlayıp yeniden kullanıma hazırlayabilir, arşive kaldırabilir ya da silebilir.';

  @override
  String get okAction => 'Tamam';

  @override
  String listCompletedOwnerBody(String title) {
    return '\"$title\" listesindeki tüm maddeler tamamlandı. Ne yapmak istersiniz?';
  }

  @override
  String get keepAsIsAction => 'Böyle kalsın';

  @override
  String itemDeletedSnackbar(String text) {
    return '\"$text\" silindi';
  }

  @override
  String get undoAction => 'Geri Al';

  @override
  String get completedSectionLabel => 'Tamamlananlar';

  @override
  String get headingActionsTooltip => 'Alt başlık işlemleri';

  @override
  String get renameAction => 'Yeniden Adlandır';

  @override
  String get removeHeadingAction => 'Başlığı Kaldır';

  @override
  String get newHeadingNameHint => 'Yeni başlık adı';

  @override
  String get noHeadingAction => 'Başlıksız yap';

  @override
  String get noItemsYetTitle => 'Henüz madde yok';

  @override
  String get noItemsYetSubtitle =>
      'Aşağıdan yazarak/mikrofonla ekleyin ya da yapıştırarak toplu aktarın';

  @override
  String get allFilterLabel => 'Tümü';

  @override
  String get categoryGroceryShopping => 'Market Alışverişi';

  @override
  String get categoryPersonalShopping => 'Kişisel Alışveriş';

  @override
  String get categoryHousework => 'Ev İşleri';

  @override
  String get categoryDailyRoutines => 'Günlük Rutinler';

  @override
  String get categoryHealthyLiving => 'Sağlıklı Yaşam';

  @override
  String get categoryWorkoutPlan => 'Antrenman Programı';

  @override
  String get categoryTravel => 'Seyahat';

  @override
  String get categoryPackingList => 'Valiz';

  @override
  String get categoryBusinessTrip => 'İş Seyahati';

  @override
  String get categoryPicnicPrep => 'Piknik Hazırlığı';

  @override
  String get categorySpecialOccasions => 'Özel Günler';

  @override
  String get categoryParty => 'Davet';

  @override
  String get categoryBirthdayPrep => 'Doğum Günü Hazırlığı';

  @override
  String get categoryGiftPlanning => 'Hediye Organizasyonu';

  @override
  String get categoryBookList => 'Kitap Listesi';

  @override
  String get categoryMovieList => 'Film Listesi';

  @override
  String get categoryKids => 'Çocuk';

  @override
  String get categoryWork => 'İş';

  @override
  String get categoryOther => 'Diğer';

  @override
  String get openSystemLanguageSettings => 'Sistem ayarlarında aç';

  @override
  String get aiCreateButton => 'Yapay Zeka ile Oluştur';

  @override
  String get aiPromptSheetTitle => 'Nasıl bir liste istersiniz?';

  @override
  String get aiPromptHint =>
      'ör. 5-12 Ağustos arası Roma\'ya gideceğim. Şehir deneyimleme ve sanatla ilgileniyorum.';

  @override
  String get aiGenerating => 'Oluşturuluyor…';

  @override
  String get aiDailyLimitReached =>
      'Günlük yapay zeka kullanım limitine ulaştınız, yarın tekrar deneyin.';

  @override
  String get aiFreeLimitReached =>
      'Ücretsiz liste hakkınız bitti, yeni liste oluşturmak için Premium\'a geçmeniz gerekiyor.';

  @override
  String get aiGenerationFailed =>
      'Liste oluşturulamadı, lütfen tekrar deneyin.';

  @override
  String get aiItemsPreviewLabel => 'Yapay zekanın önerdiği maddeler';
}
