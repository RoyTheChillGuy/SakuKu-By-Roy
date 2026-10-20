import 'package:isar_community/isar.dart';

part 'budget.g.dart';

@collection
class Budget {
  Id id = Isar.autoIncrement;

  /// Null = overall monthly budget; otherwise category-scoped.
  @Index()
  int? categoryId;

  late double amountLimit;

  @Index()
  late int month;

  @Index()
  late int year;

  /// Fraction of limit that triggers a warning (default 0.75 = 75%).
  double alertThreshold = 0.75;

  DateTime createdAt = DateTime.now();
}
