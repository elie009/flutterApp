import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../config/app_config.dart';
import '../../models/savings_account.dart';
import '../../models/savings_summary.dart';
import '../../services/data_service.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/theme.dart';
import '../../widgets/bottom_nav_bar_figma.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_widget.dart' as app_error;
import '../../widgets/loading_indicator.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  List<SavingsAccount> _accounts = [];
  SavingsSummary? _summary;
  bool _isLoading = true;
  String? _errorMessage;

  static const _primaryGreen = AppTheme.primaryColor;
  static const _headerDark = Color(0xFF093030);
  static const _textGray = Color(0xFF666666);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final results = await Future.wait([
        DataService().getSavingsAccounts(),
        DataService().getSavingsSummary(),
      ]);
      if (mounted) {
        setState(() {
          _accounts = results[0] as List<SavingsAccount>;
          _summary = results[1] as SavingsSummary;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatCurrency(double value) {
    return '${AppConfig.currencySymbol}${NumberFormat('#,##0.00').format(value)}';
  }

  String _formatSavingsType(String type) {
    return type.replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavBarFigma(currentIndex: 3),
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                bottom: 20,
              ),
              decoration: const BoxDecoration(color: _primaryGreen),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => NavigationHelper.navigateBack(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
                    ),
                  ),
                  const Text(
                    'Savings',
                    style: TextStyle(
                      color: Color(0xFF052224),
                      fontSize: 22,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            // Content
            Expanded(
              child: _isLoading
                  ? const LoadingIndicator(message: 'Loading savings...')
                  : _errorMessage != null
                      ? app_error.ErrorDisplay(
                          message: _errorMessage!,
                          onRetry: _loadData,
                        )
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          color: _primaryGreen,
                          child: _accounts.isEmpty && _summary != null && _summary!.totalSavingsAccounts == 0
                              ? EmptyState(
                                  icon: Icons.savings,
                                  title: 'No savings accounts yet',
                                  message: 'Create a savings goal to start tracking your progress.',
                                  actionLabel: 'Create',
                                  onAction: () => _showAddAccountModal(context),
                                )
                              : SingleChildScrollView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (_summary != null) _buildSummaryCard(),
                                      const SizedBox(height: 24),
                                      const Text(
                                        'Savings Accounts',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: _headerDark,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ..._accounts.map((a) => _SavingsAccountCard(
                                            account: a,
                                            formatCurrency: _formatCurrency,
                                            formatType: _formatSavingsType,
                                            onTap: () => _showAccountOptions(context, a),
                                          )),
                                    ],
                                  ),
                                ),
                          ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: GestureDetector(
          onTap: () => _showAddAccountModal(context),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _primaryGreen,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: _primaryGreen.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSummaryCard() {
    final s = _summary!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _primaryGreen.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primaryGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Savings', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: _textGray)),
                  const SizedBox(height: 4),
                  Text(
                    _formatCurrency(s.totalSavingsBalance),
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.w700, color: _headerDark),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Progress', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: _textGray)),
                  const SizedBox(height: 4),
                  Text(
                    '${s.overallProgressPercentage.toStringAsFixed(1)}%',
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w700, color: _primaryGreen),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${s.activeGoals} active · ${s.completedGoals} completed',
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: _textGray),
                ),
              ),
              Text(
                'This month: ${_formatCurrency(s.thisMonthSaved)}',
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w500, color: _headerDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAccountOptions(BuildContext context, SavingsAccount account) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: _primaryGreen),
              title: const Text('Edit', style: TextStyle(fontFamily: 'Poppins')),
              onTap: () {
                Navigator.pop(ctx);
                _showEditAccountModal(context, account);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete', style: TextStyle(fontFamily: 'Poppins', color: Colors.red)),
              onTap: () async {
                Navigator.pop(ctx);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: const Text('Delete savings account?'),
                    content: Text('${account.accountName} will be permanently deleted.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (confirm == true && mounted) {
                  try {
                    await DataService().deleteSavingsAccount(account.id);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Savings account deleted'), backgroundColor: _primaryGreen));
                      _loadData();
                    }
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAccountModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddSavingsAccountSheet(
        onSaved: () {
          Navigator.pop(ctx);
          _loadData();
        },
        onCancel: () => Navigator.pop(ctx),
      ),
    );
  }

  void _showEditAccountModal(BuildContext context, SavingsAccount account) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddSavingsAccountSheet(
        existing: account,
        onSaved: () {
          Navigator.pop(ctx);
          _loadData();
        },
        onCancel: () => Navigator.pop(ctx),
      ),
    );
  }
}

