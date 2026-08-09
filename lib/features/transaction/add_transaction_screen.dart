import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_formatter.dart';
import 'widgets/amount_input.dart';
import 'widgets/category_grid.dart';
import 'transaction_provider.dart';
import '../dashboard/dashboard_provider.dart';

import '../../data/models/transaction_model.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final TransactionModel? existingTransaction;

  const AddTransactionScreen({super.key, this.existingTransaction});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(
      text: widget.existingTransaction?.note ?? '',
    );
    if (widget.existingTransaction != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(addTransactionProvider.notifier)
            .initForEdit(widget.existingTransaction!);
      });
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final state = ref.read(addTransactionProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: state.date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      ref.read(addTransactionProvider.notifier).setDate(picked);
    }
  }

  Future<void> _save() async {
    ref.read(addTransactionProvider.notifier).setNote(_noteController.text);
    await ref.read(addTransactionProvider.notifier).save();
    final state = ref.read(addTransactionProvider);
    if (state.saved && mounted) {
      ref.read(dashboardProvider.notifier).refresh();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Transaksi berhasil disimpan!',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: AppColors.primaryDark,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.of(context).pop();
    } else if (state.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error!),
          backgroundColor: AppColors.expense,
        ),
      );
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
          // Green header with type toggle & amount
          _buildHeader(context, state, isExpense),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const CategoryGrid(),
                  const SizedBox(height: 20),
                  _buildDateField(context, state),
                  const SizedBox(height: 12),
                  _buildNoteField(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Save button
          _buildSaveButton(state),
        ],
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, AddTransactionState state, bool isExpense) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cardGreenGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // App bar row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      'Tambah',
                      style: AppTextStyles.headingMediumWhite,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // balance
                ],
              ),
            ),

            // Label
            Text(
              isExpense ? 'PENGELUARAN' : 'PEMASUKAN',
              style: AppTextStyles.labelSmallWhite.copyWith(
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),

            // Amount input display
            AmountInputWidget(),

            // Toggle segmented control
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  children: [
                    _typeTab('Pengeluaran', 'expense', state.type),
                    _typeTab('Pemasukan', 'income', state.type),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeTab(String label, String value, String currentType) {
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

  Widget _buildDateField(BuildContext context, AddTransactionState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => _selectDate(context),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border(
              left: BorderSide(color: AppColors.primaryDark, width: 4),
              top: BorderSide(color: AppColors.divider),
              right: BorderSide(color: AppColors.divider),
              bottom: BorderSide(color: AppColors.divider),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_month_rounded,
                  color: AppColors.primaryDark, size: 22),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tanggal', style: AppTextStyles.bodySmall),
                  const SizedBox(height: 2),
                  Text(
                    DateFormatter.formatInput(state.date),
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Icon(Icons.notes_rounded,
                  color: AppColors.primaryDark, size: 22),
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
                  hintStyle: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textHint),
                  contentPadding: const EdgeInsets.only(
                      top: 16, right: 16, bottom: 16),
                ),
                style: AppTextStyles.bodyMedium,
                onChanged: (v) =>
                    ref.read(addTransactionProvider.notifier).setNote(v),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(AddTransactionState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      color: Colors.white,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: (state.canSave && !state.isSaving) ? _save : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: state.canSave
                ? AppColors.primaryDark
                : AppColors.navInactive,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          icon: state.isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 22),
          label: Text(
            state.isSaving ? 'Menyimpan...' : 'Simpan Transaksi',
            style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
