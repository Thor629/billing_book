import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

/// Colorful avatar with dynamic background based on name
class ColorfulAvatar extends StatelessWidget {
  final String name;
  final double size;
  final TextStyle? textStyle;

  const ColorfulAvatar({
    super.key,
    required this.name,
    this.size = 48,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getAvatarColor(name);
    final initials = _getInitials(name);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size / 3),
      ),
      child: Center(
        child: Text(
          initials,
          style: textStyle ??
              GoogleFonts.poppins(
                fontSize: size * 0.4,
                fontWeight: FontWeight.w600,
                color: AppColors.buttonTextDark,
              ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}

/// Colorful tag/chip with pastel background
class ColorfulTag extends StatelessWidget {
  final String label;
  final int colorIndex;
  final VoidCallback? onTap;
  final bool removable;
  final VoidCallback? onRemove;

  const ColorfulTag({
    super.key,
    required this.label,
    this.colorIndex = 0,
    this.onTap,
    this.removable = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getCategoryColor(colorIndex);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.buttonTextDark,
              ),
            ),
            if (removable) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onRemove,
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: AppColors.buttonTextDark,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Colorful status badge with dynamic colors
class ColorfulStatusBadge extends StatelessWidget {
  final String status;
  final bool showDot;

  const ColorfulStatusBadge({
    super.key,
    required this.status,
    this.showDot = true,
  });

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'active':
      case 'paid':
      case 'completed':
      case 'success':
      case 'approved':
        return AppColors.accentGreen;
      case 'pending':
      case 'processing':
      case 'draft':
        return AppColors.accentYellow;
      case 'inactive':
      case 'cancelled':
      case 'failed':
      case 'rejected':
        return AppColors.pastelPink;
      case 'info':
      case 'new':
        return AppColors.accentBlue;
      case 'overdue':
      case 'expired':
        return AppColors.pastelDeepOrange;
      default:
        return AppColors.pastelPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.buttonTextDark.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            status,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.buttonTextDark,
            ),
          ),
        ],
      ),
    );
  }
}

/// Gradient card with random attractive colors
class GradientCard extends StatelessWidget {
  final Widget child;
  final LinearGradient? gradient;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const GradientCard({
    super.key,
    required this.child,
    this.gradient,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient ?? AppColors.warmGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

/// Colorful metric card for dashboards
class ColorfulMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final int colorIndex;
  final String? subtitle;
  final VoidCallback? onTap;

  const ColorfulMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.colorIndex = 0,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getCategoryColor(colorIndex);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: AppColors.buttonTextDark,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.buttonTextDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.buttonTextDark.withOpacity(0.7),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.buttonTextDark.withOpacity(0.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Random color generator widget for dynamic UI
class RandomColorBox extends StatefulWidget {
  final Widget child;
  final double borderRadius;

  const RandomColorBox({
    super.key,
    required this.child,
    this.borderRadius = 16,
  });

  @override
  State<RandomColorBox> createState() => _RandomColorBoxState();
}

class _RandomColorBoxState extends State<RandomColorBox> {
  late Color _color;
  final RandomColor _randomColor = RandomColor();

  @override
  void initState() {
    super.initState();
    _color = _randomColor.randomColor(
      colorSaturation: ColorSaturation.lowSaturation,
      colorBrightness: ColorBrightness.light,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: widget.child,
    );
  }
}

/// Colorful progress indicator
class ColorfulProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final int colorIndex;

  const ColorfulProgressBar({
    super.key,
    required this.progress,
    this.height = 8,
    this.colorIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getCategoryColor(colorIndex);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}
