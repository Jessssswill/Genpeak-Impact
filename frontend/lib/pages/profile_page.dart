import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
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
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0),
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
    final isAdmin = auth.isAdmin;
    final roleColor = isAdmin ? AppColors.secondary : AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            children: [
              // Profile hero card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      roleColor.withOpacity(0.16),
                      roleColor.withOpacity(0.06),
                      AppColors.surfaceCard,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: roleColor.withOpacity(0.22)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 3)),
                  ],
                ),
                child: Column(
                  children: [
                    // Avatar
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        GestureDetector(
                          onTap: _pickAvatar,
                          child: Container(
                            width: 96, height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [roleColor.withOpacity(0.3), roleColor.withOpacity(0.1)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(color: roleColor.withOpacity(0.4), width: 2.5),
                              boxShadow: [
                                BoxShadow(color: roleColor.withOpacity(0.2), blurRadius: 16, spreadRadius: 2),
                              ],
                            ),
                            child: ClipOval(
                              child: _avatarBase64 != null
                                  ? Image.memory(base64Decode(_avatarBase64!), fit: BoxFit.cover, width: 96, height: 96)
                                  : Center(
                                      child: Text(
                                        user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                                        style: TextStyle(color: roleColor, fontSize: 36, fontWeight: FontWeight.w800),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _pickAvatar,
                          child: Container(
                            width: 30, height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.background, width: 2),
                              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 6)],
                            ),
                            child: const Icon(CupertinoIcons.camera_fill, size: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Name + edit
                    GestureDetector(
                      onTap: _showUsernameDialog,
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [AppColors.textPrimary, roleColor.withOpacity(0.8)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(bounds),
                          child: Text(
                            user?.name ?? 'Traveler',
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.3),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(CupertinoIcons.pencil, size: 14, color: roleColor.withOpacity(0.6)),
                      ]),
                    ),
                    const SizedBox(height: 4),
                    Text(user?.email ?? '', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    const SizedBox(height: 10),

                    // Role badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: roleColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(color: roleColor.withOpacity(0.3)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(isAdmin ? CupertinoIcons.shield_fill : CupertinoIcons.person_fill, size: 11, color: roleColor),
                        const SizedBox(width: 5),
                        Text(
                          user?.role ?? 'USER',
                          style: TextStyle(color: roleColor, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2),
                        ),
                      ]),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: -0.1, duration: 500.ms, curve: Curves.easeOutCubic),

              const SizedBox(height: 16),

              // Actions card
              GlassCard(
                padding: const EdgeInsets.all(4),
                child: Column(
                  children: [
                    _ProfileAction(
                      icon: CupertinoIcons.person_circle,
                      label: 'Change Username',
                      subtitle: 'Update your display name',
                      color: AppColors.primary,
                      onTap: _showUsernameDialog,
                    ),
                    Divider(color: AppColors.divider, height: 1, indent: 56),
                    _ProfileAction(
                      icon: CupertinoIcons.photo_on_rectangle,
                      label: 'Change Avatar',
                      subtitle: 'Pick a photo from gallery',
                      color: AppColors.electro,
                      onTap: _pickAvatar,
                    ),
                  ],
                ),
              )
                  .animate(delay: 80.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.1, duration: 500.ms, curve: Curves.easeOutCubic),

              const SizedBox(height: 16),

              // Theme selector
              GlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionTitle(title: 'Appearance', icon: CupertinoIcons.paintbrush_fill, color: AppColors.primary),
                    const SizedBox(height: 4),
                    Text('Choose your preferred theme', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    const SizedBox(height: 16),
                    Row(children: [
                      _ThemeOption(mode: AppThemeMode.dark, label: 'Dark', icon: CupertinoIcons.moon_fill, previewBg: const Color(0xFF121820), previewSurface: const Color(0xFF1B2230), current: themeProvider.mode, onTap: () => themeProvider.setMode(AppThemeMode.dark)),
                      const SizedBox(width: 10),
                      _ThemeOption(mode: AppThemeMode.gray, label: 'Gray', icon: CupertinoIcons.circle_lefthalf_fill, previewBg: const Color(0xFF1C1C1E), previewSurface: const Color(0xFF2C2C2E), current: themeProvider.mode, onTap: () => themeProvider.setMode(AppThemeMode.gray)),
                      const SizedBox(width: 10),
                      _ThemeOption(mode: AppThemeMode.light, label: 'Light', icon: CupertinoIcons.sun_max_fill, previewBg: const Color(0xFFF2F4F8), previewSurface: const Color(0xFFFFFFFF), current: themeProvider.mode, onTap: () => themeProvider.setMode(AppThemeMode.light)),
                    ]),
                  ],
                ),
              )
                  .animate(delay: 160.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.1, duration: 500.ms, curve: Curves.easeOutCubic),

              const SizedBox(height: 16),

              // Sign out
              GestureDetector(
                onTap: () {
                  auth.logout();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(AppRadius.button),
                    border: Border.all(color: AppColors.danger.withOpacity(0.25)),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(CupertinoIcons.square_arrow_left, size: 16, color: AppColors.danger),
                    const SizedBox(width: 8),
                    Text('Sign Out', style: TextStyle(color: AppColors.danger, fontSize: 14, fontWeight: FontWeight.w600)),
                  ]),
                ),
              )
                  .animate(delay: 240.ms)
                  .fadeIn(duration: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _ProfileAction({required this.icon, required this.label, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
            Text(subtitle, style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ])),
          Icon(CupertinoIcons.chevron_right, size: 14, color: AppColors.textMuted.withOpacity(0.5)),
        ]),
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

  const _ThemeOption({required this.mode, required this.label, required this.icon, required this.previewBg, required this.previewSurface, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = current == mode;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.08) : AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: isSelected ? AppColors.primary.withOpacity(0.5) : AppColors.cardBorder,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: AppColors.primary.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 2))]
                : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 1))],
          ),
          child: Column(
            children: [
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: previewBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black.withOpacity(0.08)),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: previewSurface,
                          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                        ),
                      ),
                    ),
                    Center(child: Icon(icon, size: 15, color: AppColors.primary.withOpacity(isSelected ? 1.0 : 0.7))),
                  ],
                ),
              ),
              const SizedBox(height: 7),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isSelected ? 18 : 0,
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
