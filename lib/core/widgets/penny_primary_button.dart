import 'package:flutter/material.dart';

import '../../config/themes/app_colors.dart';

class PennyPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool glow;
  final bool isLoading;

  const PennyPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.glow = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: (onPressed == null || isLoading) ? null : onPressed,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 120),
        opacity: (onPressed == null) ? 0.55 : 1,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.neon,
            borderRadius: BorderRadius.circular(14),
            boxShadow: glow
                ? (isDark
                      ? AppColors.neonGlow(blur: 22, opacity: 0.35)
                      : [
                          BoxShadow(
                            color: AppColors.neon.withValues(alpha: 0.22),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ])
                : const [],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : Text(
                    text,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
