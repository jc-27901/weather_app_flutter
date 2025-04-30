part of '../weather_screen.dart';
class BackgroundContainer extends StatelessWidget {
  const BackgroundContainer(
      {super.key, required this.isDaytime, required this.weatherCondition});

  final bool isDaytime;
  final String weatherCondition;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _getBackgroundColors(isDaytime, weatherCondition),
        ),
      ),
    );
  }

  List<Color> _getBackgroundColors(bool isDaytime, String weatherCondition) {
    // Clear sky daytime
    if (isDaytime &&
        (weatherCondition.contains('clear') || weatherCondition.isEmpty)) {
      return [
        const Color(0xFF4A90E2),
        const Color(0xFF89CFF0),
      ];
    }
    // Clear sky nighttime
    else if (!isDaytime &&
        (weatherCondition.contains('clear') || weatherCondition.isEmpty)) {
      return [
        const Color(0xFF0C1445),
        const Color(0xFF232D5C),
      ];
    }
    // Cloudy
    else if (weatherCondition.contains('cloud')) {
      return isDaytime
          ? [
              const Color(0xFF6D99C1),
              const Color(0xFF8FB1D5),
            ]
          : [
              const Color(0xFF2E3B5B),
              const Color(0xFF3E4E78),
            ];
    }
    // Rainy
    else if (weatherCondition.contains('rain') ||
        weatherCondition.contains('drizzle')) {
      return isDaytime
          ? [
              const Color(0xFF5C6B8C),
              const Color(0xFF7285AA),
            ]
          : [
              const Color(0xFF2C313D),
              const Color(0xFF3A4055),
            ];
    }
    // Snowy
    else if (weatherCondition.contains('snow')) {
      return isDaytime
          ? [
              const Color(0xFF94A6B8),
              const Color(0xFFB2C3D2),
            ]
          : [
              const Color(0xFF4D5468),
              const Color(0xFF636C83),
            ];
    }
    // Thunderstorm
    else if (weatherCondition.contains('thunder')) {
      return [
        const Color(0xFF444B62),
        const Color(0xFF2E323F),
      ];
    }
    // Mist, fog, haze, etc.
    else if (weatherCondition.contains('mist') ||
        weatherCondition.contains('fog') ||
        weatherCondition.contains('haze')) {
      return isDaytime
          ? [
              const Color(0xFF9EACBA),
              const Color(0xFFBBC5D0),
            ]
          : [
              const Color(0xFF464D5E),
              const Color(0xFF5D6478),
            ];
    }
    // Default
    else {
      return isDaytime
          ? [
              const Color(0xFF6D99C1),
              const Color(0xFF8FB1D5),
            ]
          : [
              const Color(0xFF2E3B5B),
              const Color(0xFF3E4E78),
            ];
    }
  }
}
