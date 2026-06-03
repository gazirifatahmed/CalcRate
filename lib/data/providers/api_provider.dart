import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiProvider {
  final String _apiUrl = "https://open.er-api.com/v6/latest/USD";

  Future<Map<String, dynamic>?> fetchLiveRates() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_rates', response.body);
        return data['rates'];
      }
    } catch (e) {
      // ইন্টারনেট না থাকলে লোকাল স্টোরেজ থেকে ডাটা ব্যাকআপ নিবে
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString('cached_rates');
      if (cachedData != null) {
        final data = json.decode(cachedData);
        return data['rates'];
      }
    }
    return null;
  }
}