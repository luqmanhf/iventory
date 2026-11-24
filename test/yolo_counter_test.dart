import 'package:flutter_test/flutter_test.dart';
import 'package:iventory/core/ai/yolo_counter_service.dart';

void main() {
  group('YOLOv8 Nano Counter & NMS Tests', () {
    final yoloService = YoloCounterService();

    test('Eliminates overlapping redundant boxes using NMS', () {
      final boxes = [
        const DetectedObject(
          boundingBox: BoundingBox(left: 10, top: 10, width: 50, height: 50),
          confidence: 0.95,
          label: 'Box',
          classId: 0,
        ),
        // Kotak tumpang tindih tinggi (>45% IoU) dengan confidence lebih rendah
        const DetectedObject(
          boundingBox: BoundingBox(left: 12, top: 12, width: 50, height: 50),
          confidence: 0.80,
          label: 'Box',
          classId: 0,
        ),
        // Kotak terpisah jauh
        const DetectedObject(
          boundingBox: BoundingBox(left: 120, top: 120, width: 50, height: 50),
          confidence: 0.90,
          label: 'Box',
          classId: 0,
        ),
      ];

      final suppressed = yoloService.applyNms(boxes);
      expect(suppressed.length, equals(2));
      expect(suppressed.first.confidence, equals(0.95));
      expect(suppressed.last.confidence, equals(0.90));
    });

    test('Simulates live camera frame detections', () {
      final detections = yoloService.simulateLiveFrameDetection(
        300,
        300,
        baseCount: 4,
      );
      expect(detections, isNotEmpty);
      expect(detections.length, inInclusiveRange(3, 5));
    });
  });
}
