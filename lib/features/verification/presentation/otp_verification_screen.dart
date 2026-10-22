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
import '../../../shared/widgets/inputs/app_otp_field.dart';
import '../../../shared/widgets/layouts/auth_layout.dart';
import '../view_model/verification_bloc.dart';
import '../view_model/verification_event.dart';
import '../view_model/verification_state.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({
    super.key,
    this.email = 'contact@apexdental.com',
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpFieldKey = GlobalKey<AppOtpFieldState>();
  String _enteredCode = '';
  late String _activeEmail;

  @override
  void initState() {
    super.initState();
    _activeEmail = widget.email;
  }

  void _onVerify(String code) {
    if (code.length == 6) {
      context.read<VerificationBloc>().add(
            VerifyOtpSubmitted(email: _activeEmail, otp: code),
          );
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
                  'Enter the corrected email address where you would like to receive the 6-digit OTP code.',
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
                  _otpFieldKey.currentState?.clear();
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Update & Send Code'),
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
        if (state.errorMessage != null && _enteredCode.length == 6) {
          // If error occurs, allow clearing OTP easily
        }
      },
      builder: (context, state) {
        final displayEmail = _activeEmail.maskEmail;

        return AuthLayout(
          title: 'Enter Verification Code',
          subtitle: 'A 6-digit activation code was sent to $displayEmail.',
          footer: _buildFooter(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.errorMessage != null) ...[
                StatusCard(
                  title: 'Verification Failed',
                  message: state.errorMessage,
                  type: StatusType.error,
                  action: state.errorMessage!.toLowerCase().contains('expired') ||
                          state.errorMessage!.toLowerCase().contains('incorrect')
                      ? Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                _otpFieldKey.currentState?.clear();
                                setState(() => _enteredCode = '');
                              },
                              child: const Text('Clear Code'),
                            ),
                            if (state.canResend) ...[
                              const SizedBox(width: AppSpacing.sm),
                              TextButton(
                                onPressed: () {
                                  _otpFieldKey.currentState?.clear();
                                  context.read<VerificationBloc>().add(
                                        ResendVerificationOtpRequested(_activeEmail),
                                      );
                                },
                                child: const Text('Resend Code'),
                              ),
                            ],
                          ],
                        )
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              if (state.successMessage != null) ...[
                StatusCard(
                  title: 'Code Sent',
                  message: state.successMessage,
                  type: StatusType.success,
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              AppOtpField(
                key: _otpFieldKey,
                length: 6,
                enabled: !state.isLoading,
                onChanged: (val) => setState(() => _enteredCode = val),
                onCompleted: _onVerify,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Demo hints container
              Container(
                padding: AppSpacing.paddingSm,
                decoration: BoxDecoration(
                  color: AppColors.infoContainer,
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.info, size: 18),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DEMO TEST CODES:', style: AppTypography.labelSmall.copyWith(color: AppColors.info, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text('• 123456 — Valid code (verifies account)', style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                          Text('• 000000 — Expired code simulation', style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                          Text('• 888888 — Already used code', style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                          Text('• 777777 — Rate limited attempts', style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              PrimaryButton(
                text: 'Verify Account',
                isLoading: state.isLoading,
                icon: Icons.check_circle_outline_rounded,
                onPressed: _enteredCode.length == 6 ? () => _onVerify(_enteredCode) : null,
              ),
              const SizedBox(height: AppSpacing.md),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state.canResend)
                    TextButton.icon(
                      onPressed: state.isLoading
                          ? null
                          : () => context.read<VerificationBloc>().add(
                                ResendVerificationOtpRequested(_activeEmail),
                              ),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Resend Code'),
                    )
                  else
                    Text(
                      'Resend code in ${state.resendCooldownSeconds}s',
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
          onPressed: () => Navigator.of(context).pushReplacementNamed(
            RouteNames.emailVerification,
            arguments: _activeEmail,
          ),
          child: const Text('Verify with Email Link'),
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
