import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../config/themes/app_colors.dart';
import '../../../domain/entities/insight.dart';
import '../../bloc/insight/insight_bloc.dart';
import '../../bloc/insight/insight_event.dart';
import '../../bloc/insight/insight_state.dart';
import '../../bloc/transaction_state.dart';
import '../../bloc/transaction_bloc.dart';
import 'widgets/insight_card.dart';
import 'widgets/velocity_meter.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  @override
  void initState() {
    super.initState();
    context.read<InsightBloc>().add(GenerateInsightsRequested(month: DateTime.now()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Financial Insights', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, txState) {
          if (txState.isLoading && txState.transactions.isEmpty) {
            return _buildLoadingState(isDark);
          }

          if (txState.transactions.isEmpty) {
             return _buildEmptyTransactionsState(isDark);
          }

          return BlocBuilder<InsightBloc, InsightState>(
            builder: (context, state) {
              if (state is InsightInitial || state is InsightLoading) {
                return _buildLoadingState(isDark);
              }

              if (state is InsightLoaded) {
                final allInsights = state.visibleInsights;
                final velocity = allInsights.where((i) => i.type == InsightType.velocity).firstOrNull;
                
                // Consolidate all non-velocity insights into one list, sorted by priority
                final displayInsights = allInsights
                    .where((i) => i.type != InsightType.velocity)
                    .toList()
                  ..sort((a, b) {
                    if (a.priority == InsightPriority.high && b.priority != InsightPriority.high) return -1;
                    if (a.priority != InsightPriority.high && b.priority == InsightPriority.high) return 1;
                    return b.createdAt.compareTo(a.createdAt);
                  });

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                  children: [
                    // 1. PREMIUM DAILY AI WISDOM (Hero Element)
                    if (state.dailyTip != null || state.isAiLoading) ...[
                      _buildDailyAiWisdom(state.dailyTip, state.isAiLoading, isDark),
                      const SizedBox(height: 24),
                    ],

                    // 2. HEADER WITH PULSE & CLEAR ALL
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSpendingPulse(allInsights, isDark),
                        if (displayInsights.any((i) => i.priority == InsightPriority.high))
                          TextButton(
                            onPressed: () => context.read<InsightBloc>().add(const ClearAllAlertsRequested()),
                            child: const Text('Clear Alerts', style: TextStyle(color: Color(0xFFF04438), fontSize: 12, fontWeight: FontWeight.w800)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 3. AI COACH NOTE (More subtle now)
                    _buildCoachNoteSection(state.aiCoachNote, state.isAiLoading, isDark),
                    const SizedBox(height: 32),

                    // 4. VELOCITY METER
                    if (velocity != null) ...[
                      VelocityMeter(
                        timeRatio: velocity.metadata['time_ratio'] as double? ?? 0.5,
                        spendRatio: velocity.metadata['spend_ratio'] as double? ?? 0.5,
                      ),
                      const SizedBox(height: 32),
                    ],

                    // 5. THE UNIFIED INSIGHT FEED
                    _buildSectionHeader('Smart Analysis Feed', theme),
                    const SizedBox(height: 16),
                    if (displayInsights.isEmpty)
                       _buildEmptyState(isDark)
                    else
                      ...displayInsights.map((insight) => InsightCard(
                        insight: insight,
                        onDismiss: () => context.read<InsightBloc>().add(DismissInsightRequested(insightId: insight.id)),
                        onAction: () => _handleInsightAction(context, insight),
                      )),
                    
                    const SizedBox(height: 40),
                  ],
                );
              }

              if (state is InsightError) {
                 return Center(child: Text(state.message));
              }

              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  Widget _buildSpendingPulse(List<InsightEntity> insights, bool isDark) {
    final hasAnomaly = insights.any((i) => i.priority == InsightPriority.high);
    final pulseColor = hasAnomaly ? const Color(0xFFF04438) : AppColors.neon;
    final statusText = hasAnomaly ? "ACTION REQUIRED" : "SPENDING STABLE";

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PulseIndicator(color: pulseColor),
        const SizedBox(width: 8),
        Text(
          statusText,
          style: TextStyle(
            color: pulseColor,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  void _handleInsightAction(BuildContext context, InsightEntity insight) {
    switch (insight.actionType) {
      case InsightActionType.setBudget:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navigating to Budget settings...'))
        );
        break;
      case InsightActionType.viewHistory:
        Navigator.pop(context); // Go back to Dashboard/Main
        break;
      default:
        break;
    }
  }

  Widget _buildDailyAiWisdom(String? tip, bool isLoading, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.neon.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neon.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome_rounded, color: AppColors.neon, size: 20),
              const SizedBox(width: 8),
              const Text(
                "DAILY FINANCIAL WISDOM",
                style: TextStyle(
                  color: AppColors.neon,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (isLoading && tip == null)
            _buildNoteShimmer(isDark)
          else
            Text(
              "\"${tip ?? "Small savings today lead to big freedom tomorrow. Focus on the habits that build your future."}\"",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                height: 1.5,
                color: isDark ? Colors.white : const Color(0xFF101828),
              ),
            ),
          const SizedBox(height: 12),
          const Text(
            "— Penny AI",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.neon,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoachNoteSection(String? note, bool isLoading, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withOpacity(0.5) : AppColors.neon.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF2E3A47) : AppColors.neon.withOpacity(0.1),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_rounded, color: AppColors.neon, size: 20),
              const SizedBox(width: 8),
              const Text(
                "COACH'S PERSPECTIVE",
                style: TextStyle(
                  color: AppColors.neon,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              if (isLoading)
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.neon)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoading && (note == null || note.isEmpty))
            _buildNoteShimmer(isDark)
          else
            Text(
              note ?? "Tracking your spending helps me find opportunities for you to save more.",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoteShimmer(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.white10 : Colors.black12,
      highlightColor: isDark ? Colors.white24 : Colors.black26,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 14, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 8),
          Container(height: 14, width: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Text(
      title.toUpperCase(),
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildEmptyTransactionsState(bool isDark) {
     return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.query_stats_rounded, size: 64, color: isDark ? Colors.white24 : Colors.black26),
            const SizedBox(height: 24),
            const Text(
              'No trends to analyze yet!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add some expenses manually or scan receipts\nand Penny will start building your profile.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
     return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'All Clear!',
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
            ),
            const Text(
              'No new analysis items at the moment.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
     return const Center(child: CircularProgressIndicator(color: AppColors.neon));
  }
}

class _PulseIndicator extends StatefulWidget {
  final Color color;
  const _PulseIndicator({required this.color});

  @override
  State<_PulseIndicator> createState() => _PulseIndicatorState();
}

class _PulseIndicatorState extends State<_PulseIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.5 * (1 - _controller.value)),
                blurRadius: 10 * _controller.value,
                spreadRadius: 4 * _controller.value,
              ),
            ],
          ),
        );
      },
    );
  }
}
