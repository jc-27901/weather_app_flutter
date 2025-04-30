part of '../map_screen.dart';

class PulsatingContainer extends StatelessWidget {
  const PulsatingContainer({
    super.key,
    required AnimationController markerAnimationController,
  }) : _markerAnimationController = markerAnimationController;

  final AnimationController _markerAnimationController;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60 *
          (0.6 +
              0.4 * _markerAnimationController.value),
      height: 60 *
          (0.6 +
              0.4 * _markerAnimationController.value),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(
            alpha: 0.3 *
                (1 - _markerAnimationController.value)),
        shape: BoxShape.circle,
      ),
    );
  }
}