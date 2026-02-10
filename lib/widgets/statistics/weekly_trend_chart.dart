import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';
import '../../models/expense_statistics.dart';

/// [Project] Buddy - AI 가계부 서비스
/// [File] WeeklyTrendChart - 7일간 트렌드 차트 위젯
/// [Author] 이준수 (PM & Design)
/// [Description]
/// 최근 7일간 지출 추이를 라인 차트로 표시
/// 터치 시 툴팁으로 해당 날짜의 지출 금액 표시

class WeeklyTrendChart extends StatelessWidget {
  final List<DailyExpense> dailyData;

  const WeeklyTrendChart({
    super.key,
    required this.dailyData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingMedium),
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '7일간 지출 추이',
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _calculateInterval(),
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.divider,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: _buildTitles(),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: _getMaxY(),
                lineBarsData: [
                  LineChartBarData(
                    spots: _buildSpots(),
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.3),
                          AppColors.primary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) {
                        return FlDotCirclePainter(
                          radius: 5,
                          color: AppColors.primary,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => AppColors.textPrimary,
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (spots) => spots.map((spot) {
                      final formatter = NumberFormat('#,###');
                      return LineTooltipItem(
                        '${formatter.format(spot.y.toInt())}원',
                        AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList(),
                  ),
                  handleBuiltInTouches: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _buildSpots() {
    return dailyData.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.amount.toDouble(),
      );
    }).toList();
  }

  double _getMaxY() {
    if (dailyData.isEmpty) return 100000;
    final maxAmount = dailyData
        .map((e) => e.amount)
        .reduce((a, b) => a > b ? a : b);
    return (maxAmount * 1.2).roundToDouble();
  }

  double _calculateInterval() {
    final maxY = _getMaxY();
    return (maxY / 4).roundToDouble();
  }

  FlTitlesData _buildTitles() {
    final weekDays = ['월', '화', '수', '목', '금', '토', '일'];

    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: 1,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= dailyData.length) {
              return const SizedBox.shrink();
            }
            final dayOfWeek = dailyData[index].date.weekday;
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                weekDays[(dayOfWeek - 1) % 7],
                style: AppTextStyles.caption,
              ),
            );
          },
        ),
      ),
      leftTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
