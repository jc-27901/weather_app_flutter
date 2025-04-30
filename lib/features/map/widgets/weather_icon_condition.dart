part of '../map_screen.dart';

/// A widget that displays a weather icon and description based on a given condition.
class WeatherIconCondition extends StatelessWidget {
  const WeatherIconCondition({
    super.key,
    required this.condition,
  });

  final String condition;

  /// Determines the icon and label based on the weather condition.
  (IconData, String) _getIconAndText(String condition) {
    final lcCondition = condition.toLowerCase();

    if (lcCondition.contains('clear')) {
      return (Icons.wb_sunny, 'Clear');
    } else if (lcCondition.contains('cloud')) {
      return (Icons.cloud, 'Cloudy');
    } else if (lcCondition.contains('rain')) {
      return (Icons.grain, 'Rain');
    } else if (lcCondition.contains('mist')) {
      return (Icons.cloud_queue, 'Mist');
    } else {
      // Use a default icon and capitalize the condition string
      return (Icons.cloud, condition.capitalize());
    }
  }

  @override
  Widget build(BuildContext context) {
    final (IconData icon, String text) iconText = _getIconAndText(condition);

    return Column(
      children: [
        Icon(
          iconText.$1,
          color: Colors.white,
          size: 40,
        ),
        const SizedBox(height: 8),
        Text(
          iconText.$2,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
