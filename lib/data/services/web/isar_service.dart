import 'memory_store.dart';

/// Web stub — Isar native DB is unavailable in browsers.
class IsarService {
  IsarService._();

  static IsarService? _instance;

  static IsarService get instance {
    final service = _instance;
    if (service == null || !MemoryStore.instance.initialized) {
      throw StateError(
        'IsarService has not been initialized. Call IsarService.initialize() in main().',
      );
    }
    return service;
  }

  static bool get isInitialized => MemoryStore.instance.initialized;

  /// No-op open for web; backs repositories with [MemoryStore].
  static Future<IsarService> initialize({String name = 'sakuku'}) async {
    if (_instance != null && MemoryStore.instance.initialized) {
      return _instance!;
    }
    MemoryStore.instance.initialized = true;
    _instance = IsarService._();
    return _instance!;
  }

  static Future<void> close() async {
    MemoryStore.instance.reset();
    _instance = null;
  }
}
