import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_shadows.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      height: 66,
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.nav,
      ),
      child: Row(
        children: [
          // Accueil
          _NavItem(
            icon: Icons.home_outlined,
            iconFill: Icons.home_rounded,
            label: 'Accueil',
            isActive: currentIndex == 0,
            onTap: () => onTap(0),
          ),

          // Suivi
          _NavItem(
            icon: Icons.track_changes_outlined,
            iconFill: Icons.track_changes_rounded,
            label: 'Suivi',
            isActive: currentIndex == 1,
            onTap: () => onTap(1),
          ),

          // Scanner — bouton central flottant
          _NavScanButton(onTap: () => onTap(2)),

          // Profil
          _NavItem(
            icon: Icons.person_outline_rounded,
            iconFill: Icons.person_rounded,
            label: 'Profil',
            isActive: currentIndex == 3,
            onTap: () => onTap(3),
          ),

          // Paramètres / vide
          _NavItem(
            icon: Icons.settings_outlined,
            iconFill: Icons.settings_rounded,
            label: '',
            isActive: false,
            onTap: () {},
            hidden: true,
          ),
        ],
      ),
    );
  }
}

// ── Nav Item ──────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData iconFill;
  final String label;
  final bool isActive;
  final bool hidden;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.iconFill,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.hidden = false,
  });

  @override
  Widget build(BuildContext context) {
    if (hidden) return const Expanded(child: SizedBox());

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? iconFill : icon,
              size: 20,
              color: isActive ? Colors.white : const Color(0xFF8FA0AB),
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                label,
                style: AppTextStyles.monoLabel.copyWith(
                  fontSize: 9,
                  color: isActive ? AppColors.accent : const Color(0xFF8FA0AB),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Scan Button central flottant ──────────────────────────────────────────────

class _NavScanButton extends StatelessWidget {
  final VoidCallback onTap;
  const _NavScanButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            top: -22,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.background,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.65),
                      blurRadius: 18,
                      spreadRadius: -6,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            child: Text(
              'Scanner',
              style: AppTextStyles.monoLabel.copyWith(
                fontSize: 8.5,
                color: const Color(0xFF8FA0AB),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
