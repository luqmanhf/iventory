import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/inventory_item.dart';
import '../../core/repository/inventory_repository.dart';
import '../../core/theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      InventoryRepository.instance.ensureSampleImagesForSeedItems();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = InventoryRepository.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          backgroundColor: AppColors.getBackground(context),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.getSurfaceLight(context),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          CupertinoIcons.person_fill,
                          color: AppColors.getTextSecondary(context),
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Budi',
                      style: TextStyle(
                        color: AppColors.getTextPrimary(context),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.getSurfaceCard(context),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.getBorder(context)),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        tooltip: isDark ? 'Beralih ke Mode Terang' : 'Beralih ke Mode Gelap',
                        onPressed: () {
                          ThemeController.instance.toggleTheme();
                        },
                        icon: Icon(
                          isDark ? CupertinoIcons.moon_fill : CupertinoIcons.sun_max_fill,
                          color: isDark ? AppColors.buttonLokasi : Colors.amber.shade600,
                          size: 19,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),
                Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.getSurfaceCard(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.getBorder(context)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(color: AppColors.getTextMuted(context), fontSize: 14),
                      prefixIcon: Icon(
                        CupertinoIcons.search,
                        color: AppColors.getTextMuted(context),
                        size: 18,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                _buildMetricsCard(context, repo),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Text(
                      'Dashboard',
                      style: TextStyle(
                        color: AppColors.getTextPrimary(context),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.getSurfaceLight(context),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.getBorder(context)),
                      ),
                      child: Text(
                        filteredItems.length.toString(),
                        style: TextStyle(
                          color: AppColors.getTextSecondary(context),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                ...filteredItems.map((item) => _buildStockCard(context, item)),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricsCard(BuildContext context, InventoryRepository repo) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.getSurfaceCard(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.getBorder(context)),
      ),
      child: _buildMetricItem(
        context: context,
        label: 'TOTAL ITEMS',
        value: repo.totalItemsCount.toString(),
      ),
    );
  }

  Widget _buildMetricItem({
    required BuildContext context,
    required String label,
    required String value,
  }) {
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
                  style: TextStyle(
                    color: AppColors.getTextSecondary(context),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                CupertinoIcons.info_circle,
                color: AppColors.getTextMuted(context),
                size: 11,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: AppColors.getTextPrimary(context),
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockCard(BuildContext context, InventoryItem item) {
    final timeStr = DateFormat('h:mm a').format(item.updatedAt);
    final cleanUpdatedBy = item.updatedBy.replaceAll(RegExp(r'\s*\((Admin|Scanner)\)', caseSensitive: false), '').trim();
    final hasPhoto = item.imagePath != null &&
        item.imagePath!.isNotEmpty &&
        File(item.imagePath!).existsSync();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceCard(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.getBorder(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.getSurfaceLight(context),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.getBorder(context)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: hasPhoto
                    ? Image.file(
                        File(item.imagePath!),
                        fit: BoxFit.cover,
                        width: 48,
                        height: 48,
                        errorBuilder: (_, _, _) => _buildPatternThumbnail(context),
                      )
                    : _buildPatternThumbnail(context),
              ),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      color: AppColors.getTextPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$cleanUpdatedBy | $timeStr',
                    style: TextStyle(
                      color: AppColors.getTextSecondary(context),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.getSurfaceLight(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${item.quantity}',
                style: TextStyle(
                  color: AppColors.getTextPrimary(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternThumbnail(BuildContext context) {
    return Container(
      color: AppColors.getSurfaceLight(context),
      child: Center(
        child: Icon(
          CupertinoIcons.photo,
          color: AppColors.getTextMuted(context),
          size: 22,
        ),
      ),
    );
  }
}
