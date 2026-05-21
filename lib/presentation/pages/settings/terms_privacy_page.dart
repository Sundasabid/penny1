import 'package:flutter/material.dart';
import '../../../config/themes/app_colors.dart';

class TermsAndPrivacyPage extends StatelessWidget {
  const TermsAndPrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : const Color(0xFF101828),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Terms & Privacy',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          bottom: TabBar(
            indicatorColor: AppColors.neon,
            labelColor: AppColors.neon,
            unselectedLabelColor: isDark ? Colors.grey : Colors.grey.shade600,
            dividerColor: Colors.transparent,
            labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            tabs: const [
              Tab(text: 'Privacy Policy'),
              Tab(text: 'Terms of Use'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _PrivacyPolicyView(),
            _TermsOfUseView(),
          ],
        ),
      ),
    );
  }
}

class _PrivacyPolicyView extends StatelessWidget {
  const _PrivacyPolicyView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroHeader(
            context,
            icon: Icons.security_rounded,
            title: 'Your Privacy Matters',
            subtitle: 'Last updated: April 2026',
          ),
          const SizedBox(height: 32),
          _buildSection(
            context,
            '1. Data Collection',
            'Penny collects financial data (transactions, bills, budgets) to help you manage your finances. We also collect device information to ensure app stability.',
          ),
          _buildSection(
            context,
            '2. SMS Permissions',
            'When enabled, Penny reads financial SMS alerts from your bank to automate transaction logging. We do NOT read personal messages, and processing happens locally before being securely synced.',
          ),
          _buildSection(
            context,
            '3. AI Processing (Google Gemini)',
            'We use Google Gemini AI to analyze your receipt images and SMS content. This data is sent to Google\'s secure API endpoints. By using our AI features, you consent to this processing.',
          ),
          _buildSection(
            context,
            '4. Data Storage',
            'Your data is securely stored in Google Firebase Cloud. We use industry-standard encryption to protect your data during transit and at rest.',
          ),
          _buildSection(
            context,
            '5. Your Rights',
            'You can export your data or delete your account at any time from the app settings. Deleting your account removes all your data from our servers permanently.',
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _TermsOfUseView extends StatelessWidget {
  const _TermsOfUseView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroHeader(
            context,
            icon: Icons.gavel_rounded,
            title: 'Terms of Service',
            subtitle: 'Please read carefully before using Penny',
          ),
          const SizedBox(height: 32),
          _buildSection(
            context,
            '1. Acceptance',
            'By using Penny, you agree to these terms. If you do not agree, please do not use the app.',
          ),
          _buildSection(
            context,
            '2. Financial Disclaimer',
            'Penny is a financial tracking tool and NOT a financial advisor. All insights and suggestions provided by the app or our AI Co-Pilot are for informational purposes only. You are solely responsible for your financial decisions.',
          ),
          _buildSection(
            context,
            '3. AI Accuracy',
            'AI-extracted data from receipts and SMS may occasionally be inaccurate. We recommend a quick review of all automated entries to ensure your books are correct.',
          ),
          _buildSection(
            context,
            '4. User Conduct',
            'You agree not to use the app for any illegal purposes or to attempt to reverse engineer our proprietary AI systems.',
          ),
          _buildSection(
            context,
            '5. Limitation of Liability',
            'We provide Penny "as-is" without any warranties. We are not liable for any financial losses or data inaccuracies resulting from your use of the app.',
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

Widget _buildHeroHeader(BuildContext context, {required IconData icon, required String title, required String subtitle}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.neon.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: AppColors.neon, size: 32),
      ),
      const SizedBox(height: 16),
      Text(
        title,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        subtitle,
        style: TextStyle(
          fontSize: 16,
          color: isDark ? AppColors.textOnDarkMuted : AppColors.textOnLightMuted,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}

Widget _buildSection(BuildContext context, String title, String body) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.neon,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      ],
    ),
  );
}
