import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:jerseyhub/features/product/domain/repository/product_repository.dart';
import 'package:jerseyhub/features/product/domain/use_case/get_products_by_category_usecase.dart';
import 'package:jerseyhub/features/product/domain/entity/product_entity.dart';
import 'package:jerseyhub/core/error/failure.dart';

class MockProductRepository extends Mock implements IProductRepository {}

void main() {
  late MockProductRepository mockProductRepository;
  late GetProductsByCategoryUseCase getProductsByCategoryUseCase;

  const tCategoryId = '1';
  const tParams = GetProductsByCategoryParams(categoryId: tCategoryId);

  final tProducts = [
    ProductEntity(
      id: '1',
      team: 'Manchester United',
      type: 'Home',
      size: 'M',
      price: 2500.0,
      quantity: 25,
      categoryId: '1',
      productImage: 'assets/images/Manchester_United.png',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ProductEntity(
      id: '2',
      team: 'Liverpool',
      type: 'Third',
      size: 'XL',
      price: 2500.0,
      quantity: 40,
      categoryId: '1',
      productImage: 'assets/images/Liverpool.png',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  setUp(() {
    mockProductRepository = MockProductRepository();
    getProductsByCategoryUseCase = GetProductsByCategoryUseCase(
      repository: mockProductRepository,
    );
  });

  test('should get products by category from repository', () async {
    // Arrange
    when(
      () => mockProductRepository.getProductsByCategory(tCategoryId),
    ).thenAnswer((_) async => Right(tProducts));

    // Act
    final result = await getProductsByCategoryUseCase(tParams);

    // Assert
    expect(result, Right(tProducts));
    verify(
      () => mockProductRepository.getProductsByCategory(tCategoryId),
    ).called(1);
    verifyNoMoreInteractions(mockProductRepository);
  });

  test('should return failure when repository fails', () async {
    // Arrange
    const failure = RemoteDatabaseFailure(
      message: 'Failed to get products by category',
    );
    when(
      () => mockProductRepository.getProductsByCategory(tCategoryId),
    ).thenAnswer((_) async => const Left(failure));

    // Act
    final result = await getProductsByCategoryUseCase(tParams);

    // Assert
    expect(result, const Left(failure));
    verify(
      () => mockProductRepository.getProductsByCategory(tCategoryId),
    ).called(1);
    verifyNoMoreInteractions(mockProductRepository);
  });
}
