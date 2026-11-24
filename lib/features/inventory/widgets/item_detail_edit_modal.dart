import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/inventory_item.dart';
import '../../../../core/repository/inventory_repository.dart';
import '../../../../core/theme/app_theme.dart';

class ItemDetailEditModal extends StatefulWidget {
  final InventoryItem item;

  const ItemDetailEditModal({
    super.key,
    required this.item,
  });

  static Future<void> show(BuildContext context, InventoryItem item) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ItemDetailEditModal(item: item),
    );
  }

  @override
  State<ItemDetailEditModal> createState() => _ItemDetailEditModalState();
}

class _ItemDetailEditModalState extends State<ItemDetailEditModal> {
  late int _currentQuantity;
  late TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _currentQuantity = widget.item.quantity;
    _quantityController = TextEditingController(text: _currentQuantity.toString());
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _increment() {
    setState(() {
      _currentQuantity++;
      _quantityController.text = _currentQuantity.toString();
    });
  }

  void _decrement() {
    if (_currentQuantity > 0) {
      setState(() {
        _currentQuantity--;
        _quantityController.text = _currentQuantity.toString();
      });
    }
  }

  void _saveStock() {
    final parsed = int.tryParse(_quantityController.text) ?? _currentQuantity;
    final finalQty = parsed < 0 ? 0 : parsed;
    InventoryRepository.instance.updateItemQuantity(widget.item.id, finalQty);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceCard,
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.green, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Stok "${widget.item.name}" berhasil diubah menjadi $finalQty ${widget.item.unit}.',
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = widget.item.imagePath != null &&
        widget.item.imagePath!.isNotEmpty &&
        File(widget.item.imagePath!).existsSync();

    final timeFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
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
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.item.category} • ${widget.item.warehouse}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppColors.textMuted, size: 28),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Persistent Photo Container (Requirement 2)
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: hasPhoto
                    ? Image.file(
                        File(widget.item.imagePath!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (_, _, _) => _buildFallbackPhotoView(),
                      )
                    : _buildFallbackPhotoView(),
              ),
            ),

            const SizedBox(height: 20),

            // Dynamic Stock Adjustment Box (Requirement 1)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Jumlah Stok (Dinamis)',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _currentQuantity <= widget.item.lowStockThreshold
                              ? AppColors.orangeWarning.withValues(alpha: 0.15)
                              : AppColors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _currentQuantity == 0
                              ? 'Out of Stock'
                              : _currentQuantity <= widget.item.lowStockThreshold
                                  ? 'Low Stock'
                                  : 'In Stock',
                          style: TextStyle(
                            color: _currentQuantity <= widget.item.lowStockThreshold
                                ? AppColors.orangeWarning
                                : AppColors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Stepper & Input
                  Row(
                    children: [
                      // Decrement
                      IconButton(
                        onPressed: _decrement,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surfaceLight,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(CupertinoIcons.minus, color: AppColors.textPrimary),
                      ),
                      const SizedBox(width: 12),

                      // Input Field
                      Expanded(
                        child: TextField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.background,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                            suffixText: widget.item.unit,
                            suffixStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                          ),
                          onChanged: (val) {
                            final parsed = int.tryParse(val);
                            if (parsed != null && parsed >= 0) {
                              setState(() => _currentQuantity = parsed);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Increment
                      IconButton(
                        onPressed: _increment,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surfaceLight,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(CupertinoIcons.plus, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Item Metadata details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  _buildMetaRow('Detail Kemasan', widget.item.packageDetail.isNotEmpty ? widget.item.packageDetail : '-'),
                  const Divider(color: AppColors.border, height: 18),
                  _buildMetaRow('Tanggal Kadaluarsa', widget.item.expirationDate.isNotEmpty ? 'Exp ${widget.item.expirationDate}' : '-'),
                  const Divider(color: AppColors.border, height: 18),
                  _buildMetaRow('Terakhir Diperbarui', timeFormat.format(widget.item.updatedAt)),
                  const Divider(color: AppColors.border, height: 18),
                  _buildMetaRow('Petugas Gudang', widget.item.updatedBy),
                  if (widget.item.gpsReport != null) ...[
                    const Divider(color: AppColors.border, height: 18),
                    _buildMetaRow(
                      'Verifikasi Lokasi',
                      widget.item.gpsReport!.isMock
                          ? '⚠️ Mock GPS Detected'
                          : '✅ Verified GPS (${widget.item.gpsReport!.latitude.toStringAsFixed(4)}, ${widget.item.gpsReport!.longitude.toStringAsFixed(4)})',
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saveStock,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonFoto,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  'Simpan Perubahan Stok',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackPhotoView() {
    return Container(
      color: AppColors.surfaceLight,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.cube_box_fill,
              size: 48,
              color: AppColors.buttonFoto.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 8),
            Text(
              'Foto Barang: ${widget.item.name}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
