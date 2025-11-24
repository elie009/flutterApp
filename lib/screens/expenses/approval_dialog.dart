import 'package:flutter/material.dart';
import '../../models/expense.dart';

class ApprovalDialog extends StatefulWidget {
  final ExpenseApproval approval;
  final Expense expense;
  final bool isApprove;

  const ApprovalDialog({
    super.key,
    required this.approval,
    required this.expense,
    required this.isApprove,
  });

  @override
  State<ApprovalDialog> createState() => _ApprovalDialogState();
}

class _ApprovalDialogState extends State<ApprovalDialog> {
  final _notesController = TextEditingController();
  final _rejectionReasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _notesController.dispose();
    _rejectionReasonController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop({
        'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        'rejectionReason': widget.isApprove ? null : _rejectionReasonController.text.trim(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.isApprove ? 'Approve Expense' : 'Reject Expense',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Expense: ${widget.expense.description}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                'Amount: \$${widget.expense.amount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              
              if (!widget.isApprove) ...[
                TextFormField(
                  controller: _rejectionReasonController,
                  decoration: const InputDecoration(
                    labelText: 'Rejection Reason *',
                    hintText: 'Please provide a reason for rejection',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Rejection reason is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: widget.isApprove ? 'Notes (Optional)' : 'Notes (Optional)',
                  hintText: 'Add any additional notes',
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.isApprove ? Colors.green : Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(widget.isApprove ? 'Approve' : 'Reject'),
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

