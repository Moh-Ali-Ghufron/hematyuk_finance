import 'package:intl/intl.dart';

class DateFormatter {
  static final _monthFormat = DateFormat('MMMM yyyy', 'id_ID');
  static final _dayMonthFormat = DateFormat('d MMM', 'id_ID');
  static final _timeFormat = DateFormat('HH:mm');
  static final _fullFormat = DateFormat('d MMMM yyyy', 'id_ID');
  static final _inputFormat = DateFormat('dd/MM/yyyy');

  /// Returns "Hari ini", "Kemarin, 24 Okt", or "Senin, 20 Okt"
  static String formatGroupHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'HARI INI';
    } else if (dateOnly == yesterday) {
      return 'KEMARIN, ${_dayMonthFormat.format(date).toUpperCase()}';
    } else {
      final dayName = DateFormat('EEEE', 'id_ID').format(date).toUpperCase();
      return '$dayName, ${_dayMonthFormat.format(date).toUpperCase()}';
    }
  }

  /// "Oktober 2023"
  static String formatMonth(DateTime date) {
    return _monthFormat.format(date);
  }

  /// "24 Oktober 2023"
  static String formatFull(DateTime date) {
    return _fullFormat.format(date);
  }

  /// "12:30"
  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  /// "08/04/2026"
  static String formatInput(DateTime date) {
    return _inputFormat.format(date);
  }

  /// Short day names for chart: ["Sen", "Sel", "Rab", "Kam", "Jum", "Sab", "Min"]
  static List<String> getLast7DayLabels() {
    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final now = DateTime.now();
    final result = <String>[];
    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      result.add(days[d.weekday - 1]);
    }
    return result;
  }

  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime startOfMonth(DateTime date) =>
      DateTime(date.year, date.month, 1);

  static DateTime endOfMonth(DateTime date) =>
      DateTime(date.year, date.month + 1, 0, 23, 59, 59);
}
