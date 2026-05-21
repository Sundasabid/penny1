import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../config/themes/app_colors.dart';

class ForecastChart extends StatelessWidget {
  final List<double> actualDailySpend;
  final double projectedMonthEnd;

  const ForecastChart({
    super.key,
    required this.actualDailySpend,
    required this.projectedMonthEnd,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (actualDailySpend.isEmpty || actualDailySpend.length < 3) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Column(
          children: [
            Icon(Icons.show_chart_rounded, color: Colors.grey.withOpacity(0.4), size: 36),
            const SizedBox(height: 12),
            const Text('Not enough data for a forecast yet.', style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      );
    }

    // Build cumulative actual spend
    final cumulativeActual = <FlSpot>[];
    double runningTotal = 0;
    for (int i = 0; i < actualDailySpend.length; i++) {
      runningTotal += actualDailySpend[i];
      cumulativeActual.add(FlSpot(i.toDouble(), runningTotal));
    }

    // Build projected line (from last actual point to projected month end)
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final dailyAvg = runningTotal / actualDailySpend.length;
    final projectedSpots = <FlSpot>[];
    double projectedRunning = runningTotal;
    for (int i = actualDailySpend.length; i < daysInMonth; i++) {
      projectedRunning += dailyAvg;
      projectedSpots.add(FlSpot(i.toDouble(), projectedRunning));
    }

    // Add the bridge point
    if (projectedSpots.isNotEmpty) {
      projectedSpots.insert(0, FlSpot(actualDailySpend.length.toDouble() - 1, runningTotal));
    }

    final maxY = (projectedSpots.isNotEmpty ? projectedSpots.last.y : runningTotal) * 1.15;
    final todayIndex = actualDailySpend.length - 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.show_chart_rounded, color: AppColors.neon, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'SPENDING FORECAST',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: AppColors.neon),
                  ),
                ],
              ),
              if (projectedMonthEnd > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.neon.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Est. ${projectedMonthEnd.round()} PKR',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.neon),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _legendDot(AppColors.neon, 'Actual Spend'),
              const SizedBox(width: 16),
              _legendDot(Colors.grey.withOpacity(0.6), 'Penny Projection'),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.1),
                    strokeWidth: 1,
                  ),
                  drawVerticalLine: false,
                ),
                extraLinesData: ExtraLinesData(
                  verticalLines: [
                    VerticalLine(
                      x: todayIndex.toDouble(),
                      color: AppColors.neon.withOpacity(0.3),
                      strokeWidth: 2,
                      dashArray: [4, 4],
                      label: VerticalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        labelResolver: (line) => 'TODAY',
                      ),
                    ),
                  ],
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 7,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            'Day ${value.toInt() + 1}',
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (daysInMonth - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: cumulativeActual,
                    isCurved: true,
                    color: AppColors.neon,
                    barWidth: 4,
                    dotData: FlDotData(
                      show: true,
                      checkToShowDot: (spot, barData) => spot.x == todayIndex,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 6,
                        color: AppColors.neon,
                        strokeWidth: 3,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.neon.withOpacity(0.2),
                          AppColors.neon.withOpacity(0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  if (projectedSpots.isNotEmpty)
                    LineChartBarData(
                      spots: projectedSpots,
                      isCurved: true,
                      color: Colors.grey.withOpacity(0.4),
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      dashArray: [8, 4],
                    ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final isActual = barSpot.barIndex == 0;
                        final label = isActual ? 'Actual' : 'Projected';
                        return LineTooltipItem(
                          '$label\nDay ${barSpot.x.toInt() + 1}: ${barSpot.y.round()} PKR',
                          TextStyle(
                            color: isActual ? AppColors.neon : Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.neon.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: AppColors.neon),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    runningTotal > 0 
                        ? 'Based on your recent habits, you are on track to spend ~${projectedMonthEnd.round()} PKR by the end of this month.'
                        : 'Penny needs a few more transactions to build a reliable spending forecast.',
                    style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
