import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../config/themes/app_colors.dart';
import '../../../core/utils/dashboard_aggregations.dart';
import '../../bloc/transaction_bloc.dart';
import '../../bloc/transaction_state.dart';
import '../../bloc/category/category_bloc.dart';
import '../../bloc/category/category_state.dart';
import '../../bloc/vault/vault_bloc.dart';
import '../../bloc/vault/vault_state.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/transaction.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../../core/utils/currency_helper.dart';

class BalancePage extends StatefulWidget {
  const BalancePage({super.key});

  @override
  State<BalancePage> createState() => _BalancePageState();
}

class _BalancePageState extends State<BalancePage> {
  bool _isMonthly = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, txState) {
            return BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, catState) {
                return BlocBuilder<VaultBloc, VaultState>(
                  builder: (context, vaultState) {
                    final allTxs = txState.transactions;
                    final filteredTxs = _isMonthly 
                        ? allTxs.where((t) => t.dateTime.month == now.month && t.dateTime.year == now.year).toList()
                        : allTxs;

                    final userCurrency = context.select((AuthBloc bloc) => bloc.state.user.currency ?? 'PKR');
                    final symbol = CurrencyHelper.getSymbol(userCurrency);

                    double totalIncome = 0;
                    double totalExpense = 0;
                    for (final tx in filteredTxs) {
                      if (tx.isIncome) totalIncome += tx.amount;
                      else totalExpense += tx.amount;
                    }

                    final balance = totalIncome - totalExpense;
                    
                    // Safe to Spend Logic
                    final lockedInVaults = vaultState.totalSavedInVaults;
                    final safeToSpend = balance - lockedInVaults;

                    final savingsRate = getSavingsRate(income: totalIncome, expense: totalExpense);
                    final topCategories = getTopSpendingCategories(transactions: filteredTxs);
                    final dailyFlow = getDailyNetCashFlow(transactions: allTxs, days: 7);

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                      children: [
                        // Header
                        _buildHeader(context, isDark, theme),
                        const SizedBox(height: 24),

                        // Balance Card (Overhauled for Vaults)
                        _buildBalanceCard(isDark, balance, lockedInVaults, safeToSpend, symbol),
                        const SizedBox(height: 24),

                        // Quick Stats
                        _buildQuickStats(totalIncome, totalExpense, symbol),
                        const SizedBox(height: 32),

                        // Cash Flow Chart
                        _buildSectionHeader('Weekly Cash Flow', theme),
                        const SizedBox(height: 16),
                        _buildCashFlowChart(dailyFlow, isDark),
                        const SizedBox(height: 32),

                        // Top Spending
                        _buildSectionHeader('Top Spending Categories', theme),
                        const SizedBox(height: 16),
                        if (topCategories.isEmpty)
                          _buildEmptyState('No spending recorded', Icons.shopping_bag_outlined, theme, isDark)
                        else 
                          _buildTopSpendingList(topCategories, catState, isDark, symbol),
                        
                        const SizedBox(height: 32),

                        // Savings Rate & Highlights
                        _buildSectionHeader('Financial Health', theme),
                        const SizedBox(height: 16),
                        _buildHighlights(savingsRate, filteredTxs, isDark, symbol),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, ThemeData theme) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : const Color(0xFF101828),
            size: 20,
          ),
        ),
        const Spacer(),
        Text(
          'Financial Overview',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        _ToggleSwitch(
          value: _isMonthly,
          onChanged: (val) => setState(() => _isMonthly = val),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(bool isDark, double balance, double locked, double safe, String symbol) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
            ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
            : [const Color(0xFF101828), const Color(0xFF1D2939)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: Stack(
          children: [
            // Decorative background circles
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neon.withOpacity(0.05),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.neon.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.neon.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.shield_rounded, color: AppColors.neon, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              'SAFE TO SPEND',
                              style: TextStyle(
                                color: AppColors.neon,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'AVAILABLE',
                        style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  FittedBox(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          symbol,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatWithCommas(safe.round()),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 56,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Financial Split Row
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('TOTAL BALANCE', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                              const SizedBox(height: 6),
                              Text('$symbol ${_formatWithCommas(balance.round())}', style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 30, color: Colors.white.withOpacity(0.1)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('LOCKED FUNDS', style: TextStyle(color: Colors.orangeAccent.withOpacity(0.6), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Icon(Icons.lock_rounded, size: 14, color: Colors.orangeAccent),
                                  const SizedBox(width: 4),
                                  Text('$symbol ${_formatWithCommas(locked.round())}', style: const TextStyle(color: Colors.orangeAccent, fontSize: 17, fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
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


  Widget _buildQuickStats(double income, double expense, String symbol) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'INCOME',
            amount: income,
            symbol: symbol,
            icon: Icons.south_west_rounded,
            color: AppColors.neon,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: 'EXPENSE',
            amount: expense,
            symbol: symbol,
            icon: Icons.north_east_rounded,
            color: Colors.redAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildCashFlowChart(Map<DateTime, double> dailyFlow, bool isDark) {
    final sortedDates = dailyFlow.keys.toList()..sort();
    final barGroups = sortedDates.asMap().entries.map((entry) {
      final index = entry.key;
      final date = entry.value;
      final amount = dailyFlow[date] ?? 0;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: amount,
            color: amount >= 0 ? AppColors.neon : Colors.redAccent,
            width: 12,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: amount.abs() * 1.2,
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
            ),
          ),
        ],
      );
    }).toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131A21) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF1E272E) : const Color(0xFFF1F5F9),
        ),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: barGroups.isEmpty ? 100 : barGroups.map((g) => g.barRods[0].toY).reduce((a, b) => a > b ? a : b).abs() * 1.3,
          minY: barGroups.isEmpty ? -100 : barGroups.map((g) => g.barRods[0].toY).reduce((a, b) => a < b ? a : b).abs() * -1.3,
          barGroups: barGroups,
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= sortedDates.length) return const SizedBox();
                  final date = sortedDates[value.toInt()];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('E').format(date)[0],
                      style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopSpendingList(Map<String, double> topCategories, CategoryState catState, bool isDark, String symbol) {
    return Column(
      children: topCategories.entries.map((entry) {
        final CategoryEntity? cat = catState.categories.where((c) => c.name == entry.key).firstOrNull;
        final color = cat != null 
            ? Color(int.parse(cat.colorHex.replaceFirst('0x', ''), radix: 16))
            : Colors.grey;
        final iconCode = cat != null 
            ? int.parse(cat.iconCodePoint.replaceFirst('0x', ''), radix: 16)
            : 0xe586;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131A21) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF1E272E) : const Color(0xFFF1F5F9),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(IconData(iconCode, fontFamily: 'MaterialIcons'), color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  entry.key,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '$symbol ${_formatWithCommas(entry.value.round())}',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHighlights(double savingsRate, List<TransactionEntity> txs, bool isDark, String symbol) {
    final expenses = txs.where((t) => !t.isIncome).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final largestExpense = expenses.isNotEmpty ? expenses.first : null;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _HighlightCard(
            title: 'Savings Rate',
            value: '${savingsRate.toStringAsFixed(1)}%',
            subtitle: savingsRate > 20 ? 'Great progress!' : 'Keep saving!',
            icon: Icons.savings_rounded,
            color: AppColors.neon,
            isDark: isDark,
          ),
          const SizedBox(width: 12),
          _HighlightCard(
            title: 'Largest Expense',
            value: largestExpense != null ? '$symbol ${_formatWithCommas(largestExpense.amount.round())}' : '-',
            subtitle: largestExpense?.category ?? 'No data',
            icon: Icons.trending_down_rounded,
            color: Colors.orangeAccent,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String msg, IconData icon, ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        children: [
          Icon(icon, size: 48, color: theme.dividerColor),
          const SizedBox(height: 12),
          Text(
            msg,
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatWithCommas(int n) {
    String s = n.toString();
    if (s.length <= 3) return s;
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (s.length - i) % 3 == 0) buffer.write(',');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final double amount;
  final String symbol;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.amount,
    required this.symbol,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131A21) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF1E272E) : const Color(0xFFF1F5F9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              '$symbol ${NumberFormat('#,###').format(amount.round())}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _HighlightCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131A21) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF1E272E) : const Color(0xFFF1F5F9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10, 
              fontWeight: FontWeight.w600, 
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Container(
        width: 100,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: value ? 50 : 2,
              top: 2,
              bottom: 2,
              child: Container(
                width: 48,
                decoration: BoxDecoration(
                  color: AppColors.neon,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      'All',
                      style: TextStyle(
                        color: !value ? Colors.white : Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Month',
                      style: TextStyle(
                        color: value ? Colors.white : Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
