import 'dart:convert';
import 'package:http/http.dart' as http;

/// A unified service for interacting with OpenWeatherMap API.
/// Handles all weather data fetching and processing needs for Flutter applications.
class OpenWeatherService {
  final String _apiKey;
  final Language _language;
  final http.Client _httpClient;

  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _currentWeatherEndpoint = 'weather';
  static const String _forecastEndpoint = 'forecast';
  static const int _successStatusCode = 200;

  /// Creates a new OpenWeatherService instance
  ///
  /// [apiKey] - Your OpenWeatherMap API key
  /// [language] - Language for weather descriptions (defaults to English)
  /// [httpClient] - Optional custom HTTP client
  OpenWeatherService(
      this._apiKey, {
        Language language = Language.english,
        http.Client? httpClient,
      }) : _language = language,
        _httpClient = httpClient ?? http.Client();

  /// Fetches current weather data for the specified coordinates
  ///
  /// [latitude] - Latitude coordinate
  /// [longitude] - Longitude coordinate
  /// Returns a [WeatherData] object with the current weather information
  Future<WeatherData> getCurrentWeatherByLocation(
      double latitude, double longitude) async {
    final json = await _fetchData(
      _currentWeatherEndpoint,
      latitude: latitude,
      longitude: longitude,
    );
    return WeatherData.fromJson(json);
  }

  /// Fetches current weather data for the specified city
  ///
  /// [cityName] - Name of the city
  /// Returns a [WeatherData] object with the current weather information
  Future<WeatherData> getCurrentWeatherByCityName(String cityName) async {
    final json = await _fetchData(
      _currentWeatherEndpoint,
      cityName: cityName,
    );
    return WeatherData.fromJson(json);
  }

  /// Fetches five-day forecast data for the specified coordinates
  ///
  /// [latitude] - Latitude coordinate
  /// [longitude] - Longitude coordinate
  /// Returns a list of [WeatherData] objects containing forecast information
  Future<List<WeatherData>> getFiveDayForecastByLocation(
      double latitude, double longitude) async {
    final json = await _fetchData(
      _forecastEndpoint,
      latitude: latitude,
      longitude: longitude,
    );
    return _parseForecast(json);
  }

  /// Fetches five-day forecast data for the specified city
  ///
  /// [cityName] - Name of the city
  /// Returns a list of [WeatherData] objects containing forecast information
  Future<List<WeatherData>> getFiveDayForecastByCityName(String cityName) async {
    final json = await _fetchData(
      _forecastEndpoint,
      cityName: cityName,
    );
    return _parseForecast(json);
  }

  /// Fetches data from the OpenWeatherMap API
  ///
  /// [endpoint] - API endpoint to access
  /// [latitude] - Optional latitude coordinate
  /// [longitude] - Optional longitude coordinate
  /// [cityName] - Optional city name
  /// Returns the JSON response as a Map
  Future<Map<String, dynamic>> _fetchData(
      String endpoint, {
        double? latitude,
        double? longitude,
        String? cityName,
      }) async {
    final Uri uri = _buildUri(
      endpoint,
      latitude: latitude,
      longitude: longitude,
      cityName: cityName,
    );

    final response = await _httpClient.get(uri);

    if (response.statusCode == _successStatusCode) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw OpenWeatherApiException(
        'API error: ${response.statusCode} - ${response.body}',
      );
    }
  }

  /// Builds the API request URI
  ///
  /// [endpoint] - API endpoint to access
  /// [latitude] - Optional latitude coordinate
  /// [longitude] - Optional longitude coordinate
  /// [cityName] - Optional city name
  /// Returns the constructed URI
  Uri _buildUri(
      String endpoint, {
        double? latitude,
        double? longitude,
        String? cityName,
      }) {
    final Map<String, String> queryParameters = {};

    if (cityName != null) {
      queryParameters['q'] = cityName;
    } else if (latitude != null && longitude != null) {
      queryParameters['lat'] = latitude.toString();
      queryParameters['lon'] = longitude.toString();
    }

    queryParameters['lang'] = languageCodes[_language] ?? 'en';
    queryParameters['appid'] = _apiKey;

    return Uri.parse('$_baseUrl/$endpoint').replace(queryParameters: queryParameters);
  }

  /// Parses forecast data from API response
  ///
  /// [jsonForecast] - JSON forecast data from API
  /// Returns a list of [WeatherData] objects
  List<WeatherData> _parseForecast(Map<String, dynamic> jsonForecast) {
    final List<dynamic> forecastList = jsonForecast['list'];
    final Map<String, dynamic> city = jsonForecast['city'];
    final Map<String, dynamic>? coord = city['coord'];
    final String? countryCode = city['country'];
    final String? areaName = city['name'];
    final double? latitude = _getValue<double>(coord, 'lat');
    final double? longitude = _getValue<double>(coord, 'lon');

    return forecastList.map((item) {
      // Add location data to each forecast item
      final Map<String, dynamic> enrichedItem = Map<String, dynamic>.from(item);
      enrichedItem['name'] = areaName;
      enrichedItem['sys'] = {
        'country': countryCode,
      };
      enrichedItem['coord'] = {
        'lat': latitude,
        'lon': longitude,
      };

      return WeatherData.fromJson(enrichedItem);
    }).toList();
  }

  /// Disposes the HTTP client when no longer needed
  void dispose() {
    _httpClient.close();
  }
}

