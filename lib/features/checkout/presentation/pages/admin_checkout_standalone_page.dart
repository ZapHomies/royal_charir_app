import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'admin_checkout_page.dart';

/// Standalone wrapper for AdminCheckoutPage when accessed via navigation
class AdminCheckoutStandalonePage extends StatelessWidget {
  const AdminCheckoutStandalonePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('New Sale'),
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        foregroundColor:
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        elevation: 0,
      ),
      body: const AdminCheckoutPage(),
    );
  }
}
