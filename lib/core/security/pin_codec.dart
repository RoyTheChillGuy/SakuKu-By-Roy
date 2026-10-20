import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Hashes app PIN codes with a per-device salt (stored alongside hash).
abstract final class PinCodec {
  static const int minLength = 4;
  static const int maxLength = 8;

  static String generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  static String hash(String pin, String salt) {
    final normalized = pin.trim();
    final bytes = utf8.encode('$salt:$normalized');
    return sha256.convert(bytes).toString();
  }

  static bool verify(String pin, String salt, String expectedHash) {
    return hash(pin, salt) == expectedHash;
  }

  static bool isValidFormat(String pin) {
    final p = pin.trim();
    if (p.length < minLength || p.length > maxLength) return false;
    return RegExp(r'^\d+$').hasMatch(p);
  }
}
