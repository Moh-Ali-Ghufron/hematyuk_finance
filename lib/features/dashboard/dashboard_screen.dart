import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_bar_widget.dart';
import '../../data/repositories/auth_repository.dart';
import 'widgets/balance_card.dart';
import 'widgets/income_expense_row.dart';
import 'widgets/spending_trend_chart.dart';
import 'widgets/recent_transactions.dart';
import 'widgets/budget_card.dart';
import 'dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: HematYukAppBar(
        title: 'Dashboard',
        avatarUrl: user?.photoURL,
      ),
      body: RefreshIndicator(
        color: AppColors.primaryDark,
        onRefresh: () async {
          ref.read(dashboardProvider.notifier).refresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(height: 8),
              BalanceCard(),
              SizedBox(height: 16),
              IncomeExpenseRow(),
              SizedBox(height: 16),
              BudgetCard(),
              SizedBox(height: 16),
              SpendingTrendChart(),
              SizedBox(height: 20),
              RecentTransactions(),
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
