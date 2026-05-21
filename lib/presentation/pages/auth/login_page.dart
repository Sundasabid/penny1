import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/themes/app_colors.dart';
import '../../../core/services/settings_service.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import 'signup_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill last used email
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = context.read<SettingsService>();
      final lastEmail = settings.getLastEmail();
      if (lastEmail != null && lastEmail.isNotEmpty) {
        _emailController.text = lastEmail;
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          // Background Poly Pattern (Simulated with CustomPainter)
          Positioned.fill(
            child: CustomPaint(painter: _PolyBackgroundPainter()),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // App Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C252E),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neon.withOpacity(0.2),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppColors.neon,
                      size: 60,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title
                  Text(
                    "PENNY",
                    style: textTheme.headlineLarge?.copyWith(
                      color: AppColors.neon,
                      letterSpacing: 4,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    "Your personal finance companion.",
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.textOnDarkMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Form Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131A21),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFF1E272E)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label("Email", context),
                        _inputField(
                          hint: "name@example.com",
                          icon: Icons.email_rounded,
                          controller: _emailController,
                        ),
                        const SizedBox(height: 24),
                        _label("Password", context),
                        _inputField(
                          hint: "••••••••••••",
                          icon: Icons.lock_rounded,
                          isPassword: true,
                          controller: _passwordController,
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: AppColors.neon,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: BlocConsumer<AuthBloc, AuthState>(
                            listener: (context, state) {
                              if (state.status == AuthStatus.error) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      state.errorMessage ?? 'Error',
                                    ),
                                  ),
                                );
                              }
                            },
                            builder: (context, state) {
                              if (state.status == AuthStatus.loading) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.neon,
                                  ),
                                );
                              }
                              return ElevatedButton(
                                onPressed: () {
                                  final email = _emailController.text.trim();
                                  final password = _passwordController.text;
                                  if (email.isEmpty || password.isEmpty) {
                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please enter both email and password.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  context.read<AuthBloc>().add(
                                    AuthLoginRequested(email, password),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.neon,
                                  shadowColor: AppColors.neon.withOpacity(0.4),
                                  elevation: 12,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: const Text("Continue"),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                "Or continue with",
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.textOnDarkMuted,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Google Login
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.1),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              backgroundColor: const Color(0xFF1C252E),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.g_mobiledata_rounded,
                                  size: 32,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Google Account",
                                  style: textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textOnDarkMuted,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignupScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            color: AppColors.neon,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _label(String text, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textOnDarkMuted,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _inputField({
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 22),

        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              )
            : null,
      ),
    );
  }
}

class _PolyBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path();

    // Simple poly line pattern
    for (var i = 0; i < size.width; i += 40) {
      path.moveTo(i.toDouble(), 0);
      path.lineTo(size.width, size.height - i);

      path.moveTo(0, i.toDouble());
      path.lineTo(size.width - i, size.height);
    }

    canvas.drawPath(path, paint);

    // Add a dark overlay gradient
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = RadialGradient(
      center: const Alignment(0, -0.5),
      radius: 1.2,
      colors: [AppColors.neon.withOpacity(0.05), Colors.transparent],
    );
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
