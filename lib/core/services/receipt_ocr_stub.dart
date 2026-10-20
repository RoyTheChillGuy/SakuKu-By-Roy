import 'package:image_picker/image_picker.dart';

import '../models/receipt_scan_prefill.dart';

/// Web/desktop stub — ML Kit OCR is mobile-only.
class ReceiptOcrService {
  Future<ReceiptScanPrefill> parseReceipt(XFile image) async {
    return const ReceiptScanPrefill();
  }

  Future<void> dispose() async {}
}
