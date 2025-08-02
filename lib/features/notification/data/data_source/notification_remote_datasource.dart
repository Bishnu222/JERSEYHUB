import 'dart:async';
import 'package:dio/dio.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:jerseyhub/app/constant/backend_config.dart';
import 'package:jerseyhub/features/notification/data/model/notification_api_model.dart';
import 'package:jerseyhub/features/notification/domain/entity/notification_entity.dart';

abstract class INotificationRemoteDataSource {
  Future<List<NotificationApiModel>> getNotifications(String userId);
  Future<NotificationApiModel> markAsRead(String notificationId);
  Future<void> connectToSocket(String userId);
  Future<void> disconnectFromSocket();
  Stream<NotificationEntity> get notificationStream;
}

class NotificationRemoteDataSource implements INotificationRemoteDataSource {
  final Dio _dio;
  IO.Socket? _socket;
  final StreamController<NotificationEntity> _notificationController =
      StreamController<NotificationEntity>.broadcast();

  NotificationRemoteDataSource(this._dio);

  @override
  Future<List<NotificationApiModel>> getNotifications(String userId) async {
    try {
      final response = await _dio.get('/notifications/user/$userId');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => NotificationApiModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
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
  Future<void> connectToSocket(String userId) async {
    try {
      // Disconnect existing socket if any
      await disconnectFromSocket();

      // Create new socket connection
      _socket = IO.io(
        BackendConfig.serverAddress,
        IO.OptionBuilder()
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

  void dispose() {
    disconnectFromSocket();
    _notificationController.close();
  }
}
