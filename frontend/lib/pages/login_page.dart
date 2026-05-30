import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/particle_background.dart';
import '../widgets/shared_ui.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.login(_emailCtrl.text.trim(), _passwordCtrl.text);
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  Future<void> _handleGoogleLogin() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.loginWithGoogle();
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  Future<void> _handleDemoLogin() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.login('user@genshin.com', 'password123');
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  Future<void> _handleDemoAdminLogin() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.login('admin@genshin.com', 'password123');
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(
            child: ParticleBackground(particleCount: 24, targetFps: 30),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.4),
                  radius: 0.75,
                  colors: [
                    AppColors.primary.withOpacity(0.07),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),

                    // Animated multi-ring logo
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (_, _) {
                        final t = _pulse.value;
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 102, height: 102,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.07 + 0.05 * t),
                                  width: 1,
                                ),
                              ),
                            ),
                            Container(
                              width: 86, height: 86,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.1 + 0.07 * t),
                                  width: 1,
                                ),
                              ),
                            ),
                            Container(
                              width: 68, height: 68,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary.withOpacity(0.09 + 0.04 * t),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.25 + 0.12 * t),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.18 + 0.1 * t),
                                    blurRadius: 18 + 10 * t,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.diamond_rounded, size: 30, color: AppColors.primary),
                            ),
                          ],
                        );
                      },
                    )
                        .animate()
                        .scaleXY(begin: 0.3, duration: 700.ms, curve: Curves.easeOutBack)
                        .fadeIn(duration: 500.ms),

                    const SizedBox(height: 22),

                    // App name + headline
                    Column(
                      children: [
                        Text(
                          'GENSHIN IMPORT',
                          style: TextStyle(
                            color: AppColors.primary.withOpacity(0.65),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [AppColors.textPrimary, AppColors.primaryLight],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: const Text(
                            'Welcome Back',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 27,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Sign in to your account',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                      ],
                    )
                        .animate(delay: 150.ms)
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: 0.3, duration: 500.ms, curve: Curves.easeOutCubic),

                    const SizedBox(height: 28),

                    // Form card
                    GlassCard(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            CustomTextField(
                              label: 'Email',
                              hint: 'Enter your email',
                              controller: _emailCtrl,
                              prefixIcon: CupertinoIcons.mail,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Email is required';
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'Enter a valid email';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              label: 'Password',
                              hint: 'Enter your password',
                              controller: _passwordCtrl,
                              prefixIcon: CupertinoIcons.lock,
                              obscureText: _obscure,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _handleLogin(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                                  color: AppColors.textMuted,
                                  size: 20,
                                ),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Password is required';
                                if (v.length < 6) return 'Password must be at least 6 characters';
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),

                            // Error message
                            Consumer<AuthProvider>(
                              builder: (context, auth, _) {
                                if (auth.error != null) {
                                  return Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    margin: const EdgeInsets.only(top: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.danger.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.danger.withOpacity(0.2)),
                                    ),
                                    child: Row(children: [
                                      const Icon(CupertinoIcons.exclamationmark_circle, color: AppColors.danger, size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(auth.error!, style: const TextStyle(color: AppColors.danger, fontSize: 12))),
                                    ]),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                            const SizedBox(height: 20),

                            Consumer<AuthProvider>(
                              builder: (context, auth, _) => GlassButton(
                                text: 'Sign In',
                                isLoading: auth.isLoading,
                                onPressed: _handleLogin,
                                icon: CupertinoIcons.arrow_right_to_line,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate(delay: 250.ms)
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: 0.2, duration: 500.ms, curve: Curves.easeOutCubic),

                    const SizedBox(height: 20),

                    // Divider with diamond icon
                    Row(
                      children: [
                        Expanded(child: Divider(color: AppColors.divider)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(
                            CupertinoIcons.star,
                            size: 13,
                            color: AppColors.textMuted.withOpacity(0.35),
                          ),
                        ),
                        Expanded(child: Divider(color: AppColors.divider)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Google Sign-In — frosted glass style
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) => SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(AppRadius.button),
                          child: InkWell(
                            onTap: auth.isLoading ? null : _handleGoogleLogin,
                            borderRadius: BorderRadius.circular(AppRadius.button),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.surfaceCard,
                                borderRadius: BorderRadius.circular(AppRadius.button),
                                border: Border.all(color: AppColors.cardBorder),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: auth.isLoading
                                  ? const Center(
                                      child: SizedBox(
                                        width: 18, height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/images/google_logo.png',
                                          width: 18, height: 18,
                                          errorBuilder: (_, _, _) => Icon(CupertinoIcons.arrow_right_to_line, size: 18, color: AppColors.textSecondary),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Continue with Google',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Demo pills — subtle, pill-shaped
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _DemoPill(
                          label: 'Demo User',
                          icon: CupertinoIcons.person,
                          color: AppColors.primary,
                          onTap: _handleDemoLogin,
                        ),
                        const SizedBox(width: 10),
                        _DemoPill(
                          label: 'Demo Admin',
                          icon: CupertinoIcons.shield,
                          color: AppColors.secondary,
                          onTap: _handleDemoAdminLogin,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Register link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/register'),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _DemoPill({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: color.withOpacity(0.18)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: color.withOpacity(0.8)),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(color: color.withOpacity(0.85), fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ]),
      ),
    );
  }
}
