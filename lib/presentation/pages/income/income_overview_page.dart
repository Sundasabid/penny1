import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../config/themes/app_colors.dart';
import '../../../core/utils/dashboard_aggregations.dart';
import '../../bloc/transaction_bloc.dart';
import '../../bloc/transaction_state.dart';
import '../../../core/widgets/transaction_item.dart';
import 'add_income_page.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../../core/utils/currency_helper.dart';

class IncomeOverviewPage extends StatefulWidget {
  const IncomeOverviewPage({super.key});

  @override
  State<IncomeOverviewPage> createState() => _IncomeOverviewPageState();
}

class _IncomeOverviewPageState extends State<IncomeOverviewPage> {
  bool _isAllTime = false;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final userCurrency = context.select((AuthBloc bloc) => bloc.state.user.currency ?? 'PKR');
    final symbol = CurrencyHelper.getSymbol(userCurrency);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, state) {
            final tx = state.transactions;
            final incomeList = tx.where((t) => t.isIncome).toList();
            incomeList.sort((a, b) => b.dateTime.compareTo(a.dateTime));

            double totalIncome = 0;
            double pct = 0;

            if (_isAllTime) {
              totalIncome = allTimeTotalIncome(transactions: tx);
              pct = 0;
            } else {
              totalIncome = monthTotalIncome(month: _selectedMonth, transactions: tx);
              pct = percentChangeMonthToMonthIncome(currentMonth: _selectedMonth, transactions: tx);
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              children: [
                Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: isDark ? Colors.white : const Color(0xFF101828),
                          size: 22,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Income Overview',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 44),
                  ],
                ),
                const SizedBox(height: 24),

                // Total Income Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2E7D32), // Deep Green
                        Color(0xFF4CAF50), // Green
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4CAF50).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TOTAL INCOME',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              if (!_isAllTime)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        InkWell(
                                          onTap: _previousMonth,
                                          child: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 16),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 6),
                                          child: Text(
                                            DateFormat('MMM yyyy').format(_selectedMonth).toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: _nextMonth,
                                          child: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isAllTime = !_isAllTime;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(_isAllTime ? 0.3 : 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                                  ),
                                  child: Text(
                                    _isAllTime ? 'ALL TIME' : 'MONTHLY',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (!_isAllTime && pct != 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        pct >= 0 ? Icons.trending_up : Icons.trending_down,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${pct.abs().toStringAsFixed(1)}%',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            symbol,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatWithCommas(totalIncome.round()),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Income History',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AddIncomePage()),
                        );
                      },
                      child: const Text('Add New'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (incomeList.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(Icons.account_balance_wallet_outlined, size: 64, color: theme.dividerColor),
                          const SizedBox(height: 16),
                          Text(
                            'No income recorded yet.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? AppColors.textOnDarkMuted : AppColors.textOnLightMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...incomeList.map((tx) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TransactionItem(tx: tx),
                      )),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddIncomePage()),
          );
        },
        backgroundColor: AppColors.neon,
         foregroundColor: Colors.white,
        label: const Text('Add Income', style: TextStyle(fontWeight: FontWeight.w900)),
        icon: const Icon(Icons.add_rounded),
      ),
    );
  }

  String _formatWithCommas(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
        final idxFromEnd = s.length - i;
        buf.write(s[i]);
        if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write(',');
    }
    return buf.toString();
  }
}
