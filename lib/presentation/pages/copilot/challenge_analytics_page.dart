import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../config/themes/app_colors.dart';
import '../../bloc/copilot/copilot_bloc.dart';
import '../../bloc/copilot/copilot_state.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../../domain/entities/penny_challenge.dart';
import 'onyx_insights_page.dart';

class ChallengeAnalyticsPage extends StatelessWidget {
  const ChallengeAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Challenge Hub', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final user = authState.user;
          final onyxPoints = user.onyxPoints;

          return BlocBuilder<CopilotBloc, CopilotState>(
            builder: (context, state) {
              if (state is! CopilotLoaded) {
                return const Center(child: CircularProgressIndicator(color: AppColors.neon));
              }

              final challenges = state.challenges;
              final completed = challenges.where((c) => c.isCompleted).toList();
              final successRate = challenges.isEmpty ? 0 : (completed.length / challenges.length * 100).round();

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // 0. ONYX VAULT
                  _buildOnyxVault(context, onyxPoints, isDark),
                  const SizedBox(height: 32),

                  // 1. SUMMARY STATS
                  const Text(
                    'PERFORMANCE',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _statCard(context, 'Total', challenges.length.toString(), Icons.emoji_events_rounded, isDark),
                      const SizedBox(width: 12),
                      _statCard(context, 'Completed', completed.length.toString(), Icons.check_circle_rounded, isDark, color: AppColors.neon),
                      const SizedBox(width: 12),
                      _statCard(context, 'Success', '$successRate%', Icons.auto_graph_rounded, isDark, color: const Color(0xFFFDB022)),
                    ],
                  ),
                  const SizedBox(height: 32),



              // 2. ANALYTICS CHART
              const Text(
                'COMPLETION TREND',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2),
              ),
              const SizedBox(height: 16),
              _buildBarChart(challenges, isDark),
              const SizedBox(height: 40),

              // 3. HISTORY LIST
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'HISTORY',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2),
                  ),
                  Text(
                    '${challenges.length} Items',
                    style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (challenges.isEmpty)
                _buildEmptyState(isDark)
              else
                ...challenges.map((c) => _buildChallengeItem(c, isDark)),
              ],
            );
          },
        );
      },
    ),
  );
}



  Widget _buildOnyxVault(BuildContext context, int points, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const OnyxInsightsPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark 
              ? [const Color(0xFF1C252E), Colors.black]
              : [const Color(0xFF0B1220), const Color(0xFF1C252E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00FF88).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00FF88).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.dark_mode_rounded, color: Color(0xFF00FF88), size: 18),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'ONYX VAULT',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  points.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'ONYX',
                  style: TextStyle(
                    color: const Color(0xFF00FF88),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (points % 500) / 500,
                backgroundColor: Colors.white10,
                color: const Color(0xFF00FF88),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${500 - (points % 500)} more to Level Up',
                  style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'GOLD TIER',
                  style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(BuildContext context, String label, String value, IconData icon, bool isDark, {Color? color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color ?? Colors.grey),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(List<PennyChallenge> challenges, bool isDark) {
    // Group challenges by month for the last 4 months
    final now = DateTime.now();
    final Map<int, List<PennyChallenge>> monthlyData = {};

    for (int i = 0; i < 4; i++) {
      final month = (now.month - i - 1 + 12) % 12 + 1;
      monthlyData[month] = challenges.where((c) => c.weekStart.month == month).toList();
    }

    final monthsList = monthlyData.keys.toList().reversed.toList();

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(10, 24, 24, 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 5, // Static max for now or calculate dynamic
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toInt()} Completed',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final month = monthsList[value.toInt()];
                  final label = DateFormat('MMM').format(DateTime(2024, month));
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: monthsList.asMap().entries.map((entry) {
            final idx = entry.key;
            final month = entry.value;
            final total = monthlyData[month]?.length ?? 0;
            final completed = monthlyData[month]?.where((c) => c.isCompleted).length ?? 0;

            return BarChartGroupData(
              x: idx,
              barRods: [
                BarChartRodData(
                  toY: total.toDouble(),
                  color: isDark ? Colors.grey.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                  width: 14,
                  borderRadius: BorderRadius.circular(4),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 5,
                    color: Colors.transparent,
                  ),
                ),
                BarChartRodData(
                  toY: completed.toDouble(),
                  color: AppColors.neon,
                  width: 14,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildChallengeItem(PennyChallenge challenge, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (challenge.isCompleted ? AppColors.neon : Colors.grey).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              challenge.isCompleted ? Icons.check_rounded : Icons.pending_actions_rounded,
              color: challenge.isCompleted ? AppColors.neon : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMMM dd, yyyy').format(challenge.weekStart),
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          if (challenge.isCompleted)
            const Text(
              'DONE',
              style: TextStyle(color: AppColors.neon, fontWeight: FontWeight.w900, fontSize: 10),
            )
          else if (challenge.isAccepted)
            const Text(
              'ACTIVE',
              style: TextStyle(color: Color(0xFFFDB022), fontWeight: FontWeight.w900, fontSize: 10),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(Icons.history_rounded, size: 40, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('No challenges yet.', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

