import '../models/models.dart';

/// Filters for listing transactions.
class TransactionFilter {
  const TransactionFilter({
    this.start,
    this.end,
    this.accountId,
    this.categoryId,
    this.type,
  });

  final DateTime? start;
  final DateTime? end;
  final int? accountId;
  final int? categoryId;
  final TransactionType? type;
}
