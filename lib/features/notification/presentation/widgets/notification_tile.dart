import 'package:flutter/material.dart';
import 'package:jerseyhub/features/notification/domain/entity/notification_entity.dart';

class NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
    this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: notification.read ? Colors.grey.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.read
              ? Colors.grey.shade200
              : Colors.blue.shade200,
          width: notification.read ? 1 : 2,
        ),
        boxShadow: notification.read
            ? null
            : [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: _buildLeadingIcon(),
        title: Text(
          notification.message,
          style: TextStyle(
            fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
            color: notification.read ? Colors.grey.shade700 : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              _formatTime(notification.createdAt),
              style: TextStyle(
                fontSize: 12,
                color:
                    Theme.of(context).textTheme.bodySmall?.color ??
                    Colors.grey.shade500,
              ),
            ),
            if (notification.type != 'order') ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getTypeColor(notification.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  notification.type.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    color: _getTypeColor(notification.type),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: notification.read
            ? null
            : IconButton(
                icon: const Icon(Icons.check_circle_outline),
                onPressed: onMarkAsRead,
                color: Colors.blue,
              ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLeadingIcon() {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case 'order':
        iconData = Icons.shopping_bag;
        iconColor = Colors.blue;
        break;
      case 'promotion':
        iconData = Icons.local_offer;
        iconColor = Colors.orange;
        break;
      case 'alert':
        iconData = Icons.warning;
        iconColor = Colors.red;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(iconData, color: iconColor, size: 20),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'order':
        return Colors.blue;
      case 'promotion':
        return Colors.orange;
      case 'alert':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
