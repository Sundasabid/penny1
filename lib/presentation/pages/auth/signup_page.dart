import 'package:flutter/material.dart';
import '../../../config/themes/app_colors.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              // 🔰 Top Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.person_add_alt_1_outlined,
                  color: colorScheme.onPrimary,
                  size: 30,
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                "Create Account",
                style: textTheme.headlineLarge,
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                "Sign up to start managing your finances",
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 40),

              // Full Name
              _label("Full Name", context),
              _inputField(
                hint: "Enter your full name",
                icon: Icons.person_outline,
              ),

              const SizedBox(height: 20),

              // Phone Number
              _label("Phone Number", context),
              _inputField(
                hint: "Enter phone number",
                icon: Icons.phone_outlined,
              ),

              const SizedBox(height: 20),

              // Password
              _label("Password", context),
              _inputField(
                hint: "••••",
                icon: Icons.lock_outline,
                isPassword: true,
                isConfirmPassword: false,
              ),

              const SizedBox(height: 20),

              // Confirm Password
              _label("Confirm Password", context),
              _inputField(
                hint: "••••",
                icon: Icons.lock_outline,
                isPassword: true,
                isConfirmPassword: true,
              ),

              const SizedBox(height: 28),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text("Create Account"),
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
                      "Or sign up\nwith",
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

              // Google Button
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

              // Login Redirect
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    "Log In",
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

  // Label (same as Login)
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

  // Input Field (same structure as Login)
  Widget _inputField({
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isConfirmPassword = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final bool obscure = isPassword
        ? (isConfirmPassword ? _obscureConfirmPassword : _obscurePassword)
        : false;

    return TextField(
      obscureText: obscure,
      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withOpacity(0.5),
        ),
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding:
        const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        prefixIcon: Icon(icon, color: colorScheme.onSurface),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: colorScheme.onSurface,
          ),
          onPressed: () {
            setState(() {
              if (isConfirmPassword) {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              } else {
                _obscurePassword = !_obscurePassword;
              }
            });
          },
        )
            : null,
      ),
    );
  }
}
