import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium Typography for Royal Charir
/// Using Inter font family for modern, clean look
class AppTextStyles {
  AppTextStyles._();

  // ============= DISPLAY STYLES (Hero, Large Headings) =============
  static TextStyle get displayLarge => GoogleFonts.outfit(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
        height: 1.1,
      );

  static TextStyle get displayMedium => GoogleFonts.outfit(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
      );

  static TextStyle get displaySmall => GoogleFonts.outfit(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.2,
      );

  // ============= HEADLINE STYLES (Section Headings) =============
  static TextStyle get headlineLarge => GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        height: 1.25,
      );

  static TextStyle get headlineMedium => GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.3,
      );

  static TextStyle get headlineSmall => GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.3,
      );

  // ============= TITLE STYLES (Card Titles, List Items) =============
  static TextStyle get titleLarge => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.3,
      );

  static TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.4,
      );

  static TextStyle get titleSmall => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.4,
      );

  // ============= BODY STYLES (Content Text) =============
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.5,
      );

  // ============= LABEL STYLES (Buttons, Chips, Tags) =============
  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.4,
      );

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.4,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.4,
      );

  // ============= BUTTON STYLES =============
  static TextStyle get buttonLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.4,
      );

  static TextStyle get buttonMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.4,
      );

  static TextStyle get buttonSmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.4,
      );

  // ============= SPECIAL STYLES =============
  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
        height: 1.4,
      );

  static TextStyle get overline => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
        height: 1.4,
      );

  static TextStyle get code => GoogleFonts.jetBrainsMono(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.5,
      );

  // Price/Number styles
  static TextStyle get priceTag => GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
      );

  static TextStyle get statNumber => GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
        height: 1.1,
      );
}
