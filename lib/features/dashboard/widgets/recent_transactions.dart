import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/transaction_list_item.dart';
import '../../../features/transaction/widgets/transaction_detail_bottom_sheet.dart';
import '../dashboard_provider.dart';

class RecentTransactions extends ConsumerWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Transaksi Terbaru', style: AppTextStyles.headingSmall),
              GestureDetector(
                onTap: () => context.go('/history'),
                child: Text(
                  'Lihat Semua',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (state.recentTransactions.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Icon(Icons.receipt_long_outlined,
                    color: AppColors.navInactive, size: 48),
                const SizedBox(height: 8),
                Text(
                  'Belum ada transaksi',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          )
        else
          ...state.recentTransactions.map((t) => TransactionListItem(
                transaction: t,
                onTap: () => showTransactionDetail(context, ref, t),
              )),
      ],
    );
  }
}
