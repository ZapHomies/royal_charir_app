import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Animated mesh gradient background
class AnimatedMeshBackground extends StatefulWidget {
  const AnimatedMeshBackground({
    super.key,
    this.child,
    this.colors,
    this.opacity = 0.6,
  });

  final Widget? child;
  final List<Color>? colors;
  final double opacity;

  @override
  State<AnimatedMeshBackground> createState() => _AnimatedMeshBackgroundState();
}

class _AnimatedMeshBackgroundState extends State<AnimatedMeshBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ?? AppColors.meshGradientColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Base gradient
        Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? AppColors.backgroundGradientDark
                : AppColors.backgroundGradientLight,
          ),
        ),
        // Animated blobs
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _MeshGradientPainter(
                animation: _controller.value,
                colors: colors,
                opacity: widget.opacity,
              ),
              size: Size.infinite,
            );
          },
        ),
        // Content
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _MeshGradientPainter extends CustomPainter {
  _MeshGradientPainter({
    required this.animation,
    required this.colors,
    required this.opacity,
  });

  final double animation;
  final List<Color> colors;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw animated gradient blobs
    for (int i = 0; i < colors.length; i++) {
      final offset = math.pi * 2 * i / colors.length;
      final x =
          size.width * (0.3 + 0.4 * math.cos(animation * 2 * math.pi + offset));
      final y = size.height *
          (0.3 + 0.4 * math.sin(animation * 2 * math.pi + offset * 1.5));
      final radius =
          size.width * (0.3 + 0.1 * math.sin(animation * 2 * math.pi + i));

      paint.shader = RadialGradient(
        colors: [
          colors[i].withValues(alpha: opacity),
          colors[i].withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(x, y), radius: radius));

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MeshGradientPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

/// Gradient orb decoration
class GradientOrb extends StatelessWidget {
  const GradientOrb({
    super.key,
    this.size = 200,
    this.color,
    this.blur = 60,
    this.position = Alignment.topRight,
    this.opacity = 0.5,
  });

  final double size;
  final Color? color;
  final double blur;
  final Alignment position;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: position,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (color ?? AppColors.primary).withValues(alpha: opacity),
                blurRadius: blur,
                spreadRadius: blur / 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Static gradient background with optional orbs
class GradientBackground extends StatelessWidget {
  const GradientBackground({
    super.key,
    required this.child,
    this.gradient,
    this.showOrbs = true,
    this.orbs,
  });

  final Widget child;
  final Gradient? gradient;
  final bool showOrbs;
  final List<GradientOrb>? orbs;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: BoxDecoration(
            gradient: gradient ??
                (isDark
                    ? AppColors.backgroundGradientDark
                    : AppColors.backgroundGradientLight),
          ),
        ),
        // Orbs
        if (showOrbs)
          ...(orbs ??
              [
                GradientOrb(
                  position: const Alignment(-0.8, -0.6),
                  color: AppColors.primary,
                  size: 300,
                  blur: 100,
                  opacity: isDark ? 0.15 : 0.1,
                ),
                GradientOrb(
                  position: const Alignment(0.8, 0.4),
                  color: AppColors.accent,
                  size: 250,
                  blur: 80,
                  opacity: isDark ? 0.15 : 0.1,
                ),
              ]),
        // Content
        child,
      ],
    );
  }
}

/// Noise texture overlay for premium feel
class NoiseOverlay extends StatelessWidget {
  const NoiseOverlay({
    super.key,
    required this.child,
    this.opacity = 0.03,
  });

  final Widget child;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _NoisePainter(opacity: opacity),
            ),
          ),
        ),
      ],
    );
  }
}

class _NoisePainter extends CustomPainter {
  _NoisePainter({required this.opacity});

  final double opacity;
  final math.Random _random = math.Random(42);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 5000; i++) {
      final x = _random.nextDouble() * size.width;
      final y = _random.nextDouble() * size.height;
      paint.color =
          Colors.white.withValues(alpha: _random.nextDouble() * opacity);
      canvas.drawCircle(Offset(x, y), 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
