import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/budget.dart';

class BudgetModel {
  final String id;
  final String categoryId;
  final double amount;
  final BudgetPeriod period;
  final DateTime createdAt;

  const BudgetModel({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.period,
    required this.createdAt,
  });

  factory BudgetModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BudgetModel(
      id: doc.id,
      categoryId: data['categoryId'] as String,
      amount: (data['amount'] as num).toDouble(),
      period: BudgetPeriod.values.firstWhere((p) => p.name == data['period']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'categoryId': categoryId,
      'amount': amount,
      'period': period.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Budget toEntity() {
    return Budget(
      id: id,
      categoryId: categoryId,
      amount: amount,
      period: period,
      createdAt: createdAt,
    );
  }

  factory BudgetModel.fromEntity(Budget budget) {
    return BudgetModel(
      id: budget.id,
      categoryId: budget.categoryId,
      amount: budget.amount,
      period: budget.period,
      createdAt: budget.createdAt,
    );
  }
}
