import 'package:flutter/material.dart';

/// Modern Warm Gradient Color System - Inspired by Smart Home UI
class AppColors {
  // Primary Warm Gradient Colors (from the design)
  static const Color warmPeach = Color(0xFFFFD4A3); // Main warm peach
  static const Color warmOrange = Color(0xFFFFC085); // Warm orange
  static const Color warmPink = Color(0xFFFFB5B5); // Soft pink
  static const Color warmCoral = Color(0xFFFFAB91); // Coral accent
  static const Color warmSunset = Color(0xFFFFCC80); // Sunset orange

  // Soft UI Colors (glassmorphism style)
  static const Color glassWhite = Color(0xFFFFFFFE);
  static const Color glassFrost = Color(0xFFF8F9FA);
  static const Color glassOverlay = Color(0x80FFFFFF);

  // Primary Colors
  static const Color primary = Color(0xFF2D3436);
  static const Color primaryDark = Color(0xFF1E272E);
  static const Color primaryLight = Color(0xFF636E72);
  static const Color primaryPale = Color(0xFFB2BEC3);

  // Accent Colors (from fintech + warm theme)
  static const Color accentYellow = Color(0xFFFFF3E0);
  static const Color accentGreen = Color(0xFFE8F5E9);
  static const Color accentBlue = Color(0xFFE3F2FD);
  static const Color accentOrange = Color(0xFFFFE0B2);
  static const Color accentTeal = Color(0xFFE0F2F1);

  // Secondary Colors
  static const Color secondary = warmPeach;
  static const Color secondaryDark = warmOrange;

  // Neutrals
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFEEEEEE);
  static const Color neutral300 = Color(0xFFE0E0E0);
  static const Color neutral400 = Color(0xFFBDBDBD);
  static const Color neutral500 = Color(0xFF9E9E9E);
  static const Color neutral600 = Color(0xFF757575);
  static const Color neutral700 = Color(0xFF616161);
  static const Color neutral900 = Color(0xFF212121);

  // Backgrounds - Warm gradient base
  static const Color background = Color(0xFFFFF8F0);
  static const Color backgroundSecondary = Color(0xFFFFF5EB);
  static const Color cardBackground = glassWhite;

  // Sidebar Colors - Soft Blue/Lavender theme
  static const Color sidebarBackground = Color(0xFFD6E4F0); // Soft blue
  static const Color sidebarDark = Color(0xFFC5D8E8); // Slightly darker blue
  static const Color sidebarHover = Color(0xFFE8F0F8); // Light hover
  static const Color sidebarActiveOrange =
      Color(0xFFFF9F43); // Warm orange highlight
  static const Color sidebarActiveLight = Color(0xFFFFE4CC); // Light orange bg
  static const Color sidebarText = Color(0xFF2D3436); // Dark text for sidebar
  static const Color sidebarTextMuted = Color(0xFF636E72); // Muted text

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);

  // Text Colors
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textTertiary = Color(0xFFB2BEC3);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textOnWarm = Color(0xFF5D4037);

  // Borders
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFF5F5F5);
  static const Color divider = Color(0xFFEEEEEE);

  // Tables - Warm Orange Theme
  static const Color tableHeader = warning; // Warm orange header
  static const Color tableHeaderText =
      Color(0xFFFFFFFF); // White text on orange
  static const Color tableRowEven = glassWhite;
  static const Color tableRowOdd = Color(0xFFFFFBF7);
  static const Color tableRowHover = warningLight; // Light orange hover
  static const Color tableBorder = Color(0xFFE0E0E0);

  // Main Gradient (Warm Sunset - from the design)
  static const LinearGradient warmGradient = LinearGradient(
    colors: [
      Color(0xFFFFD4A3),
      Color(0xFFFFB5B5),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [
      Color(0xFFFFC085),
      Color(0xFFFFAB91),
      Color(0xFFFFB5B5),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient peachGradient = LinearGradient(
    colors: [
      Color(0xFFFFE0B2),
      Color(0xFFFFCCBC),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient coralGradient = LinearGradient(
    colors: [
      Color(0xFFFFAB91),
      Color(0xFFFF8A65),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Primary Gradient (for sidebar/navigation)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF2D3436),
      Color(0xFF1E272E),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Card Gradients
  static const LinearGradient cardGradient = LinearGradient(
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFFFFBF7),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Background Gradient (full screen)
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [
      Color(0xFFFFD4A3),
      Color(0xFFFFE4C4),
      Color(0xFFFFF8F0),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.3, 1.0],
  );

  // Shadows
  static final Color shadowLight = Colors.black.withValues(alpha: 0.04);
  static final Color shadowMedium = Colors.black.withValues(alpha: 0.08);
  static final Color shadowDark = Colors.black.withValues(alpha: 0.12);
  static final Color shadowWarm = warmOrange.withValues(alpha: 0.15);

  // Button Colors
  static const Color buttonPrimary = warmPeach;
  static const Color buttonSecondary = glassWhite;
  static const Color buttonYellow = Color(0xFFFFF3E0);
  static const Color buttonGreen = Color(0xFFE8F5E9);
  static const Color buttonBlue = Color(0xFFE3F2FD);
  static const Color buttonTextDark = Color(0xFF2D3436);

  // Chip/Tag Colors
  static const Color chipGreen = Color(0xFFE8F5E9);
  static const Color chipBlue = Color(0xFFE3F2FD);
  static const Color chipOrange = Color(0xFFFFF3E0);
  static const Color chipPink = Color(0xFFFCE4EC);
  static const Color chipPurple = Color(0xFFF3E5F5);

  // Extended Pastel Palette
  static const Color pastelPink = Color(0xFFFFCDD2);
  static const Color pastelPurple = Color(0xFFE1BEE7);
  static const Color pastelOrange = Color(0xFFFFE0B2);
  static const Color pastelTeal = Color(0xFFB2DFDB);
  static const Color pastelDeepPurple = Color(0xFFD1C4E9);
  static const Color pastelLime = Color(0xFFF0F4C3);
  static const Color pastelDeepOrange = Color(0xFFFFCCBC);
  static const Color pastelCyan = Color(0xFFB2EBF2);
  static const Color pastelIndigo = Color(0xFFC5CAE9);
  static const Color pastelAmber = Color(0xFFFFECB3);

  // Backward compatibility
  static const Color activeGreen = success;
  static const Color inactiveGray = neutral400;
  static const Color expiredRed = error;
  static const Color textOnPrimary = textLight;
  static const Color secondaryAccent = secondary;
  static const Color tableSelected = accentBlue;
  static const Color primaryGradientStart = warmPeach;
  static const Color primaryGradientEnd = warmPink;

  // Category Colors (for charts, tags, avatars)
  static const List<Color> categoryColors = [
    warmPeach,
    warmOrange,
    warmPink,
    pastelTeal,
    pastelPurple,
    pastelDeepOrange,
    pastelCyan,
    pastelLime,
    pastelIndigo,
    pastelAmber,
  ];

  /// Get category color by index
  static Color getCategoryColor(int index) {
    return categoryColors[index % categoryColors.length];
  }

  /// Get avatar color based on name
  static Color getAvatarColor(String name) {
    if (name.isEmpty) return warmPeach;
    final index = name.codeUnitAt(0) % categoryColors.length;
    return categoryColors[index];
  }

  /// Get gradient for cards based on index
  static LinearGradient getCardGradient(int index) {
    final gradients = [
      warmGradient,
      peachGradient,
      coralGradient,
      sunsetGradient,
    ];
    return gradients[index % gradients.length];
  }
}
