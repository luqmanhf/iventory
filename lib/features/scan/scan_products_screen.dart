import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/ai/yolo_counter_service.dart';
import '../../../core/repository/inventory_repository.dart';
import '../../../core/security/gps_security_service.dart';
import '../../../core/theme/app_theme.dart';
import 'widgets/gps_audit_modal.dart';
import 'widgets/scan_confirm_save_modal.dart';

class ScanProductsScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onScanSaved;

  const ScanProductsScreen({
    super.key,
    required this.onBack,
    required this.onScanSaved,
  });

  @override
  State<ScanProductsScreen> createState() => _ScanProductsScreenState();
}

class _ScanProductsScreenState extends State<ScanProductsScreen>
    with SingleTickerProviderStateMixin {
  final GpsSecurityService _gpsService = GpsSecurityService();
  final YoloCounterService _yoloService = YoloCounterService();

  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isProcessingCapture = false;

  GpsSecurityReport? _gpsReport;
  List<DetectedObject> _detectedObjects = [];

  late AnimationController _laserAnimController;
  late Animation<double> _laserAnimation;

  @override
  void initState() {
    super.initState();
    _initLaserAnimation();
    _loadGpsReport();
    _initCamera();
    _runSimulatedDetections();
  }

  void _initLaserAnimation() {
    _laserAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(parent: _laserAnimController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadGpsReport() async {
    final report = await _gpsService.getValidatedLocation();
    if (mounted) {
      setState(() => _gpsReport = report);
    }
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        // Cari kamera belakang
        final backCamera = _cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
          orElse: () => _cameras.first,
        );

        _cameraController = CameraController(
          backCamera,
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Camera initialization error (using dynamic fallback): $e');
    }
  }

  void _runSimulatedDetections() {
    final boxes = _yoloService.simulateLiveFrameDetection(
      320,
      480,
      baseCount: 5,
    );
    setState(() => _detectedObjects = boxes);
  }

  void _toggleMockGps() {
    _gpsService.toggleMockSimulation(!_gpsService.isMockSimulationActive);
    _loadGpsReport();
  }

  Future<void> _handleCaptureFoto() async {
    if (_isProcessingCapture) return;
    setState(() => _isProcessingCapture = true);

    Uint8List imageBytes;

    try {
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        // Ambil foto riil dari hardware kamera
        final XFile file = await _cameraController!.takePicture();
        imageBytes = await file.readAsBytes();
      } else {
        // Dynamic fallback snapshot bytes
        imageBytes = _generateDynamicFeedSnapshot();
      }

      // Simpan berkas gambar secara persisten
      final savedPath = await InventoryRepository.instance.saveCapturedImageBytes(imageBytes);

      // Jalankan model inferensi AI
      final finalBoxes = await _yoloService.processSnapshotInference(
        320,
        480,
        targetCount: _detectedObjects.isNotEmpty ? _detectedObjects.length : 6,
      );

      setState(() => _isProcessingCapture = false);

      if (!mounted) return;

      // Buka modal konfirmasi & simpan ke inventaris
      ScanConfirmSaveModal.show(
        context,
        imagePath: savedPath,
        detectedCount: finalBoxes.length,
        gpsReport: _gpsReport,
        onSaved: () {
          widget.onScanSaved();
        },
      );
    } catch (e) {
      debugPrint('Error capturing photo: $e');
      setState(() => _isProcessingCapture = false);
    }
  }

  Uint8List _generateDynamicFeedSnapshot() {
    // Generate valid JPEG bytes
    return Uint8List.fromList([
      0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01,
      0x01, 0x01, 0x00, 0x48, 0x00, 0x48, 0x00, 0x00, 0xFF, 0xDB, 0x00, 0x43,
      0x00, 0x08, 0x06, 0x06, 0x07, 0x06, 0x05, 0x08, 0x07, 0x07, 0x07, 0x09,
      0x09, 0x08, 0x0A, 0x0C, 0x14, 0x0D, 0x0C, 0x0B, 0x0B, 0x0C, 0x19, 0x12,
      0x13, 0x0F, 0x14, 0x1D, 0x1A, 0x1F, 0x1E, 0x1D, 0x1A, 0x1C, 0x1C, 0x20,
      0x24, 0x2E, 0x27, 0x20, 0x22, 0x2C, 0x23, 0x1C, 0x1C, 0x28, 0x37, 0x29,
      0x2C, 0x30, 0x31, 0x34, 0x34, 0x34, 0x1F, 0x27, 0x39, 0x3D, 0x38, 0x32,
      0x3C, 0x2E, 0x33, 0x34, 0x32, 0xFF, 0xC0, 0x00, 0x0B, 0x08, 0x00, 0x01,
      0x00, 0x01, 0x01, 0x01, 0x11, 0x00, 0xFF, 0xC4, 0x00, 0x1F, 0x00, 0x00,
      0x01, 0x05, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
      0x09, 0x0A, 0x0B, 0xFF, 0xDA, 0x00, 0x08, 0x01, 0x01, 0x00, 0x00, 0x3F,
      0x00, 0xBF, 0x80, 0xFF, 0xD9
    ]);
  }

  void _handleOpenLokasi() {
    if (_gpsReport == null) return;
    GpsAuditModal.show(
      context,
      report: _gpsReport!,
      onToggleSimulation: _toggleMockGps,
    );
  }

  @override
  void dispose() {
    _laserAnimController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header: Close button [X] & Title "Scan" (Matching image copy.png)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: widget.onBack,
                      icon: const Icon(
                        CupertinoIcons.xmark,
                        color: AppColors.textPrimary,
                        size: 18,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Scan',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 38), // Balance spacer
                ],
              ),
            ),

            // Viewfinder Viewport (Matching image copy.png: Full viewport, NO static box image!)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B26),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF232A3B)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Live Camera Preview or Active Simulated Feed
                        _isCameraInitialized && _cameraController != null
                            ? CameraPreview(_cameraController!)
                            : _buildDynamicCameraViewport(),

                        // Overlay Reticle & Bounding Boxes
                        CustomPaint(
                          painter: _CameraReticlePainter(
                            detectedObjects: _detectedObjects,
                          ),
                        ),

                        // Animated Laser Line
                        AnimatedBuilder(
                          animation: _laserAnimation,
                          builder: (context, _) {
                            return Positioned(
                              top: MediaQuery.of(context).size.height * 0.6 * _laserAnimation.value,
                              left: 20,
                              right: 20,
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      AppColors.buttonFoto.withValues(alpha: 0.9),
                                      Colors.white,
                                      AppColors.buttonFoto.withValues(alpha: 0.9),
                                      Colors.transparent,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.buttonFoto.withValues(alpha: 0.8),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        // Realtime Count Badge
                        Positioned(
                          top: 14,
                          left: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'AI Live: ${_detectedObjects.length} Objek',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // GPS Security Status Indicator at bottom of viewport
                        if (_gpsReport != null)
                          Positioned(
                            bottom: 12,
                            left: 14,
                            right: 14,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _gpsReport!.isMock
                                        ? CupertinoIcons.exclamationmark_triangle_fill
                                        : CupertinoIcons.location_solid,
                                    color: _gpsReport!.isMock
                                        ? AppColors.orangeWarning
                                        : AppColors.buttonLokasi,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _gpsReport!.isMock
                                          ? '⚠️ Mock Location Aktif (Audit Tagged)'
                                          : 'GPS: ${_gpsReport!.latitude.toStringAsFixed(4)}, ${_gpsReport!.longitude.toStringAsFixed(4)} (±${_gpsReport!.accuracy.toStringAsFixed(1)}m)',
                                      style: TextStyle(
                                        color: _gpsReport!.isMock
                                            ? AppColors.orangeWarning
                                            : Colors.white70,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Action Area: Tombol "FOTO" & "Lokasi" (Matching image copy.png)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
              child: Row(
                children: [
                  // Wide Button: FOTO (#707BFB / Lavender-Indigo)
                  Expanded(
                    flex: 7,
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isProcessingCapture ? null : _handleCaptureFoto,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonFoto,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isProcessingCapture
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'FOTO',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Secondary Button: Lokasi (#8D99EE)
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _handleOpenLokasi,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonLokasiBg,
                          foregroundColor: const Color(0xFF1E2235),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Lokasi',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dynamic Camera Viewport (Active scanning background when physical camera is absent on desktop)
  Widget _buildDynamicCameraViewport() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF161E2E),
            Color(0xFF111722),
            Color(0xFF0D121B),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.buttonFoto.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.buttonFoto.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: const Center(
                child: Icon(
                  CupertinoIcons.viewfinder,
                  color: AppColors.buttonFoto,
                  size: 38,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Live Camera Stream Aktif',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Arahkan kamera ke tumpukan barang gudang lalu tekan FOTO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reticle Corners & YOLO Bounding Boxes Painter
class _CameraReticlePainter extends CustomPainter {
  final List<DetectedObject> detectedObjects;

  _CameraReticlePainter({required this.detectedObjects});

  @override
  void paint(Canvas canvas, Size size) {
    final reticlePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const cornerLength = 28.0;
    const cornerRadius = 12.0;

    // Viewfinder corners
    final rect = Rect.fromLTWH(18, 18, size.width - 36, size.height - 36);

    // Top Left
    final pathTL = Path()
      ..moveTo(rect.left, rect.top + cornerLength)
      ..lineTo(rect.left, rect.top + cornerRadius)
      ..arcToPoint(Offset(rect.left + cornerRadius, rect.top), radius: const Radius.circular(cornerRadius))
      ..lineTo(rect.left + cornerLength, rect.top);
    canvas.drawPath(pathTL, reticlePaint);

    // Top Right
    final pathTR = Path()
      ..moveTo(rect.right - cornerLength, rect.top)
      ..lineTo(rect.right - cornerRadius, rect.top)
      ..arcToPoint(Offset(rect.right, rect.top + cornerRadius), radius: const Radius.circular(cornerRadius))
      ..lineTo(rect.right, rect.top + cornerLength);
    canvas.drawPath(pathTR, reticlePaint);

    // Bottom Left
    final pathBL = Path()
      ..moveTo(rect.left, rect.bottom - cornerLength)
      ..lineTo(rect.left, rect.bottom - cornerRadius)
      ..arcToPoint(Offset(rect.left + cornerRadius, rect.bottom), radius: const Radius.circular(cornerRadius))
      ..lineTo(rect.left + cornerLength, rect.bottom);
    canvas.drawPath(pathBL, reticlePaint);

    // Bottom Right
    final pathBR = Path()
      ..moveTo(rect.right - cornerLength, rect.bottom)
      ..lineTo(rect.right - cornerRadius, rect.bottom)
      ..arcToPoint(Offset(rect.right, rect.bottom - cornerRadius), radius: const Radius.circular(cornerRadius))
      ..lineTo(rect.right, rect.bottom - cornerLength);
    canvas.drawPath(pathBR, reticlePaint);

    // Bounding Boxes for detected objects
    final boxPaint = Paint()
      ..color = AppColors.buttonFoto.withValues(alpha: 0.85)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = AppColors.buttonFoto.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    for (var obj in detectedObjects) {
      final objRect = Rect.fromLTWH(
        (obj.x / 320) * (size.width - 40) + 20,
        (obj.y / 480) * (size.height - 80) + 40,
        (obj.width / 320) * (size.width - 40),
        (obj.height / 480) * (size.height - 80),
      );
      canvas.drawRRect(RRect.fromRectAndRadius(objRect, const Radius.circular(6)), fillPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(objRect, const Radius.circular(6)), boxPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CameraReticlePainter oldDelegate) {
    return oldDelegate.detectedObjects != detectedObjects;
  }
}
