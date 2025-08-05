import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jerseyhub/features/profile/domain/use_case/change_password_usecase.dart';
import 'package:jerseyhub/features/profile/domain/use_case/get_profile_usecase.dart';
import 'package:jerseyhub/features/profile/domain/use_case/update_profile_usecase.dart';
import 'package:jerseyhub/features/profile/domain/use_case/upload_profile_image_usecase.dart';
import 'package:jerseyhub/features/profile/presentation/viewmodel/profile_event.dart';
import 'package:jerseyhub/features/profile/presentation/viewmodel/profile_state.dart';

class ProfileViewModel extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final UploadProfileImageUseCase uploadProfileImageUseCase;
  final ChangePasswordUseCase changePasswordUseCase;

  ProfileViewModel({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.uploadProfileImageUseCase,
    required this.changePasswordUseCase,
  }) : super(ProfileInitial()) {
    on<GetProfileEvent>(_onGetProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<UploadProfileImageEvent>(_onUploadProfileImage);
    on<ChangePasswordEvent>(_onChangePassword);
  }

  Future<void> _onGetProfile(
    GetProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    print('🔍 ProfileViewModel: Getting profile for user ID: ${event.userId}');

    try {
      final result = await getProfileUseCase(event.userId);

      result.fold(
        (failure) {
          print(
            '❌ ProfileViewModel: Failed to get profile - ${failure.message}',
          );
          emit(ProfileError(failure.message));
        },
        (profile) {
          print(
            '✅ ProfileViewModel: Successfully loaded profile for user: ${profile.username}',
          );
          print('🔍 ProfileViewModel: Profile user ID: ${profile.id}');
          print('🔍 ProfileViewModel: Requested user ID: ${event.userId}');
          emit(ProfileLoaded(profile));
        },
      );
    } catch (e) {
      print('❌ ProfileViewModel: Exception getting profile - $e');
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    print('🔄 ProfileViewModel: Updating profile...');
    emit(ProfileLoading());

    final result = await updateProfileUseCase(event.profile);

    result.fold(
      (failure) {
        print(
          '❌ ProfileViewModel: Failed to update profile - ${failure.message}',
        );
        emit(ProfileError(failure.message));
      },
      (updatedProfile) {
        print('✅ ProfileViewModel: Profile updated successfully');
        emit(ProfileUpdated(updatedProfile));
      },
    );
  }

  Future<void> _onUploadProfileImage(
    UploadProfileImageEvent event,
    Emitter<ProfileState> emit,
  ) async {
    print('📤 ProfileViewModel: Uploading profile image...');
    emit(ProfileLoading());

    final result = await uploadProfileImageUseCase(event.imagePath);

    result.fold(
      (failure) {
        print(
          '❌ ProfileViewModel: Failed to upload image - ${failure.message}',
        );
        emit(ProfileError(failure.message));
      },
      (imageUrl) {
        print('✅ ProfileViewModel: Image uploaded successfully: $imageUrl');
        emit(ProfileImageUploaded(imageUrl));
      },
    );
  }

  Future<void> _onChangePassword(
    ChangePasswordEvent event,
    Emitter<ProfileState> emit,
  ) async {
    print('🔐 ProfileViewModel: Changing password...');
    emit(ProfileLoading());

    final result = await changePasswordUseCase(event.params);

    result.fold(
      (failure) {
        print(
          '❌ ProfileViewModel: Failed to change password - ${failure.message}',
        );
        emit(ProfileError(failure.message));
      },
      (success) {
        print('✅ ProfileViewModel: Password changed successfully');
        emit(PasswordChanged());
      },
    );
  }
}
