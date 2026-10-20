// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Selected calendar month for budget views (defaults to now).

@ProviderFor(BudgetPeriod)
final budgetPeriodProvider = BudgetPeriodProvider._();

/// Selected calendar month for budget views (defaults to now).
final class BudgetPeriodProvider
    extends $NotifierProvider<BudgetPeriod, ({int month, int year})> {
  /// Selected calendar month for budget views (defaults to now).
  BudgetPeriodProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetPeriodProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetPeriodHash();

  @$internal
  @override
  BudgetPeriod create() => BudgetPeriod();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(({int month, int year}) value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<({int month, int year})>(value),
    );
  }
}

String _$budgetPeriodHash() => r'c85490c0d66c4378838ef06b47ad11737fc17864';

/// Selected calendar month for budget views (defaults to now).

abstract class _$BudgetPeriod extends $Notifier<({int month, int year})> {
  ({int month, int year}) build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<({int month, int year}), ({int month, int year})>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<({int month, int year}), ({int month, int year})>,
              ({int month, int year}),
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Monthly budgets with live spending progress ([BudgetStatus]).

@ProviderFor(BudgetStatuses)
final budgetStatusesProvider = BudgetStatusesProvider._();

/// Monthly budgets with live spending progress ([BudgetStatus]).
final class BudgetStatusesProvider
    extends $AsyncNotifierProvider<BudgetStatuses, List<BudgetStatus>> {
  /// Monthly budgets with live spending progress ([BudgetStatus]).
  BudgetStatusesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetStatusesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetStatusesHash();

  @$internal
  @override
  BudgetStatuses create() => BudgetStatuses();
}

String _$budgetStatusesHash() => r'7e4c519d0205c590d7d83f23adf7c74021db833f';

/// Monthly budgets with live spending progress ([BudgetStatus]).

abstract class _$BudgetStatuses extends $AsyncNotifier<List<BudgetStatus>> {
  FutureOr<List<BudgetStatus>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<BudgetStatus>>, List<BudgetStatus>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<BudgetStatus>>, List<BudgetStatus>>,
              AsyncValue<List<BudgetStatus>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Budgets that crossed their alert threshold this period.

@ProviderFor(budgetAlerts)
final budgetAlertsProvider = BudgetAlertsProvider._();

/// Budgets that crossed their alert threshold this period.

final class BudgetAlertsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BudgetStatus>>,
          List<BudgetStatus>,
          FutureOr<List<BudgetStatus>>
        >
    with
        $FutureModifier<List<BudgetStatus>>,
        $FutureProvider<List<BudgetStatus>> {
  /// Budgets that crossed their alert threshold this period.
  BudgetAlertsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetAlertsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetAlertsHash();

  @$internal
  @override
  $FutureProviderElement<List<BudgetStatus>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BudgetStatus>> create(Ref ref) {
    return budgetAlerts(ref);
  }
}

String _$budgetAlertsHash() => r'6800c6835418b2c7b84c0b37f491d06700885bfd';
