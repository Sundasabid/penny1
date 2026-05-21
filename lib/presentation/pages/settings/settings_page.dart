import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/presentation/bloc/auth/auth_bloc.dart';
import 'package:app/presentation/bloc/auth/auth_event.dart';
import 'package:app/presentation/pages/settings/widgets/setting_section.dart';
import 'package:app/presentation/pages/settings/widgets/setting_tile.dart';
import 'package:app/presentation/pages/settings/widgets/toggle_setting_tile.dart';
import 'package:app/core/widgets/coming_soon_page.dart';
import 'package:app/presentation/pages/settings/terms_privacy_page.dart';
import 'package:app/presentation/bloc/theme/theme_bloc.dart';
import 'package:app/presentation/bloc/theme/theme_event.dart';
import 'package:app/main.dart';
import 'package:app/presentation/pages/auth/login_page.dart';
import 'package:app/presentation/pages/settings/category_tabs_page.dart';
import 'package:app/presentation/pages/settings/financial_profile_page.dart';
import 'package:app/presentation/pages/settings/currency_settings_page.dart';
import 'package:app/presentation/pages/profile/edit_profile_page.dart';
import 'package:app/domain/repositories/auth_repository.dart';
import '../../../config/themes/app_colors.dart';
import 'package:app/data/services/sms_sync_service.dart';
import 'package:app/core/services/settings_service.dart';
import 'package:app/core/utils/sms_background_handler.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool biometricLogin = false;
  bool autoScanReceipts = true;
  bool pushNotifications = true;
  bool emailReports = false;
  bool smsSyncEnabled = false;
  String language = 'English';

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  Future<void> _loadUserPreferences() async {
    final authState = context.read<AuthBloc>().state;
    final userId = authState.user.id;
    if (userId.isEmpty) return;

    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final prefs = doc.data()?['preferences'] as Map<String, dynamic>?;
        if (prefs != null && mounted) {
          setState(() {
            biometricLogin = prefs['biometricLogin'] ?? false;
            autoScanReceipts = prefs['autoScanReceipts'] ?? true;
            pushNotifications = prefs['pushNotifications'] ?? true;
            emailReports = prefs['emailReports'] ?? false;
            language = prefs['language'] ?? 'English';
            // Also load from local SettingsService
            smsSyncEnabled = context.read<SettingsService>().isSmsSyncEnabled();
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  Future<void> _updatePreference(String key, dynamic value) async {
    final authState = context.read<AuthBloc>().state;
    final userId = authState.user.id;
    if (userId.isEmpty) return;

    try {
      await _firestore.collection('users').doc(userId).update({
        'preferences.$key': value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating preference: $e');
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    final userEmail = context.read<AuthBloc>().state.user.email;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'A password reset link will be sent to your registered email:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Text(
              userEmail,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.neon,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please follow the instructions in the email to securely update your password.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          GestureDetector(
            onTap: () async {
              try {
                final authRepo = context.read<AuthRepository>();
                await authRepo.sendPasswordResetEmail(userEmail);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reset link sent! (Check Spam folder)'),
                      backgroundColor: AppColors.neon,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceAll('Exception: ', '')),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.neon,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neon.withOpacity(0.35),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Text(
                'Send Reset Link',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = context.select((AuthBloc bloc) => bloc.state.user);

    return Scaffold(
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
          'Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            SettingSection(
              title: 'ACCOUNT & SECURITY',
              children: [
                SettingTile(
                  icon: Icons.person_rounded,
                  title: 'Edit Profile',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfilePage(),
                      ),
                    );
                  },
                ),
                SettingTile(
                  icon: Icons.lock_rounded,
                  title: 'Change Password',
                  onTap: () => _showChangePasswordDialog(context),
                ),
                ToggleSettingTile(
                  icon: Icons.fingerprint_rounded,
                  title: 'Biometric Login',
                  value: biometricLogin,
                  onChanged: (val) {
                    setState(() => biometricLogin = val);
                    _updatePreference('biometricLogin', val);
                  },
                ),
              ],
            ),

            SettingSection(
              title: 'MASTER DATA',
              children: [
                SettingTile(
                  icon: Icons.category_rounded,
                  title: 'Categories',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CategoryTabsPage(),
                      ),
                    );
                  },
                ),
                SettingTile(
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'Financial Profile',
                  subtitle: 'Income, Currency',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FinancialProfilePage(),
                      ),
                    );
                  },
                ),
              ],
            ),

            SettingSection(
              title: 'RECEIPTS & EXPENSES',
              children: [
                ToggleSettingTile(
                  icon: Icons.camera_alt_rounded,
                  title: 'Auto-Scan Receipts',
                  value: autoScanReceipts,
                  onChanged: (val) {
                    setState(() => autoScanReceipts = val);
                    _updatePreference('autoScanReceipts', val);
                  },
                ),
                SettingTile(
                  icon: Icons.credit_card_rounded,
                  title: 'Payment Methods',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ComingSoonPage(
                          title: 'Payment Methods',
                          subtitle: 'Manage your payment methods',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            
            SettingSection(
              title: 'AUTOMATION',
              children: [
                ToggleSettingTile(
                  icon: Icons.sms_rounded,
                  title: 'Automatic SMS Sync',
                  subtitle: 'Log bank transactions from SMS alerts',
                  value: smsSyncEnabled,
                  onChanged: (val) async {
                    setState(() => smsSyncEnabled = val);
                    
                    final settingsResource = context.read<SettingsService>();
                    await settingsResource.setSmsSyncEnabled(val);
                    await _updatePreference('smsSyncEnabled', val);

                    if (val && mounted) {
                      // Trigger historical sync and request permissions
                      try {
                        await context.read<SmsSyncService>().toggleSmsSync(true, backgrounMessageHandler);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('SMS Sync enabled! Fetching this month\'s transactions...'),
                            backgroundColor: AppColors.neon,
                          ),
                        );
                      } catch (e) {
                         ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Permission denied or error: $e'),
                            backgroundColor: AppColors.danger,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),

            SettingSection(
              title: 'PREFERENCES',
              children: [
                ToggleSettingTile(
                  icon: Icons.dark_mode_rounded,
                  title: 'Dark Mode',
                  value:
                      context.watch<ThemeBloc>().state.themeMode ==
                      ThemeMode.dark,
                  onChanged: (val) {
                    context.read<ThemeBloc>().add(ToggleThemeRequested());
                    _updatePreference('darkMode', val);
                  },
                ),
                SettingTile(
                  icon: Icons.public_rounded,
                  title: 'Currency',
                  trailing: Text(
                    user.currency ?? 'PKR',
                    style: TextStyle(
                      color: isDark ? AppColors.neon : theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CurrencySettingsPage(),
                      ),
                    );
                  },
                ),
                SettingTile(
                  icon: Icons.language_rounded,
                  title: 'Language',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        language,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textOnDarkMuted
                              : AppColors.textOnLightMuted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: isDark
                            ? AppColors.textOnDarkMuted
                            : const Color(0xFF98A2B3),
                        size: 20,
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ComingSoonPage(
                          title: 'Language',
                          subtitle: 'Choose your preferred language',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            SettingSection(
              title: 'ABOUT',
              children: [
                SettingTile(
                  icon: Icons.description_rounded,
                  title: 'Terms & Privacy',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TermsAndPrivacyPage(),
                      ),
                    );
                  },
                ),
                SettingTile(
                  icon: Icons.logout_rounded,
                  title: 'Log Out',
                  onTap: () => _showLogoutDialog(context),
                  textColor: AppColors.danger,
                  iconBackgroundColor: AppColors.danger.withOpacity(0.1),
                  iconColor: AppColors.danger,
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        title: const Text(
          'Log Out',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          GestureDetector(
            onTap: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
              navigatorKey.currentState?.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.danger.withOpacity(0.3)),
              ),
              child: const Text(
                'Log Out',
                style: TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
