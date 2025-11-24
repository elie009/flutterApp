// Double-entry accounting validation utilities for Flutter

/// Result of double-entry validation
class DoubleEntryValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final double debitTotal;
  final double creditTotal;

  DoubleEntryValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
    required this.debitTotal,
    required this.creditTotal,
  });
}

/// Category type detection
bool isBillCategory(String category) {
  final billKeywords = ['bill', 'utility', 'rent', 'insurance', 'subscription', 'payment'];
  return billKeywords.any((keyword) => category.toLowerCase().contains(keyword));
}

bool isSavingsCategory(String category) {
  final savingsKeywords = ['savings', 'deposit', 'investment', 'goal', 'fund'];
  return savingsKeywords.any((keyword) => category.toLowerCase().contains(keyword));
}

bool isLoanCategory(String category) {
  final loanKeywords = ['loan', 'repayment', 'debt', 'installment', 'mortgage'];
  return loanKeywords.any((keyword) => category.toLowerCase().contains(keyword));
}

bool isTransferCategory(String category) {
  final transferKeywords = ['bank transfer', 'transfer'];
  return transferKeywords.any((keyword) => 
    category.toLowerCase().contains(keyword.toLowerCase())
  );
}

/// Validate double-entry accounting rules for a transaction
DoubleEntryValidationResult validateDoubleEntry({
  required String transactionType,
  required double amount,
  required String bankAccountId,
  String? category,
  String? toBankAccountId,
  String? billId,
  String? savingsAccountId,
  String? loanId,
}) {
  final errors = <String>[];
  final warnings = <String>[];
  double debitTotal = 0;
  double creditTotal = 0;

  // Basic amount validation
  if (amount <= 0) {
    errors.add('Amount must be greater than 0');
    return DoubleEntryValidationResult(
      isValid: false,
      errors: errors,
      warnings: warnings,
      debitTotal: 0,
      creditTotal: 0,
    );
  }

  // Determine debit and credit entries based on transaction type
  if (transactionType.toUpperCase() == 'CREDIT') {
    // Income transaction:
    // Debit: Bank Account (Asset) - increases
    // Credit: Income Account (Revenue) - increases
    debitTotal = amount;
    creditTotal = amount;
  } else if (transactionType.toUpperCase() == 'DEBIT') {
    // Check transaction type
    final isTransfer = isTransferCategory(category ?? '') || (toBankAccountId != null && toBankAccountId.isNotEmpty);
    final isBillPayment = (billId != null && billId.isNotEmpty) || isBillCategory(category ?? '');
    final isSavingsDeposit = (savingsAccountId != null && savingsAccountId.isNotEmpty) || isSavingsCategory(category ?? '');
    final isLoanPayment = (loanId != null && loanId.isNotEmpty) || isLoanCategory(category ?? '');

    if (isTransfer && toBankAccountId != null && toBankAccountId.isNotEmpty) {
      // Bank transfer:
      // Debit: Destination Bank Account (Asset) - increases
      // Credit: Source Bank Account (Asset) - decreases
      if (bankAccountId == toBankAccountId) {
        errors.add('Source and destination accounts cannot be the same for transfers');
      }
      debitTotal = amount;
      creditTotal = amount;
    } else if (isBillPayment) {
      // Bill payment:
      // Debit: Expense Account (Expense) - increases
      // Credit: Bank Account (Asset) - decreases
      debitTotal = amount;
      creditTotal = amount;
    } else if (isSavingsDeposit) {
      // Savings deposit:
      // Debit: Savings Account (Asset) - increases
      // Credit: Bank Account (Asset) - decreases
      debitTotal = amount;
      creditTotal = amount;
    } else if (isLoanPayment) {
      // Loan payment (simplified - actual may have principal + interest split):
      // Debit: Loan Payable (Liability) - decreases
      // Debit: Interest Expense (Expense) - increases (if applicable)
      // Credit: Bank Account (Asset) - decreases
      debitTotal = amount;
      creditTotal = amount;
    } else {
      // Regular expense:
      // Debit: Expense Account (Expense) - increases
      // Credit: Bank Account (Asset) - decreases
      debitTotal = amount;
      creditTotal = amount;
    }
  }

  // Validate double-entry balance
  final difference = (debitTotal - creditTotal).abs();
  if (difference > 0.01) { // Allow for floating point precision
    errors.add(
      'Double-entry validation failed: Debits (${debitTotal.toStringAsFixed(2)}) must equal Credits (${creditTotal.toStringAsFixed(2)}). Difference: ${difference.toStringAsFixed(2)}'
    );
  }

  // Check minimum entries (at least one debit and one credit)
  if (debitTotal == 0 || creditTotal == 0) {
    errors.add('Transaction must have at least one debit and one credit entry');
  }

  // Warnings for potential issues
  if (transactionType.toUpperCase() == 'DEBIT' && 
      (category == null || category.isEmpty) && 
      (billId == null || billId.isEmpty) && 
      (savingsAccountId == null || savingsAccountId.isEmpty) && 
      (loanId == null || loanId.isEmpty)) {
    warnings.add('Consider adding a category for better accounting classification');
  }

  return DoubleEntryValidationResult(
    isValid: errors.isEmpty,
    errors: errors,
    warnings: warnings,
    debitTotal: debitTotal,
    creditTotal: creditTotal,
  );
}

/// Enhanced transaction validation that includes double-entry checks
List<String> validateTransactionWithDoubleEntry({
  required String bankAccountId,
  required double amount,
  String? description,
  String? category,
  String? billId,
  String? savingsAccountId,
  String? loanId,
  String? toBankAccountId,
  required String transactionType,
}) {
  final errors = <String>[];

  // Basic validation
  if (bankAccountId.isEmpty) {
    errors.add('Bank account is required');
  }
  if (amount <= 0) {
    errors.add('Amount must be greater than 0');
  }

  // Description validation (not required for transfers)
  if (!isTransferCategory(category ?? '') && (description == null || description.trim().isEmpty)) {
    errors.add('Description is required');
  }

  // Category validation (only required for DEBIT transactions)
  if (transactionType.toUpperCase() != 'CREDIT' && (category == null || category.isEmpty)) {
    errors.add('Category is required for debit transactions');
  }

  // Category-specific validation (only for DEBIT transactions with category)
  if (transactionType.toUpperCase() != 'CREDIT' && category != null && category.isNotEmpty) {
    if (isBillCategory(category) && (billId == null || billId.isEmpty)) {
      errors.add('Bill selection is required for bill-related transactions');
    }

    if (isSavingsCategory(category) && (savingsAccountId == null || savingsAccountId.isEmpty)) {
      errors.add('Savings account selection is required for savings-related transactions');
    }

    if (isLoanCategory(category) && (loanId == null || loanId.isEmpty)) {
      errors.add('Loan selection is required for loan-related transactions');
    }

    if (isTransferCategory(category) && (toBankAccountId == null || toBankAccountId.isEmpty)) {
      errors.add('Target bank account is required for bank transfer transactions');
    }
  }

  // Double-entry validation
  final doubleEntryResult = validateDoubleEntry(
    transactionType: transactionType,
    amount: amount,
    bankAccountId: bankAccountId,
    category: category,
    toBankAccountId: toBankAccountId,
    billId: billId,
    savingsAccountId: savingsAccountId,
    loanId: loanId,
  );

  errors.addAll(doubleEntryResult.errors);

  return errors;
}

