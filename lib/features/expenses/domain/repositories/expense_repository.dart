import '../entities/expense.dart';

abstract class ExpenseRepository {
  Future<void> addExpense(Expense expense);
  Future<List<Expense>> getExpense({
    TransactionType? type,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(String id);
}
