import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/models.dart';

/// Opens and exposes a single shared Isar instance for SakuKu (IO platforms).
class IsarService {
  IsarService._();

  static IsarService? _instance;
  static Isar? _isar;

  static IsarService get instance {
    final service = _instance;
    if (service == null || _isar == null) {
      throw StateError(
        'IsarService has not been initialized. Call IsarService.initialize() in main().',
      );
    }
    return service;
  }

  static bool get isInitialized => _isar != null;

  Isar get db {
    final isar = _isar;
    if (isar == null) {
      throw StateError('Isar database is not open.');
    }
    return isar;
  }

  static Future<IsarService> initialize({String name = 'sakuku'}) async {
    if (_instance != null && _isar != null) {
      return _instance!;
    }

    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [
        AccountSchema,
        CategorySchema,
        TransactionSchema,
        BudgetSchema,
      ],
      directory: dir.path,
      name: name,
    );

    _isar = isar;
    _instance = IsarService._();
    return _instance!;
  }

  static Future<void> close() async {
    await _isar?.close();
    _isar = null;
    _instance = null;
  }
}
