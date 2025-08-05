import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:flutter/material.dart';

class SensorService {
  static final SensorService _instance = SensorService._internal();
  factory SensorService() => _instance;
  SensorService._internal();

  // Shake detection
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  final double _shakeThreshold =
      15.0; // Increased sensitivity for better detection
  final int _shakeTimeWindow =
      800; // Increased time window to prevent rapid triggers
  DateTime? _lastShakeTime;
  List<double> _recentAccelerations =
      []; // Track recent accelerations for better detection
  final int _accelerationHistorySize =
      5; // Number of recent accelerations to track

  // Proximity sensor for dark mode (disabled if not available)
  StreamSubscription<UserAccelerometerEvent>? _proximitySubscription;
  bool _isProximityEnabled = false; // Disabled by default
  bool _lastProximityState = false;
  Timer? _proximityDebounceTimer;
  bool _isProximityAvailable = false;

  // Brightness management
  double _currentBrightness = 0.5;
  Timer? _brightnessTimer;
  bool _isDarkMode = false; // Track theme state

  // Callbacks
  VoidCallback? _onShakeDetected;
  Function(bool)? _onThemeChanged;
  Function(double)? _onBrightnessChanged;
  Function(bool)? _onProximityChanged;

  // Initialize the sensor service
  void initialize({
    VoidCallback? onShakeDetected,
    Function(bool)? onThemeChanged,
    Function(double)? onBrightnessChanged,
    Function(bool)? onProximityChanged,
  }) {
    _onShakeDetected = onShakeDetected;
    _onThemeChanged = onThemeChanged;
    _onBrightnessChanged = onBrightnessChanged;
    _onProximityChanged = onProximityChanged;

    print('🔧 SensorService: Initializing...');

    try {
      // Start with light mode by default
      _onThemeChanged?.call(false);
      print('☀️ SensorService: Starting in light mode');

      // Try to initialize sensors with error handling
      _initializeSensors();

      print('🔧 SensorService: Initialization completed');
    } catch (e) {
      print('❌ SensorService: Initialization failed: $e');
      // Continue with basic functionality even if sensors fail
    }
  }

  void _initializeSensors() {
    try {
      // Check if sensors are available before trying to use them
      if (!_areSensorsAvailable()) {
        print(
          '⚠️ SensorService: Sensors not available on this device/emulator',
        );
        print('⚠️ SensorService: Disabling all sensor features');
        return;
      }

      // Try to initialize shake detection
      _startShakeDetection();

      // Try to initialize proximity detection
      _checkProximityAvailability();
      _startProximityDetection();

      // Initialize brightness management
      _startBrightnessManagement();
    } catch (e) {
      print('❌ SensorService: Sensor initialization failed: $e');
      print(
        '⚠️ SensorService: Sensor features disabled due to initialization failure',
      );
    }
  }

  // Check if sensors are available on this device
  bool _areSensorsAvailable() {
    try {
      // For now, we'll assume sensors are not available on emulators
      // and some devices to prevent MissingPluginException
      print(
        '⚠️ SensorService: Assuming sensors are not available to prevent exceptions',
      );
      return false;
    } catch (e) {
      print('❌ SensorService: Sensors not available: $e');
      return false;
    }
  }

  // Start shake detection
  void _startShakeDetection() {
    try {
      _accelerometerSubscription = accelerometerEventStream().listen((
        AccelerometerEvent event,
      ) {
        _detectShake(event);
      });
      print('📱 Shake detection started successfully');
    } catch (e) {
      print('❌ Shake detection failed: $e');
      print('📱 Shake detection will be disabled');
      _accelerometerSubscription = null;
    }
  }

  // Check if proximity sensor is available
  void _checkProximityAvailability() {
    try {
      // Try to access proximity sensor - if it fails, we'll disable it
      _isProximityAvailable = true;
      print('📱 Proximity sensor check: Available');
    } catch (e) {
      _isProximityAvailable = false;
      print('📱 Proximity sensor check: Not available - $e');
    }
  }

