import 'package:dartz/dartz.dart';
import 'package:jerseyhub/core/error/failure.dart';
import 'package:jerseyhub/features/order/domain/entity/order_entity.dart';
import 'package:jerseyhub/features/order/domain/repository/order_repository.dart';
import 'package:jerseyhub/features/order/data/data_source/local_datasource/order_local_datasource.dart';
import 'package:jerseyhub/features/order/data/data_source/remote_datasource/order_remote_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderLocalDataSource _localDataSource;
  final OrderRemoteDataSource _remoteDataSource;

  OrderRepositoryImpl(this._localDataSource, this._remoteDataSource);

  // Local operations
  @override
  Future<Either<Failure, List<OrderEntity>>> getAllLocalOrders() async {
    try {
      final orders = await _localDataSource.getAllOrders();
      return Right(orders);
    } catch (e) {
      return Left(SharedPreferencesFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getLocalOrderById(String orderId) async {
    try {
      final order = await _localDataSource.getOrderById(orderId);
      if (order != null) {
        return Right(order);
      } else {
        return Left(SharedPreferencesFailure(message: 'Order not found'));
      }
    } catch (e) {
      return Left(SharedPreferencesFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> createLocalOrder(
    OrderEntity order,
  ) async {
    try {
      final createdOrder = await _localDataSource.createOrder(order);
      return Right(createdOrder);
    } catch (e) {
      return Left(SharedPreferencesFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> updateLocalOrderStatus(
    String orderId,
    String status,
  ) async {
    try {
      final updatedOrder = await _localDataSource.updateOrderStatus(
        orderId,
        status,
      );
      return Right(updatedOrder);
    } catch (e) {
      return Left(SharedPreferencesFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLocalOrder(String orderId) async {
    try {
      await _localDataSource.deleteOrder(orderId);
      return const Right(null);
    } catch (e) {
      return Left(SharedPreferencesFailure(message: e.toString()));
    }
  }

  // Remote operations
  @override
  Future<Either<Failure, List<OrderEntity>>> getAllRemoteOrders() async {
    return await _remoteDataSource.getAllOrders();
  }

  @override
  Future<Either<Failure, OrderEntity>> getRemoteOrderById(
    String orderId,
  ) async {
    return await _remoteDataSource.getOrderById(orderId);
  }

  @override
  Future<Either<Failure, OrderEntity>> createRemoteOrder(
    OrderEntity order,
  ) async {
    return await _remoteDataSource.createOrder(order);
  }

  @override
  Future<Either<Failure, OrderEntity>> updateRemoteOrderStatus(
    String orderId,
    String status,
  ) async {
    return await _remoteDataSource.updateOrderStatus(orderId, status);
  }

  @override
  Future<Either<Failure, void>> deleteRemoteOrder(String orderId) async {
    return await _remoteDataSource.deleteOrder(orderId);
  }

  // Hybrid operations (try remote first, fallback to local)
  @override
  Future<Either<Failure, List<OrderEntity>>> getAllOrders() async {
    print('🔍 OrderRepositoryImpl: Getting orders for authenticated user');

    // Try remote first, fallback to local
    final remoteResult = await _remoteDataSource.getAllOrders();

    return remoteResult.fold(
      (failure) {
        print(
          '❌ OrderRepositoryImpl: Remote failed, falling back to local: ${failure.message}',
        );
        // If remote fails, return local orders
        return getAllLocalOrders();
      },
      (remoteOrders) {
        print(
          '✅ OrderRepositoryImpl: Remote successful, got ${remoteOrders.length} orders',
        );
        return Right(remoteOrders);
      },
    );
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId) async {
    // Try remote first, fallback to local
    final remoteResult = await _remoteDataSource.getOrderById(orderId);

    return remoteResult.fold((failure) {
      // If remote fails, return local order
      return getLocalOrderById(orderId);
    }, (remoteOrder) => Right(remoteOrder));
  }

  @override
  Future<Either<Failure, OrderEntity>> createOrder(OrderEntity order) async {
    // Create in local storage first for immediate response
    final localResult = await createLocalOrder(order);

    // Try to save to backend
    final remoteResult = await _remoteDataSource.createOrder(order);

    return remoteResult.fold((failure) {
      // If remote fails, return local result
      return localResult;
    }, (remoteOrder) => Right(remoteOrder));
  }

  @override
  Future<Either<Failure, OrderEntity>> updateOrderStatus(
    String orderId,
    String status,
  ) async {
    // Update local first for immediate response
    final localResult = await updateLocalOrderStatus(orderId, status);

    // Try to sync with backend
    final remoteResult = await _remoteDataSource.updateOrderStatus(
      orderId,
      status,
    );

    return remoteResult.fold((failure) {
      // If remote fails, return local result
      return localResult;
    }, (remoteOrder) => Right(remoteOrder));
  }

  @override
  Future<Either<Failure, void>> deleteOrder(String orderId) async {
    // Delete from local first for immediate response
    final localResult = await deleteLocalOrder(orderId);

    // Try to sync with backend
    final remoteResult = await _remoteDataSource.deleteOrder(orderId);

    return remoteResult.fold((failure) {
      // If remote fails, return local result
      return localResult;
    }, (_) => const Right(null));
  }

  @override
  Future<Either<Failure, void>> clearAllLocalOrders() async {
    try {
      await _localDataSource.clearAllOrders();
      print('✅ OrderRepositoryImpl: All local orders cleared');
      return const Right(null);
    } catch (e) {
      print('❌ OrderRepositoryImpl: Failed to clear local orders: $e');
      return Left(SharedPreferencesFailure(message: e.toString()));
    }
  }
}
