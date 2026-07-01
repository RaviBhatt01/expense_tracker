import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense.dart';

class ExpenseModel {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final DateTime date;
  final String? note;
  final String? receiptUrl;
  final DateTime createdAt;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.note,
    this.receiptUrl,
    required this.createdAt,
  });

  // Convert FROM Firestore document -> ExpenseModel
  factory ExpenseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExpenseModel(
      id: doc.id,
      title: data['title'] as String,
      amount: (data['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere((e) => e.name == data['type']),
      categoryId: data['categoryId'] as String,
      date: (data['date'] as Timestamp).toDate(),
      note: data['note'] as String?,
      receiptUrl: data['receiptUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convert to Firestore document -> Map
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'amount': amount,
      'type': type.name,
      'categoryId': categoryId,
      'date': Timestamp.fromDate(date),
      'note': note,
      'receiptUrl': receiptUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Convert ExpenseModel -> Expense entity (for domain layer)
  Expense toEntity() {
    return Expense(
      id: id,
      title: title,
      amount: amount,
      type: type,
      categoryId: categoryId,
      date: date,
      note: note,
      receiptUrl: receiptUrl,
      createdAt: createdAt,
    );
  }

  // Convert Expense entity -> ExpenseModel (from domain layer)
  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      title: expense.title,
      amount: expense.amount,
      type: expense.type,
      categoryId: expense.categoryId,
      date: expense.date,
      note: expense.note,
      receiptUrl: expense.receiptUrl,
      createdAt: expense.createdAt,
    );
  }
}
