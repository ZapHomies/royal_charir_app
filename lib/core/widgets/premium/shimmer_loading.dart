import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Modern Shimmer Loading Widget
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Widget? child;
  final bool isLoading;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    this.height = 100,
    this.borderRadius = 12,
    this.child,
    this.isLoading = true,
  });

  /// Create a shimmer placeholder for a circle (avatar)
  factory ShimmerLoading.circle({
    Key? key,
    required double size,
    bool isLoading = true,
    Widget? child,
  }) =>
      _ShimmerCircle(
        key: key,
        size: size,
        isLoading: isLoading,
        child: child,
      );

  /// Create a shimmer placeholder for text lines
  factory ShimmerLoading.text({
    Key? key,
    int lines = 3,
    double height = 12,
    bool isLoading = true,
  }) =>
      _ShimmerText(
        key: key,
        lines: lines,
        lineHeight: height,
        isLoading: isLoading,
      );

  /// Create a shimmer placeholder for a card
  factory ShimmerLoading.card({
    Key? key,
    double height = 120,
    bool isLoading = true,
  }) =>
      _ShimmerCard(
        key: key,
        cardHeight: height,
        isLoading: isLoading,
      );

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading && widget.child != null) {
      return widget.child!;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: isDark
                  ? [
                      AppColors.surfaceVariantDark,
                      AppColors.surfaceVariantDark.withValues(alpha: 0.5),
                      AppColors.surfaceVariantDark,
                    ]
                  : [
                      AppColors.surfaceVariantLight,
                      Colors.white.withValues(alpha: 0.8),
                      AppColors.surfaceVariantLight,
                    ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Circular Shimmer Loading
class _ShimmerCircle extends ShimmerLoading {
  final double size;

  const _ShimmerCircle({
    super.key,
    required this.size,
    super.isLoading,
    super.child,
  }) : super(width: size, height: size, borderRadius: size / 2);
}

/// Text Lines Shimmer Loading
class _ShimmerText extends ShimmerLoading {
  final int lines;
  final double lineHeight;

  const _ShimmerText({
    super.key,
    required this.lines,
    required this.lineHeight,
    super.isLoading,
  }) : super();

  @override
  State<ShimmerLoading> createState() => _ShimmerTextState();
}

class _ShimmerTextState extends _ShimmerLoadingState {
  _ShimmerText get _widget => widget as _ShimmerText;

  @override
  Widget build(BuildContext context) {
    if (!_widget.isLoading) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_widget.lines, (index) {
        // Make the last line shorter
        final widthFactor = index == _widget.lines - 1 ? 0.6 : 1.0;

        return Padding(
          padding: EdgeInsets.only(bottom: index < _widget.lines - 1 ? 8 : 0),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return FractionallySizedBox(
                widthFactor: widthFactor,
                child: Container(
                  height: _widget.lineHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      begin: Alignment(_animation.value - 1, 0),
                      end: Alignment(_animation.value + 1, 0),
                      colors: isDark
                          ? [
                              AppColors.surfaceVariantDark,
                              AppColors.surfaceVariantDark
                                  .withValues(alpha: 0.5),
                              AppColors.surfaceVariantDark,
                            ]
                          : [
                              AppColors.surfaceVariantLight,
                              Colors.white.withValues(alpha: 0.8),
                              AppColors.surfaceVariantLight,
                            ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

/// Card Shimmer Loading
class _ShimmerCard extends ShimmerLoading {
  final double cardHeight;

  const _ShimmerCard({
    super.key,
    required this.cardHeight,
    super.isLoading,
  }) : super(height: cardHeight);

  @override
  State<ShimmerLoading> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends _ShimmerLoadingState {
  _ShimmerCard get _widget => widget as _ShimmerCard;

  @override
  Widget build(BuildContext context) {
    if (!_widget.isLoading) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: _widget.cardHeight,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Row(
            children: [
              // Image placeholder
              Container(
                width: _widget.cardHeight - 32,
                height: _widget.cardHeight - 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment(_animation.value - 1, 0),
                    end: Alignment(_animation.value + 1, 0),
                    colors: isDark
                        ? [
                            AppColors.surfaceVariantDark,
                            AppColors.surfaceVariantDark.withValues(alpha: 0.5),
                            AppColors.surfaceVariantDark,
                          ]
                        : [
                            AppColors.surfaceVariantLight,
                            Colors.white.withValues(alpha: 0.8),
                            AppColors.surfaceVariantLight,
                          ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Text placeholder
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          begin: Alignment(_animation.value - 1, 0),
                          end: Alignment(_animation.value + 1, 0),
                          colors: isDark
                              ? [
                                  AppColors.surfaceVariantDark,
                                  AppColors.surfaceVariantDark
                                      .withValues(alpha: 0.5),
                                  AppColors.surfaceVariantDark,
                                ]
                              : [
                                  AppColors.surfaceVariantLight,
                                  Colors.white.withValues(alpha: 0.8),
                                  AppColors.surfaceVariantLight,
                                ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 12,
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          begin: Alignment(_animation.value - 1, 0),
                          end: Alignment(_animation.value + 1, 0),
                          colors: isDark
                              ? [
                                  AppColors.surfaceVariantDark,
                                  AppColors.surfaceVariantDark
                                      .withValues(alpha: 0.5),
                                  AppColors.surfaceVariantDark,
                                ]
                              : [
                                  AppColors.surfaceVariantLight,
                                  Colors.white.withValues(alpha: 0.8),
                                  AppColors.surfaceVariantLight,
                                ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 12,
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          begin: Alignment(_animation.value - 1, 0),
                          end: Alignment(_animation.value + 1, 0),
                          colors: isDark
                              ? [
                                  AppColors.surfaceVariantDark,
                                  AppColors.surfaceVariantDark
                                      .withValues(alpha: 0.5),
                                  AppColors.surfaceVariantDark,
                                ]
                              : [
                                  AppColors.surfaceVariantLight,
                                  Colors.white.withValues(alpha: 0.8),
                                  AppColors.surfaceVariantLight,
                                ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Grid Shimmer Loading for product grids
class ShimmerGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double childAspectRatio;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  const ShimmerGrid({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 3,
    this.childAspectRatio = 0.75,
    this.mainAxisSpacing = 16,
    this.crossAxisSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const _ShimmerGridItem();
      },
    );
  }
}

class _ShimmerGridItem extends StatefulWidget {
  const _ShimmerGridItem();

  @override
  State<_ShimmerGridItem> createState() => _ShimmerGridItemState();
}

class _ShimmerGridItemState extends State<_ShimmerGridItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    gradient: LinearGradient(
                      begin: Alignment(_animation.value - 1, 0),
                      end: Alignment(_animation.value + 1, 0),
                      colors: isDark
                          ? [
                              AppColors.surfaceVariantDark,
                              AppColors.surfaceVariantDark
                                  .withValues(alpha: 0.5),
                              AppColors.surfaceVariantDark,
                            ]
                          : [
                              AppColors.surfaceVariantLight,
                              Colors.white.withValues(alpha: 0.8),
                              AppColors.surfaceVariantLight,
                            ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              // Content placeholder
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        height: 14,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: LinearGradient(
                            begin: Alignment(_animation.value - 1, 0),
                            end: Alignment(_animation.value + 1, 0),
                            colors: isDark
                                ? [
                                    AppColors.surfaceVariantDark,
                                    AppColors.surfaceVariantDark
                                        .withValues(alpha: 0.5),
                                    AppColors.surfaceVariantDark,
                                  ]
                                : [
                                    AppColors.surfaceVariantLight,
                                    Colors.white.withValues(alpha: 0.8),
                                    AppColors.surfaceVariantLight,
                                  ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                      Container(
                        height: 12,
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: LinearGradient(
                            begin: Alignment(_animation.value - 1, 0),
                            end: Alignment(_animation.value + 1, 0),
                            colors: isDark
                                ? [
                                    AppColors.surfaceVariantDark,
                                    AppColors.surfaceVariantDark
                                        .withValues(alpha: 0.5),
                                    AppColors.surfaceVariantDark,
                                  ]
                                : [
                                    AppColors.surfaceVariantLight,
                                    Colors.white.withValues(alpha: 0.8),
                                    AppColors.surfaceVariantLight,
                                  ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// List Shimmer Loading for lists
class ShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final double spacing;

  const ShimmerList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: index < itemCount - 1 ? spacing : 0),
          child: ShimmerLoading.card(height: itemHeight),
        ),
      ),
    );
  }
}
