import 'package:app/presentation/pages/auth/login_page.dart';
import 'package:flutter/material.dart';

import 'config/themes/app_theme.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Penny',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,      // ✅ your light theme
      darkTheme: AppTheme.dark,   // optional
      themeMode: ThemeMode.light, // or system
      home: const LoginScreen(),  // ✅ your login screen
    );
  }
}
