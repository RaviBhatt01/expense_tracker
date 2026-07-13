import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

// RegisterModule tells injectable about external classes
// that we cannot annotate directly (like Firebase classes)
@module
abstract class RegisterModule {
  // Registers FirebaseFirestore as a lazy singleton
  // injectable will use this when any class needs FirebaseFirestore
  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
}
