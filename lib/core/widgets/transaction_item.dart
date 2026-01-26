// lib/src/core/widgets/transaction_item.dart
import 'package:flutter/material.dart';

import '../../../domain/entities/transaction.dart';
import '../../config/themes/app_colors.dart';

class TransactionItem extends StatelessWidget {
  final TransactionEntity tx;

  const TransactionItem({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isIncome = tx.isIncome;
    final amountPrefix = isIncome ? '+' : '-';
    final amountColor = isIncome ? const Color(0xFF98D8B6) : const Color(0xFF101828);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x07000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEAFBF1),
              shape: BoxShape.circle,
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        tx.merchant,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),

                    // ✅ Receipt badge
                    if (tx.source == TransactionSource.receipt)
                      Container(
                        margin: const EdgeInsets.only(left: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAFBF1),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.neon.withValues(alpha: 0.18)),
                        ),
                        child: Text(
                          'Receipt',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.neonDark,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${tx.category} • ${tx.paymentMethod}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF98A2B3),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$amountPrefix PKR ${_formatPkr(tx.amount)}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatPkr(double v) {
    final s = v.toStringAsFixed(0);
    final chars = s.split('').reversed.toList();
    final out = <String>[];
    for (var i = 0; i < chars.length; i++) {
      if (i != 0 && i % 3 == 0) out.add(',');
      out.add(chars[i]);
    }
    return out.reversed.join();
  }
}
