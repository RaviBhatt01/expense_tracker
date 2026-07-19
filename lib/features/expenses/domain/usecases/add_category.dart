import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

@injectable
class AddCategoryUseCase implements UseCase<void, Category> {
  final CategoryRepository _repository;

  AddCategoryUseCase({required CategoryRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, void>> call(Category params) {
    return _repository.addCategory(params);
  }
}
