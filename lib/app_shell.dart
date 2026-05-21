// lib/app_shell.dart
import 'package:app/presentation/pages/Dashboard/dashboard.dart';
import 'package:app/presentation/pages/add_expense.dart';
import 'package:app/presentation/pages/profile/profile_page.dart';
import 'package:app/presentation/pages/insights/insights_page.dart';
import 'package:app/presentation/pages/copilot/copilot_page.dart';
import 'package:flutter/material.dart';

import 'core/widgets/bottom navigation/app_bottom_nav.dart';
import 'core/widgets/buttons/expandable_fab.dart';
import 'presentation/pages/receipts/scan_receipt_page.dart';
import 'presentation/pages/receipts/receipts_gallery_page.dart';
import 'core/utils/receipt_process_helper.dart';
import 'presentation/bloc/transaction_bloc.dart';
import 'presentation/bloc/transaction_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state.addSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Transaction Logged!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Error: ${state.errorMessage}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SafeArea(
          child: IndexedStack(
            index: _index,
            children: const [
              DashboardPage(), // 0 → Home
              ReceiptsGalleryPage(), // 1 → Receipts
              CopilotPage(), // 2 → Co-Pilot
              InsightsPage(), // 3 → Insights
              ProfilePage(), // 4 → Profile
            ],
          ),
        ),
      ),
      floatingActionButton: (_index == 0)
          ? AddTransactionFab(
              onManualEntry: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddExpensePage()),
                );
              },
              onScanReceipt: () async {
                final result = await Navigator.of(context).push<Map<String, dynamic>>(
                  MaterialPageRoute(builder: (_) => const ScanReceiptPage()),
                );
                if (result != null && context.mounted) {
                  ReceiptProcessHelper.processScanResult(context, result);
                }
              },
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
