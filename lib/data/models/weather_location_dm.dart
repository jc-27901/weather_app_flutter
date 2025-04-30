// Model class for nearby locations
class WeatherLocation {
  final double latitude;
  final double longitude;
  final double temperature;
  final int humidity;
  final String condition;
  final String name;

  WeatherLocation({
    required this.latitude,
    required this.longitude,
    required this.temperature,
    required this.humidity,
    required this.condition,
    required this.name,
  });
}