import 'package:flutter/material.dart';

class PennyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final IconData? leadingIcon;
  final Widget? trailing;
  final TextInputType keyboardType;
  final int maxLines;
  final bool obscureText;
  final TextInputAction textInputAction;
  final VoidCallback? onTrailingTap;

  const PennyTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.leadingIcon,
    this.trailing,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.obscureText = false,
    this.textInputAction = TextInputAction.next,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      obscureText: obscureText,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: leadingIcon == null ? null : Icon(leadingIcon),
        suffixIcon: trailing == null
            ? null
            : InkWell(
          onTap: onTrailingTap,
          child: trailing,
        ),
        filled: theme.inputDecorationTheme.filled,
        fillColor: theme.inputDecorationTheme.fillColor,
        contentPadding: theme.inputDecorationTheme.contentPadding,
        border: theme.inputDecorationTheme.border,
        enabledBorder: theme.inputDecorationTheme.enabledBorder,
        focusedBorder: theme.inputDecorationTheme.focusedBorder,
        errorBorder: theme.inputDecorationTheme.errorBorder,
        focusedErrorBorder: theme.inputDecorationTheme.focusedErrorBorder,
      ),
    );
  }
}
