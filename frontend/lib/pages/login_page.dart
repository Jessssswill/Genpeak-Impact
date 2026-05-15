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

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
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
          SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 70, height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.25), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.diamond_rounded, size: 32, color: AppColors.primary),
                )
                    .animate()
                    .scaleXY(begin: 0.35, duration: 650.ms, curve: Curves.easeOutBack)
                    .fadeIn(duration: 450.ms),
                const SizedBox(height: 20),
                Column(
                  children: [
                    Text('Welcome Back', style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text('Sign in to your account', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  ],
                )
                    .animate(delay: 150.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.3, duration: 500.ms, curve: Curves.easeOutCubic),
                const SizedBox(height: 32),

                // Form
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomTextField(
                          label: 'Email',
                          hint: 'Enter your email',
                          controller: _emailCtrl,
                          prefixIcon: Icons.email_outlined,
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
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscure,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleLogin(),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: AppColors.textMuted, size: 20),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Password is required';
                            if (v.length < 6) return 'Password must be at least 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),

                        // Error
                        Consumer<AuthProvider>(
                          builder: (context, auth, _) {
                            if (auth.error != null) {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.only(top: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.danger.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.danger.withValues(alpha: 0.2)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline, color: AppColors.danger, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(auth.error!, style: const TextStyle(color: AppColors.danger, fontSize: 12))),
                                  ],
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        const SizedBox(height: 20),

                        // Login button
                        Consumer<AuthProvider>(
                          builder: (context, auth, _) {
                            return PrimaryButton(text: 'Sign In', isLoading: auth.isLoading, onPressed: _handleLogin, icon: Icons.login_rounded);
                          },
                        ),
                      ],
                    ),
                  ),
                )
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.28, duration: 500.ms, curve: Curves.easeOutCubic),
                const SizedBox(height: 20),

                // Divider + OAuth + Demo buttons
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: Divider(color: AppColors.divider)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('or', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        ),
                        Expanded(child: Divider(color: AppColors.divider)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Google Sign-In button
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) => SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: auth.isLoading ? null : _handleGoogleLogin,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: BorderSide(color: AppColors.divider),
                            backgroundColor: AppColors.surfaceCard,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
                          ),
                          child: auth.isLoading
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/google_logo.png',
                                      width: 20, height: 20,
                                      errorBuilder: (_, _, _) => const Icon(Icons.login_rounded, size: 18),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text('Continue with Google',
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _handleDemoLogin,
                            icon: const Icon(Icons.person_rounded, size: 16),
                            label: const Text('Demo User', style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _handleDemoAdminLogin,
                            icon: const Icon(Icons.admin_panel_settings_rounded, size: 16),
                            label: const Text('Demo Admin', style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.secondary,
                              side: BorderSide(color: AppColors.secondary.withValues(alpha: 0.3)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
                    .animate(delay: 520.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.2, duration: 400.ms, curve: Curves.easeOutCubic),
                const SizedBox(height: 24),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ", style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/register'),
                      child: const Text('Sign Up', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ],
                )
                    .animate(delay: 700.ms)
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
          ),   // closes SafeArea
        ],     // closes Stack children
      ),       // closes Stack
    );
  }
}
