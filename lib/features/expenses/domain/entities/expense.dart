import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense.freezed.dart';

enum TransactionType { expense, income }

@freezed
class Expense with _$Expense {
  const factory Expense({
    required String id,
    required String title,
    required double amount,
    required TransactionType type,
    required String categoryId,
    required DateTime date,
    String? note,
    String? receiptUrl,
    required DateTime createdAt,
  }) = _Expense;
}
