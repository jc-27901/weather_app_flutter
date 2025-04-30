import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BaseBottomNavbar extends StatelessWidget {
  const BaseBottomNavbar({super.key, required this.navigateToMap});

  final VoidCallback navigateToMap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                NavItem(icon: Icons.home, label: 'Home', isActive: true),
                NavItem(
                    icon: Icons.map,
                    label: 'Map',
                    isActive: false,
                    onTap: navigateToMap),
                NavItem(
                    icon: Icons.settings, label: 'Settings', isActive: false),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 1800.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0);
  }
}

class NavItem extends StatelessWidget {
  const NavItem(
      {super.key,
      required this.icon,
      required this.label,
      required this.isActive,
      this.onTap});
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color:
                isActive ? Colors.white : Colors.white.withValues(alpha: 0.5),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color:
                  isActive ? Colors.white : Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
