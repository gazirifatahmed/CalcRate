import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import '../data/models/currency_model.dart';
import '../data/repositories/currency_repository.dart';

class CalculatorViewModel extends ChangeNotifier {
  final CurrencyRepository _repository = CurrencyRepository();
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<Currency> currencies = [];
  bool isLoading = true;
  bool isDarkMode = true; 
  bool isSoundEnabled = true; // সাউন্ড ট্র্যাকিং স্টেট
  
  String inputExpression = "1000"; 
  String selectedCurrencyCode = "USD"; 
  double baseValueInUSD = 1000.0;
  String lastUpdateTime = "";

  CalculatorViewModel() {
    _loadLocalSettings();
    loadData();
  }

  Future<void> _loadLocalSettings() async {
    final prefs = await SharedPreferences.getInstance();
    lastUpdateTime = prefs.getString('last_update_time') ?? "19/05/26 12:12 am";
    isDarkMode = prefs.getBool('is_dark_mode') ?? true;
    isSoundEnabled = prefs.getBool('is_sound_enabled') ?? true; // সাউন্ড সেটিংস লোড
    notifyListeners();
  }

  // বাটন প্রেসের কাস্টম অডিও সাউন্ড মেথড
  void playClickSound() async {
    if (!isSoundEnabled) return; // সাউন্ড অফ থাকলে প্লে হবে না

    try {
      await _audioPlayer.stop(); // আগের সাউন্ড ইনস্ট্যান্ট স্টপ করে নতুনটা প্লে করবে
      await _audioPlayer.play(AssetSource('audio/click_sound.mp3'));
    } catch (e) {
      debugPrint("Audio Play Error: $e");
    }
  }

  void toggleTheme(bool value) async {
    isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', isDarkMode);
    notifyListeners();
  }

  // সাউন্ড অন/অফ টগল করার মেথড
  void toggleSound(bool value) async {
    isSoundEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_sound_enabled', isSoundEnabled);
    notifyListeners();
  }

  // হোম পেজের রিলোড বাটনের জন্য নতুন মেথড
  Future<void> refreshData() async {
    playClickSound(); // রিলোড বাটনে চাপ দিলে সাউন্ড প্লে হবে
    inputExpression = "0"; // ডাটা জিরো থেকে শুরু করার জন্য
    baseValueInUSD = 0.0;
    await loadData(); // নতুন ডলার রেট অনুযায়ী ফ্রেশ ডাটা লোড করবে
  }

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();
    
    final rawCurrencies = await _repository.getCurrencies();
    List<Currency> sortedList = [];
    
    var usdItem = rawCurrencies.where((c) => c.code == 'USD');
    if (usdItem.isNotEmpty) sortedList.add(usdItem.first);

    var bdtItem = rawCurrencies.where((c) => c.code == 'BDT');
    if (bdtItem.isNotEmpty) sortedList.add(bdtItem.first);

    for (var item in rawCurrencies) {
      if (item.code != 'USD' && item.code != 'BDT') {
        sortedList.add(item);
      }
    }
    
    currencies = sortedList;

    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    final year = now.year % 100;
    
    int hour = now.hour;
    final ampm = hour >= 12 ? 'pm' : 'am';
    hour = hour % 12;
    hour = hour == 0 ? 12 : hour;
    final minute = now.minute.toString().padLeft(2, '0');

    lastUpdateTime = "$day/$month/$year $hour:$minute $ampm";
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_update_time', lastUpdateTime);

    isLoading = false;
    _calculateValues();
  }

  // গাণিতিক চিহ্ন পরিবর্তন বা রিপ্লেস করার মেথড
  bool _isOperator(String ch) {
    return ch == '+' || ch == '−' || ch == '×' || ch == '÷' || ch == '%';
  }

  void appendInput(String val) {
    playClickSound(); // বাটন ক্লিকে সাউন্ড প্লে হবে

    if (inputExpression == "0" && val != ".") {
      if (!_isOperator(val)) {
        inputExpression = val;
      } else {
        inputExpression = "0$val";
      }
    } else {
      // পরপর দুইবার অপারেটর বসালে আগেরটা রিপ্লেস হবে
      if (inputExpression.isNotEmpty && 
          _isOperator(inputExpression.substring(inputExpression.length - 1)) && 
          _isOperator(val)) {
        inputExpression = inputExpression.substring(0, inputExpression.length - 1) + val;
      } else {
        inputExpression += val;
      }
    }
    _calculateValues();
  }

  void clearInput() {
    playClickSound();
    inputExpression = "0";
    _calculateValues();
  }

  void deleteLast() {
    playClickSound();
    if (inputExpression.isNotEmpty) {
      inputExpression = inputExpression.substring(0, inputExpression.length - 1);
      if (inputExpression.isEmpty) inputExpression = "0";
    }
    _calculateValues();
  }

  void selectCurrency(String code) {
    selectedCurrencyCode = code;
    _calculateValues();
  }

  // গাণিতিক হিসাব-নিকাশের মূল মেথড (যোগ, বিয়োগ, গুণ, ভাগ সলভ করার জন্য)
  void _calculateValues() {
    if (currencies.isEmpty) return;
    try {
      String exp = inputExpression
          .replaceAll('×', '*')
          .replaceAll('−', '-')
          .replaceAll('÷', '/');

      double calculatedResult = _parseAndEvaluate(exp);

      double currentRateToUSD = currencies.firstWhere((c) => c.code == selectedCurrencyCode).rate;
      baseValueInUSD = calculatedResult / currentRateToUSD;
    } catch (e) {
      baseValueInUSD = 0.0;
    }
    notifyListeners();
  }

  // ইকুয়াল অপারেটর ইভালুয়েটর (কোনো এক্সটার্নাল ডিপেন্ডেন্সি ছাড়া সেফ মেথড)
  double _parseAndEvaluate(String expression) {
    try {
      // সাধারণ সমীকরণগুলো টুকরো করে প্রসেস করার মিনি লজিক
      final RegExp regex = RegExp(r'([+\-*/%])');
      List<String> tokens = expression.split(regex);
      List<String> operators = regex.allMatches(expression).map((m) => m.group(0)!).toList();

      if (tokens.isEmpty || tokens[0].isEmpty) return 0.0;

      double total = double.tryParse(tokens[0]) ?? 0.0;

      for (int i = 0; i < operators.length; i++) {
        if (i + 1 >= tokens.length) break;
        double nextVal = double.tryParse(tokens[i + 1]) ?? 0.0;
        String op = operators[i];

        if (op == '+') total += nextVal;
        if (op == '-') total -= nextVal;
        if (op == '*') total *= nextVal;
        if (op == '/') total = nextVal != 0 ? total / nextVal : 0.0;
        if (op == '%') total = total * (nextVal / 100);
      }
      return total;
    } catch (e) {
      return double.tryParse(expression) ?? 0.0;
    }
  }

  String getConvertedAmount(Currency currency) {
    double result = baseValueInUSD * currency.rate;
    if (result.isNaN || result.isInfinite) return "0";

    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String mathFunc(Match match) => '${match[1]},';
    
    if (result == result.toInt()) {
      return result.toInt().toString().replaceAllMapped(reg, mathFunc);
    }
    return result.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // মেমোরি লিক রোধ করার জন্য ডিসপোজ
    super.dispose();
  }
}