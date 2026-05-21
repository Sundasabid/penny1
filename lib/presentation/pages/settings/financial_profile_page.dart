import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../../config/themes/app_colors.dart';

class FinancialProfilePage extends StatefulWidget {
  const FinancialProfilePage({super.key});

  @override
  State<FinancialProfilePage> createState() => _FinancialProfilePageState();
}

class _FinancialProfilePageState extends State<FinancialProfilePage> {
  final TextEditingController _incomeCtrl = TextEditingController();
  String _selectedCurrency = 'PKR';

  final List<String> _currencies = [
    'PKR',
    'USD',
    'EUR',
    'GBP',
    'JPY',
    'CAD',
    'AUD',
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthBloc>().state.user;
    if (user.isNotEmpty) {
      _incomeCtrl.text = user.monthlyIncome?.toStringAsFixed(0) ?? '';
      _selectedCurrency = user.currency ?? 'PKR';
    }
  }

  @override
  void dispose() {
    _incomeCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final income = double.tryParse(_incomeCtrl.text.trim());

    context.read<AuthBloc>().add(
      AuthFinancialProfileUpdated(
        monthlyIncome: income,
        currency: _selectedCurrency,
      ),
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Financial Profile Updated')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : const Color(0xFF101828),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Financial Profile',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Set up your financial basics to help Penny provide better insights and budgeting tools.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.textOnDarkMuted
                    : AppColors.textOnLightMuted,
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'Monthly Income',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _incomeCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? const Color(0xFF131A21) : Colors.white,
                hintText: 'e.g. 50000',
                prefixIcon: const Icon(
                  Icons.monetization_on_rounded,
                  color: AppColors.neon,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: isDark
                        ? const Color(0xFF1E272E)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.neon),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Currency',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131A21) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF1E272E)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCurrency,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.neon,
                  ),
                  items: _currencies
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(
                            c,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedCurrency = v);
                  },
                ),
              ),
            ),

            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neon,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                  shadowColor: AppColors.neon.withOpacity(0.4),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
