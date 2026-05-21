import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/receipt/receipt_bloc.dart';
import '../../bloc/receipt/receipt_event.dart';
import '../../bloc/receipt/receipt_state.dart';

import '../../../config/themes/app_colors.dart';
import '../../../core/utils/receipt_process_helper.dart';

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
    if (result != null && mounted) {
      ReceiptProcessHelper.processScanResult(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : const Color(0xFF0B1220),
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Receipts',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF0B1220),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () =>
                context.read<ReceiptBloc>().add(GetReceiptsRequested()),
            icon: Icon(
              Icons.refresh_rounded,
              color: isDark ? Colors.white : const Color(0xFF0B1220),
            ),
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
                onRetry: () =>
                    context.read<ReceiptBloc>().add(GetReceiptsRequested()),
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
                        total: receipts.fold<double>(
                          0,
                          (sum, r) => sum + (r.amount as num).toDouble(),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                             crossAxisCount: 2,
                             crossAxisSpacing: 16,
                             mainAxisSpacing: 16,
                             childAspectRatio: 0.78,
                           ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => _ReceiptCard(
                          receipt: receipts[i],
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    ReceiptDetailPage(receipt: receipts[i]),
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

class _ReceiptCard extends StatelessWidget {
  final dynamic receipt;
  final VoidCallback onTap;

  const _ReceiptCard({required this.receipt, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final merchant = (receipt.merchantName as String?) ?? 'Unknown';
    final category = (receipt.category as String?) ?? 'other';
    final amount = (receipt.amount as num?)?.toDouble() ?? 0.0;
    final dt = receipt.dateTime as DateTime;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131A21) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF1E272E) : const Color(0xFFE2E8F0),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(21),
                topRight: Radius.circular(21),
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
                        color: isDark
                            ? const Color(0xFF1C252E)
                            : const Color(0xFFF1F5F9),
                        child: Icon(
                          Icons.receipt_long_rounded,
                          size: 42,
                          color: isDark ? Colors.white24 : Colors.black12,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.0),
                            Colors.black.withOpacity(0.4),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      top: 10,
                      child: _CategoryChip(category: category),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      merchant,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM d • h:mm a').format(dt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.textOnDarkMuted
                            : AppColors.textOnLightMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'PKR ${_fmtMoney(amount)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.neon,
                        letterSpacing: -0.2,
                      ),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF131A21).withOpacity(0.8)
                : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            category.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppColors.neon,
              letterSpacing: 0.5,
            ),
          ),
        ),
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
            value: 'PKR',
            subtitle: _fmtMoney(total),
            icon: Icons.payments_rounded,
            highlight: true,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final bool highlight;

  const _StatCard({
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131A21) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF1E272E) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.neon.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.neon, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppColors.textOnDarkMuted
                  : AppColors.textOnLightMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: highlight
                      ? AppColors.neon
                      : (isDark ? Colors.white : const Color(0xFF0B1220)),
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(width: 4),
                Text(
                  subtitle!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: highlight
                        ? AppColors.neon
                        : (isDark ? Colors.white : const Color(0xFF0B1220)),
                  ),
                ),
              ],
            ],
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.neon.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                size: 40,
                color: AppColors.neon,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Snap your receipts',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No receipts found. Track your spending\nby scanning your physical receipts.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.textOnDarkMuted
                    : AppColors.textOnLightMuted,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onScan,
              icon: const Icon(Icons.add_a_photo_rounded),
              label: const Text('Scan Now'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.danger,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.78,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF131A21)
              : Colors.white,
          borderRadius: BorderRadius.circular(22),
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
      heroTag: 'receipt_gallery_fab',
      backgroundColor: AppColors.neon,
      foregroundColor: Colors.white,
      onPressed: onTap,
      label: const Text(
        'Scan Receipt',
        style: TextStyle(fontWeight: FontWeight.w900),
      ),
      icon: const Icon(Icons.document_scanner_rounded),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
