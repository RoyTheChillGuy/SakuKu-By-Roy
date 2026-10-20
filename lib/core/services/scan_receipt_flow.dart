import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../presentation/screens/add_transaction_bottom_sheet.dart';
import '../models/receipt_scan_prefill.dart';
import 'receipt_ocr_service.dart';

/// Camera → OCR → pre-filled transaction sheet.
Future<void> runScanReceiptFlow(BuildContext context) async {
  if (!context.mounted) return;

  final picker = ImagePicker();
  XFile? file;
  try {
    file = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      maxWidth: 2048,
      imageQuality: 90,
    );
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kamera gagal: $e')),
      );
    }
    return;
  }

  if (file == null || !context.mounted) return;

  final navigator = Navigator.of(context, rootNavigator: true);
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => const PopScope(
      canPop: false,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memindai struk…'),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  ReceiptScanPrefill prefill = const ReceiptScanPrefill();
  final ocr = ReceiptOcrService();
  try {
    prefill = await ocr.parseReceipt(file);
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OCR gagal: $e')),
      );
    }
  } finally {
    await ocr.dispose();
    if (navigator.mounted) {
      navigator.pop();
    }
  }

  if (!context.mounted) return;

  await showAddTransactionSheet(
    context,
    initialReceipt: file,
    scanPrefill: prefill.hasData ? prefill : null,
  );
}
