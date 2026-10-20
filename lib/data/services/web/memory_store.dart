import '../../models/models.dart';

/// In-memory database used on web (Isar is not JS-safe / not supported).
class MemoryStore {
  MemoryStore._();

  static final MemoryStore instance = MemoryStore._();

  final List<Account> accounts = [];
  final List<Category> categories = [];
  final List<Transaction> transactions = [];
  final List<Budget> budgets = [];

  int _accountSeq = 0;
  int _categorySeq = 0;
  int _transactionSeq = 0;
  int _budgetSeq = 0;

  bool initialized = false;

  int nextAccountId() => ++_accountSeq;
  int nextCategoryId() => ++_categorySeq;
  int nextTransactionId() => ++_transactionSeq;
  int nextBudgetId() => ++_budgetSeq;

  void reset() {
    clearAllData();
    initialized = false;
  }

  /// Clears collections and ID counters but keeps [initialized] true.
  void clearAllData() {
    accounts.clear();
    categories.clear();
    transactions.clear();
    budgets.clear();
    _accountSeq = 0;
    _categorySeq = 0;
    _transactionSeq = 0;
    _budgetSeq = 0;
  }
}
