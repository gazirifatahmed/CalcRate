import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/calculator_viewmodel.dart';
import '../../widgets/currency_row.dart';
import '../../widgets/custom_keyboard.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<CalculatorViewModel>(context).isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F0F11) : const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF0F0F11) : const Color(0xFFF5F5F7),
        elevation: 0,
        title: Row(
          children: [
            // ব্র্যান্ড লোগো/আইকন এরর বিল্ডার দিয়ে ফিক্স করা হলো
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/image/icon/logo.png',
                width: 28,
                height: 28,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 28,
                  height: 28,
                  color: Colors.amber,
                  child: const Icon(Icons.calculate, size: 18, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CalcRate',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black, 
                    fontSize: 18, 
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 2),
                Consumer<CalculatorViewModel>(
                  builder: (context, viewModel, child) {
                    return Text(
                      viewModel.lastUpdateTime,
                      style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w500),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.amber, size: 22),
            onPressed: () => context.read<CalculatorViewModel>().loadData(),
          ),
          IconButton(
            icon: Icon(Icons.account_balance, color: isDarkMode ? const Color(0xFFD4AF37) : Colors.blueGrey, size: 22),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.settings, color: isDarkMode ? Colors.grey : Colors.black54, size: 22),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: Consumer<CalculatorViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.amber));
          }
          return Column(
            children: [
              // কারেন্সি লিস্ট উইজেট
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  itemCount: viewModel.currencies.length,
                  itemBuilder: (context, index) {
                    final currency = viewModel.currencies[index];
                    return CurrencyRow(
                      currency: currency,
                      value: viewModel.getConvertedAmount(currency),
                      isSelected: viewModel.selectedCurrencyCode == currency.code,
                      onTap: () => viewModel.selectCurrency(currency.code),
                    );
                  },
                ),
              ),
              // এক্সপ্রেশন ভিউয়ার
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                alignment: Alignment.centerRight,
                child: Text(
                  viewModel.inputExpression,
                  style: TextStyle(
                    color: isDarkMode ? Colors.amber : Colors.deepOrange,
                    fontSize: 26,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              // কীবোর্ড উইজেট
              SafeArea(
                top: false,
                child: CustomKeyboard(
                  onKeyPressed: (val) => viewModel.appendInput(val),
                  onClear: () => viewModel.clearInput(),
                  onDelete: () => viewModel.deleteLast(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}