import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

/// Modern Card dengan Glassmorphism & Hover Effects
class ModernCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final ModernCardStyle style;
  final bool hasHoverEffect;
  final bool hasShadow;
  final double? width;
  final double? height;
  final Gradient? gradient;

  const ModernCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.style = ModernCardStyle.filled,
    this.hasHoverEffect = true,
    this.hasShadow = true,
    this.width,
    this.height,
    this.gradient,
  });

  @override
  State<ModernCard> createState() => _ModernCardState();
}

class _ModernCardState extends State<ModernCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) {
        if (widget.hasHoverEffect) {
          setState(() => _isHovered = true);
        }
      },
      onExit: (_) {
        if (widget.hasHoverEffect) {
          setState(() => _isHovered = false);
        }
      },
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: widget.width,
          height: widget.height,
          margin: widget.margin ?? EdgeInsets.zero,
          decoration: _getDecoration(isDark),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: widget.padding ?? const EdgeInsets.all(16),
              decoration: widget.gradient != null
                  ? BoxDecoration(gradient: widget.gradient)
                  : null,
              child: widget.child,
            ),
          ),
        )
            .animate(target: _isHovered && widget.onTap != null ? 1 : 0)
            .moveY(end: -4, duration: 200.ms)
            .scaleXY(end: 1.02, duration: 200.ms),
      ),
    );
  }

  BoxDecoration _getDecoration(bool isDark) {
    Color backgroundColor;
    Color? borderColor;
    List<BoxShadow>? shadows;

    switch (widget.style) {
      case ModernCardStyle.filled:
        backgroundColor =
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
        borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
        shadows = widget.hasShadow
            ? _isHovered
                ? (isDark
                    ? AppTheme.elevatedShadowDark
                    : AppTheme.elevatedShadowLight)
                : (isDark ? AppTheme.cardShadowDark : AppTheme.cardShadowLight)
            : null;
        break;

      case ModernCardStyle.outlined:
        backgroundColor = Colors.transparent;
        borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
        shadows = null;
        break;

      case ModernCardStyle.elevated:
        backgroundColor =
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
        borderColor = null;
        shadows = _isHovered
            ? (isDark
                ? AppTheme.elevatedShadowDark
                : AppTheme.elevatedShadowLight)
            : (isDark ? AppTheme.cardShadowDark : AppTheme.cardShadowLight);
        break;

      case ModernCardStyle.glass:
        backgroundColor = (isDark ? AppColors.glassDark : AppColors.glassLight)
            .withValues(alpha: 0.8);
        borderColor =
            (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1);
        shadows = widget.hasShadow
            ? [
                BoxShadow(
                  color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null;
        break;

      case ModernCardStyle.gradient:
        backgroundColor = Colors.transparent;
        borderColor = null;
        shadows = widget.hasShadow
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null;
        break;
    }

    return BoxDecoration(
      color: widget.style == ModernCardStyle.gradient ? null : backgroundColor,
      gradient: widget.style == ModernCardStyle.gradient
          ? (widget.gradient ?? AppColors.primaryGradient)
          : null,
      borderRadius: BorderRadius.circular(16),
      border:
          borderColor != null ? Border.all(color: borderColor, width: 1) : null,
      boxShadow: shadows,
    );
  }
}

/// Helper class untuk AppTheme shadows (referenced in ModernCard)
class AppTheme {
  static List<BoxShadow> get cardShadowLight => [
        const BoxShadow(
          color: AppColors.shadowLight,
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get cardShadowDark => [
        const BoxShadow(
          color: AppColors.shadowDark,
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get elevatedShadowLight => [
        const BoxShadow(
          color: AppColors.shadowLight,
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get elevatedShadowDark => [
        const BoxShadow(
          color: AppColors.shadowDark,
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ];
}

enum ModernCardStyle {
  filled,
  outlined,
  elevated,
  glass,
  gradient,
}
