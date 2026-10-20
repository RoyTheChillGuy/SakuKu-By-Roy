// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Full category list with create / update / delete.

@ProviderFor(CategoryList)
final categoryListProvider = CategoryListProvider._();

/// Full category list with create / update / delete.
final class CategoryListProvider
    extends $AsyncNotifierProvider<CategoryList, List<Category>> {
  /// Full category list with create / update / delete.
  CategoryListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryListHash();

  @$internal
  @override
  CategoryList create() => CategoryList();
}

String _$categoryListHash() => r'04dd1385a5488638eda8f4d7f4d8f0d5cd743948';

/// Full category list with create / update / delete.

abstract class _$CategoryList extends $AsyncNotifier<List<Category>> {
  FutureOr<List<Category>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Category>>, List<Category>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Category>>, List<Category>>,
              AsyncValue<List<Category>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Categories filtered by income / expense type.

@ProviderFor(categoriesByType)
final categoriesByTypeProvider = CategoriesByTypeFamily._();

/// Categories filtered by income / expense type.

final class CategoriesByTypeProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Category>>,
          List<Category>,
          FutureOr<List<Category>>
        >
    with $FutureModifier<List<Category>>, $FutureProvider<List<Category>> {
  /// Categories filtered by income / expense type.
  CategoriesByTypeProvider._({
    required CategoriesByTypeFamily super.from,
    required CategoryType super.argument,
  }) : super(
         retry: null,
         name: r'categoriesByTypeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoriesByTypeHash();

  @override
  String toString() {
    return r'categoriesByTypeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Category>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Category>> create(Ref ref) {
    final argument = this.argument as CategoryType;
    return categoriesByType(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoriesByTypeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoriesByTypeHash() => r'2922f8f96c04d9dd545e98031f2240f2e696bf30';

/// Categories filtered by income / expense type.

final class CategoriesByTypeFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Category>>, CategoryType> {
  CategoriesByTypeFamily._()
    : super(
        retry: null,
        name: r'categoriesByTypeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Categories filtered by income / expense type.

  CategoriesByTypeProvider call(CategoryType type) =>
      CategoriesByTypeProvider._(argument: type, from: this);

  @override
  String toString() => r'categoriesByTypeProvider';
}

@ProviderFor(category)
final categoryProvider = CategoryFamily._();

final class CategoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<Category?>,
          Category?,
          FutureOr<Category?>
        >
    with $FutureModifier<Category?>, $FutureProvider<Category?> {
  CategoryProvider._({
    required CategoryFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'categoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoryHash();

  @override
  String toString() {
    return r'categoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Category?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Category?> create(Ref ref) {
    final argument = this.argument as int;
    return category(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoryHash() => r'c22402ed69a61811a786f9959aaedefee0344ed7';

final class CategoryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Category?>, int> {
  CategoryFamily._()
    : super(
        retry: null,
        name: r'categoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CategoryProvider call(int id) => CategoryProvider._(argument: id, from: this);

  @override
  String toString() => r'categoryProvider';
}
