// lib/src/core/widgets/history_filter_bar.dart

import 'package:flutter/material.dart';

import '../../../domain/entities/transaction.dart';
import '../../config/themes/app_colors.dart';

class HistoryFilterBar extends StatelessWidget {
  final DateTimeRange? selectedRange;
  final String? selectedCategory;

  // ✅ NEW (optional, so old calls won't break)
  final TransactionSource? selectedSource;
  final ValueChanged<TransactionSource?>? onSelectSource;

  final VoidCallback onPickRange;
  final VoidCallback onPickCategory;
  final VoidCallback onClearAll;

  const HistoryFilterBar({
    super.key,
    required this.selectedRange,
    required this.selectedCategory,
    required this.onPickRange,
    required this.onPickCategory,
    required this.onClearAll,

    // ✅ optional
    this.selectedSource,
    this.onSelectSource,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // All is selected when nothing is filtered
    final allSelected =
        selectedRange == null &&
        selectedCategory == null &&
        selectedSource == null;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Pill(
            label: 'All',
            selected: allSelected,
            onTap: onClearAll,
            theme: theme,
          ),
          const SizedBox(width: 10),
          _Pill(
            label: 'Date Range',
            selected: selectedRange != null,
            outlined: true,
            onTap: onPickRange,
            theme: theme,
          ),
          const SizedBox(width: 10),
          _Pill(
            label: 'Category',
            selected: selectedCategory != null,
            outlined: true,
            onTap: onPickCategory,
            theme: theme,
          ),

          // ✅ NEW: Receipt chip (only shown if callback provided)
          if (onSelectSource != null) ...[
            const SizedBox(width: 10),
            _Pill(
              label: 'Receipt',
              selected: selectedSource == TransactionSource.receipt,
              outlined: selectedSource != TransactionSource.receipt,
              onTap: () {
                if (selectedSource == TransactionSource.receipt) {
                  onSelectSource!(null); // toggle off
                } else {
                  onSelectSource!(TransactionSource.receipt); // toggle on
                }
              },
              theme: theme,
            ),
          ],
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool selected;
  final bool outlined;
  final VoidCallback onTap;
  final ThemeData theme;

  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.theme,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    final bg = selected
        ? AppColors.neon
        : (isDark ? const Color(0xFF131A21) : Colors.white);
    final fg = selected
        ? Colors.white
        : (isDark ? AppColors.textOnDarkMuted : const Color(0xFF98A2B3));
    final borderColor = outlined
        ? (isDark
              ? const Color(0xFF1E272E)
              : theme.dividerColor.withValues(alpha: 0.85))
        : Colors.transparent;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? bg : borderColor),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: fg,
          ),
        ),
      ),
    );
  }
}
