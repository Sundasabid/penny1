// lib/src/presentation/pages/transactions/add_expense_page.dart

import 'package:app/presentation/pages/transaction_history_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/themes/app_colors.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';


class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  // No placeholders. No defaults.
  final TextEditingController _merchantCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  double _amount = 0;
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Groceries';
  String _paymentMethod = 'Card';

  final List<String> _categories = const [
    'Groceries',
    'Dining',
    'Transport',
    'Shopping',
    'Utilities',
    'Others',
  ];

  @override
  void dispose() {
    _merchantCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _saveExpense() {
    final merchant = _merchantCtrl.text.trim();
    if (_amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount.')),
      );
      return;
    }
    if (merchant.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter merchant/title.')),
      );
      return;
    }

    final tx = TransactionEntity(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      merchant: merchant,
      category: _selectedCategory,
      amount: _amount,
      dateTime: _selectedDate,
      paymentMethod: _paymentMethod,
      isIncome: false,
      source: TransactionSource.manual,
      receiptId: null
    );

    context.read<TransactionBloc>().add(AddTransactionRequested(tx));
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        final t = Theme.of(context);
        return Theme(
          data: t.copyWith(
            colorScheme: t.colorScheme.copyWith(primary: AppColors.neon),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  String _dateLabel(DateTime d) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    final now = DateTime.now();
    final isToday = d.year == now.year && d.month == now.month && d.day == now.day;
    if (isToday) return 'Today, ${d.day} ${months[d.month - 1]}';
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String _formatAmount(double v) {
    final n = v.round().toString();
    // simple thousands formatting without intl
    final chars = n.split('').reversed.toList();
    final out = <String>[];
    for (int i = 0; i < chars.length; i++) {
      out.add(chars[i]);
      if ((i + 1) % 3 == 0 && i != chars.length - 1) out.add(',');
    }
    return out.reversed.join();
  }

  Future<void> _openAmountSheet() async {
    final theme = Theme.of(context);
    final controller = TextEditingController(
      text: _amount <= 0 ? '' : _amount.round().toString(),
    );

    final result = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        final viewInsets = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(18, 14, 18, 18 + viewInsets),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.dividerColor.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Text(
                    'Amount',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(null),
                    child: Text(
                      'Cancel',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.neon.withValues(alpha: 0.25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neon.withValues(alpha: 0.10),
                      blurRadius: 18,
                      spreadRadius: 1,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      'PKR',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.neonDark,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neon,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    final raw = controller.text.trim();
                    final parsed = double.tryParse(raw);
                    if (parsed == null || parsed <= 0) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Enter a valid amount.')),
                      );
                      return;
                    }
                    Navigator.of(ctx).pop(parsed);
                  },
                  child: const Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (result != null) {
      setState(() => _amount = result);
    }
  }

  InputDecoration _fieldDecoration(ThemeData theme, {required IconData icon}) {
    return InputDecoration(
      filled: true,
      fillColor: theme.colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      prefixIcon: Container(
        margin: const EdgeInsets.only(left: 12, right: 10),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.neon.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: AppColors.neonDark, size: 20),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.7)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.neon.withValues(alpha: 0.75), width: 1.4),
      ),
    );
  }

  Widget _label(String t) {
    final theme = Theme.of(context);
    return Text(
      t,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.55),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<TransactionBloc, TransactionState>(
      listenWhen: (p, c) => p.addSuccess != c.addSuccess,
      listener: (context, state) {
        if (state.addSuccess) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const TransactionHistoryPage()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            children: [
              // Top row: X, centered title
              Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.close,
                        color: theme.textTheme.bodyLarge?.color,
                        size: 26,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'New\nExpense',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 44),
                ],
              ),

              const SizedBox(height: 18),

              // Amount card (tap to edit)
              InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: _openAmountSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 26),
                  decoration: BoxDecoration(
                    color: AppColors.neon.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    children: [
                      // Keep your existing layout text if you still want.
                      // If you truly want "digits only", delete the two Text widgets below.
                      Text(
                        'Enter',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.45),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Amount',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.45),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'PKR',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.45),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _formatAmount(_amount),
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.neonDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 22),

              _label('Merchant / Title'),
              const SizedBox(height: 8),
              TextField(
                controller: _merchantCtrl,
                decoration: _fieldDecoration(theme, icon: Icons.store),
              ),

              const SizedBox(height: 18),

              _label('Category'),
              const SizedBox(height: 8),
              InputDecorator(
                decoration: _fieldDecoration(theme, icon: Icons.shopping_cart_outlined).copyWith(
                  // Greenish focused outline already handled; add slight glow
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.neon.withValues(alpha: 0.85), width: 1.4),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.55),
                    ),
                    onChanged: (v) => setState(() => _selectedCategory = v ?? _selectedCategory),
                    items: _categories
                        .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(
                        c,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ))
                        .toList(),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              _label('Date'),
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: _fieldDecoration(theme, icon: Icons.calendar_today_outlined),
                  child: Text(
                    _dateLabel(_selectedDate),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              _label('Payment Method'),
              const SizedBox(height: 10),
              _PaymentTabs(
                value: _paymentMethod,
                onChanged: (v) => setState(() => _paymentMethod = v),
              ),

              const SizedBox(height: 18),

              _label('Notes (Optional)'),
              const SizedBox(height: 8),
              TextField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: _fieldDecoration(theme, icon: Icons.note_alt_outlined),
              ),

              const SizedBox(height: 26),

              BlocBuilder<TransactionBloc, TransactionState>(
                builder: (context, state) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neon.withValues(alpha: 0.20),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      height: 64,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.isLoading ? null : _saveExpense,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.neon,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          elevation: 0,
                        ),
                        child: state.isLoading
                            ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Text(
                          'Save Expense',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentTabs extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _PaymentTabs({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const options = ['Cash', 'Card', 'Online'];

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: options.map((opt) {
          final selected = opt == value;

          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => onChanged(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: selected
                      ? [
                    BoxShadow(
                      color: AppColors.neon.withValues(alpha: 0.14),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    opt,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: selected
                          ? theme.textTheme.bodyLarge?.color
                          : theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.45),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
