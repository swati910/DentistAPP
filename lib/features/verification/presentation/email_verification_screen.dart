import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/extensions/string_extensions.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/cards/status_card.dart';
import '../../../shared/widgets/inputs/app_email_field.dart';
import '../../../shared/widgets/layouts/auth_layout.dart';
import '../view_model/verification_bloc.dart';
import '../view_model/verification_event.dart';
import '../view_model/verification_state.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final String? token;

  const EmailVerificationScreen({
    super.key,
    this.email = 'contact@apexdental.com',
    this.token,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  late String _activeEmail;

  @override
  void initState() {
    super.initState();
    _activeEmail = widget.email;

    if (widget.token != null && widget.token!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<VerificationBloc>().add(VerifyEmailTokenSubmitted(widget.token!));
      });
    }
  }

  void _showChangeEmailDialog() {
    final controller = TextEditingController(text: _activeEmail);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Change Verification Email'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter the corrected email address where you would like to receive the activation instructions.',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                AppEmailField(
                  controller: controller,
                  label: 'New Email Address',
                  hint: 'doctor@clinic.com',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final newEmail = controller.text.trim();
                  setState(() => _activeEmail = newEmail);
                  context.read<VerificationBloc>().add(
                        UpdateVerificationEmailRequested(
                          oldEmail: widget.email,
                          newEmail: newEmail,
                        ),
                      );
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Update & Resend'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VerificationBloc, VerificationState>(
      listener: (context, state) {
        if (state.email.isNotEmpty && state.email != _activeEmail) {
          setState(() => _activeEmail = state.email);
        }
        if (state.isVerified) {
          Navigator.of(context).pushReplacementNamed(RouteNames.subscriptionPlans);
        }
      },
      builder: (context, state) {
        final displayEmail = _activeEmail.maskEmail;

        return AuthLayout(
          title: 'Verify Your Email Address',
          subtitle: 'We sent an email verification link to $displayEmail.',
          footer: _buildFooter(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.errorMessage != null) ...[
                StatusCard(
                  title: 'Verification Incomplete',
                  message: state.errorMessage,
                  type: StatusType.error,
                  action: state.errorMessage!.toLowerCase().contains('expired')
                      ? TextButton(
                          onPressed: state.canResend
                              ? () => context
                                  .read<VerificationBloc>()
                                  .add(ResendVerificationEmailRequested(_activeEmail))
                              : null,
                          child: const Text('Request New Verification Link'),
                        )
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              if (state.successMessage != null) ...[
                StatusCard(
                  title: 'Success',
                  message: state.successMessage,
                  type: StatusType.success,
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              Container(
                padding: AppSpacing.paddingMd,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withAlpha(50),
                  borderRadius: AppSpacing.borderRadiusMd,
                  border: Border.all(color: AppColors.primary.withAlpha(50)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.mark_email_unread_outlined, color: AppColors.primary, size: 28),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Check your inbox & spam folder', style: AppTypography.titleMedium),
                          const SizedBox(height: 2),
                          Text(
                            'Click the activation link inside to verify your clinic account.',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              PrimaryButton(
                text: "I've Clicked the Verification Link",
                isLoading: state.isLoading,
                icon: Icons.check_circle_outline_rounded,
                onPressed: () =>
                    context.read<VerificationBloc>().add(CheckEmailVerificationStatus(_activeEmail)),
              ),
              const SizedBox(height: AppSpacing.md),

              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pushNamed(
                  RouteNames.otpVerification,
                  arguments: _activeEmail,
                ),
                icon: const Icon(Icons.pin_outlined, size: 18),
                label: const Flexible(
                  child: Text(
                    'Verify using 6-Digit OTP instead',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state.canResend)
                    TextButton.icon(
                      onPressed: state.isLoading
                          ? null
                          : () => context
                              .read<VerificationBloc>()
                              .add(ResendVerificationEmailRequested(_activeEmail)),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Resend Email'),
                    )
                  else
                    Text(
                      'Resend link in ${state.resendCooldownSeconds}s',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const Text('  •  '),
                  TextButton.icon(
                    onPressed: state.isLoading ? null : _showChangeEmailDialog,
                    icon: const Icon(Icons.edit_outlined, size: 14),
                    label: const Text('Change Email'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.xs,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pushReplacementNamed(RouteNames.clinicOnboarding),
          child: const Text('Edit Clinic Registration'),
        ),
        const Text('•'),
        TextButton(
          onPressed: () => Navigator.of(context).pushReplacementNamed(RouteNames.login),
          child: const Text('Back to Login'),
        ),
      ],
    );
  }
}
