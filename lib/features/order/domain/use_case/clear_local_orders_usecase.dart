import 'package:dartz/dartz.dart';
import 'package:jerseyhub/core/error/failure.dart';
import 'package:jerseyhub/features/order/domain/repository/order_repository.dart';

class ClearLocalOrdersUseCase {
  final OrderRepository _repository;

  ClearLocalOrdersUseCase(this._repository);

  Future<Either<Failure, void>> call() async {
    return await _repository.clearAllLocalOrders();
  }
}
