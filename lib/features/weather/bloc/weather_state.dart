part of 'weather_cubit.dart';

@immutable
sealed class WeatherState {}

final class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {
  final String message;

  WeatherLoading({this.message = 'Fetching weather data...'});
}

class WeatherLoaded extends WeatherState {
  final WeatherData currentWeather;
  final List<WeatherData> forecastData;

  WeatherLoaded({
    required this.currentWeather,
    required this.forecastData,
  });
}

class WeatherError extends WeatherState {
  final String message;

  WeatherError({required this.message});
}

// class WeatherSearchToggled extends WeatherState {
//   final bool isSearching;
//   final WeatherData? currentWeather;
//   final List<WeatherData>? forecastData;
//
//   WeatherSearchToggled({
//     required this.isSearching,
//     this.currentWeather,
//     this.forecastData,
//   });
// }

