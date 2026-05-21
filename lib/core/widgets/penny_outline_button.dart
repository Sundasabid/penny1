import 'package:flutter/material.dart';

import '../../config/themes/app_colors.dart';

class PennyOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? leading;

  const PennyOutlineButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onPressed,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 1),
          color: Colors.transparent,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 10)],
            Text(
              text,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
