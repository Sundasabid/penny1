import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/presentation/bloc/auth/auth_bloc.dart';
import 'package:app/presentation/bloc/auth/auth_state.dart';
import 'package:app/domain/repositories/auth_repository.dart';
import '../../../config/themes/app_colors.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthBloc>().state.user;
    _nameController = TextEditingController(text: user.displayName);
    _phoneController = TextEditingController(text: user.phoneNumber);
    _bioController = TextEditingController(text: ''); // Default empty, load from Firestore
    _loadUserBio();
  }

  Future<void> _loadUserBio() async {
    final userId = context.read<AuthBloc>().state.user.id;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (doc.exists && mounted) {
        setState(() {
          _bioController.text = doc.data()?['bio'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading bio: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final userId = context.read<AuthBloc>().state.user.id;
    final newName = _nameController.text.trim();
    final newPhone = _phoneController.text.trim();
    final newBio = _bioController.text.trim();

    try {
      // 1. Update Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'displayName': newName,
        'phoneNumber': newPhone,
        'bio': newBio,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2. Update Auth (Local State)
      // Since our AuthBloc usually listens to Auth changes or has a specific update event:
      // Assuming we have an event to update user data locally
      // If not, we can trigger a re-fetch or just pop with success
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.neon,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showChangeEmailDialog(String currentEmail) {
    final newEmailController = TextEditingController();
    final passwordController = TextEditingController();
    final dFormKey = GlobalKey<FormState>();
    bool dLoading = false;

    showDialog(
      context: context,
      barrierDismissible: !dLoading,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(context).cardTheme.color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Change Email', style: TextStyle(fontWeight: FontWeight.w900)),
          content: Form(
            key: dFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Enter your new email and current password to verify your identity.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                _GlassInputField(
                  controller: newEmailController,
                  label: 'New Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty ? 'Enter new email' : null,
                ),
                const SizedBox(height: 16),
                _GlassInputField(
                  controller: passwordController,
                  label: 'Current Password',
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  validator: (v) => v!.isEmpty ? 'Password required' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: dLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            GestureDetector(
              onTap: dLoading
                  ? null
                  : () async {
                      if (!dFormKey.currentState!.validate()) return;
                      setDialogState(() => dLoading = true);
                      try {
                        final authRepo = context.read<AuthRepository>();
                        await authRepo.updateEmail(
                          newEmail: newEmailController.text.trim(),
                          password: passwordController.text,
                        );
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Verification link sent to new email! (Check Spam folder)'),
                              backgroundColor: AppColors.neon,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString().replaceAll('Exception: ', '')),
                              backgroundColor: AppColors.danger,
                            ),
                          );
                        }
                      } finally {
                        setDialogState(() => dLoading = false);
                      }
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.neon,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neon.withOpacity(0.35),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: dLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text(
                        'Verify & Send',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state.user;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // ELITE AVATAR EDIT
                  _EditableAvatar(
                    photoUrl: user.photoUrl,
                    displayName: user.displayName,
                  ),
                  
                  const SizedBox(height: 40),

                  // IDENTITY CARDS
                  _GlassInputField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person_outline_rounded,
                    validator: (v) => v!.isEmpty ? 'Name cannot be empty' : null,
                  ),
                  
                  const SizedBox(height: 20),

                  _GlassInputField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 20),

                  _GlassInputField(
                    controller: _bioController,
                    label: 'Biogram / Tagline',
                    icon: Icons.auto_awesome_outlined,
                    hint: 'Financial Freedom Hunter...',
                    maxLines: 3,
                  ),

                  const SizedBox(height: 20),

                  // EMAIL CHANGE TILE
                  _EmailChangeTile(
                    email: user.email,
                    onTap: () => _showChangeEmailDialog(user.email),
                  ),

                  const SizedBox(height: 48),

                  // SAVE BUTTON
                  GestureDetector(
                    onTap: _isLoading ? null : _saveProfile,
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.neon,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neon.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Update Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EditableAvatar extends StatefulWidget {
  final String? photoUrl;
  final String? displayName;

  const _EditableAvatar({this.photoUrl, this.displayName});

  @override
  State<_EditableAvatar> createState() => _EditableAvatarState();
}

class _EditableAvatarState extends State<_EditableAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulsing Shadow Ring
        AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            return Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neon.withOpacity(0.2 + (_glowController.value * 0.2)),
                    blurRadius: 20 + (_glowController.value * 20),
                    spreadRadius: 2 + (_glowController.value * 4),
                  ),
                ],
              ),
            );
          },
        ),
        
        // Avatar Background
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.neon.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundColor: isDark ? const Color(0xFF1C252E) : Colors.grey[200],
            backgroundImage: widget.photoUrl != null ? NetworkImage(widget.photoUrl!) : null,
            child: widget.photoUrl == null
                ? Text(
                    (widget.displayName ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: AppColors.neon,
                    ),
                  )
                : null,
          ),
        ),

        // Camera Icon Overlay
        Positioned(
          bottom: 5,
          right: 5,
          child: GestureDetector(
            onTap: () {
              // TODO: Implement Image Picker
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.neon,
                shape: BoxShape.circle,
                border: Border.all(color: isDark ? const Color(0xFF0F172A) : Colors.white, width: 3),
              ),
              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;
  final int maxLines;
  final TextInputType keyboardType;
  final bool isPassword;
  final String? Function(String?)? validator;

  const _GlassInputField({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textOnDarkMuted : AppColors.textOnLightMuted,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : Colors.black).withOpacity(isDark ? 0.03 : 0.02),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
            ),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            obscureText: isPassword,
            validator: validator,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.3),
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: Icon(icon, color: AppColors.neon, size: 22),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmailChangeTile extends StatelessWidget {
  final String email;
  final VoidCallback onTap;

  const _EmailChangeTile({required this.email, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Email Address',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textOnDarkMuted : AppColors.textOnLightMuted,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : Colors.black).withOpacity(isDark ? 0.03 : 0.02),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.email_outlined, color: AppColors.neon, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  email,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: (isDark ? Colors.white : Colors.black87).withOpacity(0.5),
                  ),
                ),
              ),
              TextButton(
                onPressed: onTap,
                child: const Text(
                  'Change',
                  style: TextStyle(
                    color: AppColors.neon,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
