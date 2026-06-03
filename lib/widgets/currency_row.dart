import 'package:flutter/material.dart';
import '../data/models/currency_model.dart';

class CurrencyRow extends StatelessWidget {
  final Currency currency;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const CurrencyRow({
    super.key,
    required this.currency,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          // স্ক্রিনশটের মতো নিঁখুত কালার ম্যাচিং
          color: isSelected ? const Color(0xFF251F14) : const Color(0xFF181818),
          borderRadius: BorderRadius.circular(14),
          border: isSelected ? Border.all(color: const Color(0xFF8B6C3F), width: 1.5) : null,
        ),
        child: Row(
          children: [
            // কাস্টম ফ্ল্যাগ সার্কেল ডিজাইন
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF2C2C2C),
              ),
              child: Center(
                child: Text(currency.flag, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              currency.code,
              style: const TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: isSelected ? const Color(0xFFE2C48E) : Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}