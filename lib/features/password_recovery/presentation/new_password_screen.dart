import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/validators/app_validators.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/cards/status_card.dart';
import '../../../shared/widgets/inputs/app_password_field.dart';
import '../../../shared/widgets/layouts/auth_layout.dart';
import '../view_model/password_recovery_bloc.dart';
import '../view_model/password_recovery_event.dart';
import '../view_model/password_recovery_state.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasDigit = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordStrength);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_updatePasswordStrength);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    final text = _passwordController.text;
    setState(() {
      _hasMinLength = text.length >= 8;
      _hasUppercase = text.contains(RegExp(r'[A-Z]'));
      _hasLowercase = text.contains(RegExp(r'[a-z]'));
      _hasDigit = text.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  void _onSetNewPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<PasswordRecoveryBloc>().add(
            NewPasswordSubmitted(_passwordController.text),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PasswordRecoveryBloc, PasswordRecoveryState>(
      listener: (context, state) {
        if (state.step == PasswordRecoveryStep.success) {
          Navigator.of(context).pushReplacementNamed(RouteNames.passwordResetSuccess);
        }
      },
      builder: (context, state) {
        return AuthLayout(
          title: 'Create New Password',
          subtitle: 'Ensure your new password meets clinical SaaS security compliance rules.',
          footer: _buildFooter(context),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.errorMessage != null) ...[
                  StatusCard(
                    title: 'Password Update Failed',
                    message: state.errorMessage,
                    type: StatusType.error,
                    action: state.errorMessage!.toLowerCase().contains('expired') ||
                            state.errorMessage!.toLowerCase().contains('session')
                        ? TextButton(
                            onPressed: () {
                              context.read<PasswordRecoveryBloc>().add(ResetFlowReset());
                              Navigator.of(context).pushReplacementNamed(RouteNames.forgotPassword);
                            },
                            child: const Text('Restart Password Reset'),
                          )
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                AppPasswordField(
                  controller: _passwordController,
                  label: 'New Password *',
                  hint: 'Min 8 chars, 1 uppercase, 1 number, 1 symbol',
                  enabled: !state.isLoading,
                ),
                const SizedBox(height: AppSpacing.md),
                AppPasswordField(
                  controller: _confirmPasswordController,
                  label: 'Confirm New Password *',
                  hint: 'Re-enter your new password',
                  enabled: !state.isLoading,
                  customValidator: (val) =>
                      AppValidators.confirmPassword(val, _passwordController.text),
                ),
                const SizedBox(height: AppSpacing.md),

                // Live password requirements checklist
                _buildRequirementsList(),
                const SizedBox(height: AppSpacing.lg),

                PrimaryButton(
                  text: 'Update Password & Continue',
                  isLoading: state.isLoading,
                  icon: Icons.check_circle_outline_rounded,
                  onPressed: _onSetNewPassword,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequirementsList() {
    return Container(
      padding: AppSpacing.paddingSm,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppSpacing.borderRadiusSm,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PASSWORD REQUIREMENTS:',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildCheckItem('At least 8 characters long', _hasMinLength),
          _buildCheckItem('At least 1 uppercase letter', _hasUppercase),
          _buildCheckItem('At least 1 lowercase letter', _hasLowercase),
          _buildCheckItem('At least 1 numerical digit', _hasDigit),
          _buildCheckItem('At least 1 special character (!@#\$%^&*)', _hasSpecialChar),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text, bool satisfied) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(
            satisfied ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 14,
            color: satisfied ? AppColors.success : AppColors.textTertiary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(
                fontSize: 11,
                color: satisfied ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: satisfied ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: () {
          context.read<PasswordRecoveryBloc>().add(ResetFlowReset());
          Navigator.of(context).pushReplacementNamed(RouteNames.login);
        },
        icon: const Icon(Icons.arrow_back_rounded, size: 16),
        label: Text(
          'Cancel & Return to Login',
          style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }
}
