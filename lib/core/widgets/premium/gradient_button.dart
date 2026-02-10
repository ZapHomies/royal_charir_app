import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Premium Gradient Button with hover effects
class GradientButton extends StatefulWidget {
  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.gradient,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height = 52,
    this.borderRadius = 16,
    this.animate = true,
  });

  final String text;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final double height;
  final double borderRadius;
  final bool animate;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Widget button = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.isDisabled
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.isDisabled || widget.isLoading ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: widget.isDisabled
                ? LinearGradient(
                    colors: [Colors.grey.shade400, Colors.grey.shade500],
                  )
                : widget.gradient ?? AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: _isHovered && !widget.isDisabled
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          transform: _isHovered && !widget.isDisabled
              ? Matrix4.translationValues(0, -2, 0)
              : Matrix4.identity(),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.text,
                        style: AppTextStyles.buttonMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );

    if (widget.animate) {
      return button.animate().fadeIn(duration: 300.ms).scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1, 1),
            curve: Curves.easeOutCubic,
          );
    }

    return button;
  }
}

/// Outline Button with gradient border
class GradientOutlineButton extends StatefulWidget {
  const GradientOutlineButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.gradient,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height = 52,
    this.borderRadius = 16,
  });

  final String text;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final double height;
  final double borderRadius;

  @override
  State<GradientOutlineButton> createState() => _GradientOutlineButtonState();
}

class _GradientOutlineButtonState extends State<GradientOutlineButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.isDisabled
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.isDisabled || widget.isLoading ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: widget.gradient ?? AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          padding: const EdgeInsets.all(2),
          transform: _isHovered && !widget.isDisabled
              ? Matrix4.translationValues(0, -2, 0)
              : Matrix4.identity(),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(widget.borderRadius - 2),
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : ShaderMask(
                      shaderCallback: (bounds) {
                        return (widget.gradient ?? AppColors.primaryGradient)
                            .createShader(bounds);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.text,
                            style: AppTextStyles.buttonMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Icon Button with gradient background
class GradientIconButton extends StatefulWidget {
  const GradientIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.gradient,
    this.size = 48,
    this.iconSize = 24,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Gradient? gradient;
  final double size;
  final double iconSize;
  final String? tooltip;

  @override
  State<GradientIconButton> createState() => _GradientIconButtonState();
}

class _GradientIconButtonState extends State<GradientIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Widget button = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            gradient: widget.gradient ?? AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(widget.size / 3),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          transform: _isHovered
              ? Matrix4.translationValues(0, -2, 0)
              : Matrix4.identity(),
          child: Icon(widget.icon, color: Colors.white, size: widget.iconSize),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: button);
    }

    return button;
  }
}
