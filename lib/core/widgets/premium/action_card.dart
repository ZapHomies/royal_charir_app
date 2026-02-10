import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Premium action card for navigation/quick actions
class ActionCard extends StatefulWidget {
  const ActionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.subtitle,
    this.color,
    this.gradient,
    this.badge,
    this.animationDelay = Duration.zero,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final String? subtitle;
  final Color? color;
  final Gradient? gradient;
  final String? badge;
  final Duration animationDelay;

  @override
  State<ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<ActionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Theme access for future use if needed
    final cardColor = widget.color ?? AppColors.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: _isHovered
              ? (Matrix4.identity()..translate(0.0, -6.0))
              : Matrix4.identity(),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: widget.gradient ??
                LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cardColor,
                    cardColor.withValues(alpha: 0.8),
                  ],
                ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: cardColor.withValues(alpha: _isHovered ? 0.4 : 0.25),
                blurRadius: _isHovered ? 24 : 16,
                offset: Offset(0, _isHovered ? 12 : 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  widget.icon,
                  size: 100,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              // Content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          widget.icon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      if (widget.badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.badge!,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.title,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: widget.animationDelay)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic);
  }
}

/// Quick action button for lists
class QuickActionButton extends StatefulWidget {
  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.isCompact = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final bool isCompact;

  @override
  State<QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<QuickActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Theme access for future use if needed
    final buttonColor = widget.color ?? AppColors.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isCompact ? 12 : 16,
            vertical: widget.isCompact ? 8 : 12,
          ),
          decoration: BoxDecoration(
            color: _isHovered
                ? buttonColor.withValues(alpha: 0.15)
                : buttonColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: buttonColor.withValues(alpha: _isHovered ? 0.3 : 0.15),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: widget.isCompact ? 16 : 20,
                color: buttonColor,
              ),
              SizedBox(width: widget.isCompact ? 6 : 8),
              Text(
                widget.label,
                style: (widget.isCompact
                        ? AppTextStyles.labelSmall
                        : AppTextStyles.labelMedium)
                    .copyWith(
                  color: buttonColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Navigation list tile with premium styling
class PremiumListTile extends StatefulWidget {
  const PremiumListTile({
    super.key,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.leading,
    this.trailing,
    this.iconColor,
    this.showArrow = true,
    this.animationDelay = Duration.zero,
  });

  final String title;
  final VoidCallback onTap;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Color? iconColor;
  final bool showArrow;
  final Duration animationDelay;

  @override
  State<PremiumListTile> createState() => _PremiumListTileState();
}

class _PremiumListTileState extends State<PremiumListTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: _isHovered
                ? (isDark
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariantLight)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              if (widget.leading != null) ...[
                widget.leading!,
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.trailing != null)
                widget.trailing!
              else if (widget.showArrow)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: _isHovered
                      ? (Matrix4.identity()..translate(4.0, 0.0))
                      : Matrix4.identity(),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
                ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: widget.animationDelay)
        .fadeIn(duration: 300.ms)
        .slideX(begin: -0.05, end: 0, curve: Curves.easeOutCubic);
  }
}
