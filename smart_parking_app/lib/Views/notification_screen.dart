
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Booking Confirmed',
      'message':
          'Your parking reservation for Spot A1 on Aug 25, 2023 has been confirmed.',
      'time': DateTime.now().subtract(const Duration(minutes: 5)),
      'type': 'booking',
      'isRead': false,
      'isExpanded': false,
      'details': {
        'Location': 'Downtown Parking Garage',
        'Spot': 'A1 (Ground Floor)',
        'Duration': '2 hours (10:00 AM - 12:00 PM)',
        'Vehicle': 'Toyota Camry (ABC-1234)',
        'Total': 'RS 300.00'
      }
    },
    {
      'id': '2',
      'title': 'Payment Successful',
      'message':
          'Payment of RS 600.00 for parking reservation has been processed successfully.',
      'time': DateTime.now().subtract(const Duration(hours: 2)),
      'type': 'payment',
      'isRead': false,
      'isExpanded': false,
      'details': {
        'Amount': 'RS 600.00',
        'Payment Method': 'Visa ending in 4567',
        'Transaction ID': 'TXN-789456123',
        'Date': 'Aug 24, 2023 at 10:23 AM'
      }
    },
    {
      'id': '3',
      'title': 'Parking Reminder',
      'message': 'Your parking session at Spot B3 will expire in 30 minutes.',
      'time': DateTime.now().subtract(const Duration(hours: 4)),
      'type': 'reminder',
      'isRead': true,
      'isExpanded': false,
      'details': {
        'Location': 'Central Mall Parking',
        'Spot': 'B3 (Level 2)',
        'Expires': '12:30 PM (30 minutes)',
        'Options': 'You can extend your session remotely'
      }
    },
    {
      'id': '4',
      'title': 'New Parking Spot Available',
      'message': 'A parking spot has become available near your location.',
      'time': DateTime.now().subtract(const Duration(days: 1)),
      'type': 'availability',
      'isRead': true,
      'isExpanded': false,
      'details': {
        'Location': '123 Main Street',
        'Distance': '0.3 miles from your current location',
        'Rate': 'RS 50.00 per hour',
        'Availability': 'Next 2 hours'
      }
    },
    {
      'id': '5',
      'title': 'Welcome to Parking Flow',
      'message':
          'Thank you for joining Parking Flow! Start booking your first parking spot.',
      'time': DateTime.now().subtract(const Duration(days: 2)),
      'type': 'welcome',
      'isRead': true,
      'isExpanded': false,
      'details': {
        'Getting Started':
            'Complete your profile to get personalized parking recommendations',
        'Benefits':
            'Reserve spots in advance, contactless payment, and real-time availability',
        'Support': 'Our team is available 24/7 to assist with any questions'
      }
    },
  ];

  void _openNotificationDetails(Map<String, dynamic> notification) {
    // Mark as read when opened
    if (!notification['isRead']) {
      setState(() {
        notification['isRead'] = true;
      });
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationDetailScreen(
          notification: notification,
          onActionPressed: _handleNotificationAction,
        ),
      ),
    );
  }

  void _handleNotificationAction(String action, String notificationId) {
    String message = '';
    switch (action) {
      case 'view_booking':
        message = 'Opening booking details...';
        break;
      case 'add_calendar':
        message = 'Adding to calendar...';
        break;
      case 'view_receipt':
        message = 'Opening receipt...';
        break;
      case 'extend_parking':
        message = 'Extending parking session...';
        break;
      case 'get_directions':
        message = 'Opening directions...';
        break;
      case 'reserve_now':
        message = 'Reserving parking spot...';
        break;
      case 'complete_profile':
        message = 'Opening profile completion...';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }

  void _markAsRead(String id) {
    setState(() {
      final notification = _notifications.firstWhere((n) => n['id'] == id);
      notification['isRead'] = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Marked as read'),
        duration: Duration(seconds: 1),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  void _deleteNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n['id'] == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification deleted'),
        duration: Duration(seconds: 1),
        backgroundColor: Color(0xFFFF5722),
      ),
    );
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Clear All Notifications',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Are you sure you want to clear all notifications?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _notifications.clear();
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All notifications cleared'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Color(0xFFFF5722),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n['isRead']).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2D3748),
        title: Row(
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                color: Color(0xFF2D3748),
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFff6b6b),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Color(0xFF2D3748)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all, color: Color(0xFF4CAF50)),
              onPressed: _markAllAsRead,
              tooltip: 'Mark all as read',
            ),
          IconButton(
            icon: const Icon(Icons.clear_all, color: Color(0xFFFF5722)),
            onPressed: _clearAllNotifications,
            tooltip: 'Clear all',
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: () async {
                // Simulate refresh
                await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return _buildNotificationCard(notification);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.notifications_none,
              size: 60,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No notifications',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You\'re all caught up!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.home),
            label: const Text('Go to Dashboard'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isUnread = !notification['isRead'];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isUnread ? 8 : 2,
      shadowColor: isUnread ? const Color(0xFF2E5AAC).withOpacity(0.3) : Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isUnread
            ? BorderSide(color: const Color(0xFF2E5AAC).withOpacity(0.3), width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _openNotificationDetails(notification),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isUnread
                ? const Color(0xFF2E5AAC).withOpacity(0.05)
                : Colors.white,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced Notification Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification['type']).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: _getNotificationColor(notification['type']).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  _getNotificationIcon(notification['type']),
                  color: _getNotificationColor(notification['type']),
                  size: 28,
                ),
              ),

              const SizedBox(width: 16),

              // Notification Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                              color: isUnread ? Colors.black : Colors.black87,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2E5AAC),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification['message'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getTimeAgo(notification['time']),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            color: Colors.grey[500],
                            size: 22,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          onSelected: (value) {
                            if (value == 'mark_read') {
                              _markAsRead(notification['id']);
                            } else if (value == 'delete') {
                              _deleteNotification(notification['id']);
                            }
                          },
                          itemBuilder: (context) => [
                            if (isUnread)
                              const PopupMenuItem(
                                value: 'mark_read',
                                child: Row(
                                  children: [
                                    Icon(Icons.done, size: 18, color: Color(0xFF4CAF50)),
                                    SizedBox(width: 8),
                                    Text('Mark as read'),
                                  ],
                                ),
                              ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 18, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'booking':
        return Icons.event_available;
      case 'payment':
        return Icons.payment;
      case 'reminder':
        return Icons.alarm;
      case 'availability':
        return Icons.local_parking;
      case 'welcome':
        return Icons.emoji_emotions;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'booking':
        return const Color(0xFF2E5AAC);
      case 'payment':
        return const Color(0xFF4CAF50);
      case 'reminder':
        return const Color(0xFFFFB200);
      case 'availability':
        return const Color(0xFF00B4D8);
      case 'welcome':
        return const Color(0xFFff6b6b);
      default:
        return Colors.grey;
    }
  }

  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}

