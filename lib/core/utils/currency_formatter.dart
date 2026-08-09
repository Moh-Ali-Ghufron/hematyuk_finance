import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final _formatterNoSymbol = NumberFormat.currency(
    locale: 'id_ID',
    symbol: '',
    decimalDigits: 0,
  );

  /// Format to "Rp 12.450.000"
  static String format(double amount) {
    return _formatter.format(amount.abs());
  }

  /// Format with sign: "+ Rp 8.200.000" or "- Rp 3.150.000"
  static String formatWithSign(double amount, {bool isIncome = true}) {
    final prefix = isIncome ? '+' : '-';
    return '$prefix ${_formatter.format(amount.abs())}';
  }

  /// Compact format: "Rp 4.5M" or "Rp 450Rb"
  static String formatCompact(double amount) {
    if (amount >= 1000000000) {
      return 'Rp ${(amount / 1000000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}Jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}Rb';
    }
    return format(amount);
  }

  /// Format number only (no symbol): "12.450.000"
  static String formatNumberOnly(double amount) {
    return _formatterNoSymbol.format(amount.abs()).trim();
  }

  /// Parse input string to double
  static double parse(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(cleaned) ?? 0;
  }
}
