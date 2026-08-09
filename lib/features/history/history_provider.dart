import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/transaction_model.dart';

enum HistoryFilter { all, income, expense }

class HistoryState {
  final List<TransactionModel> transactions;
  final HistoryFilter filter;
  final String searchQuery;
  final bool isLoading;

  const HistoryState({
    this.transactions = const [],
    this.filter = HistoryFilter.all,
    this.searchQuery = '',
    this.isLoading = false,
  });

  HistoryState copyWith({
    List<TransactionModel>? transactions,
    HistoryFilter? filter,
    String? searchQuery,
    bool? isLoading,
  }) {
    return HistoryState(
      transactions: transactions ?? this.transactions,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  List<TransactionModel> get filteredTransactions {
    var list = transactions;

    // Filter by type
    if (filter == HistoryFilter.income) {
      list = list.where((t) => t.isIncome).toList();
    } else if (filter == HistoryFilter.expense) {
      list = list.where((t) => t.isExpense).toList();
    }

    // Filter by search
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list
          .where((t) =>
              t.note.toLowerCase().contains(q) ||
              t.categoryId.toLowerCase().contains(q))
          .toList();
    }

    return list;
  }

  /// Group transactions by date key "yyyy-MM-dd"
  Map<String, List<TransactionModel>> get groupedTransactions {
    final map = <String, List<TransactionModel>>{};
    for (final t in filteredTransactions) {
      final key =
          '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}-${t.date.day.toString().padLeft(2, '0')}';
      map.putIfAbsent(key, () => []).add(t);
    }
    return map;
  }
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  final TransactionRepository _repo;
  final String _userId;

  HistoryNotifier(this._repo, this._userId)
      : super(const HistoryState(isLoading: true)) {
    _load();
  }

  void _load() {
    final transactions = _repo.getAll(_userId);
    state = state.copyWith(transactions: transactions, isLoading: false);
  }

  void setFilter(HistoryFilter filter) {
    state = state.copyWith(filter: filter);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void refresh() => _load();
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  return HistoryNotifier(repo, user?.uid ?? 'mock_user');
});
