import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jerseyhub/app/service_locator/service_locator.dart';
import 'package:jerseyhub/app/shared_prefs/user_shared_prefs.dart';
import 'package:jerseyhub/features/cart/presentation/view/cart_view.dart';
import 'package:jerseyhub/features/cart/presentation/viewmodel/cart_viewmodel.dart';
import 'package:jerseyhub/features/order/presentation/view/order_list_view.dart';
import 'package:jerseyhub/features/order/presentation/viewmodel/order_viewmodel.dart';
import 'package:jerseyhub/features/product/presentation/view/product_list_view.dart';
import 'package:jerseyhub/features/product/presentation/viewmodel/product_viewmodel.dart';
import 'package:jerseyhub/features/profile/presentation/view/profile_view.dart';
import 'package:jerseyhub/features/profile/presentation/viewmodel/profile_viewmodel.dart';
import 'package:jerseyhub/features/notification/presentation/view/notification_list_view.dart';
import 'package:jerseyhub/features/notification/presentation/bloc/notification_bloc.dart';
// import 'package:jerseyhub/core/sensors/proximity_sensor_service.dart';  // Removed sensor functionality
// import 'package:jerseyhub/core/sensors/home_shake_sensor_service.dart';  // Removed sensor functionality
import 'package:jerseyhub/core/theme/theme_manager.dart';
import 'package:jerseyhub/core/widgets/asset_test_widget.dart';
import 'package:jerseyhub/features/auth/presentation/view/login_view.dart';
import 'package:jerseyhub/features/auth/presentation/view_model/login_view_model/login_view_model.dart';
import 'package:jerseyhub/app/services/sensor_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late final CartViewModel _cartViewModel;
  late final ThemeManager _themeManager;
  late final SensorService _sensorService;
  bool _isRefreshing = false; // Track refresh state for visual feedback

  final List<String> _titles = ['', '', '', '', 'Profile'];

  @override
  void initState() {
    super.initState();
    _cartViewModel = serviceLocator<CartViewModel>();
    _themeManager = ThemeManager();
    _sensorService = serviceLocator<SensorService>();

    // Initialize sensor callbacks for home page
    _initializeSensorCallbacks();
  }

  // Future<void> _initializeSensors() async {  // REMOVED SENSOR FUNCTIONALITY
  //   try {
  //     // Initialize proximity sensor
  //     await _proximitySensorService.initialize();
  //     final isProximityAvailable = await _proximitySensorService.isAvailable();

  //     if (isProximityAvailable) {
  //       print('📱 Proximity sensor available on home page');

  //       // Start listening to proximity changes
  //       _proximitySensorService.startListening(
  //         onChanged: (bool isNear) {
  //           print(
  //             '📱 Proximity sensor on home page: ${isNear ? "Hand NEAR" : "Hand FAR"}',
  //           );

  //           // Control app theme based on proximity
  //           if (isNear) {
  //             // Hand near camera - enable dark mode
  //             _themeManager.setDarkMode(true);
  //             print('🌙 Dark mode enabled via proximity sensor');
  //           } else {
  //             // Hand far from camera - enable light mode
  //             _themeManager.setDarkMode(false);
  //             print('☀️ Light mode enabled via proximity sensor');
  //           }
  //         },
  //       );

  //       print('🎧 Proximity sensor listening started on home page');
  //     } else {
  //       print('❌ Proximity sensor not available on home page');
  //     }

  //     // Initialize shake sensor
  //     await _shakeSensorService.initialize();
  //     final isShakeAvailable = await _shakeSensorService.isAvailable();

  //     if (isShakeAvailable) {
  //       print('📱 Shake sensor available on home page');

  //       // Start listening to shake events
  //       _shakeSensorService.startListening(
  //         onShake: () {
  //           print('📱 Shake detected on home page! Refreshing current page...');
  //           _refreshCurrentPage();
  //         },
  //       );

  //       print('🎧 Shake sensor listening started on home page');
  //     } else {
  //       print('❌ Shake sensor not available on home page');
  //     }
  //   } catch (e) {
  //     print('❌ Error initializing sensors on home page: $e');
  //   }
  // }

  // void _refreshCurrentPage() {  // REMOVED - Only used by sensors
  //   // Refresh specific content based on current tab
  //   switch (_selectedIndex) {
  //     case 0: // Products
  //       final productViewModel = serviceLocator<ProductViewModel>();
  //       productViewModel.add(LoadAllProductsEvent());
  //       break;
  //     case 1: // Cart - Remove this to prevent infinite refresh
  //       // _cartViewModel.add(LoadCartEvent()); // Commented out to prevent infinite refresh
  //       break;
  //     case 2: // Orders
  //       final orderViewModel = serviceLocator<OrderViewModel>();
  //       final userSharedPrefs = serviceLocator<UserSharedPrefs>();
  //       final userId = userSharedPrefs.getCurrentUserId() ?? 'unknown_user';
  //       orderViewModel.add(LoadAllOrdersEvent(userId: userId));
  //       break;
  //     case 3: // Notifications
  //       final notificationBloc = serviceLocator<NotificationBloc>();
  //       final userSharedPrefs = serviceLocator<UserSharedPrefs>();
  //       final userId = userSharedPrefs.getCurrentUserId() ?? 'unknown_user';
  //       notificationBloc.add(LoadNotifications(userId));
  //       break;
  //     case 4: // Profile
  //       // Profile doesn't need refresh
  //       break;
  //   }

  //   print('🔄 Current page refreshed via shake sensor');
  // }

  @override
  void dispose() {
    super.dispose();
  }

  void _initializeSensorCallbacks() {
    // Update sensor service callbacks for home page specific functionality
    _sensorService.initialize(
      onShakeDetected: () {
        print('📱 Shake detected on home page! Refreshing current page...');
        _showRefreshFeedback();
        _refreshCurrentPage();
      },
      onThemeChanged: (isDarkMode) {
        print(
          '🎨 Theme changed on home page: ${isDarkMode ? "Dark" : "Light"}',
        );
        _themeManager.setDarkMode(isDarkMode);
      },
      onBrightnessChanged: (brightness) {
        print(
          '💡 Brightness changed on home page: ${(brightness * 100).toStringAsFixed(0)}%',
        );
      },
    );
  }

  void _showRefreshFeedback() {
    setState(() {
      _isRefreshing = true;
    });

    // Show refresh feedback for 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    });

    // Show snackbar feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.refresh, color: Colors.white),
              const SizedBox(width: 8),
              Text('Refreshing ${_getCurrentTabName()}...'),
            ],
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );
    }
  }

  String _getCurrentTabName() {
    switch (_selectedIndex) {
      case 0:
        return 'Products';
      case 1:
        return 'Cart';
      case 2:
        return 'Orders';
      case 3:
        return 'Notifications';
      case 4:
        return 'Profile';
      default:
        return 'Page';
    }
  }

  void _refreshCurrentPage() {
    try {
      // Refresh specific content based on current tab
      switch (_selectedIndex) {
        case 0: // Products
          final productViewModel = serviceLocator<ProductViewModel>();
          productViewModel.add(LoadAllProductsEvent());
          print('🔄 Refreshing Products tab');
          break;
        case 1: // Cart - Skip refresh to prevent infinite loops
          print('🔄 Cart tab refresh skipped (prevents infinite loops)');
          break;
        case 2: // Orders
          final orderViewModel = serviceLocator<OrderViewModel>();
          orderViewModel.add(const LoadAllOrdersEvent());
          print('🔄 Refreshing Orders tab');
          break;
        case 3: // Notifications
          final notificationBloc = serviceLocator<NotificationBloc>();
          final userSharedPrefs = serviceLocator<UserSharedPrefs>();
          final userId = userSharedPrefs.getCurrentUserId() ?? 'unknown_user';
          notificationBloc.add(LoadNotifications(userId));
          print('🔄 Refreshing Notifications tab');
          break;
        case 4: // Profile - No refresh needed
          print('🔄 Profile tab refresh skipped (no refresh needed)');
          break;
      }

      print('✅ Current page refreshed successfully via shake sensor');
    } catch (e) {
      print('❌ Error refreshing current page: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Connect to notification socket when notifications tab is selected
    if (index == 3) {
      final userSharedPrefs = serviceLocator<UserSharedPrefs>();
      final userId = userSharedPrefs.getCurrentUserId();
      if (userId != null && userId.isNotEmpty) {
        final notificationBloc = serviceLocator<NotificationBloc>();
        notificationBloc.add(ConnectToSocket(userId));
        notificationBloc.add(LoadNotifications(userId));
      }
    }
  }

  Widget _buildProfilePage() {
    final userSharedPrefs = serviceLocator<UserSharedPrefs>();
    final userId = userSharedPrefs.getCurrentUserId();

    print('🔍 HomePage: Building profile page with user ID: $userId');

    if (userId == null || userId.isEmpty || userId == 'unknown_user') {
      print('❌ HomePage: No valid user ID found, showing login prompt');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Please log in to view your profile',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => serviceLocator<LoginViewModel>(),
                      child: const LoginView(),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      );
    }

    print('✅ HomePage: Valid user ID found, building profile view');
    return BlocProvider(
      create: (context) => serviceLocator<ProfileViewModel>(),
      child: ProfileView(userId: userId),
    );
  }

  Widget _buildProtectedTab(Widget child, String tabName) {
    final userSharedPrefs = serviceLocator<UserSharedPrefs>();
    final userId = userSharedPrefs.getCurrentUserId();

    // Check if user is logged in and has a valid user ID
    if (userId == null || userId.isEmpty || userId == 'unknown_user') {
      // User is not logged in, show login prompt
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              tabName == 'Orders' ? Icons.shopping_bag : Icons.notifications,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Please log in to view your $tabName',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => serviceLocator<LoginViewModel>(),
                      child: const LoginView(),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      );
    }

    return child;
  }

  @override
  Widget build(BuildContext context) {
    final notificationBloc = serviceLocator<NotificationBloc>();

    final List<Widget> pages = [
      BlocProvider(
        create: (context) => serviceLocator<ProductViewModel>(),
        child: const ProductListView(),
      ),
      BlocProvider.value(
        value: _cartViewModel,
        child: CartView(
          onShopNowPressed: () {
            setState(() {
              _selectedIndex = 0; // Switch to home/products tab
            });
          },
        ),
      ),
      _buildProtectedTab(
        BlocProvider(
          create: (context) => serviceLocator<OrderViewModel>(),
          child: OrderListView(
            onShopNowPressed: () {
              setState(() {
                _selectedIndex = 0; // Switch to home/products tab
              });
            },
          ),
        ),
        'Orders',
      ),
      _buildProtectedTab(
        BlocProvider.value(
          value: notificationBloc,
          child: const NotificationListView(),
        ),
        'Notifications',
      ),
      _buildProfilePage(),
    ];

    return BlocProvider.value(
      value: notificationBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_titles[_selectedIndex]),
          backgroundColor: Theme.of(context).primaryColor,
          actions: [
            // Sensor test button
            // IconButton(  // Removed sensor functionality
            //   onPressed: () {
            //     Navigator.of(context).push(
            //       MaterialPageRoute(
            //         builder: (context) => const SensorTestWidget(),
            //       ),
            //     );
            //   },
            //   icon: const Icon(Icons.sensors, color: Colors.white),
            //   tooltip: 'Test Sensors',
            // ),
            // Asset test button
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AssetTestWidget(),
                  ),
                );
              },
              icon: const Icon(Icons.image, color: Colors.white),
              tooltip: 'Test Assets',
            ),
            // Theme indicator in app bar
            ListenableBuilder(
              listenable: _themeManager,
              builder: (context, child) {
                return Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: Icon(
                    _themeManager.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ],
        ),
        body: pages[_selectedIndex],
        floatingActionButton: _selectedIndex != 3
            ? BlocBuilder<NotificationBloc, NotificationState>(
                builder: (context, state) {
                  if (state is NotificationsLoaded && state.unreadCount > 0) {
                    return FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 3; // Switch to notifications tab
                        });
                      },
                      backgroundColor: Colors.red,
                      child: Stack(
                        children: [
                          const Icon(Icons.notifications, color: Colors.white),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Text(
                                '${state.unreadCount}',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              )
            : null,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag),
              label: 'Orders',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Notifications',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
