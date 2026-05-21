import 'package:flutter/material.dart';
import '../../../../config/themes/app_colors.dart';
import '../../../bloc/copilot/copilot_state.dart';

class SubscriptionCard extends StatelessWidget {
  final List<DetectedSubscription> subscriptions;
  final double totalFixedCosts;

  const SubscriptionCard({
    super.key,
    required this.subscriptions,
    required this.totalFixedCosts,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (subscriptions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Column(
          children: [
            Icon(Icons.subscriptions_outlined, color: Colors.grey.withOpacity(0.4), size: 36),
            const SizedBox(height: 12),
            const Text('No recurring expenses detected yet.', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const Text('Keep logging and Penny will find patterns.', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.autorenew_rounded, color: AppColors.info, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'RECURRING EXPENSES',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: AppColors.info),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${totalFixedCosts.round()} PKR/avg',
                    style: TextStyle(color: AppColors.info, fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...subscriptions.map((sub) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      sub.merchant[0].toUpperCase(),
                      style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.info, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sub.merchant, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF101828))),
                      Text('${sub.occurrences} transactions', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                Text(
                  '~${sub.avgAmount.round()} PKR',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF101828)),
                ),
              ],
            ),
          )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
