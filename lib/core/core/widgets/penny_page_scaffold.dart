import 'package:flutter/material.dart';
import 'penny_icon_button.dart';

class PennyPageScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const PennyPageScaffold({
    super.key,
    required this.title,
    required this.child,
    this.showBack = true,
    this.onBack,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  if (showBack)
                    PennyIconCircleButton(
                      icon: Icons.arrow_back,
                      onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                    )
                  else
                    const SizedBox(width: 44),
                  const Spacer(),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 44,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: (actions == null || actions!.isEmpty)
                          ? const SizedBox.shrink()
                          : Row(mainAxisSize: MainAxisSize.min, children: actions!),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
