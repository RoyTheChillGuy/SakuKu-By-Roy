import 'package:isar_community/isar.dart';

import '../../models/models.dart';
import '../../services/isar_service.dart';

/// CRUD for income / expense [Category] records.
class CategoryRepository {
  CategoryRepository({Isar? isar}) : _isar = isar ?? IsarService.instance.db;

  final Isar _isar;

  Future<List<Category>> getAll() {
    return _isar.categories.where().sortByName().findAll();
  }

  Future<List<Category>> getByType(CategoryType type) {
    return _isar.categories
        .filter()
        .typeEqualTo(type)
        .sortByName()
        .findAll();
  }

  Future<List<Category>> getTopLevel({CategoryType? type}) async {
    final all = type == null ? await getAll() : await getByType(type);
    return all.where((c) => c.parentId == null).toList();
  }

  Future<List<Category>> getSubcategories(Id parentId) {
    return _isar.categories
        .filter()
        .parentIdEqualTo(parentId)
        .sortByName()
        .findAll();
  }

  Future<Category?> getById(Id id) => _isar.categories.get(id);

  Future<Id> create(Category category) {
    return _isar.writeTxn(() => _isar.categories.put(category));
  }

  Future<Id> update(Category category) {
    return _isar.writeTxn(() => _isar.categories.put(category));
  }

  /// Deletes a category unless it is a seeded default.
  Future<bool> delete(Id id) async {
    return _isar.writeTxn(() async {
      final category = await _isar.categories.get(id);
      if (category == null) return false;
      if (category.isDefault) {
        throw StateError('Default categories cannot be deleted.');
      }
      return _isar.categories.delete(id);
    });
  }

  Future<int> count() => _isar.categories.count();
}
