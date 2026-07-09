import 'package:dartz/dartz.dart';
import '../error/failures.dart';

abstract class UseCase<Type, Params> {
  //                   ^^^^  ^^^^^^
  //                    |     what it needs as input
  //                   what it gives back as output
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {}
