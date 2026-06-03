class Currency {
  final String code;
  final String name;
  final String flag;
  final double rate;

  Currency({
    required this.code,
    required this.name,
    required this.flag,
    required this.rate,
  });

  factory Currency.fromJson(Map<String, dynamic> json, String code) {
    return Currency(
      code: code,
      name: _getName(code),
      flag: _getFlag(code),
      rate: (json[code] as num).toDouble(),
    );
  }

  static String _getName(String code) {
    switch (code) {
      case 'BDT': return 'Bangladeshi Taka';
      case 'USD': return 'US Dollar';
      case 'INR': return 'Indian Rupee';
      case 'EUR': return 'Euro';
      case 'SAR': return 'Saudi Riyal';
      default: return '';
    }
  }

  static String _getFlag(String code) {
    switch (code) {
      case 'BDT': return '🇧🇩';
      case 'USD': return '🇺🇸';
      case 'INR': return '🇮🇳';
      case 'EUR': return '🇪🇺';
      case 'SAR': return '🇸🇦';
      default: return '🏳️';
    }
  }
}