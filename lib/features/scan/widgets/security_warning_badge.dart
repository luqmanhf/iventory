import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/security/gps_security_service.dart';

class SecurityWarningBadge extends StatelessWidget {
  final GpsSecurityReport report;
  final VoidCallback onToggleSimulation;

  const SecurityWarningBadge({
    super.key,
    required this.report,
    required this.onToggleSimulation,
  });

  @override
  Widget build(BuildContext context) {
    final bool isWarning = report.trustLevel == TrustLevel.warning;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isWarning ? AppColors.orangeWarningLight : AppColors.greenLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWarning
              ? AppColors.orangeWarning.withValues(alpha: 0.5)
              : AppColors.green.withValues(alpha: 0.5),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            isWarning ? Icons.warning_amber_rounded : Icons.verified_user_rounded,
            color: isWarning ? AppColors.orangeWarning : AppColors.green,
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isWarning
                      ? '⚠️ Peringatan: Mock / Fake GPS Terdeteksi'
                      : '🛡️ Lokasi Terverifikasi (Hardware GPS)',
                  style: TextStyle(
                    color: isWarning
                        ? const Color(0xFFB45309)
                        : const Color(0xFF065F46),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isWarning
                      ? 'Audit ditandai [UNTRUSTED]. Foto tetap dapat diambil untuk review.'
                      : 'Akurasi: ±${report.accuracy.toStringAsFixed(1)}m • Satelit aktif',
                  style: TextStyle(
                    color: isWarning
                        ? const Color(0xFF92400E)
                        : const Color(0xFF047857),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // Tombol simulasi untuk pengujian QA / demo
          TextButton(
            onPressed: onToggleSimulation,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              isWarning ? 'Matikan Mock' : 'Tes Fake GPS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isWarning ? AppColors.orangeWarning : AppColors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
