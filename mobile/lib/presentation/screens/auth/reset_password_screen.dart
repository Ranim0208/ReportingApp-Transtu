import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../data/datasources/remote/api_client.dart';
import '../../../core/utils/snackbar_helper.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String token;
  const ResetPasswordScreen({super.key, required this.token});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _success = false;
  int _passwordStrength = 0;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updateStrength);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _updateStrength() {
    final p = _passwordController.text;
    int score = 0;
    if (p.length >= 8) score++;
    if (p.contains(RegExp(r'[A-Z]'))) score++;
    if (p.contains(RegExp(r'[0-9]'))) score++;
    if (p.contains(RegExp(r'[!@#\$%^&*]'))) score++;
    setState(() => _passwordStrength = score);
  }

  Color get _strengthColor => switch (_passwordStrength) {
        1 => AppColors.error,
        2 => AppColors.warning,
        3 => AppColors.warning,
        4 => AppColors.success,
        _ => AppColors.border,
      };

  String get _strengthLabel => switch (_passwordStrength) {
        1 => 'Faible',
        2 => 'Moyen',
        3 => 'Bon',
        4 => 'Fort',
        _ => '',
      };

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.token.isEmpty) {
      SnackbarHelper.showError(context, 'Token invalide.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(apiClientProvider).resetPassword(
            token: widget.token,
            newPassword: _passwordController.text,
          );
      if (mounted)
        setState(() {
          _isLoading = false;
          _success = true;
        });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SnackbarHelper.showError(
          context,
          'Lien invalide ou expiré. Veuillez en demander un nouveau.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_success) return const _SuccessScreen();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: AppRadius.large,
                  ),
                  child: const Icon(Icons.lock_outline_rounded,
                      color: AppColors.primary, size: 32),
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: AppSpacing.xl),

                Text('Nouveau mot de passe', style: AppTextStyles.display)
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 80.ms),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  'Choisissez un nouveau mot de passe sécurisé pour votre compte.',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 120.ms),

                const SizedBox(height: AppSpacing.xxxl),

                // New password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Nouveau mot de passe',
                    prefixIcon:
                        const Icon(Icons.lock_outline_rounded, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) => v == null || v.length < 8
                      ? 'Minimum 8 caractères.'
                      : null,
                ).animate().fadeIn(duration: 400.ms, delay: 160.ms),

                // Strength bar
                if (_passwordController.text.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _passwordStrength / 4,
                            backgroundColor: AppColors.border,
                            color: _strengthColor,
                            minHeight: 3,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        _strengthLabel,
                        style: AppTextStyles.caption.copyWith(
                          color: _strengthColor,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: AppSpacing.md),

                // Confirm password
                TextFormField(
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le mot de passe',
                    prefixIcon:
                        const Icon(Icons.lock_outline_rounded, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (v) => v != _passwordController.text
                      ? 'Les mots de passe ne correspondent pas.'
                      : null,
                ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                const SizedBox(height: AppSpacing.xxxl),

                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Réinitialiser le mot de passe'),
                ).animate().fadeIn(duration: 400.ms, delay: 240.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessScreen extends StatelessWidget {
  const _SuccessScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: AppColors.success, size: 48),
              ).animate().scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    duration: 500.ms,
                    curve: Curves.elasticOut,
                  ),
              const SizedBox(height: AppSpacing.xxl),
              Text('Mot de passe modifié !', style: AppTextStyles.display)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 300.ms),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Votre mot de passe a été réinitialisé avec succès. Vous pouvez maintenant vous connecter.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 400.ms, delay: 380.ms),
              const SizedBox(height: AppSpacing.xxxl),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Se connecter'),
              ).animate().fadeIn(duration: 400.ms, delay: 450.ms),
            ],
          ),
        ),
      ),
    );
  }
}
