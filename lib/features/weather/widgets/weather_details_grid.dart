import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../data/services/open_weather_service.dart';

class WeatherDetailsGrid extends StatelessWidget {
  const WeatherDetailsGrid({super.key, required this.currentWeather});
  final WeatherData currentWeather;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weather Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              DetailCard(
                title: 'Humidity',
                value: '${currentWeather.humidity?.toStringAsFixed(0)}%',
                icon: Icons.water_drop_outlined,
              ),
              DetailCard(
                title: 'Wind Speed',
                value: '${currentWeather.windSpeed?.toStringAsFixed(1)} m/s',
                icon: Icons.air,
              ),
              DetailCard(
                title: 'Pressure',
                value: '${currentWeather.pressure?.toStringAsFixed(0)} hPa',
                icon: Icons.speed,
              ),
              DetailCard(
                title: 'Cloudiness',
                value: '${currentWeather.cloudiness?.toStringAsFixed(0)}%',
                icon: Icons.cloud_outlined,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 1600.ms, duration: 500.ms);
  }
}

class DetailCard extends StatelessWidget {
  const DetailCard(
      {super.key,
      required this.title,
      required this.value,
      required this.icon});

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
