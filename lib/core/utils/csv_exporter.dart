import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../features/expenses/domain/entities/category.dart';
import '../../features/expenses/domain/entities/expense.dart';
import '../utils/date_formatter.dart';

class CsvExporter {
  CsvExporter._();

  /// Exports all expenses to a CSV file and shares it
  static Future<void> export({
    required List<Expense> expenses,
    required List<Category> categories,
  }) async {
    // Build CSV rows
    final rows = <List<dynamic>>[];

    // Header row
    rows.add([
      'Date',
      'Title',
      'Amount',
      'Type',
      'Category',
      'Note',
      'Created At',
    ]);

    // Data rows
    for (final expense in expenses) {
      // Look up category name
      final category = categories.firstWhere(
        (c) => c.id == expense.categoryId,
        orElse: () => categories.first,
      );

      rows.add([
        DateFormatter.full(expense.date),
        expense.title,
        expense.amount.toStringAsFixed(2),
        expense.type.name,
        category.name,
        expense.note ?? '',
        DateFormatter.full(expense.createdAt),
      ]);
    }

    // Convert to CSV string
    final csv = const ListToCsvConverter().convert(rows);

    // Save to temporary directory
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/expense_tracker_export_$timestamp.csv');
    await file.writeAsString(csv);

    // Share the file
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Expense Tracker Transactions Export',
      text:
          'My Expense Tracker transactions exported on ${DateFormatter.format(DateTime.now())}',
    );
  }
}
