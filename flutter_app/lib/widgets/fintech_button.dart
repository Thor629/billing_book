import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

enum WarmButtonStyle {
  peach,
  orange,
  pink,
  coral,
  white,
  dark,
  green,
  blue,
}

/// Modern warm-themed button
class WarmButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final WarmButtonStyle style;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double? height;
  final bool outlined;

  const WarmButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = WarmButtonStyle.peach,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height,
    this.outlined = false,
  });

  Color _getBackgroundColor() {
    if (outlined) return Colors.transparent;
    switch (style) {
      case WarmButtonStyle.peach:
        return AppColors.warmPeach;
      case WarmButtonStyle.orange:
        return AppColors.warmOrange;
      case WarmButtonStyle.pink:
        return AppColors.warmPink;
      case WarmButtonStyle.coral:
        return AppColors.warmCoral;
      case WarmButtonStyle.white:
        return AppColors.cardBackground;
      case WarmButtonStyle.dark:
        return AppColors.primary;
      case WarmButtonStyle.green:
        return AppColors.chipGreen;
      case WarmButtonStyle.blue:
        return AppColors.chipBlue;
    }
  }

  Color _getTextColor() {
    if (outlined) return AppColors.textPrimary;
    return style == WarmButtonStyle.dark
        ? AppColors.textLight
        : AppColors.buttonTextDark;
  }

  Color _getBorderColor() {
    switch (style) {
      case WarmButtonStyle.peach:
        return AppColors.warmPeach;
      case WarmButtonStyle.orange:
        return AppColors.warmOrange;
      case WarmButtonStyle.pink:
        return AppColors.warmPink;
      default:
        return AppColors.border;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height ?? 52,
      child: outlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: _getTextColor(),
                side: BorderSide(color: _getBorderColor(), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              child: _buildChild(),
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: _getBackgroundColor(),
                foregroundColor: _getTextColor(),
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              child: _buildChild(),
            ),
    );
  }

  Widget _buildChild() {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: _getTextColor(),
          ),
        ),
      ],
    );
  }
}

/// Compact icon button with warm colors
class WarmIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final WarmButtonStyle style;
  final double size;

  const WarmIconButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.style = WarmButtonStyle.peach,
    this.size = 80,
  });

  Color _getBackgroundColor() {
    switch (style) {
      case WarmButtonStyle.peach:
        return AppColors.warmPeach;
      case WarmButtonStyle.orange:
        return AppColors.warmOrange;
      case WarmButtonStyle.pink:
        return AppColors.warmPink;
      case WarmButtonStyle.coral:
        return AppColors.warmCoral;
      case WarmButtonStyle.white:
        return AppColors.cardBackground;
      case WarmButtonStyle.dark:
        return AppColors.primary;
      case WarmButtonStyle.green:
        return AppColors.chipGreen;
      case WarmButtonStyle.blue:
        return AppColors.chipBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: size,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28,
              color: AppColors.buttonTextDark,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.buttonTextDark,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// Backward compatibility aliases
typedef FintechButton = WarmButton;
typedef FintechIconButton = WarmIconButton;

enum FintechButtonStyle {
  yellow,
  green,
  blue,
  dark,
  pink,
  purple,
  orange,
  teal,
}

extension FintechToWarm on FintechButtonStyle {
  WarmButtonStyle toWarm() {
    switch (this) {
      case FintechButtonStyle.yellow:
        return WarmButtonStyle.peach;
      case FintechButtonStyle.green:
        return WarmButtonStyle.green;
      case FintechButtonStyle.blue:
        return WarmButtonStyle.blue;
      case FintechButtonStyle.dark:
        return WarmButtonStyle.dark;
      case FintechButtonStyle.pink:
        return WarmButtonStyle.pink;
      case FintechButtonStyle.purple:
        return WarmButtonStyle.coral;
      case FintechButtonStyle.orange:
        return WarmButtonStyle.orange;
      case FintechButtonStyle.teal:
        return WarmButtonStyle.green;
    }
  }
}
