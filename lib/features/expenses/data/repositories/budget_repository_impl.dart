import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_datasource.dart';
import '../models/budget_model.dart';

@LazySingleton(as: BudgetRepository)
class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetDatasource _datasource;

  BudgetRepositoryImpl({required BudgetDatasource datasource})
    : _datasource = datasource;

  @override
  Future<Either<Failure, List<Budget>>> getBudgets() async {
    try {
      final models = await _datasource.getBudgets();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addBudget(Budget budget) async {
    try {
      await _datasource.addBudget(BudgetModel.fromEntity(budget));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBudget(String id) async {
    try {
      await _datasource.deleteBudget(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
