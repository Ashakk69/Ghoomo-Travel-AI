import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/currency.dart';
import '../services/currency_service.dart';

class CostDisplay extends StatelessWidget {
  final double costInUSD;
  final Currency displayCurrency;
  final bool showConversion;
  final double fontSize;

  const CostDisplay({
    super.key,
    required this.costInUSD,
    required this.displayCurrency,
    this.showConversion = true,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    final convertedAmount = CurrencyService.convert(
      costInUSD,
      Currency.usd,
      displayCurrency,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          CurrencyService.format(convertedAmount, displayCurrency),
          style: GoogleFonts.outfit(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        if (showConversion && displayCurrency != Currency.usd) ...[
          const SizedBox(width: 4),
          Text(
            '(${CurrencyService.format(costInUSD, Currency.usd)})',
            style: GoogleFonts.outfit(
              fontSize: fontSize * 0.85,
              color: Colors.white54,
            ),
          ),
        ],
      ],
    );
  }
}
