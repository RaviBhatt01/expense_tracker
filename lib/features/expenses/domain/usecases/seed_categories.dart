import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/category_repository.dart';

@injectable
class SeedCategoriesUseCase implements UseCase<void, NoParams> {
  final CategoryRepository _repository;

  SeedCategoriesUseCase({required CategoryRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return _repository.seedDefaultCategories();
  }
}
