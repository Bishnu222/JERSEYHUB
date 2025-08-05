import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jerseyhub/app/service_locator/service_locator.dart';
import 'package:jerseyhub/app/shared_prefs/user_shared_prefs.dart';
import 'package:jerseyhub/features/auth/presentation/view/login_view.dart';
import 'package:jerseyhub/features/auth/presentation/view_model/login_view_model/login_view_model.dart';
import 'package:jerseyhub/features/profile/domain/entity/profile_entity.dart';
import 'package:jerseyhub/features/profile/domain/use_case/change_password_usecase.dart';
import 'package:jerseyhub/features/profile/presentation/viewmodel/profile_event.dart';
import 'package:jerseyhub/features/profile/presentation/viewmodel/profile_state.dart';
import 'package:jerseyhub/features/profile/presentation/viewmodel/profile_viewmodel.dart';

class ProfileView extends StatefulWidget {
  final String userId;

  const ProfileView({super.key, required this.userId});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    // Load saved profile image URL from SharedPreferences
    _loadSavedProfileImage();

    // Debug: Print current user data
    final userSharedPrefs = serviceLocator<UserSharedPrefs>();
    userSharedPrefs.printCurrentUserData();
    print('🔍 ProfileView: Loading profile for user ID: ${widget.userId}');

