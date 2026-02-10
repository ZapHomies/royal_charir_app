import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/providers/theme_provider.dart';

import '../../../inventory/presentation/pages/product_list_page.dart';
import '../../../inventory/presentation/pages/product_form_page.dart';
import '../../../inventory/providers/product_provider.dart';
import '../../../customers/presentation/pages/customer_list_page.dart';
import '../../../customers/presentation/pages/customer_form_page.dart';
import '../../../customers/providers/customer_provider.dart';
import '../../../orders/presentation/pages/order_list_page.dart';
import '../../../orders/presentation/pages/order_form_page.dart';
import '../../../orders/providers/order_provider.dart';
import '../../../reports/presentation/pages/reports_page.dart';
import '../../../sync/presentation/pages/sync_settings_page.dart';
import '../../../materials/presentation/pages/material_management_page.dart';
import '../../../users/presentation/pages/user_management_page.dart';
import '../../../checkout/presentation/pages/admin_checkout_page.dart';
import '../../../finance/presentation/pages/finance_page.dart';
import '../../../employees/presentation/pages/employee_management_page.dart';
import '../widgets/dashboard_home_content.dart';
import '../../../onboarding/feature_tutorial.dart';
import '../../../onboarding/feature_tutorials_data.dart';

// Global search query provider
final globalSearchQueryProvider = StateProvider<String>((ref) => '');

