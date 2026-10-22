import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_icons.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/validators/app_validators.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/cards/app_card.dart';
import '../../../shared/widgets/cards/status_card.dart';
import '../../../shared/widgets/inputs/app_dropdown.dart';
import '../../../shared/widgets/inputs/app_email_field.dart';
import '../../../shared/widgets/inputs/app_password_field.dart';
import '../../../shared/widgets/inputs/app_phone_field.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../domain/onboarding_form_data.dart';
import '../view_model/clinic_onboarding_bloc.dart';
import '../view_model/clinic_onboarding_event.dart';
import '../view_model/clinic_onboarding_state.dart';

class ClinicOnboardingScreen extends StatefulWidget {
  const ClinicOnboardingScreen({super.key});

  @override
  State<ClinicOnboardingScreen> createState() => _ClinicOnboardingScreenState();
}

class _ClinicOnboardingScreenState extends State<ClinicOnboardingScreen> {
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();
  final _step3FormKey = GlobalKey<FormState>();

  // Controllers for Step 1: Clinic Details
  late final TextEditingController _clinicNameController;
  late final TextEditingController _clinicEmailController;
  late final TextEditingController _clinicPhoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _countryController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _websiteController;
  String _selectedClinicType = 'Multi-Speciality Practice';

  // Controllers for Step 2: Administrator Details
  late final TextEditingController _adminFirstNameController;
  late final TextEditingController _adminLastNameController;
  late final TextEditingController _adminEmailController;
  late final TextEditingController _adminPhoneController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  String _selectedAdminRole = 'Clinic Director / Owner';

  // Controllers for Step 3: Contact Details
  late final TextEditingController _primaryContactNameController;
  late final TextEditingController _primaryPhoneController;
  late final TextEditingController _primaryEmailController;
  late final TextEditingController _alternatePhoneController;
  bool _useAdminAsPrimaryContact = false;
  String _selectedPreferredContactMethod = 'Email';

  // Step 4: Terms Acceptance
  bool _termsAccepted = true;

  @override
  void initState() {
    super.initState();
    final data = context.read<ClinicOnboardingBloc>().state.formData;

    _clinicNameController = TextEditingController(
      text: data.clinicName.isNotEmpty ? data.clinicName : 'Apex Dental Center',
    );
    _clinicEmailController = TextEditingController(
      text: data.clinicEmail.isNotEmpty ? data.clinicEmail : 'contact@apexdental.com',
    );
    _clinicPhoneController = TextEditingController(
      text: data.clinicPhone.isNotEmpty ? data.clinicPhone : '+91 80 4123 4567',
    );
    _addressController = TextEditingController(
      text: data.address.isNotEmpty ? data.address : '42 Medical Enclave, MG Road',
    );
    _cityController = TextEditingController(
      text: data.city.isNotEmpty ? data.city : 'Bengaluru',
    );
    _stateController = TextEditingController(
      text: data.state.isNotEmpty ? data.state : 'Karnataka',
    );
    _countryController = TextEditingController(
      text: data.country.isNotEmpty ? data.country : 'India',
    );
    _postalCodeController = TextEditingController(
      text: data.postalCode.isNotEmpty ? data.postalCode : '560001',
    );
    _websiteController = TextEditingController(
      text: data.website.isNotEmpty ? data.website : 'https://apexdental.com',
    );
    _selectedClinicType = data.clinicType;

    _adminFirstNameController = TextEditingController(
      text: data.adminFirstName.isNotEmpty ? data.adminFirstName : 'Elena',
    );
    _adminLastNameController = TextEditingController(
      text: data.adminLastName.isNotEmpty ? data.adminLastName : 'Rostova',
    );
    _adminEmailController = TextEditingController(
      text: data.adminEmail.isNotEmpty ? data.adminEmail : 'elena.rostova@apexdental.com',
    );
    _adminPhoneController = TextEditingController(
      text: data.adminPhone.isNotEmpty ? data.adminPhone : '+91 98765 43210',
    );
    _passwordController = TextEditingController(
      text: data.password.isNotEmpty ? data.password : 'Password123!',
    );
    _confirmPasswordController = TextEditingController(
      text: data.confirmPassword.isNotEmpty ? data.confirmPassword : 'Password123!',
    );
    _selectedAdminRole = data.adminRole;

    _useAdminAsPrimaryContact = data.useAdminAsPrimaryContact;
    _primaryContactNameController = TextEditingController(
      text: data.primaryContactName.isNotEmpty ? data.primaryContactName : 'Dr. Elena Rostova',
    );
    _primaryPhoneController = TextEditingController(
      text: data.primaryPhone.isNotEmpty ? data.primaryPhone : '+91 98765 43210',
    );
    _primaryEmailController = TextEditingController(
      text: data.primaryEmail.isNotEmpty ? data.primaryEmail : 'contact@apexdental.com',
    );
    _alternatePhoneController = TextEditingController(
      text: data.alternatePhone.isNotEmpty ? data.alternatePhone : '+91 80 2345 6789',
    );
    _selectedPreferredContactMethod = data.preferredContactMethod;
    _termsAccepted = data.termsAccepted;
  }

