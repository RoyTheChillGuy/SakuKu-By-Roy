import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/security/biometric_auth.dart';
import '../../core/security/pin_codec.dart';
import '../../data/services/app_lock_storage.dart';

class AppLockState {
  const AppLockState({
    required this.lockEnabled,
    required this.biometricEnabled,
    required this.biometricAvailable,
    required this.hasPin,
    required this.isUnlocked,
  });

  const AppLockState.initial()
      : lockEnabled = false,
        biometricEnabled = false,
        biometricAvailable = false,
        hasPin = false,
        isUnlocked = true;

  final bool lockEnabled;
  final bool biometricEnabled;
  final bool biometricAvailable;
  final bool hasPin;
  final bool isUnlocked;

  AppLockState copyWith({
    bool? lockEnabled,
    bool? biometricEnabled,
    bool? biometricAvailable,
    bool? hasPin,
    bool? isUnlocked,
  }) {
    return AppLockState(
      lockEnabled: lockEnabled ?? this.lockEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      biometricAvailable: biometricAvailable ?? this.biometricAvailable,
      hasPin: hasPin ?? this.hasPin,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}

final appLockStorageProvider = Provider<AppLockStorage>(
  (ref) => AppLockStorage(),
);

final biometricAuthProvider = Provider<BiometricAuth>(
  (ref) => BiometricAuth(),
);

final appLockProvider =
    AsyncNotifierProvider<AppLockController, AppLockState>(AppLockController.new);

class AppLockController extends AsyncNotifier<AppLockState> {
  AppLockStorage get _storage => ref.read(appLockStorageProvider);
  BiometricAuth get _bio => ref.read(biometricAuthProvider);

  @override
  Future<AppLockState> build() async => _load();

  Future<AppLockState> _load() async {
    final lockEnabled = await _storage.isLockEnabled();
    final bioEnabled = await _storage.isBiometricEnabled();
    final hasPin = await _storage.hasPin();
    final bioAvailable = await _bio.isSupported;

    final effectiveLock = lockEnabled && hasPin;
    return AppLockState(
      lockEnabled: effectiveLock,
      biometricEnabled: bioEnabled && bioAvailable,
      biometricAvailable: bioAvailable,
      hasPin: hasPin,
      isUnlocked: !effectiveLock,
    );
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = AsyncData(await _load());
  }

  Future<String?> setPin(String pin, String confirmPin) async {
    if (!PinCodec.isValidFormat(pin)) {
      return 'PIN harus ${PinCodec.minLength}-${PinCodec.maxLength} digit angka.';
    }
    if (pin != confirmPin) {
      return 'Konfirmasi PIN tidak cocok.';
    }
    final salt = PinCodec.generateSalt();
    final hash = PinCodec.hash(pin, salt);
    await _storage.savePin(hash: hash, salt: salt);
    await _storage.setLockEnabled(true);
    await reload();
    final current = state.asData?.value;
    if (current != null) {
      state = AsyncData(current.copyWith(isUnlocked: true));
    }
    return null;
  }

  Future<String?> changePin(String oldPin, String newPin, String confirm) async {
    final valid = await verifyPin(oldPin);
    if (!valid) return 'PIN lama salah.';
    return setPin(newPin, confirm);
  }

  Future<bool> verifyPin(String pin) async {
    final creds = await _storage.readPinCredentials();
    if (creds == null) return false;
    return PinCodec.verify(pin, creds.salt, creds.hash);
  }

  Future<String?> unlockWithPin(String pin) async {
    if (!await verifyPin(pin)) {
      return 'PIN salah.';
    }
    final current = state.asData?.value;
    if (current != null) {
      state = AsyncData(current.copyWith(isUnlocked: true));
    }
    return null;
  }

  Future<bool> unlockWithBiometric() async {
    final current = state.asData?.value;
    if (current == null ||
        !current.lockEnabled ||
        !current.biometricEnabled) {
      return false;
    }
    final ok = await _bio.authenticate(reason: 'Buka kunci SakuKu');
    if (ok && current.lockEnabled) {
      state = AsyncData(current.copyWith(isUnlocked: true));
    }
    return ok;
  }

  Future<String?> setBiometricEnabled(bool enabled) async {
    final current = state.asData?.value;
    if (current == null) return 'Status kunci belum siap.';
    if (enabled && !current.biometricAvailable) {
      return 'Biometrik tidak tersedia di perangkat ini.';
    }
    if (enabled && (!current.hasPin || !current.lockEnabled)) {
      return 'Aktifkan kunci PIN terlebih dahulu.';
    }
    if (enabled) {
      final ok = await _bio.authenticate(
        reason: 'Verifikasi sidik jari untuk mengaktifkan kunci SakuKu',
      );
      if (!ok) return 'Verifikasi biometrik gagal atau dibatalkan.';
    }
    await _storage.setBiometricEnabled(enabled);
    state = AsyncData(
      current.copyWith(
        biometricEnabled: enabled && current.biometricAvailable,
      ),
    );
    return null;
  }

  Future<void> enableLock() async {
    if (!await _storage.hasPin()) return;
    await _storage.setLockEnabled(true);
    final loaded = await _load();
    state = AsyncData(loaded.copyWith(isUnlocked: true));
  }

  Future<void> disableLock() async {
    await _storage.setLockEnabled(false);
    await _storage.setBiometricEnabled(false);
    await _storage.clearPin();
    state = AsyncData(
      const AppLockState.initial(),
    );
  }

  void lockFromBackground() {
    final current = state.asData?.value;
    if (current == null || !current.lockEnabled) return;
    state = AsyncData(current.copyWith(isUnlocked: false));
  }
}
