import 'dart:math';

import 'package:flutter/material.dart';

class RainEffect extends StatefulWidget {
  const RainEffect({super.key});

  @override
  State<RainEffect> createState() => _RainEffectState();
}

class _RainEffectState extends State<RainEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<RainDrop> _rainDrops = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    // Create rain drops
    for (int i = 0; i < 100; i++) {
      _rainDrops.add(RainDrop(
        x: _random.nextDouble() * 1000,
        y: _random.nextDouble() * 1000,
        length: _random.nextDouble() * 10 + 10,
        speed: _random.nextDouble() * 10 + 10,
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
        // Update rain drop positions
        for (var drop in _rainDrops) {
          drop.y += drop.speed;
          if (drop.y > MediaQuery.of(context).size.height) {
            drop.y = -drop.length;
            drop.x = _random.nextDouble() * MediaQuery.of(context).size.width;
          }
        }

        return CustomPaint(
          painter: RainPainter(_rainDrops),
          size: Size.infinite,
        );
      },
    );
  }
}

class RainDrop {
  double x;
  double y;
  final double length;
  final double speed;
  final double opacity;

  RainDrop({
    required this.x,
    required this.y,
    required this.length,
    required this.speed,
    required this.opacity,
  });
}

class RainPainter extends CustomPainter {
  final List<RainDrop> rainDrops;

  RainPainter(this.rainDrops);

  @override
  void paint(Canvas canvas, Size size) {
    for (var drop in rainDrops) {
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: drop.opacity)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(drop.x, drop.y),
        Offset(drop.x, drop.y + drop.length),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(RainPainter oldDelegate) => true;
}