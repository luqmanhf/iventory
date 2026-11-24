import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/repository/inventory_repository.dart';
import '../../../core/security/gps_security_service.dart';
import '../../../core/theme/app_theme.dart';

class ScanConfirmSaveModal extends StatefulWidget {
  final String imagePath;
  final int detectedCount;
  final GpsSecurityReport? gpsReport;
  final VoidCallback onSaved;

  const ScanConfirmSaveModal({
    super.key,
    required this.imagePath,
    required this.detectedCount,
    this.gpsReport,
    required this.onSaved,
  });

  static Future<void> show(
    BuildContext context, {
    required String imagePath,
    required int detectedCount,
    GpsSecurityReport? gpsReport,
    required VoidCallback onSaved,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ScanConfirmSaveModal(
        imagePath: imagePath,
        detectedCount: detectedCount,
        gpsReport: gpsReport,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<ScanConfirmSaveModal> createState() => _ScanConfirmSaveModalState();
}

class _ScanConfirmSaveModalState extends State<ScanConfirmSaveModal> {
  late int _quantity;
  late TextEditingController _nameController;
  late TextEditingController _packageController;
  late TextEditingController _expController;

  String _selectedCategory = 'Sembako';
  String _selectedWarehouse = 'Gudang Utama';
  String _selectedUnit = 'karung';

  final List<String> _categories = [
    'Sembako',
    'Beverages',
    'Snacks',
    'Dairy',
    'Confectionery',
    'Vegetables',
    'Fruits',
  ];

  final List<String> _warehouses = [
    'Gudang Utama',
    'Warehouse A',
    'Warehouse B',
    'Warehouse C',
    'Cold Room 1',
  ];

  final List<String> _units = [
    'karung',
    'cases',
    'karton',
    'bags',
    'boxes',
    'units',
    'peti',
  ];

  @override
  void initState() {
    super.initState();
    _quantity = widget.detectedCount > 0 ? widget.detectedCount : 10;
    _nameController = TextEditingController(text: 'Produk Baru (Scan)');
    _packageController = TextEditingController(text: 'Kemasan Standar');
    _expController = TextEditingController(text: '12/27');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _packageController.dispose();
    _expController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama produk tidak boleh kosong.')),
      );
      return;
    }

    await InventoryRepository.instance.addNewItemFromScan(
      name: name,
      category: _selectedCategory,
      warehouse: _selectedWarehouse,
      quantity: _quantity,
      unit: _selectedUnit,
      packageDetail: _packageController.text.trim(),
      expirationDate: _expController.text.trim(),
      imagePath: widget.imagePath,
      gpsReport: widget.gpsReport,
    );

    if (mounted) {
      Navigator.pop(context);
      widget.onSaved();
    }
  }

  @override
  Widget build(BuildContext context) {
    final file = File(widget.imagePath);
    final bool hasFile = file.existsSync();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Simpan Hasil Pindaian',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppColors.textMuted, size: 26),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Captured Photo Preview (Requirement 2: Displays saved picture!)
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: hasFile
                    ? Image.file(file, fit: BoxFit.cover)
                    : Container(
                        color: AppColors.surfaceLight,
                        child: const Center(
                          child: Icon(CupertinoIcons.photo, size: 40, color: AppColors.textMuted),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // AI Detection Chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.buttonFoto.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.buttonFoto.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.buttonFoto, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'AI YOLOv8 Menghitung: ${widget.detectedCount} Objek Terdeteksi',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Name Field
            const Text('Nama Barang', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceCard,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),

            const SizedBox(height: 14),

            // Dynamic Quantity Stepper (Requirement 1)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Jumlah Stok (Dinamis)', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                if (_quantity > 1) setState(() => _quantity--);
                              },
                              icon: const Icon(CupertinoIcons.minus, color: AppColors.textPrimary, size: 18),
                            ),
                            Text(
                              '$_quantity',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            IconButton(
                              onPressed: () => setState(() => _quantity++),
                              icon: const Icon(CupertinoIcons.plus, color: AppColors.textPrimary, size: 18),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Satuan', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedUnit,
                            isExpanded: true,
                            dropdownColor: AppColors.surfaceCard,
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                            items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedUnit = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Category & Warehouse Dropdowns
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Kategori', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            isExpanded: true,
                            dropdownColor: AppColors.surfaceCard,
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedCategory = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Lokasi Gudang', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedWarehouse,
                            isExpanded: true,
                            dropdownColor: AppColors.surfaceCard,
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                            items: _warehouses.map((w) => DropdownMenuItem(value: w, child: Text(w))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedWarehouse = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonFoto,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  'Simpan ke Inventaris & Tampilkan Foto',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
