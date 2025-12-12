import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';
import '../constants/app_colors.dart';

/// Dynamic color generator using random_color library
/// Creates attractive, harmonious colors for the app
class ColorGenerator {
  static final RandomColor _randomColor = RandomColor();

  // Predefined attractive color palettes
  static final List<Color> _pastelPalette = [
    AppColors.accentYellow,
    AppColors.accentGreen,
    AppColors.accentBlue,
    const Color(0xFFFFCDD2), // Light Red
    const Color(0xFFE1BEE7), // Light Purple
    const Color(0xFFFFE0B2), // Light Orange
    const Color(0xFFB2DFDB), // Light Teal
    const Color(0xFFD1C4E9), // Light Deep Purple
    const Color(0xFFF0F4C3), // Light Lime
    const Color(0xFFFFCCBC), // Light Deep Orange
  ];

  /// Get a random pastel color (soft, attractive)
  static Color getRandomPastel() {
    return _randomColor.randomColor(
      colorSaturation: ColorSaturation.lowSaturation,
      colorBrightness: ColorBrightness.light,
    );
  }

  /// Get a random vibrant color (bold, eye-catching)
  static Color getRandomVibrant() {
    return _randomColor.randomColor(
      colorSaturation: ColorSaturation.highSaturation,
      colorBrightness: ColorBrightness.primary,
    );
  }

  /// Get a random color from specific hue
  static Color getRandomFromHue(ColorHue hue) {
    return _randomColor.randomColor(
      colorHue: hue,
      colorSaturation: ColorSaturation.mediumSaturation,
      colorBrightness: ColorBrightness.light,
    );
  }

  /// Get a color for avatar/profile based on name
  static Color getAvatarColor(String name) {
    final index = name.isEmpty ? 0 : name.codeUnitAt(0) % _pastelPalette.length;
    return _pastelPalette[index];
  }

  /// Get a color for category/tag based on index
  static Color getCategoryColor(int index) {
    return _pastelPalette[index % _pastelPalette.length];
  }

  /// Get a list of random harmonious colors
  static List<Color> getHarmoniousColors(int count) {
    return _randomColor.randomColors(
      count: count,
      colorSaturation: ColorSaturation.lowSaturation,
      colorBrightness: ColorBrightness.light,
    );
  }

  /// Get gradient colors for cards
  static List<Color> getGradientColors() {
    final baseColor = getRandomPastel();
    return [
      baseColor,
      Color.lerp(baseColor, Colors.white, 0.3)!,
    ];
  }

  /// Get a random fintech-style accent color
  static Color getRandomAccent() {
    final accents = [
      AppColors.accentYellow,
      AppColors.accentGreen,
      AppColors.accentBlue,
    ];
    return accents[DateTime.now().millisecond % accents.length];
  }

  /// Get status color with random variation
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'paid':
      case 'completed':
      case 'success':
        return _randomColor.randomColor(
          colorHue: ColorHue.green,
          colorSaturation: ColorSaturation.lowSaturation,
          colorBrightness: ColorBrightness.light,
        );
      case 'pending':
      case 'processing':
      case 'warning':
        return _randomColor.randomColor(
          colorHue: ColorHue.yellow,
          colorSaturation: ColorSaturation.lowSaturation,
          colorBrightness: ColorBrightness.light,
        );
      case 'inactive':
      case 'cancelled':
      case 'error':
      case 'failed':
        return _randomColor.randomColor(
          colorHue: ColorHue.red,
          colorSaturation: ColorSaturation.lowSaturation,
          colorBrightness: ColorBrightness.light,
        );
      case 'info':
      case 'draft':
        return _randomColor.randomColor(
          colorHue: ColorHue.blue,
          colorSaturation: ColorSaturation.lowSaturation,
          colorBrightness: ColorBrightness.light,
        );
      default:
        return getRandomPastel();
    }
  }
}

/// Extension for easy color manipulation
extension ColorExtension on Color {
  /// Lighten the color by percentage (0.0 - 1.0)
  Color lighten([double amount = 0.1]) {
    return Color.lerp(this, Colors.white, amount)!;
  }

  /// Darken the color by percentage (0.0 - 1.0)
  Color darken([double amount = 0.1]) {
    return Color.lerp(this, Colors.black, amount)!;
  }

  /// Get contrasting text color (black or white)
  Color get contrastText {
    final luminance = computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  /// Create a gradient with this color
  LinearGradient toGradient({Color? endColor}) {
    return LinearGradient(
      colors: [this, endColor ?? lighten(0.3)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
