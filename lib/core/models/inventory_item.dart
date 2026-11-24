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
    this.updatedBy = 'Petugas Gudang',
    this.gpsReport,
  });

  bool get isLowStock => quantity <= lowStockThreshold && quantity > 0;
  bool get isOutOfStock => quantity == 0;

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
}
