import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../core/services/open_weather_service.dart';

class HourlyForecastWidget extends StatelessWidget {
  const HourlyForecastWidget({super.key, required this.hourlyData});
  final List<WeatherData> hourlyData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Hourly Forecast',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: hourlyData.length,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (context, index) {
                final WeatherData forecast = hourlyData[index];
                return HourlyForeCastItem(forecast: forecast, index: index);
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms, duration: 300.ms);
  }
}

class HourlyForeCastItem extends StatelessWidget {
  const HourlyForeCastItem(
      {super.key, required this.forecast, required this.index});

  final WeatherData forecast;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            width: 80,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  forecast.date != null
                      ? DateFormat('h a').format(forecast.date!)
                      : '--',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Image.network(
                  'https://openweathermap.org/img/wn/${forecast.weatherIcon}.png',
                  width: 40,
                  height: 40,
                  errorBuilder: (ctx, obj, stacktrace) => const Icon(
                    Icons.cloud,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${forecast.temperature?.celsius?.toStringAsFixed(1)}°',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 300))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.2, end: 0);
  }
}
