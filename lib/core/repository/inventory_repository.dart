import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../database/inventory_database.dart';
import '../models/inventory_item.dart';
import '../security/gps_security_service.dart';

class InventoryRepository extends ChangeNotifier {
  static final InventoryRepository _instance = InventoryRepository._internal();
  factory InventoryRepository() => _instance;
  static InventoryRepository get instance => _instance;

  InventoryRepository._internal() {
    _initDefaultItemsSynchronous();
    _loadFromDatabase();
  }

  final List<InventoryItem> _items = [];
  bool _isInitialized = false;

  List<InventoryItem> get items => List.unmodifiable(_items);

  int get totalItemsCount {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  void _initDefaultItemsSynchronous() {
    if (_isInitialized) return;
    _isInitialized = true;

    final now = DateTime.now();
    _items.addAll([
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
    ]);
  }

  Future<void> _loadFromDatabase() async {
    try {
      final dbItems = await InventoryDatabase.instance.getAllItems();
      if (dbItems.isNotEmpty) {
        _items.clear();
        _items.addAll(dbItems);
        notifyListeners();
      } else {
        for (var item in _items) {
          unawaited(InventoryDatabase.instance.insertItem(item));
        }
      }
    } catch (e) {
      debugPrint('Database load notice: $e');
    }
  }

  Future<void> updateItemQuantity(String id, int newQuantity) async {
    final index = _items.indexWhere((element) => element.id == id);
    if (index != -1) {
      final updated = _items[index].copyWith(
        quantity: newQuantity < 0 ? 0 : newQuantity,
        updatedAt: DateTime.now(),
        updatedBy: 'Budi',
      );
      _items[index] = updated;
      await InventoryDatabase.instance.updateItem(updated);
      notifyListeners();
    }
  }

  Future<void> deleteItem(String id) async {
    final index = _items.indexWhere((element) => element.id == id);
    if (index != -1) {
      final item = _items[index];
      if (item.imagePath != null && item.imagePath!.isNotEmpty) {
        try {
          final file = File(item.imagePath!);
          if (file.existsSync()) {
            file.deleteSync();
          }
        } catch (e) {
          debugPrint('Error deleting image file: $e');
        }
      }
      _items.removeAt(index);
      await InventoryDatabase.instance.deleteItem(id);
      notifyListeners();
    }
  }

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
    final newItemId = const Uuid().v4();
    final now = DateTime.now();

    final newItem = InventoryItem(
      id: newItemId,
      name: name,
      category: category,
      warehouse: warehouse,
      quantity: quantity,
      unit: unit,
      packageDetail: packageDetail,
      expirationDate: expirationDate,
      imagePath: imagePath,
      updatedAt: now,
      updatedBy: 'Budi',
      gpsReport: gpsReport,
    );

    if (gpsReport != null) {
      final historyEntry = ScanHistoryEntry(
        id: const Uuid().v4(),
        itemId: newItemId,
        itemName: name,
        quantity: quantity,
        imagePath: imagePath,
        scannedAt: now,
        latitude: gpsReport.latitude,
        longitude: gpsReport.longitude,
        accuracy: gpsReport.accuracy,
        isMocked: gpsReport.isMocked,
        signature: gpsReport.securitySignature,
      );
      await InventoryDatabase.instance.insertScanHistory(historyEntry);
    }

    _items.insert(0, newItem);
    await InventoryDatabase.instance.insertItem(newItem);
    notifyListeners();
    return newItem;
  }

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

}
