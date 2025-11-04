import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../models/income_source.dart';
import '../../services/data_service.dart';
import '../../utils/formatters.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/theme.dart';
import '../../config/app_config.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/skeleton_loader.dart';
import 'add_edit_income_source_dialog.dart';

class IncomeSourcesScreen extends StatefulWidget {
  const IncomeSourcesScreen({super.key});

  @override
  State<IncomeSourcesScreen> createState() => _IncomeSourcesScreenState();
}

class _IncomeSourcesScreenState extends State<IncomeSourcesScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  List<IncomeSource> _incomeSources = [];
  double _totalMonthlyIncome = 0.0;
  int _totalSources = 0;
  int _totalActiveSources = 0;
  bool _isLoading = true;
  String? _errorMessage;
  
  // Filter states
  String? _selectedCategory;
  String? _selectedFrequency;
  bool _showActiveOnly = true;
  List<String> _availableCategories = [];
  List<String> _availableFrequencies = [];

  @override
  void initState() {
    super.initState();
    _loadIncomeSources();
    _loadCategoriesAndFrequencies();
  }

  Future<void> _loadCategoriesAndFrequencies() async {
    try {
      final categories = await DataService().getAvailableCategories();
      final frequencies = await DataService().getAvailableFrequencies();
      setState(() {
        _availableCategories = categories;
        _availableFrequencies = frequencies;
      });
    } catch (e) {
      // Silent fail - filters will work with empty lists
    }
  }

  Future<void> _loadIncomeSources() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<IncomeSource> sources;
      double totalIncome = 0.0;

      // If filters are active, use filtered endpoints
      if (_selectedCategory != null) {
        sources = await DataService().getIncomeSourcesByCategory(_selectedCategory!);
        // Calculate total from filtered sources
        totalIncome = sources.fold(0.0, (sum, source) => sum + source.monthlyAmount);
      } else if (_selectedFrequency != null) {
        sources = await DataService().getIncomeSourcesByFrequency(_selectedFrequency!);
        totalIncome = sources.fold(0.0, (sum, source) => sum + source.monthlyAmount);
      } else {
        // Get all with summary
        final result = await DataService().getIncomeSources(
          includeSummary: true,
          activeOnly: _showActiveOnly,
        );
        sources = result['incomeSources'] as List<IncomeSource>;
        totalIncome = result['totalMonthlyIncome'] as double;
        _totalSources = result['totalSources'] as int;
        _totalActiveSources = result['totalActiveSources'] as int;
      }

      // Apply active filter locally if needed
      if (_showActiveOnly && (_selectedCategory != null || _selectedFrequency != null)) {
        sources = sources.where((s) => s.isActive).toList();
      }

      setState(() {
        _incomeSources = sources;
        _totalMonthlyIncome = totalIncome;
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
    try {
      await _loadIncomeSources();
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
    }
  }

  Future<void> _showAddIncomeSourceDialog() async {
    final result = await showDialog<IncomeSource>(
      context: context,
      builder: (context) => const AddEditIncomeSourceDialog(),
    );

    if (result != null && mounted) {
      _loadIncomeSources();
      NavigationHelper.showSnackBar(
        context,
        'Income source added successfully',
        backgroundColor: AppTheme.successColor,
      );
    }
  }

  Future<void> _showEditIncomeSourceDialog(IncomeSource incomeSource) async {
    final result = await showDialog<IncomeSource>(
      context: context,
      builder: (context) => AddEditIncomeSourceDialog(incomeSource: incomeSource),
    );

    if (result != null && mounted) {
      _loadIncomeSources();
      NavigationHelper.showSnackBar(
        context,
        'Income source updated successfully',
        backgroundColor: AppTheme.successColor,
      );
    }
  }

  Future<void> _deleteIncomeSource(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Income Source'),
        content: const Text('Are you sure you want to delete this income source?'),
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

    if (confirmed == true && mounted) {
      final success = await DataService().deleteIncomeSource(id);
      if (success && mounted) {
        NavigationHelper.showSnackBar(
          context,
          'Income source deleted successfully',
          backgroundColor: AppTheme.successColor,
        );
        _loadIncomeSources();
      } else if (mounted) {
        NavigationHelper.showSnackBar(
          context,
          'Failed to delete income source',
          backgroundColor: AppTheme.errorColor,
        );
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedFrequency = null;
    });
    _loadIncomeSources();
  }

  String _formatFrequency(String frequency) {
    switch (frequency) {
      case 'WEEKLY':
        return 'Weekly';
      case 'BI_WEEKLY':
        return 'Bi-Weekly';
      case 'MONTHLY':
        return 'Monthly';
      case 'QUARTERLY':
        return 'Quarterly';
      case 'ANNUALLY':
        return 'Annually';
      default:
        return frequency;
    }
  }

  String _formatCategory(String? category) {
    if (category == null) return 'Other';
    switch (category) {
      case 'PRIMARY':
        return 'Primary';
      case 'PASSIVE':
        return 'Passive';
      case 'BUSINESS':
        return 'Business';
      case 'SIDE_HUSTLE':
        return 'Side Hustle';
      case 'INVESTMENT':
        return 'Investment';
      case 'RENTAL':
        return 'Rental';
      case 'OTHER':
        return 'Other';
      default:
        return category;
    }
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'PRIMARY':
        return AppTheme.primaryColor;
      case 'PASSIVE':
        return AppTheme.successColor;
      case 'BUSINESS':
        return Colors.blue;
      case 'SIDE_HUSTLE':
        return Colors.orange;
      case 'INVESTMENT':
        return Colors.purple;
      case 'RENTAL':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  Widget _buildFilterItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.primaryColor.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? AppTheme.primaryColor : Colors.grey.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownMenuItem({
    required String label,
    required bool isSelected,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          if (isSelected)
            Icon(
              Icons.check_circle,
              color: AppTheme.primaryColor,
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    if (_availableCategories.isEmpty && _availableFrequencies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              if (_selectedCategory != null || _selectedFrequency != null)
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Category and Frequency Dropdowns in same row
          Row(
            children: [
              // Category Dropdown
              if (_availableCategories.isNotEmpty)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      hint: const Text('All Category'),
                      isExpanded: true,
                      underline: Container(),
                      icon: const Icon(Icons.arrow_drop_down, size: 20),
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                      ),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      selectedItemBuilder: (context) {
                        return [
                          const Text('All Category'),
                          ..._availableCategories.map((category) => Text(_formatCategory(category))),
                        ];
                      },
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: _buildDropdownMenuItem(
                            label: 'All',
                            isSelected: _selectedCategory == null,
                          ),
                        ),
                        ..._availableCategories.map((category) {
                          final isSelected = _selectedCategory == category;
                          return DropdownMenuItem<String>(
                            value: category,
                            child: _buildDropdownMenuItem(
                              label: _formatCategory(category),
                              isSelected: isSelected,
                            ),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                          _selectedFrequency = null; // Clear frequency when category selected
                        });
                        _loadIncomeSources();
                      },
                    ),
                  ),
                ),
              if (_availableCategories.isNotEmpty && _availableFrequencies.isNotEmpty)
                const SizedBox(width: 12),
              // Frequency Dropdown
              if (_availableFrequencies.isNotEmpty)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedFrequency,
                      hint: const Text('All Frequency'),
                      isExpanded: true,
                      underline: Container(),
                      icon: const Icon(Icons.arrow_drop_down, size: 20),
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                      ),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      selectedItemBuilder: (context) {
                        return [
                          const Text('All Frequency'),
                          ..._availableFrequencies.map((frequency) => Text(_formatFrequency(frequency))),
                        ];
                      },
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: _buildDropdownMenuItem(
                            label: 'All',
                            isSelected: _selectedFrequency == null,
                          ),
                        ),
                        ..._availableFrequencies.map((frequency) {
                          final isSelected = _selectedFrequency == frequency;
                          return DropdownMenuItem<String>(
                            value: frequency,
                            child: _buildDropdownMenuItem(
                              label: _formatFrequency(frequency),
                              isSelected: isSelected,
                            ),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedFrequency = value;
                          _selectedCategory = null; // Clear category when frequency selected
                        });
                        _loadIncomeSources();
                      },
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Switch(
                value: _showActiveOnly,
                onChanged: (value) {
                  setState(() {
                    _showActiveOnly = value;
                  });
                  _loadIncomeSources();
                },
              ),
              const Text(
                'Show active only',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'PRIMARY':
        return Icons.work_outline;
      case 'PASSIVE':
        return Icons.trending_up_outlined;
      case 'BUSINESS':
        return Icons.business_outlined;
      case 'SIDE_HUSTLE':
        return Icons.handyman_outlined;
      case 'INVESTMENT':
        return Icons.show_chart_outlined;
      case 'RENTAL':
        return Icons.home_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  IconData _getFrequencyIcon(String frequency) {
    switch (frequency) {
      case 'WEEKLY':
        return Icons.date_range_outlined;
      case 'BI_WEEKLY':
        return Icons.calendar_view_week_outlined;
      case 'MONTHLY':
        return Icons.calendar_month_outlined;
      case 'QUARTERLY':
        return Icons.event_outlined;
      case 'ANNUALLY':
        return Icons.event_note_outlined;
      default:
        return Icons.calendar_today_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddIncomeSourceDialog,
        backgroundColor: const Color(0xFF10B981),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Header Section with Green Background and Curved Edges
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Income Sources',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Body Content
          Expanded(
            child: _isLoading
                ? SkeletonList(itemCount: 5)
                : _errorMessage != null
                    ? ErrorDisplay(
                        message: _errorMessage!,
                        onRetry: _loadIncomeSources,
                      )
                    : SmartRefresher(
                        controller: _refreshController,
                        onRefresh: _onRefresh,
                        child: Column(
                          children: [
                      // Summary Card
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Formatters.formatCurrency(_totalMonthlyIncome, symbol: ''),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Total Monthly Income',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            if (_totalSources > 0) ...[
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem(
                                    'Total Sources',
                                    _totalSources.toString(),
                                    Icons.list,
                                  ),
                                  _buildStatItem(
                                    'Active Sources',
                                    _totalActiveSources.toString(),
                                    Icons.check_circle,
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Filters
                      _buildFilterChips(),
                      // Income Sources List
                      Expanded(
                        child: _incomeSources.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.account_balance_wallet_outlined,
                                      size: 64,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'No income sources found',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Tap the + button to add your first income source',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: _incomeSources.length,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                                itemBuilder: (context, index) {
                                  final source = _incomeSources[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 4),
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: InkWell(
                                      onTap: () => _showEditIncomeSourceDialog(source),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            // Icon on the left
                                            Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                color: source.isActive
                                                    ? _getCategoryColor(source.category)
                                                        .withOpacity(0.1)
                                                    : Colors.red.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                source.isActive
                                                    ? Icons.check
                                                    : Icons.close,
                                                color: source.isActive
                                                    ? _getCategoryColor(source.category)
                                                    : Colors.red.shade300,
                                                size: 18,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            // Content on the right
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // Row 1: Name + 3 dots menu
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          source.name,
                                                          style: const TextStyle(
                                                            fontSize: 17,
                                                            fontWeight: FontWeight.bold,
                                                            color: AppTheme.textPrimary,
                                                            height: 1.0,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                          maxLines: 1,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      // Actions
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 2),
                                                        child: SizedBox(
                                                          height: 20,
                                                          width: 20,
                                                          child: PopupMenuButton(
                                                            icon: const Icon(Icons.more_vert, size: 16),
                                                            constraints: const BoxConstraints(),
                                                            padding: EdgeInsets.zero,
                                                            splashRadius: 16,
                                                            iconSize: 16,
                                                        itemBuilder: (context) => [
                                                          PopupMenuItem(
                                                            child: const Row(
                                                              children: [
                                                                Icon(Icons.edit, size: 16),
                                                                SizedBox(width: 8),
                                                                Text('Edit'),
                                                              ],
                                                            ),
                                                            onTap: () {
                                                              Future.delayed(
                                                                const Duration(milliseconds: 100),
                                                                () => _showEditIncomeSourceDialog(source),
                                                              );
                                                            },
                                                          ),
                                                          PopupMenuItem(
                                                            child: const Row(
                                                              children: [
                                                                Icon(Icons.delete, size: 18, color: AppTheme.errorColor),
                                                                SizedBox(width: 8),
                                                                Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
                                                              ],
                                                            ),
                                                            onTap: () {
                                                              Future.delayed(
                                                                const Duration(milliseconds: 100),
                                                                () => _deleteIncomeSource(source.id),
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  // Row 2: Amount - No spacing
                                                  Text(
                                                    Formatters.formatCurrency(
                                                      source.amount,
                                                      symbol: '',
                                                    ),
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppTheme.textPrimary,
                                                      height: 1.0,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                  const SizedBox(height: 1),
                                                  // Row 3: per / frequency
                                                  Text(
                                                    'per / ${_formatFrequency(source.frequency)}',
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: AppTheme.textSecondary,
                                                      height: 1.2,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  // Row 4: Category (right aligned)
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 5,
                                                          vertical: 1,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: _getCategoryColor(source.category)
                                                              .withOpacity(0.1),
                                                          borderRadius: BorderRadius.circular(4),
                                                        ),
                                                        child: Text(
                                                          _formatCategory(source.category),
                                                          style: TextStyle(
                                                            fontSize: 8,
                                                            color: _getCategoryColor(source.category),
                                                            fontWeight: FontWeight.w600,
                                                            height: 1.2,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
            ),
          ],
        ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 4),
        Text(
          '$value $label',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}