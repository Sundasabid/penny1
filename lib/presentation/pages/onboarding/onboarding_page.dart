import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import '../../../config/themes/app_colors.dart';
import '../../../core/services/settings_service.dart';
import '../auth/login_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animController;

  final List<OnboardingData> _pages = [
    OnboardingData(
      id: 'sms',
      image: 'assets/images/onboarding_sms.png',
      title: 'Automatic Expense Tracking',
      description: 'Penny securely scans your bank alerts to organize your spending without lifting a finger.',
      highlightText: 'No passwords required. Your data stays on your device.',
      buttonText: 'Securely Sync SMS',
      footerText: '100% Secure & Private',
      benefits: [
        'Automatic categorization of bills & food',
        'Works with all major Pakistani banks',
        'Offline processing for total privacy',
      ],
    ),
    OnboardingData(
      id: 'ai',
      image: 'assets/images/onboarding_ai_v2.png',
      title: 'AI Financial Co-Pilot',
      description: 'Your intelligent assistant for budgeting, saving, and answering every "where did my money go?" question.',
      highlightText: 'Speak or chat with Penny. Personalized insights on the go.',
      buttonText: 'Meet Your Co-Pilot',
      footerText: 'Safe. Smart. Private.',
      benefits: [
        'Natural language chat for instant queries',
        'Smart budget alerts to prevent overspending',
        'Personalized savings goals & weekly reports',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _finishOnboarding() async {
    final settingsService = context.read<SettingsService>();
    await settingsService.setHasSeenOnboarding(true);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finishOnboarding,
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() => _currentPage = page);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingContentView(
                    data: _pages[index],
                    animation: _animController,
                  );
                },
              ),
            ),

            // Navigation Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 6,
                        width: _currentPage == index ? 24 : 6,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.neon
                              : AppColors.neon.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neon,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: AppColors.neon.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        _pages[_currentPage].buttonText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.verified_user_rounded, size: 14, color: AppColors.neon),
                      const SizedBox(width: 4),
                      Text(
                        _pages[_currentPage].footerText,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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

class _OnboardingContentView extends StatelessWidget {
  final OnboardingData data;
  final Animation<double> animation;

  const _OnboardingContentView({required this.data, required this.animation});

  @override
  Widget build(BuildContext context) {
    if (data.id == 'ai') {
      return _buildAiPage(context);
    }
    return _buildDefaultPage(context);
  }

  Widget _buildDefaultPage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 280,
            child: Image.asset(data.image, fit: BoxFit.contain),
          ),
          const SizedBox(height: 32),
          _buildTextContent(context),
        ],
      ),
    );
  }

  Widget _buildAiPage(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 150,
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neon.withOpacity(0.15 * (math.sin(animation.value * 2 * math.pi) + 1.2)),
                      blurRadius: 100,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 320,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, 10 * math.sin(animation.value * 2 * math.pi)),
                          child: child,
                        );
                      },
                      child: Image.asset(data.image, fit: BoxFit.contain, height: 240),
                    ),

                    _buildFloatingChip(
                      top: 40, left: 0, 
                      text: "💡 Overspending alert", 
                      delay: 0,
                    ),
                    _buildFloatingChip(
                      top: 100, right: -10, 
                      text: "🎯 Goal: 5k PKR saved!", 
                      color: AppColors.neon,
                      delay: 1,
                    ),
                    _buildFloatingChip(
                      bottom: 40, left: -10, 
                      text: "💰 \"Total fuel cost?\"", 
                      delay: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildTextContent(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingChip({
    double? top, double? bottom, double? left, double? right,
    required String text, Color? color, required double delay
  }) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final phase = (animation.value + (delay / 3.0)) % 1.0;
          return Transform.translate(
            offset: Offset(0, 8 * math.sin(phase * 2 * math.pi)),
            child: Opacity(
              opacity: (0.8 + 0.2 * math.sin(phase * 2 * math.pi)).clamp(0, 1),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: (color ?? Colors.white).withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: (color ?? AppColors.neon).withOpacity(0.1)),
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color != null ? Colors.white : const Color(0xFF101828),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextContent(BuildContext context) {
    return Column(
      children: [
        Text(
          data.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Color(0xFF101828),
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 12),
        
        // Checklist Benefits
        ...data.benefits.map((benefit) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.neon),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  benefit,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),

        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.neon.withOpacity(0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.neon.withOpacity(0.1)),
          ),
          child: Text(
            data.highlightText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.neon,
            ),
          ),
        ),
      ],
    );
  }
}

class OnboardingData {
  final String id;
  final String image;
  final String title;
  final String description;
  final String highlightText;
  final String buttonText;
  final String footerText;
  final List<String> benefits;

  OnboardingData({
    required this.id,
    required this.image,
    required this.title,
    required this.description,
    required this.highlightText,
    required this.buttonText,
    required this.footerText,
    required this.benefits,
  });
}
