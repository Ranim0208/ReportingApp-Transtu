import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
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

    final rawValue = barcode!.rawValue!;
    final uuid = _extractUuid(rawValue);

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
    // Try as URL: extract last path segment
    try {
      final uri = Uri.parse(raw);
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        final last = segments.last;
        if (_isValidUuid(last)) return last;
      }
    } catch (_) {}

    // Try raw UUID
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
          // Scanner
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Overlay with cutout
          _ScannerOverlay(),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  IconButton(
                    icon: Icon(
                      _torchOn ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() => _torchOn = !_torchOn);
                      _controller.toggleTorch();
                    },
                  ),
                ],
              ),
            ),
          ),

          // Bottom instruction card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Icon(
                    Icons.qr_code_scanner,
                    color: AppColors.primary,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pointez le QR Code affiché dans votre véhicule',
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Loading overlay
          if (isLoading || _isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Scanner Overlay ───────────────────────────────────────────────────────────

class _ScannerOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OverlayPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cutoutSize = 250.0;
    final cutoutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 60),
      width: cutoutSize,
      height: cutoutSize,
    );

    // Dark overlay
    final paint = Paint()..color = Colors.black54;
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..addRRect(
            RRect.fromRectAndRadius(cutoutRect, const Radius.circular(12)),
          ),
      ),
      paint,
    );

    // Corner brackets
    final corner = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const cornerLen = 24.0;
    final l = cutoutRect.left;
    final t = cutoutRect.top;
    final r = cutoutRect.right;
    final b = cutoutRect.bottom;

    // Top-left
    canvas.drawLine(Offset(l, t + cornerLen), Offset(l, t), corner);
    canvas.drawLine(Offset(l, t), Offset(l + cornerLen, t), corner);
    // Top-right
    canvas.drawLine(Offset(r - cornerLen, t), Offset(r, t), corner);
    canvas.drawLine(Offset(r, t), Offset(r, t + cornerLen), corner);
    // Bottom-left
    canvas.drawLine(Offset(l, b - cornerLen), Offset(l, b), corner);
    canvas.drawLine(Offset(l, b), Offset(l + cornerLen, b), corner);
    // Bottom-right
    canvas.drawLine(Offset(r - cornerLen, b), Offset(r, b), corner);
    canvas.drawLine(Offset(r, b), Offset(r, b - cornerLen), corner);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
