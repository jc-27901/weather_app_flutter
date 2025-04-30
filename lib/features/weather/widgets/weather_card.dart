import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:weather_app_flutter/core/extensions/string_extensions.dart';
import 'package:weather_app_flutter/core/services/open_weather_service.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key, required this.currentWeather});

  final WeatherData currentWeather;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              children: [
                // Weather icon and temperature
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Weather icon
                    Image.network(
                      'https://openweathermap.org/img/wn/${currentWeather.weatherIcon}@4x.png',
                      width: 100,
                      height: 100,
                      errorBuilder: (ctx, obj, stacktrace) => const Icon(
                        Icons.cloud,
                        size: 100,
                        color: Colors.white,
                      ),
                    ).animate().scale(delay: 300.ms, duration: 500.ms),

                    // Temperature
                    Text(
                      '${currentWeather.temperature?.celsius?.toStringAsFixed(1)}°',
                      style: const TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
                  ],
                ),

                // Weather description
                Text(
                  currentWeather.weatherDescription?.capitalize() ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().fadeIn(delay: 700.ms, duration: 500.ms),

                const SizedBox(height: 16),

                // Min/Max temperatures
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TemperatureInfo(
                      icon: Icons.arrow_downward,
                      label: 'Min',
                      value:
                          '${currentWeather.tempMin?.celsius?.toStringAsFixed(1)}°',
                    ),
                    const SizedBox(width: 32),
                    TemperatureInfo(
                      icon: Icons.arrow_upward,
                      label: 'Max',
                      value:
                          '${currentWeather.tempMax?.celsius?.toStringAsFixed(1)}°',
                    ),
                  ],
                ).animate().fadeIn(delay: 900.ms, duration: 500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TemperatureInfo extends StatelessWidget {
  const TemperatureInfo(
      {super.key,
      required this.icon,
      required this.label,
      required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
