import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// The stored `category` value is always the original Turkish string (it's
/// what's persisted in Firestore) — this maps it to a localized display
/// label without touching the stored data or requiring a migration.
String categoryDisplayName(BuildContext context, String category) {
  final l10n = AppLocalizations.of(context)!;
  switch (category) {
    case 'Market Alışverişi':
      return l10n.categoryGroceryShopping;
    case 'Kişisel Alışveriş':
      return l10n.categoryPersonalShopping;
    case 'Ev İşleri':
      return l10n.categoryHousework;
    case 'Günlük Rutinler':
      return l10n.categoryDailyRoutines;
    case 'Sağlıklı Yaşam':
      return l10n.categoryHealthyLiving;
    case 'Antrenman Programı':
      return l10n.categoryWorkoutPlan;
    case 'Seyahat':
      return l10n.categoryTravel;
    case 'Valiz':
      return l10n.categoryPackingList;
    case 'İş Seyahati':
      return l10n.categoryBusinessTrip;
    case 'Piknik Hazırlığı':
      return l10n.categoryPicnicPrep;
    case 'Özel Günler':
      return l10n.categorySpecialOccasions;
    case 'Davet':
      return l10n.categoryParty;
    case 'Doğum Günü Hazırlığı':
      return l10n.categoryBirthdayPrep;
    case 'Hediye Organizasyonu':
      return l10n.categoryGiftPlanning;
    case 'Kitap Listesi':
      return l10n.categoryBookList;
    case 'Film Listesi':
      return l10n.categoryMovieList;
    case 'Çocuk':
      return l10n.categoryKids;
    case 'İş':
      return l10n.categoryWork;
    default:
      return l10n.categoryOther;
  }
}

IconData categoryIcon(String? category) {
  switch (category) {
    case 'Market Alışverişi':
      return Icons.shopping_cart_rounded;
    case 'Kişisel Alışveriş':
      return Icons.shopping_bag_rounded;
    case 'Ev İşleri':
      return Icons.home_rounded;
    case 'Günlük Rutinler':
      return Icons.repeat_rounded;
    case 'Sağlıklı Yaşam':
      return Icons.favorite_rounded;
    case 'Antrenman Programı':
      return Icons.fitness_center_rounded;
    case 'Seyahat':
      return Icons.flight_takeoff_rounded;
    case 'Valiz':
      return Icons.luggage_rounded;
    case 'İş Seyahati':
      return Icons.business_center_rounded;
    case 'Piknik Hazırlığı':
      return Icons.outdoor_grill_rounded;
    case 'Özel Günler':
      return Icons.celebration_rounded;
    case 'Davet':
      return Icons.groups_rounded;
    case 'Doğum Günü Hazırlığı':
      return Icons.cake_rounded;
    case 'Hediye Organizasyonu':
      return Icons.card_giftcard_rounded;
    case 'Kitap Listesi':
      return Icons.menu_book_rounded;
    case 'Film Listesi':
      return Icons.movie_rounded;
    case 'Çocuk':
      return Icons.child_care_rounded;
    case 'İş':
      return Icons.work_rounded;
    default:
      return Icons.checklist_rounded;
  }
}
