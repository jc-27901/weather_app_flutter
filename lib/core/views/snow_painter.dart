import 'dart:math';

import 'package:flutter/material.dart';


class SnowEffect extends StatefulWidget {
  const SnowEffect({super.key});

  @override
  State<SnowEffect> createState() => _SnowEffectState();
}

class _SnowEffectState extends State<SnowEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<SnowFlake> _snowFlakes = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    // Create snow flakes
    for (int i = 0; i < 100; i++) {
      _snowFlakes.add(SnowFlake(
        x: _random.nextDouble() * 1000,
        y: _random.nextDouble() * 1000,
        size: _random.nextDouble() * 4 + 2,
        speedY: _random.nextDouble() * 2 + 1,
        speedX: _random.nextDouble() * 1 - 0.5,
        opacity: _random.nextDouble() * 0.6 + 0.3,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Update snow flake positions
        for (var flake in _snowFlakes) {
          flake.y += flake.speedY;
          flake.x += flake.speedX;

          if (flake.y > MediaQuery.of(context).size.height) {
            flake.y = 0;
            flake.x = _random.nextDouble() * MediaQuery.of(context).size.width;
          }

          if (flake.x < 0) {
            flake.x = MediaQuery.of(context).size.width;
          } else if (flake.x > MediaQuery.of(context).size.width) {
            flake.x = 0;
          }
        }

        return CustomPaint(
          painter: SnowPainter(_snowFlakes),
          size: Size.infinite,
        );
      },
    );
  }
}

class SnowPainter extends CustomPainter {
  final List<SnowFlake> snowFlakes;

  SnowPainter(this.snowFlakes);

  @override
  void paint(Canvas canvas, Size size) {
    for (var flake in snowFlakes) {
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: flake.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(flake.x, flake.y),
        flake.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(SnowPainter oldDelegate) => true;
}


class SnowFlake {
  double x;
  double y;
  final double size;
  final double speedY;
  final double speedX;
  final double opacity;

  SnowFlake({
    required this.x,
    required this.y,
    required this.size,
    required this.speedY,
    required this.speedX,
    required this.opacity,
  });
}