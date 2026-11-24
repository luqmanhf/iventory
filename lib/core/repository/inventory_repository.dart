import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../models/inventory_item.dart';
import '../security/gps_security_service.dart';

class InventoryRepository extends ChangeNotifier {
  static final InventoryRepository _instance = InventoryRepository._internal();
  factory InventoryRepository() => _instance;
  static InventoryRepository get instance => _instance;

  InventoryRepository._internal() {
    _initDefaultItems();
  }

  final List<InventoryItem> _items = [];
  bool _isInitialized = false;

  List<InventoryItem> get items => List.unmodifiable(_items);

  // Dynamic Dashboard Metrics
  int get saleStockCount {
    return _items.where((item) => item.isForSale).fold(0, (sum, item) => sum + item.quantity);
  }

  int get lowStockCount {
    return _items.where((item) => item.isLowStock).fold(0, (sum, item) => sum + item.quantity);
  }

  int get outOfStockCount {
    return _items.where((item) => item.isOutOfStock).length;
  }

  int get totalItemsCount {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  int get totalUniqueProducts => _items.length;

  void _initDefaultItems() {
    if (_isInitialized) return;
    _isInitialized = true;

    final now = DateTime.now();

    _items.addAll([
      // Dashboard commodities (matching image.png)
      InventoryItem(
        id: 'item-beras',
        name: 'Beras',
        category: 'Sembako',
        warehouse: 'Gudang Utama',
        quantity: 120,
        lowStockThreshold: 100,
        isForSale: true,
        unit: 'karung',
        packageDetail: 'Karung 25kg · Pulen Premium',
        expirationDate: '12/27',
        updatedAt: now.subtract(const Duration(hours: 5)),
        updatedBy: 'Luqman',
      ),
      InventoryItem(
        id: 'item-minyak',
        name: 'Minyak Goreng',
        category: 'Sembako',
        warehouse: 'Gudang Barat',
        quantity: 80,
        lowStockThreshold: 100,
        isForSale: true,
        unit: 'karton',
        packageDetail: 'Pouch 2L (Isi 6/dus)',
        expirationDate: '10/26',
        updatedAt: now.subtract(const Duration(hours: 3, minutes: 20)),
        updatedBy: 'Luqman',
      ),
      InventoryItem(
        id: 'item-gandum',
        name: 'Gandum',
        category: 'Sembako',
        warehouse: 'Gudang Utara',
        quantity: 65,
        lowStockThreshold: 100,
        isForSale: true,
        unit: 'sak',
        packageDetail: 'Sak 50kg · Gandum Utuh',
        expirationDate: '04/27',
        updatedAt: now.subtract(const Duration(hours: 1, minutes: 45)),
        updatedBy: 'Luqman',
      ),
      InventoryItem(
        id: 'item-telur',
        name: 'Telur',
        category: 'Sembako',
        warehouse: 'Gudang Timur',
        quantity: 55,
        lowStockThreshold: 100,
        isForSale: true,
        unit: 'peti',
        packageDetail: 'Peti Kayu 15kg',
        expirationDate: '01/27',
        updatedAt: now.subtract(const Duration(minutes: 45)),
        updatedBy: 'Budi Santoso',
      ),

      // Inventory commodities (matching image copy 2.png)
      InventoryItem(
        id: 'item-coca-cola',
        name: 'Coca Cola',
        category: 'Beverages',
        warehouse: 'Warehouse A',
        quantity: 450,
        lowStockThreshold: 100,
        isForSale: true,
        unit: 'cases',
        packageDetail: '12 oz cans',
        expirationDate: '08/27',
        updatedAt: now.subtract(const Duration(hours: 6)),
        updatedBy: 'Budi Santoso',
      ),
      InventoryItem(
        id: 'item-doritos',
        name: 'Doritos',
        category: 'Snacks',
        warehouse: 'Warehouse B',
        quantity: 120,
        lowStockThreshold: 100,
        isForSale: true,
        unit: 'bags',
        packageDetail: 'Nacho Cheese',
        expirationDate: '02/27',
        updatedAt: now.subtract(const Duration(hours: 8)),
        updatedBy: 'Budi Santoso',
      ),
      InventoryItem(
        id: 'item-lass',
        name: 'Lass',
        category: 'Dairy',
        warehouse: 'Cold Room 1',
        quantity: 85,
        lowStockThreshold: 100,
        isForSale: true,
        unit: 'units',
        packageDetail: 'Whole Milk',
        expirationDate: '11/26',
        updatedAt: now.subtract(const Duration(hours: 12)),
        updatedBy: 'Luqman',
      ),
      InventoryItem(
        id: 'item-kitkat',
        name: 'KitKat',
        category: 'Confectionery',
        warehouse: 'Warehouse C',
        quantity: 310,
        lowStockThreshold: 100,
        isForSale: true,
        unit: 'boxes',
        packageDetail: '4-finger bar',
        expirationDate: '05/27',
        updatedAt: now.subtract(const Duration(hours: 18)),
        updatedBy: 'Luqman',
      ),
    ]);
  }

  // Update Stock Quantity Dinamis
  void updateItemQuantity(String id, int newQuantity) {
    final index = _items.indexWhere((element) => element.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(
        quantity: newQuantity < 0 ? 0 : newQuantity,
        updatedAt: DateTime.now(),
        updatedBy: 'Budi (Admin)',
      );
      notifyListeners();
    }
  }

  // Update Gambar & Detail Item
  void updateItemDetails({
    required String id,
    String? name,
    String? category,
    String? warehouse,
    int? quantity,
    String? imagePath,
  }) {
    final index = _items.indexWhere((element) => element.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(
        name: name,
        category: category,
        warehouse: warehouse,
        quantity: quantity,
        imagePath: imagePath,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  // Add Item from Camera Scan
  Future<InventoryItem> addNewItemFromScan({
    required String name,
    required String category,
    required String warehouse,
    required int quantity,
    required String unit,
    required String packageDetail,
    required String expirationDate,
    required String imagePath,
    GpsSecurityReport? gpsReport,
  }) async {
    final newItem = InventoryItem(
      id: const Uuid().v4(),
      name: name,
      category: category,
      warehouse: warehouse,
      quantity: quantity,
      unit: unit,
      packageDetail: packageDetail,
      expirationDate: expirationDate,
      imagePath: imagePath,
      updatedAt: DateTime.now(),
      updatedBy: 'Budi (Scanner)',
      gpsReport: gpsReport,
    );

    // Sisipkan di posisi pertama agar langsung terlihat di atas list
    _items.insert(0, newItem);
    notifyListeners();
    return newItem;
  }

  // Persistent Image Directory
  Future<String> saveCapturedImageBytes(Uint8List bytes) async {
    final dir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(dir.path, 'inventory_photos'));
    if (!photosDir.existsSync()) {
      photosDir.createSync(recursive: true);
    }
    final fileName = 'IMG_${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4().substring(0, 8)}.jpg';
    final filePath = p.join(photosDir.path, fileName);
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return filePath;
  }

  // Generate Sample Image for items if needed
  Future<void> ensureSampleImagesForSeedItems() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final photosDir = Directory(p.join(dir.path, 'inventory_photos'));
      if (!photosDir.existsSync()) {
        photosDir.createSync(recursive: true);
      }

      for (var item in _items) {
        if (item.imagePath == null || !File(item.imagePath!).existsSync()) {
          final samplePath = p.join(photosDir.path, '${item.id}.jpg');
          final file = File(samplePath);
          if (!file.existsSync()) {
            // Generate a lightweight placeholder JPEG
            final dummyBytes = _generateDummyJpegBytes(item.name);
            await file.writeAsBytes(dummyBytes);
          }
          item.imagePath = samplePath;
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Sample image error: $e');
    }
  }

  static Uint8List _generateDummyJpegBytes(String label) {
    // Basic valid tiny 1x1 or sample JPEG payload
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

  // Export CSV Data
  String generateCsv() {
    final buffer = StringBuffer();
    buffer.writeln('ID,Name,Category,Warehouse,Quantity,Unit,PackageDetail,ExpirationDate,UpdatedBy,UpdatedAt');
    for (var item in _items) {
      buffer.writeln(
        '${item.id},"${item.name}","${item.category}","${item.warehouse}",${item.quantity},"${item.unit}","${item.packageDetail}","${item.expirationDate}","${item.updatedBy}","${item.updatedAt.toIso8601String()}"'
      );
    }
    return buffer.toString();
  }
}
