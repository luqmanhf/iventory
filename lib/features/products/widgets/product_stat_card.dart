import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ProductStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String percentage;
  final bool isGreen;

  const ProductStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.percentage,
    required this.isGreen,
  });

  @override
  Widget build(BuildContext context) {
    final Color badgeBg = isGreen ? const Color(0xFFE6F8EE) : const Color(0xFFE8F4FF);
    final Color badgeColor = isGreen ? AppColors.green : AppColors.primaryBlue;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_upward,
                  size: 12,
                  color: badgeColor,
                ),
                const SizedBox(width: 4),
                Text(
                  percentage,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
