import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../transaction_provider.dart';

class AmountInputWidget extends ConsumerStatefulWidget {
  const AmountInputWidget({super.key});

  @override
  ConsumerState<AmountInputWidget> createState() => _AmountInputWidgetState();
}

class _AmountInputWidgetState extends ConsumerState<AmountInputWidget> {
  String _rawInput = '';

  void _onDigit(String digit) {
    if (_rawInput.length >= 12) return;
    setState(() {
      _rawInput += digit;
    });
    final amount = double.tryParse(_rawInput) ?? 0;
    ref.read(addTransactionProvider.notifier).setAmount(amount);
  }

  void _onDelete() {
    if (_rawInput.isEmpty) return;
    setState(() {
      _rawInput = _rawInput.substring(0, _rawInput.length - 1);
    });
    final amount = double.tryParse(_rawInput) ?? 0;
    ref.read(addTransactionProvider.notifier).setAmount(amount);
  }

  void _onClear() {
    setState(() {
      _rawInput = '';
    });
    ref.read(addTransactionProvider.notifier).setAmount(0);
  }

  String get _formattedAmount {
    if (_rawInput.isEmpty) return '0';
    final amount = double.tryParse(_rawInput) ?? 0;
    return CurrencyFormatter.formatNumberOnly(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Amount display
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Rp',
                style: AppTextStyles.headingMediumWhite.copyWith(fontSize: 22),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  _formattedAmount,
                  style: AppTextStyles.amountInput,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // Numpad
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            children: [
              _buildRow(['1', '2', '3']),
              const SizedBox(height: 8),
              _buildRow(['4', '5', '6']),
              const SizedBox(height: 8),
              _buildRow(['7', '8', '9']),
              const SizedBox(height: 8),
              _buildSpecialRow(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(List<String> digits) {
    return Row(
      children: digits
          .map((d) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _DigitButton(
                    label: d,
                    onTap: () => _onDigit(d),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildSpecialRow() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _DigitButton(
              label: '000',
              onTap: () {
                _onDigit('0');
                _onDigit('0');
                _onDigit('0');
              },
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _DigitButton(
              label: '0',
              onTap: () => _onDigit('0'),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _ActionButton(
              icon: Icons.backspace_rounded,
              onTap: _onDelete,
              onLongPress: _onClear,
            ),
          ),
        ),
      ],
    );
  }
}

class _DigitButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DigitButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.headingSmall.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.expenseBg,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: AppColors.expense, size: 22),
      ),
    );
  }
}
