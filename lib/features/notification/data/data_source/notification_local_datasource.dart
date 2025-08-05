import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jerseyhub/features/notification/domain/entity/notification_entity.dart';
import 'package:jerseyhub/features/notification/data/model/notification_api_model.dart';

abstract class NotificationLocalDataSource {
  Future<List<NotificationEntity>> getNotifications(String userId);
  Future<NotificationEntity> addNotification(NotificationEntity notification);
  Future<NotificationEntity> markAsRead(String notificationId);
  Future<void> markAllAsRead(String userId);
  Future<void> clearAllNotifications(String userId);
  Future<void> clearAllNotificationsForUser(String userId);
}

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  static const String _notificationsKey = 'notifications';

  @override
  Future<List<NotificationEntity>> getNotifications(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getStringList(_notificationsKey) ?? [];

    final allNotifications = notificationsJson
        .map(
          (json) => NotificationApiModel.fromJson(jsonDecode(json)).toEntity(),
        )
        .toList();

    // Filter notifications for the specific user
    final userNotifications = allNotifications
        .where((notification) => notification.userId == userId)
        .toList();

    // Sort by creation date (newest first)
    userNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return userNotifications;
  }

  @override
  Future<NotificationEntity> addNotification(
    NotificationEntity notification,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getStringList(_notificationsKey) ?? [];

    // Convert to API model for storage
    final notificationModel = NotificationApiModel.fromEntity(notification);
    final notificationJson = jsonEncode(notificationModel.toJson());

    // Add new notification
    notificationsJson.add(notificationJson);

    // Keep only the last 100 notifications to prevent storage bloat
    if (notificationsJson.length > 100) {
      notificationsJson.removeRange(0, notificationsJson.length - 100);
    }

    await prefs.setStringList(_notificationsKey, notificationsJson);

    print(
      '📱 NotificationLocalDataSource: Added notification: ${notification.message}',
    );
    return notification;
  }

  @override
  Future<NotificationEntity> markAsRead(String notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getStringList(_notificationsKey) ?? [];

    final updatedNotificationsJson = <String>[];
    NotificationEntity? updatedNotification;

    for (final json in notificationsJson) {
      final notificationModel = NotificationApiModel.fromJson(jsonDecode(json));
      final notification = notificationModel.toEntity();

      if (notification.id == notificationId) {
        // Mark as read
        final updatedModel = NotificationApiModel(
          id: notification.id,
          userId: notification.userId,
          message: notification.message,
          read: true,
          type: notification.type,
          metadata: notification.metadata,
          createdAt: notification.createdAt.toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        );
        updatedNotificationsJson.add(jsonEncode(updatedModel.toJson()));
        updatedNotification = updatedModel.toEntity();
      } else {
        updatedNotificationsJson.add(json);
      }
    }

    await prefs.setStringList(_notificationsKey, updatedNotificationsJson);

    if (updatedNotification != null) {
      print(
        '📱 NotificationLocalDataSource: Marked notification as read: $notificationId',
      );
      return updatedNotification;
    } else {
      throw Exception('Notification not found: $notificationId');
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getStringList(_notificationsKey) ?? [];

    final updatedNotificationsJson = <String>[];

    for (final json in notificationsJson) {
      final notificationModel = NotificationApiModel.fromJson(jsonDecode(json));
      final notification = notificationModel.toEntity();

      if (notification.userId == userId) {
        // Mark as read
        final updatedModel = NotificationApiModel(
          id: notification.id,
          userId: notification.userId,
          message: notification.message,
          read: true,
          type: notification.type,
          metadata: notification.metadata,
          createdAt: notification.createdAt.toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        );
        updatedNotificationsJson.add(jsonEncode(updatedModel.toJson()));
      } else {
        updatedNotificationsJson.add(json);
      }
    }

    await prefs.setStringList(_notificationsKey, updatedNotificationsJson);
    print(
      '📱 NotificationLocalDataSource: Marked all notifications as read for user: $userId',
    );
  }

  @override
  Future<void> clearAllNotifications(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getStringList(_notificationsKey) ?? [];

    final updatedNotificationsJson = <String>[];

    for (final json in notificationsJson) {
      final notificationModel = NotificationApiModel.fromJson(jsonDecode(json));
      final notification = notificationModel.toEntity();

      // Keep notifications for other users
      if (notification.userId != userId) {
        updatedNotificationsJson.add(json);
      }
    }

    await prefs.setStringList(_notificationsKey, updatedNotificationsJson);
    print(
      '📱 NotificationLocalDataSource: Cleared all notifications for user: $userId',
    );
  }

  @override
  Future<void> clearAllNotificationsForUser(String userId) async {
    await clearAllNotifications(userId);
  }
}
