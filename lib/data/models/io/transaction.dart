import 'package:isar_community/isar.dart';

part 'transaction.g.dart';

/// Transaction flow type.
enum TransactionType {
  income,
  expense,
  transfer,
}

@collection
class Transaction {
  Id id = Isar.autoIncrement;

  late double amount;

  @Index()
  late DateTime date;

  @enumerated
  @Index()
  late TransactionType type;

  /// Source account (expense debit / income credit / transfer from).
  @Index()
  late int accountId;

  /// Destination account for transfers; null for income/expense.
  int? targetAccountId;

  /// Required for income/expense; optional for pure transfers.
  int? categoryId;

  String? note;

  List<String> tags = [];

  /// Optional local file path for receipt / attachment.
  String? imagePath;

  /// Optional fee charged on internal transfers.
  double? transferFee;

  bool isRecurring = false;

  /// Simple recurrence hint (e.g. "monthly", "weekly"); refined in later phases.
  String? recurrenceRule;

  DateTime createdAt = DateTime.now();

  DateTime updatedAt = DateTime.now();
}
