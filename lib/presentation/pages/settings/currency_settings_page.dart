// lib/presentation/pages/settings/currency_settings_page.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/themes/app_colors.dart';
import '../../../core/utils/currency_helper.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';

class CurrencySettingsPage extends StatefulWidget {
  const CurrencySettingsPage({super.key});

  @override
  State<CurrencySettingsPage> createState() => _CurrencySettingsPageState();
}

class _CurrencySettingsPageState extends State<CurrencySettingsPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final allCurrencies = CurrencyHelper.getSupportedCurrencies();
    
    final filtered = allCurrencies.where((c) {
      final name = CurrencyHelper.getName(c).toLowerCase();
      final code = c.toLowerCase();
      return name.contains(_query) || code.contains(_query);
    }).toList();

    final userCurrency = context.select((AuthBloc bloc) => bloc.state.user.currency ?? 'PKR');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Subtle Ambient Glow
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neon.withOpacity(0.04),
              ),
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                floating: true,
                pinned: true,
                backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.7),
                elevation: 0,
                flexibleSpace: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Text(
                        'CURRENCY',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // Search Bar - Sleek & Compact
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: TextField(
                        controller: _searchCtrl,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search currencies...',
                          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.neon, size: 20),
                          filled: true,
                          fillColor: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: AppColors.neon.withOpacity(0.5)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              filtered.isEmpty 
                ? const SliverFillRemaining(
                    child: Center(
                      child: Text("No matches found", style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final code = filtered[index];
                          final isSelected = code == userCurrency;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _UltraSlimCurrencyCard(
                              code: code,
                              isSelected: isSelected,
                              onTap: () {
                                context.read<AuthBloc>().add(
                                  AuthFinancialProfileUpdated(currency: code),
                                );
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                        childCount: filtered.length,
                      ),
                    ),
                  ),
              const SliverToBoxAdapter(child: SizedBox(height: 50)),
            ],
          ),
        ],
      ),
    );
  }
}

class _UltraSlimCurrencyCard extends StatelessWidget {
  final String code;
  final bool isSelected;
  final VoidCallback onTap;

  const _UltraSlimCurrencyCard({
    required this.code,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final symbol = CurrencyHelper.getSymbol(code);
    final name = CurrencyHelper.getName(code);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected 
            ? AppColors.neon.withOpacity(0.08)
            : (isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.02)),
          border: Border.all(
            color: isSelected 
              ? AppColors.neon.withOpacity(0.6) 
              : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.neon : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  symbol,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    code,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF101828),
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white38 : Colors.black38,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.circle, color: AppColors.neon, size: 8),
          ],
        ),
      ),
    );
  }
}
