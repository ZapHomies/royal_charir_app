import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Widget tombol tutorial untuk app bar
class TutorialButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String tooltip;
  final bool showPulse;

  const TutorialButton({
    super.key,
    required this.onPressed,
    this.tooltip = 'Tutorial & Bantuan',
    this.showPulse = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.15),
                AppColors.primary.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.help_outline_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                '?',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (showPulse) {
      button = button
          .animate(
            onComplete: (controller) => controller.repeat(reverse: true),
          )
          .shimmer(
            duration: 2.seconds,
            color: AppColors.primary.withOpacity(0.3),
          );
    }

    return Tooltip(
      message: tooltip,
      child: button,
    );
  }
}

/// Widget untuk menampilkan tutorial dengan langkah-langkah visual
class FeatureTutorialDialog extends StatefulWidget {
  final String title;
  final String featureKey;
  final List<TutorialStep> steps;
  final VoidCallback? onComplete;

  const FeatureTutorialDialog({
    super.key,
    required this.title,
    required this.featureKey,
    required this.steps,
    this.onComplete,
  });

  @override
  State<FeatureTutorialDialog> createState() => _FeatureTutorialDialogState();
}

class _FeatureTutorialDialogState extends State<FeatureTutorialDialog> {
  int _currentStep = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < widget.steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      widget.onComplete?.call();
      Navigator.of(context).pop();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isWide ? size.width * 0.15 : 16,
        vertical: 24,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 700,
          maxHeight: size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(isDark),

            // Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentStep = index),
                itemCount: widget.steps.length,
                itemBuilder: (context, index) {
                  return _buildStepContent(widget.steps[index], index, isDark);
                },
              ),
            ),

            // Footer with navigation
            _buildFooter(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final step = widget.steps[_currentStep];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            step.color.withOpacity(0.2),
            step.color.withOpacity(0.05),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [step.color, step.color.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: step.color.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              step.icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: step.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Langkah ${_currentStep + 1} dari ${widget.steps.length}',
                        style: AppTextStyles.caption.copyWith(
                          color: step.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close_rounded,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildStepContent(TutorialStep step, int index, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step title
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [step.color, step.color.withOpacity(0.7)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step.title,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ).animate(delay: 100.ms).fadeIn().slideX(begin: -0.1),

          const SizedBox(height: 20),

          // Visual instruction card
          if (step.visualInstruction != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    step.color.withOpacity(0.1),
                    step.color.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: step.color.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    step.visualInstruction!.icon,
                    size: 64,
                    color: step.color,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    step.visualInstruction!.label,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: step.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (step.visualInstruction!.arrow != null) ...[
                    const SizedBox(height: 8),
                    Icon(
                      step.visualInstruction!.arrow,
                      size: 32,
                      color: step.color.withOpacity(0.7),
                    ),
                  ],
                ],
              ),
            )
                .animate(delay: 200.ms)
                .fadeIn()
                .scale(begin: const Offset(0.95, 0.95)),

          const SizedBox(height: 20),

          // Description
          Text(
            step.description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
              height: 1.6,
            ),
          ).animate(delay: 300.ms).fadeIn(),

          // Detail steps
          if (step.detailSteps.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.checklist_rounded,
                        color: step.color,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Langkah Detail:',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: step.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...step.detailSteps.asMap().entries.map((entry) {
                    final stepIndex = entry.key;
                    final stepText = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: step.color.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${stepIndex + 1}',
                                style: TextStyle(
                                  color: step.color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              stepText,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isDark
                                    ? Colors.white70
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate(
                            delay:
                                Duration(milliseconds: 400 + (stepIndex * 50)))
                        .fadeIn()
                        .slideX(begin: 0.1);
                  }),
                ],
              ),
            ),
          ],

          // Tips
          if (step.tips.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_rounded,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tips:',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: Colors.amber.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...step.tips.map((tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('💡 ',
                                style: TextStyle(color: Colors.amber.shade700)),
                            Expanded(
                              child: Text(
                                tip,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: isDark
                                      ? Colors.amber.shade200
                                      : Colors.amber.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ).animate(delay: 500.ms).fadeIn(),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    final step = widget.steps[_currentStep];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.grey.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Progress indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.steps.length,
              (index) => GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentStep == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentStep == index
                        ? step.color
                        : (isDark ? Colors.white24 : Colors.black26),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Navigation buttons
          Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _previousStep,
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text('Sebelumnya'),
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
              if (_currentStep > 0) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _nextStep,
                  icon: Icon(
                    _currentStep == widget.steps.length - 1
                        ? Icons.check_rounded
                        : Icons.arrow_forward_rounded,
                    size: 18,
                  ),
                  label: Text(
                    _currentStep == widget.steps.length - 1
                        ? 'Selesai'
                        : 'Lanjut',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: step.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Model untuk langkah tutorial
class TutorialStep {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> detailSteps;
  final List<String> tips;
  final VisualInstruction? visualInstruction;

  const TutorialStep({
    required this.title,
    required this.description,
    required this.icon,
    this.color = const Color(0xFF6366F1),
    this.detailSteps = const [],
    this.tips = const [],
    this.visualInstruction,
  });
}

/// Model untuk instruksi visual
class VisualInstruction {
  final IconData icon;
  final String label;
  final IconData? arrow;

  const VisualInstruction({
    required this.icon,
    required this.label,
    this.arrow,
  });
}

/// Helper untuk menampilkan tutorial dialog
void showFeatureTutorial(
  BuildContext context, {
  required String title,
  required String featureKey,
  required List<TutorialStep> steps,
  VoidCallback? onComplete,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => FeatureTutorialDialog(
      title: title,
      featureKey: featureKey,
      steps: steps,
      onComplete: onComplete,
    ),
  );
}
