import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'providers/onboarding_provider.dart';

/// Helper class untuk menampilkan tutorial
class TutorialHelper {
  /// Cek apakah harus menampilkan tour untuk fitur tertentu
  static bool shouldShowTour(WidgetRef ref, String tourKey) {
    final tours = ref.read(featureTourProvider);
    return !(tours[tourKey] ?? false);
  }

  /// Tandai tour sebagai selesai
  static Future<void> completeTour(WidgetRef ref, String tourKey) async {
    await ref.read(featureTourProvider.notifier).completeTour(tourKey);
  }

  /// Reset semua tutorial
  static Future<void> resetAllTutorials(WidgetRef ref) async {
    await ref.read(onboardingCompleteProvider.notifier).resetOnboarding();
    await ref.read(featureTourProvider.notifier).resetAllTours();
  }

  /// Tampilkan dialog konfirmasi reset tutorial
  static Future<void> showResetTutorialDialog(
      BuildContext context, WidgetRef ref) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.refresh_rounded, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(
              'Reset Tutorial?',
              style: AppTextStyles.titleMedium.copyWith(
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
        content: Text(
          'Semua tutorial akan ditampilkan kembali saat Anda mengakses masing-masing menu. '
          'Berguna jika Anda ingin mempelajari fitur-fitur lagi.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Reset'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await resetAllTutorials(ref);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 12),
                const Text('Tutorial berhasil direset!'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }
}

/// Widget tombol bantuan/tutorial untuk app bar
class TutorialHelpButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String tooltip;

  const TutorialHelpButton({
    super.key,
    required this.onPressed,
    this.tooltip = 'Bantuan & Tutorial',
  });

  @override
  Widget build(BuildContext context) {
    final _ = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.2),
                AppColors.primary.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.help_outline_rounded,
            color: AppColors.primary,
            size: 20,
          ),
        ),
      )
          .animate(
            onComplete: (controller) => controller.repeat(reverse: true),
          )
          .shimmer(
            duration: 3.seconds,
            color: AppColors.primary.withOpacity(0.3),
          ),
    );
  }
}

/// Widget dialog pemilihan tutorial
class TutorialPickerDialog extends StatelessWidget {
  const TutorialPickerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final tutorials = [
      _TutorialOption(
        icon: Icons.dashboard_rounded,
        title: 'Tour Dashboard',
        description: 'Pelajari navigasi dan fitur dashboard',
        color: const Color(0xFF6366F1),
        tourKey: TutorialKeys.dashboardTourComplete,
      ),
      _TutorialOption(
        icon: Icons.add_box_rounded,
        title: 'Cara Input Produk',
        description: 'Langkah-langkah menambah produk baru',
        color: const Color(0xFF10B981),
        tourKey: TutorialKeys.productTourComplete,
      ),
      _TutorialOption(
        icon: Icons.point_of_sale_rounded,
        title: 'Cara Menggunakan Kasir',
        description: 'Proses transaksi penjualan',
        color: const Color(0xFFF59E0B),
        tourKey: TutorialKeys.cashierTourComplete,
      ),
      _TutorialOption(
        icon: Icons.layers_rounded,
        title: 'Kelola Bahan Baku',
        description: 'Pantau stok bahan produksi',
        color: const Color(0xFFEC4899),
        tourKey: TutorialKeys.materialTourComplete,
      ),
      _TutorialOption(
        icon: Icons.cloud_sync_rounded,
        title: 'Backup & Sinkronisasi',
        description: 'Amankan dan sinkronkan data',
        color: const Color(0xFF3B82F6),
        tourKey: TutorialKeys.syncTourComplete,
      ),
    ];

    return Dialog(
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pusat Bantuan',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: isDark
                              ? Colors.white
                              : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Pilih tutorial yang ingin dipelajari',
                        style: AppTextStyles.caption.copyWith(
                          color: isDark
                              ? Colors.white60
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Tutorial list
            ...tutorials.asMap().entries.map((entry) {
              final index = entry.key;
              final tutorial = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : tutorial.color.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context, tutorial.tourKey);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: tutorial.color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              tutorial.icon,
                              color: tutorial.color,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tutorial.title,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.textPrimaryLight,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  tutorial.description,
                                  style: AppTextStyles.caption.copyWith(
                                    color: isDark
                                        ? Colors.white54
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: isDark ? Colors.white30 : Colors.black26,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
                  .animate(delay: Duration(milliseconds: 100 * index))
                  .fadeIn()
                  .slideX(begin: 0.1);
            }),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Reset button
            Consumer(
              builder: (context, ref, _) {
                return TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    TutorialHelper.showResetTutorialDialog(context, ref);
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Reset Semua Tutorial'),
                  style: TextButton.styleFrom(
                    foregroundColor: isDark ? Colors.white60 : Colors.black54,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TutorialOption {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final String tourKey;

  const _TutorialOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.tourKey,
  });
}