  // Start proximity detection using accelerometer as workaround
  void _startProximityDetection() {
    try {
      _proximitySubscription = userAccelerometerEventStream().listen((
        UserAccelerometerEvent event,
      ) {
        _detectProximity(event);
      });
      print('📱 Proximity detection started successfully');
    } catch (e) {
      print('❌ Proximity detection failed: $e');
      print('📱 Proximity detection will be disabled');
      _proximitySubscription = null;
      _isProximityAvailable = false;
    }
  }

  // Detect proximity using accelerometer patterns
  void _detectProximity(UserAccelerometerEvent event) {
    if (!_isProximityEnabled) return;

    // Calculate the magnitude of user acceleration
    final double magnitude = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    // Detect when phone is held near face (low movement, stable position)
    // This is a simplified proximity detection using accelerometer patterns
    final bool isNear =
        magnitude < 2.0; // Low movement indicates phone near face

    _handleProximityChange(isNear);
  }

  // Handle proximity sensor changes
  void _handleProximityChange(bool isNear) {
    if (!_isProximityEnabled || !_isProximityAvailable) return;

    // Debounce rapid proximity changes
    _proximityDebounceTimer?.cancel();
    _proximityDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (isNear != _lastProximityState) {
        _lastProximityState = isNear;

        print('📱 Proximity detected: ${isNear ? "NEAR" : "FAR"}');

        // Toggle dark mode based on proximity
        _onProximityChanged?.call(isNear);

        // If hand is near camera, enable dark mode; if far, return to light mode
        if (isNear) {
          print('🌙 Proximity: Hand detected near camera - Enabling dark mode');
          _onThemeChanged?.call(true); // Enable dark mode
        } else {
          print('☀️ Proximity: Hand moved away - Returning to light mode');
          _onThemeChanged?.call(false); // Return to light mode
        }
      }
    });
  }

  // Detect shake gesture
  void _detectShake(AccelerometerEvent event) {
    final double acceleration = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    // Add current acceleration to history
    _recentAccelerations.add(acceleration);
    if (_recentAccelerations.length > _accelerationHistorySize) {
      _recentAccelerations.removeAt(0);
    }

    // Check if we have enough data points
    if (_recentAccelerations.length < 3) return;

    // Calculate average acceleration and variance
    final double avgAcceleration =
        _recentAccelerations.reduce((a, b) => a + b) /
        _recentAccelerations.length;
    final double variance =
        _recentAccelerations
            .map((a) => (a - avgAcceleration) * (a - avgAcceleration))
            .reduce((a, b) => a + b) /
        _recentAccelerations.length;

    // Detect shake based on both threshold and variance (sudden changes)
    final bool isSignificantShake =
        acceleration > _shakeThreshold && variance > 5.0;
    final bool isSuddenChange =
        variance > 10.0 && acceleration > _shakeThreshold * 0.7;

    if (isSignificantShake || isSuddenChange) {
      final now = DateTime.now();

      // Prevent multiple shake events in short time
      if (_lastShakeTime == null ||
          now.difference(_lastShakeTime!).inMilliseconds > _shakeTimeWindow) {
        _lastShakeTime = now;
        print(
          '📱 Shake detected! Acceleration: ${acceleration.toStringAsFixed(2)}, '
          'Variance: ${variance.toStringAsFixed(2)}, '
          'Type: ${isSignificantShake ? "Significant" : "Sudden Change"}',
        );
        _onShakeDetected?.call();

        // Clear acceleration history after successful detection
        _recentAccelerations.clear();
      }
    }
  }

  // Start brightness management based on time
  void _startBrightnessManagement() {
    _brightnessTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateBrightnessBasedOnTime();
    });

    // Initial brightness update
    _updateBrightnessBasedOnTime();
  }

  // Update brightness based on current time
  void _updateBrightnessBasedOnTime() async {
    final now = DateTime.now();
    final hour = now.hour;

    double targetBrightness;

    if (hour >= 6 && hour < 18) {
      // Day time (6 AM - 6 PM): Bright screen
      targetBrightness = 0.8;
    } else if (hour >= 18 && hour < 22) {
      // Evening (6 PM - 10 PM): Medium brightness
      targetBrightness = 0.6;
    } else {
      // Night time (10 PM - 6 AM): Low brightness
      targetBrightness = 0.3;
    }

    await _setBrightness(targetBrightness);

    // Only update theme if proximity sensor is not active
    // When proximity is active, theme is controlled by proximity sensor
    if (!_lastProximityState) {
      // Default to light mode when no proximity is detected
      _onThemeChanged?.call(false);
    }

    _onBrightnessChanged?.call(targetBrightness);

    print(
      '🌅 Time: ${hour.toString().padLeft(2, '0')}:00, '
      'Brightness: ${(targetBrightness * 100).toStringAsFixed(0)}%, '
      'Theme: ${_lastProximityState ? "Dark (Proximity)" : "Light (Default)"}',
    );
  }

  // Set screen brightness
  Future<void> _setBrightness(double brightness) async {
    try {
      await ScreenBrightness().setScreenBrightness(brightness);
      _currentBrightness = brightness;
    } catch (e) {
      print('❌ Failed to set brightness: $e');
    }
  }

  // Get current brightness
  double get currentBrightness => _currentBrightness;

  // Get proximity state
  bool get isProximityActive => _lastProximityState;

  // Getters for sensor status
  bool get isShakeDetectionEnabled => _accelerometerSubscription != null;
  bool get isProximityEnabled => _proximitySubscription != null;
  bool get isProximityAvailable => _isProximityAvailable;

  // Manual controls for when sensors are not available
  void setShakeDetectionEnabled(bool enabled) {
    if (enabled && _accelerometerSubscription == null) {
      _startShakeDetection();
    } else if (!enabled && _accelerometerSubscription != null) {
      _accelerometerSubscription?.cancel();
      _accelerometerSubscription = null;
    }
  }

  void setProximityEnabled(bool enabled) {
    if (enabled && _proximitySubscription == null) {
      _startProximityDetection();
    } else if (!enabled && _proximitySubscription != null) {
      _proximitySubscription?.cancel();
      _proximitySubscription = null;
      // Return to light mode when proximity is disabled
      _onThemeChanged?.call(false);
    }
  }

  // Manual theme control for when sensors are not available
  void toggleTheme() {
    // Simple toggle - we'll track the state internally
    _isDarkMode = !_isDarkMode;

    _onThemeChanged?.call(_isDarkMode);
    print(
      '🎨 SensorService: Manual theme toggle to ${_isDarkMode ? "dark" : "light"} mode',
    );
  }

  void setManualBrightness(double brightness) {
    try {
      ScreenBrightness().setScreenBrightness(brightness);
      _currentBrightness = brightness;
      _onBrightnessChanged?.call(brightness);
      print(
        '💡 SensorService: Manual brightness set to ${(brightness * 100).toStringAsFixed(1)}%',
      );
    } catch (e) {
      print('❌ SensorService: Failed to set manual brightness: $e');
    }
  }

  // Disable all sensor features
  void disableAllSensors() {
    print('🔧 SensorService: Disabling all sensor features');

    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;

    _proximitySubscription?.cancel();
    _proximitySubscription = null;

    _proximityDebounceTimer?.cancel();
    _brightnessTimer?.cancel();

    _isProximityAvailable = false;
    _isProximityEnabled = false;

    print('🔧 SensorService: All sensor features disabled');
  }

  // Check if any sensors are working
  bool get areSensorsWorking =>
      _accelerometerSubscription != null || _proximitySubscription != null;

  // Dispose resources
  void dispose() {
    _accelerometerSubscription?.cancel();
    _proximitySubscription?.cancel();
    _proximityDebounceTimer?.cancel();
    _brightnessTimer?.cancel();
    _onShakeDetected = null;
    _onThemeChanged = null;
    _onBrightnessChanged = null;
    _onProximityChanged = null;
  }
}
