import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ProductCategoryItem extends StatelessWidget {
  final String title;
  final String emoji;
  final Color avatarBg;
  final int incomingCount;
  final int outgoingCount;
  final bool isLowStock;
  final VoidCallback? onTap;

  const ProductCategoryItem({
    super.key,
    required this.title,
    required this.emoji,
    required this.avatarBg,
    required this.incomingCount,
    required this.outgoingCount,
    this.isLowStock = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Circular Avatar with Emoji / Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: avatarBg,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Title & Low Stock Badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (isLowStock) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.peachLowStock,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Low Stock',
                            style: TextStyle(
                              color: AppColors.peachText,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Incoming (▲ green)
                      const Icon(
                        Icons.arrow_drop_up,
                        size: 16,
                        color: AppColors.green,
                      ),
                      Text(
                        '$incomingCount',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Outgoing (▼ red)
                      const Icon(
                        Icons.arrow_drop_down,
                        size: 16,
                        color: AppColors.red,
                      ),
                      Text(
                        '$outgoingCount',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Chevron Right
            const Icon(
              CupertinoIcons.chevron_right,
              color: AppColors.textMuted,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