/// Simplified Dashboard with reliable navigation
class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _selectedIndex = 0;
  bool _isSidebarCollapsed = false;
  final _searchController = TextEditingController();

  final List<_NavItem> _navItems = [
    _NavItem(Icons.dashboard_rounded, 'Beranda', AppColors.primary),
    _NavItem(Icons.point_of_sale_rounded, 'Kasir', AppColors.success),
    _NavItem(Icons.inventory_2_rounded, 'Produk', AppColors.info),
    _NavItem(Icons.people_rounded, 'Pelanggan', AppColors.accent),
    _NavItem(Icons.receipt_long_rounded, 'Pesanan', AppColors.warning),
    _NavItem(Icons.bar_chart_rounded, 'Laporan', AppColors.error),
  ];

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const DashboardHomeContent(),
      const AdminCheckoutPage(),
      const ProductListPage(),
      const CustomerListPage(),
      const OrderListPage(),
      const ReportsPage(),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Menampilkan tutorial berdasarkan halaman yang sedang aktif
  void _showCurrentPageTutorial() {
    List<TutorialStep> steps;
    String title;

    switch (_selectedIndex) {
      case 0: // Dashboard
        steps = FeatureTutorials.dashboardTutorial;
        title = 'Tutorial Dashboard';
        break;
      case 1: // Kasir
        steps = FeatureTutorials.cashierTutorial;
        title = 'Tutorial Kasir';
        break;
      case 2: // Produk
        steps = FeatureTutorials.productTutorial;
        title = 'Tutorial Produk';
        break;
      case 3: // Pelanggan
        steps = FeatureTutorials.customerTutorial;
        title = 'Tutorial Pelanggan';
        break;
      case 4: // Pesanan
        steps = FeatureTutorials.orderTutorial;
        title = 'Tutorial Pesanan';
        break;
      case 5: // Laporan
        steps = FeatureTutorials.reportTutorial;
        title = 'Tutorial Laporan';
        break;
      default:
        steps = FeatureTutorials.dashboardTutorial;
        title = 'Tutorial';
    }

    showFeatureTutorial(
      context,
      title: title,
      featureKey: 'menu_$_selectedIndex',
      steps: steps,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Row(
        children: [
          // Side Navigation (for wide screens)
          if (isWide) _buildSideNav(isDark),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top App Bar
                _buildAppBar(isDark, isWide),

                // Page Content
                Expanded(
                  child: _pages[_selectedIndex],
                ),
              ],
            ),
          ),
        ],
      ),

      // Bottom Navigation (for narrow screens)
      bottomNavigationBar: isWide ? null : _buildBottomNav(isDark),
    );
  }

  Widget _buildSideNav(bool isDark) {
    final sidebarWidth = _isSidebarCollapsed ? 72.0 : 240.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: sidebarWidth,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          right: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo Header
          Container(
            padding: EdgeInsets.all(_isSidebarCollapsed ? 12 : 24),
            child: Row(
              mainAxisAlignment: _isSidebarCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: _isSidebarCollapsed ? 40 : 48,
                    height: _isSidebarCollapsed ? 40 : 48,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.storefront_rounded,
                          color: Colors.white),
                    ),
                  ),
                ),
                if (!_isSidebarCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Royal Charir',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Sistem Manajemen',
                          style: AppTextStyles.caption.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 1),

          // Navigation Items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                  vertical: 12, horizontal: _isSidebarCollapsed ? 8 : 12),
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = _selectedIndex == index;

                return Tooltip(
                  message: _isSidebarCollapsed ? item.label : '',
                  preferBelow: false,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    child: Material(
                      color: isSelected
                          ? item.color.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => setState(() => _selectedIndex = index),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: _isSidebarCollapsed ? 12 : 16,
                              vertical: 12),
                          child: Row(
                            mainAxisAlignment: _isSidebarCollapsed
                                ? MainAxisAlignment.center
                                : MainAxisAlignment.start,
                            children: [
                              Icon(
                                item.icon,
                                color: isSelected
                                    ? item.color
                                    : (isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight),
                                size: 22,
                              ),
                              if (!_isSidebarCollapsed) ...[
                                const SizedBox(width: 12),
                                Text(
                                  item.label,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: isSelected
                                        ? item.color
                                        : (isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimaryLight),
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

          // Quick Actions - Always visible
          Padding(
            padding: EdgeInsets.all(_isSidebarCollapsed ? 8 : 12),
            child: Column(
              children: [
                _buildQuickNavButton(
                    'Karyawan',
                    Icons.badge_rounded,
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const EmployeeManagementPage())),
                    isDark),
                SizedBox(height: _isSidebarCollapsed ? 4 : 8),
                _buildQuickNavButton(
                    'Keuangan',
                    Icons.account_balance_wallet_rounded,
                    () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const FinancePage())),
                    isDark),
                SizedBox(height: _isSidebarCollapsed ? 4 : 8),
                _buildQuickNavButton(
                    'Kelola Bahan',
                    Icons.layers_rounded,
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MaterialManagementPage())),
                    isDark),
                if (!_isSidebarCollapsed) ...[
                  const SizedBox(height: 8),
                  _buildQuickNavButton(
                      'Pengguna',
                      Icons.people_alt_rounded,
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const UserManagementPage())),
                      isDark),
                  const SizedBox(height: 8),
                  _buildQuickNavButton(
                      'Sinkronisasi',
                      Icons.sync_rounded,
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SyncSettingsPage())),
                      isDark),
                ],
              ],
            ),
          ),

          // Toggle Button
          Container(
            padding: const EdgeInsets.all(12),
            child: Material(
              color: isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariantLight,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () =>
                    setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isSidebarCollapsed
                            ? Icons.keyboard_double_arrow_right_rounded
                            : Icons.keyboard_double_arrow_left_rounded,
                        size: 20,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                      if (!_isSidebarCollapsed) ...[
                        const SizedBox(width: 8),
                        Text(
                          'Sembunyikan',
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickNavButton(
      String label, IconData icon, VoidCallback onTap, bool isDark) {
    return Tooltip(
      message: _isSidebarCollapsed ? label : '',
      preferBelow: false,
      child: Material(
        color: isDark
            ? AppColors.surfaceVariantDark
            : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: _isSidebarCollapsed ? 0 : 12,
                vertical: _isSidebarCollapsed ? 10 : 10),
            child: _isSidebarCollapsed
                ? Center(
                    child: Icon(icon,
                        size: 20,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight),
                  )
                : Row(
                    children: [
                      Icon(icon,
                          size: 18,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                      const SizedBox(width: 10),
                      Text(
                        label,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isDark, bool isWide) {
    return Container(
      padding: EdgeInsets.fromLTRB(isWide ? 24 : 16, 12, 16, 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: Row(
        children: [
          if (!isWide) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.storefront_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
          ],

          // Current Page Title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _navItems[_selectedIndex].label,
                style: AppTextStyles.titleMedium.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                _getSubtitle(),
                style: AppTextStyles.caption.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Add Button (for Products, Customers, Orders)
          if ([2, 3, 4].contains(_selectedIndex))
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _handleAdd(),
                  borderRadius: BorderRadius.circular(10),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child:
                        Icon(Icons.add_rounded, color: Colors.white, size: 22),
                  ),
                ),
              ),
            ),

          const SizedBox(width: 8),

          // Tutorial Button
          TutorialButton(
            onPressed: () => _showCurrentPageTutorial(),
            tooltip: 'Tutorial ${_navItems[_selectedIndex].label}',
          ),

          const SizedBox(width: 8),

          // Dark Mode Toggle
          _buildThemeToggleButton(isDark),

          const SizedBox(width: 4),

          // Refresh Button
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            onPressed: () {
              ref.invalidate(productsProvider);
              ref.invalidate(customersProvider);
              ref.invalidate(ordersProvider);
            },
            tooltip: 'Refresh Data',
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggleButton(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceVariantDark
            : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            ref.read(themeProvider.notifier).toggleTheme();
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return RotationTransition(
                  turns: Tween(begin: 0.75, end: 1.0).animate(animation),
                  child: ScaleTransition(scale: animation, child: child),
                );
              },
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                key: ValueKey(isDark),
                size: 20,
                color: isDark
                    ? AppColors.warningLight
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getSubtitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Welcome back!';
      case 1:
        return 'Create new order';
      case 2:
        return 'Manage inventory';
      case 3:
        return 'Customer database';
      case 4:
        return 'Riwayat Pesanan';
      case 5:
        return 'Sales & stock reports';
      default:
        return '';
    }
  }

  void _handleAdd() {
    switch (_selectedIndex) {
      case 2:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ProductFormPage()));
        break;
      case 3:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CustomerFormPage()));
        break;
      case 4:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const OrderFormPage()));
        break;
    }
  }

  Widget _buildBottomNav(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final isSelected = _selectedIndex == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedIndex = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? item.color.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          color: isSelected
                              ? item.color
                              : (isDark
                                  ? AppColors.textTertiaryDark
                                  : AppColors.textTertiaryLight),
                          size: 22,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isSelected
                                ? item.color
                                : (isDark
                                    ? AppColors.textTertiaryDark
                                    : AppColors.textTertiaryLight),
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final Color color;

  _NavItem(this.icon, this.label, this.color);
}
