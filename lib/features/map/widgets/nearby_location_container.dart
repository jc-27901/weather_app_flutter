import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NearbyLocationContainer extends StatelessWidget {
  const NearbyLocationContainer(
      {super.key, required this.temp});

  final double temp;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: _getMarkerColor(temp),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '${temp.toStringAsFixed(0)}°',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ),
    ).animate().scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: 300.ms,
          curve: Curves.easeInOut,
        );
  }
}



Color _getMarkerColor(double temperature) {
  if (temperature < 5) return Colors.blue[700]!;
  if (temperature < 10) return Colors.blue[400]!;
  if (temperature < 15) return Colors.cyan;
  if (temperature < 20) return Colors.teal;
  if (temperature < 25) return Colors.amber;
  if (temperature < 30) return Colors.orange;
  return Colors.red;
}