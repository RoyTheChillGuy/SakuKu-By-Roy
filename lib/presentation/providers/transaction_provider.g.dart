// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Active transaction list filters (date range, account, category, type).

@ProviderFor(TransactionFilterNotifier)
final transactionFilterProvider = TransactionFilterNotifierProvider._();

/// Active transaction list filters (date range, account, category, type).
final class TransactionFilterNotifierProvider
    extends $NotifierProvider<TransactionFilterNotifier, TransactionFilter> {
  /// Active transaction list filters (date range, account, category, type).
  TransactionFilterNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionFilterNotifierHash();

  @$internal
  @override
  TransactionFilterNotifier create() => TransactionFilterNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionFilter>(value),
    );
  }
}

String _$transactionFilterNotifierHash() =>
    r'5706a16386b6bde2e609ce6adc76848798a3ce7b';

/// Active transaction list filters (date range, account, category, type).

abstract class _$TransactionFilterNotifier
    extends $Notifier<TransactionFilter> {
  TransactionFilter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TransactionFilter, TransactionFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TransactionFilter, TransactionFilter>,
              TransactionFilter,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Filtered transaction list with add / update / delete.
///
/// Mutations refresh account balances and invalidate analytics / budgets.

@ProviderFor(TransactionList)
final transactionListProvider = TransactionListProvider._();

/// Filtered transaction list with add / update / delete.
///
/// Mutations refresh account balances and invalidate analytics / budgets.
final class TransactionListProvider
    extends $AsyncNotifierProvider<TransactionList, List<Transaction>> {
  /// Filtered transaction list with add / update / delete.
  ///
  /// Mutations refresh account balances and invalidate analytics / budgets.
  TransactionListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionListHash();

  @$internal
  @override
  TransactionList create() => TransactionList();
}

String _$transactionListHash() => r'2e1b2a1fcf72009d25d5b92518c4b199649f39eb';

/// Filtered transaction list with add / update / delete.
///
/// Mutations refresh account balances and invalidate analytics / budgets.

abstract class _$TransactionList extends $AsyncNotifier<List<Transaction>> {
  FutureOr<List<Transaction>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<Transaction>>, List<Transaction>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Transaction>>, List<Transaction>>,
              AsyncValue<List<Transaction>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Latest transactions regardless of the active filter (dashboard strip).

@ProviderFor(recentTransactions)
final recentTransactionsProvider = RecentTransactionsFamily._();

/// Latest transactions regardless of the active filter (dashboard strip).

final class RecentTransactionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Transaction>>,
          List<Transaction>,
          FutureOr<List<Transaction>>
        >
    with
        $FutureModifier<List<Transaction>>,
        $FutureProvider<List<Transaction>> {
  /// Latest transactions regardless of the active filter (dashboard strip).
  RecentTransactionsProvider._({
    required RecentTransactionsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'recentTransactionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recentTransactionsHash();

  @override
  String toString() {
    return r'recentTransactionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Transaction>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Transaction>> create(Ref ref) {
    final argument = this.argument as int;
    return recentTransactions(ref, limit: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RecentTransactionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recentTransactionsHash() =>
    r'50cef055ed3973c282ae76ec24d560acc7f0d201';

/// Latest transactions regardless of the active filter (dashboard strip).

final class RecentTransactionsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Transaction>>, int> {
  RecentTransactionsFamily._()
    : super(
        retry: null,
        name: r'recentTransactionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Latest transactions regardless of the active filter (dashboard strip).

  RecentTransactionsProvider call({int limit = 20}) =>
      RecentTransactionsProvider._(argument: limit, from: this);

  @override
  String toString() => r'recentTransactionsProvider';
}

@ProviderFor(transaction)
final transactionProvider = TransactionFamily._();

final class TransactionProvider
    extends
        $FunctionalProvider<
          AsyncValue<Transaction?>,
          Transaction?,
          FutureOr<Transaction?>
        >
    with $FutureModifier<Transaction?>, $FutureProvider<Transaction?> {
  TransactionProvider._({
    required TransactionFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'transactionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$transactionHash();

  @override
  String toString() {
    return r'transactionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Transaction?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Transaction?> create(Ref ref) {
    final argument = this.argument as int;
    return transaction(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transactionHash() => r'815565c8f77ffa8882a0f2ec22b4a90b6ef1d662';

final class TransactionFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Transaction?>, int> {
  TransactionFamily._()
    : super(
        retry: null,
        name: r'transactionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TransactionProvider call(int id) =>
      TransactionProvider._(argument: id, from: this);

  @override
  String toString() => r'transactionProvider';
}
