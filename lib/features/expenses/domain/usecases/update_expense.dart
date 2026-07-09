import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class UpdateExpenseUseCase implements UseCase<void, Expense> {
  final ExpenseRepository _repository;

  UpdateExpenseUseCase({required ExpenseRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, void>> call(Expense params) {
    return _repository.updateExpense(params);
  }
}
