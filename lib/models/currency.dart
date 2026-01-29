class Currency {
  final String code;
  final String symbol;
  final String name;
  final double exchangeRateToUSD;

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
    required this.exchangeRateToUSD,
  });

  // Convert amount from this currency to another
  double convertTo(double amount, Currency targetCurrency) {
    // Convert to USD first, then to target currency
    final amountInUSD = amount / exchangeRateToUSD;
    return amountInUSD * targetCurrency.exchangeRateToUSD;
  }

  // Format amount with currency symbol
  String format(double amount) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  static const Currency usd = Currency(
    code: 'USD',
    symbol: '\$',
    name: 'US Dollar',
    exchangeRateToUSD: 1.0,
  );

  static const Currency eur = Currency(
    code: 'EUR',
    symbol: '€',
    name: 'Euro',
    exchangeRateToUSD: 1.09,
  );

  static const Currency gbp = Currency(
    code: 'GBP',
    symbol: '£',
    name: 'British Pound',
    exchangeRateToUSD: 1.27,
  );

  static const Currency jpy = Currency(
    code: 'JPY',
    symbol: '¥',
    name: 'Japanese Yen',
    exchangeRateToUSD: 0.0067,
  );

  static const Currency inr = Currency(
    code: 'INR',
    symbol: '₹',
    name: 'Indian Rupee',
    exchangeRateToUSD: 0.012,
  );

  static const Currency aud = Currency(
    code: 'AUD',
    symbol: 'A\$',
    name: 'Australian Dollar',
    exchangeRateToUSD: 0.66,
  );

  static const Currency cad = Currency(
    code: 'CAD',
    symbol: 'C\$',
    name: 'Canadian Dollar',
    exchangeRateToUSD: 0.74,
  );

  static List<Currency> get allCurrencies => [
        usd,
        eur,
        gbp,
        jpy,
        inr,
        aud,
        cad,
      ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Currency &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}
