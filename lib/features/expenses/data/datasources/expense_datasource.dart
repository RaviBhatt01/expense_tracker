import '../models/expense_model.dart';

abstract class ExpenseDatasource {
  Future<void> addExpense(ExpenseModel expense);

  Future<List<ExpenseModel>> getExpenses({
    String? type,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<void> updateExpense(ExpenseModel expense);
  Future<void> deleteExpense(String id);
}
