import 'package:flutter/material.dart';

class SpendingHeatmap extends StatelessWidget {
  const SpendingHeatmap({
    super.key,
    required this.month,
    required this.dailySpend,
    required this.title,
  });

  final DateTime month;
  final Map<DateTime, double> dailySpend;
  final String title;

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    final startWeekday = firstDay.weekday; // Mon=1..Sun=7
    final leadingEmpty = startWeekday - 1;

    final values = <double>[];
    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(month.year, month.month, d);
      values.add(dailySpend[_dateOnly(date)] ?? 0);
    }
    final maxVal = values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);

    final cells = <Widget>[];
    for (int i = 0; i < leadingEmpty; i++) {
      cells.add(const _HeatCell.empty());
    }
    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(month.year, month.month, d);
      final val = dailySpend[_dateOnly(date)] ?? 0;
      final intensity = (maxVal <= 0) ? 0.0 : (val / maxVal).clamp(0.0, 1.0);
      cells.add(_HeatCell(intensity: intensity));
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE6E8EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF101828),
                  ),
                ),
              ),
              Text(
                _monthName(month),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF98A2B3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _DowLabel('M'),
              _DowLabel('T'),
              _DowLabel('W'),
              _DowLabel('T'),
              _DowLabel('F'),
              _DowLabel('S'),
              _DowLabel('S'),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final cellSize = (constraints.maxWidth - (6 * 10)) / 7;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: cells
                    .map((w) => SizedBox(width: cellSize, height: cellSize, child: w))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  static String _monthName(DateTime d) {
    const names = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December'
    ];
    return names[d.month - 1];
  }
}

class _DowLabel extends StatelessWidget {
  const _DowLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF98A2B3),
      ),
    );
  }
}

class _HeatCell extends StatelessWidget {
  const _HeatCell({required this.intensity}) : isEmpty = false;
  const _HeatCell.empty()
      : intensity = 0,
        isEmpty = true;

  final double intensity;
  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    if (isEmpty) return const SizedBox.shrink();

    const base = Color(0xFF18B27A);
    final opacity = (0.12 + (0.88 * intensity)).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: base.withOpacity(opacity),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
