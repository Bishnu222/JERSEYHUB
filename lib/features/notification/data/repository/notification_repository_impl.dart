import 'package:dartz/dartz.dart';
import 'package:jerseyhub/core/error/failure.dart';
import 'package:jerseyhub/features/notification/data/data_source/notification_remote_datasource.dart';
import 'package:jerseyhub/features/notification/data/data_source/notification_local_datasource.dart';
import 'package:jerseyhub/features/notification/domain/entity/notification_entity.dart';
import 'package:jerseyhub/features/notification/domain/repository/notification_repository.dart';
import 'package:jerseyhub/app/constant/backend_config.dart';

class NotificationRepositoryImpl implements INotificationRepository {
  final INotificationRemoteDataSource _remoteDataSource;
  final NotificationLocalDataSource _localDataSource;

  NotificationRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications(
    String userId,
  ) async {
    try {
      if (BackendConfig.enableBackend) {
        // Try remote first, fallback to local
        try {
          final notifications = await _remoteDataSource.getNotifications(
            userId,
          );
          final entities = notifications
              .map((model) => model.toEntity())
              .toList();
          return Right(entities);
        } catch (e) {
          print('📱 NotificationRepository: Remote failed, using local: $e');
          final localNotifications = await _localDataSource.getNotifications(
            userId,
          );
          return Right(localNotifications);
        }
      } else {
        // Use local storage when backend is disabled
        final localNotifications = await _localDataSource.getNotifications(
          userId,
        );
        return Right(localNotifications);
      }
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationEntity>> markAsRead(
    String notificationId,
  ) async {
    try {
      if (BackendConfig.enableBackend) {
        try {
          final notification = await _remoteDataSource.markAsRead(
            notificationId,
          );
          return Right(notification.toEntity());
        } catch (e) {
          print(
            '📱 NotificationRepository: Remote markAsRead failed, using local: $e',
          );
          final localNotification = await _localDataSource.markAsRead(
            notificationId,
          );
          return Right(localNotification);
        }
      } else {
        final localNotification = await _localDataSource.markAsRead(
          notificationId,
        );
        return Right(localNotification);
      }
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead(String userId) async {
    try {
      if (BackendConfig.enableBackend) {
        try {
          await _remoteDataSource.markAllAsRead(userId);
        } catch (e) {
          print(
            '📱 NotificationRepository: Remote markAllAsRead failed, using local: $e',
          );
          await _localDataSource.markAllAsRead(userId);
        }
      } else {
        await _localDataSource.markAllAsRead(userId);
      }
      return const Right(null);
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearAllNotifications(String userId) async {
    try {
      if (BackendConfig.enableBackend) {
        try {
          await _remoteDataSource.clearAllNotifications(userId);
        } catch (e) {
          print(
            '📱 NotificationRepository: Remote clearAllNotifications failed, using local: $e',
          );
          await _localDataSource.clearAllNotifications(userId);
        }
      } else {
        await _localDataSource.clearAllNotifications(userId);
      }
      return const Right(null);
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> connectToSocket(String userId) async {
    try {
      if (BackendConfig.enableBackend) {
        await _remoteDataSource.connectToSocket(userId);
      } else {
        print(
          '📱 NotificationRepository: Socket connection skipped (backend disabled)',
        );
      }
      return const Right(null);
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> disconnectFromSocket() async {
    try {
      if (BackendConfig.enableBackend) {
        await _remoteDataSource.disconnectFromSocket();
      }
      return const Right(null);
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Stream<NotificationEntity> get notificationStream {
    if (BackendConfig.enableBackend) {
      return _remoteDataSource.notificationStream;
    } else {
      // Return empty stream when backend is disabled
      return Stream.empty();
    }
  }

  // Add method to store notifications locally
  Future<Either<Failure, NotificationEntity>> addNotification(
    NotificationEntity notification,
  ) async {
    try {
      final storedNotification = await _localDataSource.addNotification(
        notification,
      );
      return Right(storedNotification);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}
