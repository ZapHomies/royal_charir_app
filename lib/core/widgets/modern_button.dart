import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Modern Button dengan Glassmorphism & Animations
class ModernButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ModernButtonStyle style;
  final ModernButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final Color? customColor;

  const ModernButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.style = ModernButtonStyle.primary,
    this.size = ModernButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.customColor,
  });

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: widget.isFullWidth ? double.infinity : null,
          height: _getHeight(),
          decoration: _getDecoration(isDark),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.isLoading ? null : widget.onPressed,
              borderRadius: BorderRadius.circular(_getBorderRadius()),
              child: Padding(
                padding: _getPadding(),
                child: Row(
                  mainAxisSize:
                      widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.isLoading)
                      SizedBox(
                        width: _getIconSize(),
                        height: _getIconSize(),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getTextColor(isDark),
                          ),
                        ),
                      )
                    else if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        size: _getIconSize(),
                        color: _getTextColor(isDark),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (!widget.isLoading)
                      Text(
                        widget.text,
                        style: _getTextStyle().copyWith(
                          color: _getTextColor(isDark),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        )
            .animate(target: _isPressed ? 1 : 0)
            .scaleXY(end: 0.95, duration: 100.ms),
      ),
    );
  }

  BoxDecoration _getDecoration(bool isDark) {
    Color backgroundColor;
    List<BoxShadow>? shadows;

    switch (widget.style) {
      case ModernButtonStyle.primary:
        backgroundColor = widget.customColor ?? AppColors.primary;
        shadows = _isHovered
            ? [
                BoxShadow(
                  color: (widget.customColor ?? AppColors.primary)
                      .withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null;
        break;

      case ModernButtonStyle.secondary:
        backgroundColor = isDark
            ? AppColors.surfaceVariantDark
            : AppColors.surfaceVariantLight;
        shadows = _isHovered
            ? [
                BoxShadow(
                  color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null;
        break;

      case ModernButtonStyle.outline:
        backgroundColor = Colors.transparent;
        break;

      case ModernButtonStyle.text:
        backgroundColor = Colors.transparent;
        break;

      case ModernButtonStyle.gradient:
        return BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        );

      case ModernButtonStyle.glass:
        return BoxDecoration(
          color: (isDark ? AppColors.glassDark : AppColors.glassLight)
              .withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          border: Border.all(
            color:
                (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        );
    }

    return BoxDecoration(
      color:
          _isPressed ? backgroundColor.withValues(alpha: 0.9) : backgroundColor,
      borderRadius: BorderRadius.circular(_getBorderRadius()),
      border: widget.style == ModernButtonStyle.outline
          ? Border.all(
              color: widget.customColor ?? AppColors.primary,
              width: 2,
            )
          : null,
      boxShadow: shadows,
    );
  }

  Color _getTextColor(bool isDark) {
    switch (widget.style) {
      case ModernButtonStyle.primary:
      case ModernButtonStyle.gradient:
        return Colors.white;

      case ModernButtonStyle.secondary:
      case ModernButtonStyle.glass:
        return isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

      case ModernButtonStyle.outline:
      case ModernButtonStyle.text:
        return widget.customColor ?? AppColors.primary;
    }
  }

  TextStyle _getTextStyle() {
    switch (widget.size) {
      case ModernButtonSize.small:
        return AppTextStyles.buttonSmall;
      case ModernButtonSize.medium:
        return AppTextStyles.buttonMedium;
      case ModernButtonSize.large:
        return AppTextStyles.buttonLarge;
    }
  }

  double _getHeight() {
    switch (widget.size) {
      case ModernButtonSize.small:
        return 32;
      case ModernButtonSize.medium:
        return 40;
      case ModernButtonSize.large:
        return 48;
    }
  }

  double _getBorderRadius() {
    switch (widget.size) {
      case ModernButtonSize.small:
        return 8;
      case ModernButtonSize.medium:
        return 10;
      case ModernButtonSize.large:
        return 12;
    }
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case ModernButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case ModernButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ModernButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case ModernButtonSize.small:
        return 16;
      case ModernButtonSize.medium:
        return 18;
      case ModernButtonSize.large:
        return 20;
    }
  }
}

enum ModernButtonStyle {
  primary,
  secondary,
  outline,
  text,
  gradient,
  glass,
}

enum ModernButtonSize {
  small,
  medium,
  large,
}