  @override
  void dispose() {
    _clinicNameController.dispose();
    _clinicEmailController.dispose();
    _clinicPhoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    _websiteController.dispose();

    _adminFirstNameController.dispose();
    _adminLastNameController.dispose();
    _adminEmailController.dispose();
    _adminPhoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _primaryContactNameController.dispose();
    _primaryPhoneController.dispose();
    _primaryEmailController.dispose();
    _alternatePhoneController.dispose();
    super.dispose();
  }

  void _saveCurrentStepToState() {
    final updatedData = OnboardingFormData(
      clinicName: _clinicNameController.text.trim(),
      clinicType: _selectedClinicType,
      clinicEmail: _clinicEmailController.text.trim(),
      clinicPhone: _clinicPhoneController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      country: _countryController.text.trim(),
      postalCode: _postalCodeController.text.trim(),
      website: _websiteController.text.trim(),
      adminFirstName: _adminFirstNameController.text.trim(),
      adminLastName: _adminLastNameController.text.trim(),
      adminEmail: _adminEmailController.text.trim(),
      adminPhone: _adminPhoneController.text.trim(),
      adminRole: _selectedAdminRole,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      useAdminAsPrimaryContact: _useAdminAsPrimaryContact,
      primaryContactName: _primaryContactNameController.text.trim(),
      primaryPhone: _primaryPhoneController.text.trim(),
      primaryEmail: _primaryEmailController.text.trim(),
      alternatePhone: _alternatePhoneController.text.trim(),
      preferredContactMethod: _selectedPreferredContactMethod,
      termsAccepted: _termsAccepted,
    );
    context.read<ClinicOnboardingBloc>().add(FormDataUpdated(updatedData));
  }

