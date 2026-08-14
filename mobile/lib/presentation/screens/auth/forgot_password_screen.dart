import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../data/datasources/remote/api_client.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(apiClientProvider).forgotPassword(
            _controller.text.trim(),
          );
      if (mounted)
        setState(() {
          _isLoading = false;
          _sent = true;
        });
    } catch (_) {
      // Always show success — anti-enumeration
      if (mounted)
        setState(() {
          _isLoading = false;
          _sent = true;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: _sent
              ? _SentContent(email: _controller.text.trim())
              : _FormContent(
                  formKey: _formKey,
                  controller: _controller,
                  isLoading: _isLoading,
                  onSubmit: _submit,
                ),
        ),
      ),
    );
  }
}

class _FormContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSubmit;

  const _FormContent({
    required this.formKey,
    required this.controller,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: AppRadius.large,
            ),
            child: const Icon(Icons.lock_reset_rounded,
                color: AppColors.primary, size: 32),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: AppSpacing.xl),

          Text('Mot de passe oublié', style: AppTextStyles.display)
              .animate()
              .fadeIn(duration: 400.ms, delay: 80.ms),

          const SizedBox(height: AppSpacing.sm),

          Text(
            'Entrez votre adresse email. Nous vous enverrons un lien pour réinitialiser votre mot de passe.',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ).animate().fadeIn(duration: 400.ms, delay: 120.ms),

          const SizedBox(height: AppSpacing.xxxl),

          TextFormField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Adresse email',
              prefixIcon: Icon(Icons.mail_outline_rounded, size: 20),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email requis.';
              if (!v.contains('@')) return 'Email invalide.';
              return null;
            },
          ).animate().fadeIn(duration: 400.ms, delay: 160.ms),

          const SizedBox(height: AppSpacing.xxl),

          ElevatedButton(
            onPressed: isLoading ? null : onSubmit,
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Envoyer le lien'),
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
        ],
      ),
    );
  }
}

class _SentContent extends StatelessWidget {
  final String email;
  const _SentContent({required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.xxxl),
        Container(
          width: 88,
          height: 88,
          decoration: const BoxDecoration(
            color: AppColors.successLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.mark_email_read_rounded,
              color: AppColors.success, size: 44),
        ).animate().scale(
              begin: const Offset(0, 0),
              end: const Offset(1, 1),
              duration: 500.ms,
              curve: Curves.elasticOut,
            ),
        const SizedBox(height: AppSpacing.xxl),
        Text('Email envoyé !', style: AppTextStyles.display)
            .animate()
            .fadeIn(duration: 400.ms, delay: 300.ms),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Si un compte existe avec l\'adresse $email, vous recevrez un lien de réinitialisation.',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms, delay: 380.ms),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Vérifiez également vos spams.',
          style: AppTextStyles.caption,
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms, delay: 420.ms),
        const SizedBox(height: AppSpacing.xxxl),
        OutlinedButton(
          onPressed: () => context.go('/login'),
          child: const Text('Retour à la connexion'),
        ).animate().fadeIn(duration: 400.ms, delay: 480.ms),
      ],
    );
  }
}
