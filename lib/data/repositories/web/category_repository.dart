import '../../models/models.dart';
import '../../services/web/memory_store.dart';

class CategoryRepository {
  CategoryRepository({Object? isar});

  MemoryStore get _store => MemoryStore.instance;

  Future<List<Category>> getAll() async {
    final list = List<Category>.from(_store.categories);
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  Future<List<Category>> getByType(CategoryType type) async {
    final list = _store.categories.where((c) => c.type == type).toList();
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  Future<List<Category>> getTopLevel({CategoryType? type}) async {
    final all = type == null ? await getAll() : await getByType(type);
    return all.where((c) => c.parentId == null).toList();
  }

  Future<List<Category>> getSubcategories(int parentId) async {
    final list =
        _store.categories.where((c) => c.parentId == parentId).toList();
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  Future<Category?> getById(int id) async {
    for (final c in _store.categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  Future<int> create(Category category) async {
    category.id = _store.nextCategoryId();
    _store.categories.add(category);
    return category.id;
  }

  Future<int> update(Category category) async {
    final index = _store.categories.indexWhere((c) => c.id == category.id);
    if (index >= 0) {
      _store.categories[index] = category;
    }
    return category.id;
  }

  Future<bool> delete(int id) async {
    final category = await getById(id);
    if (category == null) return false;
    if (category.isDefault) {
      throw StateError('Default categories cannot be deleted.');
    }
    _store.categories.removeWhere((c) => c.id == id);
    return true;
  }

  Future<int> count() async => _store.categories.length;
}
