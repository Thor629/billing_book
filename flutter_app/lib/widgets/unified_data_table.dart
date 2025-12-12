import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

/// Unified Data Table - Use this across all screens for consistent design
/// Features:
/// - Warm orange header background
/// - White header text
/// - Rounded corners
/// - Hover effects
/// - Responsive scrolling
class UnifiedDataTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final bool showCheckboxColumn;
  final double? minWidth;

  const UnifiedDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.showCheckboxColumn = false,
    this.minWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F0), // Warm peach background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 12,
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
              constraints: BoxConstraints(
                minWidth: minWidth ?? MediaQuery.of(context).size.width - 320,
              ),
              child: DataTable(
                showCheckboxColumn: showCheckboxColumn,
                columnSpacing: 48,
                headingRowHeight: 56,
                dataRowMinHeight: 60,
                dataRowMaxHeight: 68,
                headingRowColor: WidgetStateProperty.all(AppColors.warning),
                dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.warningLight;
                    }
                    if (states.contains(WidgetState.hovered)) {
                      return AppColors.warningLight.withOpacity(0.5);
                    }
                    return const Color(0xFFFFF8F0); // Warm peach background
                  },
                ),
                dividerThickness: 1,
                columns: columns,
                rows: rows,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Unified Table Header Text - White text for orange header
class TableHeader extends StatelessWidget {
  final String text;
  final bool sortable;
  final bool ascending;
  final VoidCallback? onSort;

  const TableHeader(
    this.text, {
    super.key,
    this.sortable = false,
    this.ascending = true,
    this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
        if (sortable) ...[
          const SizedBox(width: 4),
          Icon(
            ascending ? Icons.arrow_upward : Icons.arrow_downward,
            size: 14,
            color: Colors.white70,
          ),
        ],
      ],
    );
  }
}

/// Unified Table Cell Text
class TableCellText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;

  const TableCellText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style ??
          GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
    );
  }
}

/// Unified Status Badge
class TableStatusBadge extends StatelessWidget {
  final String status;

  const TableStatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final colors = _getStatusColors();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors['bg'],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colors['text'],
        ),
      ),
    );
  }

  Map<String, Color> _getStatusColors() {
    final s = status.toLowerCase();

    if (s.contains('paid') ||
        s.contains('active') ||
        s.contains('approved') ||
        s.contains('completed') ||
        s.contains('success') ||
        s.contains('refunded')) {
      return {'bg': AppColors.successLight, 'text': AppColors.success};
    } else if (s.contains('pending') ||
        s.contains('partial') ||
        s.contains('open') ||
        s.contains('draft') ||
        s.contains('processing')) {
      return {'bg': AppColors.warningLight, 'text': AppColors.warning};
    } else if (s.contains('unpaid') ||
        s.contains('overdue') ||
        s.contains('cancelled') ||
        s.contains('rejected') ||
        s.contains('failed') ||
        s.contains('inactive')) {
      return {'bg': AppColors.errorLight, 'text': AppColors.error};
    } else if (s.contains('info') || s.contains('issued')) {
      return {'bg': AppColors.infoLight, 'text': AppColors.info};
    }

    return {'bg': AppColors.neutral200, 'text': AppColors.textSecondary};
  }
}

/// Unified Action Button
class TableActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final Color? color;

  const TableActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final button = InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (color ?? AppColors.textSecondary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: color ?? AppColors.textSecondary,
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}

/// Row of action buttons
class TableActionButtons extends StatelessWidget {
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onPrint;
  final List<Widget>? customActions;

  const TableActionButtons({
    super.key,
    this.onView,
    this.onEdit,
    this.onDelete,
    this.onPrint,
    this.customActions,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onView != null)
          TableActionButton(
            icon: Icons.visibility_outlined,
            onPressed: onView!,
            tooltip: 'View',
            color: AppColors.info,
          ),
        if (onEdit != null) ...[
          const SizedBox(width: 4),
          TableActionButton(
            icon: Icons.edit_outlined,
            onPressed: onEdit!,
            tooltip: 'Edit',
            color: AppColors.warning,
          ),
        ],
        if (onPrint != null) ...[
          const SizedBox(width: 4),
          TableActionButton(
            icon: Icons.print_outlined,
            onPressed: onPrint!,
            tooltip: 'Print',
            color: AppColors.textSecondary,
          ),
        ],
        if (onDelete != null) ...[
          const SizedBox(width: 4),
          TableActionButton(
            icon: Icons.delete_outlined,
            onPressed: onDelete!,
            tooltip: 'Delete',
            color: AppColors.error,
          ),
        ],
        if (customActions != null) ...customActions!,
      ],
    );
  }
}

/// Amount/Currency display
class TableAmount extends StatelessWidget {
  final double amount;
  final String currency;
  final bool showPositive;

  const TableAmount({
    super.key,
    required this.amount,
    this.currency = '₹',
    this.showPositive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isNegative = amount < 0;
    final displayAmount = amount.abs();

    return Text(
      '${isNegative ? '-' : (showPositive ? '+' : '')}$currency${displayAmount.toStringAsFixed(2)}',
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isNegative ? AppColors.error : AppColors.textPrimary,
      ),
    );
  }
}
