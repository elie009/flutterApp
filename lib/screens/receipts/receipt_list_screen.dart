import 'package:flutter/material.dart';
import '../../models/receipt.dart';
import '../../services/data_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/loading_indicator.dart';
import 'receipt_detail_dialog.dart';
import 'receipt_match_dialog.dart';

class ReceiptListScreen extends StatefulWidget {
  const ReceiptListScreen({super.key});

  @override
  State<ReceiptListScreen> createState() => _ReceiptListScreenState();
}

class _ReceiptListScreenState extends State<ReceiptListScreen> {
  final DataService _dataService = DataService();
  List<Receipt> _receipts = [];
  bool _isLoading = true;
  String? _error;
  String _searchText = '';
  int _page = 1;
  final int _limit = 20;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadReceipts();
  }

  Future<void> _loadReceipts({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _page = 1;
        _receipts.clear();
        _hasMore = true;
      });
    }

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final receipts = await _dataService.getReceipts(
        searchText: _searchText.isEmpty ? null : _searchText,
        page: _page,
        limit: _limit,
      );

      setState(() {
        if (refresh) {
          _receipts = receipts;
        } else {
          _receipts.addAll(receipts);
        }
        _hasMore = receipts.length == _limit;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading receipts: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteReceipt(String receiptId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Receipt'),
        content: const Text('Are you sure you want to delete this receipt?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _dataService.deleteReceipt(receiptId);
        setState(() {
          _receipts.removeWhere((r) => r.id == receiptId);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Receipt deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting receipt: $e')),
          );
        }
      }
    }
  }

  Future<void> _findMatches(Receipt receipt) async {
    try {
      final matches = await _dataService.findMatchingExpenses(receipt.id);
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => ReceiptMatchDialog(
            receipt: receipt,
            matches: matches,
            onLink: (expenseId) async {
              try {
                await _dataService.linkReceiptToExpense(receipt.id, expenseId);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Receipt linked to expense')),
                  );
                  _loadReceipts(refresh: true);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error linking receipt: $e')),
                  );
                }
              }
            },
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error finding matches: $e')),
        );
      }
    }
  }

  void _showDetails(Receipt receipt) {
    showDialog(
      context: context,
      builder: (context) => ReceiptDetailDialog(receipt: receipt),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Receipts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadReceipts(refresh: true),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search receipts...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
              onSubmitted: (_) => _loadReceipts(refresh: true),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_error!),
                ),
              ),
            ),
          Expanded(
            child: _isLoading && _receipts.isEmpty
                ? const LoadingIndicator()
                : _receipts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              'No receipts found',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Upload your first receipt to get started',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _loadReceipts(refresh: true),
                        child: ListView.builder(
                          itemCount: _receipts.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _receipts.length) {
                              return Padding(
                                padding: const EdgeInsets.all(16),
                                child: Center(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _page++;
                                      });
                                      _loadReceipts();
                                    },
                                    child: const Text('Load More'),
                                  ),
                                ),
                              );
                            }

                            final receipt = _receipts[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: ListTile(
                                leading: receipt.thumbnailUrl != null
                                    ? Image.network(
                                        receipt.thumbnailUrl!,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.receipt),
                                      )
                                    : const Icon(Icons.receipt, size: 40),
                                title: Text(
                                  receipt.extractedMerchant ?? receipt.originalFileName ?? 'Receipt',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (receipt.extractedAmount != null)
                                      Text(
                                        formatCurrency(receipt.extractedAmount!),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    if (receipt.extractedDate != null)
                                      Text(
                                        formatDate(receipt.extractedDate!),
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    Row(
                                      children: [
                                        Chip(
                                          label: Text(
                                            receipt.isOcrProcessed ? 'Processed' : 'Processing',
                                          ),
                                          backgroundColor: receipt.isOcrProcessed
                                              ? Colors.green.shade100
                                              : Colors.orange.shade100,
                                          labelStyle: TextStyle(
                                            color: receipt.isOcrProcessed
                                                ? Colors.green.shade700
                                                : Colors.orange.shade700,
                                            fontSize: 10,
                                          ),
                                        ),
                                        if (receipt.expenseId != null)
                                          Chip(
                                            label: const Text('Linked'),
                                            backgroundColor: Colors.blue.shade100,
                                            labelStyle: TextStyle(
                                              color: Colors.blue.shade700,
                                              fontSize: 10,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton(
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'view',
                                      child: Row(
                                        children: [
                                          Icon(Icons.visibility),
                                          SizedBox(width: 8),
                                          Text('View Details'),
                                        ],
                                      ),
                                    ),
                                    if (receipt.isOcrProcessed)
                                      const PopupMenuItem(
                                        value: 'match',
                                        child: Row(
                                          children: [
                                            Icon(Icons.auto_awesome),
                                            SizedBox(width: 8),
                                            Text('Find Matches'),
                                          ],
                                        ),
                                      ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Delete', style: TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    switch (value) {
                                      case 'view':
                                        _showDetails(receipt);
                                        break;
                                      case 'match':
                                        _findMatches(receipt);
                                        break;
                                      case 'delete':
                                        _deleteReceipt(receipt.id);
                                        break;
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/receipts/upload');
          if (result == true) {
            _loadReceipts(refresh: true);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

