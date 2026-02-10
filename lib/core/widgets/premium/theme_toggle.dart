import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../providers/theme_provider.dart';
import '../../theme/app_colors.dart';

/// Animated Theme Toggle Switch
class ThemeToggle extends ConsumerStatefulWidget {
  final bool showLabel;
  final double size;

  const ThemeToggle({
    super.key,
    this.showLabel = true,
    this.size = 56,
  });

  @override
  ConsumerState<ThemeToggle> createState() => _ThemeToggleState();
}

class _ThemeToggleState extends ConsumerState<ThemeToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    // Update animation based on theme
    if (isDark && _controller.status != AnimationStatus.completed) {
      _controller.forward();
    } else if (!isDark && _controller.status != AnimationStatus.dismissed) {
      _controller.reverse();
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ref.read(themeProvider.notifier).toggleTheme();
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            width: widget.size,
            height: widget.size * 0.5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.size * 0.25),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                    const Color(0xFF87CEEB), // Light blue sky
                    const Color(0xFF1A1A2E), // Dark night sky
                    _animation.value,
                  )!,
                  Color.lerp(
                    const Color(0xFFFFA500), // Orange sun
                    const Color(0xFF0D1B2A), // Deep night
                    _animation.value,
                  )!,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color.lerp(
                    const Color(0xFFFFA500).withValues(alpha: 0.3),
                    const Color(0xFF6366F1).withValues(alpha: 0.3),
                    _animation.value,
                  )!,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Stars (appear in dark mode)
                ...List.generate(5, (index) {
                  final positions = [
                    const Offset(0.15, 0.2),
                    const Offset(0.7, 0.3),
                    const Offset(0.5, 0.7),
                    const Offset(0.25, 0.6),
                    const Offset(0.8, 0.65),
                  ];
                  return Positioned(
                    left: positions[index].dx * widget.size,
                    top: positions[index].dy * widget.size * 0.5,
                    child: Opacity(
                      opacity: _animation.value * 0.8,
                      child: Container(
                        width: 2 + (index % 2),
                        height: 2 + (index % 2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),

                // Moon crater (appears in dark mode)
                Positioned(
                  left: widget.size * 0.6 +
                      (widget.size * 0.25 * _animation.value),
                  top: widget.size * 0.08,
                  child: Opacity(
                    opacity: _animation.value,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),

                // Sun/Moon toggle
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  left: isDark ? widget.size * 0.55 : widget.size * 0.05,
                  top: widget.size * 0.05,
                  child: Container(
                    width: widget.size * 0.4,
                    height: widget.size * 0.4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Color.lerp(
                            const Color(0xFFFFD700), // Sun yellow
                            const Color(0xFFF5F5F5), // Moon white
                            _animation.value,
                          )!,
                          Color.lerp(
                            const Color(0xFFFFA500), // Sun orange
                            const Color(0xFFE0E0E0), // Moon gray
                            _animation.value,
                          )!,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color.lerp(
                            const Color(0xFFFFD700).withValues(alpha: 0.5),
                            Colors.white.withValues(alpha: 0.3),
                            _animation.value,
                          )!,
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ).animate().scale(duration: 200.ms, curve: Curves.easeOut);
  }
}

/// Simple Theme Icon Button
class ThemeIconButton extends ConsumerWidget {
  final double size;
  final Color? color;

  const ThemeIconButton({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    final iconColor = color ??
        (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return RotationTransition(
            turns: Tween(begin: 0.75, end: 1.0).animate(animation),
            child: ScaleTransition(scale: animation, child: child),
          );
        },
        child: Icon(
          isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          key: ValueKey(isDark),
          size: size,
          color: iconColor,
        ),
      ),
      onPressed: () {
        HapticFeedback.lightImpact();
        ref.read(themeProvider.notifier).toggleTheme();
      },
      tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
    );
  }
}

/// Theme Mode Selector with Radio buttons
class ThemeModeSelector extends ConsumerWidget {
  const ThemeModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceVariantDark
            : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Appearance',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 12),
          _buildOption(
            context,
            ref,
            ThemeMode.light,
            'Light',
            Icons.light_mode_rounded,
            currentMode,
          ),
          const SizedBox(height: 8),
          _buildOption(
            context,
            ref,
            ThemeMode.dark,
            'Dark',
            Icons.dark_mode_rounded,
            currentMode,
          ),
          const SizedBox(height: 8),
          _buildOption(
            context,
            ref,
            ThemeMode.system,
            'System',
            Icons.settings_suggest_rounded,
            currentMode,
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context,
    WidgetRef ref,
    ThemeMode mode,
    String label,
    IconData icon,
    ThemeMode currentMode,
  ) {
    final isSelected = currentMode == mode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isSelected
          ? (isDark
              ? AppColors.primaryLight.withValues(alpha: 0.15)
              : AppColors.primary.withValues(alpha: 0.1))
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          ref.read(themeProvider.notifier).setTheme(mode);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected
                    ? (isDark ? AppColors.primaryLight : AppColors.primary)
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? (isDark ? AppColors.primaryLight : AppColors.primary)
                      : (isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight),
                ),
              ),
              const Spacer(),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  size: 20,
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
