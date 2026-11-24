import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/security/gps_security_service.dart';
import '../../../core/theme/app_theme.dart';

class GpsAuditModal extends StatelessWidget {
  final GpsSecurityReport report;
  final VoidCallback onToggleSimulation;

  const GpsAuditModal({
    super.key,
    required this.report,
    required this.onToggleSimulation,
  });

  static Future<void> show(
    BuildContext context, {
    required GpsSecurityReport report,
    required VoidCallback onToggleSimulation,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GpsAuditModal(
        report: report,
        onToggleSimulation: onToggleSimulation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWarning = report.trustLevel == TrustLevel.warning;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
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
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(CupertinoIcons.location_solid, color: AppColors.buttonLokasi, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Audit Keamanan Lokasi GPS',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppColors.textMuted, size: 26),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Status Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isWarning
                  ? AppColors.orangeWarning.withValues(alpha: 0.12)
                  : AppColors.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isWarning
                    ? AppColors.orangeWarning.withValues(alpha: 0.4)
                    : AppColors.green.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isWarning ? CupertinoIcons.exclamationmark_triangle_fill : CupertinoIcons.shield_fill,
                  color: isWarning ? AppColors.orangeWarning : AppColors.green,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isWarning ? '⚠️ Mock / Fake GPS Terdeteksi' : '✅ Lokasi Terverifikasi Asli',
                        style: TextStyle(
                          color: isWarning ? AppColors.orangeWarning : AppColors.green,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isWarning
                            ? 'Flag isMock terdeteksi aktif. Pindaian ditandai [UNTRUSTED].'
                            : 'Koordinat satelit valid dengan akurasi tinggi.',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Detailed Table
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _buildRow('Latitude & Longitude', '${report.latitude.toStringAsFixed(6)}, ${report.longitude.toStringAsFixed(6)}'),
                const Divider(color: AppColors.border, height: 16),
                _buildRow('Akurasi Satelit', '±${report.accuracy.toStringAsFixed(1)} meter'),
                const Divider(color: AppColors.border, height: 16),
                _buildRow('Status Mock Provider', report.isMock ? 'AKTIF (Fake GPS)' : 'TIDAK (Hardware GPS)'),
                const Divider(color: AppColors.border, height: 16),
                _buildRow('Developer Options', report.isDevMode ? 'Aktif' : 'Nonaktif'),
                const Divider(color: AppColors.border, height: 16),
                _buildRow('Digital Signature', '${report.digitalSignature.substring(0, 16)}... (SHA-256)'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Toggle Simulation Button
          OutlinedButton.icon(
            onPressed: () {
              onToggleSimulation();
              Navigator.pop(context);
            },
            icon: Icon(
              report.isMock ? CupertinoIcons.checkmark_shield : CupertinoIcons.exclamationmark_shield,
              color: AppColors.buttonLokasi,
              size: 18,
            ),
            label: Text(
              report.isMock ? 'Matikan Simulasi Fake GPS' : 'Uji Simulasi Fake GPS (Mock)',
              style: const TextStyle(color: AppColors.buttonLokasi, fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 46),
              side: const BorderSide(color: AppColors.buttonLokasi),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
