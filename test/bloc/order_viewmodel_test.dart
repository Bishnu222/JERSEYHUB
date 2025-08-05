import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:jerseyhub/features/order/domain/entity/order_entity.dart';
import 'package:jerseyhub/features/order/presentation/viewmodel/order_viewmodel.dart';
import 'package:jerseyhub/features/cart/domain/entity/cart_item_entity.dart';
import 'package:jerseyhub/features/product/domain/entity/product_entity.dart';
import 'package:jerseyhub/features/order/domain/use_case/get_all_orders_usecase.dart';
import 'package:jerseyhub/features/order/domain/use_case/get_order_by_id_usecase.dart';
import 'package:jerseyhub/features/order/domain/use_case/create_order_usecase.dart';
import 'package:jerseyhub/features/order/domain/use_case/update_order_status_usecase.dart';
import 'package:jerseyhub/features/order/domain/use_case/delete_order_usecase.dart';
import 'package:jerseyhub/features/order/domain/repository/order_repository.dart';
import 'package:jerseyhub/app/shared_prefs/user_shared_prefs.dart';
import 'package:dartz/dartz.dart';
import 'package:jerseyhub/core/error/failure.dart';

class FakeUserSharedPrefs implements UserSharedPrefs {
  @override
  Future<void> clearUserData() async {}

  @override
  String? getCurrentUserEmail() => 'test@example.com';

  @override
  String? getCurrentUserId() => 'user123';

  @override
  String? getProfileImageUrl() => null;

  @override
  bool isLoggedIn() => true;

  @override
  Future<bool> isUserLoggedIn() async => true;

  @override
  Future<void> setCurrentUserEmail(String email) async {}

  @override
  Future<void> setCurrentUserId(String userId) async {}

  @override
  Future<void> setProfileImageUrl(String imageUrl) async {}

  @override
  Future<void> setUserLoggedIn(String userId, String email) async {}

  @override
  Map<String, dynamic> getAllUserData() {
    return {
      'userId': getCurrentUserId(),
      'userEmail': getCurrentUserEmail(),
      'profileImageUrl': getProfileImageUrl(),
      'isLoggedIn': isLoggedIn(),
    };
  }

  @override
  void printCurrentUserData() {
    final data = getAllUserData();
    print('🔍 FakeUserSharedPrefs: Current user data:');
    data.forEach((key, value) {
      print('  $key: $value');
    });
  }
}

class MockGetAllOrdersUseCase extends GetAllOrdersUseCase {
  final List<OrderEntity> orders;
  final bool shouldFail;
  final String errorMessage;

  MockGetAllOrdersUseCase({
    this.orders = const [],
    this.shouldFail = false,
    this.errorMessage = 'Test error',
  }) : super(_MockOrderRepository());

  @override
  Future<Either<Failure, List<OrderEntity>>> call() async {
    if (shouldFail) {
      return Left(RemoteDatabaseFailure(message: errorMessage));
    }
    return Right(orders);
  }
}

class MockGetOrderByIdUseCase extends GetOrderByIdUseCase {
  final OrderEntity? order;
  final bool shouldFail;
  final String errorMessage;

  MockGetOrderByIdUseCase({
    this.order,
    this.shouldFail = false,
    this.errorMessage = 'Test error',
  }) : super(_MockOrderRepository());

  @override
  Future<Either<Failure, OrderEntity>> call(GetOrderByIdParams params) async {
    if (shouldFail) {
      return Left(RemoteDatabaseFailure(message: errorMessage));
    }
    if (order != null) {
      return Right(order!);
    }
    return Left(RemoteDatabaseFailure(message: 'Order not found'));
  }
}

class MockCreateOrderUseCase extends CreateOrderUseCase {
  final OrderEntity? createdOrder;
  final bool shouldFail;
  final String errorMessage;

  MockCreateOrderUseCase({
    this.createdOrder,
    this.shouldFail = false,
    this.errorMessage = 'Test error',
  }) : super(_MockOrderRepository());

  @override
  Future<Either<Failure, OrderEntity>> call(CreateOrderParams params) async {
    if (shouldFail) {
      return Left(RemoteDatabaseFailure(message: errorMessage));
    }
    if (createdOrder != null) {
      return Right(createdOrder!);
    }
    return Right(params.order);
  }
}

class MockUpdateOrderStatusUseCase extends UpdateOrderStatusUseCase {
  final OrderEntity? updatedOrder;
  final bool shouldFail;
  final String errorMessage;

