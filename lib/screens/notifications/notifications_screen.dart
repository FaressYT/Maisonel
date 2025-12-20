import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../models/notification.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = AppNotification.getMockNotifications();

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Theme.of(context).hintColor,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No notifications yet',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return ListTile(
                  tileColor: notification.isRead
                      ? null
                      : AppColors.primary.withOpacity(0.05),
                  leading: CircleAvatar(
                    backgroundColor: _getIconColor(
                      notification.type,
                    ).withOpacity(0.1),
                    child: Icon(
                      _getIcon(notification.type),
                      color: _getIconColor(notification.type),
                      size: 20,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(notification.date),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                  onTap: () {
                    // Mark as read or navigate details
                  },
                );
              },
            ),
    );
  }

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.orderUpdate:
        return Icons.shopping_bag_outlined;
      case NotificationType.message:
        return Icons.message_outlined;
      case NotificationType.promotion:
        return Icons.local_offer_outlined;
      case NotificationType.system:
        return Icons.info_outline;
    }
  }

  Color _getIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.orderUpdate:
        return AppColors.success;
      case NotificationType.message:
        return AppColors.primary;
      case NotificationType.promotion:
        return Colors.orange;
      case NotificationType.system:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
