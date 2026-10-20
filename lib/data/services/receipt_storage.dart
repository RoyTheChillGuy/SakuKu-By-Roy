import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Persists receipt images under app documents (mobile/desktop).
abstract final class ReceiptStorage {
  static Future<String?> persistReceipt(XFile file) async {
    if (kIsWeb) {
      // Web: store path as blob URL-like identifier (bytes path not durable).
      return file.path.isNotEmpty ? file.path : null;
    }

    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/receipts');
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    final safeName = file.name.replaceAll(RegExp(r'[^\w.\-]'), '_');
    final dest = File(
      '${folder.path}/${DateTime.now().millisecondsSinceEpoch}_$safeName',
    );
    await dest.writeAsBytes(await file.readAsBytes());
    return dest.path;
  }
}
