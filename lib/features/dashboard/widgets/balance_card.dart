import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../dashboard_provider.dart';

class BalanceCard extends ConsumerWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.cardGreenGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x330E6B4F),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Saldo', style: AppTextStyles.bodyMediumWhite),
              GestureDetector(
                onTap: () =>
                    ref.read(dashboardProvider.notifier).toggleBalanceVisibility(),
                child: Icon(
                  state.isBalanceHidden
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: Colors.white.withOpacity(0.8),
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: state.isBalanceHidden
                ? Text(
                    'Rp ••••••••',
                    key: const ValueKey('hidden'),
                    style: AppTextStyles.amountLarge,
                  )
                : Text(
                    CurrencyFormatter.format(state.totalBalance),
                    key: const ValueKey('shown'),
                    style: AppTextStyles.amountLarge,
                  ),
          ),
          const SizedBox(height: 12),
          _buildGrowthBadge(),
        ],
      ),
    );
  }

  Widget _buildGrowthBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.trending_up_rounded, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            '+4.5% dari bulan lalu',
            style: AppTextStyles.bodySmallWhite.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
