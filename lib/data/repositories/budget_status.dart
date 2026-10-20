import '../models/models.dart';

/// Result of evaluating a budget against current spending.
class BudgetStatus {
  const BudgetStatus({
    required this.budget,
    required this.spent,
    required this.ratio,
    required this.isOverThreshold,
    required this.isOverBudget,
  });

  final Budget budget;
  final double spent;
  final double ratio;
  final bool isOverThreshold;
  final bool isOverBudget;

  double get remaining => budget.amountLimit - spent;
}
