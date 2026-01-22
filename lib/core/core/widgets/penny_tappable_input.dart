import 'package:flutter/material.dart';

class PennyTappableInput extends StatelessWidget {
  final String text;
  final IconData? leadingIcon;
  final IconData trailingIcon;
  final VoidCallback onTap;

  const PennyTappableInput({
    super.key,
    required this.text,
    required this.onTap,
    this.leadingIcon,
    this.trailingIcon = Icons.keyboard_arrow_down_rounded,
  });

  InputDecoration _decorationFromTheme(BuildContext context, {Widget? prefixIcon, Widget? suffixIcon}) {
    final t = Theme.of(context).inputDecorationTheme;
    return InputDecoration(
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: t.filled ?? true,
      fillColor: t.fillColor,
      contentPadding: t.contentPadding,
      border: t.border,
      enabledBorder: t.enabledBorder,
      focusedBorder: t.focusedBorder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: InputDecorator(
        decoration: _decorationFromTheme(
          context,
          prefixIcon: leadingIcon == null ? null : Icon(leadingIcon),
          suffixIcon: Icon(trailingIcon),
        ),
        child: Text(text),
      ),
    );
  }
}
