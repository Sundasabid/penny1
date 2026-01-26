// lib/app_shell.dart
import 'package:app/presentation/pages/Dashboard/dashboard.dart';
import 'package:app/presentation/pages/add_expense.dart';
import 'package:flutter/material.dart';



// Home


// Receipts
import 'core/widgets/bottom navigation/app_bottom_nav.dart';
import 'core/widgets/buttons/expandable_fab.dart';
import 'presentation/pages/receipts/receipts_gallery_page.dart';

// Manual entry page (THIS is your add_expense page)


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
      backgroundColor: const Color(0xFFF7F8FA),

      /// -------------------------------
      /// MAIN TAB CONTENT
      /// -------------------------------
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: const [
            DashboardPage(),        // 0 → Home
            ReceiptsGalleryPage(),  // 1 → Receipts
            _ComingSoonPage(title: 'Analytics'), // 2
            _ComingSoonPage(title: 'Profile'),   // 3
          ],
        ),
      ),

      /// -------------------------------
      /// FLOATING ACTION BUTTON
      /// -------------------------------
      floatingActionButton: _index == 0
          ? AddTransactionFab(
        onManualEntry: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddExpensePage(),
            ),
          );
        },
        onScanReceipt: () {
          // Switch to receipts tab (gallery + scan flow)
          setState(() => _index = 1);
        },
      )
          : null,

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      /// -------------------------------
      /// BOTTOM NAVIGATION
      /// -------------------------------
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

/// ------------------------------------------------
/// TEMP placeholders for tabs not built yet
/// ------------------------------------------------
class _ComingSoonPage extends StatelessWidget {
  const _ComingSoonPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Center(
          child: Text(
            '$title (Coming soon)',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF101828),
            ),
          ),
        ),
      ),
    );
  }
}
