import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primaryDark = Color(0xFF0E6B4F);
  static const Color primaryMedium = Color(0xFF1CAA6B);
  static const Color primaryBright = Color(0xFF0FA968);

  // Background
  static const Color background = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFF7F8FA);
  static const Color chipBackground = Color(0xFFE4E9FB);

  // Transaction colors
  static const Color income = Color(0xFF1CAA6B);
  static const Color expense = Color(0xFFE5484D);

  // Neutral
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFADB5BD);
  static const Color divider = Color(0xFFEEEEEE);
  static const Color navInactive = Color(0xFFADB5BD);

  // Navy logo
  static const Color navy = Color(0xFF1B2A4A);

  // Income icon background
  static const Color incomeBg = Color(0xFFE6F7EF);
  // Expense icon background
  static const Color expenseBg = Color(0xFFFEECED);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0E6B4F), Color(0xFF1CAA6B)],
  );

  static const LinearGradient cardGreenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D5C44), Color(0xFF0E6B4F), Color(0xFF1CAA6B)],
  );

  static const LinearGradient insightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE4E9FB), Color(0xFFDDE8F8)],
  );

  // Chart greens (donut chart)
  static const List<Color> chartColors = [
    Color(0xFF0E6B4F),
    Color(0xFF1CAA6B),
    Color(0xFF4DC78A),
    Color(0xFF82D9AE),
    Color(0xFFB3EDD0),
    Color(0xFF2196F3),
    Color(0xFFFF9800),
  ];
}
