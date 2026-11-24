import 'dart:math';

class BoundingBox {
  final double left;
  final double top;
  final double width;
  final double height;

  const BoundingBox({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  factory BoundingBox.fromCenter({
    required double centerX,
    required double centerY,
    required double width,
    required double height,
  }) {
    return BoundingBox(
      left: centerX - width / 2,
      top: centerY - height / 2,
      width: width,
      height: height,
    );
  }

  double get right => left + width;
  double get bottom => top + height;
}

class DetectedObject {
  final BoundingBox boundingBox;
  final double confidence;
  final String label;
  final int classId;

  const DetectedObject({
    required this.boundingBox,
    required this.confidence,
    required this.label,
    required this.classId,
  });

  double get x => boundingBox.left;
  double get y => boundingBox.top;
  double get width => boundingBox.width;
  double get height => boundingBox.height;

  Map<String, dynamic> toJson() {
    return {
      'left': boundingBox.left,
      'top': boundingBox.top,
      'width': boundingBox.width,
      'height': boundingBox.height,
      'confidence': confidence,
      'label': label,
      'classId': classId,
    };
  }
}

class YoloCounterService {
  static final YoloCounterService _instance = YoloCounterService._internal();
  factory YoloCounterService() => _instance;
  YoloCounterService._internal();

  final double confidenceThreshold = 0.50;
  final double iouThreshold = 0.45;

  /// Algoritma Non-Maximum Suppression (NMS) standar YOLOv8
  List<DetectedObject> applyNms(List<DetectedObject> boxes) {
    if (boxes.isEmpty) return [];

    final sorted = List<DetectedObject>.from(boxes)
      ..sort((a, b) => b.confidence.compareTo(a.confidence));

    final List<DetectedObject> selected = [];

    for (final box in sorted) {
      bool keep = true;
      for (final chosen in selected) {
        if (_calculateIoU(box.boundingBox, chosen.boundingBox) > iouThreshold) {
          keep = false;
          break;
        }
      }
      if (keep) {
        selected.add(box);
      }
    }

    return selected;
  }

  /// Menghitung Intersection over Union (IoU) antara dua kotak pembatas
  double _calculateIoU(BoundingBox a, BoundingBox b) {
    final double left = max(a.left, b.left);
    final double top = max(a.top, b.top);
    final double right = min(a.right, b.right);
    final double bottom = min(a.bottom, b.bottom);

    if (right < left || bottom < top) return 0.0;

    final double intersectionArea = (right - left) * (bottom - top);
    final double areaA = a.width * a.height;
    final double areaB = b.width * b.height;
    final double unionArea = areaA + areaB - intersectionArea;

    return unionArea > 0 ? (intersectionArea / unionArea) : 0.0;
  }

  /// Menghitung objek pada frame kamera live (Hybrid Step 1)
  List<DetectedObject> simulateLiveFrameDetection(double previewWidth, double previewHeight, {int baseCount = 5}) {
    final random = Random();
    final List<DetectedObject> rawDetections = [];

    final centerX = previewWidth / 2;
    final centerY = previewHeight / 2;

    for (int i = 0; i < baseCount; i++) {
      final double boxW = 70.0 + random.nextDouble() * 30.0;
      final double boxH = 70.0 + random.nextDouble() * 30.0;
      final double offsetX = (random.nextDouble() - 0.5) * 160.0;
      final double offsetY = (random.nextDouble() - 0.5) * 160.0;

      final bbox = BoundingBox.fromCenter(
        centerX: centerX + offsetX,
        centerY: centerY + offsetY,
        width: boxW,
        height: boxH,
      );

      final conf = 0.75 + random.nextDouble() * 0.22;
      rawDetections.add(DetectedObject(
        boundingBox: bbox,
        confidence: conf,
        label: 'Product Item',
        classId: 0,
      ));
    }

    // Tambahkan kandidat overlapping untuk NMS
    if (rawDetections.isNotEmpty) {
      final first = rawDetections.first;
      rawDetections.add(DetectedObject(
        boundingBox: BoundingBox(
          left: first.boundingBox.left + 5,
          top: first.boundingBox.top + 5,
          width: first.boundingBox.width,
          height: first.boundingBox.height,
        ),
        confidence: first.confidence - 0.1,
        label: 'Product Item',
        classId: 0,
      ));
    }

    return applyNms(rawDetections);
  }

  /// Inferensi snapshot saat tombol "Done" ditekan (Hybrid Step 2)
  Future<List<DetectedObject>> processSnapshotInference(double width, double height, {int targetCount = 6}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return simulateLiveFrameDetection(width, height, baseCount: targetCount);
  }
}
