import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/security/gps_security_service.dart';

class ScanReviewModal extends StatefulWidget {
  final int initialCount;
  final GpsSecurityReport gpsReport;
  final Function(int finalCount, String category) onConfirmSave;

  const ScanReviewModal({
    super.key,
    required this.initialCount,
    required this.gpsReport,
    required this.onConfirmSave,
  });

  @override
  State<ScanReviewModal> createState() => _ScanReviewModalState();
}

class _ScanReviewModalState extends State<ScanReviewModal> {
  late int _currentCount;
  String _selectedCategory = 'Vegetables';
  bool _isSaving = false;

  final List<String> _categories = [
    'Vegetables',
    'Sweet Food',
    'Snack',
    'Fruits',
    'Warehouse Box',
  ];

  @override
  void initState() {
    super.initState();
    _currentCount = widget.initialCount;
  }

  @override
  Widget build(BuildContext context) {
    final bool isWarning = widget.gpsReport.trustLevel == TrustLevel.warning;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Konfirmasi Hasil Pindaian AI',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Sesuaikan jumlah dan kategori jika diperlukan sebelum disimpan ke cache lokal.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 20),

          // Object Counter Adjustment (+ / -)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Jumlah Barang Terdeteksi',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'YOLOv8 Nano inference result',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (_currentCount > 1) {
                          setState(() => _currentCount--);
                        }
                      },
                      icon: const Icon(Icons.remove_circle_outline),
                      color: AppColors.primaryBlue,
                    ),
                    Text(
                      '$_currentCount',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() => _currentCount++);
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppColors.primaryBlue,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Category Dropdown
          const Text(
            'Kategori Produk',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedCategory,
                items: _categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedCategory = val);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // GPS Audit Info Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isWarning ? AppColors.orangeWarningLight : AppColors.greenLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  isWarning ? Icons.warning_rounded : Icons.verified_rounded,
                  color: isWarning ? AppColors.orangeWarning : AppColors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isWarning
                        ? 'Koordinat: ${widget.gpsReport.latitude.toStringAsFixed(4)}, ${widget.gpsReport.longitude.toStringAsFixed(4)} (FLAGGED: UNTRUSTED MOCK GPS)'
                        : 'Koordinat: ${widget.gpsReport.latitude.toStringAsFixed(4)}, ${widget.gpsReport.longitude.toStringAsFixed(4)} (VERIFIED GPS)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isWarning
                          ? const Color(0xFF92400E)
                          : const Color(0xFF047857),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSaving
                  ? null
                  : () async {
                      setState(() => _isSaving = true);
                      await widget.onConfirmSave(_currentCount, _selectedCategory);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Simpan ke Storage Sementara',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
