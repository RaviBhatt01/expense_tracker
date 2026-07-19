import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/category_repository.dart';

@injectable
class DeleteCategoryUseCase implements UseCase<void, String> {
  final CategoryRepository _repository;

  DeleteCategoryUseCase({required CategoryRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, void>> call(String params) {
    return _repository.deleteCategory(params);
  }
}
