import '../models/budget_model.dart';

abstract class BudgetDatasource {
  Future<List<BudgetModel>> getBudgets();
  Future<void> addBudget(BudgetModel budget);
  Future<void> deleteBudget(String id);
}
