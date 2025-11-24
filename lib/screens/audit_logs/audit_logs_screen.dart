import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/audit_log.dart';
import '../../services/data_service.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_widget.dart' as error_widget;

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({Key? key}) : super(key: key);

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  final DataService _dataService = DataService();
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  PaginatedAuditLogs? _paginatedLogs;
  AuditLogSummary? _summary;

  // Filters
  AuditLogQuery _query = AuditLogQuery();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedAction;
  String? _selectedEntityType;
  String? _selectedLogType;
  String? _selectedSeverity;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      _query.searchTerm = _searchController.text.isEmpty ? null : _searchController.text;
      _query.action = _selectedAction;
      _query.entityType = _selectedEntityType;
      _query.logType = _selectedLogType;
      _query.severity = _selectedSeverity;
      _query.startDate = _startDate;
      _query.endDate = _endDate;

      final logs = await _dataService.getAuditLogs(_query);
      final summary = await _dataService.getAuditLogSummary(
        startDate: _startDate,
        endDate: _endDate,
      );

      setState(() {
        _paginatedLogs = logs;
        _summary = summary;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _paginatedLogs == null) return;
    if (_paginatedLogs!.page >= _paginatedLogs!.totalPages) return;

    setState(() {
      _loadingMore = true;
    });

    try {
      final nextQuery = AuditLogQuery(
        userId: _query.userId,
        action: _selectedAction,
        entityType: _selectedEntityType,
        logType: _selectedLogType,
        severity: _selectedSeverity,
        startDate: _startDate,
        endDate: _endDate,
        searchTerm: _searchController.text.isEmpty ? null : _searchController.text,
        page: _paginatedLogs!.page + 1,
        pageSize: _query.pageSize,
        sortBy: _query.sortBy,
        sortOrder: _query.sortOrder,
      );

      final logs = await _dataService.getAuditLogs(nextQuery);

      setState(() {
        _paginatedLogs = PaginatedAuditLogs(
          logs: [..._paginatedLogs!.logs, ...logs.logs],
          totalCount: logs.totalCount,
          page: logs.page,
          pageSize: logs.pageSize,
          totalPages: logs.totalPages,
        );
        _loadingMore = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loadingMore = false;
      });
    }
  }

  void _showLogDetails(AuditLog log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Audit Log Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Date/Time', DateFormat('yyyy-MM-dd HH:mm:ss').format(log.createdAt)),
              _buildDetailRow('User', log.userEmail ?? log.userId),
              _buildDetailRow('Action', log.action),
              _buildDetailRow('Entity Type', log.entityType),
              if (log.entityId != null) _buildDetailRow('Entity ID', log.entityId!),
              if (log.entityName != null) _buildDetailRow('Entity Name', log.entityName!),
              _buildDetailRow('Log Type', log.logType),
              if (log.severity != null) _buildDetailRow('Severity', log.severity!),
              _buildDetailRow('Description', log.description),
              if (log.ipAddress != null) _buildDetailRow('IP Address', log.ipAddress!),
              if (log.requestPath != null) _buildDetailRow('Request Path', log.requestPath!),
              if (log.complianceType != null) _buildDetailRow('Compliance Type', log.complianceType!),
              if (log.oldValues != null && log.oldValues!.isNotEmpty)
                _buildDetailRow('Old Values', log.oldValues.toString()),
              if (log.newValues != null && log.newValues!.isNotEmpty)
                _buildDetailRow('New Values', log.newValues.toString()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
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
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(String? severity) {
    switch (severity) {
      case 'CRITICAL':
      case 'ERROR':
        return Colors.red;
      case 'WARNING':
        return Colors.orange;
      case 'INFO':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getLogTypeIcon(String logType) {
    switch (logType) {
      case 'USER_ACTIVITY':
        return Icons.event;
      case 'SYSTEM_EVENT':
        return Icons.assessment;
      case 'SECURITY_EVENT':
        return Icons.security;
      case 'COMPLIANCE_EVENT':
        return Icons.verified_user;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: LoadingIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Audit Logs')),
        body: error_widget.ErrorWidget(
          message: _error!,
          onRetry: _loadData,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Cards
          if (_summary != null)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Total',
                      _summary!.totalLogs.toString(),
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSummaryCard(
                      'User Activity',
                      _summary!.userActivityLogs.toString(),
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSummaryCard(
                      'Security',
                      _summary!.securityEventLogs.toString(),
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSummaryCard(
                      'Compliance',
                      _summary!.complianceEventLogs.toString(),
                      Colors.red,
                    ),
                  ),
                ],
              ),
            ),

          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _loadData(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedAction,
                        decoration: const InputDecoration(
                          labelText: 'Action',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All')),
                          const DropdownMenuItem(value: 'CREATE', child: Text('Create')),
                          const DropdownMenuItem(value: 'UPDATE', child: Text('Update')),
                          const DropdownMenuItem(value: 'DELETE', child: Text('Delete')),
                          const DropdownMenuItem(value: 'VIEW', child: Text('View')),
                          const DropdownMenuItem(value: 'LOGIN', child: Text('Login')),
                          const DropdownMenuItem(value: 'LOGOUT', child: Text('Logout')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedAction = value;
                          });
                          _loadData();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedLogType,
                        decoration: const InputDecoration(
                          labelText: 'Log Type',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All')),
                          const DropdownMenuItem(value: 'USER_ACTIVITY', child: Text('User Activity')),
                          const DropdownMenuItem(value: 'SYSTEM_EVENT', child: Text('System Event')),
                          const DropdownMenuItem(value: 'SECURITY_EVENT', child: Text('Security Event')),
                          const DropdownMenuItem(value: 'COMPLIANCE_EVENT', child: Text('Compliance Event')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedLogType = value;
                          });
                          _loadData();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(_startDate == null
                            ? 'Start Date'
                            : DateFormat('yyyy-MM-dd').format(_startDate!)),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _startDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              _startDate = date;
                            });
                            _loadData();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(_endDate == null
                            ? 'End Date'
                            : DateFormat('yyyy-MM-dd').format(_endDate!)),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _endDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              _endDate = date;
                            });
                            _loadData();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear'),
                      onPressed: () {
                        setState(() {
                          _selectedAction = null;
                          _selectedEntityType = null;
                          _selectedLogType = null;
                          _selectedSeverity = null;
                          _startDate = null;
                          _endDate = null;
                          _searchController.clear();
                        });
                        _loadData();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Logs List
          Expanded(
            child: _paginatedLogs == null || _paginatedLogs!.logs.isEmpty
                ? const Center(child: Text('No audit logs found'))
                : ListView.builder(
                    itemCount: _paginatedLogs!.logs.length + (_loadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _paginatedLogs!.logs.length) {
                        return const Center(child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ));
                      }

                      final log = _paginatedLogs!.logs[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: Icon(
                            _getLogTypeIcon(log.logType),
                            color: _getSeverityColor(log.severity),
                          ),
                          title: Text(log.description),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${log.action} • ${log.entityType}'),
                              Text(
                                DateFormat('yyyy-MM-dd HH:mm:ss').format(log.createdAt),
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          trailing: log.severity != null
                              ? Chip(
                                  label: Text(log.severity!),
                                  backgroundColor: _getSeverityColor(log.severity),
                                  labelStyle: const TextStyle(color: Colors.white, fontSize: 10),
                                )
                              : null,
                          onTap: () => _showLogDetails(log),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

