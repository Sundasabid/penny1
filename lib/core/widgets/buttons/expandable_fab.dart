import 'package:flutter/material.dart';

class AddTransactionFab extends StatelessWidget {
  const AddTransactionFab({
    super.key,
    required this.onManualEntry,
    required this.onScanReceipt,
  });

  final VoidCallback onManualEntry;
  final VoidCallback onScanReceipt;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: const Color(0xFF18B27A),
      elevation: 10,
      onPressed: () async {
        final action = await showModalBottomSheet<_FabAction>(
          context: context,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) => const _FabSheet(),
        );

        if (action == _FabAction.manual) onManualEntry();
        if (action == _FabAction.receipt) onScanReceipt();
      },
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}

enum _FabAction { manual, receipt }

class _FabSheet extends StatelessWidget {
  const _FabSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFE6E8EC),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 14),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Add transaction',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF101828),
                ),
              ),
            ),
            const SizedBox(height: 12),

            _ActionTile(
              icon: Icons.edit_note,
              title: 'Manual entry',
              subtitle: 'Add expense/income manually',
              onTap: () => Navigator.pop(context, _FabAction.manual),
            ),
            const SizedBox(height: 8),
            _ActionTile(
              icon: Icons.receipt_long,
              title: 'Scan receipt',
              subtitle: 'Create transaction from receipt',
              onTap: () => Navigator.pop(context, _FabAction.receipt),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE6E8EC)),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE7F6EE),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF18B27A)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF101828),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF98A2B3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
