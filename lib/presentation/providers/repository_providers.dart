import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/account_repository.dart';
import '../../data/repositories/budget_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/transaction_repository.dart';
import 'isar_provider.dart';

part 'repository_providers.g.dart';

@Riverpod(keepAlive: true)
AccountRepository accountRepository(Ref ref) {
  ref.watch(databaseProvider);
  return AccountRepository();
}

@Riverpod(keepAlive: true)
CategoryRepository categoryRepository(Ref ref) {
  ref.watch(databaseProvider);
  return CategoryRepository();
}

@Riverpod(keepAlive: true)
TransactionRepository transactionRepository(Ref ref) {
  ref.watch(databaseProvider);
  return TransactionRepository(
    accountRepository: ref.watch(accountRepositoryProvider),
  );
}

@Riverpod(keepAlive: true)
BudgetRepository budgetRepository(Ref ref) {
  ref.watch(databaseProvider);
  return BudgetRepository(
    transactionRepository: ref.watch(transactionRepositoryProvider),
  );
}
