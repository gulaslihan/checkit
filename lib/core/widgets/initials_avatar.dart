import 'package:flutter/material.dart';

const List<Color> _avatarPalette = [
  Color(0xFF4F46E5),
  Color(0xFF8B5CF6),
  Color(0xFFEC4899),
  Color(0xFFF59E0B),
  Color(0xFF10B981),
  Color(0xFF06B6D4),
];

Color colorForName(String name) {
  final hash = name.codeUnits.fold<int>(0, (a, b) => a + b);
  return _avatarPalette[hash % _avatarPalette.length];
}

/// A colored circle with a person's initial — color is stable per name so
/// the same collaborator always looks the same across the app.
class InitialsAvatar extends StatelessWidget {
  final String name;
  final double radius;

  /// What the color is derived from, if different from [name] — e.g. pass
  /// the person's email here while [name] shows a per-list nickname, so
  /// their avatar color stays stable regardless of which list is showing it.
  final String? colorKey;

  const InitialsAvatar({super.key, required this.name, this.radius = 16, this.colorKey});

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final initial = trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();
    return CircleAvatar(
      radius: radius,
      backgroundColor: colorForName((colorKey ?? name).trim()),
      child: Text(
        initial,
        style: TextStyle(color: Colors.white, fontSize: radius * 0.8, fontWeight: FontWeight.w600),
      ),
    );
  }
}
