import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/app_user.dart';

@lazySingleton
class AuthDatasource {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthDatasource()
    : _auth = FirebaseAuth.instance,
      _googleSignIn = GoogleSignIn();

  // Get current user
  AppUser? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _mapUser(user, isNewUser: false);
  }

  // Stream of auth state changes
  Stream<AppUser?> get authStateChanges {
    return _auth.authStateChanges().map(
      (user) => user == null ? null : _mapUser(user, isNewUser: false),
    );
  }

  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _mapUser(credential.user!, isNewUser: false);
  }

  Future<AppUser> registerWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Update display name after registration
    await credential.user!.updateDisplayName(name);
    await credential.user!.reload();

    return _mapUser(
      _auth.currentUser!,
      isNewUser: true, // new user → show onboarding
    );
  }

  Future<AppUser> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign in cancelled');

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final result = await _auth.signInWithCredential(credential);

    // additionalUserInfo.isNewUser tells us if first time
    final isNew = result.additionalUserInfo?.isNewUser ?? false;

    return _mapUser(result.user!, isNewUser: isNew);
  }

  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
  }

  // Convert Firebase User to our AppUser entity
  AppUser _mapUser(User user, {required bool isNewUser}) {
    return AppUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      isNewUser: isNewUser,
    );
  }
}
