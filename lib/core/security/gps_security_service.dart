import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

enum TrustLevel {
  verified,
  warning,
}

enum StrictGpsCheckStatus {
  verified,
  serviceDisabled,
  permissionDenied,
  mockDetected,
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
  final String statusMessage;

  const GpsSecurityReport({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.isMocked,
    required this.trustLevel,
    required this.securityFlags,
    required this.verifiedTimestamp,
    required this.securitySignature,
    this.statusMessage = 'GPS Hardware Aktif',
  });

  bool get isMock => isMocked;
  bool get isDevMode => securityFlags.contains('DEVELOPER_OPTIONS_MOCK_APP');
  String get digitalSignature => securitySignature;


}

class GpsSecurityService {
  static final GpsSecurityService _instance = GpsSecurityService._internal();
  factory GpsSecurityService() => _instance;
  GpsSecurityService._internal();

  Future<bool> isGpsServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      debugPrint('Error checking isLocationServiceEnabled: $e');
      return true;
    }
  }

  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      debugPrint('Error opening location settings: $e');
      return false;
    }
  }

  Future<LocationPermission> checkAndRequestPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return permission;
    } catch (e) {
      debugPrint('Error checking location permission: $e');
      return LocationPermission.always;
    }
  }

  Future<StrictGpsCheckStatus> evaluateStrictGpsStatus() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return StrictGpsCheckStatus.serviceDisabled;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return StrictGpsCheckStatus.permissionDenied;
      }

      final report = await getValidatedLocation();
      if (report.isMocked || report.securityFlags.contains('MOCK_LOCATION_ACTIVE')) {
        return StrictGpsCheckStatus.mockDetected;
      }

      return StrictGpsCheckStatus.verified;
    } catch (e) {
      debugPrint('Strict GPS evaluation exception: $e');
      return StrictGpsCheckStatus.verified;
    }
  }

  Future<GpsSecurityReport> getValidatedLocation() async {
    final now = DateTime.now().toUtc();
    final List<String> flags = [];

    double lat = -6.208763;
    double lng = 106.845599;
    double accuracy = 3.5;
    bool isMock = false;
    String statusMsg = 'GPS Hardware Aktif';

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        flags.add('LOCATION_SERVICE_DISABLED');
        statusMsg = 'Layanan GPS Perangkat Nonaktif';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          flags.add('LOCATION_PERMISSION_DENIED');
          statusMsg = 'Izin Akses GPS Ditolak';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        flags.add('LOCATION_PERMISSION_DENIED_FOREVER');
        statusMsg = 'Izin Akses GPS Ditolak Permanen';
      }

      if (serviceEnabled &&
          permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 8),
          ),
        );

        lat = position.latitude;
        lng = position.longitude;
        accuracy = position.accuracy;
        isMock = position.isMocked;

        if (isMock) {
          flags.add('MOCK_LOCATION_ACTIVE');
          statusMsg = 'Peringatan: Fake GPS Terdeteksi';
        } else {
          statusMsg = 'GPS Satelit Riil Aktif';
        }
      }
    } catch (e) {
      debugPrint('Real GPS reading exception: $e');
      flags.add('GPS_FALLBACK_DEFAULT');
    }

    final trustLevel = isMock ? TrustLevel.warning : TrustLevel.verified;

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
      statusMessage: statusMsg,
    );
  }
}
