import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

@injectable
class AddBudgetUseCase implements UseCase<void, Budget> {
  final BudgetRepository _repository;

  AddBudgetUseCase({required BudgetRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, void>> call(Budget params) {
    return _repository.addBudget(params);
  }
}
