import 'package:flutter/material.dart';

import '../../config/themes/app_colors.dart';


class HistoryFilterBar extends StatelessWidget {
  final DateTimeRange? selectedRange;
  final String? selectedCategory;
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
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Chip(
            text: 'All',
            selected: selectedRange == null && selectedCategory == null,
            onTap: onClearAll,
          ),
          const SizedBox(width: 10),
          _Chip(
            text: selectedRange == null
                ? 'Date Range'
                : '${selectedRange!.start.day}/${selectedRange!.start.month} - ${selectedRange!.end.day}/${selectedRange!.end.month}',
            selected: selectedRange != null,
            onTap: onPickRange,
          ),
          const SizedBox(width: 10),
          _Chip(
            text: selectedCategory ?? 'Category',
            selected: selectedCategory != null,
            onTap: onPickCategory,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({required this.text, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.neonDark : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? Colors.transparent : theme.dividerColor.withValues(alpha: 0.7),
          ),
        ),
        child: Text(
          text,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : theme.textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }
}
