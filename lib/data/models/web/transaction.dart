enum TransactionType {
  income,
  expense,
  transfer,
}

class Transaction {
  int id = 0;

  late double amount;
  late DateTime date;
  late TransactionType type;
  late int accountId;
  int? targetAccountId;
  int? categoryId;
  String? note;
  List<String> tags = [];
  String? imagePath;
  double? transferFee;
  bool isRecurring = false;
  String? recurrenceRule;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
