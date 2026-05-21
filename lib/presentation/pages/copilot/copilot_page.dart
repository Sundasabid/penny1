import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/themes/app_colors.dart';
import '../../bloc/copilot/copilot_bloc.dart';
import '../../bloc/copilot/copilot_event.dart';
import '../../bloc/copilot/copilot_state.dart';
import 'widgets/health_score_ring.dart';
import 'widgets/challenge_card.dart';
import 'widgets/purchase_planner_card.dart';
import 'widgets/add_purchase_sheet.dart';
import 'widgets/subscription_card.dart';
import 'widgets/forecast_chart.dart';

class CopilotPage extends StatefulWidget {
  const CopilotPage({super.key});

  @override
  State<CopilotPage> createState() => _CopilotPageState();
}

class _CopilotPageState extends State<CopilotPage> {
  @override
  void initState() {
    super.initState();
    context.read<CopilotBloc>().add(const LoadCopilotRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocBuilder<CopilotBloc, CopilotState>(
          builder: (context, state) {
            if (state is CopilotInitial || state is CopilotLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.neon));
            }

            if (state is CopilotLoaded) {
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                children: [
                  // HEADER
                  Row(
                    children: [
                      const Icon(Icons.rocket_launch_rounded, color: AppColors.neon, size: 28),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Co-Pilot',
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                          ),
                          Text(
                            'Your AI financial advisor',
                            style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // 1. HEALTH SCORE
                  HealthScoreRing(score: state.healthScore),
                  const SizedBox(height: 28),

                  // 2. WEEKLY CHALLENGE
                  _sectionHeader('WEEKLY CHALLENGE', Icons.emoji_events_rounded),
                  const SizedBox(height: 12),
                  ChallengeCard(
                    challenge: state.activeChallenge,
                    isLoading: state.isChallengeLoading,
                    onAccept: () => context.read<CopilotBloc>().add(const AcceptChallenge()),
                    onComplete: () => context.read<CopilotBloc>().add(const CompleteChallenge()),
                    onGenerate: () => context.read<CopilotBloc>().add(const GenerateNewChallenge()),
                  ),
                  const SizedBox(height: 28),

                  // 3. PURCHASE PLANNER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionHeader('PURCHASE PLANNER', Icons.shopping_bag_rounded),
                      GestureDetector(
                        onTap: () => _showAddPurchaseSheet(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.neon,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text('Plan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (state.purchases.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.lightbulb_outline_rounded, color: AppColors.neon.withOpacity(0.4), size: 40),
                          const SizedBox(height: 14),
                          const Text(
                            'Planning a big purchase?',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Tap "+ Plan" and Penny will tell you\nexactly how to afford it.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  else
                    ...state.purchases.map((p) => PurchasePlannerCard(
                      purchase: p,
                      onRemove: () => context.read<CopilotBloc>().add(RemovePlannedPurchase(purchaseId: p.id)),
                    )),
                  const SizedBox(height: 28),

                  // 4. SPENDING FORECAST
                  _sectionHeader('SPENDING FORECAST', Icons.show_chart_rounded),
                  const SizedBox(height: 12),
                  ForecastChart(
                    actualDailySpend: state.actualDailySpend,
                    projectedMonthEnd: state.projectedMonthEnd,
                  ),
                  const SizedBox(height: 28),

                  // 5. SUBSCRIPTIONS
                  _sectionHeader('DETECTED SUBSCRIPTIONS', Icons.autorenew_rounded),
                  const SizedBox(height: 12),
                  SubscriptionCard(
                    subscriptions: state.subscriptions,
                    totalFixedCosts: state.totalFixedCosts,
                  ),
                  const SizedBox(height: 40),
                ],
              );
            }

            if (state is CopilotError) {
              return Center(child: Text(state.message));
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 16),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  void _showAddPurchaseSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddPurchaseSheet(
        onAdd: (name, amount, date) {
          context.read<CopilotBloc>().add(AddPlannedPurchase(
            name: name,
            amount: amount,
            targetDate: date,
          ));
        },
      ),
    );
  }
}
