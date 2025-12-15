class AppConfig {
  // API Configuration
  static const String baseUrl = 'http://localhost:5000/api';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration categoriesApiTimeout = Duration(seconds: 180); // Extended timeout for categories API (3 minutes)
  static const Duration cacheTimeout = Duration(minutes: 5);

  // App Information
  static const String appName = 'UtilityHub360';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String biometricEnabledKey = 'biometric_enabled';

  // Pagination
  static const int defaultPageSize = 20;
  static const int transactionsPageSize = 50;
  static const int billsPageSize = 20;

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'MMM dd, yyyy';

  // Currency
  static const String defaultCurrency = 'PHP';
  static const String currencySymbol = '₱';

  // Cache Keys
  static const String cacheDashboard = 'dashboard_data';
  static const String cacheTransactions = 'transactions_data';
  static const String cacheBills = 'bills_data';
  static const String cacheLoans = 'loans_data';
  static const String cacheIncomeSources = 'income_sources_data';
  static const String cacheBankAccounts = 'bank_accounts_data';
}

