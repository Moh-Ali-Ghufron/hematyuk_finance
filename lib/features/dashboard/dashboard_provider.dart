import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/transaction_model.dart';

// Dashboard state
class DashboardState {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpense;
  final List<TransactionModel> recentTransactions;
  final List<double> last7DayExpenses;
  final bool isBalanceHidden;
  final bool isLoading;

  const DashboardState({
    this.totalBalance = 0,
    this.monthlyIncome = 0,
    this.monthlyExpense = 0,
    this.recentTransactions = const [],
    this.last7DayExpenses = const [],
    this.isBalanceHidden = false,
    this.isLoading = false,
  });

  DashboardState copyWith({
    double? totalBalance,
    double? monthlyIncome,
    double? monthlyExpense,
    List<TransactionModel>? recentTransactions,
    List<double>? last7DayExpenses,
    bool? isBalanceHidden,
    bool? isLoading,
  }) {
    return DashboardState(
      totalBalance: totalBalance ?? this.totalBalance,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyExpense: monthlyExpense ?? this.monthlyExpense,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      last7DayExpenses: last7DayExpenses ?? this.last7DayExpenses,
      isBalanceHidden: isBalanceHidden ?? this.isBalanceHidden,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final TransactionRepository _repo;
  final String _userId;

  DashboardNotifier(this._repo, this._userId)
      : super(const DashboardState(isLoading: true)) {
    _load();
  }

  void _load() {
    final now = DateTime.now();
    state = state.copyWith(
      totalBalance: _repo.getTotalBalance(_userId),
      monthlyIncome: _repo.getMonthlyIncome(_userId, now),
      monthlyExpense: _repo.getMonthlyExpense(_userId, now),
      recentTransactions: _repo.getRecent(_userId, limit: 5),
      last7DayExpenses: _repo.getLast7DayExpenseTotals(_userId),
      isLoading: false,
    );
  }

  void refresh() => _load();

  void toggleBalanceVisibility() {
    state = state.copyWith(isBalanceHidden: !state.isBalanceHidden);
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  return DashboardNotifier(repo, user?.uid ?? 'mock_user');
});
