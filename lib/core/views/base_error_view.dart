
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BaseErrorView extends StatelessWidget {
  const BaseErrorView({super.key, required this.errText, required this.onTryAgain});
  final String errText;
  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              errText,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onTryAgain,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ]
            .animate(interval: 200.ms)
            .fadeIn(duration: 500.ms)
            .slideY(begin: 0.2, end: 0),
      ),
    );
  }
}
