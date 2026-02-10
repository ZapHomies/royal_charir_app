import 'package:flutter/material.dart';

/// Royal Charir Premium Color Palette
/// Modern, vibrant colors with gradient support
class AppColors {
  AppColors._();

  // ============= PRIMARY COLORS =============
  static const Color primary = Color(0xFF6366F1); // Indigo-500
  static const Color primaryLight = Color(0xFF818CF8); // Indigo-400
  static const Color primaryDark = Color(0xFF4F46E5); // Indigo-600
  static const Color primaryContainer = Color(0xFFE0E7FF); // Indigo-100

  // ============= ACCENT COLORS =============
  static const Color accent = Color(0xFF8B5CF6); // Violet-500
  static const Color accentLight = Color(0xFFA78BFA); // Violet-400
  static const Color accentDark = Color(0xFF7C3AED); // Violet-600

  // ============= GRADIENT SETS =============
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, accent],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEC4899), Color(0xFFF97316)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
  );

  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
  );

  static const LinearGradient dangerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEF4444), Color(0xFFF87171)],
  );

  static const LinearGradient infoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
  );

  // Background gradients
  static const LinearGradient backgroundGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
  );

  static const LinearGradient backgroundGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
  );

  static const LinearGradient cardGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
  );

  static const LinearGradient cardGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E293B), Color(0xFF334155)],
  );

  // Mesh gradient colors for hero sections
  static const List<Color> meshGradientColors = [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF06B6D4),
  ];

  // ============= SEMANTIC COLORS =============
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successContainer = Color(0xFFD1FAE5);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningContainer = Color(0xFFFEF3C7);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorContainer = Color(0xFFFEE2E2);

  static const Color info = Color(0xFF0EA5E9);
  static const Color infoLight = Color(0xFF38BDF8);
  static const Color infoContainer = Color(0xFFE0F2FE);

  // ============= LIGHT THEME COLORS =============
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1F5F9);

  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textTertiaryLight = Color(0xFF94A3B8);
  static const Color textMutedLight = Color(0xFFCBD5E1);

  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color dividerLight = Color(0xFFF1F5F9);
  static const Color shadowLight = Color(0x1A0F172A);

  // ============= DARK THEME COLORS =============
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceVariantDark = Color(0xFF334155);

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);
  static const Color textTertiaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  static const Color borderDark = Color(0xFF334155);
  static const Color dividerDark = Color(0xFF1E293B);
  static const Color shadowDark = Color(0x400F172A);

  // ============= GLASSMORPHISM =============
  static Color glassLight = Colors.white.withValues(alpha: 0.7);
  static Color glassDark = const Color(0xFF1E293B).withValues(alpha: 0.7);
  static Color glassBorderLight = Colors.white.withValues(alpha: 0.3);
  static Color glassBorderDark = Colors.white.withValues(alpha: 0.1);

  // ============= CHART COLORS =============
  static const List<Color> chartColors = [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF06B6D4),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF3B82F6),
  ];

  // ============= STATUS COLORS =============
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusProcessing = Color(0xFF3B82F6);
  static const Color statusCompleted = Color(0xFF10B981);
  static const Color statusCancelled = Color(0xFFEF4444);
  static const Color statusPartial = Color(0xFF8B5CF6);

  // ============= CATEGORY COLORS =============
  static const List<Color> categoryColors = [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF06B6D4),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF3B82F6),
    Color(0xFF84CC16),
    Color(0xFF14B8A6),
  ];
}