class _SavingsAccountCard extends StatelessWidget {
  const _SavingsAccountCard({
    required this.account,
    required this.formatCurrency,
    required this.formatType,
    required this.onTap,
  });

  final SavingsAccount account;
  final String Function(double) formatCurrency;
  final String Function(String) formatType;
  final VoidCallback onTap;

  static const _primaryGreen = AppTheme.primaryColor;
  static const _headerDark = Color(0xFF093030);
  static const _textGray = Color(0xFF666666);

  @override
  Widget build(BuildContext context) {
    final progress = account.targetAmount > 0
        ? (account.currentBalance / account.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _primaryGreen.withOpacity(0.3)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _primaryGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.savings, color: _primaryGreen, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.accountName,
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: _headerDark),
                      ),
                      Text(
                        formatType(account.savingsType),
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: _textGray),
                      ),
                    ],
                  ),
                ),
                Text(
                  formatCurrency(account.currentBalance),
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: _primaryGreen),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: _primaryGreen.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(_primaryGreen),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${(progress * 100).toStringAsFixed(0)}% of ${formatCurrency(account.targetAmount)} target',
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: _textGray),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddSavingsAccountSheet extends StatefulWidget {
  final SavingsAccount? existing;
  final VoidCallback onSaved;
  final VoidCallback onCancel;

  const _AddSavingsAccountSheet({this.existing, required this.onSaved, required this.onCancel});

  @override
  State<_AddSavingsAccountSheet> createState() => _AddSavingsAccountSheetState();
}

class _AddSavingsAccountSheetState extends State<_AddSavingsAccountSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _descController = TextEditingController();
  String _savingsType = 'GENERAL';
  DateTime _targetDate = DateTime.now().add(const Duration(days: 365));
  bool _saving = false;
  String? _error;

  static const _savingsTypes = [
    'EMERGENCY', 'VACATION', 'INVESTMENT', 'RETIREMENT', 'EDUCATION',
    'HOME_DOWN_PAYMENT', 'CAR_PURCHASE', 'WEDDING', 'TRAVEL', 'BUSINESS',
    'HEALTH', 'TAX_SAVINGS', 'GENERAL', 'OTHERS',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final e = widget.existing!;
      _nameController.text = e.accountName;
      _targetController.text = e.targetAmount.toStringAsFixed(2);
      _descController.text = e.description ?? '';
      _savingsType = e.savingsType;
      _targetDate = e.targetDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) setState(() => _targetDate = picked);
  }

  Future<void> _submit() async {
    _error = null;
    if (!_formKey.currentState!.validate()) return;
    final target = double.tryParse(_targetController.text.trim());
    if (target == null || target <= 0) {
      setState(() => _error = 'Enter a valid target amount');
      return;
    }
    setState(() => _saving = true);
    try {
      if (widget.existing != null) {
        await DataService().updateSavingsAccount(widget.existing!.id,
          accountName: _nameController.text.trim(),
          savingsType: _savingsType,
          targetAmount: target,
          targetDate: _targetDate,
          description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        );
      } else {
        await DataService().createSavingsAccount(
          accountName: _nameController.text.trim(),
          savingsType: _savingsType,
          targetAmount: target,
          targetDate: _targetDate,
          description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.existing != null ? 'Savings account updated' : 'Savings account created'), backgroundColor: AppTheme.primaryColor),
        );
        widget.onSaved();
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),
              Text(
                widget.existing != null ? 'Edit Savings Account' : 'New Savings Account',
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF093030)),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Account name', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _savingsType,
                decoration: const InputDecoration(labelText: 'Savings type', border: OutlineInputBorder()),
                items: _savingsTypes.map((t) => DropdownMenuItem(value: t, child: Text(t.replaceAll('_', ' ')))).toList(),
                onChanged: (v) => setState(() => _savingsType = v ?? _savingsType),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _targetController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Target amount (${AppConfig.currencySymbol})',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty || double.tryParse(v) == null) ? 'Enter a valid amount' : null,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _saving ? null : _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Target date', border: OutlineInputBorder()),
                  child: Text(DateFormat('MMM d, yyyy').format(_targetDate)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description (optional)', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving ? null : widget.onCancel,
                      style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF093030), side: const BorderSide(color: AppTheme.primaryColor)),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saving ? null : _submit,
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: const Color(0xFF093030)),
                      child: _saving ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