// Full-screen notification detail screen
class NotificationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> notification;
  final Function(String, String) onActionPressed;

  const NotificationDetailScreen({
    super.key,
    required this.notification,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2D3748),
        title: const Text(
          'Notification Details',
          style: TextStyle(
            color: Color(0xFF2D3748),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF2D3748)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        _getNotificationColor(notification['type']).withOpacity(0.1),
                        _getNotificationColor(notification['type']).withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: _getNotificationColor(notification['type']).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                color: _getNotificationColor(notification['type']).withOpacity(0.4),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              _getNotificationIcon(notification['type']),
                              color: _getNotificationColor(notification['type']),
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification['title'],
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D3748),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _getTimeAgo(notification['time']),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        notification['message'],
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF4A5568),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Details Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...notification['details'].entries.map((entry) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: Color(0xFF4A5568),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  entry.value,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF2D3748),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Actions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildActionButtons(notification['type'], notification['id']),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(String type, String notificationId) {
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF4CAF50),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
    );

    final outlineButtonStyle = OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF4CAF50),
      side: const BorderSide(color: Color(0xFF4CAF50), width: 2),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    switch (type) {
      case 'booking':
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => onActionPressed('view_booking', notificationId),
                style: buttonStyle,
                icon: const Icon(Icons.visibility),
                label: const Text('View Booking Details', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => onActionPressed('add_calendar', notificationId),
                style: outlineButtonStyle,
                icon: const Icon(Icons.calendar_today),
                label: const Text('Add to Calendar', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        );
      case 'payment':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => onActionPressed('view_receipt', notificationId),
            style: buttonStyle,
            icon: const Icon(Icons.receipt),
            label: const Text('View Receipt', style: TextStyle(fontSize: 16)),
          ),
        );
      case 'reminder':
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => onActionPressed('extend_parking', notificationId),
                style: buttonStyle,
                icon: const Icon(Icons.access_time),
                label: const Text('Extend Parking Session', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => onActionPressed('get_directions', notificationId),
                style: outlineButtonStyle,
                icon: const Icon(Icons.directions),
                label: const Text('Get Directions', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        );
      case 'availability':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => onActionPressed('reserve_now', notificationId),
            style: buttonStyle,
            icon: const Icon(Icons.local_parking),
            label: const Text('Reserve Now', style: TextStyle(fontSize: 16)),
          ),
        );
      case 'welcome':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => onActionPressed('complete_profile', notificationId),
            style: buttonStyle,
            icon: const Icon(Icons.person),
            label: const Text('Complete Profile', style: TextStyle(fontSize: 16)),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'booking':
        return Icons.event_available;
      case 'payment':
        return Icons.payment;
      case 'reminder':
        return Icons.alarm;
      case 'availability':
        return Icons.local_parking;
      case 'welcome':
        return Icons.emoji_emotions;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'booking':
        return const Color(0xFF2E5AAC);
      case 'payment':
        return const Color(0xFF4CAF50);
      case 'reminder':
        return const Color(0xFFFFB200);
      case 'availability':
        return const Color(0xFF00B4D8);
      case 'welcome':
        return const Color(0xFFff6b6b);
      default:
        return Colors.grey;
    }
  }

  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}