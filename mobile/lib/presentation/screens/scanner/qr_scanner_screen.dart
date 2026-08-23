import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../providers/report_form_provider.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;
  bool _torchOn = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    setState(() => _isProcessing = true);
    await _controller.stop();

    final uuid = _extractUuid(barcode!.rawValue!);
    if (uuid == null) {
      if (mounted) {
        SnackbarHelper.showError(context, 'QR Code invalide. Réessayez.');
        await _controller.start();
        setState(() => _isProcessing = false);
      }
      return;
    }

    final success =
        await ref.read(reportFormProvider.notifier).loadVehicle(uuid);

    if (!mounted) return;

    if (success) {
      final vehicle = ref.read(reportFormProvider).vehicle!;
      context.push('/vehicle-confirmation', extra: {
        'uuid': vehicle.uuid,
        'label': vehicle.label,
        'reference': vehicle.reference,
        'supportTypeCode': vehicle.supportTypeCode,
        'supportTypeLabel': vehicle.supportTypeLabel,
      });
    } else {
      final error = ref.read(reportFormProvider).error;
      SnackbarHelper.showError(context, error ?? 'Véhicule introuvable.');
      await _controller.start();
      setState(() => _isProcessing = false);
    }
  }

  String? _extractUuid(String raw) {
    try {
      final uri = Uri.parse(raw);
      final segments = uri.pathSegments;
      if (segments.isNotEmpty && _isValidUuid(segments.last)) {
        return segments.last;
      }
    } catch (_) {}
    if (_isValidUuid(raw)) return raw;
    return null;
  }

  bool _isValidUuid(String value) {
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}'
      r'-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return uuidRegex.hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(reportFormProvider).isLoading;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Scanner ───────────────────────────────────────────────────────
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // ── Dark overlay with cutout ──────────────────────────────────────
          CustomPaint(
            painter: _ScanOverlayPainter(),
            child: const SizedBox.expand(),
          ),

          // ── Top bar ───────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ScanIconBtn(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => context.pop(),
                  ),
                  _ScanIconBtn(
                    icon: _torchOn
                        ? Icons.flash_on_rounded
                        : Icons.flash_off_rounded,
                    onTap: () {
                      setState(() => _torchOn = !_torchOn);
                      _controller.toggleTorch();
                    },
                  ),
                ],
              ),
            ),
          ),

          // ── Center label ──────────────────────────────────────────────────
          const Positioned(
            bottom: 220,
            left: 0,
            right: 0,
            child: _ScanHint(),
          ),

          // ── Bottom sheet ──────────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.xl,
                AppSpacing.xxl,
                AppSpacing.xxxl,
              ),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(26),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Scannez pour signaler',
                    style: AppTextStyles.h2,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Visez le QR code affiché à l\'arrêt ou à bord\ndu véhicule pour ouvrir un signalement.',
                    style: AppTextStyles.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // ── Loading overlay ───────────────────────────────────────────────
          if (isLoading || _isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Scan Icon Button ──────────────────────────────────────────────────────────

class _ScanIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ScanIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

// ── Scan Hint ─────────────────────────────────────────────────────────────────

class _ScanHint extends StatelessWidget {
  const _ScanHint();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'RECHERCHE DU CODE…',
          style: AppTextStyles.monoLabel.copyWith(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

// ── Overlay Painter ───────────────────────────────────────────────────────────

class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cutoutSize = 240.0;
    final centerY = size.height * 0.42;
    final cutoutRect = Rect.fromCenter(
      center: Offset(size.width / 2, centerY),
      width: cutoutSize,
      height: cutoutSize,
    );

    // Dark overlay
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.62);
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..addRRect(
            RRect.fromRectAndRadius(cutoutRect, const Radius.circular(18)),
          ),
      ),
      paint,
    );

    // Corner brackets
    final corner = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 28.0;
    final l = cutoutRect.left;
    final t = cutoutRect.top;
    final r = cutoutRect.right;
    final b = cutoutRect.bottom;

    // Top-left
    canvas.drawLine(Offset(l, t + len), Offset(l, t), corner);
    canvas.drawLine(Offset(l, t), Offset(l + len, t), corner);
    // Top-right
    canvas.drawLine(Offset(r - len, t), Offset(r, t), corner);
    canvas.drawLine(Offset(r, t), Offset(r, t + len), corner);
    // Bottom-left
    canvas.drawLine(Offset(l, b - len), Offset(l, b), corner);
    canvas.drawLine(Offset(l, b), Offset(l + len, b), corner);
    // Bottom-right
    canvas.drawLine(Offset(r - len, b), Offset(r, b), corner);
    canvas.drawLine(Offset(r, b), Offset(r, b - len), corner);

    // Scan line animation via gradient
    final scanLine = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          AppColors.primary.withValues(alpha: 0.8),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTRB(l, t, r, b));
    canvas.drawLine(
      Offset(l, centerY),
      Offset(r, centerY),
      scanLine..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
