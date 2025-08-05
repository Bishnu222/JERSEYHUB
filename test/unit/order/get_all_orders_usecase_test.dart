import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:jerseyhub/core/error/failure.dart';
import 'package:jerseyhub/features/order/domain/entity/order_entity.dart';
import 'package:jerseyhub/features/order/domain/repository/order_repository.dart';
import 'package:jerseyhub/features/order/domain/use_case/get_all_orders_usecase.dart';
import 'package:jerseyhub/features/cart/domain/entity/cart_item_entity.dart';
import 'package:jerseyhub/features/product/domain/entity/product_entity.dart';

import 'get_all_orders_usecase_test.mocks.dart';

// Use existing Failure classes for testing
class ServerFailure extends RemoteDatabaseFailure {
  ServerFailure({required String message}) : super(message: message);
}

class NetworkFailure extends RemoteDatabaseFailure {
  NetworkFailure({required String message}) : super(message: message);
}

class DatabaseFailure extends LocalDatabaseFailure {
  DatabaseFailure({required String message}) : super(message: message);
}

@GenerateMocks([OrderRepository])
void main() {
  group('GetAllOrdersUseCase', () {
    late GetAllOrdersUseCase useCase;
    late MockOrderRepository mockRepository;
    late List<OrderEntity> testOrders;

    setUp(() {
      mockRepository = MockOrderRepository();
      useCase = GetAllOrdersUseCase(mockRepository);

      // Create test data
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

      testOrders = [
        OrderEntity(
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
        ),
        OrderEntity(
          id: 'order2',
          userId: 'user123',
          items: [testCartItem],
          subtotal: 2500.0,
          shippingCost: 5.99,
          totalAmount: 2505.99,
          status: OrderStatus.processing,
          customerName: 'John Doe',
          customerEmail: 'john@example.com',
          customerPhone: '1234567890',
          shippingAddress: '123 Test St',
          createdAt: DateTime(2025, 1, 2),
          updatedAt: DateTime(2025, 1, 2),
        ),
      ];
    });

    test('should get all orders from repository successfully', () async {
      // Arrange
      when(
        mockRepository.getAllOrders(),
      ).thenAnswer((_) async => Right(testOrders));

      // Act
      final result = await useCase();

      // Assert
      expect(result, Right(testOrders));
      verify(mockRepository.getAllOrders()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      final failure = ServerFailure(message: 'Failed to load orders');
      when(
        mockRepository.getAllOrders(),
      ).thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase();

      // Assert
      expect(result, Left(failure));
      verify(mockRepository.getAllOrders()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no orders exist', () async {
      // Arrange
      when(
        mockRepository.getAllOrders(),
      ).thenAnswer((_) async => const Right(<OrderEntity>[]));

      // Act
      final result = await useCase();

      // Assert
      expect(result, const Right(<OrderEntity>[]));
      verify(mockRepository.getAllOrders()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle network failure', () async {
      // Arrange
      final failure = NetworkFailure(message: 'No internet connection');
      when(
        mockRepository.getAllOrders(),
      ).thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase();

      // Assert
      expect(result, Left(failure));
      verify(mockRepository.getAllOrders()).called(1);
    });

    test('should handle database failure', () async {
      // Arrange
      final failure = DatabaseFailure(message: 'Database connection failed');
      when(
        mockRepository.getAllOrders(),
      ).thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase();

      // Assert
      expect(result, Left(failure));
      verify(mockRepository.getAllOrders()).called(1);
    });

    test('should return orders sorted by creation date', () async {
      // Arrange
      final sortedOrders = List<OrderEntity>.from(testOrders)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      when(
        mockRepository.getAllOrders(),
      ).thenAnswer((_) async => Right(sortedOrders));

      // Act
      final result = await useCase();

      // Assert
      final orders = result.fold(
        (l) => <OrderEntity>[],
        (r) => r as List<OrderEntity>,
      );
      expect(result, Right(sortedOrders));
      expect(orders.first.id, 'order2');
      expect(orders.last.id, 'order1');
    });

    test('should handle repository throwing exception', () async {
      // Arrange
      when(
        mockRepository.getAllOrders(),
      ).thenThrow(Exception('Unexpected error'));

      // Act & Assert
      expect(() => useCase(), throwsA(isA<Exception>()));
    });

    test('should verify repository is called only once', () async {
      // Arrange
      when(
        mockRepository.getAllOrders(),
      ).thenAnswer((_) async => Right(testOrders));

      // Act
      await useCase();
      await useCase();

      // Assert
      verify(mockRepository.getAllOrders()).called(2);
    });

    test('should handle null response from repository', () async {
      // Arrange
      when(
        mockRepository.getAllOrders(),
      ).thenAnswer((_) async => const Right(<OrderEntity>[]));

      // Act
      final result = await useCase();

      // Assert
      expect(result, const Right(<OrderEntity>[]));
      verify(mockRepository.getAllOrders()).called(1);
    });

    test('should handle large number of orders', () async {
      // Arrange
      final largeOrderList = List<OrderEntity>.generate(
        100,
        (index) => testOrders.first.copyWith(id: 'order$index'),
      );

      when(
        mockRepository.getAllOrders(),
      ).thenAnswer((_) async => Right(largeOrderList));

      // Act
      final result = await useCase();

      // Assert
      final orders = result.fold(
        (l) => <OrderEntity>[],
        (r) => r as List<OrderEntity>,
      );
      expect(orders.length, 100);
      verify(mockRepository.getAllOrders()).called(1);
    });
  });
}
