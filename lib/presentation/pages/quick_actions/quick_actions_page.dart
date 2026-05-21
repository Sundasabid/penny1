import 'package:flutter/material.dart';
import '../budget/budget_planner_page.dart';
import '../transaction_history_page.dart';
import '../chat/chat_page.dart';
import '../income/income_overview_page.dart';
import '../balance/balance_page.dart';
import '../debt/debt_overview_page.dart';
import '../subscriptions/subscription_radar_page.dart';
import '../vault/vaults_overview_page.dart';


class QuickActionsPage extends StatelessWidget {
  const QuickActionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> actions = [
      {
        'icon': Icons.payments_rounded,
        'label': 'Income',
        'color': Colors.greenAccent,
        'desc': 'Track earnings',
        'page': const IncomeOverviewPage(),
      },
      {
        'icon': Icons.account_balance_wallet_rounded,
        'label': 'Balance',
        'color': Colors.tealAccent,
        'desc': 'Current wealth',
        'page': const BalancePage(),
      },
      {
        'icon': Icons.history_rounded,
        'label': 'History',
        'color': Colors.blueAccent,
        'desc': 'View past logs',
        'page': const TransactionHistoryPage(),
      },
      {
        'icon': Icons.pie_chart_rounded,
        'label': 'Budget',
        'color': Colors.orangeAccent,
        'desc': 'Plan spending',
        'page': const BudgetPlannerPage(),
      },
      {
        'icon': Icons.auto_awesome_rounded,
        'label': 'Penny AI',
        'color': Colors.purpleAccent,
        'desc': 'AI Coach',
        'page': const ChatPage(),
      },
      {
        'icon': Icons.people_alt_rounded,
        'label': 'Debts',
        'color': const Color(0xFF00FF88),
        'desc': 'Lend & Borrow',
        'page': const DebtOverviewPage(),
      },
      {
        'icon': Icons.radar_rounded,
        'label': 'Radar',
        'color': const Color(0xFFFF9800),
        'desc': 'Upcoming Bills',
        'page': const SubscriptionRadarPage(),
      },
      {
        'icon': Icons.shield_rounded,
        'label': 'Vault',
        'color': Colors.orangeAccent,
        'desc': 'Secure goals',
        'page': const VaultsOverviewPage(),
      },

    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text("ALL TOOLS",
            style: TextStyle(
                letterSpacing: 4,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black87)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Financial Suite",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.3),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: actions.length,
                itemBuilder: (context, index) {
                  final action = actions[index];
                  return _GridActionCard(
                    icon: action['icon'],
                    label: action['label'],
                    color: action['color'],
                    desc: action['desc'],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => action['page']),
                    ),
                    isDark: isDark,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const _GridActionCard({
    required this.icon,
    required this.label,
    required this.desc,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.04),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: color.withOpacity(0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.03),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          children: [
            // GLOW EFFECT (Subtle)
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.05),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: color.withOpacity(0.2)),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const Spacer(),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
