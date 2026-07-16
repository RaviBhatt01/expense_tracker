import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../models/budget_model.dart';
import 'budget_datasource.dart';

@LazySingleton(as: BudgetDatasource)
class FirebaseBudgetDatasource implements BudgetDatasource {
  final FirebaseFirestore _firestore;
  static const String _collection = 'budgets';

  FirebaseBudgetDatasource(this._firestore);

  @override
  Future<List<BudgetModel>> getBudgets() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs.map((doc) => BudgetModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> addBudget(BudgetModel budget) async {
    await _firestore
        .collection(_collection)
        .doc(budget.id)
        .set(budget.toFirestore());
  }

  @override
  Future<void> deleteBudget(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
