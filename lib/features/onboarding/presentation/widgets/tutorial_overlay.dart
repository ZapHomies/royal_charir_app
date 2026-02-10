import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Widget untuk menampilkan overlay tutorial dengan highlight dan tooltip
class TutorialOverlay extends StatefulWidget {
  final List<TutorialTarget> targets;
  final int currentStep;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onSkip;
  final VoidCallback onComplete;

  const TutorialOverlay({
    super.key,
    required this.targets,
    required this.currentStep,
    required this.onNext,
    required this.onPrevious,
    required this.onSkip,
    required this.onComplete,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.targets.isEmpty || widget.currentStep >= widget.targets.length) {
      return const SizedBox.shrink();
    }

    final target = widget.targets[widget.currentStep];
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get target position
    Rect? targetRect;
    if (target.targetKey?.currentContext != null) {
      final RenderBox box =
          target.targetKey!.currentContext!.findRenderObject() as RenderBox;
      final position = box.localToGlobal(Offset.zero);
      targetRect = Rect.fromLTWH(
        position.dx - 8,
        position.dy - 8,
        box.size.width + 16,
        box.size.height + 16,
      );
    }

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Backdrop with hole
          if (targetRect != null)
            _buildBackdropWithHole(size, targetRect, isDark)
          else
            _buildFullBackdrop(isDark),

          // Pulse animation around target
          if (targetRect != null)
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Positioned(
                  left: targetRect!.left - _pulseAnimation.value,
                  top: targetRect.top - _pulseAnimation.value,
                  child: Container(
                    width: targetRect.width + (_pulseAnimation.value * 2),
                    height: targetRect.height + (_pulseAnimation.value * 2),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(12 + _pulseAnimation.value),
                      border: Border.all(
                        color: target.color.withOpacity(0.6),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: target.color.withOpacity(0.3),
                          blurRadius: 20 + _pulseAnimation.value,
                          spreadRadius: _pulseAnimation.value,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

          // Tooltip
          _buildTooltip(target, targetRect, size, isDark),

          // Skip button
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: TextButton.icon(
                onPressed: widget.onSkip,
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('Lewati Tutorial'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white70,
                  backgroundColor: Colors.black26,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }

  Widget _buildBackdropWithHole(Size size, Rect targetRect, bool isDark) {
    return CustomPaint(
      size: size,
      painter: _HolePainter(
        holeRect: targetRect,
        backgroundColor: Colors.black.withOpacity(0.75),
      ),
    );
  }

  Widget _buildFullBackdrop(bool isDark) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
      child: Container(
        color: Colors.black.withOpacity(0.7),
      ),
    );
  }

  Widget _buildTooltip(
      TutorialTarget target, Rect? targetRect, Size size, bool isDark) {
    // Calculate tooltip position
    double top = 0;
    double left = 0;
    bool showAbove = false;

    if (targetRect != null) {
      // Check if we should show above or below
      if (targetRect.bottom + 250 > size.height) {
        showAbove = true;
        top = targetRect.top - 220;
      } else {
        top = targetRect.bottom + 20;
      }

      // Center horizontally with the target
      left = targetRect.center.dx - 175;
      // Clamp to screen bounds
      left = left.clamp(16.0, size.width - 366.0);
    } else {
      // Center on screen
      top = size.height / 2 - 100;
      left = size.width / 2 - 175;
    }

    return Positioned(
      top: top,
      left: left,
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: target.color.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: target.color.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Arrow pointing to target
            if (targetRect != null)
              Align(
                alignment:
                    showAbove ? Alignment.bottomCenter : Alignment.topCenter,
                child: Transform.rotate(
                  angle: showAbove ? 3.14159 : 0,
                  child: Icon(
                    Icons.arrow_drop_up_rounded,
                    color: target.color,
                    size: 40,
                  ),
                ),
              ),

            // Header with icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [target.color, target.color.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(target.icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        target.title,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: isDark
                              ? Colors.white
                              : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Langkah ${widget.currentStep + 1} dari ${widget.targets.length}',
                        style: AppTextStyles.caption.copyWith(
                          color: target.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              target.description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                height: 1.5,
              ),
            ),

            // Tips if available
            if (target.tips.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: target.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_rounded,
                            color: target.color, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Tips:',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: target.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...target.tips.map((tip) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('• ', style: TextStyle(color: target.color)),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: AppTextStyles.caption.copyWith(
                                    color: isDark
                                        ? Colors.white60
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Navigation buttons
            Row(
              children: [
                if (widget.currentStep > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onPrevious,
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('Sebelumnya'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            isDark ? Colors.white70 : Colors.black54,
                        side: BorderSide(
                          color: isDark ? Colors.white24 : Colors.black26,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  )
                else
                  const Spacer(),
                if (widget.currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: widget.currentStep == widget.targets.length - 1
                        ? widget.onComplete
                        : widget.onNext,
                    icon: Icon(
                      widget.currentStep == widget.targets.length - 1
                          ? Icons.check_rounded
                          : Icons.arrow_forward_rounded,
                      size: 18,
                    ),
                    label: Text(
                      widget.currentStep == widget.targets.length - 1
                          ? 'Selesai!'
                          : 'Lanjut',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: target.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
    );
  }
}

/// Model untuk target tutorial
class TutorialTarget {
  final String title;
  final String description;
  final GlobalKey? targetKey;
  final IconData icon;
  final Color color;
  final List<String> tips;

  const TutorialTarget({
    required this.title,
    required this.description,
    this.targetKey,
    this.icon = Icons.info_rounded,
    this.color = const Color(0xFF6366F1),
    this.tips = const [],
  });
}

/// Custom painter untuk membuat hole di backdrop
class _HolePainter extends CustomPainter {
  final Rect holeRect;
  final Color backgroundColor;

  _HolePainter({
    required this.holeRect,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = backgroundColor;

    // Create path with hole
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(holeRect, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Mixin untuk menambahkan tutorial ke halaman
mixin TutorialMixin<T extends StatefulWidget> on State<T> {
  List<TutorialTarget> get tutorialTargets;
  String get tutorialKey;

  int _currentStep = 0;
  bool _showTutorial = false;

  bool get showTutorial => _showTutorial;
  int get currentStep => _currentStep;

  void startTutorial() {
    setState(() {
      _currentStep = 0;
      _showTutorial = true;
    });
  }

  void nextStep() {
    if (_currentStep < tutorialTargets.length - 1) {
      setState(() => _currentStep++);
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void skipTutorial() {
    setState(() => _showTutorial = false);
  }

  void completeTutorial() {
    setState(() => _showTutorial = false);
  }

  Widget buildTutorialOverlay() {
    if (!_showTutorial) return const SizedBox.shrink();

    return TutorialOverlay(
      targets: tutorialTargets,
      currentStep: _currentStep,
      onNext: nextStep,
      onPrevious: previousStep,
      onSkip: skipTutorial,
      onComplete: completeTutorial,
    );
  }
}
