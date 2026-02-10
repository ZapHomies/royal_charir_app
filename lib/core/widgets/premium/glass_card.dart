import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';

/// Clean Card with subtle transparency - optimized for dark theme
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 12,
    this.blurAmount = 5,
    this.opacity = 0.6,
    this.borderOpacity = 0.1,
    this.gradient,
    this.onTap,
    this.animate = false, // Disabled by default for performance
    this.animationDelay = Duration.zero,
    this.elevation = 0,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blurAmount;
  final double opacity;
  final double borderOpacity;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final bool animate;
  final Duration animationDelay;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget cardContent = Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey[900]!.withValues(alpha: 0.7)
            : Colors.white.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                  blurRadius: elevation * 2,
                  offset: Offset(0, elevation),
                ),
              ]
            : null,
      ),
      padding: padding ?? const EdgeInsets.all(12),
      child: child,
    );

    Widget card = Container(
      margin: margin,
      child: onTap != null
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(borderRadius),
                splashColor: AppColors.primary.withValues(alpha: 0.1),
                highlightColor: AppColors.primary.withValues(alpha: 0.05),
                child: cardContent,
              ),
            )
          : cardContent,
    );

    if (animate) {
      return card
          .animate(delay: animationDelay)
          .fadeIn(duration: 200.ms)
          .slideY(begin: 0.02, end: 0);
    }

    return card;
  }
}

/// Simple Container with clean styling
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.borderRadius = 10,
    this.gradientBorder = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final double borderRadius;
  final bool gradientBorder;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (gradientBorder) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: AppColors.primaryGradient,
        ),
        padding: const EdgeInsets.all(1),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(borderRadius - 1),
          ),
          padding: padding ?? const EdgeInsets.all(12),
          child: child,
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey[900]!.withValues(alpha: 0.6)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
          width: 1,
        ),
      ),
      padding: padding ?? const EdgeInsets.all(12),
      child: child,
    );
  }
}
