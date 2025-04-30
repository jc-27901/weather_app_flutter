import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:weather_app_flutter/core/services/open_weather_service.dart';

class WeatherAppBar extends StatelessWidget {
  const WeatherAppBar(
      {super.key,
      required this.searchC,
      required this.searchF,
      required this.isSearching,
      this.currentWeather,
      required this.onToggle,
      this.onSubmitted,});

  final TextEditingController searchC;
  final FocusNode searchF;
  final bool isSearching;
  final WeatherData? currentWeather;
  final VoidCallback onToggle;
  final void Function(String)? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: isSearching
                          ? Center(
                              child: TextField(
                                controller: searchC,
                                focusNode: searchF,
                                style: const TextStyle(color: Colors.white),
                                textInputAction: TextInputAction.search,
                                decoration: InputDecoration(
                                  hintText: 'Search city...',
                                  hintStyle: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.7)),
                                  border: InputBorder.none,
                                ),
                                onSubmitted: onSubmitted,
                              ),
                            )
                          : Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: onToggle,
                                    child: Text(
                                      '${currentWeather!.areaName}, ${currentWeather!.countryCode}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        isSearching ? Icons.close : Icons.search,
                        color: Colors.white,
                      ),
                      onPressed: onToggle,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (currentWeather?.date != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Last updated: ${DateFormat('EEEE, h:mm a').format(currentWeather!.date!)}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}
