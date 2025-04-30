// map_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:weather_app_flutter/core/extensions/string_extensions.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../data/models/weather_location_dm.dart';
import '../../data/services/open_weather_service.dart';
part 'widgets/back_button.dart';
part 'widgets/control_buttons.dart';
part 'widgets/current_location_container.dart';
part 'widgets/nearby_location_container.dart';
part 'widgets/pulsating_container.dart';
part 'widgets/weather_detail_tile.dart';
part 'widgets/weather_icon_condition.dart';
part 'widgets/weather_info.dart';

class MapScreen extends StatefulWidget {
  final WeatherData weatherData;

  const MapScreen({super.key, required this.weatherData});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  bool _isWeatherLayerVisible = true;
  late final AnimationController _markerAnimationController;

  // API key for OpenWeatherMap
  final String _apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';

  // Map layer selection
  String _selectedMapLayer = 'precipitation';

  // For demonstration, we'll have some hardcoded nearby locations with weather
  final List<WeatherLocation> _nearbyLocations = [];
  late final WeatherData weatherData;

  @override
  void initState() {
    super.initState();
    _markerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    weatherData = widget.weatherData;

    _generateNearbyLocations();

    // Show the marker animation when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markerAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    _markerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Default to London if no location data available
    final double lat = weatherData.latitude ?? 51.5074;
    final double lon = weatherData.longitude ?? -0.1278;

    return Scaffold(
      body: Stack(
        children: [
          // Map Layer
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(lat, lon),
              initialZoom: 10.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              // Base map layer
              TileLayer(
                urlTemplate:
                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.weather_app_flutter',
                tileDisplay: TileDisplay.fadeIn(),
              ),

              // Weather overlay layer - only add if visible
              if (_isWeatherLayerVisible)
                TileLayer(
                  urlTemplate: _getWeatherLayerUrl(),
                  userAgentPackageName: 'com.weather_app_flutter',
                  tileDisplay: const TileDisplay.fadeIn(
                    duration: Duration(milliseconds: 200),
                  ),
                ),

              // Markers for current location and nearby locations
              MarkerLayer(
                markers: [
                  // Current location marker
                  Marker(
                    width: 60.0,
                    height: 60.0,
                    point: LatLng(lat, lon),
                    child: AnimatedBuilder(
                      animation: _markerAnimationController,
                      builder: (context, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Pulsating circle
                            PulsatingContainer(
                                markerAnimationController:
                                _markerAnimationController),
                            // Inner circle
                            GestureDetector(
                              onTap: () => _showLocationDetails(WeatherLocation(
                                  latitude: weatherData.latitude!,
                                  longitude: weatherData.longitude!,
                                  temperature:
                                  weatherData.temperature!.celsius!,
                                  humidity: weatherData.humidity!.toInt(),
                                  condition: weatherData.weatherMain!,
                                  name: weatherData.areaName!)),
                              child: CurrentLocationContainer(
                                  weatherData: weatherData),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Nearby location markers
                  ..._nearbyLocations.map((location) {
                    return Marker(
                        width: 40.0,
                        height: 40.0,
                        point: LatLng(location.latitude, location.longitude),
                        child: GestureDetector(
                          onTap: () {
                            _showLocationDetails(location);
                          },
                          child: NearbyLocationContainer(
                            temp: location.temperature,
                          ),
                        ));
                  }),
                ],
              ),
            ],
          ),

          // Debug indicator for weather layer - helps during development
          if (_isWeatherLayerVisible)
            Positioned(
              top: MediaQuery.sizeOf(context).height * 0.15,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  'Weather Layer: $_selectedMapLayer',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),

          // Back button
          const CustomBackButton(),

          // Map controls
          Positioned(
            right: 16,
            top: 100,
            child: Column(
              children: [
                ControlButtons(
                  icon: Icons.layers,
                  onPressed: _toggleLayerOptions,
                  tooltip: 'Map Layers',
                ),
                const SizedBox(height: 16),
                ControlButtons(
                  icon: Icons.add,
                  onPressed: () => _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom + 1,
                  ),
                  tooltip: 'Zoom In',
                ),
                const SizedBox(height: 8),
                ControlButtons(
                  icon: Icons.remove,
                  onPressed: () => _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom - 1,
                  ),
                  tooltip: 'Zoom Out',
                ),
                const SizedBox(height: 16),
                ControlButtons(
                  icon: Icons.my_location,
                  onPressed: () => _mapController.move(LatLng(lat, lon), 12),
                  tooltip: 'Current Location',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// --- Class Methods --------------------------------------------------------

  // Get the correct weather layer URL based on selection
  String _getWeatherLayerUrl() {
    // Use the correct endpoint format for OpenWeatherMap tile server
    switch (_selectedMapLayer) {
      case 'precipitation':
        return 'https://tile.openweathermap.org/map/precipitation_new/{z}/{x}/{y}.png?appid=$_apiKey';
      case 'temperature':
        return 'https://tile.openweathermap.org/map/temp_new/{z}/{x}/{y}.png?appid=$_apiKey';
      case 'clouds':
        return 'https://tile.openweathermap.org/map/clouds_new/{z}/{x}/{y}.png?appid=$_apiKey';
      case 'wind':
        return 'https://tile.openweathermap.org/map/wind_new/{z}/{x}/{y}.png?appid=$_apiKey';
      default:
        return 'https://tile.openweathermap.org/map/precipitation_new/{z}/{x}/{y}.png?appid=$_apiKey';
    }
  }

  void _generateNearbyLocations() {
    if (weatherData.latitude == null || weatherData.longitude == null) {
      return;
    }

    final random = math.Random();
    final double baseTemp = weatherData.temperature?.celsius ?? 20.0;
    final double baseHumidity = weatherData.humidity ?? 70;

    // Generate 5 nearby locations
    for (int i = 0; i < 5; i++) {
      // Generate locations within approximately 10km
      final double latOffset = (random.nextDouble() - 0.5) * 0.1;
      final double lonOffset = (random.nextDouble() - 0.5) * 0.1;

      // Vary the temperature and humidity slightly
      final double tempOffset = (random.nextDouble() - 0.5) * 5;
      final double humidityOffset = (random.nextInt(20) - 10);

      _nearbyLocations.add(
        WeatherLocation(
          latitude: weatherData.latitude! + latOffset,
          longitude: weatherData.longitude! + lonOffset,
          temperature: baseTemp + tempOffset,
          humidity: ((baseHumidity + humidityOffset).clamp(30, 100)).toInt(),
          condition: _getRandomWeatherCondition(),
          name: _getRandomLocationName(i),
        ),
      );
    }
  }

  String _getRandomWeatherCondition() {
    final List<String> conditions = ['clear', 'clouds', 'rain', 'mist'];
    return conditions[math.Random().nextInt(conditions.length)];
  }

  String _getRandomLocationName(int index) {
    final List<String> names = [
      'Downtown',
      'Westside',
      'Northpark',
      'Eastville',
      'Southend'
    ];
    return names[index % names.length];
  }

  void _toggleLayerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Map Layers',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text(
                    'Weather Layer',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: _isWeatherLayerVisible,
                  activeColor: Colors.blue,
                  onChanged: (value) {
                    setState(() {
                      _isWeatherLayerVisible = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
                const Divider(color: Colors.white30),
                RadioListTile<String>(
                  title: const Text(
                    'Precipitation Layer',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: 'precipitation',
                  groupValue: _selectedMapLayer,
                  activeColor: Colors.blue,
                  onChanged: (value) {
                    setState(() {
                      _selectedMapLayer = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
                RadioListTile<String>(
                  title: const Text(
                    'Temperature Layer',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: 'temperature',
                  groupValue: _selectedMapLayer,
                  activeColor: Colors.blue,
                  onChanged: (value) {
                    setState(() {
                      _selectedMapLayer = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
                RadioListTile<String>(
                  title: const Text(
                    'Clouds Layer',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: 'clouds',
                  groupValue: _selectedMapLayer,
                  activeColor: Colors.blue,
                  onChanged: (value) {
                    setState(() {
                      _selectedMapLayer = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
                RadioListTile<String>(
                  title: const Text(
                    'Wind Layer',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: 'wind',
                  groupValue: _selectedMapLayer,
                  activeColor: Colors.blue,
                  onChanged: (value) {
                    setState(() {
                      _selectedMapLayer = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLocationDetails(WeatherLocation location) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    location.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      WeatherInfo(
                        icon: Icons.thermostat,
                        label: 'Temperature',
                        value: '${location.temperature.toStringAsFixed(1)}°C',
                      ),
                      const SizedBox(width: 40),
                      WeatherInfo(
                        icon: Icons.water_drop,
                        label: 'Humidity',
                        value: '${location.humidity}%',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  WeatherIconCondition(condition: location.condition),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _mapController.move(
                        LatLng(location.latitude, location.longitude),
                        _mapController.camera.zoom,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                    ),
                    child: const Text('Go to location'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}