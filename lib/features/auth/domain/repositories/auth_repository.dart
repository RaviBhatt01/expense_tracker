import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/app_user.dart';

abstract class AuthRepository {
  // Get currently logged in user — null if not logged in
  AppUser? get currentUser;

  // Stream of auth state changes
  Stream<AppUser?> get authStateChanges;

  Future<Either<Failure, AppUser>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, AppUser>> registerWithEmail({
    required String email,
    required String password,
    required String name,
  });

  Future<Either<Failure, AppUser>> signInWithGoogle();

  Future<Either<Failure, void>> signOut();
}
