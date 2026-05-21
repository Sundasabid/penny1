import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../config/themes/app_colors.dart';
import '../../utils/dashboard_aggregations.dart';
import '../../../domain/entities/transaction.dart';

class SpendingHeatmap extends StatefulWidget {
  final List<TransactionEntity> transactions;
  final String title;

  const SpendingHeatmap({
    super.key,
    required this.transactions,
    this.title = 'Spending Heatmap',
  });

  @override
  State<SpendingHeatmap> createState() => _SpendingHeatmapState();
}

class _SpendingHeatmapState extends State<SpendingHeatmap> {
  DateTime _selectedMonth = DateTime.now();

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    });
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(_selectedMonth.year, _selectedMonth.month);
    final leadingEmpty = firstDay.weekday % 7;
    
    final dailySpend = dailySpendForMonth(month: _selectedMonth, transactions: widget.transactions);

    final List<Widget> cells = [];

    // Weekday labels (S, M, T, W, T, F, S)
    final weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    for (var day in weekdays) {
      cells.add(
        Center(
          child: Text(
            day,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: isDark
                  ? AppColors.textOnDarkMuted
                  : AppColors.textOnLightMuted,
            ),
          ),
        ),
      );
    }

    // Empty cells for the start of the week
    for (int i = 0; i < leadingEmpty; i++) {
      cells.add(const SizedBox.shrink());
    }

    // Actual day cells
    for (int day = 1; day <= daysInMonth; day++) {
      final d = DateTime(_selectedMonth.year, _selectedMonth.month, day);
      final spent = dailySpend[_dateOnly(d)] ?? 0.0;

      int intensity = 0;
      if (spent > 0) {
        if (spent > 2000) {
          intensity = 3; // High
        } else if (spent > 1000) {
          intensity = 2; // Mid
        } else {
          intensity = 1; // Low
        }
      }
      cells.add(_HeatCell(intensity: intensity));
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131A21) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark ? const Color(0xFF1E272E) : const Color(0xFFF1F5F9),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0B1220),
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: _previousMonth,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.chevron_left_rounded, size: 16, color: AppColors.neon),
                      ),
                    ),
                    Text(
                      DateFormat('MMMM yyyy').format(_selectedMonth),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.neon,
                        letterSpacing: 0.5,
                      ),
                    ),
                    InkWell(
                      onTap: _nextMonth,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.neon),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: cells,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'LESS',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.textOnDarkMuted
                      : AppColors.textOnLightMuted,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              _LegendItem(intensity: 0),
              const SizedBox(width: 4),
              _LegendItem(intensity: 1),
              const SizedBox(width: 4),
              _LegendItem(intensity: 2),
              const SizedBox(width: 4),
              _LegendItem(intensity: 3),
              const SizedBox(width: 8),
              Text(
                'MORE',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.textOnDarkMuted
                      : AppColors.textOnLightMuted,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeatCell extends StatelessWidget {
  final int intensity;

  const _HeatCell({required this.intensity});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color cellColor;
    List<BoxShadow>? shadows;

    switch (intensity) {
      case 1:
        cellColor = AppColors.neon.withOpacity(0.2);
        break;
      case 2:
        cellColor = AppColors.neon.withOpacity(0.55);
        break;
      case 3:
        cellColor = AppColors.neon.withOpacity(0.9);
        if (isDark) {
          shadows = [
            BoxShadow(
              color: AppColors.neon.withOpacity(0.25),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ];
        }
        break;
      default:
        cellColor = isDark ? const Color(0xFF1C252E) : const Color(0xFFF8FAFC);
    }

    return Container(
      decoration: BoxDecoration(
        color: cellColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: shadows,
        border: intensity == 0
            ? Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.04)
                    : Colors.black.withOpacity(0.04),
              )
            : null,
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final int intensity;

  const _LegendItem({required this.intensity});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color boxColor;
    switch (intensity) {
      case 1:
        boxColor = AppColors.neon.withOpacity(0.2);
        break;
      case 2:
        boxColor = AppColors.neon.withOpacity(0.55);
        break;
      case 3:
        boxColor = AppColors.neon.withOpacity(0.9);
        break;
      default:
        boxColor = isDark ? const Color(0xFF1C252E) : const Color(0xFFF1F5F9);
    }

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