/// Represents temperature with conversions between different units
class Temperature {
  final double? _kelvin;

  /// Creates a new Temperature instance
  ///
  /// [kelvin] - Temperature in Kelvin
  Temperature(this._kelvin);

  /// Temperature in Kelvin
  double? get kelvin => _kelvin;

  /// Temperature in Celsius
  double? get celsius => _kelvin != null ? _kelvin - 273.15 : null;

  /// Temperature in Fahrenheit
  double? get fahrenheit =>
      _kelvin != null ? _kelvin * (9 / 5) - 459.67 : null;

  @override
  String toString() => celsius != null
      ? '${celsius!.toStringAsFixed(1)} °C'
      : 'No temperature data';
}

/// Comprehensive weather data model that corresponds to OpenWeatherMap API responses
class WeatherData {
  // Location information
  final String? countryCode;
  final String? areaName;
  final double? latitude;
  final double? longitude;

  // Weather description
  final String? weatherMain;
  final String? weatherDescription;
  final String? weatherIcon;
  final int? weatherConditionCode;

  // Temperature data
  final Temperature? temperature;
  final Temperature? tempMin;
  final Temperature? tempMax;
  final Temperature? tempFeelsLike;

  // Date and time
  final DateTime? date;
  final DateTime? sunrise;
  final DateTime? sunset;

  // Atmospheric conditions
  final double? pressure;
  final double? humidity;
  final double? cloudiness;

  // Wind information
  final double? windSpeed;
  final double? windDegree;
  final double? windGust;

  // Precipitation
  final double? rainLastHour;
  final double? rainLast3Hours;
  final double? snowLastHour;
  final double? snowLast3Hours;

  // Raw data
  final Map<String, dynamic>? _rawData;

  /// Creates a WeatherData object from OpenWeatherMap API JSON response
  WeatherData.fromJson(Map<String, dynamic> json)
      : _rawData = json,
  // Extract location data
        countryCode = _getValue<String>(_getValue<Map<String, dynamic>>(json, 'sys'), 'country'),
        areaName = _getValue<String>(json, 'name'),
        latitude = _getValue<double>(_getValue<Map<String, dynamic>>(json, 'coord'), 'lat'),
        longitude = _getValue<double>(_getValue<Map<String, dynamic>>(json, 'coord'), 'lon'),

  // Extract weather description
        weatherMain = json['weather'] != null && json['weather'].isNotEmpty
            ? _getValue<String>(json['weather'][0], 'main')
            : null,
        weatherDescription = json['weather'] != null && json['weather'].isNotEmpty
            ? _getValue<String>(json['weather'][0], 'description')
            : null,
        weatherIcon = json['weather'] != null && json['weather'].isNotEmpty
            ? _getValue<String>(json['weather'][0], 'icon')
            : null,
        weatherConditionCode = json['weather'] != null && json['weather'].isNotEmpty
            ? _getValue<int>(json['weather'][0], 'id')
            : null,

  // Extract temperature data
        temperature = _extractTemperature(_getValue<Map<String, dynamic>>(json, 'main'), 'temp'),
        tempMin = _extractTemperature(_getValue<Map<String, dynamic>>(json, 'main'), 'temp_min'),
        tempMax = _extractTemperature(_getValue<Map<String, dynamic>>(json, 'main'), 'temp_max'),
        tempFeelsLike = _extractTemperature(_getValue<Map<String, dynamic>>(json, 'main'), 'feels_like'),

