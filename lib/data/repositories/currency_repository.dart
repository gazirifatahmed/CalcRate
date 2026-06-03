import '../models/currency_model.dart';
import '../providers/api_provider.dart';

class CurrencyRepository {
  final ApiProvider _apiProvider = ApiProvider();

  Future<List<Currency>> getCurrencies() async {
    final rates = await _apiProvider.fetchLiveRates();
    if (rates == null) return [];

    List<String> targetCurrencies = ['BDT', 'USD', 'INR', 'EUR', 'SAR'];
    return targetCurrencies.map((code) {
      return Currency.fromJson(rates, code);
    }).toList();
  }
}