abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('No Internet Connection!');
}

class CacheFailure extends Failure {
  const CacheFailure() : super('Local data error!');
}
