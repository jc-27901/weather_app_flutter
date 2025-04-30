import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:weather_app_flutter/core/extensions/string_extensions.dart';

import '../../../data/services/open_weather_service.dart';


class FiveDayForecastWidget extends StatelessWidget {
  const FiveDayForecastWidget({super.key, required this.dailyForecasts});

  final List<WeatherData> dailyForecasts;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '5-Day Forecast',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: dailyForecasts.length,
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.white.withValues(alpha: 0.2),
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final WeatherData forecast = dailyForecasts[index];
                    return DailyForeCastItem(forecast: forecast, index: index);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 1300.ms, duration: 500.ms);
  }
}

class DailyForeCastItem extends StatelessWidget {
  const DailyForeCastItem(
      {super.key, required this.forecast, required this.index});
  final WeatherData forecast;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          // Day name
          SizedBox(
            width: 50,
            child: Text(
              forecast.date != null
                  ? DateFormat('EE').format(forecast.date!)
                  : '--',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Weather icon
          Image.network(
            'https://openweathermap.org/img/wn/${forecast.weatherIcon}.png',
            width: 40,
            height: 40,
            errorBuilder: (ctx, obj, stacktrace) => const Icon(
              Icons.cloud,
              size: 30,
              color: Colors.white,
            ),
          ),

          // Weather condition
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                forecast.weatherDescription?.capitalize() ?? 'Unknown',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Temperature
          Row(
            children: [
              Text(
                '${forecast.tempMin?.celsius?.toStringAsFixed(0)}°',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade200, Colors.orange.shade300],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${forecast.tempMax?.celsius?.toStringAsFixed(0)}°',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: 1400 + (index * 100)))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.1, end: 0);
  }
}
