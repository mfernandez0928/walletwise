import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'dart:ui';

class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final List<Color>? gradient;
  final bool hasShadow;
  final VoidCallback? onTap;

  const ModernCard({
    Key? key,
    required this.child,
    this.padding,
    this.gradient,
    this.hasShadow = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient != null
              ? LinearGradient(
                  colors: gradient!,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: gradient == null ? AppColors.cardBg : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow: hasShadow
              ? [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: child,
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double blur;
  final double opacity;

  const GlassCard({
    Key? key,
    required this.child,
    this.padding,
    this.blur = 10,
    this.opacity = 0.1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
