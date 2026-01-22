// lib/src/features/transactions/presentation/pages/new_expense_page.dart
//
// Manual expense entry page (Light theme) for PENNY.
// FIXED: All InputDecorator/InputDecoration usage (no InputDecorationTheme misuse).
//
// Requirements:
// - You already have AppTheme/AppColors set up.
// - This page compiles standalone and can be previewed from main.dart.

import 'package:flutter/material.dart';

import '../../config/themes/app_colors.dart';


class NewExpensePage extends StatefulWidget {
  const NewExpensePage({super.key});

  @override
  State<NewExpensePage> createState() => _NewExpensePageState();
}

class _NewExpensePageState extends State<NewExpensePage> {
  final _merchantCtrl = TextEditingController(text: 'Carrefour Market');
  final _notesCtrl = TextEditingController();
  final _amountCtrl = TextEditingController(text: '2450');

  String _selectedCategory = 'Groceries';
  DateTime _selectedDate = DateTime.now();
  String _paymentMethod = 'Card'; // Cash | Card | Online

  @override
  void dispose() {
    _merchantCtrl.dispose();
    _notesCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  String get _amountPretty {
    final raw = _amountCtrl.text.trim().replaceAll(',', '');
    final value = int.tryParse(raw);
    if (value == null) return '0';
    return value.toString();
  }

  String get _datePretty {
    final now = DateTime.now();
    final isToday =
        now.year == _selectedDate.year && now.month == _selectedDate.month && now.day == _selectedDate.day;

    if (isToday) return 'Today, ${_selectedDate.day} Oct';
    return '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.neon),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense saved (demo).')),
    );
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  _IconCircleButton(
                    icon: Icons.close,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const Spacer(),
                  Text(
                    'New\nExpense',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 44),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Amount card
                    _AmountCard(
                      amount: _amountPretty,
                      onTap: () async {
                        final result = await showModalBottomSheet<String>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => _AmountSheet(initial: _amountCtrl.text),
                        );
                        if (result != null) setState(() => _amountCtrl.text = result);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Merchant
                    const _FieldLabel(text: 'Merchant / Title'),
                    TextField(
                      controller: _merchantCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: 'e.g., Carrefour Market',
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Category dropdown
                    const _FieldLabel(text: 'Category'),
                    _DropdownField(
                      value: _selectedCategory,
                      leadingIcon: Icons.shopping_bag_outlined,
                      onChanged: (v) => setState(() => _selectedCategory = v),
                      items: const [
                        'Groceries',
                        'Dining',
                        'Transport',
                        'Shopping',
                        'Utilities',
                        'Health',
                        'Others',
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Date field (decorated like an input)
                    const _FieldLabel(text: 'Date'),
                    _TappableInput(
                      leadingIcon: Icons.calendar_today_outlined,
                      trailingIcon: Icons.keyboard_arrow_down_rounded,
                      text: _datePretty,
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 14),

                    // Payment method segmented
                    const _FieldLabel(text: 'Payment Method'),
                    _SegmentedPayment(
                      value: _paymentMethod,
                      onChanged: (v) => setState(() => _paymentMethod = v),
                    ),
                    const SizedBox(height: 14),

                    // Notes
                    const _FieldLabel(text: 'Notes (Optional)'),
                    TextField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Add details...',
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Save button (neon)
                    _NeonPrimaryButton(
                      text: 'Save Expense',
                      onTap: _save,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------- Helpers: build InputDecoration from theme (no errors) ----------

InputDecoration _decorationFromTheme(
    BuildContext context, {
      String? hintText,
      Widget? prefixIcon,
      Widget? suffixIcon,
      String? prefixText,
    }) {
  final t = Theme.of(context).inputDecorationTheme;

  // NOTE: InputDecorationTheme fields are optional; provide safe fallbacks.
  return InputDecoration(
    hintText: hintText,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    prefixText: prefixText,
    filled: t.filled ?? true,
    fillColor: t.fillColor,
    contentPadding: t.contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    hintStyle: t.hintStyle,
    labelStyle: t.labelStyle,
    border: t.border ??
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
    enabledBorder: t.enabledBorder,
    focusedBorder: t.focusedBorder,
    errorBorder: t.errorBorder,
    focusedErrorBorder: t.focusedErrorBorder,
  );
}

/// ---------- UI Components ----------

class _AmountCard extends StatelessWidget {
  final String amount;
  final VoidCallback onTap;

  const _AmountCard({
    required this.amount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface2 : const Color(0xFFEAFBF1);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.neon.withValues(alpha: 0.18), width: 1),
        ),
        child: Column(
          children: [
            Text(
              'Enter\nAmount',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'PKR ',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.75),
                    ),
                  ),
                  TextSpan(
                    text: amount,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: AppColors.neonDark,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String value;
  final List<String> items;
  final IconData leadingIcon;
  final ValueChanged<String> onChanged;

  const _DropdownField({
    required this.value,
    required this.items,
    required this.leadingIcon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InputDecorator(
      decoration: _decorationFromTheme(
        context,
        prefixIcon: Icon(leadingIcon, color: AppColors.neonDark),
        suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const SizedBox.shrink(), // we render our own suffixIcon
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

class _TappableInput extends StatelessWidget {
  final IconData leadingIcon;
  final IconData trailingIcon;
  final String text;
  final VoidCallback onTap;

  const _TappableInput({
    required this.leadingIcon,
    required this.trailingIcon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: InputDecorator(
        decoration: _decorationFromTheme(
          context,
          prefixIcon: Icon(leadingIcon, color: theme.iconTheme.color?.withValues(alpha: 0.7)),
          suffixIcon: Icon(trailingIcon, color: theme.iconTheme.color?.withValues(alpha: 0.7)),
        ),
        child: Text(text, style: theme.textTheme.bodyMedium),
      ),
    );
  }
}

class _SegmentedPayment extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _SegmentedPayment({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = isDark ? AppColors.darkSurface2 : theme.colorScheme.surfaceContainerHighest;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    Widget item(String label) {
      final selected = value == label;
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onChanged(label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? (isDark ? AppColors.darkCard : Colors.white) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? AppColors.neon.withValues(alpha: 0.65) : Colors.transparent,
                width: 1,
              ),
              boxShadow: selected && isDark ? AppColors.neonGlow(blur: 16, opacity: 0.18) : const [],
            ),
            child: Center(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected
                      ? (isDark ? AppColors.textOnDark : theme.colorScheme.onSurface)
                      : theme.textTheme.bodySmall?.color,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        children: [
          item('Cash'),
          const SizedBox(width: 6),
          item('Card'),
          const SizedBox(width: 6),
          item('Online'),
        ],
      ),
    );
  }
}

class _NeonPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _NeonPrimaryButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.neon,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isDark
              ? AppColors.neonGlow(blur: 22, opacity: 0.35)
              : [
            BoxShadow(
              color: AppColors.neon.withValues(alpha: 0.22),
              blurRadius: 18,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _IconCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconCircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
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

/// ---------- Amount bottom sheet ----------

class _AmountSheet extends StatefulWidget {
  final String initial;
  const _AmountSheet({required this.initial});

  @override
  State<_AmountSheet> createState() => _AmountSheetState();
}

class _AmountSheetState extends State<_AmountSheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: theme.dividerColor.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Enter Amount',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            decoration: _decorationFromTheme(
              context,
              prefixText: 'PKR ',
              hintText: '0',
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(_ctrl.text.trim()),
              child: const Text('Done'),
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}
