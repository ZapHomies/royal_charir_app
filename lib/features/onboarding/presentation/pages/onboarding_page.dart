import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/onboarding_step.dart';
import '../../providers/onboarding_provider.dart';

/// Halaman Onboarding dengan animasi menarik dan layout rapi
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < OnboardingData.steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    await ref.read(onboardingCompleteProvider.notifier).completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 800;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0F0F1A),
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                  ]
                : [
                    const Color(0xFFF8FAFC),
                    const Color(0xFFE2E8F0),
                    const Color(0xFFCBD5E1),
                  ],
          ),
        ),
        child: SafeArea(
          child: isWideScreen
              ? _buildWideLayout(isDark, size)
              : _buildNarrowLayout(isDark, size),
        ),
      ),
    );
  }

  /// Layout untuk layar lebar (desktop/tablet landscape)
  Widget _buildWideLayout(bool isDark, Size size) {
    final step = OnboardingData.steps[_currentPage];

    return Row(
      children: [
        // Left side - Illustration
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  step.color.withOpacity(0.15),
                  step.color.withOpacity(0.05),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated icon
                AnimatedBuilder(
                  animation: _floatAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatAnimation.value),
                      child: child,
                    );
                  },
                  child: _buildAnimatedIcon(step, isDark),
                ),
                const SizedBox(height: 40),

                // Tips grid
                _buildTipsGrid(step.tips, step.color, isDark),
              ],
            ),
          ).animate().fadeIn(),
        ),

        // Right side - Content
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                _buildHeader(isDark),
                const Spacer(),

                // Content area with PageView
                Expanded(
                  flex: 4,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: OnboardingData.steps.length,
                    itemBuilder: (context, index) {
                      return _buildContentOnly(
                          OnboardingData.steps[index], isDark);
                    },
                  ),
                ),

                const Spacer(),

                // Bottom navigation
                _buildBottomNavigation(isDark),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Layout untuk layar sempit (phone/tablet portrait)
  Widget _buildNarrowLayout(bool isDark, Size size) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: _buildHeader(isDark),
        ),

        // Page content
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: OnboardingData.steps.length,
            itemBuilder: (context, index) {
              return _buildPageContent(OnboardingData.steps[index], isDark);
            },
          ),
        ),

        // Bottom navigation
        Padding(
          padding: const EdgeInsets.all(20),
          child: _buildBottomNavigation(isDark),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.store_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Royal Charir',
              style: AppTextStyles.titleSmall.copyWith(
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ).animate().fadeIn().slideX(begin: -0.2),

        // Skip button
        if (_currentPage < OnboardingData.steps.length - 1)
          TextButton(
            onPressed: _completeOnboarding,
            child: Text(
              'Lewati →',
              style: TextStyle(
                color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ).animate().fadeIn().slideX(begin: 0.2),
      ],
    );
  }

  Widget _buildAnimatedIcon(OnboardingStep step, bool isDark) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            step.color.withOpacity(0.3),
            step.color.withOpacity(0.1),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: step.color.withOpacity(0.3),
            blurRadius: 60,
            spreadRadius: 20,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [step.color, step.color.withOpacity(0.8)],
          ),
          boxShadow: [
            BoxShadow(
              color: step.color.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Icon(
          step.icon,
          size: 60,
          color: Colors.white,
        ),
      ),
    ).animate().scale(begin: const Offset(0.8, 0.8)).fadeIn();
  }

  Widget _buildContentOnly(OnboardingStep step, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Title
        Text(
          step.title,
          style: AppTextStyles.headlineSmall.copyWith(
            color: isDark ? Colors.white : AppColors.textPrimaryLight,
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
        const SizedBox(height: 16),

        // Description
        Text(
          step.description,
          style: AppTextStyles.bodyLarge.copyWith(
            color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
            height: 1.6,
          ),
        ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),
      ],
    );
  }

  Widget _buildPageContent(OnboardingStep step, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Animated Icon
          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: child,
              );
            },
            child: _buildAnimatedIcon(step, isDark),
          ),
          const SizedBox(height: 32),

          // Title
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineSmall.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),
          const SizedBox(height: 16),

          // Description
          Text(
            step.description,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
              height: 1.6,
            ),
          ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),
          const SizedBox(height: 24),

          // Tips
          _buildTipsGrid(step.tips, step.color, isDark),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTipsGrid(List<String> tips, Color color, bool isDark) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: tips.asMap().entries.map((entry) {
        final index = entry.key;
        final tip = entry.value;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            tip,
            style: AppTextStyles.labelSmall.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        )
            .animate(delay: Duration(milliseconds: 400 + (index * 80)))
            .fadeIn()
            .scale(begin: const Offset(0.9, 0.9));
      }).toList(),
    );
  }

  Widget _buildBottomNavigation(bool isDark) {
    final step = OnboardingData.steps[_currentPage];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Page indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            OnboardingData.steps.length,
            (index) => GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: _currentPage == index ? 28 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? step.color
                      : (isDark ? Colors.white24 : Colors.black26),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Navigation buttons
        Row(
          children: [
            // Back button
            if (_currentPage > 0)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _previousPage,
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Kembali'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: isDark ? Colors.white30 : Colors.black26,
                    ),
                    foregroundColor: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              )
            else
              const Spacer(),

            if (_currentPage > 0) const SizedBox(width: 12),

            // Next/Complete button
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [step.color, step.color.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: step.color.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _nextPage,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == OnboardingData.steps.length - 1
                                ? 'Mulai Sekarang!'
                                : 'Lanjutkan',
                            style: AppTextStyles.titleSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _currentPage == OnboardingData.steps.length - 1
                                ? Icons.rocket_launch_rounded
                                : Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Step counter
        Text(
          'Langkah ${_currentPage + 1} dari ${OnboardingData.steps.length}',
          style: AppTextStyles.caption.copyWith(
            color: isDark
                ? Colors.white.withOpacity(0.4)
                : AppColors.textTertiaryLight,
          ),
        ),
      ],
    );
  }
}
