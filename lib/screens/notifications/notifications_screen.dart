import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Mock notifications data
  final List<Map<String, dynamic>> _notifications = [
    {
      'date': 'Today',
      'items': [
        {
          'type': 'reminder',
          'title': 'Reminder!',
          'description': 'Set up your automatic savings to meet your savings goal...',
          'time': '17:00 - April 24',
          'icon': Icons.notifications,
        },
        {
          'type': 'update',
          'title': 'New update',
          'description': 'Set up your automatic savings to meet your savings goal...',
          'time': '17:00 - April 24',
          'icon': Icons.system_update,
        },
      ],
    },
    {
      'date': 'Yesterday',
      'items': [
        {
          'type': 'transaction',
          'title': 'Transactions',
          'description': 'A new transaction has been registered',
          'details': 'Groceries | pantry | -\$100.00',
          'time': '17:00 - April 24',
          'icon': Icons.receipt,
        },
        {
          'type': 'reminder',
          'title': 'Reminder!',
          'description': 'Set up your automatic savings to meet your savings goal...',
          'time': '17:00 - April 24',
          'icon': Icons.notifications,
        },
      ],
    },
    {
      'date': 'This Weekend',
      'items': [
        {
          'type': 'expense_record',
          'title': 'Expense record',
          'description': 'We recommend that you be more attentive to your finances.',
          'time': '17:00 - April 24',
          'icon': Icons.account_balance_wallet,
        },
        {
          'type': 'transaction',
          'title': 'Transactions',
          'description': 'A new transaction has been registered',
          'details': 'Food | Dinner | -\$70.40',
          'time': '17:00 - April 24',
          'icon': Icons.receipt,
        },
      ],
    },
  ];

  Widget _buildNotificationIcon(String type) {
    IconData iconData;
    switch (type) {
      case 'reminder':
        iconData = Icons.notifications;
        break;
      case 'update':
        iconData = Icons.system_update;
        break;
      case 'transaction':
        iconData = Icons.receipt;
        break;
      case 'expense_record':
        iconData = Icons.account_balance_wallet;
        break;
      default:
        iconData = Icons.notifications;
    }

    return Container(
      width: 37,
      height: 37,
      decoration: BoxDecoration(
        color: const Color(0xFF00D09E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        iconData,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            _buildNotificationIcon(notification['type']),

            const SizedBox(width: 20),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    notification['title'],
                    style: const TextStyle(
                      color: Color(0xFF052224),
                      fontSize: 15,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Description
                  Text(
                    notification['description'],
                    style: const TextStyle(
                      color: Color(0xFF052224),
                      fontSize: 14,
                      fontFamily: 'League Spartan',
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  // Transaction details (if available)
                  if (notification['details'] != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      notification['details'],
                      style: const TextStyle(
                        color: Color(0xFF0068FF),
                        fontSize: 11.16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Time
            Text(
              notification['time'],
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF0068FF),
                fontSize: 13,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w300,
                height: 1.15,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSection(String date, List<Map<String, dynamic>> notifications) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header
        Padding(
          padding: const EdgeInsets.only(left: 7, bottom: 10),
          child: Text(
            date,
            style: const TextStyle(
              color: Color(0xFF052224),
              fontSize: 14,
              fontFamily: 'League Spartan',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),

        // Notifications for this date
        ...notifications.map(_buildNotificationItem),

        // Divider
        const SizedBox(height: 20),
        Container(
          width: 357,
          height: 0,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                width: 1.01,
                color: Color(0xFF00D09E),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 430,
        height: 932,
        decoration: const BoxDecoration(
          color: Color(0xFF00D09E),
          borderRadius: BorderRadius.all(Radius.circular(40)),
        ),
        child: Stack(
          children: [
            // Status bar
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: 430,
                height: 32,
                decoration: const BoxDecoration(),
                child: Stack(
                  children: [
                    Positioned(
                      left: 37,
                      top: 9,
                      child: SizedBox(
                        width: 30,
                        height: 14,
                        child: Text(
                          '16:04',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontFamily: 'League Spartan',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Back button
            Positioned(
              left: 38,
              top: 69,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 19,
                  height: 16,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFF1FFF3),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),

            // Title
            const Positioned(
              left: 88,
              top: 65,
              child: SizedBox(
                width: 255,
                child: Text(
                  'Notification',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF093030),
                    fontSize: 20,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    height: 1.10,
                  ),
                ),
              ),
            ),

            // Notification icon
            Positioned(
              left: 364,
              top: 61,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFFDFF7E2),
                  borderRadius: BorderRadius.all(Radius.circular(25.71)),
                ),
                child: Center(
                  child: Container(
                    width: 14.57,
                    height: 18.86,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF093030),
                        width: 1.29,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Notifications list
            Positioned(
              left: 37,
              top: 120,
              child: SizedBox(
                width: 356,
                height: 650,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _notifications.map((section) {
                      return _buildDateSection(
                        section['date'],
                        List<Map<String, dynamic>>.from(section['items']),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            // Bottom Navigation
            Positioned(
              left: 0,
              top: 824,
              width: 430,
              height: 108,
              child: Container(
                padding: const EdgeInsets.fromLTRB(60, 36, 60, 41),
                decoration: const BoxDecoration(
                  color: Color(0xFFDFF7E2),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(70),
                    topRight: Radius.circular(70),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Home icon
                    Container(
                      width: 25,
                      height: 31,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF052224),
                          width: 2,
                        ),
                      ),
                    ),

                    // Analysis icon (active)
                    Stack(
                      children: [
                        Positioned(
                          left: -13,
                          top: -11,
                          child: Container(
                            width: 57,
                            height: 53,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00D09E),
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                        ),
                        Container(
                          width: 31,
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF052224),
                              width: 2,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Transactions icon
                    Container(
                      width: 33,
                      height: 25,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF052224),
                          width: 2,
                        ),
                      ),
                    ),

                    // Categories icon
                    Container(
                      width: 27,
                      height: 23,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF052224),
                          width: 2,
                        ),
                      ),
                    ),

                    // Profile icon
                    Container(
                      width: 22,
                      height: 27,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF052224),
                          width: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}