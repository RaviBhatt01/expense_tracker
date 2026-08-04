import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/auth_helper.dart';
import '../models/category_model.dart';
import 'category_datasource.dart';

@LazySingleton(as: CategoryDatasource)
class FirebaseCategoryDatasource implements CategoryDatasource {
  final FirebaseFirestore _firestore;

  FirebaseCategoryDatasource(this._firestore);

  CollectionReference get _collection => _firestore
      .collection('users')
      .doc(AuthHelper.userId)
      .collection('categories');

  @override
  Future<List<CategoryModel>> getCategories() async {
    final snapshot = await _collection.get();
    return snapshot.docs
        .map((doc) => CategoryModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> addCategory(CategoryModel category) async {
    await _collection.doc(category.id).set(category.toFirestore());
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _collection.doc(id).delete();
  }

  @override
  Future<bool> categoriesExist() async {
    // Check if any categories exist — used to decide seeding
    final snapshot = await _collection.limit(1) // only fetch one document — efficient
        .get();
    return snapshot.docs.isNotEmpty;
  }

  @override
  Future<void> seedDefaultCategories(List<CategoryModel> categories) async {
    // Use batch write — all categories saved in one network call
    // Much faster than saving one by one
    final batch = _firestore.batch();

    for (final category in categories) {
      final ref = _collection.doc(category.id);
      batch.set(ref, category.toFirestore());
    }

    // Commit all writes at once
    await batch.commit();
  }
}
