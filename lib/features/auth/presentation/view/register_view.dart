import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jerseyhub/app/service_locator/service_locator.dart';
import 'package:jerseyhub/core/widgets/football_shirts_logo.dart';
import 'package:jerseyhub/features/auth/domain/use_case/user_register_usecase.dart';
import 'package:jerseyhub/features/auth/presentation/view/login_view.dart';
import 'package:jerseyhub/features/auth/presentation/view_model/signup_view_model/signup_event.dart';
import 'package:jerseyhub/features/auth/presentation/view_model/signup_view_model/signup_state.dart';
import 'package:jerseyhub/features/auth/presentation/view_model/signup_view_model/signup_view_model.dart';
import 'package:jerseyhub/core/theme/theme_manager.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView>
    with TickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isPasswordVisible = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _showAlertDialog(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _register(BuildContext context, RegisterViewModel viewModel) {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final address = _addressController.text.trim();

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        address.isEmpty) {
      _showAlertDialog(
        context,
        title: "Missing Fields",
        content: "Please fill in all the fields before registering.",
      );
      return;
    }

    if (password.length < 6) {
      _showAlertDialog(
        context,
        title: "Weak Password",
        content: "Password must be at least 6 characters long.",
      );
      return;
    }

    viewModel.add(
      RegisterUserEvent(
        context: context,
        username: username,
        email: email,
        password: password,
        address: address,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterViewModel(serviceLocator<UserRegisterUsecase>()),
      child: Builder(
        builder: (context) {
          return BlocListener<RegisterViewModel, RegisterState>(
            listener: (context, state) {
              if (state.isSuccess) {
                _usernameController.clear();
                _emailController.clear();
                _passwordController.clear();
                _addressController.clear();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Registration successful! Please login.',
                    ),
                    backgroundColor: Colors.green.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginView()),
                );
              }
            },
            child: BlocBuilder<RegisterViewModel, RegisterState>(
              builder: (context, state) {
                return Scaffold(
                  body: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.indigo.shade900,
                          Colors.purple.shade800,
                          Colors.blue.shade900,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Logo/Brand Section
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        const FootballShirtsLogo(
                                          size: 180,
                                          textColor: Colors.white,
                                          iconColor: Colors.white,
                                        ),
                                        const SizedBox(height: 15),
                                        Text(
                                          'Join Our Community!',
                                          style: TextStyle(
                                            color: _getTextColorForGradient(
                                              context,
                                            ).withOpacity(0.8),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 40),

                                  // Username Field
                                  _buildInputField(
                                    controller: _usernameController,
                                    hintText: "Enter Username",
                                    icon: Icons.person_outline,
                                    key: const Key('usernameField'),
                                  ),

                                  const SizedBox(height: 20),

                                  // Email Field
                                  _buildInputField(
                                    controller: _emailController,
                                    hintText: "Enter Email",
                                    icon: Icons.email_outlined,
                                    key: const Key('emailField'),
                                  ),

                                  const SizedBox(height: 20),

                                  // Password Field
                                  _buildPasswordField(),

                                  const SizedBox(height: 20),

                                  // Address Field
                                  _buildInputField(
                                    controller: _addressController,
                                    hintText: "Enter Address",
                                    icon: Icons.location_on_outlined,
                                    key: const Key('addressField'),
                                  ),

                                  const SizedBox(height: 30),

                                  // SignUp Button
                                  _buildSignUpButton(context, state),

                                  const SizedBox(height: 30),

                                  // Login Link
                                  _buildLoginLink(context),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required Key key,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25), // More visible background
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.8), // Very visible border
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        key: key,
        controller: controller,
        style: TextStyle(
          color: Colors.black, // Black text for contrast on white background
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.black.withOpacity(0.6), // Dark grey hint text
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.black.withOpacity(0.7), // Dark grey icon
            size: 24,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25), // More visible background
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.8), // Very visible border
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        key: const Key('passwordField'),
        controller: _passwordController,
        obscureText: !_isPasswordVisible,
        style: TextStyle(
          color: Colors.black, // Black text for contrast on white background
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: "Enter Password",
          hintStyle: TextStyle(
            color: Colors.black.withOpacity(0.6), // Dark grey hint text
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.lock_outline,
            color: Colors.black.withOpacity(0.7), // Dark grey icon
            size: 24,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.black.withOpacity(0.7), // Dark grey icon
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpButton(BuildContext context, RegisterState state) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        key: const Key('signUpButton'),
        onPressed: state.isLoading
            ? null
            : () => _register(context, context.read<RegisterViewModel>()),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: state.isLoading
            ? const CircularProgressIndicator(
                color: Colors.black,
                strokeWidth: 2,
              )
            : const Text(
                'Sign Up',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Already have an account?",
            style: TextStyle(
              color: _getTextColorForGradient(context).withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginView()),
              );
            },
            child: Text(
              "Login",
              style: TextStyle(
                color: _getAccentColorForGradient(context),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get appropriate text color for gradient background
  Color _getTextColorForGradient(BuildContext context) {
    final themeManager = ThemeManager();
    if (themeManager.isDarkMode) {
      return Colors.white; // White text for dark mode on gradient
    } else {
      return Colors
          .white; // White text for light mode on gradient (better contrast)
    }
  }

  // Helper method to get accent color for gradient background
  Color _getAccentColorForGradient(BuildContext context) {
    final themeManager = ThemeManager();
    if (themeManager.isDarkMode) {
      return Colors.yellow.shade300; // Yellow accent for dark mode
    } else {
      return Colors.yellow.shade300; // Yellow accent for light mode
    }
  }
}
