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
        backgroundColor: AppColors.getSurfaceCard(context),
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.green, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Stok "${widget.item.name}" berhasil diubah menjadi $finalQty ${widget.item.unit}.',
                style: TextStyle(
                  color: AppColors.getTextPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _confirmAndDeleteItem() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.getSurfaceCard(ctx),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(CupertinoIcons.trash_circle_fill, color: AppColors.red, size: 28),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'Hapus "${widget.item.name}"?',
                style: TextStyle(
                  color: AppColors.getTextPrimary(ctx),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus barang ini secara permanen dari inventaris? Berkas foto dan riwayat penyimpanan lokal akan dihapus.',
          style: TextStyle(
            color: AppColors.getTextSecondary(ctx),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Batal',
              style: TextStyle(
                color: AppColors.getTextSecondary(ctx),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text(
              'Hapus Permanen',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await InventoryRepository.instance.deleteItem(widget.item.id);
      if (mounted) {
        Navigator.pop(context); // Tutup Bottom Sheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.getSurfaceCard(context),
            content: Row(
              children: [
                const Icon(CupertinoIcons.trash, color: AppColors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Barang "${widget.item.name}" berhasil dihapus dari inventaris.',
                    style: TextStyle(
                      color: AppColors.getTextPrimary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showFullscreenImageZoom(BuildContext context, bool hasPhoto) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 5.0,
                child: hasPhoto
                    ? Image.file(
                        File(widget.item.imagePath!),
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => _buildFallbackPhotoView(),
                      )
                    : _buildFallbackPhotoView(),
              ),
            ),

            Positioned(
              top: 40,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.item.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.6),
                    ),
                    icon: const Icon(CupertinoIcons.xmark, color: Colors.white, size: 22),
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.zoom_in, color: Colors.white70, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Cubit layar untuk memperbesar',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.getBorder(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.name,
                        style: TextStyle(
                          color: AppColors.getTextPrimary(context),
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.item.category} • ${widget.item.warehouse}',
                        style: TextStyle(
                          color: AppColors.getTextSecondary(context),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(CupertinoIcons.xmark_circle_fill, color: AppColors.getTextMuted(context), size: 28),
                ),
              ],
            ),

            const SizedBox(height: 16),

            GestureDetector(
              onTap: () => _showFullscreenImageZoom(context, hasPhoto),
              child: Container(
                width: double.infinity,
                height: 210,
                decoration: BoxDecoration(
                  color: AppColors.getSurfaceCard(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.getBorder(context)),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
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

                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(CupertinoIcons.arrow_up_right_square, color: Colors.white, size: 13),
                            SizedBox(width: 6),
                            Text(
                              'Klik untuk Perbesar',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.getSurfaceCard(context),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.getBorder(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Jumlah Stok',
                        style: TextStyle(
                          color: AppColors.getTextPrimary(context),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      IconButton(
                        onPressed: _decrement,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.getSurfaceLight(context),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: Icon(CupertinoIcons.minus, color: AppColors.getTextPrimary(context)),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: TextField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.getTextPrimary(context),
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.getBackground(context),
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: AppColors.getBorder(context)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: AppColors.getBorder(context)),
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

                      IconButton(
                        onPressed: _increment,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.getSurfaceLight(context),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: Icon(CupertinoIcons.plus, color: AppColors.getTextPrimary(context)),
                      ),
                    ],
                  ),
                  if (widget.item.unit.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        'Satuan: ${widget.item.unit}',
                        style: TextStyle(
                          color: AppColors.getTextSecondary(context),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.getSurfaceCard(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.getBorder(context)),
              ),
              child: Column(
                children: [
                  _buildMetaRow(context, 'Satuan', widget.item.unit.isNotEmpty ? widget.item.unit : '-'),
                  Divider(color: AppColors.getBorder(context), height: 18),
                  _buildMetaRow(context, 'Terakhir Diperbarui', timeFormat.format(widget.item.updatedAt)),
                  Divider(color: AppColors.getBorder(context), height: 18),
                  _buildMetaRow(
                    context,
                    'Petugas Gudang',
                    widget.item.updatedBy
                        .replaceAll(RegExp(r'\s*\((Admin|Scanner)\)', caseSensitive: false), '')
                        .trim(),
                  ),
                  if (widget.item.gpsReport != null) ...[
                    Divider(color: AppColors.getBorder(context), height: 18),
                    _buildMetaRow(
                      context,
                      'Verifikasi Lokasi',
                      widget.item.gpsReport!.isMock
                          ? '⚠ Mock GPS Detected'
                          : 'GPS (${widget.item.gpsReport!.latitude.toStringAsFixed(4)}, ${widget.item.gpsReport!.longitude.toStringAsFixed(4)})',
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

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

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _confirmAndDeleteItem,
                icon: const Icon(CupertinoIcons.trash, color: AppColors.red, size: 18),
                label: const Text(
                  'Hapus Barang dari Inventaris',
                  style: TextStyle(
                    color: AppColors.red,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.red, width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      color: AppColors.getSurfaceLight(context),
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
              style: TextStyle(
                color: AppColors.getTextSecondary(context),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 13),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: AppColors.getTextPrimary(context),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
