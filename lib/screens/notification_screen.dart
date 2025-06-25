import 'package:cashcare/models/goal_notification.dart';
import 'package:cashcare/models/navbar_provider.dart';
import 'package:cashcare/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<GoalNotification>> _notificationsFuture;
  late final NotificationService _notificationService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService();
    _refreshNotifications();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BottomNavProvider>(context, listen: false).updateUnreadCount(0);
    });

  }

  void _refreshNotifications() {
    setState(() {
      _notificationsFuture = _notificationService.getNotifications();
    });
  }

  Future<void> _handleMarkAllRead() async {
    setState(() => _isLoading = true);
    try {
      await _notificationService.markAllAsRead();
      _refreshNotifications();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All marked as read'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_done_outlined, size: 26,color: Colors.blue,),
            onPressed: _isLoading ? null : _handleMarkAllRead,
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: FutureBuilder<List<GoalNotification>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading notifications'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No notifications yet', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }

          final notifications = snapshot.data!;
          final unreadCount = notifications.where((n) => !n.isRead).length;
          Provider.of<BottomNavProvider>(context, listen: false).updateUnreadCount(unreadCount);
          notifications.sort((a, b) {
            if (a.isRead == b.isRead) return 0;
            return a.isRead ? 1 : -1;
          });


          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final notification = snapshot.data![index];
              return _NotificationCard(notification: notification);
            },
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final GoalNotification notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = !notification.isRead;
    final iconColor = _getColorForType(notification.type);
    final timeText = DateFormat('h:mm a').format(notification.createdAt.add(const Duration(hours: 5, minutes: 45)));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          if (isUnread)
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIconForType(notification.type),
                        color: iconColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getTitleForType(notification.type),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: Text(
                    notification.message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: Text(
                    timeText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'reminder': return Icons.notifications;
      case 'achievement': return Icons.emoji_events;
      case 'update': return Icons.update;
      case 'warning': return Icons.warning;
      default: return Icons.notifications_active;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'reminder': return Colors.orange;
      case 'achievement': return Colors.green;
      case 'update': return Colors.blue;
      case 'warning': return Colors.red;
      default: return Colors.purple;
    }
  }

  String _getTitleForType(String type) {
    switch (type) {
      case 'reminder': return 'Reminder';
      case 'achievement': return 'Achievement!';
      case 'update': return 'Update';
      case 'warning': return 'Notice';
      default: return 'Notification';
    }
  }
}