  void _onNextStep(int currentStep) {
    if (currentStep == 0) {
      if (!(_step1FormKey.currentState?.validate() ?? false)) return;
      _saveCurrentStepToState();
      context.read<ClinicOnboardingBloc>().add(const StepChanged(1));
    } else if (currentStep == 1) {
      if (!(_step2FormKey.currentState?.validate() ?? false)) return;
      _saveCurrentStepToState();
      context.read<ClinicOnboardingBloc>().add(const StepChanged(2));
    } else if (currentStep == 2) {
      if (!(_step3FormKey.currentState?.validate() ?? false)) return;
      _saveCurrentStepToState();
      context.read<ClinicOnboardingBloc>().add(const StepChanged(3));
    } else if (currentStep == 3) {
      if (!_termsAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please accept the Terms of Service to continue.')),
        );
        return;
      }
      _saveCurrentStepToState();
      context.read<ClinicOnboardingBloc>().add(SubmitOnboardingRequested());
    }
  }

  void _onPreviousStep(int currentStep) {
    if (currentStep > 0) {
      _saveCurrentStepToState();
      context.read<ClinicOnboardingBloc>().add(StepChanged(currentStep - 1));
    } else {
      Navigator.of(context).pushReplacementNamed(RouteNames.login);
    }
  }

  void _onJumpToStep(int step) {
    _saveCurrentStepToState();
    context.read<ClinicOnboardingBloc>().add(StepChanged(step));
  }

  void _toggleUseAdminAsPrimary(bool? value) {
    final checked = value ?? false;
    setState(() {
      _useAdminAsPrimaryContact = checked;
      if (checked) {
        final fullName = '${_adminFirstNameController.text} ${_adminLastNameController.text}'.trim();
        if (fullName.isNotEmpty) {
          _primaryContactNameController.text = fullName;
        }
        if (_adminPhoneController.text.isNotEmpty) {
          _primaryPhoneController.text = _adminPhoneController.text;
        }
        if (_adminEmailController.text.isNotEmpty) {
          _primaryEmailController.text = _adminEmailController.text;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClinicOnboardingBloc, ClinicOnboardingState>(
      listener: (context, state) {
        if (state.isSuccess) {
          final targetEmail = state.formData.adminEmail.isNotEmpty
              ? state.formData.adminEmail
              : (state.formData.primaryEmail.isNotEmpty
                  ? state.formData.primaryEmail
                  : 'contact@apexdental.com');
          Navigator.of(context).pushReplacementNamed(
            RouteNames.emailVerification,
            arguments: targetEmail,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Clinic Registration & Onboarding'),
            leading: IconButton(
              icon: const Icon(AppIcons.back),
              onPressed: () => _onPreviousStep(state.currentStep),
            ),
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: AppSpacing.screenPadding,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;
                    final isSmall = constraints.maxWidth < 420;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 4-Step Progress Indicator
                        _buildStepProgressIndicator(state.currentStep),
                        const SizedBox(height: AppSpacing.xl),

                        if (state.errorMessage != null) ...[
                          StatusCard(
                            title: 'Registration Error',
                            message: state.errorMessage,
                            type: StatusType.error,
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],

                        AppCard(
                          padding: isMobile
                              ? const EdgeInsets.all(AppSpacing.md)
                              : AppSpacing.paddingXl,
                          child: _buildCurrentStepForm(
                            state.currentStep,
                            state.isLoading,
                            constraints.maxWidth,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Navigation Actions (Back & Next / Submit)
                        _buildActionButtons(state.currentStep, state.isLoading, isSmall),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepProgressIndicator(int currentStep) {
    final steps = [
      'Clinic Details',
      'Administrator',
      'Contact Info',
      'Review & Submit',
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 640;

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Step ${currentStep + 1} of ${steps.length}',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      steps[currentStep],
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (currentStep + 1) / steps.length,
                  minHeight: 6,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ],
          );
        }

        return Row(
          children: List.generate(steps.length, (index) {
            final isCompleted = currentStep > index;
            final isCurrent = currentStep == index;

            return Expanded(
              child: Row(
                children: [
                  InkWell(
                    onTap: isCompleted ? () => _onJumpToStep(index) : null,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.success
                            : (isCurrent ? AppColors.primary : AppColors.surfaceVariant),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: isCompleted
                          ? const Icon(AppIcons.check, color: Colors.white, size: 16)
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isCurrent ? Colors.white : AppColors.textTertiary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      steps[index],
                      style: AppTypography.labelSmall.copyWith(
                        color: isCurrent
                            ? AppColors.primary
                            : (isCompleted ? AppColors.textPrimary : AppColors.textSecondary),
                        fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (index < steps.length - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                        color: isCompleted ? AppColors.success : AppColors.border,
                      ),
                    ),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildActionButtons(int currentStep, bool isLoading, bool isSmall) {
    final isFinalStep = currentStep == 3;
    final primaryButtonText = isFinalStep ? 'Create Clinic Account' : 'Next Step';
    final primaryButtonIcon = isFinalStep ? AppIcons.check : AppIcons.forward;

    if (isSmall) {
      return Column(
        children: [
          PrimaryButton(
            text: primaryButtonText,
            isLoading: isLoading,
            icon: primaryButtonIcon,
            onPressed: () => _onNextStep(currentStep),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: isLoading ? null : () => _onPreviousStep(currentStep),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(
              currentStep == 0 ? 'Cancel to Login' : 'Back',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: OutlinedButton(
            onPressed: isLoading ? null : () => _onPreviousStep(currentStep),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(
              currentStep == 0 ? 'Cancel to Login' : 'Back',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          flex: 2,
          child: PrimaryButton(
            text: primaryButtonText,
            isLoading: isLoading,
            icon: primaryButtonIcon,
            onPressed: () => _onNextStep(currentStep),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStepForm(int step, bool isLoading, double maxWidth) {
    final isStacked = maxWidth < 540;
    switch (step) {
      case 0:
        return _buildStep1Form(isLoading, isStacked);
      case 1:
        return _buildStep2Form(isLoading, isStacked);
      case 2:
        return _buildStep3Form(isLoading, isStacked);
      case 3:
        return _buildStep4Review(isLoading, isStacked);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1Form(bool isLoading, bool isStacked) {
    return Form(
      key: _step1FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: const Icon(Icons.local_hospital_outlined, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text('Step 1: Clinic Practice Information', style: AppTypography.titleLarge),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Enter the registered details and primary identifiers of your dental facility.',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Clinic Logo Preview & Identifier Badge
          _buildClinicBrandingCard(isStacked),
          const SizedBox(height: AppSpacing.md),

          AppTextField(
            controller: _clinicNameController,
            label: 'Clinic Name *',
            hint: 'e.g., Apex Dental Care',
            enabled: !isLoading,
            validator: AppValidators.clinicName,
          ),
          const SizedBox(height: AppSpacing.md),
          AppDropdown<String>(
            label: 'Clinic Type *',
            value: _selectedClinicType,
            items: const [
              DropdownMenuItem(value: 'Multi-Speciality Practice', child: Text('Multi-Speciality Practice')),
              DropdownMenuItem(value: 'Solo Dental Practice', child: Text('Solo Dental Practice')),
              DropdownMenuItem(value: 'Orthodontics Center', child: Text('Orthodontics Center')),
              DropdownMenuItem(value: 'Oral Surgery & Hospital Unit', child: Text('Oral Surgery & Hospital Unit')),
              DropdownMenuItem(value: 'Pediatric Dental Center', child: Text('Pediatric Dental Center')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _selectedClinicType = val);
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Clinic Email & Clinic Phone
          if (isStacked) ...[
            AppEmailField(
              controller: _clinicEmailController,
              label: 'Clinic Email Address *',
              hint: 'contact@apexdental.com',
              enabled: !isLoading,
            ),
            const SizedBox(height: AppSpacing.md),
            AppPhoneField(
              controller: _clinicPhoneController,
              label: 'Clinic Phone Number *',
              hint: '+91 80 4123 4567',
              enabled: !isLoading,
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: AppEmailField(
                    controller: _clinicEmailController,
                    label: 'Clinic Email Address *',
                    hint: 'contact@apexdental.com',
                    enabled: !isLoading,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppPhoneField(
                    controller: _clinicPhoneController,
                    label: 'Clinic Phone Number *',
                    hint: '+91 80 4123 4567',
                    enabled: !isLoading,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md),

          AppTextField(
            controller: _addressController,
            label: 'Street Address (Optional)',
            hint: 'e.g., 42 Medical Enclave, MG Road',
            enabled: !isLoading,
          ),
          const SizedBox(height: AppSpacing.md),

          if (isStacked) ...[
            AppTextField(
              controller: _cityController,
              label: 'City *',
              hint: 'e.g., Bengaluru',
              enabled: !isLoading,
              validator: (v) => AppValidators.requiredField(v, 'City'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _stateController,
              label: 'State / Province *',
              hint: 'e.g., Karnataka',
              enabled: !isLoading,
              validator: (v) => AppValidators.requiredField(v, 'State'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _countryController,
              label: 'Country *',
              hint: 'e.g., India',
              enabled: !isLoading,
              validator: (v) => AppValidators.requiredField(v, 'Country'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _postalCodeController,
              label: 'Postal Code *',
              hint: 'e.g., 560001',
              enabled: !isLoading,
              validator: AppValidators.postalCode,
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _cityController,
                    label: 'City *',
                    hint: 'e.g., Bengaluru',
                    enabled: !isLoading,
                    validator: (v) => AppValidators.requiredField(v, 'City'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppTextField(
                    controller: _stateController,
                    label: 'State / Province *',
                    hint: 'e.g., Karnataka',
                    enabled: !isLoading,
                    validator: (v) => AppValidators.requiredField(v, 'State'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _countryController,
                    label: 'Country *',
                    hint: 'e.g., India',
                    enabled: !isLoading,
                    validator: (v) => AppValidators.requiredField(v, 'Country'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppTextField(
                    controller: _postalCodeController,
                    label: 'Postal Code *',
                    hint: 'e.g., 560001',
                    enabled: !isLoading,
                    validator: AppValidators.postalCode,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _websiteController,
            label: 'Clinic Website (Optional)',
            hint: 'https://apexdental.com',
            enabled: !isLoading,
            validator: AppValidators.website,
          ),
        ],
      ),
    );
  }

  Widget _buildClinicBrandingCard(bool isStacked) {
    final initials = _clinicNameController.text.trim().isNotEmpty
        ? _clinicNameController.text.trim()[0].toUpperCase()
        : 'C';

    return Container(
      padding: EdgeInsets.all(isStacked ? AppSpacing.sm : AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withAlpha(120),
        borderRadius: AppSpacing.borderRadiusSm,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: isStacked ? 18 : 24,
            backgroundColor: AppColors.primary,
            child: Text(
              initials,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isStacked ? 14 : 18,
              ),
            ),
          ),
          SizedBox(width: isStacked ? AppSpacing.sm : AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Clinic Logo & Branding',
                  style: isStacked ? AppTypography.titleSmall : AppTypography.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Upload practice emblem for invoices & charts',
                  style: AppTypography.bodySmall.copyWith(fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          if (isStacked)
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logo upload dialog (optional demo asset).')),
                );
              },
              icon: const Icon(Icons.cloud_upload_outlined, size: 20, color: AppColors.primary),
              tooltip: 'Upload Logo',
            )
          else
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logo upload dialog (optional demo asset).')),
                );
              },
              icon: const Icon(Icons.cloud_upload_outlined, size: 16),
              label: const Text('Upload'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStep2Form(bool isLoading, bool isStacked) {
    return Form(
      key: _step2FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: const Icon(Icons.admin_panel_settings_outlined, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text('Step 2: Administrator & Lead Practitioner', style: AppTypography.titleLarge),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Primary dental doctor or practice manager who will administer the SaaS clinic tenant and credentials.',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),

          if (isStacked) ...[
            AppTextField(
              controller: _adminFirstNameController,
              label: 'First Name *',
              hint: 'e.g., Elena',
              enabled: !isLoading,
              validator: (v) => AppValidators.administratorName(v, 'First Name'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _adminLastNameController,
              label: 'Last Name *',
              hint: 'e.g., Rostova',
              enabled: !isLoading,
              validator: (v) => AppValidators.administratorName(v, 'Last Name'),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _adminFirstNameController,
                    label: 'First Name *',
                    hint: 'e.g., Elena',
                    enabled: !isLoading,
                    validator: (v) => AppValidators.administratorName(v, 'First Name'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppTextField(
                    controller: _adminLastNameController,
                    label: 'Last Name *',
                    hint: 'e.g., Rostova',
                    enabled: !isLoading,
                    validator: (v) => AppValidators.administratorName(v, 'Last Name'),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md),

          AppEmailField(
            controller: _adminEmailController,
            label: 'Administrator Email *',
            hint: 'elena.rostova@apexdental.com',
            enabled: !isLoading,
          ),
          const SizedBox(height: AppSpacing.md),

          AppPhoneField(
            controller: _adminPhoneController,
            label: 'Mobile Number *',
            hint: '+91 98765 43210',
            enabled: !isLoading,
          ),
          const SizedBox(height: AppSpacing.md),

          AppDropdown<String>(
            label: 'Role / Designation *',
            value: _selectedAdminRole,
            items: const [
              DropdownMenuItem(value: 'Clinic Director / Owner', child: Text('Clinic Director / Owner')),
              DropdownMenuItem(value: 'Lead Dental Surgeon', child: Text('Lead Dental Surgeon')),
              DropdownMenuItem(value: 'Practice Administrator', child: Text('Practice Administrator')),
              DropdownMenuItem(value: 'Chief Medical Officer', child: Text('Chief Medical Officer')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _selectedAdminRole = val);
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Administrator Account Password & Confirmation
          AppPasswordField(
            controller: _passwordController,
            label: 'Administrator Password *',
            hint: 'Min 8 chars, 1 uppercase, 1 digit, 1 special symbol',
            enabled: !isLoading,
          ),
          const SizedBox(height: AppSpacing.md),

          AppPasswordField(
            controller: _confirmPasswordController,
            label: 'Confirm Administrator Password *',
            hint: 'Re-enter your administrator password',
            enabled: !isLoading,
            customValidator: (val) => AppValidators.confirmPassword(val, _passwordController.text),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Password guidelines card
          _buildPasswordGuidelines(),
        ],
      ),
    );
  }

  Widget _buildPasswordGuidelines() {
    return Container(
      padding: AppSpacing.paddingSm,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PASSWORD SECURITY POLICY:',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '• At least 8 characters\n• Uppercase & lowercase letters\n• At least 1 number and 1 special symbol (!@#\$%^&*)',
            style: AppTypography.bodySmall.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3Form(bool isLoading, bool isStacked) {
    return Form(
      key: _step3FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: const Icon(Icons.contact_phone_outlined, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text('Step 3: Contact & Emergency Information', style: AppTypography.titleLarge),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Public contact coordinates for patient bookings, appointment reminders, and critical clinic alerts.',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),

          // "Use administrator details" shortcut checkbox
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withAlpha(50),
              borderRadius: AppSpacing.borderRadiusSm,
              border: Border.all(color: AppColors.primary.withAlpha(50)),
            ),
            child: CheckboxListTile(
              value: _useAdminAsPrimaryContact,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                'Use administrator details as primary contact',
                style: AppTypography.titleMedium.copyWith(fontSize: 14),
              ),
              subtitle: Text(
                'Automatically populate primary contact name, phone, and email from Administrator step.',
                style: AppTypography.bodySmall,
              ),
              onChanged: isLoading ? null : _toggleUseAdminAsPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          AppTextField(
            controller: _primaryContactNameController,
            label: 'Primary Contact Person *',
            hint: 'e.g., Dr. Elena Rostova',
            enabled: !isLoading,
            validator: (v) => AppValidators.requiredField(v, 'Primary Contact Person'),
          ),
          const SizedBox(height: AppSpacing.md),

          if (isStacked) ...[
            AppPhoneField(
              controller: _primaryPhoneController,
              label: 'Primary Clinic Phone *',
              hint: '+91 98765 43210',
              enabled: !isLoading,
            ),
            const SizedBox(height: AppSpacing.md),
            AppEmailField(
              controller: _primaryEmailController,
              label: 'Primary Clinic Email *',
              hint: 'contact@apexdental.com',
              enabled: !isLoading,
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: AppPhoneField(
                    controller: _primaryPhoneController,
                    label: 'Primary Clinic Phone *',
                    hint: '+91 98765 43210',
                    enabled: !isLoading,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppEmailField(
                    controller: _primaryEmailController,
                    label: 'Primary Clinic Email *',
                    hint: 'contact@apexdental.com',
                    enabled: !isLoading,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md),

          AppPhoneField(
            controller: _alternatePhoneController,
            label: 'Alternate / Landline Phone (Optional)',
            hint: '+91 80 2345 6789',
            enabled: !isLoading,
            customValidator: (v) => v == null || v.isEmpty ? null : AppValidators.phone(v),
          ),
          const SizedBox(height: AppSpacing.md),

          AppDropdown<String>(
            label: 'Preferred Contact Method *',
            value: _selectedPreferredContactMethod,
            items: const [
              DropdownMenuItem(value: 'Email', child: Text('Email (Official notifications & invoices)')),
              DropdownMenuItem(value: 'Phone Call', child: Text('Phone Call (Direct doctor line)')),
              DropdownMenuItem(value: 'SMS / WhatsApp', child: Text('SMS / WhatsApp (Instant patient alerts)')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _selectedPreferredContactMethod = val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep4Review(bool isLoading, bool isStacked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: const Icon(Icons.assignment_turned_in_outlined, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text('Step 4: Review & Confirm Registration', style: AppTypography.titleLarge),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Please verify all details before submitting. You can click Edit on any section to make corrections.',
          style: AppTypography.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Review Section 1: Clinic Details
        _buildReviewSectionCard(
          title: 'Clinic Information',
          icon: Icons.local_hospital_outlined,
          onEdit: () => _onJumpToStep(0),
          isStacked: isStacked,
          entries: [
            MapEntry('Clinic Name', _clinicNameController.text.trim()),
            MapEntry('Type', _selectedClinicType),
            MapEntry('Clinic Email', _clinicEmailController.text.trim()),
            MapEntry('Clinic Phone', _clinicPhoneController.text.trim()),
            MapEntry('Location', '${_cityController.text.trim()}, ${_stateController.text.trim()}, ${_countryController.text.trim()} - ${_postalCodeController.text.trim()}'),
            if (_websiteController.text.trim().isNotEmpty)
              MapEntry('Website', _websiteController.text.trim()),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Review Section 2: Administrator Details
        _buildReviewSectionCard(
          title: 'Administrator Account',
          icon: Icons.admin_panel_settings_outlined,
          onEdit: () => _onJumpToStep(1),
          isStacked: isStacked,
          entries: [
            MapEntry('Name', '${_adminFirstNameController.text.trim()} ${_adminLastNameController.text.trim()}'),
            MapEntry('Email', _adminEmailController.text.trim()),
            MapEntry('Mobile', _adminPhoneController.text.trim()),
            MapEntry('Designation', _selectedAdminRole),
            const MapEntry('Password', '•••••••••••• (Encrypted)'),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Review Section 3: Contact & Emergency Details
        _buildReviewSectionCard(
          title: 'Public Contact Coordinates',
          icon: Icons.contact_phone_outlined,
          onEdit: () => _onJumpToStep(2),
          isStacked: isStacked,
          entries: [
            MapEntry('Contact Person', _primaryContactNameController.text.trim()),
            MapEntry('Primary Phone', _primaryPhoneController.text.trim()),
            MapEntry('Primary Email', _primaryEmailController.text.trim()),
            if (_alternatePhoneController.text.trim().isNotEmpty)
              MapEntry('Alternate Phone', _alternatePhoneController.text.trim()),
            MapEntry('Preferred Channel', _selectedPreferredContactMethod),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Terms & Conditions Checkbox
        Container(
          padding: AppSpacing.paddingSm,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: AppSpacing.borderRadiusSm,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _termsAccepted,
                onChanged: isLoading ? null : (val) => setState(() => _termsAccepted = val ?? false),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'I confirm that the clinic details provided above are true and accurate. I agree to the Dentist SaaS Terms of Service and HIPAA/Clinical Privacy Policy.',
                    style: AppTypography.bodySmall,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSectionCard({
    required String title,
    required IconData icon,
    required VoidCallback onEdit,
    required bool isStacked,
    required List<MapEntry<String, String>> entries,
  }) {
    return Container(
      padding: EdgeInsets.all(isStacked ? AppSpacing.sm : AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 18),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 14),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
          const Divider(height: AppSpacing.md),
          ...entries.map((e) {
            if (isStacked) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.key,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      e.value,
                      style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      e.key,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      e.value,
                      style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
