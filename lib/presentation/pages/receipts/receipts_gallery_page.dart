// lib/presentation/pages/receipts/receipts_gallery_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/receipt/receipt_bloc.dart';


class ReceiptsGalleryPage extends StatefulWidget {
  const ReceiptsGalleryPage({super.key});

  @override
  State<ReceiptsGalleryPage> createState() => _ReceiptsGalleryPageState();
}

class _ReceiptsGalleryPageState extends State<ReceiptsGalleryPage> {
  DateTime _monthCursor = DateTime(DateTime.now().year, DateTime.now().month, 1);

  @override
  void initState() {
    super.initState();
    context.read<ReceiptBloc>().add(const ReceiptsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('MMMM yyyy').format(_monthCursor);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: _RoundIconButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.of(context).maybePop(),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Receipts Gallery',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22, color: Color(0xFF101828)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0B8A5A),
        shape: const CircleBorder(),
        onPressed: () => context.read<ReceiptBloc>().add(const ReceiptScanRequested()),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _MonthPickerPill(
                    label: monthLabel,
                    onPrev: () => setState(() {
                      _monthCursor = DateTime(_monthCursor.year, _monthCursor.month - 1, 1);
                    }),
                    onNext: () => setState(() {
                      _monthCursor = DateTime(_monthCursor.year, _monthCursor.month + 1, 1);
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                _SquareIconButton(
                  icon: Icons.filter_alt_outlined,
                  onTap: () {
                    // hook your filter sheet later
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: BlocBuilder<ReceiptBloc, ReceiptState>(
                builder: (context, state) {
                  final receipts = state.receipts;

                  // Month filter (UI shows month selector like screenshot)
                  final filtered = receipts.where((r) {
                    return r.date.year == _monthCursor.year && r.date.month == _monthCursor.month;
                  }).toList();

                  if (state.status == ReceiptStatus.scanning) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (filtered.isEmpty) {
                    // “Empty first” requirement
                    return const SizedBox.shrink();
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.only(bottom: 96),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.72, // close to screenshot proportions
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _ReceiptCard(receipt: filtered[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  final dynamic receipt; // ReceiptEntity; kept dynamic to match your current imports easily.
  const _ReceiptCard({required this.receipt});

  @override
  Widget build(BuildContext context) {
    final merchant = (receipt.merchant as String?) ?? 'Unknown';
    final amount = (receipt.amount as num?)?.toDouble() ?? 0.0;
    final date = receipt.date as DateTime;
    final timeLabel = DateFormat('MMM d, h:mm a').format(date);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E8EC), width: 1),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              color: const Color(0xFFF2F4F7),
              child: (receipt.imagePath != null && File(receipt.imagePath as String).existsSync())
                  ? Image.file(File(receipt.imagePath as String), fit: BoxFit.cover, width: double.infinity)
                  : const SizedBox.shrink(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 2),
            child: Text(
              merchant,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF101828)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
            child: Text(
              timeLabel,
              style: const TextStyle(fontSize: 14, color: Color(0xFF98A2B3), fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Text(
              'PKR ${_formatPkr(amount)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0B8A5A)),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatPkr(double v) {
    final s = v.toStringAsFixed(0);
    // simple thousand separator
    final chars = s.split('').reversed.toList();
    final out = <String>[];
    for (var i = 0; i < chars.length; i++) {
      if (i != 0 && i % 3 == 0) out.add(',');
      out.add(chars[i]);
    }
    return out.reversed.join();
  }
}

class _MonthPickerPill extends StatelessWidget {
  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _MonthPickerPill({
    required this.label,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE6E8EC)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onPrev,
            icon: const Icon(Icons.chevron_left, color: Color(0xFF667085)),
          ),
          Expanded(
            child: Center(
              child: Text(
                label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF101828)),
              ),
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right, color: Color(0xFF667085)),
          ),
        ],
      ),
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SquareIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 46,
        width: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE6E8EC)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: const Color(0xFF667085)),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        height: 44,
        width: 44,
        decoration: const BoxDecoration(color: Color(0xFFEAF7F0), shape: BoxShape.circle),
        child: Icon(icon, color: const Color(0xFF101828)),
      ),
    );
  }
}
