import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../core/services/recaptcha_service.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final recaptchaToken = await RecaptchaService.getToken(context, 'login');

    final success = await ref.read(authProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          recaptchaToken: recaptchaToken,
        );

    if (!mounted) return;

    if (success) {
      context.go('/home');
    } else {
      final error = ref.read(authProvider).error ?? '';
      if (error.contains('EMAIL_NOT_VERIFIED')) {
        final parts = error.split(':');
        final email =
            parts.length > 1 ? parts.last.trim() : _emailController.text.trim();
        context.push('/verify-email?email=${Uri.encodeComponent(email)}');
      } else {
        SnackbarHelper.showError(
          context,
          error.isEmpty ? 'Erreur de connexion.' : error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      size: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Header
                Text('Se connecter', style: AppTextStyles.display)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.1, end: 0),

                const SizedBox(height: AppSpacing.xs),

                Text(
                  'Accédez à vos signalements et\nà votre suivi personnalisé.',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 80.ms),

                const SizedBox(height: AppSpacing.xxxl),

                // Email field
                const _FieldLabel(label: 'Adresse e-mail'),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'vous@mail.com',
                    prefixIcon: Icon(Icons.mail_outline_rounded,
                        size: 18, color: AppColors.textHint),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email requis.';
                    if (!v.contains('@')) return 'Email invalide.';
                    return null;
                  },
                ).animate().fadeIn(duration: 400.ms, delay: 120.ms),

                const SizedBox(height: AppSpacing.md),

                // Password field
                const _FieldLabel(label: 'Mot de passe'),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline_rounded,
                        size: 18, color: AppColors.textHint),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 18,
                        color: AppColors.textHint,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Mot de passe requis.' : null,
                ).animate().fadeIn(duration: 400.ms, delay: 160.ms),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Mot de passe oublié ?',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.railBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 180.ms),

                const SizedBox(height: AppSpacing.xl),

                // Submit
                ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Se connecter'),
                ).animate().fadeIn(duration: 400.ms, delay: 220.ms),

                const SizedBox(height: AppSpacing.md),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.border)),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      child: Text(
                        'ou',
                        style: AppTextStyles.monoLabel.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.border)),
                  ],
                ).animate().fadeIn(duration: 400.ms, delay: 260.ms),

                const SizedBox(height: AppSpacing.md),

                // Guest
                OutlinedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Continuer sans compte'),
                ).animate().fadeIn(duration: 400.ms, delay: 280.ms),

                const SizedBox(height: AppSpacing.xxl),

                // Register link
                Center(
                  child: GestureDetector(
                    onTap: () => context.pushReplacement('/register'),
                    child: RichText(
                      text: TextSpan(
                        text: 'Pas encore de compte ? ',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          TextSpan(
                            text: 'Créer un compte',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Field Label ───────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppTextStyles.monoLabel.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w700,
        fontSize: 11,
      ),
    );
  }
}
