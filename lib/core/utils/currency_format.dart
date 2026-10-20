import 'package:intl/intl.dart';

/// Indonesian Rupiah helpers for display and amount inputs.
abstract final class CurrencyFormat {
  static final NumberFormat _idr = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final NumberFormat _compact = NumberFormat.compactCurrency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// e.g. `Rp 50.000`
  static String idr(num amount) => _idr.format(amount);

  /// Compact for tight cards when |amount| is large.
  static String idrCompact(num amount) {
    if (amount.abs() >= 100000000) return _compact.format(amount);
    return idr(amount);
  }

  /// Signed amount for income (+) / expense (−).
  static String signed(num amount, {required bool isExpense}) {
    final formatted = idr(amount.abs());
    if (isExpense) return '−$formatted';
    return '+$formatted';
  }

  /// Digits-only parse from a currency text field.
  static double parseInput(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return 0;
    return double.parse(digits);
  }

  /// Formats raw digit string while typing: `50000` → `50.000`
  static String formatInputDigits(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    final value = int.parse(digits);
    return NumberFormat('#,###', 'id_ID').format(value);
  }
}
