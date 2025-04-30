import 'package:flutter/material.dart' show immutable;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../data/services/open_weather_service.dart';

part 'weather_state.dart';

class WeatherCubit extends Cubit<WeatherState> {
  final OpenWeatherService _weatherService;
  bool _isSearching = false;

  WeatherCubit({required OpenWeatherService weatherService})
      : _weatherService = weatherService,
        super(WeatherInitial());

  bool get isSearching => _isSearching;

  /// Fetches current location and gets weather data
  Future<void> getCurrentLocation() async {
    emit(WeatherLoading());

    try {
      final status = await Permission.location.request();

      if (status.isGranted) {
        final Position position = await Geolocator.getCurrentPosition(
            locationSettings:
                LocationSettings(accuracy: LocationAccuracy.high));

        await _fetchWeatherData(position.latitude, position.longitude);
      } else {
        // Default to a location if permission is denied
        await fetchWeatherDataByCity('London');
        emit(WeatherError(
            message: 'Location permission denied. Showing default location.'));
      }
    } catch (e) {
      emit(WeatherError(message: 'Error getting location: $e'));
    }
  }

  /// Fetches weather data for given coordinates
  Future<void> _fetchWeatherData(double lat, double lon) async {
    emit(WeatherLoading());

    try {
      final WeatherData currentWeather =
          await _weatherService.getCurrentWeatherByLocation(lat, lon);
      final List<WeatherData> forecastData =
          await _weatherService.getFiveDayForecastByLocation(lat, lon);

      emit(WeatherLoaded(
        currentWeather: currentWeather,
        forecastData: forecastData,
      ));
    } catch (e) {
      emit(WeatherError(message: 'Error fetching weather data: $e'));
    }
  }

  /// Fetches weather data by city name
  Future<void> fetchWeatherDataByCity(String city) async {
    if (city.isEmpty) return;

    emit(WeatherLoading());

    try {
      final WeatherData currentWeather =
          await _weatherService.getCurrentWeatherByCityName(city);
      final List<WeatherData> forecastData =
          await _weatherService.getFiveDayForecastByCityName(city);

      _isSearching = false;
      emit(WeatherLoaded(
        currentWeather: currentWeather,
        forecastData: forecastData,
      ));
    } catch (e) {
      emit(WeatherError(message: 'City not found or network error'));
    }
  }

  /// Refreshes weather data based on current state
  Future<void> refreshWeatherData() async {
    if (state is WeatherLoaded) {
      final currentState = state as WeatherLoaded;
      final currentWeather = currentState.currentWeather;

      if (currentWeather.latitude != null && currentWeather.longitude != null) {
        await _fetchWeatherData(
            currentWeather.latitude!, currentWeather.longitude!);
      } else {
        await getCurrentLocation();
      }
    } else {
      await getCurrentLocation();
    }
  }

  @override
  Future<void> close() {
    _weatherService.dispose();
    return super.close();
  }
}
