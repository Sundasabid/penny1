import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/presentation/bloc/auth/auth_bloc.dart';
import 'package:app/presentation/bloc/auth/auth_state.dart';
import 'package:app/presentation/bloc/auth/auth_event.dart';
import 'package:app/presentation/pages/profile/widgets/profile_menu_tile.dart';
import 'package:app/presentation/pages/settings/settings_page.dart';
import 'package:app/core/widgets/coming_soon_page.dart';
import 'package:app/presentation/pages/settings/terms_privacy_page.dart';
import '../../../config/themes/app_colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final user = state.user;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Profile Header
                  Column(
                    children: [
                      // Profile Photo with Neon Border
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.neon.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: isDark
                              ? const Color(0xFF1C252E)
                              : const Color(0xFFE6F7F0),
                          backgroundImage: user.photoUrl != null
                              ? NetworkImage(user.photoUrl!)
                              : null,
                          child: user.photoUrl == null
                              ? Text(
                                  (user.displayName ?? 'U')
                                      .trim()
                                      .split(' ')
                                      .map((e) => e[0])
                                      .take(2)
                                      .join()
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.neon,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // User Name
                      Text(
                        user.displayName ?? 'User',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Phone or Email
                      Text(
                        user.phoneNumber ?? user.email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppColors.textOnDarkMuted
                              : AppColors.textOnLightMuted,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Menu Tiles
                  ProfileMenuTile(
                    icon: Icons.settings_rounded,
                    title: 'Settings',
                    subtitle: 'App preferences & notifications',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsPage()),
                      );
                    },
                  ),

                  ProfileMenuTile(
                    icon: Icons.card_membership_rounded,
                    title: 'Subscription',
                    subtitle: 'Manage your premium plan',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ComingSoonPage(
                            title: 'Subscription',
                            subtitle:
                                'Premium features and subscription management',
                          ),
                        ),
                      );
                    },
                  ),

                  ProfileMenuTile(
                    icon: Icons.security_rounded,
                    title: 'Privacy & Security',
                    subtitle: 'Passcode, FaceID, Data',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TermsAndPrivacyPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Log Out Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: OutlinedButton(
                      onPressed: () {
                        _showLogoutDialog(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.danger.withOpacity(0.5),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'Log Out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            child: const Text(
              'Log Out',
              style: TextStyle(color: Color(0xFFF04438)),
            ),
          ),
        ],
      ),
    );
  }
}
