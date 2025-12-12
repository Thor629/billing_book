import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

/// Professional Data Table with consistent styling
class ProfessionalDataTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final bool showCheckboxColumn;
  final double columnSpacing;

  const ProfessionalDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.showCheckboxColumn = false,
    this.columnSpacing = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // FULL WIDTH
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth:
                    MediaQuery.of(context).size.width - 300, // Sidebar width
              ),
              child: DataTable(
                showCheckboxColumn: showCheckboxColumn,
                columnSpacing: 95,
                headingRowHeight: 48,
                dataRowMinHeight: 56,
                dataRowMaxHeight: 64,
                headingRowColor: WidgetStateProperty.all(AppColors.warning),
                dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.hovered)) {
                      return AppColors.warningLight;
                    }
                    return AppColors.cardBackground;
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

/// Professional Status Badge
class StatusBadge extends StatelessWidget {
  final String status;
  final Color? backgroundColor;
  final Color? textColor;

  const StatusBadge({
    super.key,
    required this.status,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getStatusColors(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? colors['bg'],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase(),
        style: AppTextStyles.badge.copyWith(
          color: textColor ?? colors['text'],
        ),
      ),
    );
  }

  Map<String, Color> _getStatusColors(String status) {
    final s = status.toLowerCase();

    if (s.contains('paid') ||
        s.contains('active') ||
        s.contains('approved') ||
        s.contains('success') ||
        s.contains('completed')) {
      return {'bg': AppColors.warmOrange, 'text': AppColors.success};
    } else if (s.contains('pending') ||
        s.contains('partial') ||
        s.contains('open') ||
        s.contains('draft')) {
      return {'bg': AppColors.warmOrange, 'text': AppColors.warning};
    } else if (s.contains('unpaid') ||
        s.contains('overdue') ||
        s.contains('cancelled') ||
        s.contains('rejected') ||
        s.contains('failed')) {
      return {'bg': AppColors.errorLight, 'text': AppColors.error};
    }

    return {'bg': AppColors.neutral100, 'text': AppColors.neutral600};
  }
}

/// Professional Action Button
class ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final String? tooltip;

  const ActionButton({
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
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 18,
            color: color ?? AppColors.neutral600,
          ),
        ),
      ),
    );
  }
}

/// Table Header Text
class TableHeaderText extends StatelessWidget {
  final String text;

  const TableHeaderText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.tableHeader);
  }
}

/// Table Cell Text
class TableCellText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const TableCellText(this.text, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: style ?? AppTextStyles.tableData);
  }
}
