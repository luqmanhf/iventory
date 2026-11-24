import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class TimeframeSelector extends StatelessWidget {
  final String selectedTimeframe;
  final ValueChanged<String> onSelected;

  const TimeframeSelector({
    super.key,
    required this.selectedTimeframe,
    required this.onSelected,
  });

  static const List<String> timeframes = ['1D', '1W', '1M', '3M', '6M', '1Y'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: timeframes.map((tf) {
        final bool isSelected = tf == selectedTimeframe;
        return GestureDetector(
          onTap: () => onSelected(tf),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryBlue : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              tf,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
