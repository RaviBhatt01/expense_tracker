import 'package:firebase_auth/firebase_auth.dart';

class AuthHelper {
  AuthHelper._();

  /// Gets current user ID
  /// Throws if not logged in — should never happen in protected screens
  static String get userId {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');
    return uid;
  }
}
