import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/app_bar_widget.dart';
import '../../core/widgets/category_icon_widget.dart';
import '../../data/repositories/auth_repository.dart';
import 'widgets/donut_chart_card.dart';
import 'widgets/smart_insight_card.dart';
import 'report_provider.dart';

class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: HematYukAppBar(
        title: 'Laporan',
        avatarUrl: user?.photoURL,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Month selector
            _buildMonthSelector(ref, state),
            const SizedBox(height: 16),

            // Donut chart
            const DonutChartCard(),
            const SizedBox(height: 16),

            // Smart insight
            const SmartInsightCard(),
            const SizedBox(height: 20),

            // Category detail list
            _buildRincianHeader(),
            const SizedBox(height: 12),
            _buildCategoryList(state),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector(WidgetRef ref, ReportState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.chipBackground,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded,
                  color: AppColors.primaryDark),
              onPressed: () =>
                  ref.read(reportProvider.notifier).previousMonth(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
            Expanded(
              child: Text(
                DateFormatter.formatMonth(state.selectedMonth),
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded,
                  color: AppColors.primaryDark),
              onPressed: () => ref.read(reportProvider.notifier).nextMonth(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRincianHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text('Rincian', style: AppTextStyles.headingSmall),
    );
  }

  Widget _buildCategoryList(ReportState state) {
    if (state.categoryReports.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.pie_chart_outline_rounded,
                  size: 56, color: AppColors.navInactive),
              const SizedBox(height: 12),
              Text(
                'Belum ada data bulan ini',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: state.categoryReports.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final report = state.categoryReports[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              CategoryIconWidget(categoryId: report.category.id, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(report.category.name, style: AppTextStyles.labelMedium),
                    const SizedBox(height: 2),
                    Text(
                      '${report.percentage.toStringAsFixed(0)}% dari total',
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: report.percentage / 100,
                        backgroundColor: AppColors.divider,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.chartColors[
                              index % AppColors.chartColors.length],
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '-${CurrencyFormatter.format(report.amount)}',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.expense,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