  // Extract date and time
        date = _extractDateTime(json, 'dt'),
        sunrise = _extractDateTime(_getValue<Map<String, dynamic>>(json, 'sys'), 'sunrise'),
        sunset = _extractDateTime(_getValue<Map<String, dynamic>>(json, 'sys'), 'sunset'),

  // Extract atmospheric conditions
        pressure = _getValue<double>(_getValue<Map<String, dynamic>>(json, 'main'), 'pressure'),
        humidity = _getValue<double>(_getValue<Map<String, dynamic>>(json, 'main'), 'humidity'),
        cloudiness = _getValue<double>(_getValue<Map<String, dynamic>>(json, 'clouds'), 'all'),

  // Extract wind information
        windSpeed = _getValue<double>(_getValue<Map<String, dynamic>>(json, 'wind'), 'speed'),
        windDegree = _getValue<double>(_getValue<Map<String, dynamic>>(json, 'wind'), 'deg'),
        windGust = _getValue<double>(_getValue<Map<String, dynamic>>(json, 'wind'), 'gust'),

  // Extract precipitation data
        rainLastHour = _getValue<double>(_getValue<Map<String, dynamic>>(json, 'rain'), '1h'),
        rainLast3Hours = _getValue<double>(_getValue<Map<String, dynamic>>(json, 'rain'), '3h'),
        snowLastHour = _getValue<double>(_getValue<Map<String, dynamic>>(json, 'snow'), '1h'),
        snowLast3Hours = _getValue<double>(_getValue<Map<String, dynamic>>(json, 'snow'), '3h');

  /// Returns the raw JSON data from the API
  Map<String, dynamic>? toJson() => _rawData;

  @override
  String toString() {
    return '''
    Location: $areaName [$countryCode] (${latitude?.toStringAsFixed(2)}, ${longitude?.toStringAsFixed(2)})
    Date: $date
    Weather: $weatherMain, $weatherDescription
    Temperature: ${temperature?.celsius?.toStringAsFixed(1)}°C (min: ${tempMin?.celsius?.toStringAsFixed(1)}°C, max: ${tempMax?.celsius?.toStringAsFixed(1)}°C, feels like: ${tempFeelsLike?.celsius?.toStringAsFixed(1)}°C)
    Sunrise: $sunrise, Sunset: $sunset
    Wind: ${windSpeed != null ? '${windSpeed!.toStringAsFixed(1)} m/s' : 'N/A'}, direction: ${windDegree != null ? '${windDegree!.toStringAsFixed(0)}°' : 'N/A'}
    Humidity: ${humidity != null ? '${humidity!.toStringAsFixed(0)}%' : 'N/A'}
    ''';
  }

  /// Safely extracts a Temperature object from a Map
  static Temperature? _extractTemperature(Map<String, dynamic>? data, String key) {
    final kelvin = _getValue<double>(data, key);
    return Temperature(kelvin);
  }

  /// Safely extracts a DateTime from a Unix timestamp
  static DateTime? _extractDateTime(Map<String, dynamic>? data, String key) {
    final timestamp = _getValue<int>(data, key);
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    }
    return null;
  }
}

/// Safely extracts a value of type T from a Map
T? _getValue<T>(Map<String, dynamic>? data, String key) {
  if (data == null || !data.containsKey(key)) {
    return null;
  }

  final value = data[key];

  if (value == null) {
    return null;
  }

  // Handle type conversions
  if (T == int && value is num) {
    return value.toInt() as T;
  } else if (T == double && value is num) {
    return value.toDouble() as T;
  } else if (T == String && value is String) {
    return value as T;
  } else if (value is T) {
    return value;
  }

  // If we can't convert to the expected type
  return null;
}

/// Enum for supported languages in the OpenWeatherMap API
enum Language {
  english,
  hindi
}

/// Mapping between Language enum and API language codes
const Map<Language, String> languageCodes = {
  Language.english: 'en',
  Language.hindi: 'hi',
};

/// Custom exception for OpenWeatherMap API errors
class OpenWeatherApiException implements Exception {
  final String message;

  OpenWeatherApiException(this.message);

  @override
  String toString() => 'OpenWeatherApiException: $message';
}