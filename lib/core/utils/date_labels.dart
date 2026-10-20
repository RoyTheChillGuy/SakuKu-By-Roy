import 'package:intl/intl.dart';

/// Human-friendly date section headers (Today, Yesterday, 18 Oct 2026).
abstract final class DateLabels {
  static DateFormat _fmt(String pattern) {
    try {
      return DateFormat(pattern, 'id_ID');
    } catch (_) {
      return DateFormat(pattern);
    }
  }

  static String sectionHeader(DateTime date, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final d = DateTime(date.year, date.month, date.day);
    final t = DateTime(today.year, today.month, today.day);
    final diff = t.difference(d).inDays;

    if (diff == 0) return 'Hari Ini';
    if (diff == 1) return 'Kemarin';
    if (diff == -1) return 'Besok';

    return _fmt('d MMM yyyy').format(date);
  }

  static String shortDate(DateTime date) => _fmt('d MMM yyyy').format(date);

  static String monthYear(DateTime date) => _fmt('MMMM yyyy').format(date);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
