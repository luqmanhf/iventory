import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../security/gps_security_service.dart';

enum SyncStatus {
  pending,
  syncing,
  synced,
  failed,
}

class InventoryAuditRecord {
  final String id;
  final String tempImagePath;
  final int detectedCount;
  final int finalCount;
  final String category;
  final double latitude;
  final double longitude;
  final double accuracy;
  final bool isMocked;
  final String trustLevel;
  final List<String> securityFlags;
  final DateTime capturedAt;
  final SyncStatus syncStatus;
  final String signature;

  const InventoryAuditRecord({
    required this.id,
    required this.tempImagePath,
    required this.detectedCount,
    required this.finalCount,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.isMocked,
    required this.trustLevel,
    required this.securityFlags,
    required this.capturedAt,
    required this.syncStatus,
    required this.signature,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'temp_image_path': tempImagePath,
      'detected_count': detectedCount,
      'final_count': finalCount,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'is_mocked': isMocked,
      'trust_level': trustLevel,
      'security_flags': securityFlags,
      'captured_at': capturedAt.toIso8601String(),
      'sync_status': syncStatus.name,
      'signature': signature,
    };
  }

  factory InventoryAuditRecord.fromJson(Map<String, dynamic> json) {
    return InventoryAuditRecord(
      id: json['id'] as String,
      tempImagePath: json['temp_image_path'] as String,
      detectedCount: json['detected_count'] as int,
      finalCount: json['final_count'] as int,
      category: json['category'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num).toDouble(),
      isMocked: json['is_mocked'] as bool? ?? false,
      trustLevel: json['trust_level'] as String? ?? 'VERIFIED',
      securityFlags: (json['security_flags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      capturedAt: DateTime.parse(json['captured_at'] as String),
      syncStatus: SyncStatus.values.firstWhere(
        (e) => e.name == json['sync_status'],
        orElse: () => SyncStatus.pending,
      ),
      signature: json['signature'] as String? ?? '',
    );
  }
}

class TemporaryStorageService {
  static final TemporaryStorageService _instance =
      TemporaryStorageService._internal();
  factory TemporaryStorageService() => _instance;
  TemporaryStorageService._internal();

  final List<InventoryAuditRecord> _inMemoryQueue = [];
  bool _isInitialized = false;

  List<InventoryAuditRecord> get pendingRecords =>
      List.unmodifiable(_inMemoryQueue);

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      final tempDir = await _getTempDirectory();
      final metaFile = File('${tempDir.path}/queue_index.json');
      if (await metaFile.exists()) {
        final content = await metaFile.readAsString();
        final List<dynamic> jsonList = jsonDecode(content) as List<dynamic>;
        _inMemoryQueue.clear();
        for (final item in jsonList) {
          _inMemoryQueue.add(
            InventoryAuditRecord.fromJson(item as Map<String, dynamic>),
          );
        }
      }
    } catch (_) {
      // Abaikan bila file index belum ada
    }
    _isInitialized = true;
  }

  Future<Directory> _getTempDirectory() async {
    Directory baseDir;
    try {
      baseDir = await getTemporaryDirectory();
    } catch (_) {
      baseDir = Directory('/tmp');
    }
    final dir = Directory('${baseDir.path}/inventory_temp');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Menyimpan foto dan metadata ke storage sementara lokal
  Future<InventoryAuditRecord> saveToTemporaryStorage({
    required List<int> imageBytes,
    required int detectedCount,
    required int finalCount,
    required String category,
    required GpsSecurityReport gpsReport,
  }) async {
    await initialize();

    final tempDir = await _getTempDirectory();
    final String id = const Uuid().v4();
    final String timestampStr = DateTime.now().millisecondsSinceEpoch.toString();
    final String filePath = '${tempDir.path}/INV_${timestampStr}_$id.jpg';

    // Tulis byte gambar ke disk
    final file = File(filePath);
    await file.writeAsBytes(imageBytes);

    final record = InventoryAuditRecord(
      id: id,
      tempImagePath: filePath,
      detectedCount: detectedCount,
      finalCount: finalCount,
      category: category,
      latitude: gpsReport.latitude,
      longitude: gpsReport.longitude,
      accuracy: gpsReport.accuracy,
      isMocked: gpsReport.isMocked,
      trustLevel: gpsReport.trustLevel == TrustLevel.verified ? 'VERIFIED' : 'WARNING',
      securityFlags: gpsReport.securityFlags,
      capturedAt: gpsReport.verifiedTimestamp,
      syncStatus: SyncStatus.pending,
      signature: gpsReport.securitySignature,
    );

    _inMemoryQueue.insert(0, record);
    await _persistQueueIndex();
    return record;
  }

  /// Sinkronisasi item dari antrean sementara ke cloud
  Future<bool> syncRecord(String id) async {
    final index = _inMemoryQueue.indexWhere((e) => e.id == id);
    if (index == -1) return false;

    // Simulasi upload ke server
    await Future.delayed(const Duration(milliseconds: 600));

    final old = _inMemoryQueue[index];
    final updated = InventoryAuditRecord(
      id: old.id,
      tempImagePath: old.tempImagePath,
      detectedCount: old.detectedCount,
      finalCount: old.finalCount,
      category: old.category,
      latitude: old.latitude,
      longitude: old.longitude,
      accuracy: old.accuracy,
      isMocked: old.isMocked,
      trustLevel: old.trustLevel,
      securityFlags: old.securityFlags,
      capturedAt: old.capturedAt,
      syncStatus: SyncStatus.synced,
      signature: old.signature,
    );

    _inMemoryQueue[index] = updated;

    // Bersihkan file lokal setelah status berubah menjadi synced
    try {
      final file = File(old.tempImagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}

    await _persistQueueIndex();
    return true;
  }

  Future<void> _persistQueueIndex() async {
    try {
      final tempDir = await _getTempDirectory();
      final metaFile = File('${tempDir.path}/queue_index.json');
      final jsonList = _inMemoryQueue.map((e) => e.toJson()).toList();
      await metaFile.writeAsString(jsonEncode(jsonList));
    } catch (_) {}
  }
}
