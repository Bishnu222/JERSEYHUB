import 'package:dio/dio.dart';
import 'package:jerseyhub/app/constant/backend_config.dart';
import 'package:jerseyhub/core/network/api_service.dart';
import 'package:jerseyhub/features/product/data/model/product_api_model.dart';
import 'package:jerseyhub/features/product/domain/entity/product_entity.dart';
import '../product_data_source.dart';

class ProductRemoteDataSource implements IProductDataSource {
  final ApiService _apiService;

  ProductRemoteDataSource({required ApiService apiService})
    : _apiService = apiService;

  @override
  Future<List<ProductEntity>> getAllProducts() async {
    try {
      // Use real API when backend is enabled
      if (BackendConfig.enableBackend) {
        print(
          '🔄 Fetching products from backend: ${BackendConfig.productsEndpoint}',
        );
        final response = await _apiService.dio.get(
          BackendConfig.productsEndpoint,
        );

        if (BackendConfig.successStatusCodes.contains(response.statusCode)) {
          final responseData = response.data;

          // Handle different response formats
          List<dynamic> productsData;
          if (responseData is Map<String, dynamic>) {
            if (responseData['success'] == true &&
                responseData['data'] != null) {
              productsData = responseData['data'] as List<dynamic>;
            } else if (responseData['products'] != null) {
              productsData = responseData['products'] as List<dynamic>;
            } else {
              productsData = [responseData]; // Single product
            }
          } else if (responseData is List) {
            productsData = responseData;
          } else {
            throw Exception("Invalid response format");
          }

          final products = productsData
              .map((json) => ProductApiModel.fromJson(json).toEntity())
              .toList();
          print(
            '✅ Successfully fetched ${products.length} products from backend',
          );

          // Debug: Print detailed product info for first few products
          for (int i = 0; i < products.length && i < 5; i++) {
            print('🖼️ Product ${i + 1}:');
            print('   Team: ${products[i].team}');
            print('   Type: ${products[i].type}');
            print('   Size: ${products[i].size}');
            print('   Image URL: ${products[i].productImage}');
            print('   ---');
          }

          return products;
        } else {
          throw Exception(
            "Failed to fetch products: ${response.statusMessage}",
          );
        }
      } else {
        // Fallback to mock data when backend is disabled
        print('📱 Backend disabled, using mock products');
        return _getMockProducts();
      }
    } on DioException catch (e) {
      print('❌ Backend connection error: ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout) {
        print('⏰ Connection timeout, falling back to mock products');
        return _getMockProducts();
      } else {
        print('🔄 Other connection error, falling back to mock products');
        return _getMockProducts();
      }
    } catch (e) {
      throw Exception('Failed to get products: $e');
    }
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(String categoryId) async {
    try {
      final response = await _apiService.dio.get(
        '${BackendConfig.productsEndpoint}?categoryId=$categoryId',
      );

      if (BackendConfig.successStatusCodes.contains(response.statusCode)) {
        final responseData = response.data;
        List<dynamic> productsData;

        if (responseData is Map<String, dynamic>) {
          if (responseData['success'] == true && responseData['data'] != null) {
            productsData = responseData['data'] as List<dynamic>;
          } else {
            productsData = [responseData];
          }
        } else if (responseData is List) {
          productsData = responseData;
        } else {
          throw Exception("Invalid response format");
        }

        return productsData
            .map((json) => ProductApiModel.fromJson(json).toEntity())
            .toList();
      } else {
        throw Exception(
          "Failed to fetch products by category: ${response.statusMessage}",
        );
      }
    } on DioException catch (e) {
      print('❌ Backend category error: ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout) {
        print('⏰ Category timeout, falling back to mock products');
        return _getMockProducts()
            .where((product) => product.categoryId == categoryId)
            .toList();
      } else {
        print('🔄 Other category error, falling back to mock products');
        return _getMockProducts()
            .where((product) => product.categoryId == categoryId)
            .toList();
      }
    } catch (e) {
      throw Exception('Failed to get products by category: $e');
    }
  }

  @override
  Future<ProductEntity> getProductById(String id) async {
    try {
      final response = await _apiService.dio.get(
        '${BackendConfig.productsEndpoint}/$id',
      );

      if (BackendConfig.successStatusCodes.contains(response.statusCode)) {
        final responseData = response.data;
        Map<String, dynamic> productData;

        if (responseData is Map<String, dynamic>) {
          if (responseData['success'] == true && responseData['data'] != null) {
            productData = responseData['data'] as Map<String, dynamic>;
          } else {
            productData = responseData;
          }
        } else {
          throw Exception("Invalid response format");
        }

        return ProductApiModel.fromJson(productData).toEntity();
      } else {
        throw Exception("Failed to fetch product: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      print('❌ Backend product by ID error: ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout) {
        print('⏰ Product by ID timeout, falling back to mock products');
        final mockProducts = _getMockProducts();
        final product = mockProducts.firstWhere(
          (product) => product.id == id,
          orElse: () => throw Exception('Product not found'),
        );
        return product;
      } else {
        print('🔄 Other product by ID error, falling back to mock products');
        final mockProducts = _getMockProducts();
        final product = mockProducts.firstWhere(
          (product) => product.id == id,
          orElse: () => throw Exception('Product not found'),
        );
        return product;
      }
    } catch (e) {
      throw Exception('Failed to get product: $e');
    }
  }

  @override
  Future<List<ProductEntity>> searchProducts(String query) async {
    try {
      // Use real API when backend is enabled
      if (BackendConfig.enableBackend) {
        print('🔍 Searching products from backend: $query');
        final response = await _apiService.dio.get(
          '${BackendConfig.productsEndpoint}/search?q=$query',
        );

        if (BackendConfig.successStatusCodes.contains(response.statusCode)) {
          final responseData = response.data;
          List<dynamic> productsData;

          if (responseData is Map<String, dynamic>) {
            if (responseData['success'] == true &&
                responseData['data'] != null) {
              productsData = responseData['data'] as List<dynamic>;
            } else {
              productsData = [responseData];
            }
          } else if (responseData is List) {
            productsData = responseData;
          } else {
            throw Exception("Invalid response format");
          }

          final products = productsData
              .map((json) => ProductApiModel.fromJson(json).toEntity())
              .toList();
          print('✅ Found ${products.length} products for query: $query');
          return products;
        } else {
          throw Exception(
            "Failed to search products: ${response.statusMessage}",
          );
        }
      } else {
        // Fallback to mock data when backend is disabled
        print('📱 Backend disabled, searching mock products for: $query');
        final mockProducts = _getMockProducts();
        return mockProducts
            .where(
              (product) =>
                  product.team.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    } on DioException catch (e) {
      print('❌ Backend search error: ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout) {
        print('⏰ Search timeout, falling back to mock products');
        final mockProducts = _getMockProducts();
        return mockProducts
            .where(
              (product) =>
                  product.team.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      } else {
        print('🔄 Other search error, falling back to mock products');
        final mockProducts = _getMockProducts();
        return mockProducts
            .where(
              (product) =>
                  product.team.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  @override
  Future<List<ProductEntity>> getProductsByType(String type) async {
    try {
      // For testing purposes, always use mock data
      print('Using mock products for type filtering testing');
      return _getMockProducts()
          .where((product) => product.type == type)
          .toList();

      // Uncomment the following code when you want to use real API
      /*
      final response = await _apiService.dio.get(
        '${BackendConfig.productsEndpoint}?type=$type',
      );

      if (BackendConfig.successStatusCodes.contains(response.statusCode)) {
        final responseData = response.data;
        List<dynamic> productsData;

        if (responseData is Map<String, dynamic>) {
          if (responseData['success'] == true && responseData['data'] != null) {
            productsData = responseData['data'] as List<dynamic>;
          } else {
            productsData = [responseData];
          }
        } else if (responseData is List) {
          productsData = responseData;
        } else {
          throw Exception("Invalid response format");
        }

        return productsData
            .map((json) => ProductApiModel.fromJson(json).toEntity())
            .toList();
      } else {
        throw Exception(
          "Failed to fetch products by type: ${response.statusMessage}",
        );
      }
      */
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        print('Backend not available, simulating products by type for testing');
        return _getMockProducts()
            .where((product) => product.type == type)
            .toList();
      } else {
        throw Exception('Failed to get products by type: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to get products by type: $e');
    }
  }

  @override
  Future<List<ProductEntity>> getProductsBySize(String size) async {
    try {
      final response = await _apiService.dio.get(
        '${BackendConfig.productsEndpoint}?size=$size',
      );

      if (BackendConfig.successStatusCodes.contains(response.statusCode)) {
        final responseData = response.data;
        List<dynamic> productsData;

        if (responseData is Map<String, dynamic>) {
          if (responseData['success'] == true && responseData['data'] != null) {
            productsData = responseData['data'] as List<dynamic>;
          } else {
            productsData = [responseData];
          }
        } else if (responseData is List) {
          productsData = responseData;
        } else {
          throw Exception("Invalid response format");
        }

        return productsData
            .map((json) => ProductApiModel.fromJson(json).toEntity())
            .toList();
      } else {
        throw Exception(
          "Failed to fetch products by size: ${response.statusMessage}",
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        print('Backend not available, simulating products by size for testing');
        return _getMockProducts()
            .where((product) => product.size == size)
            .toList();
      } else {
        throw Exception('Failed to get products by size: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to get products by size: $e');
    }
  }

  @override
  Future<List<ProductEntity>> getProductsByPriceRange(
    double minPrice,
    double maxPrice,
  ) async {
    try {
      final response = await _apiService.dio.get(
        '${BackendConfig.productsEndpoint}?minPrice=$minPrice&maxPrice=$maxPrice',
      );

      if (BackendConfig.successStatusCodes.contains(response.statusCode)) {
        final responseData = response.data;
        List<dynamic> productsData;

        if (responseData is Map<String, dynamic>) {
          if (responseData['success'] == true && responseData['data'] != null) {
            productsData = responseData['data'] as List<dynamic>;
          } else {
            productsData = [responseData];
          }
        } else if (responseData is List) {
          productsData = responseData;
        } else {
          throw Exception("Invalid response format");
        }

        return productsData
            .map((json) => ProductApiModel.fromJson(json).toEntity())
            .toList();
      } else {
        throw Exception(
          "Failed to fetch products by price range: ${response.statusMessage}",
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        print(
          'Backend not available, simulating products by price range for testing',
        );
        return _getMockProducts()
            .where(
              (product) =>
                  product.price >= minPrice && product.price <= maxPrice,
            )
            .toList();
      } else {
        throw Exception('Failed to get products by price range: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to get products by price range: $e');
    }
  }

  // Mock data for testing when backend is not available
  List<ProductEntity> _getMockProducts() {
    return [
      // Manchester United Products (Category ID: 2)
      ProductEntity(
        id: '1',
        team: 'Manchester United',
        type: 'Home',
        size: 'M',
        price: 2500.0,
        quantity: 25,
        categoryId: '2',
        productImage: 'assets/images/Manchester_United.png',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      // Liverpool Products (Category ID: 4)
      ProductEntity(
        id: '2',
        team: 'Liverpool',
        type: 'Third',
        size: 'XL',
        price: 2500.0,
        quantity: 40,
        categoryId: '4',
        productImage: 'assets/images/Liverpool.png',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ProductEntity(
        id: '3',
        team: 'Chelsea',
        type: 'Away',
        size: 'L',
        price: 2500.0,
        quantity: 35,
        categoryId: '1',
        productImage: 'assets/images/Chelsea.png',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ProductEntity(
        id: '4',
        team: 'Arsenal',
        type: 'Home',
        size: 'S',
        price: 2500.0,
        quantity: 30,
        categoryId: '1',
        productImage: 'assets/images/Arsenal.png',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      // Real Madrid Products (Category ID: 3)
      ProductEntity(
        id: '5',
        team: 'Real Madrid',
        type: 'Home',
        size: 'M',
        price: 2500.0,
        quantity: 50,
        categoryId: '3',
        productImage: 'assets/images/Real_Madrid.png',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      // Barcelona Products (Category ID: 1)
      ProductEntity(
        id: '6',
        team: 'Barcelona',
        type: 'Away',
        size: 'L',
        price: 2500.0,
        quantity: 30,
        categoryId: '1',
        productImage: 'assets/images/Barcelona.png',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ProductEntity(
        id: '13',
        team: 'Barcelona',
        type: 'Home',
        size: 'M',
        price: 2500.0,
        quantity: 45,
        categoryId: '1',
        productImage: 'assets/images/Barcelona.png',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ProductEntity(
        id: '14',
        team: 'Barcelona',
        type: 'Third',
        size: 'XL',
        price: 2500.0,
        quantity: 20,
        categoryId: '1',
        productImage: 'assets/images/Barcelona.png',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ProductEntity(
        id: '7',
        team: 'Atletico Madrid',
        type: 'Home',
        size: 'XL',
        price: 2500.0,
        quantity: 45,
        categoryId: '2',
        productImage: 'assets/images/Atletico Madrid.png',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      // Bundesliga Products (Category ID: 3)
      ProductEntity(
        id: '8',
        team: 'Bayern Munich',
        type: 'Home',
        size: 'M',
        price: 2500.0,
        quantity: 60,
        categoryId: '3',
        productImage: 'assets/images/Bayern Munich.png',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ProductEntity(
        id: '9',
        team: 'Borussia Dortmund',
        type: 'Away',
        size: 'L',
        price: 2500.0,
        quantity: 40,
        categoryId: '3',
        productImage: 'assets/images/Borussia Dortmund.png',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      // Serie A Products (Category ID: 4)
      ProductEntity(
        id: '10',
        team: 'Juventus',
        type: 'Home',
        size: 'M',
        price: 2500.0,
        quantity: 55,
        categoryId: '4',
        productImage: 'assets/images/Juventus.png',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ProductEntity(
        id: '11',
        team: 'AC Milan',
        type: 'Away',
        size: 'L',
        price: 2500.0,
        quantity: 35,
        categoryId: '4',
        productImage: 'assets/images/AC Milan.png',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ProductEntity(
        id: '12',
        team: 'Inter Milan',
        type: 'Home',
        size: 'XL',
        price: 2500.0,
        quantity: 45,
        categoryId: '4',
        productImage: 'assets/images/Inter Milan.png',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}
