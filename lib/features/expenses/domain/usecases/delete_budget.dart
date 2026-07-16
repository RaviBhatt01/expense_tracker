import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/budget_repository.dart';

@injectable
class DeleteBudgetUseCase implements UseCase<void, String> {
  final BudgetRepository _repository;

  DeleteBudgetUseCase({required BudgetRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, void>> call(String params) {
    return _repository.deleteBudget(params);
  }
}
