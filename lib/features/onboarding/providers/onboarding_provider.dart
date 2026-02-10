import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keys untuk menyimpan status tutorial
class TutorialKeys {
  static const String onboardingComplete = 'onboarding_complete';
  static const String dashboardTourComplete = 'dashboard_tour_complete';
  static const String productTourComplete = 'product_tour_complete';
  static const String cashierTourComplete = 'cashier_tour_complete';
  static const String customerTourComplete = 'customer_tour_complete';
  static const String orderTourComplete = 'order_tour_complete';
  static const String reportTourComplete = 'report_tour_complete';
  static const String materialTourComplete = 'material_tour_complete';
  static const String syncTourComplete = 'sync_tour_complete';
}

/// Provider untuk SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

/// Provider untuk mengecek apakah onboarding sudah selesai
final onboardingCompleteProvider =
    StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OnboardingNotifier(prefs);
});

/// Provider untuk tracking tour per fitur
final featureTourProvider =
    StateNotifierProvider<FeatureTourNotifier, Map<String, bool>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return FeatureTourNotifier(prefs);
});

/// Provider untuk step tour saat ini
final currentTourStepProvider = StateProvider<int>((ref) => 0);

/// Provider untuk menampilkan tour overlay
final showTourOverlayProvider = StateProvider<bool>((ref) => false);

/// Notifier untuk mengelola status onboarding
class OnboardingNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;

  OnboardingNotifier(this._prefs)
      : super(_prefs.getBool(TutorialKeys.onboardingComplete) ?? false);

  Future<void> completeOnboarding() async {
    await _prefs.setBool(TutorialKeys.onboardingComplete, true);
    state = true;
  }

  Future<void> resetOnboarding() async {
    await _prefs.setBool(TutorialKeys.onboardingComplete, false);
    state = false;
  }
}

/// Notifier untuk tracking tour per fitur
class FeatureTourNotifier extends StateNotifier<Map<String, bool>> {
  final SharedPreferences _prefs;

  FeatureTourNotifier(this._prefs) : super(_loadTourStatus(_prefs));

  static Map<String, bool> _loadTourStatus(SharedPreferences prefs) {
    return {
      TutorialKeys.dashboardTourComplete:
          prefs.getBool(TutorialKeys.dashboardTourComplete) ?? false,
      TutorialKeys.productTourComplete:
          prefs.getBool(TutorialKeys.productTourComplete) ?? false,
      TutorialKeys.cashierTourComplete:
          prefs.getBool(TutorialKeys.cashierTourComplete) ?? false,
      TutorialKeys.customerTourComplete:
          prefs.getBool(TutorialKeys.customerTourComplete) ?? false,
      TutorialKeys.orderTourComplete:
          prefs.getBool(TutorialKeys.orderTourComplete) ?? false,
      TutorialKeys.reportTourComplete:
          prefs.getBool(TutorialKeys.reportTourComplete) ?? false,
      TutorialKeys.materialTourComplete:
          prefs.getBool(TutorialKeys.materialTourComplete) ?? false,
      TutorialKeys.syncTourComplete:
          prefs.getBool(TutorialKeys.syncTourComplete) ?? false,
    };
  }

  /// Cek apakah tour sudah selesai
  bool isTourComplete(String key) => state[key] ?? false;

  /// Tandai tour sebagai selesai
  Future<void> completeTour(String key) async {
    await _prefs.setBool(key, true);
    state = {...state, key: true};
  }

  /// Reset semua tour
  Future<void> resetAllTours() async {
    for (final key in state.keys) {
      await _prefs.setBool(key, false);
    }
    state = state.map((key, value) => MapEntry(key, false));
  }

  /// Reset tour tertentu
  Future<void> resetTour(String key) async {
    await _prefs.setBool(key, false);
    state = {...state, key: false};
  }
}

/// Model untuk langkah tour
class TourStep {
  final String title;
  final String description;
  final GlobalKey? targetKey;
  final Alignment tooltipAlignment;
  final IconData icon;
  final Color color;

  const TourStep({
    required this.title,
    required this.description,
    this.targetKey,
    this.tooltipAlignment = Alignment.bottomCenter,
    this.icon = Icons.info_rounded,
    this.color = const Color(0xFF6366F1),
  });
}
