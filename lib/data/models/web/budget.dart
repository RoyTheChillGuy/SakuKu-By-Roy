class Budget {
  int id = 0;

  int? categoryId;
  late double amountLimit;
  late int month;
  late int year;
  double alertThreshold = 0.75;
  DateTime createdAt = DateTime.now();
}
