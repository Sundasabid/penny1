import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../domain/repositories/receipt_repository.dart';
import '../../bloc/category/category_bloc.dart';
import '../../bloc/category/category_state.dart';
import '../../../config/themes/app_colors.dart';

enum ScanStage { idle, processing, review, error }

class ScanReceiptPage extends StatefulWidget {
  const ScanReceiptPage({super.key});

  @override
  State<ScanReceiptPage> createState() => _ScanReceiptPageState();
}

class _ScanReceiptPageState extends State<ScanReceiptPage> with SingleTickerProviderStateMixin {
  ScanStage _stage = ScanStage.idle;
  String? _imagePath;
  String? _error;

  // Extracted Data (Editable)
  final TextEditingController _merchantController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _selectedCategory = 'other';
  DateTime _selectedDate = DateTime.now();

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _merchantController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    final repo = context.read<ReceiptRepository>();
    final categoryBloc = context.read<CategoryBloc>();
    
    // 1. Pick/Scan Image
    try {
      final imagePath = await repo.pickReceiptImage();
      if (imagePath.isEmpty) return;
      
      _imagePath = imagePath;
      setState(() {
        _stage = ScanStage.processing;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _stage = ScanStage.error;
        _error = e.toString();
      });
      return;
    }

    // 2. AI Extraction
    try {
      final categories = categoryBloc.state.categories;
      final categoryNames = categories.map((c) => c.name).toList();
      
      final data = await repo.extractDetailsWithAI(_imagePath!, categoryNames);
      
      if (!mounted) return;

      // Map results to controllers for Review Stage
      final rawAmount = data['amount'] ?? data['totalAmount'] ?? 0.0;
      _merchantController.text = data['merchantName'] ?? 'Unknown';
      _amountController.text = (rawAmount is num) ? rawAmount.toString() : '0.0';
      _selectedCategory = data['category'] ?? 'other';
      
      if (data['date'] != null) {
        try {
          _selectedDate = DateTime.parse(data['date']);
        } catch (_) {
          _selectedDate = DateTime.now();
        }
      }

      setState(() => _stage = ScanStage.review);

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _stage = ScanStage.error;
        _error = "Penny couldn't read the receipt: $e";
      });
    }
  }

  void _onConfirm() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    
    Navigator.of(context).pop({
      'imagePath': _imagePath,
      'merchantName': _merchantController.text.trim(),
      'amount': amount,
      'category': _selectedCategory,
      'dateTime': _selectedDate,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _stage == ScanStage.review ? 'REVIEW SCAN' : 'SCAN RECEIPT',
          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: _buildBody(context, isDark),
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isDark) {
    switch (_stage) {
      case ScanStage.idle:
        return _buildIdleState(isDark);
      case ScanStage.processing:
        return _buildProcessingState(isDark);
      case ScanStage.review:
        return _buildReviewState(isDark);
      case ScanStage.error:
        return _buildErrorState(isDark);
    }
  }

  Widget _buildIdleState(bool isDark) {
    return Center(
      key: const ValueKey('idle'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.document_scanner_rounded, size: 100, color: (isDark ? Colors.white : Colors.black).withOpacity(0.05)),
          const SizedBox(height: 48),
          _ActionButton(
            label: 'SNAP RECEIPT',
            icon: Icons.camera_alt_rounded,
            onPressed: _scan,
            isPrimary: true,
          ),
          const SizedBox(height: 16),
          Text(
            "Printed or Handwritten",
            style: TextStyle(color: (isDark ? Colors.white : Colors.black).withOpacity(0.3), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingState(bool isDark) {
    return Center(
      key: const ValueKey('processing'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.neon.withOpacity(0.2 + (0.3 * _pulseController.value)), width: 2),
                  boxShadow: [
                    BoxShadow(color: AppColors.neon.withOpacity(0.15 * _pulseController.value), blurRadius: 40, spreadRadius: 10)
                  ]
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: AppColors.neon, size: 48),
              );
            }
          ),
          const SizedBox(height: 32),
          const Text(
            "PENNY IS READING...",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 2, color: AppColors.neon),
          ),
          const SizedBox(height: 8),
          Text(
            "Scanning handwriting & structure",
            style: TextStyle(color: (isDark ? Colors.white : Colors.black).withOpacity(0.4), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewState(bool isDark) {
    return SingleChildScrollView(
      key: const ValueKey('review'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Receipt Preview
          if (_imagePath != null)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                image: DecorationImage(
                  image: FileImage(File(_imagePath!)),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                      ),
                    ),
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.all(16),
                    child: const Text(
                      "ORIGINAL SCAN",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 32),
          
          Text("MERCHANT", style: _labelStyle(isDark)),
          const SizedBox(height: 8),
          _buildTextField(controller: _merchantController, hint: "Where did you spend?", isDark: isDark),
          
          const SizedBox(height: 24),
          Text("AMOUNT (PKR)", style: _labelStyle(isDark)),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _amountController, 
            hint: "0.00", 
            isDark: isDark, 
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.neon),
          ),

          const SizedBox(height: 24),
          Text("CATEGORY", style: _labelStyle(isDark)),
          const SizedBox(height: 12),
          _buildCategoryPicker(isDark),

          const SizedBox(height: 24),
          Text("DATE", style: _labelStyle(isDark)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => _selectedDate = picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131A21) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_month_rounded, size: 20, color: (isDark ? Colors.white : Colors.black).withOpacity(0.4)),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                    style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 48),
          _ActionButton(
            label: 'CONFIRM & LOG',
            icon: Icons.check_circle_rounded,
            onPressed: _onConfirm,
            isPrimary: true,
            fullWidth: true,
          ),
          const SizedBox(height: 12),
          _ActionButton(
            label: 'RE-SCAN',
            icon: Icons.refresh_rounded,
            onPressed: _scan,
            isPrimary: false,
            fullWidth: true,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      key: const ValueKey('error'),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 64),
            const SizedBox(height: 24),
            Text(
              "OOPS!",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: isDark ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 12),
            Text(
              _error ?? "Something went wrong while reading the receipt.",
              textAlign: TextAlign.center,
              style: TextStyle(color: (isDark ? Colors.white : Colors.black).withOpacity(0.6)),
            ),
            const SizedBox(height: 32),
            _ActionButton(
              label: 'TRY AGAIN',
              icon: Icons.refresh_rounded,
              onPressed: _scan,
              isPrimary: true,
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _labelStyle(bool isDark) => TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 12,
    letterSpacing: 1,
    color: (isDark ? Colors.white : Colors.black).withOpacity(0.4),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    TextInputType? keyboardType,
    TextStyle? style,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: style ?? TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: isDark ? const Color(0xFF131A21) : const Color(0xFFF1F5F9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }

  Widget _buildCategoryPicker(bool isDark) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        final categories = state.categories;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((cat) {
            final isSelected = _selectedCategory.toLowerCase() == cat.name.toLowerCase();
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat.name),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.neon : (isDark ? const Color(0xFF131A21) : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.neon : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                    width: 1,
                  ),
                ),
                child: Text(
                  cat.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: isSelected ? Colors.black : (isDark ? Colors.white70 : Colors.black54),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool fullWidth;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final btn = ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        backgroundColor: isPrimary 
            ? (isDark ? Colors.white : Colors.black) 
            : Colors.transparent,
        foregroundColor: isPrimary 
            ? (isDark ? Colors.black : Colors.white) 
            : (isDark ? Colors.white70 : Colors.black54),
        elevation: isPrimary ? 4 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: isPrimary ? BorderSide.none : BorderSide(color: isDark ? Colors.white24 : Colors.black12),
        ),
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}
