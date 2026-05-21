import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../domain/entities/vault.dart';
import '../../bloc/vault/vault_bloc.dart';
import '../../bloc/vault/vault_event.dart';

class CreateVaultPage extends StatefulWidget {
  const CreateVaultPage({super.key});

  @override
  State<CreateVaultPage> createState() => _CreateVaultPageState();
}

class _CreateVaultPageState extends State<CreateVaultPage> {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

  String _selectedColor = '#00E5FF'; // Default neon Cyan

  final List<String> _colors = [
    '#00E5FF', // Cyan
    '#FF00FF', // Magenta
    '#00FF88', // Green
    '#FFD700', // Gold
    '#FF3366', // Red/Pink
    '#8A2BE2', // Purple
  ];

  void _submit() {
    final name = _nameCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0.0;

    if (name.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter valid vault details!'),
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final newVault = VaultEntity(
      id: const Uuid().v4(),
      name: name,
      targetAmount: amount,
      savedAmount: 0.0,
      colorHex: _selectedColor,
      iconName: 'savings',
      createdAt: DateTime.now(),
    );

    context.read<VaultBloc>().add(AddVaultRequested(newVault));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'NEW VAULT',
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
                color: _colorFromHex(_selectedColor).withOpacity(0.15),
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
                   Center(
                    child: Column(
                      children: [
                        Text('GOAL AMOUNT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: (isDark ? Colors.white : Colors.black).withOpacity(0.4))),
                        const SizedBox(height: 8),
                        IntrinsicWidth(
                          child: TextField(
                            controller: _amountCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w900,
                              color: _colorFromHex(_selectedColor),
                              letterSpacing: -2,
                            ),
                            decoration: InputDecoration(
                              hintText: '0.00',
                              hintStyle: TextStyle(color: _colorFromHex(_selectedColor).withOpacity(0.3)),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withOpacity(isDark ? 0.4 : 1.0),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.05)),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VAULT NAME',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: (isDark ? Colors.white : Colors.black).withOpacity(0.4),
                          ),
                        ),
                        TextField(
                          controller: _nameCtrl,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : Colors.black),
                          decoration: const InputDecoration(
                            hintText: 'e.g., Japan Trip, New Car',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                          ),
                        ),
                        
                        Divider(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                        const SizedBox(height: 16),

                        Text(
                          'VAULT COLOR',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: (isDark ? Colors.white : Colors.black).withOpacity(0.4),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: _colors.map((c) {
                              final isSelected = c == _selectedColor;
                              final color = _colorFromHex(c);
                              return GestureDetector(
                                onTap: () => setState(() => _selectedColor = c),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.only(right: 16),
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(isSelected ? 0.2 : 0.1),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? color : Colors.transparent,
                                      width: 2,
                                    ),
                                    boxShadow: isSelected
                                        ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10)]
                                        : [],
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  GestureDetector(
                    onTap: _submit,
                    child: Container(
                      width: double.infinity,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _colorFromHex(_selectedColor)),
                        boxShadow: [
                          BoxShadow(
                            color: _colorFromHex(_selectedColor).withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'CONSTRUCT VAULT',
                          style: TextStyle(
                            color: _colorFromHex(_selectedColor),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorFromHex(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
