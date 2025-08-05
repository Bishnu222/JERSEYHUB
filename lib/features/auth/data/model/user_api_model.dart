import 'package:equatable/equatable.dart';
import 'package:jerseyhub/features/auth/domain/entity/user_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_api_model.g.dart';

@JsonSerializable()
class UserApiModel extends Equatable {
  @JsonKey(name: '_id')
  final String? id;
  final String email;
  final String username;
  @JsonKey(
    includeFromJson: false,
    includeToJson: true,
  ) // Include password in toJson (for registration) but exclude from fromJson (for login responses)
  final String? password;
  final String address;
  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  ) // Ignore additional fields
  final String? phoneNumber;
  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  ) // Ignore additional fields
  final String? profileImage;
  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  ) // Ignore additional fields
  final String? role;
  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  ) // Ignore additional fields
  final String? createdAt;
  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  ) // Ignore additional fields
  final String? updatedAt;
  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  ) // Ignore additional fields
  final int? version;

  const UserApiModel({
    this.id,
    required this.email,
    required this.username,
    this.password, // Make it nullable
    required this.address,
    this.phoneNumber,
    this.profileImage,
    this.role,
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  /// JSON -> Model
  factory UserApiModel.fromJson(Map<String, dynamic> json) =>
      _$UserApiModelFromJson(json);

  /// Model -> JSON
  Map<String, dynamic> toJson() => _$UserApiModelToJson(this);

  /// Model -> Entity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      username: username,
      password: password ?? '', // Handle nullable password
      address: address,
    );
  }

  /// Entity -> Model
  factory UserApiModel.fromEntity(UserEntity entity) {
    return UserApiModel(
      id: entity.id,
      email: entity.email,
      username: entity.username,
      password: entity.password,
      address: entity.address,
    );
  }

  @override
  List<Object?> get props => [id, email, username, password, address];
}
