import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../data/datasources/remote/api_client.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String email;
  const VerifyEmailScreen({super.key, required this.email});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  bool get _isComplete => _code.length == 6;

  Future<void> _verify() async {
    if (!_isComplete) {
      SnackbarHelper.showError(context, 'Entrez les 6 chiffres du code.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(apiClientProvider).verifyEmail(
            email: widget.email,
            code: _code,
          );
      if (!mounted) return;

      // Marque email comme vérifié localement
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auth_email_verified', true);

      if (!mounted) return;
      SnackbarHelper.showSuccess(context, 'Email vérifié ! Connectez-vous.');
      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      // Vérifie si le compte est déjà vérifié
      SnackbarHelper.showError(
        context,
        'Code invalide ou expiré. Demandez un nouveau code.',
      );
    }
  }

  Future<void> _resend() async {
    setState(() => _isResending = true);
    try {
      await ref.read(apiClientProvider).resendVerification(widget.email);
      if (!mounted) return;
      setState(() => _isResending = false);
      SnackbarHelper.showSuccess(
          context, 'Nouveau code envoyé à ${widget.email}');
      // Clear fields
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes.first.requestFocus();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isResending = false);
      SnackbarHelper.showError(context, 'Erreur lors de l\'envoi du code.');
    }
  }

  void _onDigitChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  // ignore: deprecated_member_use
  void _onKeyDown(RawKeyEvent event, int index) {
    // ignore: deprecated_member_use
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Bloque le retour arrière — l'utilisateur doit vérifier son email
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xxxl),

                // Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: AppRadius.large,
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_rounded,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: AppSpacing.xl),

                Text('Vérifiez votre email', style: AppTextStyles.display)
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 80.ms),

                const SizedBox(height: AppSpacing.sm),

                RichText(
                  text: TextSpan(
                    text: 'Un code à 6 chiffres a été envoyé à ',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      TextSpan(
                        text: widget.email,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 120.ms),

                const SizedBox(height: AppSpacing.xxxl),

                // OTP fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (i) {
                    return SizedBox(
                      width: 48,
                      height: 56,
                      // ignore: deprecated_member_use
                      child: RawKeyboardListener(
                        focusNode: FocusNode(),
                        onKey: (event) => _onKeyDown(event, i),
                        child: TextFormField(
                          controller: _controllers[i],
                          focusNode: _focusNodes[i],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: AppTextStyles.h1.copyWith(
                            color: AppColors.primary,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: _controllers[i].text.isNotEmpty
                                ? AppColors.primaryLight
                                : AppColors.surface,
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.medium,
                              borderSide:
                                  const BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: AppRadius.medium,
                              borderSide: const BorderSide(
                                  color: AppColors.primary, width: 2),
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (v) => _onDigitChanged(v, i),
                        ),
                      ),
                    );
                  }),
                ).animate().fadeIn(duration: 400.ms, delay: 160.ms),

                const SizedBox(height: AppSpacing.xxxl),

                // Verify button
                ElevatedButton(
                  onPressed: _isLoading || !_isComplete ? null : _verify,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Vérifier'),
                ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                const SizedBox(height: AppSpacing.lg),

                // Resend
                Center(
                  child: TextButton(
                    onPressed: _isResending ? null : _resend,
                    child: _isResending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : Text(
                            'Renvoyer le code',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 240.ms),

                const SizedBox(height: AppSpacing.lg),

                // Info
                Center(
                  child: Text(
                    'Vérifiez également vos spams.',
                    style: AppTextStyles.caption,
                    textAlign: TextAlign.center,
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 280.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
