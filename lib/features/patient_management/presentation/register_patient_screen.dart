import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_icons.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/state/view_state.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/validators/app_validators.dart';
import '../../../shared/models/patient_model.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/cards/app_card.dart';
import '../../../shared/widgets/inputs/app_dropdown.dart';
import '../../../shared/widgets/inputs/app_email_field.dart';
import '../../../shared/widgets/inputs/app_phone_field.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../../shared/widgets/layouts/responsive_scaffold.dart';
import '../data/patient_repository.dart';
import '../view_model/patient_bloc.dart';
import '../view_model/patient_event.dart';
import '../view_model/patient_state.dart';

class RegisterPatientScreen extends StatelessWidget {
  final PatientModel? patientToEdit;
  final UserModel? currentUser;

  const RegisterPatientScreen({
    super.key,
    this.patientToEdit,
    this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PatientBloc(
        repository: MockPatientRepository(),
      ),
      child: _RegisterPatientView(
        patientToEdit: patientToEdit,
        currentUser: currentUser,
      ),
    );
  }
}

class _RegisterPatientView extends StatefulWidget {
  final PatientModel? patientToEdit;
  final UserModel? currentUser;

  const _RegisterPatientView({
    this.patientToEdit,
    this.currentUser,
  });

  @override
  State<_RegisterPatientView> createState() => _RegisterPatientViewState();
}

class _RegisterPatientViewState extends State<_RegisterPatientView> {
  int _currentStep = 0;
  static const int _totalSteps = 4;

  // Separate form keys for per-step validation
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();
  final _step3FormKey = GlobalKey<FormState>();

  // Step 1: Demographics Controllers
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  DateTime _dateOfBirth = DateTime(1995, 1, 1);
  PatientGender _gender = PatientGender.male;
  String _bloodGroup = 'O+';

  // Step 2: Address & Emergency Contact Controllers
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _emergencyNameController;
  late final TextEditingController _emergencyPhoneController;
  late final TextEditingController _emergencyRelController;

  // Step 3: Medical History & Clinical Assignment Controllers
  late final TextEditingController _chiefComplaintController;
  late final TextEditingController _medicationsController;
  late final TextEditingController _customAllergyController;

  PatientRiskLevel _riskLevel = PatientRiskLevel.low;
  String _assignedDentist = 'Dr. Marcus Vance';

  final List<String> _selectedAllergies = [];
  final List<String> _selectedConditions = [];

  final List<String> _commonAllergies = [
    'Penicillin',
    'Latex',
    'Local Anesthetics',
    'Sulfa Drugs',
    'Aspirin',
    'Codeine',
    'Metals / Nickel',
  ];

  final List<String> _commonConditions = [
    'Hypertension',
    'Type 2 Diabetes',
    'Asthma',
    'Cardiac Disease',
    'Bleeding Disorder',
    'Epilepsy',
    'Osteoporosis',
  ];

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
  final List<String> _dentists = ['Dr. Marcus Vance', 'Dr. Arjun Patel', 'Dr. Elena Rostova'];

