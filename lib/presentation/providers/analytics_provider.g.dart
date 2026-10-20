// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Income, expenses, net, and savings rate for the selected [budgetPeriodProvider].

@ProviderFor(monthlyCashFlow)
final monthlyCashFlowProvider = MonthlyCashFlowProvider._();

/// Income, expenses, net, and savings rate for the selected [budgetPeriodProvider].

final class MonthlyCashFlowProvider
    extends
        $FunctionalProvider<
          AsyncValue<MonthlyCashFlow>,
          MonthlyCashFlow,
          FutureOr<MonthlyCashFlow>
        >
    with $FutureModifier<MonthlyCashFlow>, $FutureProvider<MonthlyCashFlow> {
  /// Income, expenses, net, and savings rate for the selected [budgetPeriodProvider].
  MonthlyCashFlowProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'monthlyCashFlowProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$monthlyCashFlowHash();

  @$internal
  @override
  $FutureProviderElement<MonthlyCashFlow> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MonthlyCashFlow> create(Ref ref) {
    return monthlyCashFlow(ref);
  }
}

String _$monthlyCashFlowHash() => r'phase5_monthly_cash_flow_v1';

/// Full category expense breakdown for the selected period (charts).

@ProviderFor(expenseBreakdown)
final expenseBreakdownProvider = ExpenseBreakdownProvider._();

/// Full category expense breakdown for the selected period (charts).

final class ExpenseBreakdownProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CategorySpend>>,
          List<CategorySpend>,
          FutureOr<List<CategorySpend>>
        >
    with
        $FutureModifier<List<CategorySpend>>,
        $FutureProvider<List<CategorySpend>> {
  /// Full category expense breakdown for the selected period (charts).
  ExpenseBreakdownProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseBreakdownProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseBreakdownHash();

  @$internal
  @override
  $FutureProviderElement<List<CategorySpend>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CategorySpend>> create(Ref ref) {
    return expenseBreakdown(ref);
  }
}

String _$expenseBreakdownHash() => r'phase5_expense_breakdown_v1';

/// Top spend categories, MoM comparison, and tag breakdown for selected period.

@ProviderFor(boncosInspector)
final boncosInspectorProvider = BoncosInspectorProvider._();

/// Top spend categories, MoM comparison, and tag breakdown for selected period.

final class BoncosInspectorProvider
    extends
        $FunctionalProvider<
          AsyncValue<BoncosInsight>,
          BoncosInsight,
          FutureOr<BoncosInsight>
        >
    with $FutureModifier<BoncosInsight>, $FutureProvider<BoncosInsight> {
  /// Top spend categories, MoM comparison, and tag breakdown for selected period.
  BoncosInspectorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'boncosInspectorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$boncosInspectorHash();

  @$internal
  @override
  $FutureProviderElement<BoncosInsight> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BoncosInsight> create(Ref ref) {
    return boncosInspector(ref);
  }
}

String _$boncosInspectorHash() => r'phase5_boncos_inspector_v1';

/// Budgets at ≥90% or over limit for banner alerts.

@ProviderFor(criticalBudgetAlerts)
final criticalBudgetAlertsProvider = CriticalBudgetAlertsProvider._();

/// Budgets at ≥90% or over limit for banner alerts.

final class CriticalBudgetAlertsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BudgetStatus>>,
          List<BudgetStatus>,
          FutureOr<List<BudgetStatus>>
        >
    with
        $FutureModifier<List<BudgetStatus>>,
        $FutureProvider<List<BudgetStatus>> {
  /// Budgets at ≥90% or over limit for banner alerts.
  CriticalBudgetAlertsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'criticalBudgetAlertsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$criticalBudgetAlertsHash();

  @$internal
  @override
  $FutureProviderElement<List<BudgetStatus>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BudgetStatus>> create(Ref ref) {
    return criticalBudgetAlerts(ref);
  }
}

String _$criticalBudgetAlertsHash() => r'phase5_critical_budget_alerts_v1';
