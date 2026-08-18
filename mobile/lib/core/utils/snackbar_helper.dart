import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class SnackbarHelper {
  SnackbarHelper._();

  static void showError(BuildContext context, String message) {
    _show(
      context: context,
      message: _clean(message),
      color: AppColors.error,
      icon: Icons.error_outline_rounded,
    );
  }

  static void showSuccess(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      color: AppColors.success,
      icon: Icons.check_circle_outline_rounded,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      color: AppColors.primary,
      icon: Icons.info_outline_rounded,
    );
  }

  static void _show({
    required BuildContext context,
    required String message,
    required Color color,
    required IconData icon,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: color,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 4,
        ),
      );
  }

  static String _clean(String message) {
    if (message.isEmpty) return 'Une erreur est survenue.';
    if (message.startsWith('DioException')) return 'Une erreur est survenue.';
    if (message.startsWith('Exception:')) {
      return message.replaceFirst('Exception:', '').trim();
    }
    if (message.contains('EMAIL_NOT_VERIFIED')) return 'Email non vérifié.';
    if (message.contains('SocketException')) {
      return 'Vérifiez votre connexion internet.';
    }
    return message;
  }
}
