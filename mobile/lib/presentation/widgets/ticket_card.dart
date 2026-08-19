import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_shadows.dart';

/// Carte style ticket de transport — élément signature de l'identité Transtu.
/// Reproduit le design du mockup : ticket principal + stub latéral avec encoche.
class TicketCard extends StatelessWidget {
  final String       route;
  final String       title;
  final String       message;
  final String       statusCode;
  final VoidCallback? onTap;

  const TicketCard({
    super.key,
    required this.route,
    required this.title,
    required this.message,
    required this.statusCode,
    this.onTap,
  });

  String get _statusLabel => switch (statusCode) {
        'IN_PROGRESS' => 'EN COURS',
        'RESOLVED'    => 'RÉSOLU',
        'CLOSED'      => 'CLÔTURÉ',
        _             => 'ENVOYÉ',
      };

  Color get _statusBg => switch (statusCode) {
        'IN_PROGRESS' => AppColors.statusProgressBg,
        'RESOLVED'    => AppColors.statusResolvedBg,
        'CLOSED'      => AppColors.statusClosedBg,
        _             => AppColors.statusNewBg,
      };

  Color get _statusText => switch (statusCode) {
        'IN_PROGRESS' => AppColors.statusProgressText,
        'RESOLVED'    => AppColors.statusResolvedText,
        'CLOSED'      => AppColors.statusClosedText,
        _             => AppColors.statusNewText,
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color:        AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border:       Border.all(color: AppColors.border),
          boxShadow:    AppShadows.card,
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // ── Main content ──────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Route label
                      Text(
                        route.toUpperCase(),
                        style: AppTextStyles.monoLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),

                      // Title
                      Text(
                        title,
                        style: AppTextStyles.h3,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),

                      // Message
                      Text(
                        message,
                        style: AppTextStyles.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Divider with notches ──────────────────────────────────────
              _TicketDivider(),

              // ── Stub ──────────────────────────────────────────────────────
              _TicketStub(
                label:    _statusLabel,
                bgColor:  _statusBg,
                txtColor: _statusText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Divider avec encoches ─────────────────────────────────────────────────────

class _TicketDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Ligne pointillée verticale
          Positioned.fill(
            child: CustomPaint(painter: _DashedLinePainter()),
          ),
          // Encoche haut
          Positioned(
            top:  -7,
            left: 0,
            child: _Notch(),
          ),
          // Encoche bas
          Positioned(
            bottom: -7,
            left:   0,
            child:  _Notch(),
          ),
        ],
      ),
    );
  }
}

class _Notch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width:  14,
      height: 14,
      decoration: const BoxDecoration(
        color: AppColors.background,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color       = AppColors.border
      ..strokeWidth = 1
      ..style       = PaintingStyle.stroke;

    const dashHeight = 4.0;
    const dashSpace  = 3.0;
    double startY    = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Stub latéral ──────────────────────────────────────────────────────────────

class _TicketStub extends StatelessWidget {
  final String label;
  final Color  bgColor;
  final Color  txtColor;

  const _TicketStub({
    required this.label,
    required this.bgColor,
    required this.txtColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.horizontal(
          right: Radius.circular(16),
        ),
      ),
      child: Center(
        child: RotatedBox(
          quarterTurns: 3,
          child: Text(
            label,
            style: AppTextStyles.monoLabel.copyWith(
              color:      txtColor,
              fontWeight: FontWeight.w700,
              fontSize:   9,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}