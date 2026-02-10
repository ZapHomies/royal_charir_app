import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/routes.dart';
import 'core/providers/theme_provider.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/onboarding/providers/onboarding_provider.dart';

/// Main App Widget with Onboarding Support
class RoyalCharirApp extends ConsumerWidget {
  const RoyalCharirApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme provider for dark/light mode
    final themeMode = ref.watch(themeProvider);

    // Watch onboarding completion status
    final isOnboardingComplete = ref.watch(onboardingCompleteProvider);

    return MaterialApp.router(
      title: 'Royal Charir - Sistem Manajemen Gudang',
      debugShowCheckedModeBanner: false,

      // Theme Configuration with Dark Mode Support
      theme: AppTheme.lightMaterialTheme,
      darkTheme: AppTheme.darkMaterialTheme,
      themeMode: themeMode,

      // Router Configuration - changes based on onboarding status
      routerConfig: _buildRouter(isOnboardingComplete),
    );
  }
}

/// Build router based on onboarding status
GoRouter _buildRouter(bool isOnboardingComplete) {
  return GoRouter(
    initialLocation: isOnboardingComplete ? Routes.dashboard : '/onboarding',
    routes: [
      // Onboarding
      GoRoute(
        path: '/onboarding',
        name: 'Onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),

      // Dashboard
      GoRoute(
        path: Routes.dashboard,
        name: 'Beranda',
        builder: (context, state) => const DashboardPage(),
      ),
    ],

    // Redirect logic
    redirect: (context, state) {
      final isGoingToOnboarding = state.matchedLocation == '/onboarding';

      // If onboarding is complete and trying to go to onboarding, redirect to dashboard
      if (isOnboardingComplete && isGoingToOnboarding) {
        return Routes.dashboard;
      }

      // If onboarding not complete and not going to onboarding, redirect to onboarding
      if (!isOnboardingComplete && !isGoingToOnboarding) {
        return '/onboarding';
      }

      return null;
    },

    // Error Handler
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(Routes.dashboard),
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
}
