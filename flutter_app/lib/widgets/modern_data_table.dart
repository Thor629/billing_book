import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

class ModernDataTable extends StatefulWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final bool showCheckboxColumn;
  final double? columnSpacing;

  const ModernDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.showCheckboxColumn = false,
    this.columnSpacing = 40,
  });

  @override
  State<ModernDataTable> createState() => _ModernDataTableState();
}

class _ModernDataTableState extends State<ModernDataTable>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Set<int> _hoveredRows = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: DataTable(
            showCheckboxColumn: widget.showCheckboxColumn,
            columnSpacing: 85,
            headingRowHeight: 56,
            dataRowMinHeight: 64,
            dataRowMaxHeight: 72,
            headingRowColor: WidgetStateProperty.all(AppColors.warning),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderLight, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            columns: widget.columns.map((col) {
              return DataColumn(
                label: DefaultTextStyle(
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                  child: col.label,
                ),
                onSort: col.onSort,
              );
            }).toList(),
            rows: widget.rows.asMap().entries.map((entry) {
              final index = entry.key;
              final row = entry.value;
              final isHovered = _hoveredRows.contains(index);

              return DataRow(
                selected: row.selected,
                onSelectChanged: row.onSelectChanged,
                color: WidgetStateProperty.resolveWith<Color?>((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.tableSelected;
                  }
                  if (isHovered) {
                    return AppColors.tableRowHover;
                  }
                  return index.isEven
                      ? AppColors.tableRowEven
                      : AppColors.tableRowOdd;
                }),
                cells: row.cells.map((cell) {
                  return DataCell(
                    MouseRegion(
                      onEnter: (_) => setState(() => _hoveredRows.add(index)),
                      onExit: (_) => setState(() => _hoveredRows.remove(index)),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: DefaultTextStyle(
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          child: cell.child,
                        ),
                      ),
                    ),
                    onTap: cell.onTap,
                    placeholder: cell.placeholder,
                    showEditIcon: cell.showEditIcon,
                  );
                }).toList(),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
