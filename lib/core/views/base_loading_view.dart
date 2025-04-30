import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BaseLoadingView extends StatelessWidget {
  const BaseLoadingView(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            'Fetching weather data...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ]
            .animate(interval: 200.ms)
            .fadeIn(duration: 500.ms)
            .slideY(begin: 0.2, end: 0),
      ),
    );
  }
}
