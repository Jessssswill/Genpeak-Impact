import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/shared_ui.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _avatarBase64;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('profile_avatar');
    if (saved != null && mounted) setState(() => _avatarBase64 = saved);
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 400, maxHeight: 400, imageQuality: 80);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final base64 = base64Encode(bytes);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_avatar', base64);
    if (mounted) setState(() => _avatarBase64 = base64);
  }

  void _showUsernameDialog() {
    final ctrl = TextEditingController(text: context.read<AuthProvider>().user?.name ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
        title: Text('Change Username', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter new username',
            hintStyle: TextStyle(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.surfaceCard,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide(color: AppColors.divider)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide(color: AppColors.divider)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: AppColors.textMuted))),
          ElevatedButton(
            onPressed: () async {
              final ok = await context.read<AuthProvider>().updateUsername(ctrl.text);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok ? 'Username updated!' : 'Failed to update'),
                  backgroundColor: ok ? AppColors.success : AppColors.warning,
                ));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  GestureDetector(
                    onTap: _pickAvatar,
                    child: Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.15),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
                      ),
                      child: ClipOval(
                        child: _avatarBase64 != null
                            ? Image.memory(base64Decode(_avatarBase64!), fit: BoxFit.cover, width: 80, height: 80)
                            : Center(child: Text(
                                user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                                style: TextStyle(color: AppColors.primary, fontSize: 30, fontWeight: FontWeight.w700),
                              )),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _pickAvatar,
                    child: Container(
                      width: 26, height: 26,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.background, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded, size: 13, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Name row with edit button
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(user?.name ?? 'Unknown', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _showUsernameDialog,
                  child: Icon(Icons.edit_rounded, size: 16, color: AppColors.primary.withOpacity(0.7)),
                ),
              ]),
              const SizedBox(height: 4),
              Text(user?.email ?? '', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: (auth.isAdmin ? AppColors.secondary : AppColors.primary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.badge),
                ),
                child: Text(user?.role ?? 'USER', style: TextStyle(color: auth.isAdmin ? AppColors.secondary : AppColors.primary, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1)),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showUsernameDialog,
                  icon: const Icon(Icons.person_outline_rounded, size: 16),
                  label: const Text('Change Username'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              GlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionTitle(title: 'Appearance', icon: Icons.palette_outlined, color: AppColors.primary),
                    const SizedBox(height: 4),
                    Text('Choose your preferred theme', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    const SizedBox(height: 16),
                    Row(children: [
                      _ThemeOption(
                        mode: AppThemeMode.dark,
                        label: 'Dark',
                        icon: Icons.nights_stay_rounded,
                        previewBg: const Color(0xFF121820),
                        previewSurface: const Color(0xFF1B2230),
                        current: themeProvider.mode,
                        onTap: () => themeProvider.setMode(AppThemeMode.dark),
                      ),
                      const SizedBox(width: 10),
                      _ThemeOption(
                        mode: AppThemeMode.gray,
                        label: 'Gray',
                        icon: Icons.contrast_rounded,
                        previewBg: const Color(0xFF1C1C1E),
                        previewSurface: const Color(0xFF2C2C2E),
                        current: themeProvider.mode,
                        onTap: () => themeProvider.setMode(AppThemeMode.gray),
                      ),
                      const SizedBox(width: 10),
                      _ThemeOption(
                        mode: AppThemeMode.light,
                        label: 'Light',
                        icon: Icons.light_mode_rounded,
                        previewBg: const Color(0xFFF2F4F8),
                        previewSurface: const Color(0xFFFFFFFF),
                        current: themeProvider.mode,
                        onTap: () => themeProvider.setMode(AppThemeMode.light),
                      ),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    auth.logout();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  icon: const Icon(Icons.logout_rounded, size: 16),
                  label: const Text('Sign Out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: BorderSide(color: AppColors.danger.withOpacity(0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final AppThemeMode mode;
  final String label;
  final IconData icon;
  final Color previewBg;
  final Color previewSurface;
  final AppThemeMode current;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.mode,
    required this.label,
    required this.icon,
    required this.previewBg,
    required this.previewSurface,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = current == mode;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.08) : AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: isSelected ? AppColors.primary.withOpacity(0.5) : AppColors.cardBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: previewBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: previewSurface,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    Center(child: Icon(icon, size: 16, color: AppColors.primary.withOpacity(0.8))),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isSelected ? 16 : 0,
                height: isSelected ? 3 : 0,
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
