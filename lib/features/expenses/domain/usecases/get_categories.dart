import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

@injectable
class GetCategoriesUseCase implements UseCase<List<Category>, NoParams> {
  final CategoryRepository _repository;

  GetCategoriesUseCase({required CategoryRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<Category>>> call(NoParams params) {
    return _repository.getCategories();
  }
}
