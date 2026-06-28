abstract class UseCase<Type, Params> {
  //                   ^^^^  ^^^^^^
  //                    |     what it needs as input
  //                   what it gives back as output
  Future<Type> call(Params params);
}

class NoParams {}
