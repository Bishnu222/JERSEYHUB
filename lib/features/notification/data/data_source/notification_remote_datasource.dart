import 'dart:async';
import 'package:dio/dio.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import 'package:jerseyhub/app/constant/backend_config.dart';
import 'package:jerseyhub/features/notification/data/model/notification_api_model.dart';
import 'package:jerseyhub/features/notification/domain/entity/notification_entity.dart';

abstract class INotificationRemoteDataSource {
  Future<List<NotificationApiModel>> getNotifications(String userId);
  Future<NotificationApiModel> markAsRead(String notificationId);
  Future<void> markAllAsRead(String userId);
  Future<void> clearAllNotifications(String userId);
  Future<void> connectToSocket(String userId);
  Future<void> disconnectFromSocket();
  Stream<NotificationEntity> get notificationStream;
}

class NotificationRemoteDataSource implements INotificationRemoteDataSource {
  final Dio _dio;
  socket_io.Socket? _socket;
  final StreamController<NotificationEntity> _notificationController =
      StreamController<NotificationEntity>.broadcast();

  NotificationRemoteDataSource(this._dio);

  @override
  Future<List<NotificationApiModel>> getNotifications(String userId) async {
    try {
      print(
        '🔍 NotificationDataSource: Fetching notifications for user: $userId',
      );

      // Check if backend is disabled
      if (!BackendConfig.enableBackend) {
        print('📱 Backend disabled, returning mock notifications');
        return _getMockNotifications(userId);
      }

      final response = await _dio.get('/notifications/user/$userId');

      print(
        '🔍 NotificationDataSource: Response status: ${response.statusCode}',
      );
      print('🔍 NotificationDataSource: Response data: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final notifications = data
            .map((json) => NotificationApiModel.fromJson(json))
            .toList();
        print(
          '🔍 NotificationDataSource: Parsed ${notifications.length} notifications',
        );
        return notifications;
      } else {
        throw Exception(
          'Failed to load notifications: Status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ NotificationDataSource: Error fetching notifications: $e');
      throw Exception('Failed to load notifications: $e');
    }
  }

  @override
  Future<NotificationApiModel> markAsRead(String notificationId) async {
    try {
      final response = await _dio.put('/notifications/$notificationId/read');

      if (response.statusCode == 200) {
        return NotificationApiModel.fromJson(response.data);
      } else {
        throw Exception('Failed to mark notification as read');
      }
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      final response = await _dio.put(
        '/notifications/user/$userId/mark-all-read',
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark all notifications as read');
      }
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  @override
  Future<void> clearAllNotifications(String userId) async {
    try {
      final response = await _dio.delete(
        '/notifications/user/$userId/clear-all',
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to clear all notifications');
      }
    } catch (e) {
      throw Exception('Failed to clear all notifications: $e');
    }
  }

  @override
  Future<void> connectToSocket(String userId) async {
    try {
      // Check if backend is disabled
      if (!BackendConfig.enableBackend) {
        print('📱 Backend disabled, skipping socket connection');
        return;
      }

      // Disconnect existing socket if any
      await disconnectFromSocket();

      // Create new socket connection
      _socket = socket_io.io(
        BackendConfig.serverAddress,
        socket_io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build(),
      );

      // Listen for connection
      _socket!.onConnect((_) {
        print('🔌 Connected to notification socket');
        _socket!.emit('join', userId);
      });

      // Listen for notifications
      _socket!.on('notification', (data) {
        print('🔌 Socket: Received notification data: $data');
        try {
          final notification = NotificationApiModel.fromJson(data).toEntity();
          print('🔌 Socket: Parsed notification: ${notification.message}');
          _notificationController.add(notification);
        } catch (e) {
          print('❌ Error parsing notification: $e');
        }
      });

      // Listen for disconnection
      _socket!.onDisconnect((_) {
        print('🔌 Disconnected from notification socket');
      });

      // Connect to socket
      _socket!.connect();
    } catch (e) {
      throw Exception('Failed to connect to socket: $e');
    }
  }

  @override
  Future<void> disconnectFromSocket() async {
    try {
      if (_socket != null) {
        _socket!.disconnect();
        _socket!.dispose();
        _socket = null;
      }
    } catch (e) {
      print('❌ Error disconnecting from socket: $e');
    }
  }

  @override
  Stream<NotificationEntity> get notificationStream =>
      _notificationController.stream;

  // Mock notifications for testing when backend is disabled
  List<NotificationApiModel> _getMockNotifications(String userId) {
    return [
      NotificationApiModel(
        id: 'mock_notification_1',
        userId: userId,
        message:
            'Welcome to Jersey Hub! Thank you for joining our platform. Start exploring our amazing jerseys!',
        read: false,
        type: 'welcome',
        createdAt: DateTime.now()
            .subtract(Duration(hours: 2))
            .toIso8601String(),
        updatedAt: DateTime.now()
            .subtract(Duration(hours: 2))
            .toIso8601String(),
      ),
      NotificationApiModel(
        id: 'mock_notification_2',
        userId: userId,
        message:
            'New Jersey Available! Check out our latest collection of premium football jerseys!',
        read: true,
        type: 'product',
        createdAt: DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
        updatedAt: DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
      ),
      NotificationApiModel(
        id: 'mock_notification_3',
        userId: userId,
        message:
            'Order Update: Your order #12345 has been shipped and is on its way!',
        read: false,
        type: 'order',
        createdAt: DateTime.now()
            .subtract(Duration(hours: 6))
            .toIso8601String(),
        updatedAt: DateTime.now()
            .subtract(Duration(hours: 6))
            .toIso8601String(),
      ),
    ];
  }

  void dispose() {
    disconnectFromSocket();
    _notificationController.close();
  }
}
