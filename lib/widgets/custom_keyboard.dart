import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/calculator_viewmodel.dart';

class CustomKeyboard extends StatelessWidget {
  final Function(String) onKeyPressed;
  final VoidCallback onClear;
  final VoidCallback onDelete;

  const CustomKeyboard({
    super.key,
    required this.onKeyPressed,
    required this.onClear,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double keyboardHeight = screenHeight * 0.42;
    final isDarkMode = Provider.of<CalculatorViewModel>(context).isDarkMode;

    final List<List<String>> keys = [
      ['C', '←', '%', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '−'],
      ['1', '2', '3', '+'],
      ['0', '.', '=']
    ];

    return Container(
      height: keyboardHeight,
      color: isDarkMode ? const Color(0xFF0F0F11) : const Color(0xFFF5F5F7),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: keys.map((row) {
          return Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((key) {
                int flexValue = (key == '0') ? 2 : 1;

                return Expanded(
                  flex: flexValue,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: SizedBox(
                      height: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getBtnColor(key, isDarkMode),
                          elevation: isDarkMode ? 0 : 2,
                          shadowColor: Colors.black26,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () {
                          if (key == 'C') {
                            onClear();
                          } else if (key == '←') {
                            onDelete();
                          } else {
                            onKeyPressed(key);
                          }
                        },
                        child: Text(
                          key,
                          style: TextStyle(
                            fontSize: 22,
                            color: _getTxtColor(key, isDarkMode),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getBtnColor(String key, bool isDarkMode) {
    if (['÷', '×', '−', '+', '='].contains(key)) {
      return const Color(0xFFE5A93C); 
    }
    if (['C', '←', '%'].contains(key)) {
      return isDarkMode ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA);
    }
    return isDarkMode ? const Color(0xFF222224) : Colors.white;
  }

  Color _getTxtColor(String key, bool isDarkMode) {
    if (['÷', '×', '−', '+', '='].contains(key)) return Colors.white;
    if (['C', '←', '%'].contains(key)) {
      return isDarkMode ? const Color(0xFFE5A93C) : Colors.black87;
    }
    return isDarkMode ? Colors.white : const Color(0xFF1C1C1E);
  }
}