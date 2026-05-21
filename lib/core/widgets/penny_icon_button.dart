import 'package:flutter/material.dart';

import '../../config/themes/app_colors.dart';

class PennyIconCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const PennyIconCircleButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onPressed,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border, width: 1),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}
