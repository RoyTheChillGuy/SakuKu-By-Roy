// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// All non-archived accounts with CRUD helpers.

@ProviderFor(AccountList)
final accountListProvider = AccountListProvider._();

/// All non-archived accounts with CRUD helpers.
final class AccountListProvider
    extends $AsyncNotifierProvider<AccountList, List<Account>> {
  /// All non-archived accounts with CRUD helpers.
  AccountListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountListHash();

  @$internal
  @override
  AccountList create() => AccountList();
}

String _$accountListHash() => r'6ae5ca2b262bc32695f4f22e4eb41d90661031cf';

/// All non-archived accounts with CRUD helpers.

abstract class _$AccountList extends $AsyncNotifier<List<Account>> {
  FutureOr<List<Account>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Account>>, List<Account>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Account>>, List<Account>>,
              AsyncValue<List<Account>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Alias-friendly single-account lookup.

@ProviderFor(account)
final accountProvider = AccountFamily._();

/// Alias-friendly single-account lookup.

final class AccountProvider
    extends
        $FunctionalProvider<AsyncValue<Account?>, Account?, FutureOr<Account?>>
    with $FutureModifier<Account?>, $FutureProvider<Account?> {
  /// Alias-friendly single-account lookup.
  AccountProvider._({
    required AccountFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'accountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accountHash();

  @override
  String toString() {
    return r'accountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Account?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Account?> create(Ref ref) {
    final argument = this.argument as int;
    return account(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountHash() => r'81b23a2fb90a0ff534e467f7d3d91963ef23f5fe';

/// Alias-friendly single-account lookup.

final class AccountFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Account?>, int> {
  AccountFamily._()
    : super(
        retry: null,
        name: r'accountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Alias-friendly single-account lookup.

  AccountProvider call(int id) => AccountProvider._(argument: id, from: this);

  @override
  String toString() => r'accountProvider';
}

/// Sum of current balances across active accounts (net worth).

@ProviderFor(totalNetWorth)
final totalNetWorthProvider = TotalNetWorthProvider._();

/// Sum of current balances across active accounts (net worth).

final class TotalNetWorthProvider
    extends $FunctionalProvider<AsyncValue<double>, double, FutureOr<double>>
    with $FutureModifier<double>, $FutureProvider<double> {
  /// Sum of current balances across active accounts (net worth).
  TotalNetWorthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'totalNetWorthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$totalNetWorthHash();

  @$internal
  @override
  $FutureProviderElement<double> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<double> create(Ref ref) {
    return totalNetWorth(ref);
  }
}

String _$totalNetWorthHash() => r'52ba21f0b151361748c55e61f34710a42f1c838b';
