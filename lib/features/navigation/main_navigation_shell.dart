import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../dashboard/dashboard_screen.dart';
import '../inventory/inventory_screen.dart';
import '../scan/scan_products_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  bool _isScannerOpen = false;

  void _openScanner() {
    setState(() => _isScannerOpen = true);
  }

  void _closeScanner() {
    setState(() => _isScannerOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isScannerOpen) {
      return ScanProductsScreen(
        onBack: _closeScanner,
        onScanSaved: () {
          _closeScanner();
          setState(() {
            _currentIndex = 2;
          });
        },
      );
    }

    final screens = [
      const DashboardScreen(),
      const SizedBox.shrink(),
      InventoryScreen(
        onBack: () => setState(() => _currentIndex = 0),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.getBottomNavBg(context),
          border: Border(
            top: BorderSide(color: AppColors.getBorder(context), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                index: 0,
                label: 'Home',
                icon: CupertinoIcons.home,
                activeIcon: CupertinoIcons.house_fill,
              ),
              _buildNavItem(
                context: context,
                index: 1,
                label: 'Scan',
                icon: CupertinoIcons.camera,
                activeIcon: CupertinoIcons.camera_fill,
                onTap: _openScanner,
              ),
              _buildNavItem(
                context: context,
                index: 2,
                label: 'Inventory',
                icon: CupertinoIcons.archivebox,
                activeIcon: CupertinoIcons.archivebox_fill,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
    VoidCallback? onTap,
  }) {
    final bool isSelected = _currentIndex == index && index != 1;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap ?? () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.getNavPillBg(context, isSelected),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? AppColors.buttonFoto : AppColors.getTextSecondary(context),
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? (isDark ? Colors.white : AppColors.buttonFoto)
                    : AppColors.getTextSecondary(context),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
