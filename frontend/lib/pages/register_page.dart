import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/shared_ui.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.register(_nameCtrl.text.trim(), _emailCtrl.text.trim(), _passwordCtrl.text);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account created! Please sign in.'),
          backgroundColor: AppColors.primaryDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Back button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(children: [
                Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Icon(CupertinoIcons.arrow_left, size: 18, color: AppColors.textPrimary),
                    ),
                  ),
                ),
              ]),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // Animated logo — secondary/gold theme
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (_, _) {
                        final t = _pulse.value;
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 90, height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.secondary.withOpacity(0.07 + 0.05 * t),
                                  width: 1,
                                ),
                              ),
                            ),
                            Container(
                              width: 74, height: 74,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.secondary.withOpacity(0.1 + 0.07 * t),
                                  width: 1,
                                ),
                              ),
                            ),
                            Container(
                              width: 60, height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.secondary.withOpacity(0.35 + 0.15 * t),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.secondary.withOpacity(0.18 + 0.1 * t),
                                    blurRadius: 16 + 10 * t,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/paimon.jpg',
                                  width: 60, height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    )
                        .animate()
                        .scaleXY(begin: 0.3, duration: 650.ms, curve: Curves.easeOutBack)
                        .fadeIn(duration: 450.ms),

                    const SizedBox(height: 20),

                    Column(
                      children: [
                        Text(
                          'GENSHIN IMPORT',
                          style: TextStyle(
                            color: AppColors.secondary.withOpacity(0.65),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [AppColors.textPrimary, AppColors.secondaryLight],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Join the Teyvat Marketplace',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                      ],
                    )
                        .animate(delay: 150.ms)
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: 0.3, duration: 500.ms, curve: Curves.easeOutCubic),

                    const SizedBox(height: 24),

                    // Form
                    GlassCard(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            CustomTextField(
                              label: 'Name', hint: 'Enter your name', controller: _nameCtrl,
                              prefixIcon: CupertinoIcons.person, textInputAction: TextInputAction.next,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Name is required';
                                if (v.length < 2) return 'Name must be at least 2 characters';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            CustomTextField(
                              label: 'Email', hint: 'Enter your email', controller: _emailCtrl,
                              prefixIcon: CupertinoIcons.mail,
                              keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Email is required';
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'Enter a valid email';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            CustomTextField(
                              label: 'Password', hint: 'Min 6 characters', controller: _passwordCtrl,
                              prefixIcon: CupertinoIcons.lock, obscureText: _obscure,
                              textInputAction: TextInputAction.next,
                              suffixIcon: IconButton(
                                icon: Icon(_obscure ? CupertinoIcons.eye_slash : CupertinoIcons.eye, color: AppColors.textMuted, size: 20),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Password is required';
                                if (v.length < 6) return 'Password must be at least 6 characters';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            CustomTextField(
                              label: 'Confirm Password', hint: 'Re-enter password', controller: _confirmCtrl,
                              prefixIcon: CupertinoIcons.lock_fill, obscureText: _obscureConfirm,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _handleRegister(),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureConfirm ? CupertinoIcons.eye_slash : CupertinoIcons.eye, color: AppColors.textMuted, size: 20),
                                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Please confirm your password';
                                if (v != _passwordCtrl.text) return 'Passwords do not match';
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),

                            Consumer<AuthProvider>(
                              builder: (context, auth, _) {
                                if (auth.error != null) {
                                  return Container(
                                    width: double.infinity, padding: const EdgeInsets.all(10),
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
                                text: 'Create Account',
                                isLoading: auth.isLoading,
                                onPressed: _handleRegister,
                                icon: CupertinoIcons.checkmark_alt,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate(delay: 250.ms)
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: 0.2, duration: 500.ms, curve: Curves.easeOutCubic),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account? ', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text('Sign In', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
