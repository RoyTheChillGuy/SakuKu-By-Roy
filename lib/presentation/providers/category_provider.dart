import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/models.dart';
import 'repository_providers.dart';

part 'category_provider.g.dart';

/// Full category list with create / update / delete.
@riverpod
class CategoryList extends _$CategoryList {
  @override
  Future<List<Category>> build() {
    return ref.watch(categoryRepositoryProvider).getAll();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(categoryRepositoryProvider).getAll(),
    );
  }

  Future<void> add(Category category) async {
    final repo = ref.read(categoryRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.create(category);
      return repo.getAll();
    });
  }

  Future<void> updateCategory(Category category) async {
    final repo = ref.read(categoryRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.update(category);
      return repo.getAll();
    });
  }

  Future<void> remove(int id) async {
    final repo = ref.read(categoryRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.delete(id);
      return repo.getAll();
    });
  }
}

/// Categories filtered by income / expense type.
@riverpod
Future<List<Category>> categoriesByType(Ref ref, CategoryType type) {
  return ref.watch(categoryRepositoryProvider).getByType(type);
}

@riverpod
Future<Category?> category(Ref ref, int id) {
  return ref.watch(categoryRepositoryProvider).getById(id);
}
