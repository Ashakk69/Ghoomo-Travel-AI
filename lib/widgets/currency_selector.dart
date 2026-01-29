import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/currency.dart';

class CurrencySelector extends StatelessWidget {
  final Currency selectedCurrency;
  final ValueChanged<Currency?> onChanged;

  const CurrencySelector({
    super.key,
    required this.selectedCurrency,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Currency>(
          value: selectedCurrency,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
          dropdownColor: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16),
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          items: Currency.allCurrencies.map((currency) {
            return DropdownMenuItem<Currency>(
              value: currency,
              child: Row(
                children: [
                  Text(
                    currency.symbol,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    currency.code,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '- ${currency.name}',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
