import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import '../models/receipt_scan_prefill.dart';
import 'receipt_text_parser.dart';

/// Runs on-device ML Kit OCR + heuristic parsing (Android/iOS).
class ReceiptOcrService {
  ReceiptOcrService({TextRecognizer? recognizer})
      : _recognizer = recognizer ??
            TextRecognizer(script: TextRecognitionScript.latin);

  final TextRecognizer _recognizer;

  Future<ReceiptScanPrefill> parseReceipt(XFile image) async {
    final input = InputImage.fromFilePath(image.path);
    try {
      final result = await _recognizer.processImage(input);
      final text = result.text.trim();
      if (text.isEmpty) {
        return ReceiptScanPrefill(rawText: '');
      }
      return ReceiptTextParser.parse(text);
    } finally {
      // Recognizer reused across scans; disposed with service dispose().
    }
  }

  Future<void> dispose() async {
    await _recognizer.close();
  }
}
