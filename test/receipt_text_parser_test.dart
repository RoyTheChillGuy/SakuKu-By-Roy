import 'package:flutter_test/flutter_test.dart';
import 'package:sakuku_app/core/services/receipt_text_parser.dart';

void main() {
  group('ReceiptTextParser', () {
    test('extracts total from labeled line', () {
      const text = '''
INDOMARET
Jl. Contoh
TOTAL Rp 45.500
''';
      final result = ReceiptTextParser.parse(text);
      expect(result.amount, 45500);
      expect(result.suggestedCategoryName, 'Food & Drink');
      expect(result.merchantHint, 'INDOMARET');
    });

    test('extracts date d/m/y', () {
      const text = 'Toko\n19/10/2026\nGRAND TOTAL Rp 120.000';
      final result = ReceiptTextParser.parse(text);
      expect(result.date?.year, 2026);
      expect(result.date?.month, 10);
      expect(result.date?.day, 19);
      expect(result.amount, 120000);
    });
  });
}
