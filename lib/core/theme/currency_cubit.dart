import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/currency_service.dart';

class CurrencyCubit extends Cubit<CurrencyOption> {
  CurrencyCubit()
    : super(
        // Default to NPR while loading
        const CurrencyOption(code: 'NPR', symbol: 'Rs.', name: 'Nepali Rupee'),
      );

  /// Load saved currency on app start
  Future<void> loadCurrency() async {
    final currency = await CurrencyService.load();
    emit(currency);
  }

  /// Change and persist currency selection
  Future<void> setCurrency(CurrencyOption currency) async {
    await CurrencyService.save(currency);
    emit(currency);
  }
}
