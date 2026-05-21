import 'package:flutter/material.dart';
import '../../../../config/themes/app_colors.dart';

class SettingTile extends StatelessWidget {
  const SettingTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.textColor,
    this.iconColor,
    this.iconBackgroundColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? textColor;
  final Color? iconColor;
  final Color? iconBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color:
              iconBackgroundColor ??
              (isDark
                  ? AppColors.neon.withOpacity(0.1)
                  : const Color(0xFFE6F7F0)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.neon, size: 20),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color:
                  textColor ??
                  (isDark ? Colors.white : const Color(0xFF101828)),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.textOnDarkMuted
                    : AppColors.textOnLightMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
      trailing:
          trailing ??
          Icon(
            Icons.chevron_right_rounded,
            color: isDark ? AppColors.textOnDarkMuted : const Color(0xFF98A2B3),
            size: 20,
          ),
    );
  }
}
