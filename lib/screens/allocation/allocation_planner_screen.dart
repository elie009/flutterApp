import 'package:flutter/material.dart';
import '../../models/allocation.dart';
import '../../services/data_service.dart';
import '../../utils/currency_helper.dart';
import 'package:fl_chart/fl_chart.dart';

class AllocationPlannerScreen extends StatefulWidget {
  const AllocationPlannerScreen({Key? key}) : super(key: key);

  @override
  State<AllocationPlannerScreen> createState() => _AllocationPlannerScreenState();
}

class _AllocationPlannerScreenState extends State<AllocationPlannerScreen> with SingleTickerProviderStateMixin {
  final DataService _dataService = DataService();
  
  late TabController _tabController;
  AllocationPlan? _activePlan;
  List<AllocationTemplate> _templates = [];
  List<AllocationRecommendation> _recommendations = [];
  AllocationChartData? _chartData;
  List<AllocationHistory> _history = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final [plan, templates, recommendations, chartData, history] = await Future.wait([
        _dataService.getActiveAllocationPlan(),
        _dataService.getAllocationTemplates(),
        _dataService.getAllocationRecommendations(),
        Future.value(null), // Will load after plan is available
        _dataService.getAllocationHistory(months: 12),
      ]);

      setState(() {
        _activePlan = plan;
        _templates = templates;
        _recommendations = recommendations;
        _history = history;
      });

