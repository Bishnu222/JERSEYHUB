import 'package:dartz/dartz.dart';
import 'package:jerseyhub/core/error/failure.dart';
import 'package:jerseyhub/features/profile/data/model/profile_model.dart';
import 'package:jerseyhub/features/profile/domain/entity/profile_entity.dart';
import '../profile_remote_datasource.dart';

class ProfileMockDataSource implements ProfileRemoteDataSource {
  // Mock user data
  static const Map<String, dynamic> _mockUserData = {
    'id': 'mock_user_123',
    'username': 'Test User',
    'email': 'test@example.com',
    'address': 'Test Address, Kathmandu, Nepal',
    'phoneNumber': '+977-1234567890',
    'profileImage': 'simulated_profile_image_1754324924490.jpg',
    'createdAt': '2024-01-01T00:00:00.000Z',
    'updatedAt': '2024-01-01T00:00:00.000Z',
  };

  @override
  Future<Either<Failure, ProfileModel>> getProfile(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    print('📱 ProfileMockDataSource: Loading mock profile for user: $userId');
    
    final mockProfile = ProfileModel(
      id: _mockUserData['id'],
      username: _mockUserData['username'],
      email: _mockUserData['email'],
      address: _mockUserData['address'],
      phoneNumber: _mockUserData['phoneNumber'],
      profileImage: _mockUserData['profileImage'],
      createdAt: DateTime.parse(_mockUserData['createdAt']),
      updatedAt: DateTime.parse(_mockUserData['updatedAt']),
    );
    
    return Right(mockProfile);
  }

  @override
  Future<Either<Failure, ProfileModel>> updateProfile(ProfileEntity profile) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    print('📱 ProfileMockDataSource: Updating profile with data: ${profile.username}');
    
    final updatedProfile = ProfileModel(
      id: profile.id ?? _mockUserData['id'],
      username: profile.username,
      email: profile.email,
      address: profile.address,
      phoneNumber: profile.phoneNumber ?? _mockUserData['phoneNumber'],
      profileImage: profile.profileImage ?? _mockUserData['profileImage'],
      createdAt: profile.createdAt,
      updatedAt: DateTime.now(),
    );
    
    return Right(updatedProfile);
  }

  @override
  Future<Either<Failure, String>> uploadProfileImage(String imagePath) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));
    
    print('📱 ProfileMockDataSource: Uploading image: $imagePath');
    
    // Return a mock image URL
    final mockImageUrl = 'mock_uploaded_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return Right(mockImageUrl);
  }

  @override
  Future<Either<Failure, bool>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));
    
    print('📱 ProfileMockDataSource: Changing password for user');
    
    // Mock validation - in real app, this would validate against current password
    if (currentPassword == 'wrongpassword') {
      return const Left(RemoteDatabaseFailure(message: 'Current password is incorrect'));
    }
    
    return const Right(true);
  }
} 