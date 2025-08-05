import 'package:dartz/dartz.dart';
import 'package:jerseyhub/core/error/failure.dart';
import 'package:jerseyhub/features/notification/domain/entity/notification_entity.dart';
import 'package:jerseyhub/features/notification/domain/repository/notification_repository.dart';

class AddNotificationUseCase {
  final INotificationRepository _repository;

  AddNotificationUseCase(this._repository);

  Future<Either<Failure, NotificationEntity>> call(
    NotificationEntity notification,
  ) async {
    return await _repository.addNotification(notification);
  }
}
