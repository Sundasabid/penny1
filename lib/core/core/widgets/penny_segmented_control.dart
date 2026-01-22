import 'package:flutter/material.dart';

import '../../config/themes/app_colors.dart';


class PennySegmentedControl extends StatelessWidget {
  final List<String> items;
  final String value;
  final ValueChanged<String> onChanged;

  const PennySegmentedControl({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = isDark ? AppColors.darkSurface2 : theme.colorScheme.surfaceContainerHighest;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    Widget chip(String label) {
      final selected = value == label;

      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onChanged(label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? (isDark ? AppColors.darkCard : Colors.white) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? AppColors.neon.withValues(alpha: 0.65) : Colors.transparent,
                width: 1,
              ),
              boxShadow: selected && isDark ? AppColors.neonGlow(blur: 16, opacity: 0.18) : const [],
            ),
            child: Center(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            chip(items[i]),
            if (i != items.length - 1) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}
