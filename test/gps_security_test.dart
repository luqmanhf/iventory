import 'package:flutter_test/flutter_test.dart';
import 'package:iventory/core/security/gps_security_service.dart';

void main() {
  group('GPS Anti-Spoofing & Security Tests', () {
    final gpsService = GpsSecurityService();

    test('Verifies trusted GPS coordinates by default', () async {
      gpsService.toggleMockSimulation(false);
      final report = await gpsService.getValidatedLocation();

      expect(report.isMocked, isFalse);
      expect(report.trustLevel, equals(TrustLevel.verified));
      expect(report.accuracy, greaterThan(1.0));
      expect(report.securitySignature, isNotEmpty);
      expect(report.securityFlags, isEmpty);
    });

    test('Flags mock location as UNTRUSTED WARNING when Fake GPS is active', () async {
      gpsService.toggleMockSimulation(true);
      final report = await gpsService.getValidatedLocation();

      expect(report.isMocked, isTrue);
      expect(report.trustLevel, equals(TrustLevel.warning));
      expect(report.securityFlags, contains('MOCK_LOCATION_ACTIVE'));
      expect(report.securityFlags, contains('DEVELOPER_OPTIONS_MOCK_APP'));
      expect(report.securitySignature, isNotEmpty);
    });
  });
}
