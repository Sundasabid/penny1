import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../config/themes/app_colors.dart';
import '../../../../domain/entities/planned_purchase.dart';

import '../purchase_plan_page.dart';

class PurchasePlannerCard extends StatelessWidget {
  final PlannedPurchase purchase;
  final VoidCallback onRemove;

  const PurchasePlannerCard({
    super.key,
    required this.purchase,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final daysLeft = (purchase.targetDate.difference(DateTime.now()).inDays).abs();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.5,
        ),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.neon.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.shopping_bag_rounded, color: AppColors.neon, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      purchase.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF101828),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${purchase.amount.round()} PKR • ${daysLeft > 0 ? "$daysLeft days remaining" : "Goal reached!"}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 14, color: Colors.redAccent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // ACTION AREA
          if (purchase.isAiLoading)
            _buildLoadingIndicator(isDark)
          else
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.neon.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome_rounded, color: AppColors.neon, size: 14),
                        SizedBox(width: 6),
                        Text('Plan Ready', style: TextStyle(color: AppColors.neon, fontSize: 11, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PurchasePlanPage(purchase: purchase)),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    backgroundColor: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'See Details',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.neon),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.white10 : Colors.black12,
      highlightColor: isDark ? Colors.white24 : Colors.black26,
      child: Container(
        height: 44,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
