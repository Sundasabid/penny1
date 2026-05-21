import 'package:flutter/material.dart';
import '../../../../config/themes/app_colors.dart';

class ToggleSettingTile extends StatelessWidget {
  const ToggleSettingTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.neon.withOpacity(0.1)
              : const Color(0xFFE6F7F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.neon, size: 20),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF101828),
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
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.neon,
        activeTrackColor: AppColors.neon.withOpacity(0.3),
      ),
    );
  }
}
