import 'package:flutter/material.dart';
import 'package:jerseyhub/app/service_locator/service_locator.dart';
import 'package:jerseyhub/app/services/sensor_service.dart';
import 'package:jerseyhub/core/theme/theme_manager.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late final SensorService _sensorService;
  late final ThemeManager _themeManager;

  bool _shakeDetectionEnabled = true;
  bool _autoThemeEnabled = true;
  bool _autoBrightnessEnabled = true;
  bool _proximityEnabled = false;
  double _manualBrightness = 0.5;

  @override
  void initState() {
    super.initState();
    _sensorService = serviceLocator<SensorService>();
    _themeManager = ThemeManager();
    _loadSettings();
  }

  void _loadSettings() {
    // Load current settings
    _manualBrightness = _sensorService.currentBrightness;
    _proximityEnabled = _sensorService.isProximityEnabled;
    _shakeDetectionEnabled = _sensorService.isShakeDetectionEnabled;

    // Check if sensors are actually working
    if (!_sensorService.areSensorsWorking) {
      print(
        '⚠️ SettingsView: Sensors are not working, showing manual controls only',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Sensor Controls'),
          _buildSensorStatusTile(),
          _buildShakeDetectionTile(),
          _buildAutoThemeTile(),
          _buildAutoBrightnessTile(),
          _buildProximityTile(),

          const SizedBox(height: 24),
          _buildSectionHeader('Manual Controls'),
          _buildManualThemeTile(),
          _buildManualBrightnessTile(),

          const SizedBox(height: 24),
          _buildSectionHeader('Information'),
          _buildInfoTile(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildSensorStatusTile() {
    final bool areSensorsWorking = _sensorService.areSensorsWorking;
    final bool isProximityAvailable = _sensorService.isProximityAvailable;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline),
                SizedBox(width: 16),
                Text(
                  'Sensor Status',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '• Shake Detection: ${areSensorsWorking ? 'Working' : 'Not Working'}\n'
              '• Auto Theme: ${areSensorsWorking ? 'Working' : 'Not Working'}\n'
              '• Auto Brightness: ${areSensorsWorking ? 'Working' : 'Not Working'}\n'
              '• Proximity Sensor: ${isProximityAvailable ? 'Working' : 'Not Working'}\n'
              '• Manual Controls: Always available',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShakeDetectionTile() {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.screen_rotation,
          color: _shakeDetectionEnabled ? Colors.green : Colors.grey,
        ),
        title: const Text('Shake to Refresh'),
        subtitle: Text(
          _shakeDetectionEnabled
              ? 'Shake your phone to refresh the current page'
              : 'Shake detection is disabled',
        ),
        trailing: Switch(
          value: _shakeDetectionEnabled,
          onChanged: (value) {
            setState(() {
              _shakeDetectionEnabled = value;
            });
            _sensorService.setShakeDetectionEnabled(value);

            // Show feedback
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  value
                      ? 'Shake detection enabled! Shake your phone to refresh.'
                      : 'Shake detection disabled',
                ),
                duration: const Duration(seconds: 2),
                backgroundColor: value ? Colors.green : Colors.orange,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAutoThemeTile() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.brightness_auto),
        title: const Text('Auto Theme'),
        subtitle: const Text('Automatically switch theme based on time of day'),
        trailing: Switch(
          value: _autoThemeEnabled,
          onChanged: (value) {
            setState(() {
              _autoThemeEnabled = value;
            });
            // This is handled by the sensor service
          },
        ),
      ),
    );
  }

  Widget _buildAutoBrightnessTile() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.brightness_6),
        title: const Text('Auto Brightness'),
        subtitle: const Text('Automatically adjust brightness based on time'),
        trailing: Switch(
          value: _autoBrightnessEnabled,
          onChanged: (value) {
            setState(() {
              _autoBrightnessEnabled = value;
            });
            // This is handled by the sensor service
          },
        ),
      ),
    );
  }

  Widget _buildProximityTile() {
    final bool isAvailable = _sensorService.isProximityAvailable;

    return Card(
      child: ListTile(
        leading: Icon(
          Icons.sensor_door,
          color: _proximityEnabled ? Colors.green : Colors.grey,
        ),
        title: const Text('Proximity Sensor'),
        subtitle: Text(
          isAvailable
              ? _proximityEnabled
                    ? 'Hold phone near face to switch to dark mode'
                    : 'Proximity detection is disabled'
              : 'Not available on this device',
        ),
        trailing: isAvailable
            ? Switch(
                value: _proximityEnabled,
                onChanged: (value) {
                  setState(() {
                    _proximityEnabled = value;
                  });
                  _sensorService.setProximityEnabled(value);

                  // Show feedback
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        value
                            ? 'Proximity detection enabled! Hold phone near face for dark mode.'
                            : 'Proximity detection disabled',
                      ),
                      duration: const Duration(seconds: 2),
                      backgroundColor: value ? Colors.green : Colors.orange,
                    ),
                  );
                },
              )
            : const Icon(Icons.info_outline, color: Colors.grey),
      ),
    );
  }

  Widget _buildManualThemeTile() {
    return Card(
      child: ListTile(
        leading: Icon(
          _themeManager.isDarkMode ? Icons.dark_mode : Icons.light_mode,
        ),
        title: const Text('Theme Mode'),
        subtitle: Text(_themeManager.isDarkMode ? 'Dark Mode' : 'Light Mode'),
        trailing: IconButton(
          icon: Icon(
            _themeManager.isDarkMode ? Icons.light_mode : Icons.dark_mode,
          ),
          onPressed: () {
            _themeManager.toggleTheme();
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget _buildManualBrightnessTile() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.brightness_6),
                const SizedBox(width: 16),
                const Text(
                  'Manual Brightness',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.brightness_low, size: 20),
                Expanded(
                  child: Slider(
                    value: _manualBrightness,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: '${(_manualBrightness * 100).toStringAsFixed(0)}%',
                    onChanged: (value) {
                      setState(() {
                        _manualBrightness = value;
                      });
                      _sensorService.setManualBrightness(value);
                    },
                  ),
                ),
                const Icon(Icons.brightness_high, size: 20),
              ],
            ),
            Text(
              'Brightness: ${(_manualBrightness * 100).toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile() {
    final bool isProximityAvailable = _sensorService.isProximityAvailable;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline),
                SizedBox(width: 16),
                Text(
                  'Sensor Features',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '• Shake Detection: Shake your phone to refresh the current page\n'
              '• Auto Theme: App starts in light mode by default\n'
              '• Auto Brightness: Adjusts screen brightness based on time of day\n'
              '• Proximity Sensor: ${isProximityAvailable ? "Hold phone near face to switch to dark mode" : "Not available on this device"}\n'
              '• Manual Controls: Override automatic settings with manual controls',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: const Text(
                '💡 Tip: Shake your phone while on any page to refresh its content!',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue,
                ),
              ),
            ),
            if (!isProximityAvailable) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: const Text(
                  '⚠️ Note: Proximity sensor is not available on this device. '
                  'You can still use manual theme controls and time-based auto theme.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
