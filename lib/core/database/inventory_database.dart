import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/inventory_item.dart';

class ScanHistoryEntry {
  final String id;
  final String itemId;
  final String itemName;
  final int quantity;
  final String? imagePath;
  final DateTime scannedAt;
  final double latitude;
  final double longitude;
  final double accuracy;
  final bool isMocked;
  final String signature;

  const ScanHistoryEntry({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    this.imagePath,
    required this.scannedAt,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.isMocked,
    required this.signature,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item_id': itemId,
      'item_name': itemName,
      'quantity': quantity,
      'image_path': imagePath,
      'scanned_at': scannedAt.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'is_mocked': isMocked ? 1 : 0,
      'signature': signature,
    };
  }

  factory ScanHistoryEntry.fromMap(Map<String, dynamic> map) {
    return ScanHistoryEntry(
      id: map['id'] as String,
      itemId: map['item_id'] as String,
      itemName: map['item_name'] as String,
      quantity: map['quantity'] as int,
      imagePath: map['image_path'] as String?,
      scannedAt: DateTime.tryParse(map['scanned_at'] as String? ?? '') ?? DateTime.now(),
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      accuracy: (map['accuracy'] as num).toDouble(),
      isMocked: (map['is_mocked'] as int?) == 1,
      signature: map['signature'] as String? ?? '',
    );
  }
}

class InventoryDatabase {
  static final InventoryDatabase _instance = InventoryDatabase._internal();
  factory InventoryDatabase() => _instance;
  static InventoryDatabase get instance => _instance;
  InventoryDatabase._internal();

  Database? _database;
  bool _initAttempted = false;

  Future<Database?> get database async {
    if (_database != null) return _database;
    if (_initAttempted) return _database;
    _initAttempted = true;
    try {
      if (!kIsWeb && (Platform.isLinux || Platform.isWindows)) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      final dbPath = await getDatabasesPath();
      final path = p.join(dbPath, 'inventory.db');
      _database = await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
    } catch (e) {
      debugPrint('SQLite database initialization fallback (e.g. test environment): $e');
    }
    return _database;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE inventory_items (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        warehouse TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        low_stock_threshold INTEGER NOT NULL,
        is_for_sale INTEGER NOT NULL,
        unit TEXT NOT NULL,
        package_detail TEXT NOT NULL,
        expiration_date TEXT NOT NULL,
        image_path TEXT,
        updated_at TEXT NOT NULL,
        updated_by TEXT NOT NULL,
        gps_latitude REAL,
        gps_longitude REAL,
        gps_accuracy REAL,
        gps_is_mocked INTEGER,
        gps_signature TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE scan_history (
        id TEXT PRIMARY KEY,
        item_id TEXT NOT NULL,
        item_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        image_path TEXT,
        scanned_at TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        accuracy REAL NOT NULL,
        is_mocked INTEGER NOT NULL,
        signature TEXT NOT NULL
      )
    ''');
  }

  Future<List<InventoryItem>> getAllItems() async {
    final db = await database;
    if (db == null) return [];
    final List<Map<String, dynamic>> maps = await db.query(
      'inventory_items',
      orderBy: 'updated_at DESC',
    );
    return maps.map((m) => InventoryItem.fromMap(m)).toList();
  }

  Future<int> insertItem(InventoryItem item) async {
    final db = await database;
    if (db == null) return 0;
    return await db.insert(
      'inventory_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateItem(InventoryItem item) async {
    final db = await database;
    if (db == null) return 0;
    return await db.update(
      'inventory_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteItem(String id) async {
    final db = await database;
    if (db == null) return 0;
    return await db.delete(
      'inventory_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertScanHistory(ScanHistoryEntry entry) async {
    final db = await database;
    if (db == null) return 0;
    return await db.insert(
      'scan_history',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ScanHistoryEntry>> getScanHistory() async {
    final db = await database;
    if (db == null) return [];
    final List<Map<String, dynamic>> maps = await db.query(
      'scan_history',
      orderBy: 'scanned_at DESC',
    );
    return maps.map((m) => ScanHistoryEntry.fromMap(m)).toList();
  }
}
