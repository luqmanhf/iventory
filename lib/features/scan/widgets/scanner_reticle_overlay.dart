import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ai/yolo_counter_service.dart';

class ScannerReticleOverlay extends StatefulWidget {
  final List<DetectedObject> detectedObjects;

  const ScannerReticleOverlay({
    super.key,
    required this.detectedObjects,
  });

  @override
  State<ScannerReticleOverlay> createState() => _ScannerReticleOverlayState();
}

class _ScannerReticleOverlayState extends State<ScannerReticleOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.1, end: 0.9).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;

        return Stack(
          children: [
            // Frame Rounded Reticle Corners (Matching image.png)
            CustomPaint(
              size: Size(width, height),
              painter: _ReticleCornerPainter(),
            ),

            // Translucent 3D Product Cube Visual (Center of Viewfinder)
            Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF67B6FF).withValues(alpha: 0.85),
                      const Color(0xFF1E88E5).withValues(alpha: 0.95),
                      const Color(0xFF0D47A1).withValues(alpha: 0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 2,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Highlight Facet for 3D Cube illusion
                    Positioned(
                      top: 12,
                      left: 12,
                      right: 12,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const Center(
                      child: Icon(
                        Icons.inventory_2_outlined,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Animated Scanning Laser Line
            AnimatedBuilder(
              animation: _scanAnimation,
              builder: (context, child) {
                return Positioned(
                  top: height * _scanAnimation.value,
                  left: 20,
                  right: 20,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.cyan.withValues(alpha: 0.8),
                          Colors.white,
                          AppColors.cyan.withValues(alpha: 0.8),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cyan.withValues(alpha: 0.8),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Bounding Boxes Overlay (YOLOv8 Detection)
            for (final obj in widget.detectedObjects)
              Positioned(
                left: obj.boundingBox.left,
                top: obj.boundingBox.top,
                width: obj.boundingBox.width,
                height: obj.boundingBox.height,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: 0.8),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.primaryBlue.withValues(alpha: 0.12),
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${(obj.confidence * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ReticleCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFBAC7D5)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double w = size.width;
    final double h = size.height;
    const double cornerLength = 40.0;
    const double radius = 24.0;

    // Top-Left
    final pathTL = Path()
      ..moveTo(0, cornerLength)
      ..lineTo(0, radius)
      ..arcToPoint(const Offset(radius, 0), radius: const Radius.circular(radius))
      ..lineTo(cornerLength, 0);
    canvas.drawPath(pathTL, paint);

    // Top-Right
    final pathTR = Path()
      ..moveTo(w - cornerLength, 0)
      ..lineTo(w - radius, 0)
      ..arcToPoint(Offset(w, radius), radius: const Radius.circular(radius))
      ..lineTo(w, cornerLength);
    canvas.drawPath(pathTR, paint);

    // Bottom-Left
    final pathBL = Path()
      ..moveTo(0, h - cornerLength)
      ..lineTo(0, h - radius)
      ..arcToPoint(Offset(radius, h), radius: const Radius.circular(radius))
      ..lineTo(cornerLength, h);
    canvas.drawPath(pathBL, paint);

    // Bottom-Right
    final pathBR = Path()
      ..moveTo(w - cornerLength, h)
      ..lineTo(w - radius, h)
      ..arcToPoint(Offset(w, h - radius), radius: const Radius.circular(radius))
      ..lineTo(w, h - cornerLength);
    canvas.drawPath(pathBR, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
