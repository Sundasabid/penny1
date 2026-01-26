import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/receipt/receipt_bloc.dart';
import '../../bloc/receipt/receipt_event.dart';
import '../../bloc/receipt/receipt_state.dart';

import '../../bloc/transaction_bloc.dart';
import '../../bloc/transaction_event.dart';

import '../../../domain/entities/transaction.dart';

import 'scan_receipt_page.dart';
import 'receipt_detail_page.dart';

class ReceiptsGalleryPage extends StatefulWidget {
  const ReceiptsGalleryPage({super.key});

  @override
  State<ReceiptsGalleryPage> createState() => _ReceiptsGalleryPageState();
}

class _ReceiptsGalleryPageState extends State<ReceiptsGalleryPage> {
  @override
  void initState() {
    super.initState();
    context.read<ReceiptBloc>().add(GetReceiptsRequested());
  }

  Future<void> _openScanner() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => const ScanReceiptPage()),
    );
    if (!mounted || result == null) return;

    final receiptId = DateTime.now().millisecondsSinceEpoch.toString();
    final imagePath = result['imagePath'] as String;
    final merchantName = (result['merchantName'] as String?)?.trim().isNotEmpty == true
        ? (result['merchantName'] as String)
        : 'Unknown Merchant';
    final amount = (result['amount'] as num?)?.toDouble() ?? 0.0;
    final category = (result['category'] as String?)?.trim().isNotEmpty == true
        ? (result['category'] as String)
        : 'other';
    final dateTime = (result['dateTime'] as DateTime?) ?? DateTime.now();

    // Save receipt (gallery)
    context.read<ReceiptBloc>().add(
      SaveReceiptRequested(
        receiptId: receiptId,
        imagePath: imagePath,
        merchantName: merchantName,
        amount: amount,
        category: category,
        dateTime: dateTime,
      ),
    );

    // Save transaction (history) — manual code untouched
    context.read<TransactionBloc>().add(
      AddTransactionRequested(
        TransactionEntity(
          id: 'tx_$receiptId',
          merchant: merchantName,
          category: category,
          amount: amount,
          dateTime: dateTime,
          paymentMethod: 'Cash',
          isIncome: false,
          source: TransactionSource.receipt,
          receiptId: receiptId,
        ),
      ),
    );

    // Refresh
    context.read<ReceiptBloc>().add(GetReceiptsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FB),
        surfaceTintColor: const Color(0xFFF7F8FB),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0B1220)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Receipts',
          style: TextStyle(
            color: Color(0xFF0B1220),
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => context.read<ReceiptBloc>().add(GetReceiptsRequested()),
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0B1220)),
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: _PennyFab(onTap: _openScanner),
      body: SafeArea(
        child: BlocBuilder<ReceiptBloc, ReceiptState>(
          builder: (context, state) {
            if (state is ReceiptLoading) {
              return const _LoadingGrid();
            }

            if (state is ReceiptFailure) {
              return _ErrorState(
                message: state.message,
                onRetry: () => context.read<ReceiptBloc>().add(GetReceiptsRequested()),
              );
            }

            if (state is ReceiptsLoaded) {
              final receipts = state.receipts;

              if (receipts.isEmpty) {
                return _EmptyGallery(onScan: _openScanner);
              }

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: _HeaderStats(
                        count: receipts.length,
                        total: receipts.fold<double>(0, (sum, r) => sum + (r.amount as num).toDouble()),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.78,
                      ),
                      delegate: SliverChildBuilderDelegate(
                            (context, i) => _ReceiptCard(
                          receipt: receipts[i],
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ReceiptDetailPage(receipt: receipts[i]),
                              ),
                            );
                          },
                        ),
                        childCount: receipts.length,
                      ),
                    ),
                  ),
                ],
              );
            }

            return _EmptyGallery(onScan: _openScanner);
          },
        ),
      ),
    );
  }
}

/// ---------- UI BUILDING BLOCKS ----------

class _ReceiptCard extends StatelessWidget {
  final dynamic receipt; // ReceiptEntity type in your project
  final VoidCallback onTap;

  const _ReceiptCard({
    required this.receipt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final merchant = (receipt.merchantName as String?) ?? 'Unknown';
    final category = (receipt.category as String?) ?? 'other';
    final amount = (receipt.amount as num?)?.toDouble() ?? 0.0;
    final dt = receipt.dateTime as DateTime;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      File(receipt.imagePath as String),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFF1F5F9),
                        child: const Center(
                          child: Icon(Icons.receipt_long, size: 42, color: Color(0xFF94A3B8)),
                        ),
                      ),
                    ),

                    // subtle overlay for legibility
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.04),
                            Colors.black.withOpacity(0.30),
                          ],
                        ),
                      ),
                    ),

                    // Category chip
                    Positioned(
                      left: 10,
                      top: 10,
                      child: _CategoryChip(category: category),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      merchant,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0B1220),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM d • h:mm a').format(dt),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.payments_rounded, size: 16, color: Color(0xFF0E9F6E)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'PKR ${_fmtMoney(amount)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0E9F6E),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String category;
  const _CategoryChip({required this.category});

  IconData _iconFor(String c) {
    switch (c.toLowerCase()) {
      case 'grocery':
        return Icons.local_grocery_store_rounded;
      case 'transport':
        return Icons.local_gas_station_rounded;
      case 'dining':
        return Icons.restaurant_rounded;
      case 'bills':
        return Icons.receipt_rounded;
      case 'health':
        return Icons.medical_services_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_iconFor(category), size: 16, color: const Color(0xFF0B1220)),
          const SizedBox(width: 6),
          Text(
            category,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0B1220),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderStats extends StatelessWidget {
  final int count;
  final double total;

  const _HeaderStats({required this.count, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Receipts',
            value: '$count',
            icon: Icons.receipt_long_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Total Spend',
            value: 'PKR ${_fmtMoney(total)}',
            icon: Icons.payments_rounded,
            accent: const Color(0xFF0E9F6E),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? accent;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final a = accent ?? const Color(0xFF111827);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: a.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: a),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF0B1220),
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyGallery extends StatelessWidget {
  final VoidCallback onScan;
  const _EmptyGallery({required this.onScan});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: const Color(0xFF0E9F6E).withOpacity(0.12),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.receipt_long_rounded, size: 42, color: Color(0xFF0E9F6E)),
            ),
            const SizedBox(height: 14),
            const Text(
              'No receipts yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0B1220),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Scan your first receipt and PENNY will\nextract merchant, amount, and category.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: onScan,
              icon: const Icon(Icons.document_scanner_rounded),
              label: const Text('Scan Receipt'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E9F6E),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 46, color: Color(0xFFEF4444)),
            const SizedBox(height: 10),
            const Text(
              'Something went wrong',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E9F6E),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.78,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
      ),
    );
  }
}

class _PennyFab extends StatelessWidget {
  final VoidCallback onTap;
  const _PennyFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      backgroundColor: const Color(0xFF0E9F6E),
      foregroundColor: Colors.white,
      elevation: 2,
      onPressed: onTap,
      icon: const Icon(Icons.add_rounded),
      label: const Text(
        'Scan',
        style: TextStyle(fontWeight: FontWeight.w900),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}

String _fmtMoney(num v) {
  final n = v.round();
  final s = n.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final idxFromEnd = s.length - i;
    buf.write(s[i]);
    if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write(',');
  }
  return buf.toString();
}
