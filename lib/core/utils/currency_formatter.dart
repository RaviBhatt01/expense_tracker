import 'app_constants.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  /// Formats a number as currency
  /// 1000    → "NPR 1,000"
  /// 1000.50 → "NPR 1,000.50"
  /// 0       → "NPR 0"
  static String format(double amount, {bool showDecimals = false}) {
    // Split into whole and decimal parts
    final isNegative = amount < 0;
    final absolute = amount.abs();

    // Format with thousands separator
    final whole = absolute.truncate();
    final formatted = _addThousandsSeparator(whole);

    // Only show decimals if there are meaningful cents
    // or if explicitly requested
    final hasDecimals = (absolute - whole) > 0;

    if (showDecimals || hasDecimals) {
      final decimal = (absolute - whole).toStringAsFixed(2).substring(1);
      return '${AppConstants.currency} ${isNegative ? '-' : ''}$formatted$decimal';
    }

    return '${AppConstants.currency} ${isNegative ? '-' : ''}$formatted';
  }

  /// Formats with explicit sign for balance display
  /// Positive → "NPR +1,000"
  /// Negative → "NPR -1,000"
  static String formatWithSign(double amount) {
    final sign = amount >= 0 ? '+' : '-';
    final absolute = amount.abs();
    final whole = absolute.truncate();
    final formatted = _addThousandsSeparator(whole);
    return '${AppConstants.currency} $sign$formatted';
  }

  /// Compact format for small spaces
  /// 1000     → "NPR 1K"
  /// 1000000  → "NPR 1M"
  static String compact(double amount) {
    if (amount >= 1000000) {
      return '${AppConstants.currency} ${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      return '${AppConstants.currency} ${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount);
  }

  static String _addThousandsSeparator(int number) {
    // Convert to string and add comma every 3 digits from right
    final str = number.toString();
    final result = StringBuffer();
    int count = 0;

    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        result.write(',');
      }
      result.write(str[i]);
      count++;
    }

    // Reverse the string
    return result.toString().split('').reversed.join();
  }
}
