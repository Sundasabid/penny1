import 'package:flutter/material.dart';

class PennyDropdownField extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final IconData? leadingIcon;

  const PennyDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.leadingIcon,
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
      errorBorder: t.errorBorder,
      focusedErrorBorder: t.focusedErrorBorder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InputDecorator(
      decoration: _decorationFromTheme(
        context,
        prefixIcon: leadingIcon == null ? null : Icon(leadingIcon),
        suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const SizedBox.shrink(),
          items: items
              .map(
                (e) => DropdownMenuItem<String>(
              value: e,
              child: Text(e, style: theme.textTheme.bodyMedium),
            ),
          )
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
