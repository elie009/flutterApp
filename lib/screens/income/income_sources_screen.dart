import 'package:flutter/material.dart';
import '../../models/income_source.dart';
import '../../services/data_service.dart';
import '../../utils/formatters.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/skeleton_loader.dart';
import '../../utils/theme.dart';

class IncomeSourcesScreen extends StatefulWidget {
  const IncomeSourcesScreen({super.key});

  @override
  State<IncomeSourcesScreen> createState() => _IncomeSourcesScreenState();
}

class _IncomeSourcesScreenState extends State<IncomeSourcesScreen> {
  List<IncomeSource> _incomeSources = [];
  double _totalMonthlyIncome = 0.0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadIncomeSources();
  }

  Future<void> _loadIncomeSources() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await DataService().getIncomeSources(includeSummary: true);
      setState(() {
        _incomeSources = result['incomeSources'] as List<IncomeSource>;
        _totalMonthlyIncome = result['totalMonthlyIncome'] as double;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
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

    if (confirmed == true) {
      final success = await DataService().deleteIncomeSource(id);
      if (success && mounted) {
        NavigationHelper.showSnackBar(
          context,
          'Income source deleted',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Income Sources'),
      ),
      body: _isLoading
          ? SkeletonList(itemCount: 5)
          : _errorMessage != null
              ? ErrorDisplay(
                  message: _errorMessage!,
                  onRetry: _loadIncomeSources,
                )
              : Column(
                  children: [
                    // Summary Card
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Monthly Income',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            Formatters.formatCurrency(_totalMonthlyIncome),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Income Sources List
                    Expanded(
                      child: _incomeSources.isEmpty
                          ? const Center(
                              child: Text(
                                'No income sources found',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _incomeSources.length,
                              itemBuilder: (context, index) {
                                final source = _incomeSources[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: AppTheme.successColor,
                                      child: const Icon(
                                        Icons.attach_money,
                                        color: Colors.white,
                                      ),
                                    ),
                                    title: Text(
                                      source.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (source.company != null)
                                          Text(source.company!),
                                        Text(
                                          '${source.frequency} • ${Formatters.formatCurrency(source.monthlyAmount)}/month',
                                        ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () {
                                            // TODO: Navigate to edit screen
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          color: AppTheme.errorColor,
                                          onPressed: () =>
                                              _deleteIncomeSource(source.id),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add income source screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

