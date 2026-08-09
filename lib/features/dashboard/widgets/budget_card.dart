import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/repositories/budget_repository.dart';
import '../dashboard_provider.dart';

final budgetTargetProvider = StateProvider<double>((ref) => 5000000.0);

class BudgetCard extends ConsumerWidget {
  const BudgetCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashState = ref.watch(dashboardProvider);
    final budgetRepo = ref.watch(budgetRepositoryProvider);
    final budget = budgetRepo.monthlyBudget;
    final spent = dashState.monthlyExpense;
    final percent = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final remaining = budget - spent;
    final isWarning = percent >= 0.8;
    final isDanger = percent >= 1.0;

    Color progressColor;
    if (isDanger) {
      progressColor = AppColors.expense;
    } else if (isWarning) {
      progressColor = const Color(0xFFFF9800);
    } else {
      progressColor = AppColors.primaryDark;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDanger
                ? AppColors.expense.withOpacity(0.4)
                : isWarning
                    ? const Color(0xFFFF9800).withOpacity(0.4)
                    : AppColors.divider,
          ),
          boxShadow: [
            BoxShadow(
              color: isDanger
                  ? AppColors.expense.withOpacity(0.08)
                  : AppColors.primaryDark.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDanger
                        ? AppColors.expenseBg
                        : isWarning
                            ? const Color(0xFFFFF3E0)
                            : AppColors.incomeBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isDanger
                        ? Icons.warning_rounded
                        : isWarning
                            ? Icons.notifications_active_rounded
                            : Icons.savings_rounded,
                    color: progressColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Anggaran Bulan Ini', style: AppTextStyles.labelMedium),
                      Text(
                        isDanger
                            ? '⚠️ Anggaran sudah habis!'
                            : isWarning
                                ? '⚠️ Hampir mencapai batas!'
                                : 'Keuangan aman 👍',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: progressColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _showSetBudget(context, ref, budget),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.incomeBg,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      'Ubah',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar
            Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  height: 10,
                  width: MediaQuery.of(context).size.width * percent * 0.82,
                  decoration: BoxDecoration(
                    color: progressColor,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Amount info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Terpakai', style: AppTextStyles.bodySmall),
                    Text(
                      CurrencyFormatter.format(spent),
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.expense,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${(percent * 100).toStringAsFixed(0)}% dari budget', style: AppTextStyles.bodySmall),
                    Text(
                      remaining >= 0
                          ? 'Sisa ${CurrencyFormatter.format(remaining)}'
                          : 'Lebih ${CurrencyFormatter.format(-remaining)}',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: remaining >= 0 ? AppColors.primaryDark : AppColors.expense,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSetBudget(BuildContext context, WidgetRef ref, double current) {
    final controller = TextEditingController(
      text: current.toInt().toString(),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.incomeBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.savings_rounded, color: AppColors.primaryDark, size: 20),
            ),
            const SizedBox(width: 12),
            Text('Atur Anggaran', style: AppTextStyles.headingSmall),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Target pengeluaran bulanan kamu:', style: AppTextStyles.bodySmall),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: 'Rp ',
                prefixStyle: AppTextStyles.labelMedium,
                hintText: '5.000.000',
                filled: true,
                fillColor: AppColors.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: AppTextStyles.headingSmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal',
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final val = double.tryParse(controller.text.replaceAll('.', '').replaceAll(',', ''));
              if (val != null && val > 0) {
                await ref.read(budgetRepositoryProvider).setMonthlyBudget(val);
                // ignore: unused_result
                ref.invalidate(budgetRepositoryProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Simpan', style: AppTextStyles.labelMedium.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
