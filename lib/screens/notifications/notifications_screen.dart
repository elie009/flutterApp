import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../models/notification.dart';
import '../../services/data_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_widget.dart';
import '../../utils/theme.dart';
import '../../widgets/bottom_nav_bar.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final notifications = await DataService().getNotifications(
        status: _selectedStatus,
        limit: 50,
      );
      setState(() {
        _notifications = notifications;
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
    await _loadNotifications();
    _refreshController.refreshCompleted();
  }

  Future<void> _markAsRead(String notificationId) async {
    await DataService().markNotificationAsRead(notificationId);
    _loadNotifications();
  }

  void _filterByStatus(String? status) {
    setState(() {
      _selectedStatus = status;
    });
    _loadNotifications();
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'PAYMENT_DUE':
      case 'BILL_OVERDUE':
        return AppTheme.errorColor;
      case 'LOAN_APPROVED':
        return AppTheme.successColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'PAYMENT_DUE':
      case 'BILL_OVERDUE':
        return Icons.warning;
      case 'LOAN_APPROVED':
        return Icons.check_circle;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedStatus == null,
                  onSelected: (_) => _filterByStatus(null),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Unread'),
                  selected: _selectedStatus == 'unread',
                  onSelected: (_) => _filterByStatus('unread'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Read'),
                  selected: _selectedStatus == 'read',
                  onSelected: (_) => _filterByStatus('read'),
                ),
              ],
            ),
          ),
          // Notifications List
          Expanded(
            child: _isLoading && _notifications.isEmpty
                ? const LoadingIndicator(message: 'Loading notifications...')
                : _errorMessage != null && _notifications.isEmpty
                    ? ErrorDisplay(
                        message: _errorMessage!,
                        onRetry: _loadNotifications,
                      )
                    : SmartRefresher(
                        controller: _refreshController,
                        onRefresh: _onRefresh,
                        child: _notifications.isEmpty
                            ? const Center(
                                child: Text(
                                  'No notifications',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _notifications.length,
                                itemBuilder: (context, index) {
                                  final notification = _notifications[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                    color: notification.isRead
                                        ? null
                                        : Colors.blue.shade50,
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            _getNotificationColor(
                                          notification.type,
                                        ),
                                        child: Icon(
                                          _getNotificationIcon(
                                            notification.type,
                                          ),
                                          color: Colors.white,
                                        ),
                                      ),
                                      title: Text(
                                        notification.title,
                                        style: TextStyle(
                                          fontWeight: notification.isRead
                                              ? FontWeight.normal
                                              : FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text(notification.message),
                                          const SizedBox(height: 4),
                                          Text(
                                            Formatters.formatDateTime(
                                              notification.createdAt,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: notification.isRead
                                          ? null
                                          : IconButton(
                                              icon: const Icon(Icons.done),
                                              onPressed: () =>
                                                  _markAsRead(notification.id),
                                            ),
                                      onTap: () {
                                        if (!notification.isRead) {
                                          _markAsRead(notification.id);
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}

