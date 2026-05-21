// lib/src/core/widgets/transaction_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/transaction.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../config/themes/app_colors.dart';
import '../utils/currency_helper.dart';

class TransactionItem extends StatelessWidget {
  final TransactionEntity tx;
  final VoidCallback? onDelete;

  const TransactionItem({super.key, required this.tx, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final userCurrency = context.select((AuthBloc bloc) => bloc.state.user.currency ?? 'PKR');
    final symbol = CurrencyHelper.getSymbol(userCurrency);

    final isIncome = tx.isIncome;
    final amountPrefix = isIncome ? '+' : '-';
    final amountColor = isIncome
        ? (isDark ? const Color(0xFF98D8B6) : const Color(0xFF0E9F6E))
        : (isDark ? Colors.white : const Color(0xFF101828));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131A21) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF1E272E) : const Color(0xFFE2E8F0),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C252E) : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.05),
              ),
            ),
            child: Icon(
              _iconForCategory(tx.category),
              size: 20,
              color: isDark ? AppColors.neon : AppColors.neonDark,
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

                    // Receipt badge
                    if (tx.source == TransactionSource.receipt)
                      Container(
                        margin: const EdgeInsets.only(left: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.neon.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: AppColors.neon.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          'Receipt',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.neon,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${DateFormat('MMM d').format(tx.dateTime)} • ${tx.category} • ${tx.paymentMethod}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.textOnDarkMuted
                        : const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$amountPrefix $symbol ${_formatPkr(tx.amount)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: amountColor,
                ),
              ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: isDark ? Colors.red.withOpacity(0.7) : Colors.red,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _iconForCategory(String c) {
    switch (c.toLowerCase()) {
      case 'groceries':
        return Icons.shopping_basket_rounded;
      case 'dining':
        return Icons.restaurant_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'utilities':
        return Icons.bolt_rounded;
      default:
        return Icons.category_rounded;
    }
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
