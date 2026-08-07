import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_text_styles.dart';

enum AppButtonVariant { primary, outlined, text, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                  Text(label, style: _textStyle),
                ],
              )
            : Text(label, style: _textStyle);

    return switch (variant) {
      AppButtonVariant.primary => _PrimaryButton(
          onPressed: isLoading ? null : onPressed,
          height: height,
          child: child,
        ),
      AppButtonVariant.outlined => _OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          height: height,
          child: child,
        ),
      AppButtonVariant.text => _TextButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        ),
      AppButtonVariant.danger => _DangerButton(
          onPressed: isLoading ? null : onPressed,
          height: height,
          child: child,
        ),
    };
  }

  TextStyle get _textStyle => switch (variant) {
        AppButtonVariant.primary => AppTextStyles.button,
        AppButtonVariant.danger => AppTextStyles.button,
        AppButtonVariant.outlined => AppTextStyles.button.copyWith(
            color: AppColors.primary,
          ),
        AppButtonVariant.text => AppTextStyles.button.copyWith(
            color: AppColors.primary,
          ),
      };
}

class _PrimaryButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double height;

  const _PrimaryButton({
    required this.child,
    required this.onPressed,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}

class _OutlinedButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double height;

  const _OutlinedButton({
    required this.child,
    required this.onPressed,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}

class _TextButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;

  const _TextButton({required this.child, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: onPressed, child: child);
  }
}

class _DangerButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double height;

  const _DangerButton({
    required this.child,
    required this.onPressed,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.medium,
          ),
        ),
        child: child,
      ),
    );
  }
}
