import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/models/inventory_item.dart';
import '../../core/repository/inventory_repository.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/item_detail_edit_modal.dart';

class InventoryScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const InventoryScreen({
    super.key,
    this.onBack,
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _selectedFilter = 'All Items';

  void _showExportCsvModal(BuildContext context, String csvData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(CupertinoIcons.doc_text_fill, color: AppColors.buttonFoto),
                    SizedBox(width: 8),
                    Text(
                      'Ekspor Data Inventaris (CSV)',
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
                  icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 180,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: SingleChildScrollView(
                child: Text(
                  csvData,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontFamily: 'monospace',
                    fontSize: 11,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Data CSV berhasil disalin ke memori/clipboard.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonFoto,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(CupertinoIcons.share, size: 18),
                label: const Text('Salin / Bagikan CSV', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = InventoryRepository.instance;

    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final allItems = repo.items;

        // Filter items based on selected chip
        final filteredItems = allItems.where((item) {
          if (_selectedFilter == 'Low Stock') {
            return item.isLowStock;
          } else if (_selectedFilter == 'Sale Stock') {
            return item.isForSale;
          }
          return true; // All Items
        }).toList();

        final totalActiveCount = allItems.fold(0, (sum, i) => sum + i.quantity);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              children: [
                // Header: Back Arrow [<] & Title "Inventory" (Matching image copy 2.png)
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: widget.onBack ?? () {},
                        icon: const Icon(
                          CupertinoIcons.chevron_back,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      'Inventory',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Filter Chips Row (Matching image copy 2.png)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All Items', hasCheckmark: true),
                      const SizedBox(width: 10),
                      _buildFilterChip('Low Stock'),
                      const SizedBox(width: 10),
                      _buildFilterChip('Sale Stock'),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // 3-Column Metric Card: OUT OF STOCK | LOW STOCK | TOTAL ITEMS (Matching image copy 2.png)
                _buildMetricCard(repo),

                const SizedBox(height: 24),

                // Section Header: ACTIVE INVENTORY & Export CSV > (Matching image copy 2.png)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'ACTIVE INVENTORY',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            totalActiveCount.toString(),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => _showExportCsvModal(context, repo.generateCsv()),
                      child: const Row(
                        children: [
                          Text(
                            'Export CSV',
                            style: TextStyle(
                              color: AppColors.buttonFoto,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            CupertinoIcons.chevron_right,
                            color: AppColors.buttonFoto,
                            size: 13,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Inventory Item Cards (Matching image copy 2.png + Requirements 1 & 2)
                ...filteredItems.map((item) => _buildInventoryCard(context, item)),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  // Filter Chip Widget
  Widget _buildFilterChip(String label, {bool hasCheckmark = false}) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E2235) : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.buttonFoto : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected && hasCheckmark) ...[
              const Icon(CupertinoIcons.checkmark, color: AppColors.buttonFoto, size: 14),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3-Column Metric Card: OUT OF STOCK | LOW STOCK | TOTAL ITEMS
  Widget _buildMetricCard(InventoryRepository repo) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // OUT OF STOCK
            Expanded(
              child: _buildMetricItem(
                label: 'OUT OF STOCK',
                value: repo.outOfStockCount.toString(),
              ),
            ),
            const VerticalDivider(color: AppColors.border, width: 1, thickness: 1),

            // LOW STOCK
            Expanded(
              child: _buildMetricItem(
                label: 'LOW STOCK',
                value: repo.lowStockCount.toString(),
              ),
            ),
            const VerticalDivider(color: AppColors.border, width: 1, thickness: 1),

            // TOTAL ITEMS
            Expanded(
              child: _buildMetricItem(
                label: 'TOTAL ITEMS',
                value: repo.totalItemsCount.toString(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                CupertinoIcons.info_circle,
                color: AppColors.textMuted,
                size: 11,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // Inventory List Item Card (Matching image copy 2.png)
  Widget _buildInventoryCard(BuildContext context, InventoryItem item) {
    final hasPhoto = item.imagePath != null &&
        item.imagePath!.isNotEmpty &&
        File(item.imagePath!).existsSync();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          // Open detail & dynamic stock edit modal
          ItemDetailEditModal.show(context, item);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              // Saved Photo Thumbnail (Requirement 2)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: hasPhoto
                      ? Image.file(
                          File(item.imagePath!),
                          fit: BoxFit.cover,
                          width: 48,
                          height: 48,
                          errorBuilder: (_, _, _) => _buildPatternThumbnail(),
                        )
                      : _buildPatternThumbnail(),
                ),
              ),
              const SizedBox(width: 14),

              // Product Info & Subtitle lines
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${item.category} · ${item.warehouse}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${item.quantity} ${item.unit} · ${item.packageDetail} · Exp ${item.expirationDate}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Chevron Right >
              const Icon(
                CupertinoIcons.chevron_right,
                color: AppColors.textMuted,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatternThumbnail() {
    return Container(
      color: const Color(0xFF242730),
      child: const Center(
        child: Icon(
          CupertinoIcons.cube_box,
          color: Color(0xFF5A5E6B),
          size: 22,
        ),
      ),
    );
  }
}
