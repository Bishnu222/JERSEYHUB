import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jerseyhub/app/service_locator/service_locator.dart';
import 'package:jerseyhub/features/splash/presentation/view/splash_view.dart';
import 'package:jerseyhub/features/splash/presentation/view_model/splash_view_model.dart';
import 'package:jerseyhub/core/theme/theme_manager.dart';
import 'package:jerseyhub/app/services/sensor_service.dart';
import 'package:jerseyhub/app/services/theme_service.dart';

// Global key for ScaffoldMessenger to show notifications throughout the app
final GlobalKey<ScaffoldMessengerState> globalScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initDependencies(); // Initialize all dependencies before running app

  // Initialize sensor service with callbacks
  final sensorService = serviceLocator<SensorService>();
  final themeService = serviceLocator<ThemeService>();

  sensorService.initialize(
    onShakeDetected: () {
      print('📱 Shake detected - refreshing home page');
      // This will be handled in the home page
    },
    onThemeChanged: (isDarkMode) {
      print('🎨 Theme changed via sensor: ${isDarkMode ? "Dark" : "Light"}');
      ThemeManager().setDarkMode(isDarkMode);
    },
    onBrightnessChanged: (brightness) {
      print('💡 Brightness changed: ${(brightness * 100).toStringAsFixed(0)}%');
    },
    onProximityChanged: (isNear) {
      print('📱 Proximity changed: ${isNear ? "NEAR" : "FAR"}');
      // Theme change is handled automatically in the sensor service
    },
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => serviceLocator<SplashViewModel>()),
        // You can add more BlocProviders here if needed
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeManager(),
      builder: (context, child) {
        return MaterialApp(
          title: 'Jersey Hub',
          debugShowCheckedModeBanner: false,
          theme: ThemeManager().getTheme(),
          scaffoldMessengerKey: globalScaffoldMessengerKey,
          home: BlocProvider(
            create: (context) => serviceLocator<SplashViewModel>(),
            child: const SplashScreenView(),
          ),
        );
      },
    );
  }
}
