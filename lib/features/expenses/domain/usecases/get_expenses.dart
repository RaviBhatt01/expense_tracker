import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class GetExpensesParams {
  final TransactionType? type;
  final String? categoryId;
  final DateTime? startDate;
  final DateTime? endDate;

  const GetExpensesParams({
    this.type,
    this.categoryId,
    this.startDate,
    this.endDate,
  });
}

@injectable
class GetExpensesUseCase implements UseCase<List<Expense>, GetExpensesParams> {
  final ExpenseRepository _repository;

  GetExpensesUseCase({required ExpenseRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<Expense>>> call(GetExpensesParams params) {
    return _repository.getExpenses(
      type: params.type,
      categoryId: params.categoryId,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}
