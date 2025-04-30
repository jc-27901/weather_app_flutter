import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

import '../../data/services/open_weather_service.dart';



class PlaceHolderMapScreen extends StatelessWidget {
  final WeatherData? weatherData;

  const PlaceHolderMapScreen({
    super.key,
    required this.weatherData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF4A90E2),
                  const Color(0xFF89CFF0),
                ],
              ),
            ),
          ),

          // Map placeholder content
          SafeArea(
            child: Column(
              children: [
                // App bar
                _buildAppBar(context),

                // Placeholder map content
                Expanded(
                  child: Center(
                    child: _buildMapPlaceholder(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha:0.2),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Weather Map',
              style: TextStyle(
                color: Colors.white.withValues(alpha:0.9),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha:0.2),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.layers, color: Colors.white),
                  onPressed: () {
                    // Would toggle map layers in the real implementation
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Map layers would toggle here')),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildMapPlaceholder(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha:0.2),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.map,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Map Placeholder',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha:0.9),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'This is a placeholder for the Google Maps integration that would show precipitation and temperature overlays.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha:0.7),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                if (weatherData != null)
                  _buildWeatherInfoCard(context),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).scale(delay: 200.ms, duration: 500.ms);
  }

  Widget _buildWeatherInfoCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha:0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Location',
            style: TextStyle(
              color: Colors.white.withValues(alpha:0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${weatherData?.areaName}, ${weatherData?.countryCode}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.network(
                        'https://openweathermap.org/img/wn/${weatherData?.weatherIcon}.png',
                        width: 40,
                        height: 40,
                        errorBuilder: (ctx, obj, stacktrace) => const Icon(
                          Icons.cloud,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${weatherData?.temperature?.celsius?.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    weatherData?.weatherDescription ?? 'Unknown',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha:0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.water_drop_outlined,
                        color: Colors.white.withValues(alpha:0.7),
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Humidity: ${weatherData?.humidity?.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha:0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.air,
                        color: Colors.white.withValues(alpha:0.7),
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Wind: ${weatherData?.windSpeed?.toStringAsFixed(1)} m/s',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha:0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms, duration: 500.ms);
  }
}