import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFE8553A);
  static const Color primaryLight = Color(0xFFFFF0ED);
  static const Color accent = Color(0xFF1A8D7C);
  static const Color accentLight = Color(0xFFE6F7F5);

  static const Color text = Color(0xFF1A1D21);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  static const Color background = Color(0xFFF5F6F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF0F1F3);

  static const Color upvote = Color(0xFFE8553A);
  static const Color upvoteLight = Color(0xFFFFF0ED);
  static const Color downvote = Color(0xFF6366F1);
  static const Color downvoteLight = Color(0xFFEEF0FF);

  static const Color chipBg = Color(0xFFF0F1F3);
  static const Color chipActive = Color(0xFFE8553A);

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);

  static const List<Color> avatarColors = [
    Color(0xFFE8553A),
    Color(0xFF1A8D7C),
    Color(0xFF6366F1),
    Color(0xFFF59E0B),
    Color(0xFF10B981),
    Color(0xFFEC4899),
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
  ];

  static Color getAvatarColor(String name) {
    int hash = 0;
    for (int i = 0; i < name.length; i++) {
      hash = name.codeUnitAt(i) + ((hash << 5) - hash);
    }
    return avatarColors[hash.abs() % avatarColors.length];
  }
}
