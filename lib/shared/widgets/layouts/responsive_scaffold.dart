import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_icons.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../app/router/route_names.dart';

class ResponsiveScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? leading;
  final VoidCallback? onBack;
  final Widget? floatingActionButton;
  final bool showAppBar;
  final bool showDrawer;
  final Widget? bottomNavigationBar;
  final double maxWidth;
  final String? currentRoute;

  const ResponsiveScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.leading,
    this.onBack,
    this.floatingActionButton,
    this.showAppBar = true,
    this.showDrawer = true,
    this.bottomNavigationBar,
    this.maxWidth = 1200,
    this.currentRoute,
  });

  Widget? _resolveLeading(BuildContext context) {
    if (leading != null) return leading;
    if (!showDrawer) {
      return IconButton(
        icon: const Icon(AppIcons.back),
        tooltip: 'Back',
        onPressed: onBack ??
            () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pushReplacementNamed(RouteNames.patients);
              }
            },
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveUtils.isDesktop(context);

    if (isDesktop && showDrawer) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            _buildDesktopSidebar(context),
            const VerticalDivider(width: 1, color: AppColors.border),
            Expanded(
              child: Scaffold(
                backgroundColor: AppColors.background,
                appBar: showAppBar
                    ? AppBar(
                        title: Text(
                          title,
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        leading: _resolveLeading(context),
                        actions: actions != null
                            ? [
                                ...actions!,
                                const SizedBox(width: AppSpacing.md),
                              ]
                            : null,
                        bottom: const PreferredSize(
                          preferredSize: Size.fromHeight(1),
                          child: Divider(height: 1, color: AppColors.border),
                        ),
                      )
                    : null,
                body: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: AppSpacing.desktopScreenPadding,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: body,
                      ),
                    ),
                  ),
                ),
                floatingActionButton: floatingActionButton,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: showAppBar
          ? AppBar(
              title: Text(
                title,
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              leading: _resolveLeading(context),
              actions: actions,
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Divider(height: 1, color: AppColors.border),
              ),
            )
          : null,
      drawer: showDrawer ? _buildMobileDrawer(context) : null,
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.screenPadding,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: body,
            ),
          ),
        ),
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  Widget _buildDesktopSidebar(BuildContext context) {
    return Container(
      width: 260,
      color: AppColors.surface,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppSpacing.borderRadiusSm,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    AppIcons.medical,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Row(
                      children: [
                        Text(
                          'DentFlow',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'AI',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Clinical SaaS Portal',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.md,
                horizontal: AppSpacing.sm,
              ),
              children: _buildNavItems(context),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          // Sidebar footer with active status badge
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Cloud Sync Active',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const Icon(
                  AppIcons.shield,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  child: const Icon(
                    AppIcons.medical,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DentFlow AI',
                        style: AppTypography.headlineMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Clinical Management',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm,
                horizontal: AppSpacing.sm,
              ),
              children: _buildNavItems(context, isDrawer: true),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNavItems(BuildContext context, {bool isDrawer = false}) {
    final navItems = [
      {
        'route': RouteNames.patients,
        'label': 'Patients Directory',
        'icon': AppIcons.patients,
      },
      {
        'route': RouteNames.onboardingStatus,
        'label': 'Onboarding Status',
        'icon': AppIcons.onboardingStatus,
      },
      {
        'route': RouteNames.subscriptionPlans,
        'label': 'Subscription & Plans',
        'icon': AppIcons.subscription,
      },
      {
        'route': RouteNames.profile,
        'label': 'Profile & Settings',
        'icon': AppIcons.profile,
      },
      {
        'route': RouteNames.users,
        'label': 'Team & Staff',
        'icon': AppIcons.team,
      },
      {
        'route': RouteNames.login,
        'label': 'Logout',
        'icon': AppIcons.logout,
      },
    ];

    return navItems.map((item) {
      final route = item['route'] as String;
      final label = item['label'] as String;
      final icon = item['icon'] as IconData;
      final isSelected = currentRoute == route ||
          (route == RouteNames.subscriptionPlans &&
              (currentRoute == RouteNames.subscriptionStatus ||
                  currentRoute == RouteNames.subscriptionPlans)) ||
          (route == RouteNames.profile &&
              (currentRoute == RouteNames.profile ||
                  currentRoute == RouteNames.clinicSettings));
      final isLogout = route == RouteNames.login;

      return Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : Colors.transparent,
          borderRadius: AppSpacing.borderRadiusSm,
          border: isSelected
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1)
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            leading: Icon(
              icon,
              color: isSelected
                  ? AppColors.primary
                  : (isLogout ? AppColors.error : AppColors.textSecondary),
              size: 20,
            ),
            title: Text(
              label,
              style: AppTypography.labelLarge.copyWith(
                color: isSelected
                    ? AppColors.primary
                    : (isLogout ? AppColors.error : AppColors.textPrimary),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
            dense: true,
            shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusSm),
            onTap: () {
              if (isDrawer) Navigator.of(context).pop();
              if (route == RouteNames.login) {
                Navigator.of(context).pushNamedAndRemoveUntil(route, (r) => false);
              } else if (!isSelected) {
                Navigator.of(context).pushReplacementNamed(route);
              }
            },
          ),
        ),
      );
    }).toList();
  }
}
