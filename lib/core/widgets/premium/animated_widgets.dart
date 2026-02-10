import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';

/// Modern Frosted Glass Container with blur effect
class FrostedGlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? tint;
  final double opacity;
  final List<BoxShadow>? shadows;
  final Border? border;

  const FrostedGlassContainer({
    super.key,
    required this.child,
    this.blur = 10,
    this.borderRadius = 20,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.tint,
    this.opacity = 0.2,
    this.shadows,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTint = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.white.withValues(alpha: 0.7);

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: tint ?? defaultTint,
              borderRadius: BorderRadius.circular(borderRadius),
              border: border ??
                  Border.all(
                    color: isDark
                        ? AppColors.glassBorderDark
                        : AppColors.glassBorderLight,
                    width: 1.5,
                  ),
              boxShadow: shadows,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Animated Gradient Border Container
class GradientBorderContainer extends StatefulWidget {
  final Widget child;
  final List<Color>? gradientColors;
  final double borderWidth;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Duration animationDuration;
  final bool animate;

  const GradientBorderContainer({
    super.key,
    required this.child,
    this.gradientColors,
    this.borderWidth = 2,
    this.borderRadius = 16,
    this.padding,
    this.animationDuration = const Duration(seconds: 3),
    this.animate = true,
  });

  @override
  State<GradientBorderContainer> createState() =>
      _GradientBorderContainerState();
}

class _GradientBorderContainerState extends State<GradientBorderContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = widget.gradientColors ?? AppColors.meshGradientColors;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: SweepGradient(
              center: Alignment.center,
              startAngle: _controller.value * 6.28,
              endAngle: (_controller.value * 6.28) + 6.28,
              colors: [...colors, colors.first],
            ),
          ),
          child: Container(
            margin: EdgeInsets.all(widget.borderWidth),
            padding: widget.padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(
                  widget.borderRadius - widget.borderWidth),
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Animated Floating Action Button with Pulse Effect
class PulsingFAB extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final double size;
  final String? heroTag;
  final String? tooltip;

  const PulsingFAB({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.size = 56,
    this.heroTag,
    this.tooltip,
  });

  @override
  State<PulsingFAB> createState() => _PulsingFABState();
}

class _PulsingFABState extends State<PulsingFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 1, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _opacityAnimation = Tween<double>(begin: 0.5, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fabColor = widget.color ?? AppColors.primary;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulse effect
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              width: widget.size * _scaleAnimation.value,
              height: widget.size * _scaleAnimation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: fabColor.withValues(alpha: _opacityAnimation.value),
              ),
            );
          },
        ),
        // Actual FAB
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: FloatingActionButton(
            heroTag: widget.heroTag,
            onPressed: widget.onPressed,
            tooltip: widget.tooltip,
            backgroundColor: fabColor,
            child: Icon(widget.icon, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

/// Animated Counter Widget
class AnimatedCounter extends StatefulWidget {
  final int value;
  final Duration duration;
  final TextStyle? style;
  final String? prefix;
  final String? suffix;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 800),
    this.style,
    this.prefix,
    this.suffix,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _oldValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _oldValue = oldWidget.value;
      _controller.reset();
      _controller.forward();
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
      animation: _animation,
      builder: (context, child) {
        final currentValue =
            (_oldValue + (widget.value - _oldValue) * _animation.value).round();
        return Text(
          '${widget.prefix ?? ''}$currentValue${widget.suffix ?? ''}',
          style: widget.style,
        );
      },
    );
  }
}

/// Hover Scale Effect Widget
class HoverScaleCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final Duration duration;
  final BorderRadius? borderRadius;

  const HoverScaleCard({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 1.03,
    this.duration = const Duration(milliseconds: 200),
    this.borderRadius,
  });

  @override
  State<HoverScaleCard> createState() => _HoverScaleCardState();
}

class _HoverScaleCardState extends State<HoverScaleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? widget.scale : 1.0,
          duration: widget.duration,
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: widget.duration,
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : [],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Animated List Item Wrapper
class AnimatedListItem extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration delay;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    this.delay = const Duration(milliseconds: 50),
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: Duration(milliseconds: delay.inMilliseconds * index))
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
  }
}

/// Bouncing Scroll Physics for iOS-like feel
class BouncingScrollWrapper extends StatelessWidget {
  final Widget child;

  const BouncingScrollWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const BouncingScrollBehavior(),
      child: child,
    );
  }
}

class BouncingScrollBehavior extends ScrollBehavior {
  const BouncingScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}

/// Animated Page Transition Wrapper
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final SlideDirection direction;

  SlidePageRoute({
    required this.page,
    this.direction = SlideDirection.right,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            Offset begin;
            switch (direction) {
              case SlideDirection.right:
                begin = const Offset(1.0, 0.0);
                break;
              case SlideDirection.left:
                begin = const Offset(-1.0, 0.0);
                break;
              case SlideDirection.up:
                begin = const Offset(0.0, 1.0);
                break;
              case SlideDirection.down:
                begin = const Offset(0.0, -1.0);
                break;
            }

            return SlideTransition(
              position: Tween(begin: begin, end: Offset.zero).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

enum SlideDirection { right, left, up, down }
