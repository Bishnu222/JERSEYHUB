import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../../core/error/failure.dart';
import '../../../domain/entity/user_entity.dart';
import '../../../domain/repository/user_repository.dart';
import '../../data_source/user_data_source.dart';

class UserLocalRepository implements IUserRepository {
  final IUserDataSource _dataSource;

  UserLocalRepository({required IUserDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser(String id) {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, String>> loginUser(String email, String password) {
    // TODO: implement loginUser
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> registerUser(UserEntity user) {
    // TODO: implement registerUser
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, String>> uploadProfilePicture(File file) {
    // TODO: implement uploadProfilePicture
    throw UnimplementedError();
  }

 
}