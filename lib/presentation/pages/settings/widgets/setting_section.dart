import 'package:flutter/material.dart';
import '../../../../config/themes/app_colors.dart';

class SettingSection extends StatelessWidget {
  const SettingSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isDark
                  ? AppColors.textOnDarkMuted
                  : AppColors.textOnLightMuted,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131A21) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF1E272E) : const Color(0xFFF1F5F9),
            ),
          ),
          child: Column(
            children: List.generate(children.length, (index) {
              return Column(
                children: [
                  children[index],
                  if (index < children.length - 1)
                    Divider(
                      height: 1,
                      indent: 70,
                      endIndent: 16,
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : const Color(0xFFF1F5F9),
                    ),
                ],
              );
            }),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
