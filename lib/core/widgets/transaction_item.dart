import 'package:flutter/material.dart';


import '../../../../domain/entities/transaction.dart';
import '../../config/themes/app_colors.dart';

class TransactionItem extends StatelessWidget {
  final TransactionEntity tx;

  const TransactionItem({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final amountColor = tx.isIncome
        ? AppColors.neon.withValues(alpha: 0.35)
        : theme.textTheme.bodyLarge?.color;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neon.withValues(alpha: 0.12),
            ),
            child: const Icon(
              Icons.store,
              size: 20,
              color: AppColors.neonDark,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.merchant,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${tx.category} • ${tx.paymentMethod}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Text(
            '${tx.isIncome ? '+' : '-'}PKR ${tx.amount.toStringAsFixed(0)}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}
