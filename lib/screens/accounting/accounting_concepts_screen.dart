import 'package:flutter/material.dart';
import '../../utils/formatters.dart';

class AccountingConceptsScreen extends StatefulWidget {
  const AccountingConceptsScreen({super.key});

  @override
  State<AccountingConceptsScreen> createState() => _AccountingConceptsScreenState();
}

class _AccountingConceptsScreenState extends State<AccountingConceptsScreen> {
  int _selectedIndex = 0;

  final List<AccountingConcept> _concepts = [
    AccountingConcept(
      name: 'Assets',
      definition: 'Resources owned that have economic value',
      moduleMappings: [
        ModuleMapping(module: 'Bank Accounts', accountType: 'Asset (Cash)'),
        ModuleMapping(module: 'Savings Accounts', accountType: 'Asset (Savings)'),
        ModuleMapping(module: 'Investment Accounts', accountType: 'Asset (Investments)'),
        ModuleMapping(module: 'Receivables', accountType: 'Asset (Accounts Receivable)'),
      ],
      accountingRules: AccountingRules(
        increases: 'Debit',
        decreases: 'Credit',
        normalBalance: 'Debit',
      ),
      examples: [
        TransactionExample(
          description: 'Opening bank account',
          debit: 'Cash (Bank Account)',
          credit: "Owner's Capital",
          amount: '\$10,000',
        ),
        TransactionExample(
          description: 'Receiving payment',
          debit: 'Cash',
          credit: 'Income',
          amount: '\$5,000',
        ),
        TransactionExample(
          description: 'Making payment',
          debit: 'Expense',
          credit: 'Cash',
          amount: '\$150',
        ),
      ],
      color: Colors.green,
      icon: Icons.account_balance,
    ),
    AccountingConcept(
      name: 'Liabilities',
      definition: 'Obligations to pay debts',
      moduleMappings: [
        ModuleMapping(module: 'Loans', accountType: 'Liability (Loan Payable)'),
        ModuleMapping(module: 'Credit Cards', accountType: 'Liability (Credit Card Payable)'),
        ModuleMapping(module: 'Bills (Unpaid)', accountType: 'Liability (Accounts Payable)'),
      ],
      accountingRules: AccountingRules(
        increases: 'Credit',
        decreases: 'Debit',
        normalBalance: 'Credit',
      ),
      examples: [
        TransactionExample(
          description: 'Taking loan',
          debit: 'Cash',
          credit: 'Loan Payable',
          amount: '\$20,000',
        ),
        TransactionExample(
          description: 'Paying loan',
          debit: 'Loan Payable',
          credit: 'Cash',
          amount: '\$500',
        ),
        TransactionExample(
          description: 'Receiving bill',
          debit: 'Expense',
          credit: 'Accounts Payable',
          amount: '\$150',
        ),
        TransactionExample(
          description: 'Paying bill',
          debit: 'Accounts Payable',
          credit: 'Cash',
          amount: '\$150',
        ),
      ],
      color: Colors.red,
      icon: Icons.trending_down,
    ),
    AccountingConcept(
      name: 'Equity',
      definition: "Owner's interest in assets after liabilities",
      moduleMappings: [
        ModuleMapping(module: 'Initial Capital', accountType: "Equity (Owner's Capital)"),
        ModuleMapping(module: 'Net Income', accountType: 'Equity (Retained Earnings)'),
        ModuleMapping(module: 'Withdrawals', accountType: "Equity (Owner's Draw)"),
      ],
      accountingRules: AccountingRules(
        increases: 'Credit',
        decreases: 'Debit',
        normalBalance: 'Credit',
      ),
      examples: [
        TransactionExample(
          description: 'Initial setup',
          debit: 'Cash',
          credit: "Owner's Capital",
          amount: '\$10,000',
        ),
        TransactionExample(
          description: 'Net income',
          debit: 'Income Summary',
          credit: 'Retained Earnings',
          amount: '\$5,000',
        ),
        TransactionExample(
          description: 'Owner withdrawal',
          debit: "Owner's Draw",
          credit: 'Cash',
          amount: '\$1,000',
        ),
      ],
      color: Colors.blue,
      icon: Icons.attach_money,
    ),
    AccountingConcept(
      name: 'Income',
      definition: 'Money received from business activities or investments',
      moduleMappings: [
        ModuleMapping(module: 'Income Sources', accountType: 'Income (Salary, Business Income, etc.)'),
        ModuleMapping(module: 'Interest Income', accountType: 'Income (Interest Revenue)'),
        ModuleMapping(module: 'Investment Returns', accountType: 'Income (Investment Income)'),
      ],
      accountingRules: AccountingRules(
        increases: 'Credit',
        decreases: 'Debit (rare)',
        normalBalance: 'Credit',
      ),
      examples: [
        TransactionExample(
          description: 'Receiving salary',
          debit: 'Cash',
          credit: 'Salary Income',
          amount: '\$5,000',
        ),
        TransactionExample(
          description: 'Interest earned',
          debit: 'Cash',
          credit: 'Interest Income',
          amount: '\$50',
        ),
        TransactionExample(
          description: 'Business income',
          debit: 'Cash',
          credit: 'Business Income',
          amount: '\$2,000',
        ),
      ],
      color: Colors.orange,
      icon: Icons.trending_up,
    ),
    AccountingConcept(
      name: 'Expenses',
      definition: 'Costs incurred to generate income or maintain operations',
      moduleMappings: [
        ModuleMapping(module: 'Bills', accountType: 'Expense (Utilities, Subscriptions, etc.)'),
        ModuleMapping(module: 'Loan Interest', accountType: 'Expense (Interest Expense)'),
        ModuleMapping(module: 'Transactions (Expenses)', accountType: 'Expense (Various categories)'),
      ],
      accountingRules: AccountingRules(
        increases: 'Debit',
        decreases: 'Credit (rare)',
        normalBalance: 'Debit',
      ),
      examples: [
        TransactionExample(
          description: 'Paying utility bill',
          debit: 'Utility Expense',
          credit: 'Cash',
          amount: '\$150',
        ),
        TransactionExample(
          description: 'Loan interest',
          debit: 'Interest Expense',
          credit: 'Cash',
          amount: '\$200',
        ),
        TransactionExample(
          description: 'Office supplies',
          debit: 'Supplies Expense',
          credit: 'Cash',
          amount: '\$50',
        ),
      ],
      color: Colors.pink,
      icon: Icons.trending_down,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounting Concepts'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Accounting Equation Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fundamental Accounting Equation',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Assets = Liabilities + Equity',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This equation must always balance. Your system automatically maintains this balance through double-entry bookkeeping.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // Concept List
          Expanded(
            child: ListView.builder(
              itemCount: _concepts.length,
              itemBuilder: (context, index) {
                final concept = _concepts[index];
                return ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: concept.color.withOpacity(0.2),
                    child: Icon(concept.icon, color: concept.color),
                  ),
                  title: Text(
                    concept.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(concept.definition),
                  trailing: Chip(
                    label: Text(
                      concept.accountingRules.normalBalance,
                      style: TextStyle(
                        color: concept.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: concept.color.withOpacity(0.2),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Module Mappings
                          const Text(
                            'Module Mapping',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...concept.moduleMappings.map((mapping) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      mapping.module,
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      '→ ${mapping.accountType}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              )),

                          const SizedBox(height: 16),
                          const Divider(),

                          // Accounting Rules
                          const Text(
                            'Accounting Rules',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildRuleRow('Increases:', concept.accountingRules.increases, concept.color),
                          _buildRuleRow('Decreases:', concept.accountingRules.decreases, concept.color),
                          _buildRuleRow('Normal Balance:', concept.accountingRules.normalBalance, concept.color),

                          const SizedBox(height: 16),
                          const Divider(),

                          // Examples
                          const Text(
                            'Examples',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...concept.examples.map((example) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      example.description,
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Debit: ${example.debit}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                    ),
                                    Text(
                                      'Credit: ${example.credit}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Amount: ${example.amount}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: concept.color,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Double-Entry Principle Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    const Text(
                      'Double-Entry Principle',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Every transaction in your system automatically creates balanced entries:',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Total Debits = Total Credits',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This ensures mathematical accuracy and prevents errors. Your system validates this automatically for every transaction.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Chip(
            label: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            backgroundColor: color.withOpacity(0.2),
            padding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

// Data Models
class AccountingConcept {
  final String name;
  final String definition;
  final List<ModuleMapping> moduleMappings;
  final AccountingRules accountingRules;
  final List<TransactionExample> examples;
  final Color color;
  final IconData icon;

  AccountingConcept({
    required this.name,
    required this.definition,
    required this.moduleMappings,
    required this.accountingRules,
    required this.examples,
    required this.color,
    required this.icon,
  });
}

class ModuleMapping {
  final String module;
  final String accountType;

  ModuleMapping({required this.module, required this.accountType});
}

class AccountingRules {
  final String increases;
  final String decreases;
  final String normalBalance;

  AccountingRules({
    required this.increases,
    required this.decreases,
    required this.normalBalance,
  });
}

class TransactionExample {
  final String description;
  final String debit;
  final String credit;
  final String amount;

  TransactionExample({
    required this.description,
    required this.debit,
    required this.credit,
    required this.amount,
  });
}