    // Load profile data when view initializes
    context.read<ProfileViewModel>().add(GetProfileEvent(widget.userId));
  }

  void _loadSavedProfileImage() {
    final userSharedPrefs = serviceLocator<UserSharedPrefs>();
    final savedImageUrl = userSharedPrefs.getProfileImageUrl();
    if (savedImageUrl != null && savedImageUrl.isNotEmpty) {
      setState(() {
        _profileImageUrl = savedImageUrl;
      });
      print('📸 Loaded saved profile image URL: $savedImageUrl');

      // Check if it's a local file path
      if (savedImageUrl.contains('\\') ||
          savedImageUrl.startsWith('C:') ||
          savedImageUrl.startsWith('D:') ||
          savedImageUrl.startsWith('E:') ||
          savedImageUrl.startsWith('/')) {
        print('📸 This is a LOCAL file path - should be preserved!');
      }
    } else {
      print('📸 No saved image URL found in SharedPreferences');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ProfileViewModel, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            _populateFields(state.profile);
          } else if (state is ProfileUpdated) {
            _populateFields(state.profile);
            _showSuccessSnackBar('Profile updated successfully');
            // Refresh the profile to ensure we have the latest data
            context.read<ProfileViewModel>().add(
              GetProfileEvent(widget.userId),
            );
          } else if (state is ProfileImageUploaded) {
            // Save the image URL to SharedPreferences for persistence
            final userSharedPrefs = serviceLocator<UserSharedPrefs>();
            userSharedPrefs.setProfileImageUrl(state.imageUrl);

            // Don't update the image URL if it's a simulated response
            // Keep the local file path for immediate display
            if (!state.imageUrl.contains('simulated_profile_image_')) {
              setState(() {
                _profileImageUrl = state.imageUrl;
              });
            }
            _showSuccessSnackBar('Profile image uploaded successfully');

            // Update the profile with the new image URL
            final currentState = context.read<ProfileViewModel>().state;
            ProfileEntity? currentProfile;

            if (currentState is ProfileLoaded) {
              currentProfile = currentState.profile;
            } else if (currentState is ProfileUpdated) {
              currentProfile = currentState.profile;
            }

            if (currentProfile != null) {
              final updatedProfile = ProfileEntity(
                id: currentProfile.id,
                email: currentProfile.email,
                username: currentProfile.username,
                address: currentProfile.address,
                phoneNumber: currentProfile.phoneNumber,
                profileImage: state.imageUrl,
                createdAt: currentProfile.createdAt,
                updatedAt: DateTime.now(),
              );

              print(
                '🔄 Updating profile with new image URL: ${state.imageUrl}',
              );
              context.read<ProfileViewModel>().add(
                UpdateProfileEvent(updatedProfile),
              );
            }
          } else if (state is PasswordChanged) {
            _showSuccessSnackBar('Password changed successfully');
          } else if (state is ProfileError) {
            _showErrorSnackBar(state.message);
          }
        },
        child: BlocBuilder<ProfileViewModel, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  _buildProfileInfo(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: _getProfileImage(),
                backgroundColor: _hasUploadedImage()
                    ? Colors.green.shade100
                    : Colors.grey.shade300,
                child: _getProfileImageChild(),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    onPressed: _pickImage,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _nameController.text.isNotEmpty
                ? _nameController.text
                : 'User Name',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            _emailController.text.isNotEmpty
                ? _emailController.text
                : 'user@example.com',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Name', _nameController.text),
            _buildInfoRow('Email', _emailController.text),
            _buildInfoRow('Address', _addressController.text),
            _buildInfoRow('Phone', _phoneController.text),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Not specified',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showEditDialog(),
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showChangePasswordDialog(),
            icon: const Icon(Icons.lock),
            label: const Text('Change Password'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showLogoutDialog(),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _populateFields(ProfileEntity profile) {
    setState(() {
      _nameController.text = profile.username;
      _emailController.text = profile.email;
      _addressController.text = profile.address;
      _phoneController.text = profile.phoneNumber ?? '';

      // NEVER let backend overwrite local image paths - this is the key fix
      final userSharedPrefs = serviceLocator<UserSharedPrefs>();
      final savedImageUrl = userSharedPrefs.getProfileImageUrl();

      // If we have ANY saved image URL, use it and ignore backend completely
      if (savedImageUrl != null && savedImageUrl.isNotEmpty) {
        _profileImageUrl = savedImageUrl;
        print('📸 USING SAVED IMAGE URL (ignoring backend): $savedImageUrl');

        // Check if it's a local file path
        if (savedImageUrl.contains('\\') ||
            savedImageUrl.startsWith('C:') ||
            savedImageUrl.startsWith('D:') ||
            savedImageUrl.startsWith('E:') ||
            savedImageUrl.startsWith('/')) {
          print('📸 This is a LOCAL file path - will show actual image!');
        }
        return; // Exit early - don't let backend overwrite anything
      }

      // Only use backend if we have no saved URL at all
      if (profile.profileImage != null && profile.profileImage!.isNotEmpty) {
        _profileImageUrl = profile.profileImage;
        userSharedPrefs.setProfileImageUrl(profile.profileImage!);
        print(
          '📸 Using image from backend (no saved URL): ${profile.profileImage}',
        );
      }
    });
  }

  ImageProvider? _getProfileImage() {
    if (_profileImageUrl == null || _profileImageUrl!.isEmpty) {
      return null;
    }

    // Check if it's a network URL
    if (_profileImageUrl!.startsWith('http://') ||
        _profileImageUrl!.startsWith('https://')) {
      return NetworkImage(_profileImageUrl!);
    }

    // Check if it's a local file path (including Windows paths)
    if (_profileImageUrl!.startsWith('/') ||
        _profileImageUrl!.contains('\\') ||
        _profileImageUrl!.startsWith('C:') ||
        _profileImageUrl!.startsWith('D:') ||
        _profileImageUrl!.startsWith('E:')) {
      try {
        final file = File(_profileImageUrl!);
        if (file.existsSync()) {
          print('📸 Loading local image: $_profileImageUrl');
          return FileImage(file);
        } else {
          print('📸 File does not exist: $_profileImageUrl');
          return null;
        }
      } catch (e) {
        print('📸 Error loading local image: $e');
        return null;
      }
    }

    // For simulated images, return null to show checkmark
    if (_profileImageUrl!.contains('simulated_profile_image_')) {
      print(
        '📸 Simulated image detected, showing checkmark: $_profileImageUrl',
      );
      return null;
    }

    // For other cases, return null to show default icon
    print('📸 Profile image URL format not recognized: $_profileImageUrl');
    return null;
  }

  bool _hasUploadedImage() {
    return _profileImageUrl != null && _profileImageUrl!.isNotEmpty;
  }

  Widget? _getProfileImageChild() {
    if (_profileImageUrl == null || _profileImageUrl!.isEmpty) {
      return const Icon(Icons.person, size: 60, color: Colors.grey);
    }

    // If we have a valid image provider, show the image
    if (_getProfileImage() != null) {
      return null; // Let the backgroundImage handle it
    }

    // For local files that couldn't be loaded, show an error icon
    if (_profileImageUrl!.contains('\\') ||
        _profileImageUrl!.startsWith('C:') ||
        _profileImageUrl!.startsWith('D:') ||
        _profileImageUrl!.startsWith('E:')) {
      return const Icon(Icons.error, size: 60, color: Colors.orange);
    }

    // For simulated images, show a checkmark (only if no local file path)
    if (_profileImageUrl!.contains('simulated_profile_image_')) {
      return const Icon(Icons.check_circle, size: 60, color: Colors.green);
    }

    // Default fallback
    return const Icon(Icons.person, size: 60, color: Colors.grey);
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      print('📸 Selected image path: ${image.path}');

      // Immediately show the selected image
      setState(() {
        _profileImageUrl = image.path;
      });

      print('📸 Set profile image URL to: $_profileImageUrl');

      // Then upload it
      context.read<ProfileViewModel>().add(UploadProfileImageEvent(image.path));
    }
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(onPressed: _saveProfile, child: const Text('Save')),
          ],
        );
      },
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // Get the current profile state to preserve original data
      final currentState = context.read<ProfileViewModel>().state;
      ProfileEntity? currentProfile;

      if (currentState is ProfileLoaded) {
        currentProfile = currentState.profile;
      } else if (currentState is ProfileUpdated) {
        currentProfile = currentState.profile;
      }

      final updatedProfile = ProfileEntity(
        id: widget.userId,
        email: _emailController.text,
        username: _nameController.text,
        address: _addressController.text,
        phoneNumber: _phoneController.text,
        profileImage: _profileImageUrl,
        createdAt: currentProfile?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      print(
        '🔄 Saving profile update: ${updatedProfile.username}, ${updatedProfile.email}',
      );
      context.read<ProfileViewModel>().add(UpdateProfileEvent(updatedProfile));
      Navigator.of(context).pop();
    }
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newPasswordController.text ==
                        confirmPasswordController.text &&
                    newPasswordController.text.isNotEmpty) {
                  context.read<ProfileViewModel>().add(
                    ChangePasswordEvent(
                      ChangePasswordParams(
                        currentPassword: currentPasswordController.text,
                        newPassword: newPasswordController.text,
                      ),
                    ),
                  );
                  Navigator.of(context).pop();
                } else {
                  _showErrorSnackBar('Passwords do not match');
                }
              },
              child: const Text('Change Password'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Clear user session
                final userSharedPrefs = serviceLocator<UserSharedPrefs>();
                await userSharedPrefs.clearUserData();

                // Navigate to login screen
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => serviceLocator<LoginViewModel>(),
                      child: const LoginView(),
                    ),
                  ),
                  (route) => false, // Remove all previous routes
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
