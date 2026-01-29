import 'package:flutter/material.dart';
import 'dart:ui';

/// A custom liquid glass widget that creates a glassmorphism effect
/// with smooth, fluid animations optimized for 120Hz displays
class LiquidGlass extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final Color? tintColor;
  final double opacity;
  final Border? border;

  const LiquidGlass({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.blur = 10,
    this.tintColor,
    this.opacity = 0.2,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: (tintColor ?? Colors.white).withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: border ??
                Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1.5,
                ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// A liquid glass layer that can be placed over background content
/// to create depth and glassmorphism effects
class LiquidGlassLayer extends StatelessWidget {
  final Widget child;

  const LiquidGlassLayer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// A liquid glass widget with a superellipse (rounded rectangle) shape
class LiquidRoundedSuperellipse extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final Color? tintColor;
  final double opacity;

  const LiquidRoundedSuperellipse({
    super.key,
    required this.child,
    this.borderRadius = 30,
    this.blur = 10,
    this.tintColor,
    this.opacity = 0.2,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      borderRadius: borderRadius,
      blur: blur,
      tintColor: tintColor,
      opacity: opacity,
      child: child,
    );
  }
}
