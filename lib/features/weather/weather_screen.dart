import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:weather_app_flutter/core/views/base_error_view.dart';
import 'package:weather_app_flutter/core/views/base_loading_view.dart';
import 'package:weather_app_flutter/features/map/map_screen.dart';
import 'package:weather_app_flutter/features/weather/bloc/weather_cubit.dart';
import 'package:weather_app_flutter/features/weather/widgets/background_container.dart';
import 'package:weather_app_flutter/features/weather/widgets/five_day_forecast_widget.dart';
import 'package:weather_app_flutter/features/weather/widgets/hourly_forecast_widget.dart';
import 'package:weather_app_flutter/features/weather/widgets/weather_app_bar.dart';
import 'package:weather_app_flutter/features/weather/widgets/weather_card.dart';
import 'package:weather_app_flutter/features/weather/widgets/weather_details_grid.dart';
import '../../core/views/base_bottom_navbar.dart';
import '../../core/views/rain_painter.dart';
import '../../core/views/snow_painter.dart';
import '../../data/services/open_weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  /// text controller.
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  late final WeatherCubit _cubit;

  bool _isSearching = false;

  late WeatherData? currentWeather;
  late List<WeatherData>? forecastData;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    final String apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';
    _cubit = WeatherCubit(
        weatherService: OpenWeatherService(apiKey));
    _cubit.getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocConsumer<WeatherCubit, WeatherState>(
        bloc: _cubit,
        listener: (context, state) {
          if (state is WeatherLoaded) {
            currentWeather = state.currentWeather;
            forecastData = state.forecastData;
          }
        },
        builder: (context, state) {
          if (state is WeatherLoading) {
            return BaseLoadingView(state.message);
          } else if (state is WeatherError) {
            return BaseErrorView(
                errText: state.message,
                onTryAgain: () {
                  currentWeather != null
                      ? _cubit.fetchWeatherDataByCity(currentWeather!.areaName!)
                      : _cubit.refreshWeatherData();
                  _isSearching = false;
                  _searchController.clear();
                });
          } else if (state is WeatherLoaded) {
            return _buildWeatherView();
          }

          // Initial state - show loading
          return BaseLoadingView('Initializing weather app...');
        },
      ),
    );
  }

  Widget _buildWeatherView() {
    // If weather data is null, show empty view
    if (currentWeather == null) return const SizedBox.shrink();

    // Determine the background gradient based on time of day and weather
    final bool isDaytime = _isDaytime(currentWeather!);
    final String weatherCondition =
        currentWeather?.weatherMain?.toLowerCase() ?? '';

    return Stack(
      children: [
        // Background gradient
        BackgroundContainer(
            isDaytime: isDaytime, weatherCondition: weatherCondition),

        // Weather effects overlay (rain, snow, etc.)
        if (weatherCondition.contains('rain'))
          RainEffect()
        else if (weatherCondition.contains('snow'))
          SnowEffect()
        else if (weatherCondition.contains('drizzle'))
          const SizedBox.shrink(),

        // Main content
        SafeArea(
          child: Column(
            children: [
              // App bar with search
              WeatherAppBar(
                searchC: _searchController,
                searchF: _searchFocusNode,
                isSearching: _isSearching,
                onToggle: _toggleSearch,
                onSubmitted: (city) => _cubit.fetchWeatherDataByCity(city),
                currentWeather: currentWeather,
              ),
              // Current weather display
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _cubit.refreshWeatherData(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // Current weather card
                        WeatherCard(currentWeather: currentWeather!),

                        // Hourly forecast
                        _buildHourlyForecast(forecastData),

                        // 5-day forecast
                        _buildFiveDayForecast(forecastData),

                        // Extra weather details
                        WeatherDetailsGrid(currentWeather: currentWeather!),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom navigation
              BaseBottomNavbar(
                navigateToMap: () => _navigateToMapScreen(currentWeather),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Function returns hourly forecast widget.
  Widget _buildHourlyForecast(List<WeatherData>? forecastData) {
    if (forecastData == null || forecastData.isEmpty) {
      return const SizedBox.shrink();
    }

    // Filter forecast data for the next 24 hours (8 entries with 3-hour steps)
    final List<WeatherData> hourlyData = forecastData.take(8).toList();

    return HourlyForecastWidget(hourlyData: hourlyData);
  }

  Widget _buildFiveDayForecast(List<WeatherData>? forecastData) {
    if (forecastData == null || forecastData.isEmpty) {
      return const SizedBox.shrink();
    }

    // Group forecast data by day (taking only one entry per day)
    final Map<String, WeatherData> dailyData = {};
    for (WeatherData forecast in forecastData) {
      if (forecast.date != null) {
        final String dayKey = DateFormat('yyyy-MM-dd').format(forecast.date!);
        if (!dailyData.containsKey(dayKey)) {
          dailyData[dayKey] = forecast;
        }
      }
    }

    final List<WeatherData> dailyForecasts = dailyData.values.take(5).toList();
    return FiveDayForecastWidget(dailyForecasts: dailyForecasts);
  }

  void _navigateToMapScreen(WeatherData? weatherData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          weatherData: weatherData!,
        ),
      ),
    );
  }

  bool _isDaytime(WeatherData weatherData) {
    if (weatherData.date == null ||
        weatherData.sunrise == null ||
        weatherData.sunset == null) {
      return true;
    }

    final now = weatherData.date!;
    final sunrise = weatherData.sunrise!;
    final sunset = weatherData.sunset!;

    return now.isAfter(sunrise) && now.isBefore(sunset);
  }

  /// toggle search function.
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
    });

    if (_isSearching) {
      _searchFocusNode.requestFocus();
    } else {
      _searchFocusNode.unfocus();
    }
  }
}
