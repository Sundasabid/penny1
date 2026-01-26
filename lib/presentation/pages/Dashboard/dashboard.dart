import 'package:flutter/material.dart';

import '../../../core/utils/dashboard_aggregations.dart';
import '../../../core/widgets/cards/total_spend_card.dart';
import '../../../core/widgets/charts/spending_heatmap.dart';
import '../../../domain/entities/transaction.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  // TEMP: still mock until you connect repository/bloc into dashboard
  // (This does NOT affect heatmap correctness: heatmap is computed from tx list)
  List<TransactionEntity> _mockTransactions() {
    final now = DateTime.now();
    DateTime d(int day, {int monthOffset = 0, int h = 12, int m = 0}) =>
        DateTime(now.year, now.month + monthOffset, day, h, m);

    return [
      TransactionEntity.manualExpense(
        id: 't1',
        merchant: 'Imtiaz',
        category: 'Grocery',
        amount: 1850,
        dateTime: d(1),
        paymentMethod: 'Card',
      ),
      TransactionEntity.receiptExpense(
        id: 't2',
        merchant: 'McDonald\'s',
        category: 'Dining',
        amount: 1240,
        dateTime: d(2, h: 20),
        paymentMethod: 'Cash',
        receiptId: 'r1',
      ),
      TransactionEntity.manualExpense(
        id: 't3',
        merchant: 'Careem',
        category: 'Transport',
        amount: 760,
        dateTime: d(2, h: 9),
        paymentMethod: 'Wallet',
      ),
      TransactionEntity.receiptExpense(
        id: 't4',
        merchant: 'PSO',
        category: 'Fuel',
        amount: 5200,
        dateTime: d(4, h: 18),
        paymentMethod: 'Card',
        receiptId: 'r2',
      ),
      TransactionEntity.manualIncome(
        id: 't5',
        merchant: 'Salary',
        category: 'Income',
        amount: 150000,
        dateTime: d(3, h: 10),
        paymentMethod: 'Bank',
      ),

      // last month for % comparison
      TransactionEntity.manualExpense(
        id: 't6',
        merchant: 'KFC',
        category: 'Dining',
        amount: 2100,
        dateTime: d(6, monthOffset: -1, h: 21),
        paymentMethod: 'Cash',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final tx = _mockTransactions();

    final totalSpend = monthTotalSpend(month: now, transactions: tx);
    final pct = percentChangeMonthToMonthSpend(currentMonth: now, transactions: tx);
    final daily = dailySpendForMonth(month: now, transactions: tx);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (simplified to avoid overlap distortion)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assalam-o-Alaikum',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF98A2B3),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Fatima',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF101828),
                      ),
                    ),
                  ],
                ),
              ),
              _CircleIconButton(
                icon: Icons.notifications_none_outlined,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications (TODO)')),
                  );
                },
              ),
              const SizedBox(width: 10),
              _CircleIconButton(
                icon: Icons.tune_outlined,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Filters (TODO)')),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 22),

          TotalSpendCard(
            totalPkr: totalSpend.round(),
            percentVsLastMonth: pct,
          ),

          const SizedBox(height: 26),

          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _QuickAction(icon: Icons.history, label: 'History'),
              _QuickAction(icon: Icons.pie_chart_outline, label: 'Budget'),
              _QuickAction(icon: Icons.bolt, label: 'Insights'),
              _QuickAction(icon: Icons.credit_card, label: 'Subs'),
            ],
          ),

          const SizedBox(height: 22),

          SpendingHeatmap(
            month: now,
            title: 'Spending Intensity',
            dailySpend: daily,
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: Color(0xFFE7F6EE),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF101828)),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 74,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFE7F6EE),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, size: 28, color: const Color(0xFF18B27A)),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF98A2B3),
            ),
          ),
        ],
      ),
    );
  }
}
