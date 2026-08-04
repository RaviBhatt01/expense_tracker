import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/auth_helper.dart';
import '../models/budget_model.dart';
import 'budget_datasource.dart';

@LazySingleton(as: BudgetDatasource)
class FirebaseBudgetDatasource implements BudgetDatasource {
  final FirebaseFirestore _firestore;

  FirebaseBudgetDatasource(this._firestore);

  CollectionReference get _collection => _firestore
      .collection('users')
      .doc(AuthHelper.userId)
      .collection('budgets');

  @override
  Future<List<BudgetModel>> getBudgets() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) => BudgetModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> addBudget(BudgetModel budget) async {
    await _collection.doc(budget.id).set(budget.toFirestore());
  }

  @override
  Future<void> deleteBudget(String id) async {
    await _collection.doc(id).delete();
  }
}
