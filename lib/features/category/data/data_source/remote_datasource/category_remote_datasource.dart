import 'package:dio/dio.dart';
import 'package:jerseyhub/app/constant/backend_config.dart';
import 'package:jerseyhub/core/network/api_service.dart';
import 'package:jerseyhub/features/category/data/model/category_api_model.dart';
import 'package:jerseyhub/features/category/domain/entity/category_entity.dart';
import '../category_data_source.dart';

class CategoryRemoteDataSource implements ICategoryDataSource {
  final ApiService _apiService;

  CategoryRemoteDataSource({required ApiService apiService})
    : _apiService = apiService;

  @override
  Future<List<CategoryEntity>> getAllCategories() async {
    try {
      // For testing purposes, always use mock data
      print('Using mock categories for testing');
      return _getMockCategories();

      // Uncomment the following code when you want to use real API
      /*
      final response = await _apiService.dio.get(
        BackendConfig.categoriesEndpoint,
      );

      if (BackendConfig.successStatusCodes.contains(response.statusCode)) {
        final responseData = response.data;
        List<dynamic> categoriesData;

        if (responseData is Map<String, dynamic>) {
          if (responseData['success'] == true && responseData['data'] != null) {
            categoriesData = responseData['data'] as List<dynamic>;
          } else {
            categoriesData = [responseData];
          }
        } else if (responseData is List) {
          categoriesData = responseData;
        } else {
          throw Exception("Invalid response format");
        }

        return categoriesData
            .map((json) => CategoryApiModel.fromJson(json).toEntity())
            .toList();
      } else {
        throw Exception("Failed to fetch categories: ${response.statusMessage}");
      }
      */
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        print('Backend not available, simulating categories fetch for testing');
        return _getMockCategories();
      } else {
        throw Exception('Failed to get categories: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  @override
  Future<CategoryEntity> getCategoryById(String id) async {
    try {
      // For testing purposes, always use mock data
      print('Using mock category by ID for testing');
      final mockCategories = _getMockCategories();
      final category = mockCategories.firstWhere(
        (category) => category.id == id,
        orElse: () => throw Exception('Category not found'),
      );
      return category;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        print('Backend not available, simulating category by ID for testing');
        final mockCategories = _getMockCategories();
        final category = mockCategories.firstWhere(
          (category) => category.id == id,
          orElse: () => throw Exception('Category not found'),
        );
        return category;
      } else {
        throw Exception('Failed to get category: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to get category: $e');
    }
  }

  @override
  Future<CategoryEntity> createCategory(CategoryEntity category) async {
    try {
      // For testing purposes, return the category as is
      print('Using mock category creation for testing');
      return category;
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  @override
  Future<CategoryEntity> updateCategory(CategoryEntity category) async {
    try {
      // For testing purposes, return the updated category
      print('Using mock category update for testing');
      return category;
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      // For testing purposes, simulate successful deletion
      print('Using mock category deletion for testing');
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  // Mock data for testing when backend is not available
  List<CategoryEntity> _getMockCategories() {
    return [
      CategoryEntity(
        id: '1',
        name: 'Barcelona',
        description: 'Official Barcelona jerseys',
        imageUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CategoryEntity(
        id: '2',
        name: 'Manchester United',
        description: 'Official Manchester United jerseys',
        imageUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CategoryEntity(
        id: '3',
        name: 'Real Madrid',
        description: 'Official Real Madrid jerseys',
        imageUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CategoryEntity(
        id: '4',
        name: 'Liverpool',
        description: 'Official Liverpool jerseys',
        imageUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}
