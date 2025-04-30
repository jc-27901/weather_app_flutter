import 'package:flutter/material.dart';
import 'package:weather_app_flutter/core/services/open_weather_service.dart';


class CurrentLocationContainer extends StatelessWidget {
  const CurrentLocationContainer({
    super.key,
    required this.weatherData,
  });

  final WeatherData weatherData;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
        border:
        Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withValues(alpha: 0.3),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '${weatherData.temperature?.celsius?.toStringAsFixed(0)}°',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}