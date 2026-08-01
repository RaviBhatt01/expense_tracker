import 'package:shared_preferences/shared_preferences.dart';

/// Represents a currency option
class CurrencyOption {
  final String code; // USD, EUR, NPR
  final String symbol; // $, €, Rs.
  final String name; // US Dollar, Euro

  const CurrencyOption({
    required this.code,
    required this.symbol,
    required this.name,
  });

  String get display => '$code $symbol';
}

/// Manages currency selection and persistence
class CurrencyService {
  CurrencyService._();

  static const String _key = 'selected_currency';

  // All supported currencies
  static const List<CurrencyOption> currencies = [
    CurrencyOption(code: 'NPR', symbol: 'Rs.', name: 'Nepali Rupee'),
    CurrencyOption(code: 'USD', symbol: '\$', name: 'US Dollar'),
    CurrencyOption(code: 'EUR', symbol: '€', name: 'Euro'),
    CurrencyOption(code: 'GBP', symbol: '£', name: 'British Pound'),
    CurrencyOption(code: 'JPY', symbol: '¥', name: 'Japanese Yen'),
    CurrencyOption(code: 'INR', symbol: '₹', name: 'Indian Rupee'),
    CurrencyOption(code: 'AUD', symbol: 'A\$', name: 'Australian Dollar'),
    CurrencyOption(code: 'CAD', symbol: 'C\$', name: 'Canadian Dollar'),
  ];

  /// Load saved currency — defaults to NPR
  static Future<CurrencyOption> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'NPR';
    return currencies.firstWhere(
      (c) => c.code == code,
      orElse: () => currencies.first,
    );
  }

  /// Save selected currency
  static Future<void> save(CurrencyOption currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, currency.code);
  }
}
