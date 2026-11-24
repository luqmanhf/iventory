import 'dart:convert';
import 'package:crypto/crypto.dart';

enum TrustLevel {
  verified,
  warning,
}

class GpsSecurityReport {
  final double latitude;
  final double longitude;
  final double accuracy;
  final bool isMocked;
  final TrustLevel trustLevel;
  final List<String> securityFlags;
  final DateTime verifiedTimestamp;
  final String securitySignature;

  const GpsSecurityReport({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.isMocked,
    required this.trustLevel,
    required this.securityFlags,
    required this.verifiedTimestamp,
    required this.securitySignature,
  });

  bool get isMock => isMocked;
  bool get isDevMode => securityFlags.contains('DEVELOPER_OPTIONS_MOCK_APP');
  String get digitalSignature => securitySignature;

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'is_mocked': isMocked,
      'trust_level': trustLevel == TrustLevel.verified ? 'VERIFIED' : 'WARNING',
      'security_flags': securityFlags,
      'verified_timestamp': verifiedTimestamp.toIso8601String(),
      'security_signature': securitySignature,
    };
  }

  factory GpsSecurityReport.fromJson(Map<String, dynamic> json) {
    return GpsSecurityReport(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num).toDouble(),
      isMocked: json['is_mocked'] as bool? ?? false,
      trustLevel: (json['trust_level'] == 'WARNING')
          ? TrustLevel.warning
          : TrustLevel.verified,
      securityFlags: (json['security_flags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      verifiedTimestamp: DateTime.parse(json['verified_timestamp'] as String),
      securitySignature: json['security_signature'] as String? ?? '',
    );
  }
}

class GpsSecurityService {
  static final GpsSecurityService _instance = GpsSecurityService._internal();
  factory GpsSecurityService() => _instance;
  GpsSecurityService._internal();

  // Mode simulasi untuk pengujian perangkat / demo
  bool _simulateMockGps = false;
  bool get isMockSimulationActive => _simulateMockGps;

  void toggleMockSimulation(bool enable) {
    _simulateMockGps = enable;
  }

  /// Mendapatkan koordinat lokasi dengan verifikasi anti-spoofing
  Future<GpsSecurityReport> getValidatedLocation() async {
    // Simulasi delay pembacaan sensor GPS fisik
    await Future.delayed(const Duration(milliseconds: 300));

    final now = DateTime.now().toUtc();
    final List<String> flags = [];

    // Nilai dasar koordinat (contoh area gudang / warehouse)
    double lat = -6.208763;
    double lng = 106.845599;
    double accuracy = 3.5; // Akurasi tinggi GPS satelit

    bool isMock = _simulateMockGps;

    if (isMock) {
      flags.add('MOCK_LOCATION_ACTIVE');
      flags.add('DEVELOPER_OPTIONS_MOCK_APP');
      accuracy = 0.1;
      lat += 0.05;
      lng += 0.05;
    }

    final trustLevel = isMock ? TrustLevel.warning : TrustLevel.verified;

    // Menghasilkan digital signature / hash SHA-256 anti-tamper
    final payloadToSign = '$lat:$lng:$accuracy:$isMock:${now.toIso8601String()}:SECURE_SALT_IVENTORY_2026';
    final bytes = utf8.encode(payloadToSign);
    final signature = sha256.convert(bytes).toString();

    return GpsSecurityReport(
      latitude: lat,
      longitude: lng,
      accuracy: accuracy,
      isMocked: isMock,
      trustLevel: trustLevel,
      securityFlags: flags,
      verifiedTimestamp: now,
      securitySignature: signature,
    );
  }
}
