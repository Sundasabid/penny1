import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../config/themes/app_colors.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../domain/entities/subscription.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/subscription/subscription_bloc.dart';
import '../../bloc/subscription/subscription_event.dart';
import '../../bloc/subscription/subscription_state.dart';
import 'add_subscription_page.dart';

class SubscriptionRadarPage extends StatefulWidget {
  const SubscriptionRadarPage({super.key});

  @override
  State<SubscriptionRadarPage> createState() => _SubscriptionRadarPageState();
}

class _SubscriptionRadarPageState extends State<SubscriptionRadarPage> {
  @override
  void initState() {
    super.initState();
    context.read<SubscriptionBloc>().add(LoadSubscriptionsRequested());
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;
    final symbol = CurrencyHelper.getSymbol(user.currency);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Subscription Radar', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: BlocBuilder<SubscriptionBloc, SubscriptionState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.neon));
          }

          if (state.errorMessage != null) {
            return Center(child: Text('Error: \${state.errorMessage}', style: const TextStyle(color: Colors.red)));
          }

          final subs = state.subscriptions;
          
          double totalMonthly = 0.0;
          for (var s in subs) {
            if (s.cycle == BillingCycle.monthly) totalMonthly += s.amount;
            else if (s.cycle == BillingCycle.yearly) totalMonthly += s.amount / 12;
            else if (s.cycle == BillingCycle.weekly) totalMonthly += s.amount * 4;
          }

          return Column(
            children: [
              _buildSummaryHeader(totalMonthly, symbol),
              const SizedBox(height: 16),
              Expanded(
                child: subs.isEmpty 
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: subs.length,
                        itemBuilder: (context, index) {
                          return _buildSubscriptionCard(subs[index], symbol, context);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.neon,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddSubscriptionPage()),
          );
        },
        child: const Icon(Icons.add_alert, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryHeader(double total, String symbol) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.neon.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(color: AppColors.neon.withOpacity(0.15), spreadRadius: 4, blurRadius: 20)
        ],
      ),
      child: Column(
        children: [
          const Text('MONTHLY FIXED COSTS', style: TextStyle(letterSpacing: 1.5, fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 8),
          Text('$symbol${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: AppColors.neon)),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(SubscriptionEntity sub, String symbol, BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(sub.nextDueDate.year, sub.nextDueDate.month, sub.nextDueDate.day);
    
    final diff = due.difference(today).inDays;
    
    Color glowColor = AppColors.neon;
    String status = 'Due in $diff days';

    if (diff <= 0) {
      glowColor = Colors.redAccent;
      status = diff == 0 ? 'DUE TODAY' : 'OVERDUE';
    } else if (diff <= 3) {
      glowColor = Colors.amber;
      status = 'Due in $diff days';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: glowColor.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(color: glowColor.withOpacity(0.1), blurRadius: 10, spreadRadius: 1),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: glowColor.withOpacity(0.2),
              child: Icon(Icons.autorenew, color: glowColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(sub.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(status, style: TextStyle(color: glowColor, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(DateFormat.yMMMd().format(sub.nextDueDate), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$symbol${sub.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    context.read<SubscriptionBloc>().add(MarkSubscriptionPaidRequested(sub));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Marked paid! Expense logged & date updated. 🚀')),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.neon.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.neon),
                    ),
                    child: const Text('MARK PAID', style: TextStyle(color: AppColors.neon, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.radar, size: 80, color: AppColors.neon.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text('No subscriptions tracking!', style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }
}
