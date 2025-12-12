import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Modern Typography System with Poppins
/// Clean, modern, and highly readable
class AppTextStyles {
  // Helper method with fallback to Poppins
  static TextStyle _safeFont({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? letterSpacing,
    double? height,
  }) {
    try {
      return GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );
    } catch (e) {
      return TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );
    }
  }

  // Display - Large headings
  static TextStyle get displayLarge => _safeFont(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
        height: 1.2,
      );

  static TextStyle get displayMedium => _safeFont(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
        height: 1.2,
      );

  // Headings
  static TextStyle get h1 => _safeFont(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
        height: 1.3,
      );

  static TextStyle get h2 => _safeFont(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.2,
        height: 1.3,
      );

  static TextStyle get h3 => _safeFont(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0,
        height: 1.4,
      );

  static TextStyle get h4 => _safeFont(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0,
        height: 1.4,
      );

  static TextStyle get h5 => _safeFont(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0,
        height: 1.5,
      );

  // Body Text
  static TextStyle get bodyLarge => _safeFont(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        letterSpacing: 0,
        height: 1.5,
      );

  static TextStyle get bodyMedium => _safeFont(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        letterSpacing: 0,
        height: 1.5,
      );

  static TextStyle get bodySmall => _safeFont(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        letterSpacing: 0,
        height: 1.4,
      );

  // Labels
  static TextStyle get labelLarge => _safeFont(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0,
        height: 1.4,
      );

  static TextStyle get labelMedium => _safeFont(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0,
        height: 1.4,
      );

  static TextStyle get labelSmall => _safeFont(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        letterSpacing: 0,
        height: 1.3,
      );

  static TextStyle get label => labelMedium;

  // Buttons
  static TextStyle get buttonLarge => _safeFont(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textLight,
        letterSpacing: 0,
        height: 1.2,
      );

  static TextStyle get buttonMedium => _safeFont(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textLight,
        letterSpacing: 0,
        height: 1.2,
      );

  static TextStyle get buttonSmall => _safeFont(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textLight,
        letterSpacing: 0,
        height: 1.2,
      );

  static TextStyle get button => buttonMedium;

  // Caption
  static TextStyle get caption => _safeFont(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        letterSpacing: 0,
        height: 1.3,
      );

  static TextStyle get overline => _safeFont(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textTertiary,
        letterSpacing: 1.0,
        height: 1.3,
      );

  // Table Styles
  static TextStyle get tableHeader => _safeFont(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textLight, // White text on orange header
        letterSpacing: 0.3,
        height: 1.3,
      );

  static TextStyle get tableData => _safeFont(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        letterSpacing: 0,
        height: 1.4,
      );

  // Special Styles
  static TextStyle get metric => _safeFont(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
        height: 1.1,
      );

  static TextStyle get metricSmall => _safeFont(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
        height: 1.2,
      );

  static TextStyle get currency => _safeFont(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0,
        height: 1.4,
      );

  static TextStyle get badge => _safeFont(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.2,
        height: 1.2,
      );

  static TextStyle get menuItem => _safeFont(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textLight,
        letterSpacing: 0,
        height: 1.4,
      );

  static TextStyle get menuItemActive => _safeFont(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textLight,
        letterSpacing: 0,
        height: 1.4,
      );

  // Warm Theme Specific
  static TextStyle get warmTitle => _safeFont(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textOnWarm,
        letterSpacing: -0.2,
        height: 1.3,
      );

  static TextStyle get warmSubtitle => _safeFont(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textOnWarm,
        letterSpacing: 0,
        height: 1.4,
      );

  static TextStyle get statusGood => _safeFont(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.success,
        letterSpacing: 0,
        height: 1.4,
      );
}
