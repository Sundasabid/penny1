import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/themes/app_colors.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final _nameController = TextEditingController();
  final _emailController =
      TextEditingController(); // Reusing phone field for email for now as per UI
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          // Background Poly Pattern
          Positioned.fill(
            child: CustomPaint(painter: _PolyBackgroundPainter()),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 30),

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

                  Text(
                    "Join the elite savers.",
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.textOnDarkMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 32),

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
                        _label("Full Name", context),
                        _inputField(
                          hint: "John Doe",
                          icon: Icons.person_rounded,
                          controller: _nameController,
                        ),
                        const SizedBox(height: 20),
                        _label("Email", context),
                        _inputField(
                          hint: "name@example.com",
                          icon: Icons.email_rounded,
                          controller: _emailController,
                        ),
                        const SizedBox(height: 20),
                        _label("Password", context),
                        _inputField(
                          hint: "••••••••••••",
                          icon: Icons.lock_rounded,
                          isPassword: true,
                          controller: _passwordController,
                        ),
                        const SizedBox(height: 20),
                        _label("Confirm Password", context),
                        _inputField(
                          hint: "••••••••••••",
                          icon: Icons.lock_rounded,
                          isPassword: true,
                          isConfirmPassword: true,
                          controller: _confirmPasswordController,
                        ),

                        const SizedBox(height: 32),

                        // Sign Up Button
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: BlocConsumer<AuthBloc, AuthState>(
                            listener: (context, state) {
                              if (state.status == AuthStatus.error) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      state.errorMessage ?? 'Signup Failed',
                                    ),
                                  ),
                                );
                              } else if (state.status ==
                                  AuthStatus.authenticated) {
                                Navigator.of(
                                  context,
                                ).popUntil((route) => route.isFirst);
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
                                  context.read<AuthBloc>().add(
                                    AuthSignupRequested(
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                      fullName: _nameController.text,
                                    ),
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
                                child: const Text("Create Account"),
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
                                "Or sign up with",
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

                        // Google Sign Up
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

                  const SizedBox(height: 32),

                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textOnDarkMuted,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Log In",
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
    bool isConfirmPassword = false,
    TextEditingController? controller,
  }) {
    final bool obscure = isPassword
        ? (isConfirmPassword ? _obscureConfirmPassword : _obscurePassword)
        : false;

    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 22),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
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

class _PolyBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path();
    for (var i = 0; i < size.width; i += 40) {
      path.moveTo(i.toDouble(), 0);
      path.lineTo(size.width, size.height - i);
      path.moveTo(0, i.toDouble());
      path.lineTo(size.width - i, size.height);
    }
    canvas.drawPath(path, paint);

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
