import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bar_widget.dart';
import '../../core/widgets/transaction_list_item.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/repositories/auth_repository.dart';
import '../transaction/widgets/transaction_detail_bottom_sheet.dart';
import 'history_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyProvider);
    final user = ref.watch(currentUserProvider);
    final grouped = state.groupedTransactions;
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: HematYukAppBar(
        title: 'Riwayat',
        avatarUrl: user?.photoURL,
        onAvatarTap: () => context.go('/profile'),
      ),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(),
          // Filter chips
          _buildFilterChips(state),
          // Transaction list
          Expanded(
            child: state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryDark))
                : grouped.isEmpty
                    ? _buildEmpty()
                    : RefreshIndicator(
                        color: AppColors.primaryDark,
                        onRefresh: () async {
                          ref.read(historyProvider.notifier).refresh();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: sortedKeys.length,
                          itemBuilder: (context, idx) {
                            final key = sortedKeys[idx];
                            final transactions = grouped[key]!;
                            final date = DateTime.parse(key);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDateHeader(date),
                                ...transactions.map(
                                  (t) => TransactionListItem(
                                    transaction: t,
                                    onTap: () => showTransactionDetail(context, ref, t),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (v) =>
            ref.read(historyProvider.notifier).setSearchQuery(v),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.chipBackground,
          hintText: 'Cari transaksi...',
          hintStyle:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.textSecondary, size: 22),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded,
                      color: AppColors.textSecondary, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(historyProvider.notifier).setSearchQuery('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide:
                const BorderSide(color: AppColors.primaryDark, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterChips(HistoryState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          _FilterChip(
            label: 'Semua',
            isActive: state.filter == HistoryFilter.all,
            onTap: () => ref
                .read(historyProvider.notifier)
                .setFilter(HistoryFilter.all),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Pemasukan',
            isActive: state.filter == HistoryFilter.income,
            onTap: () => ref
                .read(historyProvider.notifier)
                .setFilter(HistoryFilter.income),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Pengeluaran',
            isActive: state.filter == HistoryFilter.expense,
            onTap: () => ref
                .read(historyProvider.notifier)
                .setFilter(HistoryFilter.expense),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(DateTime date) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        DateFormatter.formatGroupHeader(date),
        style: AppTextStyles.labelSmall.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 64, color: AppColors.navInactive),
          const SizedBox(height: 16),
          Text(
            'Tidak ada transaksi',
            style: AppTextStyles.headingSmall
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba ubah filter atau tambah transaksi baru',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryDark : Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isActive ? AppColors.primaryDark : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isActive ? Colors.white : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
