import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/inventory_item.dart';
import '../../core/repository/inventory_repository.dart';
import '../../core/theme/app_theme.dart';
import '../inventory/widgets/item_detail_edit_modal.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onOpenScan;
  final VoidCallback? onOpenInventory;

  const DashboardScreen({
    super.key,
    this.onOpenScan,
    this.onOpenInventory,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedItemIds = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });

    // Inisialisasi sampel foto jika belum tersedia
    WidgetsBinding.instance.addPostFrameCallback((_) {
      InventoryRepository.instance.ensureSampleImagesForSeedItems();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSelection(String itemId) {
    setState(() {
      if (_selectedItemIds.contains(itemId)) {
        _selectedItemIds.remove(itemId);
      } else {
        _selectedItemIds.add(itemId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = InventoryRepository.instance;

    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final allItems = repo.items;
        final filteredItems = allItems.where((item) {
          if (_searchQuery.isEmpty) return true;
          return item.name.toLowerCase().contains(_searchQuery) ||
              item.category.toLowerCase().contains(_searchQuery) ||
              item.warehouse.toLowerCase().contains(_searchQuery);
        }).toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              children: [
                // Top Header: User Profile Budi + Moon & Bell Icons (Matching image.png)
                Row(
                  children: [
                    // Avatar & Username
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          CupertinoIcons.person_fill,
                          color: AppColors.textSecondary,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Budi',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),

                    // Dark Mode Toggle Icon Button
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
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tema gelap aktif.'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: const Icon(
                          CupertinoIcons.moon,
                          color: AppColors.textPrimary,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Notification Bell Icon Button
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Ada ${repo.lowStockCount} item dalam status stok menipis.'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(
                              CupertinoIcons.bell,
                              color: AppColors.textPrimary,
                              size: 18,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 9,
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: AppColors.buttonFoto,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Search Bar (Matching image.png)
                Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                      prefixIcon: Icon(
                        CupertinoIcons.search,
                        color: AppColors.textMuted,
                        size: 18,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Dynamic 3-Column Stock Metrics Card (Matching image.png)
                _buildMetricsCard(repo),

                const SizedBox(height: 24),

                // Dashboard Section Header with Badge (Matching image.png)
                Row(
                  children: [
                    const Text(
                      'Dashboard',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        filteredItems.length.toString(),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Stock Activity List (Matching image.png + Requirement 1 & 2)
                ...filteredItems.map((item) => _buildStockCard(context, item)),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  // 3-Column Metric Card: SALE STOCK | LOW STOCK | TOTAL ITEMS
  Widget _buildMetricsCard(InventoryRepository repo) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Column 1: SALE STOCK
            Expanded(
              child: _buildMetricItem(
                label: 'SALE STOCK',
                value: repo.saleStockCount.toString(),
              ),
            ),
            const VerticalDivider(color: AppColors.border, width: 1, thickness: 1),

            // Column 2: LOW STOCK
            Expanded(
              child: _buildMetricItem(
                label: 'LOW STOCK',
                value: repo.lowStockCount.toString(),
              ),
            ),
            const VerticalDivider(color: AppColors.border, width: 1, thickness: 1),

            // Column 3: TOTAL ITEMS
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
                    fontSize: 10,
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

  // Stock List Item Card with Saved Photo & Selection Checkbox
  Widget _buildStockCard(BuildContext context, InventoryItem item) {
    final isSelected = _selectedItemIds.contains(item.id);
    final timeStr = DateFormat('h:mm a').format(item.updatedAt);
    final hasPhoto = item.imagePath != null &&
        item.imagePath!.isNotEmpty &&
        File(item.imagePath!).existsSync();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? AppColors.buttonFoto.withValues(alpha: 0.6) : AppColors.border,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          // Open detail and dynamic stock edit modal
          ItemDetailEditModal.show(context, item);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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

              // Title & Subtitle: Name, PIC & Time
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
                    const SizedBox(height: 4),
                    Text(
                      '${item.updatedBy} | $timeStr',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // Quantity Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              // Checkbox indicator on right (matching image.png)
              GestureDetector(
                onTap: () => _toggleSelection(item.id),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.buttonFoto : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected ? AppColors.buttonFoto : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          CupertinoIcons.checkmark,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
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
          CupertinoIcons.photo,
          color: Color(0xFF5A5E6B),
          size: 22,
        ),
      ),
    );
  }
}
