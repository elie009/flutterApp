import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../models/expense.dart';
import '../../services/expense_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/expense_receipt_upload_dialog.dart';
import 'pending_approvals_screen.dart';
import 'expense_report_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> with SingleTickerProviderStateMixin {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final ExpenseService _expenseService = ExpenseService();
  List<Expense> _expenses = [];
  List<ExpenseCategory> _categories = [];
  List<ExpenseBudget> _budgets = [];
  bool _isLoading = true;
  String? _errorMessage;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadExpenses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadExpenses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _expenseService.getExpenses(),
        _expenseService.getCategories(),
        _expenseService.getBudgets(),
      ]);

      setState(() {
        _expenses = results[0] as List<Expense>;
        _categories = results[1] as List<ExpenseCategory>;
        _budgets = results[2] as List<ExpenseBudget>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onRefresh() async {
    await _loadExpenses();
    _refreshController.refreshCompleted();
  }

  double _getTotalExpenses() {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  void _showReceiptUpload(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => ExpenseReceiptUploadDialog(
        expense: expense,
        onUploaded: _loadExpenses,
      ),
    );
  }

  void _submitForApproval(Expense expense) async {
    try {
      await _expenseService.submitForApproval(expense.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense submitted for approval'),
            backgroundColor: Colors.green,
          ),
        );
        _loadExpenses();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.receipt), text: 'Expenses'),
            Tab(icon: Icon(Icons.category), text: 'Categories'),
            Tab(icon: Icon(Icons.account_balance_wallet), text: 'Budgets'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.assessment),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExpenseReportScreen()),
              );
            },
            tooltip: 'Reports',
          ),
          IconButton(
            icon: const Icon(Icons.approval),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PendingApprovalsScreen()),
              );
            },
            tooltip: 'Pending Approvals',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to add expense screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add expense feature coming soon')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? CustomErrorWidget(
                  message: _errorMessage!,
                  onRetry: _loadExpenses,
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // Expenses Tab
                    SmartRefresher(
                      controller: _refreshController,
                      onRefresh: _onRefresh,
                      child: Column(
                        children: [
                          // Summary Card
                          Card(
                            margin: const EdgeInsets.all(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Total Expenses',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    Formatters.formatCurrency(_getTotalExpenses()),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${_expenses.length} expenses',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Expenses List
                          Expanded(
                            child: _expenses.isEmpty
                                ? const Center(
                                    child: Text('No expenses found'),
                                  )
                                : ListView.builder(
                                    itemCount: _expenses.length,
                                    itemBuilder: (context, index) {
                                      final expense = _expenses[index];
                                      return Card(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: expense.isApproved
                                                ? Colors.green
                                                : expense.isPending
                                                    ? Colors.orange
                                                    : Colors.red,
                                            child: const Icon(Icons.receipt, color: Colors.white),
                                          ),
                                          title: Text(expense.description),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(expense.categoryName),
                                              Text(
                                                Formatters.formatDate(expense.expenseDate),
                                                style: const TextStyle(fontSize: 12),
                                              ),
                                            ],
                                          ),
                                          trailing: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                Formatters.formatCurrency(expense.amount),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (expense.hasReceipt)
                                                const Icon(
                                                  Icons.attach_file,
                                                  size: 16,
                                                  color: Colors.green,
                                                ),
                                            ],
                                          ),
                                          onTap: () {
                                            // TODO: Navigate to expense detail screen
                                          },
                                          onLongPress: () {
                                            _showExpenseActions(context, expense);
                                          },
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                    // Categories Tab
                    _buildCategoriesTab(),
                    // Budgets Tab
                    _buildBudgetsTab(),
                  ],
                ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  void _showExpenseActions(BuildContext context, Expense expense) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text('Upload Receipt'),
              onTap: () {
                Navigator.pop(context);
                _showReceiptUpload(expense);
              },
            ),
            if (expense.approvalStatus == 'NOT_REQUIRED' || expense.approvalStatus == 'DRAFT')
              ListTile(
                leading: const Icon(Icons.approval),
                title: const Text('Submit for Approval'),
                onTap: () {
                  Navigator.pop(context);
                  _submitForApproval(expense);
                },
              ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to expense detail screen
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesTab() {
    return _categories.isEmpty
        ? const Center(child: Text('No categories found'))
        : ListView.builder(
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: category.color != null
                        ? Color(int.parse(category.color!.replaceFirst('#', '0xFF')))
                        : Colors.blue,
                    child: Text(
                      category.icon ?? category.name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(category.name),
                  subtitle: Text(
                    category.description ?? 'No description',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Formatters.formatCurrency(category.totalExpenses),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${category.expenseCount} expenses',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  Widget _buildBudgetsTab() {
    return _budgets.isEmpty
        ? const Center(child: Text('No budgets found'))
        : ListView.builder(
            itemCount: _budgets.length,
            itemBuilder: (context, index) {
              final budget = _budgets[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: budget.isOverBudget
                        ? Colors.red
                        : budget.isNearLimit
                            ? Colors.orange
                            : Colors.green,
                    child: const Icon(Icons.account_balance_wallet, color: Colors.white),
                  ),
                  title: Text(budget.categoryName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Period: ${budget.periodType}'),
                      Text(
                        '${budget.percentageUsed.toStringAsFixed(1)}% used',
                        style: TextStyle(
                          color: budget.isOverBudget ? Colors.red : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Formatters.formatCurrency(budget.budgetAmount),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Spent: ${Formatters.formatCurrency(budget.spentAmount)}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        'Remaining: ${Formatters.formatCurrency(budget.remainingAmount)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: budget.isOverBudget ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}

