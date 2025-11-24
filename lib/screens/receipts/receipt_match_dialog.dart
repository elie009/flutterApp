import 'package:flutter/material.dart';
import '../../models/receipt.dart';
import '../../utils/formatters.dart';

class ReceiptMatchDialog extends StatelessWidget {
  final Receipt receipt;
  final List<ExpenseMatch> matches;
  final Function(String expenseId) onLink;

  const ReceiptMatchDialog({
    super.key,
    required this.receipt,
    required this.matches,
    required this.onLink,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Matching Expenses',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            if (matches.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Text('No matching expenses found'),
              )
            else
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final match = matches[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(match.description),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formatCurrency(match.amount),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              '${formatDate(match.expenseDate)} • ${match.category}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Chip(
                              label: Text('${match.matchScore.toStringAsFixed(0)}% Match'),
                              backgroundColor: Colors.green.shade100,
                              labelStyle: TextStyle(
                                color: Colors.green.shade700,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              match.matchReason,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => onLink(match.expenseId),
                          child: const Text('Link'),
                        ),
                      ),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

