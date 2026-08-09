import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository();
});

class BudgetRepository {
  static const String _keyBudget = 'monthly_budget_target';

  // Default target budget: 5,000,000 IDR
  double _monthlyBudget = 5000000.0;

  double get monthlyBudget => _monthlyBudget;

  BudgetRepository() {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey(_keyBudget)) {
        _monthlyBudget = prefs.getDouble(_keyBudget) ?? 5000000.0;
      }
    } catch (_) {}
  }

  Future<void> setMonthlyBudget(double amount) async {
    _monthlyBudget = amount;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_keyBudget, amount);
    } catch (_) {}
  }
}
