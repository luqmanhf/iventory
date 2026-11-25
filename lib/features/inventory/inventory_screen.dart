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
  String? _selectedUnit;
  String? _selectedCategory;
  String? _selectedWarehouse;

  bool get _isFilterActive =>
      _selectedUnit != null ||
      _selectedCategory != null ||
      _selectedWarehouse != null;

  void _clearFilters() {
    setState(() {
      _selectedUnit = null;
      _selectedCategory = null;
      _selectedWarehouse = null;
    });
  }

  void _showFilterSettingModal(BuildContext context, List<InventoryItem> allItems) {
    final units = allItems
        .map((e) => e.unit.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final categories = allItems
        .map((e) => e.category.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final warehouses = allItems
        .map((e) => e.warehouse.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    String? tempUnit = _selectedUnit;
    String? tempCategory = _selectedCategory;
    String? tempWarehouse = _selectedWarehouse;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 14,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: AppColors.getSurface(context),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.getBorder(context),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            CupertinoIcons.slider_horizontal_3,
                            color: AppColors.buttonFoto,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Filter Inventaris',
                            style: TextStyle(
                              color: AppColors.getTextPrimary(context),
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          CupertinoIcons.xmark_circle_fill,
                          color: AppColors.getTextMuted(context),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Section 1: Satuan
                  _buildFilterSectionTitle(context, 'Satuan', tempUnit),
                  const SizedBox(height: 8),
                  _buildDropdownSelector(
                    context: context,
                    hint: 'Semua Satuan',
                    value: tempUnit,
                    items: units,
                    onChanged: (val) {
                      setModalState(() => tempUnit = val);
                    },
                  ),

                  const SizedBox(height: 18),

                  // Section 2: Kategori
                  _buildFilterSectionTitle(context, 'Kategori', tempCategory),
                  const SizedBox(height: 8),
                  _buildDropdownSelector(
                    context: context,
                    hint: 'Semua Kategori',
                    value: tempCategory,
                    items: categories,
                    onChanged: (val) {
                      setModalState(() => tempCategory = val);
                    },
                  ),

                  const SizedBox(height: 18),

                  // Section 3: Lokasi Gudang
                  _buildFilterSectionTitle(context, 'Lokasi Gudang', tempWarehouse),
                  const SizedBox(height: 8),
                  _buildDropdownSelector(
                    context: context,
                    hint: 'Semua Lokasi Gudang',
                    value: tempWarehouse,
                    items: warehouses,
                    onChanged: (val) {
                      setModalState(() => tempWarehouse = val);
                    },
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              tempUnit = null;
                              tempCategory = null;
                              tempWarehouse = null;
                            });
                            setState(() {
                              _selectedUnit = null;
                              _selectedCategory = null;
                              _selectedWarehouse = null;
                            });
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: AppColors.getBorder(context)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Reset Filter',
                            style: TextStyle(
                              color: AppColors.getTextSecondary(context),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedUnit = tempUnit;
                              _selectedCategory = tempCategory;
                              _selectedWarehouse = tempWarehouse;
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonFoto,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Terapkan Filter',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSectionTitle(BuildContext context, String title, String? activeValue) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.getTextSecondary(context),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (activeValue != null)
          Text(
            activeValue,
            style: const TextStyle(
              color: AppColors.buttonFoto,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }

  Widget _buildDropdownSelector({
    required BuildContext context,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceCard(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value != null ? AppColors.buttonFoto : AppColors.getBorder(context),
          width: value != null ? 1.5 : 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint,
            style: TextStyle(color: AppColors.getTextMuted(context), fontSize: 14),
          ),
          dropdownColor: AppColors.getSurfaceCard(context),
          style: TextStyle(
            color: AppColors.getTextPrimary(context),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          icon: Icon(
            CupertinoIcons.chevron_down,
            size: 16,
            color: AppColors.getTextSecondary(context),
          ),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(
                hint,
                style: TextStyle(color: AppColors.getTextMuted(context), fontSize: 14),
              ),
            ),
            ...items.map(
              (item) => DropdownMenuItem<String?>(
                value: item,
                child: Text(item),
              ),
            ),
          ],
          onChanged: onChanged,
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

        final filteredItems = allItems.where((item) {
          if (_selectedUnit != null &&
              item.unit.toLowerCase() != _selectedUnit!.toLowerCase()) {
            return false;
          }
          if (_selectedCategory != null &&
              item.category.toLowerCase() != _selectedCategory!.toLowerCase()) {
            return false;
          }
          if (_selectedWarehouse != null &&
              item.warehouse.toLowerCase() != _selectedWarehouse!.toLowerCase()) {
            return false;
          }
          return true;
        }).toList();

        final totalActiveCount = filteredItems.fold(0, (sum, i) => sum + i.quantity);

        return Scaffold(
          backgroundColor: AppColors.getBackground(context),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              children: [
                Row(
                  children: [
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
                        onPressed: widget.onBack ?? () {},
                        icon: Icon(
                          CupertinoIcons.chevron_back,
                          color: AppColors.getTextPrimary(context),
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'Inventory',
                      style: TextStyle(
                        color: AppColors.getTextPrimary(context),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.getSurfaceCard(context),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _isFilterActive
                              ? AppColors.buttonFoto
                              : AppColors.getBorder(context),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            tooltip: 'Filter Inventaris',
                            onPressed: () => _showFilterSettingModal(context, allItems),
                            icon: Icon(
                              CupertinoIcons.slider_horizontal_3,
                              color: _isFilterActive
                                  ? AppColors.buttonFoto
                                  : AppColors.getTextPrimary(context),
                              size: 20,
                            ),
                          ),
                          if (_isFilterActive)
                            Positioned(
                              top: 8,
                              right: 8,
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

                _buildSingleSummaryCard(repo, context),

                if (_isFilterActive) ...[
                  const SizedBox(height: 14),
                  _buildActiveFilterBar(context),
                ],

                const SizedBox(height: 20),

                Row(
                  children: [
                    Text(
                      'ACTIVE INVENTORY',
                      style: TextStyle(
                        color: AppColors.getTextPrimary(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.getSurfaceLight(context),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.getBorder(context)),
                      ),
                      child: Text(
                        totalActiveCount.toString(),
                        style: TextStyle(
                          color: AppColors.getTextSecondary(context),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                if (filteredItems.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Icon(
                          CupertinoIcons.tray,
                          size: 42,
                          color: AppColors.getTextMuted(context),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tidak ada barang yang cocok dengan filter',
                          style: TextStyle(
                            color: AppColors.getTextSecondary(context),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _clearFilters,
                          child: const Text('Reset Filter'),
                        ),
                      ],
                    ),
                  )
                else
                  ...filteredItems.map((item) => _buildInventoryCard(context, item)),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveFilterBar(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (_selectedUnit != null)
            _buildActiveChip(
              context,
              label: 'Satuan: $_selectedUnit',
              onDeleted: () => setState(() => _selectedUnit = null),
            ),
          if (_selectedCategory != null) ...[
            const SizedBox(width: 8),
            _buildActiveChip(
              context,
              label: 'Kategori: $_selectedCategory',
              onDeleted: () => setState(() => _selectedCategory = null),
            ),
          ],
          if (_selectedWarehouse != null) ...[
            const SizedBox(width: 8),
            _buildActiveChip(
              context,
              label: 'Gudang: $_selectedWarehouse',
              onDeleted: () => setState(() => _selectedWarehouse = null),
            ),
          ],
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _clearFilters,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.red.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Hapus Semua',
                style: TextStyle(
                  color: AppColors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveChip(
    BuildContext context, {
    required String label,
    required VoidCallback onDeleted,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.buttonFoto.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.buttonFoto.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.buttonFoto,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onDeleted,
            child: const Icon(
              CupertinoIcons.xmark_circle_fill,
              size: 14,
              color: AppColors.buttonFoto,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleSummaryCard(InventoryRepository repo, BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.getSurfaceCard(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.getBorder(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'TOTAL ITEMS',
                  style: TextStyle(
                    color: AppColors.getTextSecondary(context),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
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
              repo.totalItemsCount.toString(),
              style: TextStyle(
                color: AppColors.getTextPrimary(context),
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryCard(BuildContext context, InventoryItem item) {
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
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          ItemDetailEditModal.show(context, item);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                    const SizedBox(height: 3),
                    Text(
                      '${item.category} · ${item.warehouse}',
                      style: TextStyle(
                        color: AppColors.getTextSecondary(context),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${item.quantity} ${item.unit} · ${item.packageDetail}',
                      style: TextStyle(
                        color: AppColors.getTextMuted(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                CupertinoIcons.chevron_right,
                color: AppColors.getTextMuted(context),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatternThumbnail(BuildContext context) {
    return Container(
      color: AppColors.getThumbnailBg(context),
      child: Center(
        child: Icon(
          CupertinoIcons.cube_box,
          color: AppColors.getThumbnailIcon(context),
          size: 22,
        ),
      ),
    );
  }
}
