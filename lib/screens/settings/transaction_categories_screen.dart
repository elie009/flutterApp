import 'package:flutter/material.dart';
import '../../models/transaction_category.dart';
import '../../services/data_service.dart';
import '../../utils/theme.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';

class TransactionCategoriesScreen extends StatefulWidget {
  const TransactionCategoriesScreen({super.key});

  @override
  State<TransactionCategoriesScreen> createState() => _TransactionCategoriesScreenState();
}

class _TransactionCategoriesScreenState extends State<TransactionCategoriesScreen> {
  List<TransactionCategory> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final categories = await DataService().getTransactionCategories(type: _selectedType);
      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
        NavigationHelper.showSnackBar(
          context,
          'Failed to load categories: $e',
          backgroundColor: AppTheme.errorColor,
        );
      }
    }
  }

  Future<void> _deleteCategory(TransactionCategory category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${category.isSystemCategory ? 'System ' : ''}Category'),
        content: Text(
          category.isSystemCategory
              ? 'Are you sure you want to delete this system category "${category.name}"? This action cannot be undone.'
              : 'Are you sure you want to delete "${category.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await DataService().deleteTransactionCategory(category.id);
      if (success && mounted) {
        NavigationHelper.showSnackBar(
          context,
          'Category deleted successfully',
          backgroundColor: AppTheme.successColor,
        );
        _loadCategories();
      } else if (mounted) {
        NavigationHelper.showSnackBar(
          context,
          'Failed to delete category',
          backgroundColor: AppTheme.errorColor,
        );
      }
    }
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  IconData _getIconData(String iconName) {
    // Map icon names to Flutter icons - comprehensive mapping
    final iconMap = {
      'restaurant': Icons.restaurant,
      'restaurant_menu': Icons.restaurant_menu,
      'shopping_cart': Icons.shopping_cart,
      'shopping_bag': Icons.shopping_bag,
      'directions_car': Icons.directions_car,
      'local_gas_station': Icons.local_gas_station,
      'local_hospital': Icons.local_hospital,
      'movie': Icons.movie,
      'home': Icons.home,
      'savings': Icons.savings,
      'school': Icons.school,
      'work': Icons.work,
      'laptop': Icons.laptop,
      'trending_up': Icons.trending_up,
      'attach_money': Icons.attach_money,
      'account_balance': Icons.account_balance,
      'swap_horiz': Icons.swap_horiz,
      'card_giftcard': Icons.card_giftcard,
      'more_horiz': Icons.more_horiz,
      // Additional icons from backend
      'flight': Icons.flight,
      'bolt': Icons.bolt,
      'security': Icons.security,
      'subscriptions': Icons.subscriptions,
    };
    return iconMap[iconName] ?? Icons.category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Categories'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedType = value == 'All' ? null : value;
              });
              _loadCategories();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('All Types')),
              const PopupMenuItem(value: 'EXPENSE', child: Text('Expense')),
              const PopupMenuItem(value: 'INCOME', child: Text('Income')),
              const PopupMenuItem(value: 'TRANSFER', child: Text('Transfer')),
              const PopupMenuItem(value: 'BILL', child: Text('Bill')),
              const PopupMenuItem(value: 'SAVINGS', child: Text('Savings')),
              const PopupMenuItem(value: 'LOAN', child: Text('Loan')),
            ],
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(Icons.filter_list),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error loading categories',
                        style: TextStyle(color: AppTheme.errorColor),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadCategories,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _categories.isEmpty
                  ? const EmptyState(
                      title: 'No Categories',
                      message: 'No categories found',
                      icon: Icons.category,
                    )
                  : ListView.builder(
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: category.color != null
                                    ? _parseColor(category.color!)
                                    : AppTheme.primaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                category.icon != null
                                    ? _getIconData(category.icon!)
                                    : Icons.category,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              category.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('Type: ${category.type}'),
                                if (category.description != null &&
                                    category.description!.isNotEmpty)
                                  Text(
                                    category.description!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    if (category.isSystemCategory)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          'System Category',
                                          style: TextStyle(
                                            color: Colors.orange,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    if (category.transactionCount > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${category.transactionCount} transaction(s)',
                                          style: TextStyle(
                                            color: AppTheme.primaryColor,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              color: AppTheme.errorColor,
                              onPressed: () => _deleteCategory(category),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

