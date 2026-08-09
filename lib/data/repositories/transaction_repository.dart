import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

class TransactionRepository {
  static const String _storageKey = 'user_transactions_list';
  final List<TransactionModel> _transactions = [];

  TransactionRepository() {
    _initStorage();
  }

  Future<void> _initStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(jsonStr);
        _transactions.clear();
        _transactions.addAll(
          list.map((item) => TransactionModel.fromMap(Map<String, dynamic>.from(item))),
        );
      } else {
        // Initialize with default mock data
        _transactions.addAll(TransactionModel.mockData);
        _saveToStorage();
      }
    } catch (_) {
      if (_transactions.isEmpty) {
        _transactions.addAll(TransactionModel.mockData);
      }
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _transactions.map((t) => t.toMap()).toList();
      await prefs.setString(_storageKey, jsonEncode(list));
    } catch (_) {}
  }

  List<TransactionModel> getAll(String userId) {
    return List.from(_transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<TransactionModel> getLast7Days(String userId) {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    return _transactions
        .where((t) =>
            t.date.isAfter(sevenDaysAgo) &&
            t.type == 'expense')
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<TransactionModel> getByMonth(String userId, DateTime month) {
    return _transactions
        .where((t) =>
            t.date.year == month.year &&
            t.date.month == month.month)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<TransactionModel> getRecent(String userId, {int limit = 5}) {
    final all = getAll(userId);
    return all.take(limit).toList();
  }

  double getTotalBalance(String userId) {
    double income = 0;
    double expense = 0;
    for (final t in _transactions) {
      if (t.isIncome) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }
    return income - expense;
  }

  double getMonthlyIncome(String userId, DateTime month) {
    return _transactions
        .where((t) =>
            t.isIncome &&
            t.date.year == month.year &&
            t.date.month == month.month)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getMonthlyExpense(String userId, DateTime month) {
    return _transactions
        .where((t) =>
            t.isExpense &&
            t.date.year == month.year &&
            t.date.month == month.month)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Map<String, double> getExpenseByCategory(String userId, DateTime month) {
    final map = <String, double>{};
    for (final t in _transactions.where((t) =>
        t.isExpense &&
        t.date.year == month.year &&
        t.date.month == month.month)) {
      map[t.categoryId] = (map[t.categoryId] ?? 0) + t.amount;
    }
    return map;
  }

  /// Returns daily totals for last 7 days [0..6] => Mon..Sun direction
  List<double> getLast7DayExpenseTotals(String userId) {
    final now = DateTime.now();
    final result = List<double>.filled(7, 0);
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final idx = 6 - i;
      result[idx] = _transactions
          .where((t) =>
              t.isExpense &&
              t.date.year == day.year &&
              t.date.month == day.month &&
              t.date.day == day.day)
          .fold(0.0, (sum, t) => sum + t.amount);
    }
    return result;
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    _transactions.add(transaction);
    await _saveToStorage();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final idx = _transactions.indexWhere((t) => t.id == transaction.id);
    if (idx != -1) {
      _transactions[idx] = transaction;
      await _saveToStorage();
    }
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await _saveToStorage();
  }

  List<TransactionModel> search(String userId, String query) {
    final q = query.toLowerCase();
    return _transactions
        .where((t) =>
            t.note.toLowerCase().contains(q) ||
            CategoryModel.findById(t.categoryId)
                .name
                .toLowerCase()
                .contains(q))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}

