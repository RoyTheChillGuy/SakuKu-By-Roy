import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists lock settings and PIN hash in secure storage.
class AppLockStorage {
  AppLockStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  static const _keyLockEnabled = 'sakuku_lock_enabled';
  static const _keyBioEnabled = 'sakuku_bio_enabled';
  static const _keyPinHash = 'sakuku_pin_hash';
  static const _keyPinSalt = 'sakuku_pin_salt';

  final FlutterSecureStorage _storage;

  Future<bool> isLockEnabled() async {
    return (await _storage.read(key: _keyLockEnabled)) == 'true';
  }

  Future<bool> isBiometricEnabled() async {
    return (await _storage.read(key: _keyBioEnabled)) == 'true';
  }

  Future<bool> hasPin() async {
    final hash = await _storage.read(key: _keyPinHash);
    final salt = await _storage.read(key: _keyPinSalt);
    return hash != null && hash.isNotEmpty && salt != null && salt.isNotEmpty;
  }

  Future<({String hash, String salt})?> readPinCredentials() async {
    final hash = await _storage.read(key: _keyPinHash);
    final salt = await _storage.read(key: _keyPinSalt);
    if (hash == null || salt == null) return null;
    return (hash: hash, salt: salt);
  }

  Future<void> setLockEnabled(bool value) async {
    await _storage.write(key: _keyLockEnabled, value: value ? 'true' : 'false');
  }

  Future<void> setBiometricEnabled(bool value) async {
    await _storage.write(key: _keyBioEnabled, value: value ? 'true' : 'false');
  }

  Future<void> savePin({required String hash, required String salt}) async {
    await _storage.write(key: _keyPinHash, value: hash);
    await _storage.write(key: _keyPinSalt, value: salt);
  }

  Future<void> clearPin() async {
    await _storage.delete(key: _keyPinHash);
    await _storage.delete(key: _keyPinSalt);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
