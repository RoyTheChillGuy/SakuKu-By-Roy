import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Platform biometric gate (unavailable on web).
class BiometricAuth {
  BiometricAuth({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  Future<bool> get isSupported async {
    if (kIsWeb) return false;
    try {
      if (!await _auth.isDeviceSupported()) return false;
      final types = await _auth.getAvailableBiometrics();
      if (types.isNotEmpty) return true;
      return await _auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  Future<List<BiometricType>> get availableTypes async {
    if (kIsWeb) return const [];
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return const [];
    }
  }

  /// Returns true when user passed device biometric / credential gate.
  Future<bool> authenticate({required String reason}) async {
    if (kIsWeb) return false;

    const strict = AuthenticationOptions(
      stickyAuth: true,
      biometricOnly: true,
      useErrorDialogs: true,
      sensitiveTransaction: false,
    );

    const relaxed = AuthenticationOptions(
      stickyAuth: true,
      biometricOnly: false,
      useErrorDialogs: true,
      sensitiveTransaction: false,
    );

    try {
      if (await _auth.authenticate(localizedReason: reason, options: strict)) {
        return true;
      }
    } on PlatformException catch (e) {
      debugPrint('Biometric strict auth: ${e.code} ${e.message}');
      if (_isPermanentFailure(e.code)) return false;
    } catch (e) {
      debugPrint('Biometric strict auth error: $e');
    }

    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: relaxed,
      );
    } on PlatformException catch (e) {
      debugPrint('Biometric relaxed auth: ${e.code} ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Biometric relaxed auth error: $e');
      return false;
    }
  }

  bool _isPermanentFailure(String code) {
    return code == 'NotEnrolled' ||
        code == 'PasscodeNotSet' ||
        code == 'LockedOut' ||
        code == 'PermanentlyLockedOut';
  }
}