      if (plan != null) {
        try {
          final chart = await _dataService.getAllocationChartData(plan.id);
          setState(() {
            _chartData = chart;
          });
        } catch (e) {
          // Chart data is optional
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load allocation data: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _applyTemplate(String templateId, double monthlyIncome) async {
    try {
      final plan = await _dataService.applyAllocationTemplate(templateId, monthlyIncome);
      setState(() {
        _activePlan = plan;
      });
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Template applied successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to apply template: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Allocation Planner'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.assessment), text: 'Plan'),
            Tab(icon: Icon(Icons.pie_chart), text: 'Charts'),
            Tab(icon: Icon(Icons.timeline), text: 'Trends'),
            Tab(icon: Icon(Icons.lightbulb), text: 'Recommendations'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showTemplateDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPlanTab(),
                    _buildChartsTab(),
                    _buildTrendsTab(),
                    _buildRecommendationsTab(),
                  ],
                ),
    );
  }

  Widget _buildPlanTab() {
    if (_activePlan == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assessment, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No active allocation plan'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _showTemplateDialog(),
              child: const Text('Create Plan from Template'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _activePlan!.planName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Monthly Income: ${CurrencyHelper.format(_activePlan!.monthlyIncome)}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (_activePlan!.templateName != null)
                  Text(
                    'Based on: ${_activePlan!.templateName}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ..._activePlan!.categories.map((category) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(category.status),
              child: Text(
                '${category.percentage.toStringAsFixed(0)}%',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            title: Text(category.categoryName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Allocated: ${CurrencyHelper.format(category.allocatedAmount)}'),
                Text('Actual: ${CurrencyHelper.format(category.actualAmount)}'),
                if (category.variance != 0)
                  Text(
                    'Variance: ${CurrencyHelper.format(category.variance)}',
                    style: TextStyle(
                      color: category.variance < 0 ? Colors.red : Colors.green,
                    ),
                  ),
              ],
            ),
            trailing: Chip(
              label: Text(_getStatusLabel(category.status)),
              backgroundColor: _getStatusColor(category.status),
              labelStyle: const TextStyle(color: Colors.white),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildChartsTab() {
    if (_chartData == null || _chartData!.dataPoints.isEmpty) {
      return const Center(child: Text('No chart data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            height: 300,
            child: PieChart(
              PieChartData(
                sections: _chartData!.dataPoints.asMap().entries.map((entry) {
                  final index = entry.key;
                  final point = entry.value;
                  return PieChartSectionData(
                    value: point.allocatedAmount,
                    title: '${point.percentage.toStringAsFixed(0)}%',
                    color: _getColorForIndex(index),
                    radius: 100,
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _chartData!.dataPoints
                    .map((p) => p.allocatedAmount > p.actualAmount ? p.allocatedAmount : p.actualAmount)
                    .reduce((a, b) => a > b ? a : b) * 1.2,
                barGroups: _chartData!.dataPoints.asMap().entries.map((entry) {
                  final index = entry.key;
                  final point = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: point.allocatedAmount,
                        color: Colors.blue,
                        width: 16,
                      ),
                      BarChartRodData(
                        toY: point.actualAmount,
                        color: Colors.green,
                        width: 16,
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < _chartData!.dataPoints.length) {
                          return Text(
                            _chartData!.dataPoints[value.toInt()].categoryName,
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    if (_history.isEmpty) {
      return const Center(child: Text('No trend data available'));
    }

    // Group history by period date
    final groupedHistory = <DateTime, List<AllocationHistory>>{};
    for (var h in _history) {
      final key = DateTime(h.periodDate.year, h.periodDate.month);
      groupedHistory.putIfAbsent(key, () => []).add(h);
    }

    final trendData = groupedHistory.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: trendData.length,
      itemBuilder: (context, index) {
        final entry = trendData[index];
        final totalAllocated = entry.value
            .where((h) => h.categoryId == null)
            .fold<double>(0, (sum, h) => sum + h.allocatedAmount);
        final totalActual = entry.value
            .where((h) => h.categoryId == null)
            .fold<double>(0, (sum, h) => sum + h.actualAmount);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text('${entry.key.month}/${entry.key.year}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Allocated: ${CurrencyHelper.format(totalAllocated)}'),
                Text('Actual: ${CurrencyHelper.format(totalActual)}'),
                Text(
                  'Variance: ${CurrencyHelper.format(totalAllocated - totalActual)}',
                  style: TextStyle(
                    color: (totalAllocated - totalActual) < 0 ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecommendationsTab() {
    if (_recommendations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lightbulb_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No recommendations available'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                if (_activePlan != null) {
                  try {
                    final recs = await _dataService.generateAllocationRecommendations(_activePlan!.id);
                    setState(() {
                      _recommendations = recs;
                    });
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to generate recommendations: ${e.toString()}')),
                      );
                    }
                  }
                }
              },
              child: const Text('Generate Recommendations'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _recommendations.length,
      itemBuilder: (context, index) {
        final rec = _recommendations[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              _getPriorityIcon(rec.priority),
              color: _getPriorityColor(rec.priority),
            ),
            title: Text(rec.title),
            subtitle: Text(rec.message),
            trailing: rec.isApplied
                ? const Icon(Icons.check_circle, color: Colors.green)
                : ElevatedButton(
                    onPressed: () async {
                      try {
                        await _dataService.applyRecommendation(rec.id);
                        await _loadData();
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to apply recommendation: ${e.toString()}')),
                          );
                        }
                      }
                    },
                    child: const Text('Apply'),
                  ),
          ),
        );
      },
    );
  }

  void _showTemplateDialog() {
    showDialog(
      context: context,
      builder: (context) => _TemplateSelectionDialog(
        templates: _templates,
        onTemplateSelected: (templateId, monthlyIncome) {
          _applyTemplate(templateId, monthlyIncome);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'on_track':
        return Colors.green;
      case 'over_budget':
        return Colors.red;
      case 'under_budget':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'on_track':
        return 'On Track';
      case 'over_budget':
        return 'Over Budget';
      case 'under_budget':
        return 'Under Budget';
      default:
        return status;
    }
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];
    return colors[index % colors.length];
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority) {
      case 'urgent':
        return Icons.warning;
      case 'high':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}

class _TemplateSelectionDialog extends StatefulWidget {
  final List<AllocationTemplate> templates;
  final Function(String templateId, double monthlyIncome) onTemplateSelected;

  const _TemplateSelectionDialog({
    required this.templates,
    required this.onTemplateSelected,
  });

  @override
  State<_TemplateSelectionDialog> createState() => _TemplateSelectionDialogState();
}

class _TemplateSelectionDialogState extends State<_TemplateSelectionDialog> {
  String? _selectedTemplateId;
  final _incomeController = TextEditingController();

  @override
  void dispose() {
    _incomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Allocation Template'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _incomeController,
              decoration: const InputDecoration(
                labelText: 'Monthly Income',
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ...widget.templates.map((template) => RadioListTile<String>(
              title: Text(template.name),
              subtitle: Text(template.description ?? ''),
              value: template.id,
              groupValue: _selectedTemplateId,
              onChanged: (value) {
                setState(() {
                  _selectedTemplateId = value;
                });
              },
            )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedTemplateId != null && _incomeController.text.isNotEmpty
              ? () {
                  final income = double.tryParse(_incomeController.text);
                  if (income != null && income > 0) {
                    widget.onTemplateSelected(_selectedTemplateId!, income);
                  }
                }
              : null,
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

