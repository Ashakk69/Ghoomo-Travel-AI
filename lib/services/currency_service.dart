import '../models/currency.dart';

class CurrencyService {
  // Convert amount from one currency to another
  static double convert(double amount, Currency from, Currency to) {
    return from.convertTo(amount, to);
  }

  // Format amount with currency symbol
  static String format(double amount, Currency currency) {
    return currency.format(amount);
  }

  // Format with conversion indicator if not in USD
  static String formatWithConversion(
      double amountInUSD, Currency displayCurrency) {
    if (displayCurrency == Currency.usd) {
      return format(amountInUSD, displayCurrency);
    }

    final convertedAmount = convert(amountInUSD, Currency.usd, displayCurrency);
    return '${format(convertedAmount, displayCurrency)} (${format(amountInUSD, Currency.usd)})';
  }

  // Get currency by code
  static Currency? getCurrencyByCode(String code) {
    try {
      return Currency.allCurrencies.firstWhere((c) => c.code == code);
    } catch (e) {
      return null;
    }
  }

  // Format large amounts with K/M notation
  static String formatCompact(double amount, Currency currency) {
    if (amount >= 1000000) {
      return '${currency.symbol}${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${currency.symbol}${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount, currency);
  }
}
