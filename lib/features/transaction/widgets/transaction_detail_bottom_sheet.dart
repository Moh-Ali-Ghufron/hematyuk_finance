import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/category_icon_widget.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../dashboard/dashboard_provider.dart';
import '../../history/history_provider.dart';
import '../transaction_provider.dart';

void showTransactionDetail(
  BuildContext context,
  WidgetRef ref,
  TransactionModel transaction,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _TransactionDetailSheet(transaction: transaction),
  );
}

class _TransactionDetailSheet extends ConsumerWidget {
  final TransactionModel transaction;

  const _TransactionDetailSheet({required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = CategoryModel.findById(transaction.categoryId);
    final isIncome = transaction.isIncome;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header - colored
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isIncome ? AppColors.incomeBg : AppColors.expenseBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                CategoryIconWidget(categoryId: transaction.categoryId, size: 56),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.note.isNotEmpty ? transaction.note : category.name,
                        style: AppTextStyles.headingSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(category.name, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isIncome ? '+' : '-'} ${CurrencyFormatter.format(transaction.amount)}',
                      style: AppTextStyles.headingSmall.copyWith(
                        color: isIncome ? AppColors.income : AppColors.expense,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: isIncome ? AppColors.income : AppColors.expense,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        isIncome ? 'Pemasukan' : 'Pengeluaran',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Detail rows
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Tanggal',
                  value: DateFormatter.formatInput(transaction.date),
                ),
                const Divider(height: 24, color: AppColors.divider),
                _DetailRow(
                  icon: Icons.access_time_rounded,
                  label: 'Waktu',
                  value: DateFormatter.formatTime(transaction.date),
                ),
                const Divider(height: 24, color: AppColors.divider),
                _DetailRow(
                  icon: Icons.notes_rounded,
                  label: 'Keterangan',
                  value: transaction.note.isNotEmpty ? transaction.note : '-',
                ),
              ],
            ),
          ),
          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmDelete(context, ref),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.expense,
                      side: const BorderSide(color: AppColors.expense),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: Text('Hapus', style: AppTextStyles.labelMedium),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (_) => ProviderScope(
                            child: _EditTransactionPage(transaction: transaction),
                          ),
                        ),
                      ).then((_) {
                        ref.read(dashboardProvider.notifier).refresh();
                        ref.read(historyProvider.notifier).refresh();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                    label: Text(
                      'Edit',
                      style: AppTextStyles.labelMedium.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Transaksi', style: AppTextStyles.headingSmall),
        content: Text(
          'Apakah kamu yakin ingin menghapus transaksi ini?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal',
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Hapus',
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.expense)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(transactionRepositoryProvider).deleteTransaction(transaction.id);
      ref.read(dashboardProvider.notifier).refresh();
      ref.read(historyProvider.notifier).refresh();
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text('Transaksi dihapus',
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
              ],
            ),
            backgroundColor: AppColors.expense,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.incomeBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primaryDark, size: 18),
        ),
        const SizedBox(width: 12),
        Text(label, style: AppTextStyles.bodySmall),
        const Spacer(),
        Text(value,
            style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// Edit Transaction page reusing AddTransactionScreen
class _EditTransactionPage extends ConsumerStatefulWidget {
  final TransactionModel transaction;
  const _EditTransactionPage({required this.transaction});

  @override
  ConsumerState<_EditTransactionPage> createState() => _EditTransactionPageState();
}

class _EditTransactionPageState extends ConsumerState<_EditTransactionPage> {
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.transaction.note);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(addTransactionProvider.notifier).initForEdit(widget.transaction);
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    ref.read(addTransactionProvider.notifier).setNote(_noteController.text);
    await ref.read(addTransactionProvider.notifier).save();
    final state = ref.read(addTransactionProvider);
    if (state.saved && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text('Transaksi berhasil diperbarui!',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
            ],
          ),
          backgroundColor: AppColors.primaryDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _selectDate() async {
    final state = ref.read(addTransactionProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: state.date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primaryDark),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      ref.read(addTransactionProvider.notifier).setDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addTransactionProvider);
    final isExpense = state.type == 'expense';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.cardGreenGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            'Edit Transaksi',
                            style: AppTextStyles.headingMediumWhite,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  Text(
                    isExpense ? 'PENGELUARAN' : 'PEMASUKAN',
                    style: AppTextStyles.labelSmallWhite.copyWith(
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Rp ', style: AppTextStyles.headingMediumWhite.copyWith(fontSize: 22)),
                          Text(
                            CurrencyFormatter.formatNumberOnly(state.amount),
                            style: AppTextStyles.headingMediumWhite.copyWith(fontSize: 32, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        children: [
                          _typeTab(context, ref, 'Pengeluaran', 'expense', state.type),
                          _typeTab(context, ref, 'Pemasukan', 'income', state.type),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Category grid
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Category grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kategori', style: AppTextStyles.headingSmall),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 8,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: state.categories.length,
                          itemBuilder: (context, idx) {
                            final cat = state.categories[idx];
                            final isSelected = state.selectedCategoryId == cat.id;
                            return GestureDetector(
                              onTap: () => ref.read(addTransactionProvider.notifier).setCategory(cat.id),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: isSelected ? cat.color : cat.bgColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(cat.icon,
                                        color: isSelected ? Colors.white : cat.color, size: 24),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    cat.name,
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Date field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: const Border(
                            left: BorderSide(color: AppColors.primaryDark, width: 4),
                            top: BorderSide(color: AppColors.divider),
                            right: BorderSide(color: AppColors.divider),
                            bottom: BorderSide(color: AppColors.divider),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded, color: AppColors.primaryDark, size: 22),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Tanggal', style: AppTextStyles.bodySmall),
                                const SizedBox(height: 2),
                                Text(DateFormatter.formatInput(state.date),
                                    style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const Spacer(),
                            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 22),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Note field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        border: Border(
                          left: BorderSide(color: AppColors.primaryDark, width: 4),
                          top: BorderSide(color: AppColors.divider),
                          right: BorderSide(color: AppColors.divider),
                          bottom: BorderSide(color: AppColors.divider),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Icon(Icons.notes_rounded, color: AppColors.primaryDark, size: 22),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _noteController,
                              maxLines: 3,
                              minLines: 1,
                              decoration: InputDecoration(
                                filled: false,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                hintText: 'Tulis keterangan (opsional)...',
                                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
                                contentPadding: const EdgeInsets.only(top: 16, right: 16, bottom: 16),
                              ),
                              style: AppTextStyles.bodyMedium,
                              onChanged: (v) => ref.read(addTransactionProvider.notifier).setNote(v),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          // Save button
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: (state.canSave && !state.isSaving) ? _save : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: state.canSave ? AppColors.primaryDark : AppColors.navInactive,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                ),
                icon: state.isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                label: Text(
                  state.isSaving ? 'Menyimpan...' : 'Simpan Perubahan',
                  style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeTab(BuildContext context, WidgetRef ref, String label, String value, String currentType) {
    final isActive = currentType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(addTransactionProvider.notifier).setType(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: isActive ? AppColors.primaryDark : Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
