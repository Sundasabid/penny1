import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../../../config/themes/app_colors.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../domain/entities/subscription.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/category/category_bloc.dart';
import '../../bloc/subscription/subscription_bloc.dart';
import '../../bloc/subscription/subscription_event.dart';

class AddSubscriptionPage extends StatefulWidget {
  const AddSubscriptionPage({super.key});

  @override
  State<AddSubscriptionPage> createState() => _AddSubscriptionPageState();
}

class _AddSubscriptionPageState extends State<AddSubscriptionPage> {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  BillingCycle _selectedCycle = BillingCycle.monthly;
  String? _selectedCategory; // Nullable so we can set it dynamically if empty

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _submit(String fallbackCategory) {
    final name = _nameCtrl.text.trim();
    final amountText = _amountCtrl.text.trim();
    final amount = double.tryParse(amountText) ?? 0.0;

    if (name.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter valid details!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final sub = SubscriptionEntity(
      id: const Uuid().v4(),
      name: name,
      amount: amount,
      nextDueDate: _selectedDate,
      cycle: _selectedCycle,
      category: _selectedCategory ?? fallbackCategory,
    );

    context.read<SubscriptionBloc>().add(AddSubscriptionRequested(sub));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthBloc>().state.user;
    final symbol = CurrencyHelper.getSymbol(user.currency);
    
    final categoryState = context.watch<CategoryBloc>().state;
    List<String> dynamicCategories = categoryState.categories.map((c) => c.name).toList();
    if (dynamicCategories.isEmpty) dynamicCategories.add('Utilities'); // Fallback

    if (_selectedCategory == null || !dynamicCategories.contains(_selectedCategory)) {
       _selectedCategory = dynamicCategories.first;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          'NEW RADAR ITEM',
          style: TextStyle(
            letterSpacing: 2,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background ambient glows
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neon.withOpacity(0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purpleAccent.withOpacity(0.1),
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(color: Colors.transparent),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  // Massive Amount Input
                  Center(
                    child: Column(
                      children: [
                        Text('AMOUNT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: (isDark ? Colors.white : Colors.black).withOpacity(0.4))),
                        const SizedBox(height: 8),
                        IntrinsicWidth(
                          child: TextField(
                            controller: _amountCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w900,
                              color: AppColors.neon,
                              letterSpacing: -2,
                            ),
                            decoration: InputDecoration(
                              hintText: '0.00',
                              hintStyle: TextStyle(color: AppColors.neon.withOpacity(0.3)),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              prefixText: '$symbol ',
                              prefixStyle: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.neon.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 48),

                  // Neumorphic Input Form
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withOpacity(isDark ? 0.4 : 1.0),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.05)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildCustomField(
                          icon: Icons.subscriptions_rounded,
                          label: 'Service Name',
                          child: TextField(
                            controller: _nameCtrl,
                            style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black),
                            decoration: const InputDecoration(
                              hintText: 'e.g., Netflix, Spotify',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                          ),
                        ),
                        
                        _buildDivider(),
                        
                        _buildCustomField(
                          icon: Icons.autorenew_rounded,
                          label: 'Billing Cycle',
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<BillingCycle>(
                              value: _selectedCycle,
                              dropdownColor: Theme.of(context).cardColor,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded),
                              style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black, fontSize: 16),
                              items: BillingCycle.values.map((c) {
                                return DropdownMenuItem(
                                  value: c,
                                  child: Text(c.name.toUpperCase()),
                                );
                              }).toList(),
                              onChanged: (v) {
                                if (v != null) setState(() => _selectedCycle = v);
                              },
                            ),
                          ),
                        ),
                        
                        _buildDivider(),
                        
                        _buildCustomField(
                          icon: Icons.category_rounded,
                          label: 'Category',
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCategory,
                              dropdownColor: Theme.of(context).cardColor,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded),
                              style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black, fontSize: 16),
                              items: dynamicCategories.map((c) {
                                return DropdownMenuItem(value: c, child: Text(c));
                              }).toList(),
                              onChanged: (v) {
                                if (v != null) setState(() => _selectedCategory = v);
                              },
                            ),
                          ),
                        ),

                        _buildDivider(),

                        GestureDetector(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime.now().subtract(const Duration(days: 30)),
                              lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                            );
                            if (date != null) setState(() => _selectedDate = date);
                          },
                          child: Container(
                            color: Colors.transparent, // Ensures the whole row is clickable
                            child: _buildCustomField(
                              icon: Icons.calendar_month_rounded,
                              label: 'Next Due Date',
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  DateFormat('MMM dd, yyyy').format(_selectedDate),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Glowing Action Button
                  GestureDetector(
                    onTap: () => _submit(dynamicCategories.first),
                    child: Container(
                      width: double.infinity,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.neon, Color(0xFF00FF88)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neon.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.radar_rounded, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'ACTIVATE RADAR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(color: Theme.of(context).dividerColor.withOpacity(0.1), height: 1),
    );
  }

  Widget _buildCustomField({required IconData icon, required String label, required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.neon.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.neon, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.4),
                  ),
                ),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
