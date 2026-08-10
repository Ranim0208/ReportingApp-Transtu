import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';
import '../providers/auth_provider.dart';

class Step3Contact extends StatelessWidget {
  final AuthState authState;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;

  const Step3Contact({
    super.key,
    required this.authState,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vos coordonnées', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Optionnel — permet de recevoir le suivi par email.',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xxl),
          if (authState.isLoggedIn)
            _LoggedInCard(authState: authState)
          else
            _GuestFields(
              nameController: nameController,
              emailController: emailController,
              phoneController: phoneController,
            ),
        ],
      ),
    );
  }
}

class _LoggedInCard extends StatelessWidget {
  final AuthState authState;
  const _LoggedInCard({required this.authState});

  @override
  Widget build(BuildContext context) {
    final name = authState.passenger!.name;
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: AppRadius.large,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary,
            child: Text(
              initials,
              style: AppTextStyles.h3.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  authState.passenger!.email,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _GuestFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;

  const _GuestFields({
    required this.nameController,
    required this.emailController,
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info banner
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.infoLight,
            borderRadius: AppRadius.medium,
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: AppColors.info, size: 16),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Sans email, vous ne recevrez pas le lien de suivi.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.info,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nom (optionnel)',
            prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email (optionnel)',
            prefixIcon: Icon(Icons.mail_outline_rounded, size: 20),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Téléphone (optionnel)',
            prefixIcon: Icon(Icons.phone_outlined, size: 20),
            prefixText: '+216 ',
          ),
        ),
      ],
    );
  }
}
