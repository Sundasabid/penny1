import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/debt/debt_bloc.dart';
import '../../bloc/debt/debt_event.dart';
import '../../bloc/debt/debt_state.dart';
import '../../../domain/entities/debt.dart';
import '../../../core/utils/communication_helper.dart';
import 'add_debt_page.dart';

class DebtOverviewPage extends StatelessWidget {
  const DebtOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: context.read<DebtBloc>()..add(LoadDebtsRequested()),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          title: Text("DEBTS & LENDING",
              style: TextStyle(
                  letterSpacing: 2, 
                  fontWeight: FontWeight.w900, 
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87)),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white70 : Colors.black54),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<DebtBloc, DebtState>(
          builder: (context, state) {
            final lended = state.debts.where((d) => d.type == DebtType.lended && !d.isSettled).toList();
            final borrowed = state.debts.where((d) => d.type == DebtType.borrowed && !d.isSettled).toList();

            final totalLended = lended.fold(0.0, (sum, item) => sum + item.amount);
            final totalBorrowed = borrowed.fold(0.0, (sum, item) => sum + item.amount);

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        _buildSummaryCard("LENDED", totalLended, const Color(0xFF00FF88), isDark),
                        const SizedBox(width: 12),
                        _buildSummaryCard("BORROWED", totalBorrowed, Colors.orangeAccent, isDark),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("ACTIVE DEBTS",
                            style: TextStyle(
                                color: (isDark ? Colors.white : Colors.black).withOpacity(0.38), 
                                fontSize: 12, 
                                letterSpacing: 2, 
                                fontWeight: FontWeight.bold)),
                        Text("${lended.length + borrowed.length} Items",
                            style: TextStyle(color: (isDark ? Colors.white : Colors.black).withOpacity(0.24), fontSize: 10)),
                      ],
                    ),
                  ),
                ),
                if (state.debts.isEmpty)
                  _buildEmptyState(isDark)
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final debt = state.debts[index];
                        if (debt.isSettled) return const SizedBox.shrink();
                        return _buildDebtItem(context, debt, isDark);
                      },
                      childCount: state.debts.length,
                    ),
                  ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddDebtPage()),
          ),
          backgroundColor: const Color(0xFF00FF88),
          foregroundColor: Colors.black,
          icon: const Icon(Icons.add, fontWeight: FontWeight.w900),
          label: const Text("ADD ENTRY", style: TextStyle(fontWeight: FontWeight.w900)),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String label, double amount, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: color.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
            const SizedBox(height: 8),
            Text(
              NumberFormat.simpleCurrency(decimalDigits: 0).format(amount),
              style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 24, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebtItem(BuildContext context, DebtEntity debt, bool isDark) {
    final isLended = debt.type == DebtType.lended;
    final color = isLended ? const Color(0xFF00FF88) : Colors.orangeAccent;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isLended ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(debt.personName, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w900, fontSize: 15)),
                    Text(DateFormat('MMM dd, yyyy').format(debt.dateTime), style: TextStyle(color: (isDark ? Colors.white : Colors.black).withOpacity(0.38), fontSize: 11)),
                  ],
                ),
              ),
              Text(
                NumberFormat.simpleCurrency(decimalDigits: 1).format(debt.amount),
                style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (isLended && debt.phoneNumber != null)
                Expanded(
                  child: _actionButton(
                    "REMIND",
                    Icons.message_outlined,
                    const Color(0xFF00FF88),
                    isDark,
                    () => CommunicationHelper.sendReminder(
                      phoneNumber: debt.phoneNumber!,
                      personName: debt.personName,
                      amount: debt.amount,
                      isLended: true,
                    ),
                  ),
                ),
              if (isLended && debt.phoneNumber != null) const SizedBox(width: 12),
              Expanded(
                child: _actionButton(
                  "SETTLE",
                  Icons.check_circle_outline,
                  isDark ? Colors.white70 : Colors.black54,
                  isDark,
                  () => context.read<DebtBloc>().add(UpdateDebtRequested(debt.copyWith(isSettled: true))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String label, IconData icon, Color color, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: (isDark ? Colors.white : Colors.black).withOpacity(0.05)),
            const SizedBox(height: 16),
            Text("NO ACTIVE DEBTS", style: TextStyle(color: (isDark ? Colors.white : Colors.black).withOpacity(0.24), letterSpacing: 2, fontWeight: FontWeight.w900, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
