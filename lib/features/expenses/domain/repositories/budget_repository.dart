import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/budget.dart';

abstract class BudgetRepository {
  Future<Either<Failure, List<Budget>>> getBudgets();
  Future<Either<Failure, void>> addBudget(Budget budget);
  Future<Either<Failure, void>> deleteBudget(String id);
}
