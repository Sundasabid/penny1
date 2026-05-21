import 'package:flutter/material.dart';
import '../../../../config/themes/app_colors.dart';

class AddPurchaseSheet extends StatefulWidget {
  final Function(String name, double amount, DateTime targetDate) onAdd;
  const AddPurchaseSheet({super.key, required this.onAdd});

  @override
  State<AddPurchaseSheet> createState() => _AddPurchaseSheetState();
}

class _AddPurchaseSheetState extends State<AddPurchaseSheet> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _targetDate = DateTime.now().add(const Duration(days: 30));

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Plan a Purchase',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Penny will analyze your finances and create a savings plan.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 28),

            // Name field
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'What do you want to buy?',
                hintText: 'e.g., iPhone 16, Vacation, PS5',
                prefixIcon: const Icon(Icons.shopping_bag_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                filled: true,
                fillColor: isDark ? AppColors.darkCard : const Color(0xFFF8FAFC),
              ),
            ),
            const SizedBox(height: 16),

            // Amount field
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'How much does it cost?',
                hintText: 'Amount in PKR',
                prefixIcon: const Icon(Icons.payments_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                filled: true,
                fillColor: isDark ? AppColors.darkCard : const Color(0xFFF8FAFC),
              ),
            ),
            const SizedBox(height: 16),

            // Date picker
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _targetDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _targetDate = picked);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFD0D5DD)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Target: ${_targetDate.day}/${_targetDate.month}/${_targetDate.year}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Submit
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final name = _nameController.text.trim();
                  final amount = double.tryParse(_amountController.text.trim());
                  if (name.isEmpty || amount == null || amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill in all fields correctly.')),
                    );
                    return;
                  }
                  widget.onAdd(name, amount, _targetDate);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neon,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Ask Penny for a Plan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
