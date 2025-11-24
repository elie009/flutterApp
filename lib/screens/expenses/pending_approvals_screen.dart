import 'package:flutter/material.dart';
import '../../models/expense.dart';
import '../../services/expense_service.dart';
import '../../utils/formatters.dart';
import '../expenses/approval_dialog.dart';

class PendingApprovalsScreen extends StatefulWidget {
  const PendingApprovalsScreen({super.key});

  @override
  State<PendingApprovalsScreen> createState() => _PendingApprovalsScreenState();
}

class _PendingApprovalsScreenState extends State<PendingApprovalsScreen> {
  final ExpenseService _expenseService = ExpenseService();
  List<ExpenseApproval> _approvals = [];
  Map<String, Expense> _expenses = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPendingApprovals();
  }

  Future<void> _loadPendingApprovals() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final approvals = await _expenseService.getPendingApprovals();
      
      // Load expense details for each approval
      final expenses = <String, Expense>{};
      for (var approval in approvals) {
        try {
          final expense = await _expenseService.getExpense(approval.expenseId);
          expenses[approval.expenseId] = expense;
        } catch (e) {
          // Skip if expense not found
        }
      }

      setState(() {
        _approvals = approvals;
        _expenses = expenses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleApproval(ExpenseApproval approval, bool isApprove) async {
    final expense = _expenses[approval.expenseId];
    if (expense == null) return;

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => ApprovalDialog(
        approval: approval,
        expense: expense,
        isApprove: isApprove,
      ),
    );

    if (result != null && mounted) {
      try {
        if (isApprove) {
          await _expenseService.approveExpense(
            approval.id,
            notes: result['notes'],
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expense approved successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          await _expenseService.rejectExpense(
            approval.id,
            result['rejectionReason'] ?? '',
            notes: result['notes'],
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expense rejected'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        _loadPendingApprovals();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Approvals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingApprovals,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPendingApprovals,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _approvals.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                          SizedBox(height: 16),
                          Text(
                            'No pending approvals',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _approvals.length,
                      itemBuilder: (context, index) {
                        final approval = _approvals[index];
                        final expense = _expenses[approval.expenseId];

                        if (expense == null) {
                          return const SizedBox.shrink();
                        }

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: Colors.orange,
                              child: const Icon(Icons.pending, color: Colors.white),
                            ),
                            title: Text(
                              expense.description,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('Amount: ${Formatters.formatCurrency(expense.amount)}'),
                                Text('Category: ${expense.categoryName}'),
                                Text(
                                  'Requested: ${Formatters.formatDate(approval.requestedAt)}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                if (approval.notes != null && approval.notes!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      'Notes: ${approval.notes}',
                                      style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check, color: Colors.green),
                                  onPressed: () => _handleApproval(approval, true),
                                  tooltip: 'Approve',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () => _handleApproval(approval, false),
                                  tooltip: 'Reject',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

