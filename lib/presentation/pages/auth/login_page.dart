import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import '../../../config/themes/app_colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background, // from theme
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              const SizedBox(height: 60),

              // 🔰 Top Icon (Finance related)
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: colorScheme.onPrimary,
                  size: 30,
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                "Welcome Back",
                style: textTheme.headlineLarge,
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                "Log in to manage your finances securely",
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 40),

              // Phone Number
              _label("Phone Number", context),
              _inputField(
                hint: "Enter phone number",
                icon: Icons.phone_outlined,
                context: context,
              ),

              const SizedBox(height: 20),

              // Password
              _label("Password", context),
              _inputField(
                hint: "••••",
                icon: Icons.lock_outline,
                suffix: Icons.visibility_outlined,
                obscure: true,
                context: context,
              ),

              const SizedBox(height: 8),

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Forgot Password?",
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.secondary, // theme color
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text("Continue"),
                ),
              ),

              const SizedBox(height: 32),

              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: colorScheme.outline)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      "Or continue\nwith",
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: colorScheme.outline)),
                ],
              ),

              const SizedBox(height: 24),

              // Google Button (uses OutlinedButton theme)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Image.asset(
                          "assets/images/google_logo.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          "Google",
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Sign Up
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    "Sign Up",
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _label(String text, BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  static Widget _inputField({
    required String hint,
    required IconData icon,
    IconData? suffix,
    bool obscure = false,
    required BuildContext context,
  }) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffix != null ? Icon(suffix) : null,
        // styling comes from theme's InputDecorationTheme
      ),
    );
  }
}

