import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/category_model.dart';

class AddTransactionState {
  final String? editId;
  final String type; // 'expense' | 'income'
  final double amount;
  final String? selectedCategoryId;
  final DateTime date;
  final String note;
  final bool isSaving;
  final String? error;
  final bool saved;

  AddTransactionState({
    this.editId,
    this.type = 'expense',
    this.amount = 0,
    this.selectedCategoryId,
    DateTime? date,
    this.note = '',
    this.isSaving = false,
    this.error,
    this.saved = false,
  }) : date = date ?? DateTime.now();

  bool get isEditMode => editId != null;

  AddTransactionState copyWith({
    String? editId,
    String? type,
    double? amount,
    String? selectedCategoryId,
    DateTime? date,
    String? note,
    bool? isSaving,
    String? error,
    bool? saved,
  }) {
    return AddTransactionState(
      editId: editId ?? this.editId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      date: date ?? this.date,
      note: note ?? this.note,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      saved: saved ?? this.saved,
    );
  }

  List<CategoryModel> get categories {
    final list = type == 'expense'
        ? CategoryModel.defaultExpenseCategories
        : CategoryModel.defaultIncomeCategories;
    final custom = CategoryModel.customCategories.where((c) => c.type == type || c.type == 'both');
    return [...list, ...custom];
  }

  bool get canSave => amount > 0 && selectedCategoryId != null;
}

class AddTransactionNotifier extends StateNotifier<AddTransactionState> {
  final TransactionRepository _repo;
  final String _userId;

  AddTransactionNotifier(this._repo, this._userId)
      : super(AddTransactionState(date: DateTime.now()));

  void initForEdit(TransactionModel existing) {
    state = AddTransactionState(
      editId: existing.id,
      type: existing.type,
      amount: existing.amount,
      selectedCategoryId: existing.categoryId,
      date: existing.date,
      note: existing.note,
    );
  }

  void setType(String type) {
    state = AddTransactionState(
      editId: state.editId,
      type: type,
      date: state.date,
      amount: state.amount,
    );
  }

  void setAmount(double amount) {
    state = state.copyWith(amount: amount);
  }

  void setCategory(String categoryId) {
    state = state.copyWith(selectedCategoryId: categoryId);
  }

  void setDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  void setNote(String note) {
    state = state.copyWith(note: note);
  }

  Future<void> save() async {
    if (!state.canSave) return;

    state = state.copyWith(isSaving: true, error: null);
    try {
      if (state.isEditMode) {
        final updated = TransactionModel(
          id: state.editId!,
          type: state.type,
          amount: state.amount,
          categoryId: state.selectedCategoryId!,
          note: state.note,
          date: state.date,
          createdAt: DateTime.now(),
          userId: _userId,
        );
        await _repo.updateTransaction(updated);
      } else {
        final transaction = TransactionModel(
          id: const Uuid().v4(),
          type: state.type,
          amount: state.amount,
          categoryId: state.selectedCategoryId!,
          note: state.note,
          date: state.date,
          createdAt: DateTime.now(),
          userId: _userId,
        );
        await _repo.addTransaction(transaction);
      }
      state = state.copyWith(isSaving: false, saved: true);
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Gagal menyimpan transaksi: $e',
      );
    }
  }

  void reset() {
    state = AddTransactionState(date: DateTime.now());
  }
}

final addTransactionProvider =
    StateNotifierProvider.autoDispose<AddTransactionNotifier, AddTransactionState>(
        (ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  return AddTransactionNotifier(repo, user?.uid ?? 'mock_user');
});
