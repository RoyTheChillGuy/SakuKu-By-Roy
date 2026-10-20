import '../models/receipt_scan_prefill.dart';

/// Regex / keyword extraction from OCR plain text.
abstract final class ReceiptTextParser {
  static const _categoryRules = <({List<String> keywords, String category})>[
    (
      keywords: [
        'indomaret',
        'alfamart',
        'alfamidi',
        'hypermart',
        'superindo',
        'resto',
        'restaurant',
        'kopi',
        'coffee',
        'starbucks',
        'mcd',
        'kfc',
        'warung',
        'cafe',
        'food',
        'makan',
      ],
      category: 'Food & Drink',
    ),
    (
      keywords: [
        'grab',
        'gojek',
        'pertamina',
        'shell',
        'bp',
        'bensin',
        'spbu',
        'tol',
        'parkir',
        'transport',
        'taxi',
      ],
      category: 'Transport',
    ),
    (
      keywords: [
        'mall',
        'fashion',
        'tokopedia',
        'shopee',
        'lazada',
        'belanja',
        'shopping',
        'department',
      ],
      category: 'Shopping',
    ),
    (
      keywords: [
        'pln',
        'pdam',
        'telkom',
        'indihome',
        'internet',
        'listrik',
        'utilities',
        'bill',
        'tagihan',
      ],
      category: 'Bills & Utilities',
    ),
    (
      keywords: [
        'bioskop',
        'cinema',
        'netflix',
        'spotify',
        'game',
        'entertainment',
      ],
      category: 'Entertainment',
    ),
    (
      keywords: ['gaji', 'salary', 'payroll', 'transfer masuk'],
      category: 'Salary',
    ),
  ];

  static ReceiptScanPrefill parse(String text) {
    final normalized = text.replaceAll('\r', '\n');
    final lower = normalized.toLowerCase();

    return ReceiptScanPrefill(
      amount: _extractAmount(normalized, lower),
      date: _extractDate(normalized),
      suggestedCategoryName: _suggestCategory(lower),
      merchantHint: _extractMerchantHint(normalized),
      rawText: text,
    );
  }

  static double? _extractAmount(String text, String lower) {
    final candidates = <double>[];

    final labeled = RegExp(
      r'(?:grand\s*total|total\s*bayar|total|jumlah|amount\s*due|bayar|subtotal\s*akhir)[^\d]{0,20}(?:rp\.?\s*)?([\d][\d.,]*)',
      caseSensitive: false,
    );
    for (final m in labeled.allMatches(lower)) {
      final v = _parseMoney(m.group(1));
      if (v != null && v > 0) candidates.add(v);
    }

    final rpMatches = RegExp(
      r'rp\.?\s*([\d][\d.,]*)',
      caseSensitive: false,
    ).allMatches(text);
    for (final m in rpMatches) {
      final v = _parseMoney(m.group(1));
      if (v != null && v >= 1000) candidates.add(v);
    }

    if (candidates.isEmpty) {
      final plain = RegExp(r'(?<!\d)([\d]{1,3}(?:[.,]\d{3})+(?:[.,]\d{2})?)(?!\d)');
      for (final m in plain.allMatches(text)) {
        final v = _parseMoney(m.group(1));
        if (v != null && v >= 1000) candidates.add(v);
      }
    }

    if (candidates.isEmpty) return null;
    candidates.sort();
    return candidates.last;
  }

  static double? _parseMoney(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    var s = raw.trim();
    if (s.contains('.') && s.contains(',')) {
      s = s.replaceAll('.', '').replaceAll(',', '.');
    } else if (s.contains(',')) {
      final parts = s.split(',');
      if (parts.length == 2 && parts[1].length <= 2) {
        s = '${parts[0].replaceAll('.', '')}.${parts[1]}';
      } else {
        s = s.replaceAll(',', '');
      }
    } else {
      s = s.replaceAll('.', '');
    }
    return double.tryParse(s);
  }

  static DateTime? _extractDate(String text) {
    final now = DateTime.now();
    final dmy = RegExp(r'(\d{1,2})[/.-](\d{1,2})[/.-](\d{2,4})');
    final match = dmy.firstMatch(text);
    if (match != null) {
      final d = int.parse(match.group(1)!);
      final m = int.parse(match.group(2)!);
      var y = int.parse(match.group(3)!);
      if (y < 100) y += 2000;
      if (m >= 1 && m <= 12 && d >= 1 && d <= 31) {
        return DateTime(y, m, d, now.hour, now.minute);
      }
    }
    return null;
  }

  static String? _suggestCategory(String lower) {
    for (final rule in _categoryRules) {
      for (final kw in rule.keywords) {
        if (lower.contains(kw)) return rule.category;
      }
    }
    return null;
  }

  static String? _extractMerchantHint(String text) {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    if (lines.isEmpty) return null;
    final first = lines.first;
    if (first.length > 3 && first.length < 48 && !RegExp(r'^\d').hasMatch(first)) {
      return first;
    }
    return null;
  }
}
