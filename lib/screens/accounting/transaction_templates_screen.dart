import 'package:flutter/material.dart';
import '../../utils/formatters.dart';

class TransactionTemplatesScreen extends StatefulWidget {
  const TransactionTemplatesScreen({super.key});

  @override
  State<TransactionTemplatesScreen> createState() => _TransactionTemplatesScreenState();
}

class _TransactionTemplatesScreenState extends State<TransactionTemplatesScreen> {
  final List<TransactionTemplate> _templates = [
    TransactionTemplate(
      title: 'Opening Bank Account',
      description: 'Initial deposit when setting up your account',
      date: '2024-01-01',
      entries: [
        JournalEntry(
          account: 'Cash (Bank Account)',
          type: EntryType.debit,
          amount: 10000,
          explanation: 'Asset increases (money in account)',
        ),
        JournalEntry(
          account: "Owner's Capital",
          type: EntryType.credit,
          amount: 10000,
          explanation: 'Equity increases (your initial investment)',
        ),
      ],
      color: Colors.green,
      icon: Icons.account_balance,
    ),
    TransactionTemplate(
      title: 'Receiving Salary',
      description: 'Monthly salary deposit',
      date: '2024-01-15',
      entries: [
        JournalEntry(
          account: 'Cash',
          type: EntryType.debit,
          amount: 5000,
          explanation: 'Asset increases (money received)',
        ),
        JournalEntry(
          account: 'Salary Income',
          type: EntryType.credit,
          amount: 5000,
          explanation: 'Income increases (revenue earned)',
        ),
      ],
      color: Colors.orange,
      icon: Icons.trending_up,
    ),
    TransactionTemplate(
      title: 'Paying Utility Bill',
      description: 'Monthly electricity bill payment',
      date: '2024-01-20',
      entries: [
        JournalEntry(
          account: 'Utility Expense',
          type: EntryType.debit,
          amount: 150,
          explanation: 'Expense increases (cost incurred)',
        ),
        JournalEntry(
          account: 'Cash',
          type: EntryType.credit,
          amount: 150,
          explanation: 'Asset decreases (money paid out)',
        ),
      ],
      color: Colors.pink,
      icon: Icons.trending_down,
    ),
    TransactionTemplate(
      title: 'Taking Loan',
      description: 'Receiving loan disbursement',
      date: '2024-01-25',
      entries: [
        JournalEntry(
          account: 'Cash',
          type: EntryType.debit,
          amount: 20000,
          explanation: 'Asset increases (money received)',
        ),
        JournalEntry(
          account: 'Loan Payable',
          type: EntryType.credit,
          amount: 20000,
          explanation: 'Liability increases (debt owed)',
        ),
      ],
      color: Colors.red,
      icon: Icons.account_balance,
    ),
    TransactionTemplate(
      title: 'Making Loan Payment',
      description: 'Monthly loan payment (principal + interest)',
      date: '2024-02-01',
      entries: [
        JournalEntry(
          account: 'Loan Payable (Principal)',
          type: EntryType.debit,
          amount: 500,
          explanation: 'Liability decreases (debt reduced)',
        ),
        JournalEntry(
          account: 'Interest Expense',
          type: EntryType.debit,
          amount: 200,
          explanation: 'Expense increases (interest cost)',
        ),
        JournalEntry(
          account: 'Cash',
          type: EntryType.credit,
          amount: 700,
          explanation: 'Asset decreases (money paid out)',
        ),
      ],
      color: Colors.red,
      icon: Icons.trending_down,
    ),
    TransactionTemplate(
      title: 'Transfer Between Accounts',
      description: 'Moving money from checking to savings',
      date: '2024-02-05',
      entries: [
        JournalEntry(
          account: 'Cash (Savings Account)',
          type: EntryType.debit,
          amount: 1000,
          explanation: 'Asset increases (savings account balance)',
        ),
        JournalEntry(
          account: 'Cash (Checking Account)',
          type: EntryType.credit,
          amount: 1000,
          explanation: 'Asset decreases (checking account balance)',
        ),
      ],
      color: Colors.blue,
      icon: Icons.account_balance,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Templates'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Double-Entry Structure Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text(
                      'Double-Entry Structure',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transaction Date: [Date]',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Description: [Description]',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      Divider(color: Colors.white30),
                      Text(
                        'Debit Account: [Account Name] Amount: [Amount]',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Credit Account: [Account Name] Amount: [Amount]',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      Divider(color: Colors.white30),
                      Text(
                        'Total Debits = Total Credits',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Validation Rules
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Validation Rules',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      avatar: const Icon(Icons.check_circle, size: 18, color: Colors.green),
                      label: const Text('At least one debit and one credit'),
                      backgroundColor: Colors.green[50],
                    ),
                    Chip(
                      avatar: const Icon(Icons.check_circle, size: 18, color: Colors.green),
                      label: const Text('Total debits equal total credits'),
                      backgroundColor: Colors.green[50],
                    ),
                    Chip(
                      avatar: const Icon(Icons.check_circle, size: 18, color: Colors.green),
                      label: const Text('Account balances consistent'),
                      backgroundColor: Colors.green[50],
                    ),
                    Chip(
                      avatar: const Icon(Icons.info, size: 18, color: Colors.blue),
                      label: const Text('Transactions cannot be deleted'),
                      backgroundColor: Colors.blue[50],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Templates
          ..._templates.map((template) => _buildTemplateCard(template)),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(TransactionTemplate template) {
    final totalDebits = template.entries
        .where((e) => e.type == EntryType.debit)
        .fold(0.0, (sum, e) => sum + e.amount);
    final totalCredits = template.entries
        .where((e) => e.type == EntryType.credit)
        .fold(0.0, (sum, e) => sum + e.amount);
    final isBalanced = (totalDebits - totalCredits).abs() < 0.01;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: template.color.withOpacity(0.2),
          child: Icon(template.icon, color: template.color),
        ),
        title: Text(
          template.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(template.description),
        trailing: Chip(
          label: Text('${template.entries.length} entries'),
          backgroundColor: template.color.withOpacity(0.2),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transaction Details
                const Text(
                  'Transaction Details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Date: ${template.date}'),
                Text('Description: ${template.description}'),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),

                // Journal Entries
                const Text(
                  'Journal Entries',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                DataTable(
                  columns: const [
                    DataColumn(label: Text('Account')),
                    DataColumn(label: Text('Type'), numeric: false),
                    DataColumn(label: Text('Amount'), numeric: true),
                    DataColumn(label: Text('Explanation')),
                  ],
                  rows: [
                    ...template.entries.map((entry) => DataRow(
                          cells: [
                            DataCell(Text(
                              entry.account,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            )),
                            DataCell(Chip(
                              label: Text(
                                entry.type == EntryType.debit ? 'Debit' : 'Credit',
                                style: TextStyle(
                                  color: entry.type == EntryType.debit
                                      ? Colors.green
                                      : Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                              backgroundColor: entry.type == EntryType.debit
                                  ? Colors.green[50]
                                  : Colors.blue[50],
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            )),
                            DataCell(Text(
                              formatCurrency(entry.amount),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: entry.type == EntryType.debit
                                    ? Colors.green
                                    : Colors.blue,
                              ),
                            )),
                            DataCell(Text(
                              entry.explanation,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[700],
                              ),
                            )),
                          ],
                        )),
                    DataRow(
                      color: MaterialStateProperty.all(Colors.grey[100]),
                      cells: [
                        const DataCell(Text(
                          'Total',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                        const DataCell(SizedBox.shrink()),
                        DataCell(Text(
                          formatCurrency(totalDebits),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )),
                        DataCell(Chip(
                          avatar: const Icon(Icons.check_circle, size: 16, color: Colors.green),
                          label: const Text(
                            'Balanced',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                          backgroundColor: Colors.green[50],
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        )),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Validation Status
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isBalanced ? Colors.green[50] : Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isBalanced ? Icons.check_circle : Icons.warning,
                        color: isBalanced ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isBalanced ? 'Validation Passed' : 'Validation Check',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isBalanced ? Colors.green[700] : Colors.orange[700],
                              ),
                            ),
                            Text(
                              'Total Debits (${formatCurrency(totalDebits)}) = Total Credits (${formatCurrency(totalCredits)})',
                              style: TextStyle(
                                fontSize: 11,
                                color: isBalanced ? Colors.green[700] : Colors.orange[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Data Models
class TransactionTemplate {
  final String title;
  final String description;
  final String date;
  final List<JournalEntry> entries;
  final Color color;
  final IconData icon;

  TransactionTemplate({
    required this.title,
    required this.description,
    required this.date,
    required this.entries,
    required this.color,
    required this.icon,
  });
}

class JournalEntry {
  final String account;
  final EntryType type;
  final double amount;
  final String explanation;

  JournalEntry({
    required this.account,
    required this.type,
    required this.amount,
    required this.explanation,
  });
}

enum EntryType {
  debit,
  credit,
}