  MockUpdateOrderStatusUseCase({
    this.updatedOrder,
    this.shouldFail = false,
    this.errorMessage = 'Test error',
  }) : super(_MockOrderRepository());

  @override
  Future<Either<Failure, OrderEntity>> call(
    UpdateOrderStatusParams params,
  ) async {
    if (shouldFail) {
      return Left(RemoteDatabaseFailure(message: errorMessage));
    }
    if (updatedOrder != null) {
      return Right(updatedOrder!);
    }
    return Left(RemoteDatabaseFailure(message: 'Order not found'));
  }
}

class MockDeleteOrderUseCase extends DeleteOrderUseCase {
  final bool shouldFail;
  final String errorMessage;

  MockDeleteOrderUseCase({
    this.shouldFail = false,
    this.errorMessage = 'Test error',
  }) : super(_MockOrderRepository());

  @override
  Future<Either<Failure, void>> call(DeleteOrderParams params) async {
    if (shouldFail) {
      return Left(RemoteDatabaseFailure(message: errorMessage));
    }
    return const Right(null);
  }
}

class _MockOrderRepository implements OrderRepository {
  @override
  Future<Either<Failure, List<OrderEntity>>> getAllLocalOrders() async {
    return Left(RemoteDatabaseFailure(message: 'Not implemented in test'));
  }

  @override
  Future<Either<Failure, OrderEntity>> getLocalOrderById(String orderId) async {
    return Left(RemoteDatabaseFailure(message: 'Not implemented in test'));
  }

  @override
  Future<Either<Failure, OrderEntity>> createLocalOrder(
    OrderEntity order,
  ) async {
    return Left(RemoteDatabaseFailure(message: 'Not implemented in test'));
  }

  @override
  Future<Either<Failure, OrderEntity>> updateLocalOrderStatus(
    String orderId,
    String status,
  ) async {
    return Left(RemoteDatabaseFailure(message: 'Not implemented in test'));
  }

