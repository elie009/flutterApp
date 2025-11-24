import 'package:flutter/material.dart';
import '../../models/receipt.dart';
import '../../utils/formatters.dart';

class ReceiptDetailDialog extends StatelessWidget {
  final Receipt receipt;

  const ReceiptDetailDialog({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Receipt Details',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              if (receipt.thumbnailUrl != null)
                Center(
                  child: Image.network(
                    receipt.thumbnailUrl!,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              const SizedBox(height: 16),
              _buildDetailRow('Merchant', receipt.extractedMerchant ?? 'N/A'),
              _buildDetailRow(
                'Amount',
                receipt.extractedAmount != null
                    ? formatCurrency(receipt.extractedAmount!)
                    : 'N/A',
              ),
              _buildDetailRow(
                'Date',
                receipt.extractedDate != null
                    ? formatDate(receipt.extractedDate!)
                    : 'N/A',
              ),
              _buildDetailRow('File', receipt.originalFileName ?? receipt.fileName),
              _buildDetailRow(
                'File Size',
                '${(receipt.fileSize / 1024 / 1024).toStringAsFixed(2)} MB',
              ),
              _buildDetailRow(
                'Status',
                receipt.isOcrProcessed ? 'Processed' : 'Processing',
              ),
              if (receipt.extractedItems != null && receipt.extractedItems!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Items:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ...receipt.extractedItems!.map((item) => Padding(
                      padding: const EdgeInsets.only(left: 16, top: 8),
                      child: Text(
                        '${item.description} - ${item.price != null ? formatCurrency(item.price!) : "N/A"}',
                      ),
                    )),
              ],
              if (receipt.ocrText != null && receipt.ocrText!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'OCR Text:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    receipt.ocrText!,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

