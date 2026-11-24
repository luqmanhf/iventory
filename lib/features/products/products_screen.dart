import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'widgets/product_stat_card.dart';
import 'widgets/product_category_item.dart';

class ProductsScreen extends StatelessWidget {
  final VoidCallback onOpenScanner;

  const ProductsScreen({
    super.key,
    required this.onOpenScanner,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Title & Action Icons (Barcode Scan & Search)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Products',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: onOpenScanner,
                        icon: const Icon(
                          CupertinoIcons.viewfinder,
                          color: AppColors.textPrimary,
                          size: 24,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pencarian produk inventaris...'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: const Icon(
                          CupertinoIcons.search,
                          color: AppColors.textPrimary,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Metric Cards Row: "Total Products: 128" & "Stock in Hand: 2,350"
              Row(
                children: const [
                  Expanded(
                    child: ProductStatCard(
                      title: 'Total Products',
                      value: '128',
                      percentage: '+8.00%',
                      isGreen: true,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ProductStatCard(
                      title: 'Stock in Hand',
                      value: '2,350',
                      percentage: '+2.34%',
                      isGreen: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Section Header: "Products list" with Filter Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Products list',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      CupertinoIcons.slider_horizontal_3,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Product Categories matching image.png:
              ProductCategoryItem(
                title: 'Vegetables',
                emoji: '🥬',
                avatarBg: const Color(0xFFE8F5E9),
                incomingCount: 267,
                outgoingCount: 149,
                onTap: onOpenScanner,
              ),
              ProductCategoryItem(
                title: 'Sweet Food',
                emoji: '🍭',
                avatarBg: const Color(0xFFEDE7F6),
                incomingCount: 124,
                outgoingCount: 87,
                onTap: onOpenScanner,
              ),
              ProductCategoryItem(
                title: 'Snack',
                emoji: '🍟',
                avatarBg: const Color(0xFFFFF3E0),
                incomingCount: 88,
                outgoingCount: 27,
                isLowStock: true,
                onTap: onOpenScanner,
              ),
              ProductCategoryItem(
                title: 'Fruits',
                emoji: '🥑',
                avatarBg: const Color(0xFFF1F8E9),
                incomingCount: 450,
                outgoingCount: 234,
                onTap: onOpenScanner,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
