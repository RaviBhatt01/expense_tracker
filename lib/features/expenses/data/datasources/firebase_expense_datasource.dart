import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'expense_datasource.dart';
import '../models/expense_model.dart';

@LazySingleton(as: ExpenseDatasource)
class FirebaseExpenseDatasource implements ExpenseDatasource {
  final FirebaseFirestore _firestore;

  FirebaseExpenseDatasource(this._firestore);
  // Collection name in Firestore
  static const String _collection = 'expenses';

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    await _firestore
        .collection(_collection)
        .doc(expense.id)
        .set(expense.toFirestore());
  }

  @override
  Future<List<ExpenseModel>> getExpenses({
    String? type,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query query = _firestore.collection(_collection);

    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }

    if (categoryId != null) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }

    if (startDate != null) {
      query = query.where(
        'date',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      );
    }

    if (endDate != null) {
      query = query.where(
        'date',
        isLessThanOrEqualTo: Timestamp.fromDate(endDate),
      );
    }

    query = query.orderBy('date', descending: true);

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => ExpenseModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    await _firestore
        .collection(_collection)
        .doc(expense.id)
        .update(expense.toFirestore());
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
