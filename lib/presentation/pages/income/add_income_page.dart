import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/themes/app_colors.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/entities/category.dart';
import '../../bloc/transaction_bloc.dart';
import '../../bloc/transaction_event.dart';
import '../../bloc/transaction_state.dart';
import '../../bloc/category/category_bloc.dart';
import '../../bloc/category/category_state.dart';

class AddIncomePage extends StatefulWidget {
  const AddIncomePage({super.key});

  @override
  State<AddIncomePage> createState() => _AddIncomePageState();
}

class _AddIncomePageState extends State<AddIncomePage> {
  final TextEditingController _merchantCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  double _amount = 0;
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Salary';
  String _paymentMethod = 'Bank';

  @override
  void dispose() {
    _merchantCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _saveIncome() {
    final merchant = _merchantCtrl.text.trim();
    if (_amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount.')),
      );
      return;
    }
    if (merchant.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter source / title.')),
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
      isIncome: true,
      source: TransactionSource.manual,
      receiptId: null,
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
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final now = DateTime.now();
    final isToday = d.year == now.year && d.month == now.month && d.day == now.day;
    if (isToday) return 'Today, ${d.day} ${months[d.month - 1]}';
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String _formatAmount(double v) {
    final n = v.round().toString();
    final chars = n.split('').reversed.toList();
    final out = <String>[];
    for (int i = 0; i < chars.length; i++) {
      if (i != 0 && i % 3 == 0) out.add(',');
      out.add(chars[i]);
    }
    return out.reversed.join();
  }

  Future<void> _openAmountSheet() async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    'Income Amount',
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
                        color: isDark ? AppColors.textOnDarkMuted : AppColors.textOnLightMuted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF131A21) : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.neon.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    Text(
                      'PKR',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.textOnDarkMuted : AppColors.textOnLightMuted,
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
                          color: AppColors.neon,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          filled: false,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neon,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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
    final isDark = theme.brightness == Brightness.dark;
    return InputDecoration(
      filled: true,
      fillColor: isDark ? const Color(0xFF131A21) : theme.colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      prefixIcon: Container(
        margin: const EdgeInsets.only(left: 12, right: 10),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.neon.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: AppColors.neon, size: 20),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF1E272E) : const Color(0xFFE2E8F0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.neon.withOpacity(0.5),
          width: 1.5,
        ),
      ),
    );
  }

  Widget _label(String t) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Text(
      t,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.textOnDarkMuted : AppColors.textOnLightMuted,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocListener<TransactionBloc, TransactionState>(
      listenWhen: (p, c) => p.addSuccess != c.addSuccess,
      listener: (context, state) {
        if (state.addSuccess) {
          Navigator.of(context).pop(); // Back to where we came from
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            children: [
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
                        Icons.close_rounded,
                        color: isDark ? Colors.white : const Color(0xFF101828),
                        size: 26,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'New Income',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 44),
                ],
              ),
              const SizedBox(height: 24),
              InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: _openAmountSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 30),
                  decoration: BoxDecoration(
                    color: AppColors.neon.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.neon.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Income Amount',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textOnDarkMuted : AppColors.textOnLightMuted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'PKR',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.textOnDarkMuted : AppColors.textOnLightMuted,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _formatAmount(_amount),
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.neon,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _label('Source / Title'),
              const SizedBox(height: 10),
              TextField(
                controller: _merchantCtrl,
                decoration: _fieldDecoration(theme, icon: Icons.source_rounded),
              ),
              const SizedBox(height: 20),
              _label('Category'),
              const SizedBox(height: 10),
              BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  // Filter for income categories
                  var categories = state.categories.where((c) => c.type == CategoryType.income).toList();
                  
                  if (categories.isEmpty) {
                    return const Center(child: Text("No income categories found."));
                  }

                  if (!categories.any((c) => c.name == _selectedCategory)) {
                     // _selectedCategory = categories.first.name;
                  }

                  return InputDecorator(
                    decoration: _fieldDecoration(theme, icon: Icons.category_rounded),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: categories.any((c) => c.name == _selectedCategory) ? _selectedCategory : categories.first.name,
                        isExpanded: true,
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: isDark ? AppColors.textOnDarkMuted : AppColors.textOnLightMuted,
                        ),
                        onChanged: (v) => setState(() => _selectedCategory = v ?? _selectedCategory),
                        items: categories
                            .map((c) => DropdownMenuItem(
                                  value: c.name,
                                  child: Text(
                                    c.name,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _label('Date'),
              const SizedBox(height: 10),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: _fieldDecoration(theme, icon: Icons.calendar_today_rounded),
                  child: Text(
                    _dateLabel(_selectedDate),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _label('Deposit To'),
              const SizedBox(height: 12),
              _PaymentTabs(
                value: _paymentMethod,
                onChanged: (v) => setState(() => _paymentMethod = v),
              ),
              const SizedBox(height: 20),
              _label('Notes (Optional)'),
              const SizedBox(height: 10),
              TextField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: _fieldDecoration(theme, icon: Icons.note_alt_rounded),
              ),
              const SizedBox(height: 32),
              BlocBuilder<TransactionBloc, TransactionState>(
                builder: (context, state) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neon.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      height: 64,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.isLoading ? null : _saveIncome,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.neon,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: state.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Save Income',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                              ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
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

  const _PaymentTabs({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const options = ['Cash', 'Bank', 'Digital'];

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131A21) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF1E272E) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: options.map((opt) {
          final selected = opt == value;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => onChanged(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected
                      ? (isDark ? const Color(0xFF1C252E) : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: selected && !isDark
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
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
                          ? (isDark ? AppColors.neon : theme.textTheme.bodyLarge?.color)
                          : (isDark ? AppColors.textOnDarkMuted : AppColors.textOnLightMuted),
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
