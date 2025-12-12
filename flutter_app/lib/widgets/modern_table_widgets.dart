import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

/// Modern Status Badge for Data Tables
class ModernStatusBadge extends StatelessWidget {
  final String status;
  final Color? backgroundColor;
  final Color? textColor;

  const ModernStatusBadge({
    super.key,
    required this.status,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getStatusColors(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? colors['bg'],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: AppTextStyles.badge.copyWith(
          color: textColor ?? colors['text'],
        ),
      ),
    );
  }

  Map<String, Color> _getStatusColors(String status) {
    final statusLower = status.toLowerCase();

    if (statusLower.contains('paid') ||
        statusLower.contains('active') ||
        statusLower.contains('approved') ||
        statusLower.contains('refunded') ||
        statusLower.contains('applied')) {
      return {
        'bg': AppColors.successLight,
        'text': AppColors.success,
      };
    } else if (statusLower.contains('pending') ||
        statusLower.contains('partial') ||
        statusLower.contains('open')) {
      return {
        'bg': AppColors.warningLight,
        'text': AppColors.warning,
      };
    } else if (statusLower.contains('unpaid') ||
        statusLower.contains('overdue') ||
        statusLower.contains('cancelled') ||
        statusLower.contains('rejected') ||
        statusLower.contains('inactive')) {
      return {
        'bg': AppColors.errorLight,
        'text': AppColors.error,
      };
    } else if (statusLower.contains('draft') ||
        statusLower.contains('issued')) {
      return {
        'bg': AppColors.infoLight,
        'text': AppColors.info,
      };
    }

    return {
      'bg': AppColors.backgroundSecondary,
      'text': AppColors.textSecondary,
    };
  }
}

/// Modern Action Button for Data Tables
class ModernActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final String? tooltip;

  const ModernActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color ?? AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Modern Table Header
class ModernTableHeader extends StatelessWidget {
  final String label;
  final bool sortable;
  final VoidCallback? onSort;

  const ModernTableHeader({
    super.key,
    required this.label,
    this.sortable = false,
    this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.tableHeader,
    );
  }
}

/// Modern Table Cell
class ModernTableCell extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const ModernTableCell({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style ?? AppTextStyles.tableData,
      textAlign: textAlign,
    );
  }
}

/// Helper function to create modern DataTable container
Widget buildModernDataTable({
  required List<DataColumn> columns,
  required List<DataRow> rows,
  bool showCheckboxColumn = false,
  double columnSpacing = 40,
}) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.borderLight, width: 1),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowLight,
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 1000, // Minimum width to ensure table doesn't shrink
            ),
            child: DataTable(
              showCheckboxColumn: showCheckboxColumn,
              columnSpacing: 85,
              headingRowHeight: 56,
              dataRowMinHeight: 64,
              dataRowMaxHeight: 72,
              headingRowColor: WidgetStateProperty.all(AppColors.tableHeader),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.borderLight, width: 1),
                ),
              ),
              columns: columns,
              rows: rows,
            ),
          ),
        ),
      ),
    ),
  );
}
