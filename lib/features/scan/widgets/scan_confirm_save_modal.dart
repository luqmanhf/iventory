import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/repository/inventory_repository.dart';
import '../../../core/security/gps_security_service.dart';
import '../../../core/theme/app_theme.dart';

class ScanConfirmSaveModal extends StatefulWidget {
  final String imagePath;
  final int initialQuantity;
  final GpsSecurityReport? gpsReport;
  final VoidCallback onSaved;

  const ScanConfirmSaveModal({
    super.key,
    required this.imagePath,
    this.initialQuantity = 1,
    this.gpsReport,
    required this.onSaved,
  });

  static Future<void> show(
    BuildContext context, {
    required String imagePath,
    int initialQuantity = 1,
    GpsSecurityReport? gpsReport,
    required VoidCallback onSaved,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ScanConfirmSaveModal(
        imagePath: imagePath,
        initialQuantity: initialQuantity,
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

  String _selectedCategory = 'Elektronik';
  String _selectedWarehouse = 'Gudang Utama';
  String _selectedUnit = 'Karung';

  final List<String> _categories = [
    'Sembako',
    'Elektronik',
    'Snack',
  ];

  final List<String> _warehouses = [
    'Gudang Utama',
    'Gudang A',
    'Gudang B',
    'Gudang C',
  ];

  final List<String> _units = [
    'Karung',
    'Box',
    'Unit',
    'Peti',
  ];

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity > 0 ? widget.initialQuantity : 1;
    _nameController = TextEditingController(text: '');
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
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.getBorder(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Simpan Hasil Pindaian',
                  style: TextStyle(
                    color: AppColors.getTextPrimary(context),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(CupertinoIcons.xmark_circle_fill, color: AppColors.getTextMuted(context), size: 26),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.getSurfaceCard(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.getBorder(context)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: hasFile
                    ? Image.file(file, fit: BoxFit.cover)
                    : Container(
                        color: AppColors.getSurfaceLight(context),
                        child: Center(
                          child: Icon(CupertinoIcons.photo, size: 40, color: AppColors.getTextMuted(context)),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.buttonFoto.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.buttonFoto.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.camera_fill, color: AppColors.buttonFoto, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Masukkan Detail Barang',
                      style: TextStyle(
                        color: AppColors.getTextPrimary(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Text('Nama Barang', style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              style: TextStyle(color: AppColors.getTextPrimary(context)),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.getSurfaceCard(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.getBorder(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.getBorder(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.buttonFoto, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Jumlah Stok', style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 13)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.getSurfaceCard(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.getBorder(context)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                if (_quantity > 1) setState(() => _quantity--);
                              },
                              icon: Icon(CupertinoIcons.minus, color: AppColors.getTextPrimary(context), size: 18),
                            ),
                            Text(
                              '$_quantity',
                              style: TextStyle(
                                color: AppColors.getTextPrimary(context),
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            IconButton(
                              onPressed: () => setState(() => _quantity++),
                              icon: Icon(CupertinoIcons.plus, color: AppColors.getTextPrimary(context), size: 18),
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
                      Text('Satuan', style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 13)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.getSurfaceCard(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.getBorder(context)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedUnit,
                            isExpanded: true,
                            dropdownColor: AppColors.getSurfaceCard(context),
                            style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 14),
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

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kategori', style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 13)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.getSurfaceCard(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.getBorder(context)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            isExpanded: true,
                            dropdownColor: AppColors.getSurfaceCard(context),
                            style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 14),
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
                      Text('Lokasi Gudang', style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 13)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.getSurfaceCard(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.getBorder(context)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedWarehouse,
                            isExpanded: true,
                            dropdownColor: AppColors.getSurfaceCard(context),
                            style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 14),
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
                  'Simpan',
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
