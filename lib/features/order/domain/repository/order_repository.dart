import 'package:dartz/dartz.dart';
import 'package:jerseyhub/core/error/failure.dart';
import 'package:jerseyhub/features/order/domain/entity/order_entity.dart';

abstract class OrderRepository {
  // Local operations
  Future<Either<Failure, List<OrderEntity>>> getAllLocalOrders();
  Future<Either<Failure, OrderEntity>> getLocalOrderById(String orderId);
  Future<Either<Failure, OrderEntity>> createLocalOrder(OrderEntity order);
  Future<Either<Failure, OrderEntity>> updateLocalOrderStatus(
    String orderId,
    String status,
  );
  Future<Either<Failure, void>> deleteLocalOrder(String orderId);

  // Remote operations
  Future<Either<Failure, List<OrderEntity>>> getAllRemoteOrders();
  Future<Either<Failure, OrderEntity>> getRemoteOrderById(String orderId);
  Future<Either<Failure, OrderEntity>> createRemoteOrder(OrderEntity order);
  Future<Either<Failure, OrderEntity>> updateRemoteOrderStatus(
    String orderId,
    String status,
  );
  Future<Either<Failure, void>> deleteRemoteOrder(String orderId);

  // Hybrid operations (try remote first, fallback to local)
  Future<Either<Failure, List<OrderEntity>>> getAllOrders();
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId);
  Future<Either<Failure, OrderEntity>> createOrder(OrderEntity order);
  Future<Either<Failure, OrderEntity>> updateOrderStatus(
    String orderId,
    String status,
  );
  Future<Either<Failure, void>> deleteOrder(String orderId);
  Future<Either<Failure, void>> clearAllLocalOrders();
}
