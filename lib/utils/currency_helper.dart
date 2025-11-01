import '../services/auth_service.dart';
import 'formatters.dart';

class CurrencyHelper {
  // Map of currency codes to their symbols
  static const Map<String, String> _currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'PHP': '₱',
    'JPY': '¥',
    'CNY': '¥',
    'AUD': 'A\$',
    'CAD': 'C\$',
    'INR': '₹',
    'SGD': 'S\$',
    'HKD': 'HK\$',
    'KRW': '₩',
    'THB': '฿',
    'MYR': 'RM',
    'IDR': 'Rp',
    'VND': '₫',
  };

  /// Get currency symbol for a given currency code
  static String getCurrencySymbol(String? currencyCode) {
    if (currencyCode == null || currencyCode.isEmpty) {
      return getDefaultCurrencySymbol();
    }
    return _currencySymbols[currencyCode.toUpperCase()] ?? getDefaultCurrencySymbol();
  }

  /// Get default currency symbol (fallback - empty string for no symbol)
  static String getDefaultCurrencySymbol() {
    // Return empty string if no currency is set
    // This allows the formatter to handle it appropriately
    return '';
  }

  /// Get user's preferred currency symbol from current user
  static String getCurrentUserCurrencySymbol() {
    final user = AuthService.getCurrentUser();
    if (user?.preferredCurrency != null) {
      return getCurrencySymbol(user!.preferredCurrency);
    }
    return getDefaultCurrencySymbol();
  }

  /// Format currency with user's preferred currency symbol
  static String formatCurrencyWithUserPreference(double amount) {
    final symbol = getCurrentUserCurrencySymbol();
    return Formatters.formatCurrency(amount, symbol: symbol);
  }
}

