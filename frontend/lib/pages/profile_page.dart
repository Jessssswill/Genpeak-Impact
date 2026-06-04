import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _avatarBase64;
  String? _avatarPreset; // asset path of the chosen preset, if any

  // The 9 bundled preset avatars.
  static final List<String> _presets =
      List.generate(9, (i) => 'assets/images/avatars/${i + 1}.png');

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('profile_avatar');
    final preset = prefs.getString('profile_avatar_preset');
    if (mounted) {
      setState(() {
        _avatarBase64 = saved;
        _avatarPreset = preset;
      });
    }
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      maxHeight: 400,
      imageQuality: 80,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final base64 = base64Encode(bytes);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_avatar', base64);
    await prefs.remove('profile_avatar_preset');
    if (mounted) {
      setState(() {
        _avatarBase64 = base64;
        _avatarPreset = null;
      });
    }
  }

  Future<void> _setPresetAvatar(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final base64 = base64Encode(data.buffer.asUint8List());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_avatar', base64);
    await prefs.setString('profile_avatar_preset', assetPath);
    if (mounted) {
      setState(() {
        _avatarBase64 = base64;
        _avatarPreset = assetPath;
      });
    }
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Grab handle
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Change Avatar',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),

                // Upload from gallery
                InkWell(
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickAvatar();
                  },
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.photo_on_rectangle,
                            size: 20, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Upload from Gallery',
                                  style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                              Text('Use a photo from your device',
                                  style: TextStyle(
                                      color: AppColors.textMuted, fontSize: 11)),
                            ],
                          ),
                        ),
                        Icon(CupertinoIcons.chevron_right,
                            size: 14, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'CHOOSE A PRESET',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: _presets.map((path) {
                    final selected = _avatarPreset == path;
                    return GestureDetector(
                      onTap: () {
                        _setPresetAvatar(path);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : AppColors.cardBorder,
                            width: selected ? 2.5 : 1,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.asset(path, fit: BoxFit.cover),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUsernameDialog() {
    final ctrl = TextEditingController(
      text: context.read<AuthProvider>().user?.name ?? '',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'Change Username',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter new username',
            hintStyle: TextStyle(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.surfaceCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              final ok = await context.read<AuthProvider>().updateUsername(
                ctrl.text,
              );
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok ? 'Username updated' : 'Failed to update'),
                    backgroundColor: ok ? AppColors.success : AppColors.warning,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
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
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── Banner ──────────────────────────────────────────────────
          Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                height: 168,
                width: double.infinity,
                child: Align(
                  alignment: Alignment.topRight,
                  // Fade the illustration's edges so it blends into the page
                  // background in any theme — no scrim bands.
                  child: ShaderMask(
                    shaderCallback: (rect) => const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Colors.transparent, Colors.white],
                      stops: [0.0, 0.55],
                    ).createShader(rect),
                    blendMode: BlendMode.dstIn,
                    child: Image.asset(
                      'assets/images/bgProfile.png',
                      height: 168,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
              ),
              // Avatar overlaps banner bottom-left
              Positioned(
                bottom: -36,
                left: 20,
                child: GestureDetector(
                  onTap: _showAvatarPicker,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfaceCard,
                          border: Border.all(
                            color: AppColors.background,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: roleColor.withOpacity(0.25),
                              blurRadius: 16,
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _avatarBase64 != null
                              ? Image.memory(
                                  base64Decode(_avatarBase64!),
                                  fit: BoxFit.cover,
                                  width: 76,
                                  height: 76,
                                )
                              : Center(
                                  child: Text(
                                    user?.name.isNotEmpty == true
                                        ? user!.name[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      color: roleColor,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.background,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            CupertinoIcons.camera_fill,
                            size: 13,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 46),

          // ── Name / email / role ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user?.name ?? 'Traveler',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _RoleTag(
                      isAdmin: isAdmin,
                      color: roleColor,
                      role: user?.role ?? 'USER',
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Account ──────────────────────────────────────────
                _SectionLabel('Account'),
                const SizedBox(height: 8),
                _Group(
                  children: [
                    _Row(
                      icon: CupertinoIcons.person,
                      label: 'Username',
                      trailingText: user?.name ?? '',
                      onTap: _showUsernameDialog,
                    ),
                    _Divider(),
                    _Row(
                      icon: CupertinoIcons.photo,
                      label: 'Avatar',
                      trailingText: 'Change',
                      onTap: _showAvatarPicker,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Appearance ───────────────────────────────────────────
                _SectionLabel('Appearance'),
                const SizedBox(height: 8),
                _Group(
                  children: [
                    _ThemeRow(
                      label: 'Dark',
                      icon: CupertinoIcons.moon,
                      mode: AppThemeMode.dark,
                      current: themeProvider.mode,
                      onTap: () => themeProvider.setMode(AppThemeMode.dark),
                    ),
                    _Divider(),
                    _ThemeRow(
                      label: 'Gray',
                      icon: CupertinoIcons.circle_lefthalf_fill,
                      mode: AppThemeMode.gray,
                      current: themeProvider.mode,
                      onTap: () => themeProvider.setMode(AppThemeMode.gray),
                    ),
                    _Divider(),
                    _ThemeRow(
                      label: 'Light',
                      icon: CupertinoIcons.sun_max,
                      mode: AppThemeMode.light,
                      current: themeProvider.mode,
                      onTap: () => themeProvider.setMode(AppThemeMode.light),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Sign out ──────────────────────────────────────────
                _Group(
                  children: [
                    _Row(
                      icon: CupertinoIcons.square_arrow_left,
                      label: 'Sign Out',
                      danger: true,
                      showChevron: false,
                      onTap: () {
                        auth.logout();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Building blocks ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  final List<Widget> children;
  const _Group({required this.children});
  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(children: children),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(color: AppColors.divider, height: 1, indent: 52);
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailingText;
  final bool showChevron;
  final bool danger;
  final VoidCallback? onTap;

  const _Row({
    required this.icon,
    required this.label,
    this.trailingText,
    this.showChevron = true,
    this.danger = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = danger ? AppColors.danger : AppColors.textPrimary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: danger ? AppColors.danger : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Expanded(
              child: Text(
                trailingText ?? '',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(width: 6),
            // Always reserve the chevron column so trailing text aligns.
            Icon(
              CupertinoIcons.chevron_right,
              size: 14,
              color: showChevron ? AppColors.textMuted : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final AppThemeMode mode;
  final AppThemeMode current;
  final VoidCallback onTap;

  const _ThemeRow({
    required this.label,
    required this.icon,
    required this.mode,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = current == mode;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (selected)
              Icon(
                CupertinoIcons.checkmark_alt,
                size: 17,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}

class _RoleTag extends StatelessWidget {
  final bool isAdmin;
  final Color color;
  final String role;
  const _RoleTag({
    required this.isAdmin,
    required this.color,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
