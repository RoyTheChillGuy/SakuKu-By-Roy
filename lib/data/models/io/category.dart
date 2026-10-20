import 'package:isar_community/isar.dart';

part 'category.g.dart';

/// Whether a category applies to income or expense flows.
enum CategoryType {
  income,
  expense,
}

@Collection(accessor: 'categories')
class Category {
  Id id = Isar.autoIncrement;

  late String name;

  /// Lucide / Material icon key name (e.g. "utensils", "salary").
  late String icon;

  /// Hex color without alpha, e.g. "#EF4444".
  late String colorHex;

  @enumerated
  late CategoryType type;

  /// Seeded system categories cannot be deleted by the user.
  bool isDefault = false;

  /// Parent category id for sub-categories; null = top-level.
  int? parentId;
}