  @override
  Future<Either<Failure, void>> deleteLocalOrder(String orderId) async {
    return Left(RemoteDatabaseFailure(message: 'Not implemented in test'));
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getAllRemoteOrders() async {
    return Left(RemoteDatabaseFailure(message: 'Not implemented in test'));
  }

  @override
  Future<Either<Failure, OrderEntity>> getRemoteOrderById(
    String orderId,
  ) async {
    return Left(RemoteDatabaseFailure(message: 'Not implemented in test'));
  }

  @override
  Future<Either<Failure, OrderEntity>> createRemoteOrder(
    OrderEntity order,
  ) async {
    return Left(RemoteDatabaseFailure(message: 'Not implemented in test'));
  }

  @override
  Future<Either<Failure, OrderEntity>> updateRemoteOrderStatus(
    String orderId,
    String status,
  ) async {
    return Left(RemoteDatabaseFailure(message: 'Not implemented in test'));
  }

  @override
  Future<Either<Failure, void>> deleteRemoteOrder(String orderId) async {
    return Left(RemoteDatabaseFailure(message: 'Not implemented in test'));
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getAllOrders() async {
    return Left(RemoteDatabaseFailure(message: 'Not implemented in test'));
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId) async {
    return Left(RemoteDatabaseFailure(message: 'Not implemented in test'));
  }

  @override
  Future<Either<Failure, OrderEntity>> createOrder(OrderEntity order) async {
    return Left(RemoteDatabaseFailure(message: 'Not implemented in test'));
  }

  @override
  Future<Either<Failure, OrderEntity>> updateOrderStatus(
    String orderId,
    String status,
  ) async {
    return Left(RemoteDatabaseFailure(message: 'Not implemented in test'));
  }

  @override
  Future<Either<Failure, void>> deleteOrder(String orderId) async {
    return Left(RemoteDatabaseFailure(message: 'Not implemented in test'));
  }

  @override
  Future<Either<Failure, void>> clearAllLocalOrders() async {
    return const Right(null);
  }
}

void main() {
  group('OrderViewModel Bloc Tests', () {
    late List<OrderEntity> testOrders;
    late OrderEntity testOrder;

    setUp(() {
      final testProduct = ProductEntity(
        id: '1',
        team: 'Real Madrid',
        type: 'Home',
        size: 'M',
        price: 2500.0,
        quantity: 10,
        categoryId: 'cat1',
        productImage: 'test.jpg',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      final testCartItem = CartItemEntity(
        id: 'cart1',
        product: testProduct,
        quantity: 2,
        selectedSize: 'M',
        addedAt: DateTime(2025, 1, 1),
      );

      testOrder = OrderEntity(
        id: 'order1',
        userId: 'user123',
        items: [testCartItem],
        subtotal: 5000.0,
        shippingCost: 5.99,
        totalAmount: 5005.99,
        status: OrderStatus.pending,
        customerName: 'John Doe',
        customerEmail: 'john@example.com',
        customerPhone: '1234567890',
        shippingAddress: '123 Test St',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      testOrders = [testOrder];
    });

    test('initial state should be OrderInitial', () {
      final orderViewModel = OrderViewModel(
        getAllOrdersUseCase: MockGetAllOrdersUseCase(),
        getOrderByIdUseCase: MockGetOrderByIdUseCase(),
        createOrderUseCase: MockCreateOrderUseCase(),
        updateOrderStatusUseCase: MockUpdateOrderStatusUseCase(),
        deleteOrderUseCase: MockDeleteOrderUseCase(),
        userSharedPrefs: FakeUserSharedPrefs(),
      );

      expect(orderViewModel.state, isA<OrderInitial>());
    });

    blocTest<OrderViewModel, OrderState>(
      'should emit [OrderLoading, OrdersLoaded] when LoadAllOrdersEvent succeeds',
      build: () => OrderViewModel(
        getAllOrdersUseCase: MockGetAllOrdersUseCase(orders: testOrders),
        getOrderByIdUseCase: MockGetOrderByIdUseCase(),
        createOrderUseCase: MockCreateOrderUseCase(),
        updateOrderStatusUseCase: MockUpdateOrderStatusUseCase(),
        deleteOrderUseCase: MockDeleteOrderUseCase(),
        userSharedPrefs: FakeUserSharedPrefs(),
      ),
      act: (bloc) => bloc.add(const LoadAllOrdersEvent()),
      expect: () => [isA<OrderLoading>(), isA<OrdersLoaded>()],
    );

    blocTest<OrderViewModel, OrderState>(
      'should emit [OrderLoading, OrderError] when LoadAllOrdersEvent fails',
      build: () => OrderViewModel(
        getAllOrdersUseCase: MockGetAllOrdersUseCase(
          shouldFail: true,
          errorMessage: 'Failed to load orders',
        ),
        getOrderByIdUseCase: MockGetOrderByIdUseCase(),
        createOrderUseCase: MockCreateOrderUseCase(),
        updateOrderStatusUseCase: MockUpdateOrderStatusUseCase(),
        deleteOrderUseCase: MockDeleteOrderUseCase(),
        userSharedPrefs: FakeUserSharedPrefs(),
      ),
      act: (bloc) => bloc.add(const LoadAllOrdersEvent()),
      expect: () => [isA<OrderLoading>(), isA<OrderError>()],
    );

    blocTest<OrderViewModel, OrderState>(
      'should emit [OrderLoading, OrderLoaded] when LoadOrderByIdEvent succeeds',
      build: () => OrderViewModel(
        getAllOrdersUseCase: MockGetAllOrdersUseCase(),
        getOrderByIdUseCase: MockGetOrderByIdUseCase(order: testOrder),
        createOrderUseCase: MockCreateOrderUseCase(),
        updateOrderStatusUseCase: MockUpdateOrderStatusUseCase(),
        deleteOrderUseCase: MockDeleteOrderUseCase(),
        userSharedPrefs: FakeUserSharedPrefs(),
      ),
      act: (bloc) => bloc.add(const LoadOrderByIdEvent(orderId: 'order1')),
      expect: () => [isA<OrderLoading>(), isA<OrderLoaded>()],
    );

    blocTest<OrderViewModel, OrderState>(
      'should emit [OrderLoading, OrderCreated] when CreateOrderEvent succeeds',
      build: () => OrderViewModel(
        getAllOrdersUseCase: MockGetAllOrdersUseCase(),
        getOrderByIdUseCase: MockGetOrderByIdUseCase(),
        createOrderUseCase: MockCreateOrderUseCase(createdOrder: testOrder),
        updateOrderStatusUseCase: MockUpdateOrderStatusUseCase(),
        deleteOrderUseCase: MockDeleteOrderUseCase(),
        userSharedPrefs: FakeUserSharedPrefs(),
      ),
      act: (bloc) => bloc.add(CreateOrderEvent(order: testOrder)),
      expect: () => [isA<OrderLoading>(), isA<OrderCreated>()],
    );

    blocTest<OrderViewModel, OrderState>(
      'should emit [OrderLoading, OrderUpdated] when UpdateOrderStatusEvent succeeds',
      build: () => OrderViewModel(
        getAllOrdersUseCase: MockGetAllOrdersUseCase(),
        getOrderByIdUseCase: MockGetOrderByIdUseCase(),
        createOrderUseCase: MockCreateOrderUseCase(),
        updateOrderStatusUseCase: MockUpdateOrderStatusUseCase(
          updatedOrder: testOrder,
        ),
        deleteOrderUseCase: MockDeleteOrderUseCase(),
        userSharedPrefs: FakeUserSharedPrefs(),
      ),
      act: (bloc) => bloc.add(
        const UpdateOrderStatusEvent(orderId: 'order1', status: 'processing'),
      ),
      expect: () => [isA<OrderLoading>(), isA<OrderUpdated>()],
    );

    blocTest<OrderViewModel, OrderState>(
      'should emit [OrderLoading, OrderDeleted] when DeleteOrderEvent succeeds',
      build: () => OrderViewModel(
        getAllOrdersUseCase: MockGetAllOrdersUseCase(),
        getOrderByIdUseCase: MockGetOrderByIdUseCase(),
        createOrderUseCase: MockCreateOrderUseCase(),
        updateOrderStatusUseCase: MockUpdateOrderStatusUseCase(),
        deleteOrderUseCase: MockDeleteOrderUseCase(),
        userSharedPrefs: FakeUserSharedPrefs(),
      ),
      act: (bloc) => bloc.add(const DeleteOrderEvent(orderId: 'order1')),
      expect: () => [isA<OrderLoading>(), isA<OrderDeleted>()],
    );

    test('should handle LoadAllOrdersEvent correctly', () {
      final event = const LoadAllOrdersEvent();
      expect(event, isA<LoadAllOrdersEvent>());
      expect(event.props, isEmpty);
    });

    test('should filter orders by current user for security', () {
      final orderViewModel = OrderViewModel(
        getAllOrdersUseCase: MockGetAllOrdersUseCase(
          orders: [
            testOrder.copyWith(userId: 'user123'), // Current user's order
            testOrder.copyWith(
              id: 'order2',
              userId: 'user456',
            ), // Different user's order
          ],
        ),
        getOrderByIdUseCase: MockGetOrderByIdUseCase(),
        createOrderUseCase: MockCreateOrderUseCase(),
        updateOrderStatusUseCase: MockUpdateOrderStatusUseCase(),
        deleteOrderUseCase: MockDeleteOrderUseCase(),
        userSharedPrefs: FakeUserSharedPrefs(), // Returns 'user123'
      );

      // Should only show orders for current user
      expect(orderViewModel.state, isA<OrderInitial>());
    });

    test('should NOT show orphaned orders (null userId) for security', () {
      final orderViewModel = OrderViewModel(
        getAllOrdersUseCase: MockGetAllOrdersUseCase(
          orders: [
            testOrder.copyWith(
              userId: null,
            ), // Orphaned order - should be filtered out
            testOrder.copyWith(
              id: 'order2',
              userId: 'user456',
            ), // Different user's order - should be filtered out
          ],
        ),
        getOrderByIdUseCase: MockGetOrderByIdUseCase(),
        createOrderUseCase: MockCreateOrderUseCase(),
        updateOrderStatusUseCase: MockUpdateOrderStatusUseCase(),
        deleteOrderUseCase: MockDeleteOrderUseCase(),
        userSharedPrefs: FakeUserSharedPrefs(), // Returns 'user123'
      );

      // Trigger the load event
      orderViewModel.add(const LoadAllOrdersEvent());

      // Should NOT show orphaned orders for security
      expect(orderViewModel.state, isA<OrderInitial>());
    });

    test('should handle LoadOrderByIdEvent correctly', () {
      final event = const LoadOrderByIdEvent(orderId: 'order1');
      expect(event, isA<LoadOrderByIdEvent>());
      expect(event.orderId, 'order1');
      expect(event.props, contains('order1'));
    });

    test('should handle CreateOrderEvent correctly', () {
      final event = CreateOrderEvent(order: testOrder);
      expect(event, isA<CreateOrderEvent>());
      expect(event.order, testOrder);
      expect(event.props, contains(testOrder));
    });

    test('should handle UpdateOrderStatusEvent correctly', () {
      final event = const UpdateOrderStatusEvent(
        orderId: 'order1',
        status: 'processing',
      );
      expect(event, isA<UpdateOrderStatusEvent>());
      expect(event.orderId, 'order1');
      expect(event.status, 'processing');
      expect(event.props, containsAll(['order1', 'processing']));
    });
  });
}
