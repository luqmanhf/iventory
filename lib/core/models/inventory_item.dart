import '../security/gps_security_service.dart';

class InventoryItem {
  final String id;
  String name;
  String category;
  String warehouse;
  int quantity;
  int lowStockThreshold;
  bool isForSale;
  String unit;
  String packageDetail;
  String expirationDate;
  String? imagePath;
  DateTime updatedAt;
  String updatedBy;
  GpsSecurityReport? gpsReport;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.warehouse,
    required this.quantity,
    this.lowStockThreshold = 100,
    this.isForSale = true,
    this.unit = 'units',
    this.packageDetail = '',
    this.expirationDate = '',
    this.imagePath,
    required this.updatedAt,
    String updatedBy = 'Petugas Gudang',
    this.gpsReport,
  }) : updatedBy = updatedBy
            .replaceAll(RegExp(r'\s*\((Admin|Scanner)\)', caseSensitive: false), '')
            .trim();


  InventoryItem copyWith({
    String? id,
    String? name,
    String? category,
    String? warehouse,
    int? quantity,
    int? lowStockThreshold,
    bool? isForSale,
    String? unit,
    String? packageDetail,
    String? expirationDate,
    String? imagePath,
    DateTime? updatedAt,
    String? updatedBy,
    GpsSecurityReport? gpsReport,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      warehouse: warehouse ?? this.warehouse,
      quantity: quantity ?? this.quantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      isForSale: isForSale ?? this.isForSale,
      unit: unit ?? this.unit,
      packageDetail: packageDetail ?? this.packageDetail,
      expirationDate: expirationDate ?? this.expirationDate,
      imagePath: imagePath ?? this.imagePath,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      gpsReport: gpsReport ?? this.gpsReport,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'warehouse': warehouse,
      'quantity': quantity,
      'low_stock_threshold': lowStockThreshold,
      'is_for_sale': isForSale ? 1 : 0,
      'unit': unit,
      'package_detail': packageDetail,
      'expiration_date': expirationDate,
      'image_path': imagePath,
      'updated_at': updatedAt.toIso8601String(),
      'updated_by': updatedBy,
      'gps_latitude': gpsReport?.latitude,
      'gps_longitude': gpsReport?.longitude,
      'gps_accuracy': gpsReport?.accuracy,
      'gps_is_mocked': (gpsReport?.isMocked ?? false) ? 1 : 0,
      'gps_signature': gpsReport?.securitySignature,
    };
  }

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    GpsSecurityReport? report;
    if (map['gps_latitude'] != null && map['gps_longitude'] != null) {
      final isMock = (map['gps_is_mocked'] as int?) == 1;
      report = GpsSecurityReport(
        latitude: (map['gps_latitude'] as num).toDouble(),
        longitude: (map['gps_longitude'] as num).toDouble(),
        accuracy: (map['gps_accuracy'] as num?)?.toDouble() ?? 3.5,
        isMocked: isMock,
        trustLevel: isMock ? TrustLevel.warning : TrustLevel.verified,
        securityFlags: const [],
        verifiedTimestamp: DateTime.tryParse(map['updated_at'] as String? ?? '') ?? DateTime.now(),
        securitySignature: map['gps_signature'] as String? ?? '',
      );
    }

    return InventoryItem(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      warehouse: map['warehouse'] as String,
      quantity: map['quantity'] as int,
      lowStockThreshold: map['low_stock_threshold'] as int? ?? 100,
      isForSale: (map['is_for_sale'] as int?) != 0,
      unit: map['unit'] as String? ?? 'units',
      packageDetail: map['package_detail'] as String? ?? '',
      expirationDate: map['expiration_date'] as String? ?? '',
      imagePath: map['image_path'] as String?,
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ?? DateTime.now(),
      updatedBy: (map['updated_by'] as String? ?? 'Petugas Gudang')
          .replaceAll(RegExp(r'\s*\((Admin|Scanner)\)', caseSensitive: false), '')
          .trim(),
      gpsReport: report,
    );
  }
}
