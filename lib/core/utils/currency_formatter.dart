import 'app_constants.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static String _symbol = AppConstants.currency;

  static void updateSymbol(String symbol) {
    _symbol = symbol;
  }

  static String get currentSymbol => _symbol;

  static String format(double amount, {bool showDecimals = false}) {
    final isNegative = amount < 0;
    final absolute = amount.abs();
    final whole = absolute.truncate();
    final formatted = _addThousandsSeparator(whole);
    final hasDecimals = (absolute - whole) > 0;

    if (showDecimals || hasDecimals) {
      final decimal = (absolute - whole).toStringAsFixed(2).substring(1);
      return '$_symbol ${isNegative ? '-' : ''}$formatted$decimal';
    }
    return '$_symbol ${isNegative ? '-' : ''}$formatted';
  }

  static String formatWithSign(double amount) {
    final sign = amount >= 0 ? '+' : '-';
    final absolute = amount.abs();
    final whole = absolute.truncate();
    final formatted = _addThousandsSeparator(whole);
    return '$_symbol $sign$formatted';
  }

  static String compact(double amount) {
    if (amount >= 1000000) {
      return '$_symbol ${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      return '$_symbol ${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount);
  }

  static String _addThousandsSeparator(int number) {
    final str = number.toString();
    final result = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) result.write(',');
      result.write(str[i]);
      count++;
    }
    return result.toString().split('').reversed.join();
  }
}
