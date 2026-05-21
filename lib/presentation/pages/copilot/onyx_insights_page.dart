import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/copilot/copilot_bloc.dart';
import '../../bloc/copilot/copilot_state.dart';
import '../../bloc/transaction_bloc.dart';
import '../../bloc/transaction_state.dart';
import '../../../domain/entities/transaction.dart';

class OnyxInsightsPage extends StatelessWidget {
  const OnyxInsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final user = authState.user;
          final points = user.onyxPoints;

          return BlocBuilder<CopilotBloc, CopilotState>(
            builder: (context, copilotState) {
              final completedChallenges = copilotState is CopilotLoaded
                  ? copilotState.challenges.where((c) => c.isCompleted).length
                  : 0;

              return BlocBuilder<TransactionBloc, TransactionState>(
                builder: (context, txState) {
                  final transactions = txState.transactions;
                  final streak = _calculateStreak(transactions);

                  return CustomScrollView(
                    slivers: [
                      _buildAppBar(context, points),
                      SliverToBoxAdapter(child: _buildBalanceCard(points)),
                      SliverToBoxAdapter(child: _buildEarningStats(completedChallenges, streak)),
                      SliverToBoxAdapter(child: _buildSectionHeader("Onyx Rewards")),
                      SliverToBoxAdapter(child: _buildRewardsGrid()),
                      const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  int _calculateStreak(List<TransactionEntity> transactions) {
    if (transactions.isEmpty) return 0;
    
    final dates = transactions
        .map((t) => DateTime(t.dateTime.year, t.dateTime.month, t.dateTime.day))
        .toSet()
        .toList();
    
    if (dates.isEmpty) return 0;
    dates.sort((a, b) => b.compareTo(a));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (dates.first.isBefore(yesterday)) return 0;

    int streak = 0;
    DateTime currentCheck = dates.first;

    for (final date in dates) {
      if (date == currentCheck) {
        streak++;
        currentCheck = currentCheck.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  Widget _buildAppBar(BuildContext context, int points) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      backgroundColor: Colors.black,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        "ONYX INSIGHTS",
        style: TextStyle(
          letterSpacing: 2,
          fontWeight: FontWeight.w900,
          fontSize: 14,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBalanceCard(int points) {
    final level = (points / 500).floor() + 1;
    final progress = (points % 500) / 500;
    final String levelName = level >= 10 ? "FINANCIAL LEGEND" : level >= 5 ? "VISIONARY" : "STRATEGIST";

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[900]!,
            Colors.black,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FF88).withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.dark_mode_rounded, color: Color(0xFF00FF88), size: 40),
          ),
          const SizedBox(height: 20),
          Text(
            points.toString(),
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -2,
            ),
          ),
          const Text(
            "TOTAL ONYX EARNED",
            style: TextStyle(
              color: Colors.white38,
              fontSize: 12,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildProgressBar(progress),
          const SizedBox(height: 12),
          Text(
            "LVL $level: $levelName",
            style: const TextStyle(color: Color(0xFF00FF88), fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Stack(
      children: [
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        FractionallySizedBox(
          widthFactor: progress.clamp(0.0, 1.0),
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF00FF88), Color(0xFF9DFF00)]),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(color: const Color(0xFF00FF88).withOpacity(0.5), blurRadius: 10),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEarningStats(int challenges, int streak) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildStatBox("Challenges", challenges.toString(), Icons.emoji_events_outlined),
          const SizedBox(width: 12),
          _buildStatBox("Logging", "$streak Days", Icons.history_toggle_off),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF00FF88), size: 20),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text(
            "VIEW ALL",
            style: TextStyle(color: const Color(0xFF00FF88), fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildRewardItem("Onyx Cashback", "Convert to 5,000 PKR", Icons.account_balance_wallet, "2,000 Onyx"),
          const SizedBox(height: 12),
          _buildRewardItem("Premium Tee", "Limited Edition Penny Merch", Icons.monetization_on, "1,500 Onyx"),
          const SizedBox(height: 12),
          _buildRewardItem("Glass Theme", "Unlock Ultra-Premium UI", Icons.auto_awesome, "500 Onyx"),
        ],
      ),
    );
  }

  Widget _buildRewardItem(String title, String subtitle, IconData icon, String price) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF00FF88).withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, color: const Color(0xFF00FF88)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.5)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(price, style: const TextStyle(color: const Color(0xFF00FF88), fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
