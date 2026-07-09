import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/expense_repository.dart';

@injectable
class DeleteExpenseUseCase implements UseCase<void, String> {
  final ExpenseRepository _repository;

  DeleteExpenseUseCase({required ExpenseRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, void>> call(String params) {
    return _repository.deleteExpense(params);
  }
}
