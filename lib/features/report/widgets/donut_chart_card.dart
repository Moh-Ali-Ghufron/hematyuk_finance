import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../report_provider.dart';

class DonutChartCard extends ConsumerStatefulWidget {
  const DonutChartCard({super.key});

  @override
  ConsumerState<DonutChartCard> createState() => _DonutChartCardState();
}

class _DonutChartCardState extends ConsumerState<DonutChartCard> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportProvider);
    final reports = state.categoryReports;

    // Demo data if empty
    final chartData = reports.isEmpty
        ? _demoSections()
        : reports.asMap().entries.map((e) {
            final idx = e.key;
            final report = e.value;
            final color = AppColors.chartColors[idx % AppColors.chartColors.length];
            final isTouched = idx == _touchedIndex;
            return PieChartSectionData(
              color: color,
              value: report.amount,
              title: '',
              radius: isTouched ? 70 : 60,
              badgeWidget: null,
            );
          }).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pengeluaran Kategori', style: AppTextStyles.headingSmall),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _touchedIndex = -1;
                            return;
                          }
                          _touchedIndex = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 3,
                    centerSpaceRadius: 60,
                    sections: chartData,
                  ),
                ),
                // Center text
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.formatCompact(state.totalExpense),
                      style: AppTextStyles.headingSmall.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Legend
          if (reports.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: reports.asMap().entries.take(4).map((e) {
                final color = AppColors.chartColors[e.key % AppColors.chartColors.length];
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      e.value.category.name,
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  List<PieChartSectionData> _demoSections() {
    final colors = [
      AppColors.primaryDark,
      AppColors.primaryMedium,
      const Color(0xFF4DC78A),
      const Color(0xFF82D9AE),
      const Color(0xFFB3EDD0),
    ];
    final values = [40.0, 25.0, 15.0, 12.0, 8.0];
    return List.generate(5, (i) {
      return PieChartSectionData(
        color: colors[i],
        value: values[i],
        title: '',
        radius: 60,
      );
    });
  }
}
