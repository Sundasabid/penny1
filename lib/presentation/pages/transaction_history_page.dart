// lib/src/presentation/pages/history/transaction_history_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../../domain/entities/transaction.dart';
import '../../config/themes/app_colors.dart';
import '../../core/widgets/history_filter_bar.dart';
import '../../core/widgets/search_bar_widget.dart';
import '../../core/widgets/transaction_item.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import 'add_expense.dart';


class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  final _searchCtrl = TextEditingController();

  DateTimeRange? _range;
  String? _category;

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(const LoadTransactionsRequested());
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<TransactionEntity> _applyFilters(List<TransactionEntity> all) {
    final q = _searchCtrl.text.trim().toLowerCase();

    final filtered = all.where((tx) {
      final matchSearch = q.isEmpty ||
          tx.merchant.toLowerCase().contains(q) ||
          tx.category.toLowerCase().contains(q) ||
          tx.paymentMethod.toLowerCase().contains(q);

      final matchRange = _range == null ||
          (tx.dateTime.isAfter(_range!.start.subtract(const Duration(seconds: 1))) &&
              tx.dateTime.isBefore(_range!.end.add(const Duration(days: 1))));

      final matchCategory = _category == null || tx.category == _category;

      return matchSearch && matchRange && matchCategory;
    }).toList();

    filtered.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, state) {
            // ✅ FIXED: use state.transactions (not state.items)
            final filtered = _applyFilters(state.transactions);

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CircleIcon(
                      icon: Icons.arrow_back,
                      onTap: () {
                        // ✅ If you used pushReplacement to open History,
                        // maybePop/pop will not work. Replace back to AddExpensePage.
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const AddExpensePage()),
                        );
                      },
                    ),
                    SizedBox(width: 12), // ✅ removed const to avoid const-context issues
                    Expanded(
                      child: Text(
                        'Transaction\nHistory',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    SizedBox(width: 12), // ✅ removed const to avoid const-context issues
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Export (coming soon).')),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAFBF1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.neon.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Text(
                          'Export',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.neonDark,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),




                const SizedBox(height: 14),

                SearchBarWidget(controller: _searchCtrl),

                const SizedBox(height: 14),

                HistoryFilterBar(
                  selectedRange: _range,
                  selectedCategory: _category,
                  onPickRange: () async {
                    final now = DateTime.now();
                    final picked = await showDateRangePicker(
                      context: context,
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
                    if (picked != null) setState(() => _range = picked);
                  },
                  onPickCategory: () async {
                    final cats = <String>[
                      'Groceries',
                      'Dining',
                      'Transport',
                      'Shopping',
                      'Utilities',
                      'Others',
                    ];

                    final picked = await showModalBottomSheet<String?>(
                      context: context,
                      builder: (_) => SafeArea(
                        child: ListView(
                          children: [
                            ListTile(
                              title: const Text('All Categories'),
                              onTap: () => Navigator.of(context).pop(null),
                            ),
                            for (final c in cats)
                              ListTile(
                                title: Text(c),
                                onTap: () => Navigator.of(context).pop(c),
                              ),
                          ],
                        ),
                      ),
                    );

                    setState(() => _category = picked);
                  },
                  onClearAll: () {
                    setState(() {
                      _range = null;
                      _category = null;
                      _searchCtrl.clear();
                    });
                  },
                ),

                const SizedBox(height: 18),

                if (state.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  ),

                if (state.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      state.errorMessage!,
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
                    ),
                  ),

                if (!state.isLoading && filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Center(
                      child: Text(
                        'No transactions found.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ),

                for (final tx in filtered) ...[
                  TransactionItem(tx: tx),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          shape: BoxShape.circle,
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}
