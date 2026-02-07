import 'package:flutter/material.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/theme.dart';
import '../../widgets/bottom_nav_bar_figma.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const _lightGreen = AppTheme.primaryColor;
  static const _headerDark = Color(0xFF093030);
  static const _textGray = Color(0xFF666666);

  String _filter = 'all'; // 'all' | 'unread' | 'read'

  final List<Map<String, dynamic>> _notifications = [
    {
      'type': 'payment_received',
      'title': 'Payment Received',
      'description': 'Salary payment of \$3,500.00 has been credited to your Chase Bank account.',
      'timeAgo': '2 hours ago',
      'isRead': false,
    },
    {
      'type': 'bill_reminder',
      'title': 'Bill Reminder',
      'description': 'Your electricity bill of \$89.99 is due in 3 days.',
      'timeAgo': '5 hours ago',
      'isRead': false,
    },
    {
      'type': 'transaction_alert',
      'title': 'Transaction Alert',
      'description': 'You spent \$125.50 at Land Store Groceries using American Bank card.',
      'timeAgo': '1 day ago',
      'isRead': true,
    },
    {
      'type': 'low_balance',
      'title': 'Low Balance Alert',
      'description': 'Your Wells Fargo account balance is below \$500.',
      'timeAgo': '1 day ago',
      'isRead': true,
    },
  ];

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_filter == 'unread') {
      return _notifications.where((n) => n['isRead'] == false).toList();
    }
    if (_filter == 'read') {
      return _notifications.where((n) => n['isRead'] == true).toList();
    }
    return List.from(_notifications);
  }

  int get _unreadCount =>
      _notifications.where((n) => n['isRead'] == false).length;

  void _markAsRead(int index) {
    final notification = _filteredNotifications[index];
    final listIndex =
        _notifications.indexWhere((n) => identical(n, notification));
    if (listIndex >= 0) {
      setState(() {
        _notifications[listIndex]['isRead'] = true;
      });
    }
  }

  Widget _buildNotificationIcon(String type) {
    IconData iconData;
    Color bgColor;
    switch (type) {
      case 'payment_received':
        iconData = Icons.attach_money_rounded;
        bgColor = _lightGreen;
        break;
      case 'bill_reminder':
        iconData = Icons.notifications;
        bgColor = const Color(0xFFFFB74D); // yellow/orange
        break;
      case 'transaction_alert':
        iconData = Icons.credit_card_rounded;
        bgColor = const Color(0xFF64B5F6); // blue
        break;
      case 'low_balance':
        iconData = Icons.error_outline_rounded;
        bgColor = const Color(0xFFE57373); // red
        break;
      default:
        iconData = Icons.notifications;
        bgColor = _lightGreen;
    }
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: Colors.white, size: 22),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
    final isUnread = notification['isRead'] == false;
    final type = (notification['type'] as String?) ?? 'unknown';
    final title = (notification['title'] as String?) ?? '';
    final description = (notification['description'] as String?) ?? '';
    final timeAgo = (notification['timeAgo'] as String?) ?? '';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _lightGreen.withOpacity(0.4), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNotificationIcon(type),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: const BoxDecoration(
                              color: _lightGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _headerDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: _textGray,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: _textGray.withOpacity(0.8),
                      ),
                    ),
                    if (isUnread) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => _markAsRead(index),
                          style: TextButton.styleFrom(
                            backgroundColor: _lightGreen.withOpacity(0.5),
                            foregroundColor: _headerDark,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Mark as read',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _unreadCount;
    final filtered = _filteredNotifications;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavBarFigma(currentIndex: 0),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Header - light green with subtle shapes
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              decoration: const BoxDecoration(
                color: _lightGreen,
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _HeaderShapesPainter(),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                              child: const Icon(
                                Icons.chevron_left,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Notifications',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (unreadCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: _headerDark.withOpacity(0.3),
                                    width: 1),
                              ),
                              child: Text(
                                '$unreadCount',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _headerDark,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Filter buttons
                      Row(
                        children: [
                          _buildFilterChip('All', _filter == 'all'),
                          const SizedBox(width: 10),
                          _buildFilterChip('Unread', _filter == 'unread'),
                          const SizedBox(width: 10),
                          _buildFilterChip('Read', _filter == 'read'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        _filter == 'all'
                            ? 'No notifications'
                            : 'No ${_filter} notifications',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: _textGray,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        return _buildNotificationCard(
                            filtered[index], index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() {
        _filter = label.toLowerCase();
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(24),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? _headerDark : _headerDark.withOpacity(0.8),
          ),
        ),
      ),
    );
  }
}

class _HeaderShapesPainter extends CustomPainter {
  static const _lightGreen = AppTheme.primaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..style = PaintingStyle.fill;
    // Subtle circles
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.3),
      50,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.6),
      35,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.2),
      25,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