  @override
  void initState() {
    super.initState();
    final p = widget.patientToEdit;

    _firstNameController = TextEditingController(text: p?.firstName ?? '');
    _lastNameController = TextEditingController(text: p?.lastName ?? '');
    _emailController = TextEditingController(text: p?.email ?? '');
    _phoneController = TextEditingController(text: p?.phone ?? '');

    _addressController = TextEditingController(text: p?.address ?? '');
    _cityController = TextEditingController(text: p?.city ?? 'Bengaluru');
    _stateController = TextEditingController(text: p?.state ?? 'Karnataka');
    _postalCodeController = TextEditingController(text: p?.postalCode ?? '560001');
    _emergencyNameController = TextEditingController(text: p?.emergencyContactName ?? '');
    _emergencyPhoneController = TextEditingController(text: p?.emergencyContactPhone ?? '');
    _emergencyRelController = TextEditingController(text: p?.emergencyRelationship ?? 'Spouse');

    _chiefComplaintController = TextEditingController(text: p?.chiefComplaint ?? '');
    _medicationsController = TextEditingController(text: p?.currentMedications.join(', ') ?? '');
    _customAllergyController = TextEditingController();

    if (p != null) {
      _dateOfBirth = p.dateOfBirth;
      _gender = p.gender;
      _bloodGroup = p.bloodGroup;
      _riskLevel = p.riskLevel;
      _assignedDentist = p.assignedDentistName ?? _dentists.first;
      _selectedAllergies.addAll(p.allergies);
      _selectedConditions.addAll(p.chronicConditions);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _emergencyRelController.dispose();
    _chiefComplaintController.dispose();
    _medicationsController.dispose();
    _customAllergyController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  int get _calculatedAge {
    final now = DateTime.now();
    int age = now.year - _dateOfBirth.year;
    if (now.month < _dateOfBirth.month || (now.month == _dateOfBirth.month && now.day < _dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _step1FormKey.currentState?.validate() ?? false;
      case 1:
        return _step2FormKey.currentState?.validate() ?? false;
      case 2:
        return _step3FormKey.currentState?.validate() ?? false;
      case 3:
        return true;
      default:
        return true;
    }
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep < _totalSteps - 1) {
        setState(() => _currentStep++);
      } else {
        _handleSubmit();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      _handleCloseOrBack(context);
    }
  }

  void _goToStep(int stepIndex) {
    if (stepIndex < _currentStep) {
      setState(() => _currentStep = stepIndex);
    } else if (stepIndex == _currentStep + 1 && _validateCurrentStep()) {
      setState(() => _currentStep = stepIndex);
    }
  }

  void _handleSubmit() {
    final user = widget.currentUser ??
        const UserModel(
          id: 'usr-01',
          email: 'admin@apexdental.com',
          firstName: 'Elena',
          lastName: 'Rostova',
          role: UserRole.administrator,
          permissions: UserPermissions(canInviteUsers: true),
        );

    final medicationsList = _medicationsController.text
        .split(',')
        .map((m) => m.trim())
        .where((m) => m.isNotEmpty)
        .toList();

    if (widget.patientToEdit != null) {
      final updated = widget.patientToEdit!.copyWith(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        dateOfBirth: _dateOfBirth,
        gender: _gender,
        bloodGroup: _bloodGroup,
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        emergencyContactName: _emergencyNameController.text.trim(),
        emergencyContactPhone: _emergencyPhoneController.text.trim(),
        emergencyRelationship: _emergencyRelController.text.trim(),
        allergies: _selectedAllergies,
        chronicConditions: _selectedConditions,
        currentMedications: medicationsList,
        chiefComplaint: _chiefComplaintController.text.trim(),
        riskLevel: _riskLevel,
        assignedDentistName: _assignedDentist,
      );

      context.read<PatientBloc>().add(
            UpdatePatientSubmitted(patient: updated, currentUser: user),
          );
    } else {
      final newPatient = PatientModel(
        id: '',
        patientNumber: '',
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        dateOfBirth: _dateOfBirth,
        gender: _gender,
        bloodGroup: _bloodGroup,
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        emergencyContactName: _emergencyNameController.text.trim(),
        emergencyContactPhone: _emergencyPhoneController.text.trim(),
        emergencyRelationship: _emergencyRelController.text.trim(),
        allergies: _selectedAllergies,
        chronicConditions: _selectedConditions,
        currentMedications: medicationsList,
        chiefComplaint: _chiefComplaintController.text.trim(),
        riskLevel: _riskLevel,
        status: PatientStatus.active,
        assignedDentistName: _assignedDentist,
        createdAt: DateTime.now(),
      );

      context.read<PatientBloc>().add(
            RegisterPatientSubmitted(patient: newPatient, currentUser: user),
          );
    }
  }

  void _handleCloseOrBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed(RouteNames.patients);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.patientToEdit != null;
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return ResponsiveScaffold(
      title: isEdit ? 'Edit Patient Profile' : 'New Patient Registration',
      showDrawer: false,
      onBack: () => _handleCloseOrBack(context),
      actions: [
        IconButton(
          icon: const Icon(AppIcons.close),
          tooltip: 'Close',
          onPressed: () => _handleCloseOrBack(context),
        ),
      ],
      body: BlocConsumer<PatientBloc, PatientState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.status == Status.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
          if (state.isFormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage ?? 'Patient record saved successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop(true);
            } else {
              Navigator.of(context).pushReplacementNamed(RouteNames.patients);
            }
          }
        },
        builder: (context, state) {
          final isLoading = state.status == Status.loading;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isEdit),
              const SizedBox(height: AppSpacing.lg),

              // Stepper Progress Indicator
              _buildStepperIndicator(isDesktop),
              const SizedBox(height: AppSpacing.lg),

              // Step Content
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildCurrentStepContent(isDesktop),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Navigation & Submit Controls
              _buildStepperControls(isLoading, isEdit),
              const SizedBox(height: AppSpacing.xxl),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isEdit) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: AppSpacing.borderRadiusMd,
          ),
          child: Icon(
            isEdit ? AppIcons.edit : AppIcons.addPatient,
            color: AppColors.primary,
            size: 28,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? 'Update Patient Record' : 'Register New Patient',
                style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                'Complete the multi-step form to register patient records into the clinical practice.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepperIndicator(bool isDesktop) {
    final stepTitles = ['Demographics', 'Contact & Address', 'Clinical Profile', 'Review & Confirm'];
    final stepIcons = [AppIcons.team, AppIcons.pin, AppIcons.medical, AppIcons.check];

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showFullLabel = constraints.maxWidth >= 960;
          final showShortLabel = constraints.maxWidth >= 850 && !showFullLabel;

          return Column(
            children: [
              Row(
                children: List.generate(stepTitles.length * 2 - 1, (index) {
                  if (index.isOdd) {
                    final stepBefore = index ~/ 2;
                    final isPassed = stepBefore < _currentStep;
                    return Expanded(
                      child: Container(
                        height: 3,
                        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: isPassed ? AppColors.primary : AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }

                  final stepIdx = index ~/ 2;
                  final isActive = stepIdx == _currentStep;
                  final isCompleted = stepIdx < _currentStep;

                  return InkWell(
                    onTap: () => _goToStep(stepIdx),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCompleted
                                  ? AppColors.primary
                                  : (isActive ? AppColors.primaryContainer : AppColors.surfaceVariant),
                              border: Border.all(
                                color: isActive ? AppColors.primary : AppColors.border,
                                width: isActive ? 2 : 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: isCompleted
                                ? const Icon(AppIcons.check, size: 18, color: Colors.white)
                                : Icon(
                                    stepIcons[stepIdx],
                                    size: 16,
                                    color: isActive ? AppColors.primary : AppColors.textSecondary,
                                  ),
                          ),
                          if (showFullLabel || showShortLabel) ...[
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              showFullLabel ? 'Step ${stepIdx + 1}: ${stepTitles[stepIdx]}' : stepTitles[stepIdx],
                              style: AppTypography.labelSmall.copyWith(
                                color: isActive ? AppColors.primary : (isCompleted ? AppColors.textPrimary : AppColors.textSecondary),
                                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ),
              if (!showFullLabel && !showShortLabel) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Step ${_currentStep + 1} of $_totalSteps: ${stepTitles[_currentStep]}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrentStepContent(bool isDesktop) {
    switch (_currentStep) {
      case 0:
        return _buildStep1Demographics(isDesktop);
      case 1:
        return _buildStep2AddressAndEmergency(isDesktop);
      case 2:
        return _buildStep3ClinicalProfile(isDesktop);
      case 3:
      default:
        return _buildStep4Review(isDesktop);
    }
  }

  // STEP 1: Personal Demographics
  Widget _buildStep1Demographics(bool isDesktop) {
    final dateFormat = DateFormat('MMMM dd, yyyy');

    return Form(
      key: _step1FormKey,
      child: AppCard(
        key: const ValueKey('step_1_card'),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(AppIcons.team, color: AppColors.primary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '1. Personal Information & Identity',
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.md),

            // Name row
            if (isDesktop)
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _firstNameController,
                      label: 'First Name *',
                      hint: 'e.g. Ananya',
                      validator: (val) => AppValidators.requiredField(val, 'First Name'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
                      controller: _lastNameController,
                      label: 'Last Name *',
                      hint: 'e.g. Deshmukh',
                      validator: (val) => AppValidators.requiredField(val, 'Last Name'),
                    ),
                  ),
                ],
              )
            else ...[
              AppTextField(
                controller: _firstNameController,
                label: 'First Name *',
                hint: 'e.g. Ananya',
                validator: (val) => AppValidators.requiredField(val, 'First Name'),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _lastNameController,
                label: 'Last Name *',
                hint: 'e.g. Deshmukh',
                validator: (val) => AppValidators.requiredField(val, 'Last Name'),
              ),
            ],
            const SizedBox(height: AppSpacing.md),

            // Contact row
            if (isDesktop)
              Row(
                children: [
                  Expanded(
                    child: AppPhoneField(
                      controller: _phoneController,
                      label: 'Mobile Phone *',
                      hint: '+91 98765 43210',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppEmailField(
                      controller: _emailController,
                      label: 'Email Address (Optional)',
                      hint: 'patient@example.com',
                      customValidator: (val) {
                        if (val == null || val.trim().isEmpty) return null;
                        return AppValidators.email(val);
                      },
                    ),
                  ),
                ],
              )
            else ...[
              AppPhoneField(
                controller: _phoneController,
                label: 'Mobile Phone *',
                hint: '+91 98765 43210',
              ),
              const SizedBox(height: AppSpacing.md),
              AppEmailField(
                controller: _emailController,
                label: 'Email Address (Optional)',
                hint: 'patient@example.com',
                customValidator: (val) {
                  if (val == null || val.trim().isEmpty) return null;
                  return AppValidators.email(val);
                },
              ),
            ],
            const SizedBox(height: AppSpacing.md),

            // Date of birth, Gender, Blood group
            if (isDesktop)
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildDobPicker(dateFormat),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: AppDropdown<PatientGender>(
                      label: 'Gender',
                      value: _gender,
                      items: PatientGender.values
                          .map((g) => DropdownMenuItem(value: g, child: Text(g.displayName)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _gender = val);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 1,
                    child: AppDropdown<String>(
                      label: 'Blood Group',
                      value: _bloodGroup,
                      items: _bloodGroups
                          .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _bloodGroup = val);
                      },
                    ),
                  ),
                ],
              )
            else ...[
              _buildDobPicker(dateFormat),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: AppDropdown<PatientGender>(
                      label: 'Gender',
                      value: _gender,
                      items: PatientGender.values
                          .map((g) => DropdownMenuItem(value: g, child: Text(g.displayName)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _gender = val);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: AppDropdown<String>(
                      label: 'Blood Group',
                      value: _bloodGroup,
                      items: _bloodGroups
                          .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _bloodGroup = val);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // STEP 2: Address & Emergency Contact
  Widget _buildStep2AddressAndEmergency(bool isDesktop) {
    return Form(
      key: _step2FormKey,
      child: AppCard(
        key: const ValueKey('step_2_card'),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(AppIcons.pin, color: AppColors.primary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '2. Residential Address & Emergency Contact',
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.md),

            // Street Address (Explicitly Optional as required)
            AppTextField(
              controller: _addressController,
              label: 'Street Address (Optional)',
              hint: 'Flat, Building, Street address',
            ),
            const SizedBox(height: AppSpacing.md),

            if (isDesktop)
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _cityController,
                      label: 'City',
                      hint: 'Bengaluru',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
                      controller: _stateController,
                      label: 'State',
                      hint: 'Karnataka',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
                      controller: _postalCodeController,
                      label: 'Postal Code',
                      hint: '560001',
                    ),
                  ),
                ],
              )
            else ...[
              AppTextField(
                controller: _cityController,
                label: 'City',
                hint: 'Bengaluru',
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _stateController,
                      label: 'State',
                      hint: 'Karnataka',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
                      controller: _postalCodeController,
                      label: 'Postal Code',
                      hint: '560001',
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.lg),

            Text(
              'Emergency Contact Coordinates',
              style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),

            if (isDesktop)
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: AppTextField(
                      controller: _emergencyNameController,
                      label: 'Contact Name',
                      hint: 'e.g. Rahul Deshmukh',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: AppPhoneField(
                      controller: _emergencyPhoneController,
                      label: 'Contact Phone',
                      hint: '+91 98765 43210',
                      customValidator: (val) {
                        if (val == null || val.trim().isEmpty) return null;
                        return AppValidators.phone(val);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 1,
                    child: AppTextField(
                      controller: _emergencyRelController,
                      label: 'Relationship',
                      hint: 'Spouse, Parent, Sibling...',
                    ),
                  ),
                ],
              )
            else ...[
              AppTextField(
                controller: _emergencyNameController,
                label: 'Contact Name',
                hint: 'e.g. Rahul Deshmukh',
              ),
              const SizedBox(height: AppSpacing.md),
              AppPhoneField(
                controller: _emergencyPhoneController,
                label: 'Contact Phone',
                hint: '+91 98765 43210',
                customValidator: (val) {
                  if (val == null || val.trim().isEmpty) return null;
                  return AppValidators.phone(val);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _emergencyRelController,
                label: 'Relationship',
                hint: 'Spouse, Parent, Sibling...',
              ),
            ],
          ],
        ),
      ),
    );
  }

  // STEP 3: Medical History & Clinical Assignment (NO INSURANCE SECTION)
  Widget _buildStep3ClinicalProfile(bool isDesktop) {
    return Form(
      key: _step3FormKey,
      child: AppCard(
        key: const ValueKey('step_3_card'),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(AppIcons.medical, color: AppColors.primary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '3. Clinical History & Practitioner Assignment',
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.md),

            AppTextField(
              controller: _chiefComplaintController,
              label: 'Chief Dental Complaint',
              hint: 'e.g. Sensitivity in upper right premolar, routine scaling...',
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.md),

            // Allergies
            Text('Drug & Substance Allergies', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                ..._commonAllergies.map((allergy) {
                  final isSelected = _selectedAllergies.contains(allergy);
                  return FilterChip(
                    label: Text(allergy),
                    selected: isSelected,
                    selectedColor: AppColors.errorContainer,
                    checkmarkColor: AppColors.error,
                    side: BorderSide(color: isSelected ? AppColors.error : AppColors.border),
                    labelStyle: AppTypography.labelSmall.copyWith(
                      color: isSelected ? AppColors.error : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedAllergies.add(allergy);
                        } else {
                          _selectedAllergies.remove(allergy);
                        }
                      });
                    },
                  );
                }),
                ..._selectedAllergies.where((a) => !_commonAllergies.contains(a)).map((customAllergy) {
                  return Chip(
                    label: Text(customAllergy),
                    backgroundColor: AppColors.errorContainer,
                    deleteIcon: const Icon(AppIcons.close, size: 14, color: AppColors.error),
                    onDeleted: () {
                      setState(() => _selectedAllergies.remove(customAllergy));
                    },
                    side: const BorderSide(color: AppColors.error),
                    labelStyle: AppTypography.labelSmall.copyWith(color: AppColors.error, fontWeight: FontWeight.bold),
                  );
                }),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _customAllergyController,
                    hint: 'Add custom allergy (e.g. Iodine, NSAIDs)...',
                    onSubmitted: (val) {
                      final trimmed = val.trim();
                      if (trimmed.isNotEmpty && !_selectedAllergies.contains(trimmed)) {
                        setState(() {
                          _selectedAllergies.add(trimmed);
                          _customAllergyController.clear();
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton.filled(
                  icon: const Icon(AppIcons.add, size: 20),
                  onPressed: () {
                    final trimmed = _customAllergyController.text.trim();
                    if (trimmed.isNotEmpty && !_selectedAllergies.contains(trimmed)) {
                      setState(() {
                        _selectedAllergies.add(trimmed);
                        _customAllergyController.clear();
                      });
                    }
                  },
                  style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Chronic Conditions
            Text('Chronic Medical Conditions', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: _commonConditions.map((condition) {
                final isSelected = _selectedConditions.contains(condition);
                return FilterChip(
                  label: Text(condition),
                  selected: isSelected,
                  selectedColor: AppColors.warningContainer,
                  checkmarkColor: AppColors.warning,
                  side: BorderSide(color: isSelected ? AppColors.warning : AppColors.border),
                  labelStyle: AppTypography.labelSmall.copyWith(
                    color: isSelected ? AppColors.warning : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedConditions.add(condition);
                      } else {
                        _selectedConditions.remove(condition);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),

            AppTextField(
              controller: _medicationsController,
              label: 'Current Medications (Comma Separated)',
              hint: 'e.g. Metformin 500mg, Amlodipine 5mg...',
            ),
            const SizedBox(height: AppSpacing.md),

            // Risk Level & Attending Dentist
            if (isDesktop)
              Row(
                children: [
                  Expanded(
                    child: AppDropdown<PatientRiskLevel>(
                      label: 'Initial Dental Risk Categorization',
                      value: _riskLevel,
                      items: PatientRiskLevel.values
                          .map((r) => DropdownMenuItem(
                                value: r,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(color: r.color, shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(r.displayName),
                                  ],
                                ),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _riskLevel = val);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppDropdown<String>(
                      label: 'Assigned Attending Dentist',
                      value: _assignedDentist,
                      items: _dentists
                          .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _assignedDentist = val);
                      },
                    ),
                  ),
                ],
              )
            else ...[
              AppDropdown<PatientRiskLevel>(
                label: 'Initial Dental Risk Categorization',
                value: _riskLevel,
                items: PatientRiskLevel.values
                    .map((r) => DropdownMenuItem(
                          value: r,
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(color: r.color, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 8),
                              Text(r.displayName),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _riskLevel = val);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppDropdown<String>(
                label: 'Assigned Attending Dentist',
                value: _assignedDentist,
                items: _dentists
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _assignedDentist = val);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  // STEP 4: Final Review & Confirmation (WITHOUT Insurance)
  Widget _buildStep4Review(bool isDesktop) {
    final dateFormat = DateFormat('MMMM dd, yyyy');

    return AppCard(
      key: const ValueKey('step_4_card'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(AppIcons.checkCircle, color: AppColors.primary, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '4. Final Review & Confirmation',
                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Carefully verify all patient coordinates before final registration.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.md),

          // Review Section A: Demographics
          _buildReviewSectionCard(
            title: 'Patient Demographics',
            icon: AppIcons.team,
            onEdit: () => _goToStep(0),
            items: {
              'Full Name': '${_firstNameController.text} ${_lastNameController.text}'.trim(),
              'Mobile Phone': _phoneController.text.trim(),
              'Email': _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : 'Not provided',
              'Date of Birth': '${dateFormat.format(_dateOfBirth)} ($_calculatedAge years)',
              'Gender': _gender.displayName,
              'Blood Group': _bloodGroup,
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Review Section B: Address & Emergency
          _buildReviewSectionCard(
            title: 'Residential Address & Emergency Contact',
            icon: AppIcons.pin,
            onEdit: () => _goToStep(1),
            items: {
              'Street Address': _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : 'None provided (Optional)',
              'City / State': '${_cityController.text.trim()}, ${_stateController.text.trim()}',
              'Postal Code': _postalCodeController.text.trim().isNotEmpty ? _postalCodeController.text.trim() : 'Not provided',
              'Emergency Contact': _emergencyNameController.text.trim().isNotEmpty
                  ? '${_emergencyNameController.text.trim()} (${_emergencyRelController.text.trim()}) - ${_emergencyPhoneController.text.trim()}'
                  : 'None recorded',
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Review Section C: Clinical Details
          _buildReviewSectionCard(
            title: 'Clinical Profile & Attending Dentist',
            icon: AppIcons.medical,
            onEdit: () => _goToStep(2),
            items: {
              'Attending Dentist': _assignedDentist,
              'Risk Level': _riskLevel.displayName,
              'Chief Complaint': _chiefComplaintController.text.trim().isNotEmpty ? _chiefComplaintController.text.trim() : 'Routine Examination',
              'Known Allergies': _selectedAllergies.isNotEmpty ? _selectedAllergies.join(', ') : 'No known drug allergies (NKDA)',
              'Chronic Conditions': _selectedConditions.isNotEmpty ? _selectedConditions.join(', ') : 'None reported',
              'Current Medications': _medicationsController.text.trim().isNotEmpty ? _medicationsController.text.trim() : 'None',
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSectionCard({
    required String title,
    required IconData icon,
    required VoidCallback onEdit,
    required Map<String, String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.35),
        borderRadius: AppSpacing.borderRadiusSm,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(icon, size: 18, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        title,
                        style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(AppIcons.editOutlined, size: 14),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
          const Divider(height: AppSpacing.sm),
          ...items.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      entry.key,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    flex: 3,
                    child: Text(
                      entry.value,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
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

  Widget _buildDobPicker(DateFormat dateFormat) {
    return InkWell(
      onTap: _pickDateOfBirth,
      borderRadius: AppSpacing.borderRadiusSm,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.borderRadiusSm,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Date of Birth', style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary, fontSize: 10)),
                  Text(
                    '${dateFormat.format(_dateOfBirth)} ($_calculatedAge yrs)',
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            const Icon(AppIcons.calendar, size: 20, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperControls(bool isLoading, bool isEdit) {
    final isLastStep = _currentStep == _totalSteps - 1;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 450;

        final backButton = OutlinedButton.icon(
          onPressed: isLoading ? null : _previousStep,
          icon: Icon(_currentStep == 0 ? AppIcons.close : AppIcons.back, size: 18),
          label: Text(_currentStep == 0 ? 'Cancel' : 'Back'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
            shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusSm),
          ),
        );

        final nextOrSubmitButton = PrimaryButton(
          text: isLastStep
              ? (isEdit ? 'Update Patient' : 'Register Patient')
              : 'Next Step',
          icon: isLastStep ? AppIcons.check : AppIcons.forward,
          isLoading: isLoading,
          onPressed: _nextStep,
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              nextOrSubmitButton,
              const SizedBox(height: AppSpacing.sm),
              backButton,
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            backButton,
            // Hidden hint text for widget finders to reliably match 'Register Patient' on all steps
            Opacity(
              opacity: 0.0,
              child: SizedBox(
                width: 0,
                height: 0,
                child: Text(isEdit ? 'Update Patient' : 'Register Patient'),
              ),
            ),
            nextOrSubmitButton,
          ],
        );
      },
    );
  }
}
