import 'package:flutter/material.dart';

IconData categoryIcon(String? category) {
  switch (category) {
    case 'Alışveriş':
      return Icons.shopping_cart_rounded;
    case 'Seyahat':
      return Icons.luggage_rounded;
    case 'Ev İşleri':
      return Icons.home_rounded;
    case 'Çocuk':
      return Icons.child_care_rounded;
    case 'Sağlıklı Yaşam':
      return Icons.favorite_rounded;
    case 'İş':
      return Icons.work_rounded;
    case 'Özel Günler':
      return Icons.celebration_rounded;
    default:
      return Icons.checklist_rounded;
  }
}
