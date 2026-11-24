import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';

class RevenueChartWidget extends StatelessWidget {
  const RevenueChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Revenue Header & Percentage Badge
        const Text(
          'Revenue',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '\$27,003.98',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.greenLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '+7.6%',
                style: TextStyle(
                  color: AppColors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Interactive Spline Line Chart
        SizedBox(
          height: 220,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          const days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
                          final index = value.toInt();
                          if (index >= 0 && index < days.length) {
                            final isHighlight = index == 4; // Friday
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                days[index],
                                style: TextStyle(
                                  color: isHighlight
                                      ? AppColors.primaryBlue
                                      : AppColors.textMuted,
                                  fontSize: 12,
                                  fontWeight: isHighlight
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 6,
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 1.8),
                        FlSpot(0.8, 2.2),
                        FlSpot(1.5, 3.2),
                        FlSpot(2.3, 2.7),
                        FlSpot(3.1, 3.4),
                        FlSpot(4.0, 4.8), // Friday Peak
                        FlSpot(4.8, 2.1),
                        FlSpot(5.5, 1.9),
                        FlSpot(6.0, 1.2),
                      ],
                      isCurved: true,
                      curveSmoothness: 0.35,
                      color: AppColors.primaryBlue,
                      barWidth: 2.8,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        checkToShowDot: (spot, barData) => spot.x == 4.0,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 5,
                            color: AppColors.textPrimary,
                            strokeWidth: 2.5,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primaryBlue.withValues(alpha: 0.22),
                            AppColors.primaryBlue.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Tooltip Badge "$2,673" at Friday (X = 4.0)
              Positioned(
                left: 175,
                top: 0,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Text(
                        '\$2,673',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      width: 1.5,
                      height: 18,
                      color: AppColors.primaryBlue.withValues(alpha: 0.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
