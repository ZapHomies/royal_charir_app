import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_colors.dart';

/// View Mode enum
enum ViewMode { grid, list, compact }

/// Provider for view mode state per page
final productViewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.grid);
final customerViewModeProvider =
    StateProvider<ViewMode>((ref) => ViewMode.list);
final orderViewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.list);
final checkoutViewModeProvider =
    StateProvider<ViewMode>((ref) => ViewMode.grid);

/// Premium View Toggle Widget
class ViewModeToggle extends StatelessWidget {
  final ViewMode currentMode;
  final ValueChanged<ViewMode> onModeChanged;
  final List<ViewMode> availableModes;

  const ViewModeToggle({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
    this.availableModes = const [ViewMode.grid, ViewMode.list],
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: availableModes.map((mode) {
          final isSelected = currentMode == mode;
          return _buildModeButton(
            mode: mode,
            isSelected: isSelected,
            isDark: isDark,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildModeButton({
    required ViewMode mode,
    required bool isSelected,
    required bool isDark,
  }) {
    IconData icon;
    String tooltip;

    switch (mode) {
      case ViewMode.grid:
        icon = Icons.grid_view_rounded;
        tooltip = 'Grid View';
        break;
      case ViewMode.list:
        icon = Icons.list_rounded;
        tooltip = 'List View';
        break;
      case ViewMode.compact:
        icon = Icons.view_agenda_rounded;
        tooltip = 'Compact View';
        break;
    }

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onModeChanged(mode),
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isSelected
                  ? AppColors.primary
                  : (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
            ),
          ),
        ),
      ),
    );
  }
}
