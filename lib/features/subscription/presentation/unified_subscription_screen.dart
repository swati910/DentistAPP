import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_icons.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../shared/models/subscription_model.dart';
import '../../../shared/widgets/cards/status_card.dart';
import '../../../shared/widgets/cards/subscription_plan_card.dart';
import '../../../shared/widgets/cards/subscription_status_card.dart';
import '../../../shared/widgets/dialogs/confirmation_dialog.dart';
import '../../../shared/widgets/feedback/app_loading.dart';
import '../../../shared/widgets/layouts/responsive_scaffold.dart';
import '../view_model/subscription_bloc.dart';
import '../view_model/subscription_event.dart';
import '../view_model/subscription_state.dart';

class UnifiedSubscriptionScreen extends StatefulWidget {
  const UnifiedSubscriptionScreen({super.key});

  @override
  State<UnifiedSubscriptionScreen> createState() => _UnifiedSubscriptionScreenState();
}

class _UnifiedSubscriptionScreenState extends State<UnifiedSubscriptionScreen> {
  final _availablePlansKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Load both current subscription and available tiers in unified flow
    context.read<SubscriptionBloc>().add(LoadCurrentSubscriptionRequested());
    context.read<SubscriptionBloc>().add(LoadSubscriptionPlansRequested());
  }

  void _scrollToAvailablePlans() {
    Scrollable.ensureVisible(
      _availablePlansKey.currentContext ?? context,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _onProceedToCheckout(SubscriptionPlan plan, CurrentSubscription? currentSub) {
    if (currentSub != null && currentSub.plan.id == plan.id && currentSub.isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You are already subscribed to the ${plan.name} plan.'),
          backgroundColor: AppColors.info,
        ),
      );
      return;
    }

    Navigator.of(context).pushNamed(
      RouteNames.subscriptionCheckout,
      arguments: plan,
    );
  }

  void _onCancelSubscription(CurrentSubscription sub) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Cancel Subscription?',
      message:
          'Are you sure you want to cancel the ${sub.plan.name} subscription? You will retain access until ${sub.renewalDate.day}/${sub.renewalDate.month}/${sub.renewalDate.year}, after which AI scanning will be disabled.',
      confirmText: 'Yes, Cancel Plan',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      context.read<SubscriptionBloc>().add(CancelSubscriptionRequested(sub.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return ResponsiveScaffold(
      title: 'Subscription & Plans',
      currentRoute: RouteNames.subscriptionPlans,
      maxWidth: 1200,
      actions: [
        IconButton(
          icon: const Icon(AppIcons.refresh),
          tooltip: 'Refresh Plans',
          onPressed: () {
            context.read<SubscriptionBloc>().add(LoadCurrentSubscriptionRequested());
            context.read<SubscriptionBloc>().add(LoadSubscriptionPlansRequested());
          },
        ),
      ],
      body: BlocConsumer<SubscriptionBloc, SubscriptionState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.availablePlans.isEmpty && state.currentSubscription == null) {
            return const AppLoading(message: 'Loading subscription details & available plans...');
          }

          final currentSub = state.currentSubscription ??
              CurrentSubscription(
                id: 'sub-demo-01',
                plan: const SubscriptionPlan(
                  id: 'plan-pro',
                  name: 'Professional Clinic',
                  monthlyPrice: 3999,
                  currency: '₹',
                  billingPeriod: 'month',
                  features: [
                    'Up to 5 Dentists',
                    '15 Staff Logins',
                    'Unlimited AI Scans & Diagnostics',
                    'Advanced Periodontal Charting',
                    'Priority 24/7 Support',
                  ],
                  limits: {'Dentists': '5', 'Staff Seats': '15'},
                ),
                status: SubscriptionStatus.active,
                startDate: DateTime.now().subtract(const Duration(days: 15)),
                renewalDate: DateTime.now().add(const Duration(days: 15)),
              );
          final plans = state.availablePlans;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.errorMessage != null) ...[
                StatusCard(
                  title: 'Subscription Notice',
                  message: state.errorMessage,
                  type: StatusType.warning,
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // ==========================================
              // SECTION A: Current Plan Overview
              // ==========================================
              Row(
                children: [
                  const Icon(AppIcons.subscription, color: AppColors.primary, size: 22),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'Current Plan & Billing Status',
                      style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Review your active dental subscription, renewal terms, and operational limits.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.md),

              SubscriptionStatusCard(
                subscription: currentSub,
                onUpgrade: _scrollToAvailablePlans,
                onDowngrade: _scrollToAvailablePlans,
                onCancel: () => _onCancelSubscription(currentSub),
                onRetryPayment: () => Navigator.of(context).pushNamed(
                  RouteNames.subscriptionCheckout,
                  arguments: currentSub.plan,
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),
              const Divider(color: AppColors.border),
              const SizedBox(height: AppSpacing.lg),

              // ==========================================
              // SECTION B: Available Plans / Subscribe Section
              // ==========================================
              Container(
                key: _availablePlansKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        'Available Practice Plans',
                        textAlign: TextAlign.center,
                        style: AppTypography.displayLarge.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Center(
                      child: Text(
                        'Compare plan tiers or upgrade to higher AI diagnostic capacities. Current plan is marked below.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    if (plans.isEmpty && !state.isLoading) ...[
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.xl),
                          child: Text('No plans currently available. Please refresh or contact support.'),
                        ),
                      ),
                    ] else if (isDesktop) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: plans.map((plan) {
                          final isSelected = state.selectedPlan?.id == plan.id;
                          final isCurrent = currentSub.plan.id == plan.id && currentSub.isActive;

                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                              child: SubscriptionPlanCard(
                                plan: plan,
                                isSelected: isSelected,
                                isCurrentPlan: isCurrent,
                                onSelect: () => context.read<SubscriptionBloc>().add(SelectSubscriptionPlan(plan)),
                                onCheckout: () => _onProceedToCheckout(plan, currentSub),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ] else ...[
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: plans.length,
                        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
                        itemBuilder: (context, index) {
                          final plan = plans[index];
                          final isSelected = state.selectedPlan?.id == plan.id;
                          final isCurrent = currentSub.plan.id == plan.id && currentSub.isActive;

                          return SubscriptionPlanCard(
                            plan: plan,
                            isSelected: isSelected,
                            isCurrentPlan: isCurrent,
                            onSelect: () => context.read<SubscriptionBloc>().add(SelectSubscriptionPlan(plan)),
                            onCheckout: () => _onProceedToCheckout(plan, currentSub),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          );
        },
      ),
    );
  }
}
