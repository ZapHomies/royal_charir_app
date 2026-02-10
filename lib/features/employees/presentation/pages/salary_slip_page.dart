import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Halaman slip gaji karyawan
class SalarySlipPage extends StatelessWidget {
  const SalarySlipPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Slip Gaji Karyawan'),
        elevation: 0,
      ),
      body: _buildComingSoon(isDark, context),
    );
  }

  Widget _buildComingSoon(bool isDark, BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container with animation
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.15),
                    AppColors.accent.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                size: 64,
                color: AppColors.primary,
              ),
            )
                .animate(
                  onComplete: (controller) => controller.repeat(reverse: true),
                )
                .scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1.0, 1.0),
                  duration: 2.seconds,
                ),
            const SizedBox(height: 32),

            // Title
            Text(
              '🚧 Fitur Segera Hadir!',
              style: AppTextStyles.headlineSmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

            const SizedBox(height: 16),

            // Description
            Text(
              'Fitur Slip Gaji sedang dalam tahap pengembangan.\nTunggu update selanjutnya ya!',
              style: AppTextStyles.bodyLarge.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 40),

            // Features coming
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.warning,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Yang Akan Tersedia:',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    '📊',
                    'Buat slip gaji otomatis',
                    isDark,
                    0,
                  ),
                  _buildFeatureItem(
                    '🧮',
                    'Kalkulasi potongan & bonus',
                    isDark,
                    1,
                  ),
                  _buildFeatureItem(
                    '📅',
                    'Riwayat gaji bulanan',
                    isDark,
                    2,
                  ),
                  _buildFeatureItem(
                    '🖨️',
                    'Cetak slip gaji PDF',
                    isDark,
                    3,
                  ),
                  _buildFeatureItem(
                    '📧',
                    'Kirim slip via email/WhatsApp',
                    isDark,
                    4,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

            const SizedBox(height: 32),

            // Back button
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Kembali'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                side: BorderSide(
                  color: isDark ? Colors.white30 : Colors.black26,
                ),
              ),
            ).animate().fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String text, bool isDark, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: 450 + (index * 50)))
        .fadeIn()
        .slideX(begin: 0.1);
  }
}
