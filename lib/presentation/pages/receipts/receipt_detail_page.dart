import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/receipt.dart';
import '../../bloc/receipt/receipt_bloc.dart';
import '../../bloc/receipt/receipt_event.dart';
import '../../../config/themes/app_colors.dart';

class ReceiptDetailPage extends StatelessWidget {
  final ReceiptEntity receipt;

  const ReceiptDetailPage({super.key, required this.receipt});

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Delete Receipt?',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'This will permanently remove the receipt image, delete the transaction from your history, and restore your budget balance.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'CANCEL',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ReceiptBloc>().add(DeleteReceiptRequested(receipt));
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Go back to gallery
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'DELETE',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateStr = DateFormat('EEEE, MMM d, yyyy').format(receipt.dateTime);
    final timeStr = DateFormat('h:mm a').format(receipt.dateTime);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'RECEIPT DETAIL',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            onPressed: () => _showDeleteDialog(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HERO IMAGE
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Image.file(
                  File(receipt.imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: isDark ? const Color(0xFF1C252E) : const Color(0xFFF1F5F9),
                    child: Center(
                      child: Icon(
                        Icons.receipt_long_rounded,
                        size: 64,
                        color: isDark ? Colors.white10 : Colors.black12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // MERCHANT & PRICE
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        receipt.merchantName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_month_rounded, size: 14, color: (isDark ? Colors.white : Colors.black).withOpacity(0.4)),
                          const SizedBox(width: 6),
                          Text(
                            "$dateStr • $timeStr",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: (isDark ? Colors.white : Colors.black).withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.neon.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "AMOUNT",
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, color: AppColors.neon),
                      ),
                      Text(
                        "Rs. ${receipt.amount.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.neon,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // INFO GRID
            _buildDetailRow(
              label: "CATEGORY",
              value: receipt.category,
              icon: Icons.category_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              label: "PAYMENT METHOD",
              value: "CASH",
              icon: Icons.payments_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              label: "SOURCE",
              value: "SMART SCAN",
              icon: Icons.auto_awesome_rounded,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131A21) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: (isDark ? Colors.white : Colors.black).withOpacity(0.3)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.3),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
