import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Adjust import to your entity location:
import '../../../domain/entities/receipt.dart';


class ReceiptDetailPage extends StatelessWidget {
  final ReceiptEntity receipt;

  const ReceiptDetailPage({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, yyyy • h:mm a').format(receipt.dateTime);

    return Scaffold(
      appBar: AppBar(title: const Text('Receipt Detail')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(
              File(receipt.imagePath),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 220,
                color: const Color(0xFFF3F4F6),
                child: const Center(
                  child: Icon(Icons.receipt_long, size: 48, color: Color(0xFF9CA3AF)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            receipt.merchantName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(dateStr, style: const TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Category: ${receipt.category}', style: const TextStyle(fontWeight: FontWeight.w700)),
              Text('PKR ${receipt.amount}', style: const TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }
}
