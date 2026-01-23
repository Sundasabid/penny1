import 'package:app/presentation/pages/auth/login_page.dart';
import 'package:app/presentation/pages/receipts/receipts_gallery_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/themes/app_theme.dart';
import 'data/data_sources/local/local_data_source.dart';
import 'data/data_sources/remote/firestore_source.dart';
import 'data/repositories/transaction_repository_impl.dart';
import 'domain/usecases/ transaction/add_transaction.dart';
import 'domain/usecases/ transaction/get_transactions.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PennyApp());
}

class PennyApp extends StatelessWidget {
  const PennyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Penny',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,      // ✅ your light theme
      darkTheme: AppTheme.dark,   // optional
      themeMode: ThemeMode.light, // or system
      // home: const LoginScreen(),
      //✅ your login screen
      home: ReceiptsGalleryPage(),
    );
  }
}
