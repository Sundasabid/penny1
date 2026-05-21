import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/budget/budget_bloc.dart';
import '../../bloc/budget/budget_event.dart';
import '../../bloc/budget/budget_state.dart';
import '../../bloc/transaction_bloc.dart';
import '../../bloc/transaction_state.dart';
import '../../bloc/category/category_bloc.dart';
import '../../bloc/category/category_state.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../../domain/entities/budget.dart';
import '../../../config/themes/app_colors.dart';

class BudgetPlannerPage extends StatefulWidget {
  const BudgetPlannerPage({super.key});

  @override
  State<BudgetPlannerPage> createState() => _BudgetPlannerPageState();
}

class _BudgetPlannerPageState extends State<BudgetPlannerPage> {
  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  void _loadBudgets() {
    context.read<BudgetBloc>().add(LoadBudgetsRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocListener<TransactionBloc, TransactionState>(
      listenWhen: (p, c) =>
          (p.addSuccess != c.addSuccess && c.addSuccess) ||
          (p.deleteSuccess != c.deleteSuccess && c.deleteSuccess),
      listener: (context, state) => _loadBudgets(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : const Color(0xFF101828),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Budget Planner',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1C252E)
                    : const Color(0xFFE7F6EE),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    _getCurrentMonthName(),
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textOnDark
                          : const Color(0xFF101828),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: isDark
                        ? AppColors.textOnDarkMuted
                        : const Color(0xFF101828),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: BlocBuilder<BudgetBloc, BudgetState>(
          builder: (context, state) {
            if (state.isLoading && state.budgets.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.neon),
              );
            }

            final totalLimit = state.budgets.fold<double>(
              0,
              (sum, b) => sum + b.limit,
            );
            final totalSpent = state.budgets.fold<double>(
              0,
              (sum, b) => sum + b.spent,
            );

            final user = context.watch<AuthBloc>().state.user;
            final income = user.monthlyIncome ?? 0.0;

            return RefreshIndicator(
              onRefresh: () async => _loadBudgets(),
              color: AppColors.neon,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SummaryCard(
                      totalLimit: totalLimit,
                      totalSpent: totalSpent,
                      income: income,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Category Budgets',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (state.budgets.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 60),
                          child: Column(
                            children: [
                              Icon(
                                Icons.pie_chart_outline_rounded,
                                size: 64,
                                color: isDark ? Colors.white10 : Colors.black12,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No budgets set yet.\nAdd one to start tracking!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.textOnDarkMuted
                                      : AppColors.textOnLightMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...state.budgets.map(
                        (budget) => _BudgetCategoryCard(
                          budget: budget,
                          onDelete: () => _confirmDelete(context, budget),
                        ),
                      ),
                    const SizedBox(height: 16),
                    _AddBudgetButton(
                      onTap: () => _showAddBudgetDialog(context),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _getCurrentMonthName() {
    final now = DateTime.now();
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[now.month - 1];
  }

  void _confirmDelete(BuildContext context, BudgetEntity budget) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        title: const Text(
          'Delete Budget',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Text('Remove the ${budget.category} budget?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<BudgetBloc>().add(DeleteBudgetRequested(budget.id));
              Navigator.pop(ctx);
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddBudgetSheet(),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double totalLimit;
  final double totalSpent;
  final double income;

  const _SummaryCard({
    required this.totalLimit,
    required this.totalSpent,
    this.income = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final remainingAmount = totalLimit - totalSpent;
    final progress = totalLimit > 0 ? (totalSpent / totalLimit) : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppColors.neon,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.neon.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Remaining Budget',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'PKR',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatCurrency(remainingAmount),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Limit: ${_formatCurrency(totalLimit)}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (income > 0)
                Text(
                  'Income: ${_formatCurrency(income)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BudgetCategoryCard extends StatelessWidget {
  final BudgetEntity budget;
  final VoidCallback onDelete;

  const _BudgetCategoryCard({required this.budget, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color progressColor = budget.isExceeded
        ? AppColors.danger
        : (budget.isApproaching ? AppColors.warning : AppColors.neon);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131A21) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF1E272E) : const Color(0xFFF1F5F9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                budget.category,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: isDark
                      ? AppColors.textOnDarkMuted
                      : AppColors.textOnLightMuted,
                  size: 20,
                ),
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: budget.progress.clamp(0.0, 1.0),
              backgroundColor: isDark
                  ? Colors.white.withOpacity(0.05)
                  : const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'PKR ${_formatCurrency(budget.spent)} ',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF101828),
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    TextSpan(
                      text: 'spent',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textOnDarkMuted
                            : AppColors.textOnLightMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Limit: ${_formatCurrency(budget.limit)}',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textOnDarkMuted
                      : AppColors.textOnLightMuted,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddBudgetButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddBudgetButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark
                ? AppColors.neon.withOpacity(0.2)
                : AppColors.neon.withOpacity(0.15),
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_circle_outline_rounded,
              color: AppColors.neon,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Add New Category Budget',
              style: TextStyle(
                color: AppColors.neon,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddBudgetSheet extends StatefulWidget {
  const _AddBudgetSheet();

  @override
  State<_AddBudgetSheet> createState() => _AddBudgetSheetState();
}

class _AddBudgetSheetState extends State<_AddBudgetSheet> {
  String? _selectedCategory;
  final TextEditingController _limitController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        26,
        12,
        26,
        26 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'New Budget',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 24),
          Text(
            'Category',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, state) {
              final categories = state.categories;
              if (categories.isEmpty) return const SizedBox();

              // Ensure selected is valid
              if (_selectedCategory == null ||
                  !categories.any((c) => c.name == _selectedCategory)) {
                if (categories.isNotEmpty)
                  _selectedCategory = categories.first.name;
              }

              return DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: categories
                    .map(
                      (c) =>
                          DropdownMenuItem(value: c.name, child: Text(c.name)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark ? const Color(0xFF131A21) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Monthly Limit (PKR)',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _limitController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontWeight: FontWeight.w800),
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? const Color(0xFF131A21) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neon,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: () {
                final limit = double.tryParse(_limitController.text) ?? 0;
                final category = _selectedCategory;

                if (limit > 0 && category != null) {
                  final budget = BudgetEntity(
                    id: '',
                    category: category,
                    limit: limit,
                    spent: 0,
                  );
                  context.read<BudgetBloc>().add(SaveBudgetRequested(budget));
                  Navigator.pop(context);
                } else if (category == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a category')),
                  );
                }
              },
              child: const Text(
                'Set Budget',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatCurrency(double amount) {
  final n = amount.round().toString();
  final chars = n.split('').reversed.toList();
  final out = <String>[];
  for (int i = 0; i < chars.length; i++) {
    if (i != 0 && i % 3 == 0) out.add(',');
    out.add(chars[i]);
  }
  return out.reversed.join();
}
