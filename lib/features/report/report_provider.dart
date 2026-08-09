import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/category_model.dart';

class CategoryReport {
  final CategoryModel category;
  final double amount;
  final double percentage;

  const CategoryReport({
    required this.category,
    required this.amount,
    required this.percentage,
  });
}

class ReportState {
  final DateTime selectedMonth;
  final double totalExpense;
  final double totalIncome;
  final List<CategoryReport> categoryReports;
  final bool isLoading;

  const ReportState({
    required this.selectedMonth,
    this.totalExpense = 0,
    this.totalIncome = 0,
    this.categoryReports = const [],
    this.isLoading = false,
  });

  ReportState copyWith({
    DateTime? selectedMonth,
    double? totalExpense,
    double? totalIncome,
    List<CategoryReport>? categoryReports,
    bool? isLoading,
  }) {
    return ReportState(
      selectedMonth: selectedMonth ?? this.selectedMonth,
      totalExpense: totalExpense ?? this.totalExpense,
      totalIncome: totalIncome ?? this.totalIncome,
      categoryReports: categoryReports ?? this.categoryReports,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  String get topCategoryInsight {
    if (categoryReports.isEmpty) return '';
    final top = categoryReports.first;
    return top.category.name;
  }
}

class ReportNotifier extends StateNotifier<ReportState> {
  final TransactionRepository _repo;
  final String _userId;

  ReportNotifier(this._repo, this._userId)
      : super(ReportState(selectedMonth: DateTime.now())) {
    _load();
  }

  void _load() {
    final month = state.selectedMonth;
    final totalExpense = _repo.getMonthlyExpense(_userId, month);
    final totalIncome = _repo.getMonthlyIncome(_userId, month);
    final catMap = _repo.getExpenseByCategory(_userId, month);

    final reports = catMap.entries
        .map((e) {
          final cat = CategoryModel.findById(e.key);
          final pct = totalExpense > 0 ? (e.value / totalExpense * 100) : 0.0;
          return CategoryReport(
            category: cat,
            amount: e.value,
            percentage: pct,
          );
        })
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    state = state.copyWith(
      totalExpense: totalExpense,
      totalIncome: totalIncome,
      categoryReports: reports,
      isLoading: false,
    );
  }

  void previousMonth() {
    final current = state.selectedMonth;
    state = state.copyWith(
      selectedMonth: DateTime(current.year, current.month - 1),
      isLoading: true,
    );
    _load();
  }

  void nextMonth() {
    final current = state.selectedMonth;
    final next = DateTime(current.year, current.month + 1);
    if (next.isAfter(DateTime.now())) return;
    state = state.copyWith(selectedMonth: next, isLoading: true);
    _load();
  }
}

final reportProvider =
    StateNotifierProvider<ReportNotifier, ReportState>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  return ReportNotifier(repo, user?.uid ?? 'mock_user');
});
