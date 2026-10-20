import 'package:flutter/material.dart';

import '../services/scan_receipt_flow.dart';

/// Opens camera, OCR, then add-transaction sheet with pre-filled fields.
Future<void> captureReceiptAndOpenTransactionForm(BuildContext context) {
  return runScanReceiptFlow(context);
}
