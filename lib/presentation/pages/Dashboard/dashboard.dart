import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/themes/app_colors.dart';
import '../../../core/widgets/cards/total_spend_card.dart';
import '../../../core/widgets/charts/spending_heatmap.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/transaction_bloc.dart';
import '../../bloc/transaction_state.dart';
import '../budget/budget_planner_page.dart';
import '../transaction_history_page.dart';
import '../chat/chat_page.dart';
import '../income/income_overview_page.dart';
import '../balance/balance_page.dart';
import '../insights/insights_page.dart';
import '../../bloc/insight/insight_bloc.dart';
import '../../bloc/insight/insight_state.dart';
import '../../../domain/entities/insight.dart';
import '../copilot/onyx_insights_page.dart';
import '../../../core/utils/currency_helper.dart';
import '../quick_actions/quick_actions_page.dart';
import '../vault/vaults_overview_page.dart';
import '../../bloc/vault/vault_bloc.dart';
import '../../bloc/vault/vault_state.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        final tx = state.transactions;

        final user = context.select((AuthBloc bloc) => bloc.state.user);
        final displayName = user.displayName?.isNotEmpty == true
            ? user.displayName!
            : 'User';

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final theme = Theme.of(context);

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // PREMIUM AVATAR WITH STATUS RING
                      Container(
                        width: 62,
                        height: 62,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.neon.withOpacity(isDark ? 0.3 : 0.15),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neon.withOpacity(isDark ? 0.1 : 0.05),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? AppColors.darkSurface2 : Colors.white,
                            border: Border.all(
                              color: AppColors.neon.withOpacity(0.05),
                            ),
                            boxShadow: isDark ? null : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: AppColors.neon,
                            size: 34,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // GREETING & NAME
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Text(
                                  'Assalam-o-Alaikum',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.4),
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                // STATUS PILLS GROUP
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // ONYX JEWEL PILL (RESPONSIVE)
                                    TweenAnimationBuilder<double>(
                                      duration: const Duration(milliseconds: 200),
                                      tween: Tween(begin: 1.0, end: 1.0),
                                      builder: (context, scale, child) => Transform.scale(
                                        scale: scale,
                                        child: child,
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(builder: (_) => const OnyxInsightsPage()),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: isDark 
                                                ? [const Color(0xFF0F172A), const Color(0xFF1E293B).withOpacity(0.9)]
                                                : [Colors.white, Colors.blueGrey[50]!],
                                            ),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: const Color(0xFF00FF88).withOpacity(isDark ? 0.4 : 0.2), 
                                              width: 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF00FF88).withOpacity(isDark ? 0.1 : 0.05),
                                                blurRadius: 15,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.diamond_rounded,
                                                color: Color(0xFF00FF88),
                                                size: 14,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                '${user.onyxPoints}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w900,
                                                  color: isDark ? Colors.white : Colors.blueGrey[900],
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // VAULTS ENTRANCE PILL
                                    BlocBuilder<VaultBloc, VaultState>(
                                      builder: (context, vaultState) {
                                        final count = vaultState.vaults.length;
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(builder: (_) => const VaultsOverviewPage()),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Colors.orangeAccent.withOpacity(isDark ? 0.4 : 0.2), 
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.shield_rounded,
                                                  color: Colors.orangeAccent,
                                                  size: 14,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  count > 0 ? '$count Vaults' : 'Vault',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w900,
                                                    color: isDark ? Colors.white : Colors.blueGrey[900],
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              displayName,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // RESPONSIVE ALERT BUTTON
                      BlocBuilder<InsightBloc, InsightState>(
                        builder: (context, insightState) {
                          bool hasAlerts = false;
                          if (insightState is InsightLoaded) {
                            hasAlerts = insightState.visibleInsights.any((i) => i.priority == InsightPriority.high);
                          }

                          return TweenAnimationBuilder<double>(
                            duration: const Duration(seconds: 2),
                            tween: Tween(begin: 0.0, end: hasAlerts ? 1.0 : 0.0),
                            curve: Curves.easeInOutSine,
                            builder: (context, value, child) {
                              return Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1C252E) : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: hasAlerts 
                                      ? const Color(0xFFF04438).withOpacity(0.3 + (0.4 * value))
                                      : (isDark ? const Color(0xFF2E3A47) : const Color(0xFFE2E8F0)),
                                    width: hasAlerts ? 2 : 1,
                                  ),
                                  boxShadow: [
                                    if (hasAlerts)
                                      BoxShadow(
                                        color: const Color(0xFFF04438).withOpacity(0.2 * value),
                                        blurRadius: 10 * value,
                                        spreadRadius: 2 * value,
                                      ),
                                    if (!isDark)
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                  ],
                                ),
                                child: child,
                              );
                            },
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Center(
                                  child: IconButton(
                                    icon: Icon(
                                      hasAlerts ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
                                      color: hasAlerts 
                                        ? const Color(0xFFF04438)
                                        : (isDark ? Colors.white : const Color(0xFF0B1220)),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (_) => const InsightsPage()),
                                      );
                                    },
                                  ),
                                ),
                                if (hasAlerts)
                                  Positioned(
                                    right: 12,
                                    top: 12,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF04438),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isDark ? const Color(0xFF1C252E) : Colors.white, 
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),




                  const SizedBox(height: 28),

                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 40 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: TotalSpendCard(
                      transactions: tx,
                      symbol: CurrencyHelper.getSymbol(user.currency),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? const Color(0xFFF1F5F9)
                              : const Color(0xFF101828),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 18),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _QuickAction(
                          icon: Icons.payments_rounded,
                          label: 'Income',
                          color: Colors.green,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const IncomeOverviewPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        _QuickAction(
                          icon: Icons.account_balance_wallet_rounded,
                          label: 'Balance',
                          color: Colors.teal,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const BalancePage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        _QuickAction(
                          icon: Icons.history_rounded,
                          label: 'History',
                          color: Colors.blue,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const TransactionHistoryPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        _QuickAction(
                          icon: Icons.pie_chart_rounded,
                          label: 'Budget',
                          color: Colors.orange,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const BudgetPlannerPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        _QuickAction(
                          icon: Icons.grid_view_rounded,
                          label: 'See All',


                          color: const Color(0xFF00FF88),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const QuickActionsPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  SpendingHeatmap(
                    transactions: tx,
                    title: 'Spending Intensity',
                  ),
                ],
              ),
            ),

            // 🤖 PREMIUM CHAT BUTTON
            Positioned(
              right: 18,
              bottom: 110, // Above bottom nav
              child: _CatchyChatButton(
                onTap: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const ChatPage()));
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _QuickAction extends StatefulWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  State<_QuickAction> createState() => _QuickActionState();
}

class _QuickActionState extends State<_QuickAction> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isTapped = true),
      onTapUp: (_) => setState(() => _isTapped = false),
      onTapCancel: () => setState(() => _isTapped = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isTapped ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: SizedBox(
          width: 76,
          child: Column(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF131A21) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF1E272E)
                        : const Color(0xFFE2E8F0),
                    width: isDark ? 1 : 1.5,
                  ),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                  ],
                  gradient: isDark
                      ? null
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.white, const Color(0xFFF8FAFC)],
                        ),
                ),
                child: Center(
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(isDark ? 0.1 : 0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      widget.icon,
                      size: 24,
                      color: isDark
                          ? widget.color.withOpacity(0.9)
                          : widget.color.withOpacity(0.85),
                    ),
                  ),
                ),

              ),
              const SizedBox(height: 12),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textOnDarkMuted
                      : AppColors.textOnLightMuted,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CatchyChatButton extends StatefulWidget {
  final VoidCallback onTap;
  const _CatchyChatButton({required this.onTap});

  @override
  State<_CatchyChatButton> createState() => _CatchyChatButtonState();
}

class _CatchyChatButtonState extends State<_CatchyChatButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.neon,
                  AppColors.neon.withOpacity(0.8),
                  const Color(0xFF00D2FF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.5 + (_controller.value * 0.2), 1.0],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neon.withOpacity(0.4),
                  blurRadius: 15 + (_controller.value * 10),
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  "Penny AI",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
