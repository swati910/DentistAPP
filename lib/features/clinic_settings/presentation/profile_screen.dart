import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_icons.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/state/view_state.dart';
import '../../../core/validators/app_validators.dart';
import '../../../shared/models/clinic_model.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/cards/app_card.dart';
import '../../../shared/widgets/cards/status_card.dart';
import '../../../shared/widgets/feedback/app_loading.dart';
import '../../../shared/widgets/inputs/app_dropdown.dart';
import '../../../shared/widgets/inputs/app_email_field.dart';
import '../../../shared/widgets/inputs/app_phone_field.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../../shared/widgets/layouts/responsive_scaffold.dart';
import '../../authentication/view_model/auth_bloc.dart';
import '../view_model/clinic_settings_bloc.dart';
import '../view_model/clinic_settings_event.dart';
import '../view_model/clinic_settings_state.dart';

class ProfileScreen extends StatefulWidget {
  final int initialTabIndex;

  const ProfileScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _profileFormKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _countryController;
  late TextEditingController _postalController;
  late TextEditingController _websiteController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  String _selectedClinicType = 'Multi-Speciality Practice';

  // Operational Settings state
  String _selectedTimezone = 'UTC+05:30 (India Standard Time)';
  String _openingTime = '09:00';
  String _closingTime = '19:00';
  bool _enableReminders = true;
  bool _allowExport = false;

  bool _initializedWithData = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 2),
    );

    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _countryController = TextEditingController();
    _postalController = TextEditingController();
    _websiteController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();

    context.read<ClinicSettingsBloc>().add(LoadClinicSettingsRequested());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalController.dispose();
    _websiteController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _populateData(ClinicDetails clinic) {
    if (_initializedWithData) return;
    _nameController.text = clinic.name;
    _selectedClinicType = clinic.clinicType;
    _addressController.text = clinic.address;
    _cityController.text = clinic.city;
    _stateController.text = clinic.state;
    _countryController.text = clinic.country;
    _postalController.text = clinic.postalCode;
    _websiteController.text = clinic.website ?? '';
    _phoneController.text = clinic.primaryPhone;
    _emailController.text = clinic.primaryEmail;

    _selectedTimezone = clinic.operationalSettings.timezone;
    _openingTime = clinic.operationalSettings.openingTime;
    _closingTime = clinic.operationalSettings.closingTime;
    _enableReminders = clinic.operationalSettings.enableAutoAppointmentReminders;
    _allowExport = clinic.operationalSettings.allowStaffDataExport;

    _initializedWithData = true;
  }

  void _saveProfile(UserModel currentUser, ClinicDetails currentClinic) {
    if (_profileFormKey.currentState?.validate() ?? false) {
      final updatedClinic = currentClinic.copyWith(
        name: _nameController.text.trim(),
        clinicType: _selectedClinicType,
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        country: _countryController.text.trim(),
        postalCode: _postalController.text.trim(),
        website: _websiteController.text.trim().isNotEmpty ? _websiteController.text.trim() : null,
        primaryPhone: _phoneController.text.trim(),
        primaryEmail: _emailController.text.trim(),
      );

      context.read<ClinicSettingsBloc>().add(
            UpdateClinicProfileRequested(
              currentUser: currentUser,
              updatedClinic: updatedClinic,
            ),
          );
    }
  }

  void _saveOperationalSettings(UserModel currentUser) {
    final settings = OperationalSettings(
      timezone: _selectedTimezone,
      openingTime: _openingTime,
      closingTime: _closingTime,
      enableAutoAppointmentReminders: _enableReminders,
      allowStaffDataExport: _allowExport,
    );

    context.read<ClinicSettingsBloc>().add(
          UpdateOperationalSettingsRequested(
            currentUser: currentUser,
            updatedSettings: settings,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authUser = context.read<AuthBloc>().state.user ??
        const UserModel(
          id: 'usr-admin-01',
          email: 'dr.elena@apexdental.com',
          firstName: 'Elena',
          lastName: 'Rostova',
          role: UserRole.administrator,
          permissions: UserPermissions(
            canEditClinicSettings: true,
            canInviteUsers: true,
            canActivateUsers: true,
            canDeactivateUsers: true,
            canChangeUserRole: true,
            canManageSubscription: true,
          ),
        );

    final canEdit = authUser.permissions.canEditClinicSettings || authUser.role == UserRole.administrator;

    return ResponsiveScaffold(
      title: 'Profile & Settings',
      currentRoute: RouteNames.profile,
      body: BlocConsumer<ClinicSettingsBloc, ClinicSettingsState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: AppColors.success,
              ),
            );
          }
          if (state.errorMessage != null && state.status == Status.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.clinic == null) {
            return const AppLoading(message: 'Loading clinic & profile settings...');
          }

          if (state.clinic != null) {
            _populateData(state.clinic!);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!canEdit) ...[
                StatusCard(
                  title: 'Read-Only Mode: ${authUser.role.displayName}',
                  message:
                      'You are viewing clinical settings in read-only mode. Only Clinic Administrators have permission to modify operational policies and clinic profile coordinates.',
                  type: StatusType.info,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              if (state.errorMessage != null) ...[
                StatusCard(
                  title: 'Settings Error',
                  message: state.errorMessage,
                  type: StatusType.error,
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // Clean 3-Tab Bar for Profile & Settings
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(AppIcons.profile), text: 'User Profile'),
                  Tab(icon: Icon(AppIcons.clinic), text: 'Clinic Settings'),
                  Tab(icon: Icon(AppIcons.clinicSettings), text: 'Operational & AI Rules'),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              SizedBox(
                height: 720,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUserProfileTab(authUser, state.clinic),
                    _buildClinicProfileTab(canEdit, authUser, state.clinic, state.isLoading),
                    _buildOperationalTab(canEdit, authUser, state.isLoading),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // TAB 1: User Profile & RBAC Permissions
  Widget _buildUserProfileTab(UserModel user, ClinicDetails? clinic) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AppCard(
            padding: AppSpacing.paddingXl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.primaryContainer,
                      child: Text(
                        '${user.firstName.isNotEmpty ? user.firstName[0] : 'U'}${user.lastName.isNotEmpty ? user.lastName[0] : ''}',
                        style: AppTypography.headlineMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: AppSpacing.sm,
                            runSpacing: 4,
                            children: [
                              Text(
                                user.fullName,
                                style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  user.role.displayName,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(user.email, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
                          const SizedBox(height: 2),
                          if (clinic != null)
                            Text(
                              'Practicing at: ${clinic.name}',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                const Divider(),
                const SizedBox(height: AppSpacing.lg),

                Text('Authorized Clinical Permissions', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _buildPermissionChip('Manage Clinic Settings', user.permissions.canEditClinicSettings),
                    _buildPermissionChip('Invite & Manage Staff', user.permissions.canInviteUsers),
                    _buildPermissionChip('Manage Subscription & Billing', user.permissions.canManageSubscription),
                    _buildPermissionChip('Activate & Deactivate Users', user.permissions.canActivateUsers),
                    _buildPermissionChip('Reassign Roles', user.permissions.canChangeUserRole),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // Account Security
                Text('Account & Security', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.sm),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 450) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(AppIcons.lock, color: AppColors.primary),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  'Password & Recovery',
                                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Update login credentials and two-factor authentication rules',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          OutlinedButton(
                            onPressed: () => Navigator.of(context).pushNamed(RouteNames.forgotPassword),
                            child: const Text('Change Password'),
                          ),
                        ],
                      );
                    }

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(AppIcons.lock, color: AppColors.primary),
                      title: const Text('Password & Recovery'),
                      subtitle: const Text('Update login credentials and two-factor authentication rules'),
                      trailing: OutlinedButton(
                        onPressed: () => Navigator.of(context).pushNamed(RouteNames.forgotPassword),
                        child: const Text('Change Password'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionChip(String label, bool isGranted) {
    return Chip(
      avatar: Icon(
        isGranted ? AppIcons.check : AppIcons.close,
        size: 14,
        color: isGranted ? AppColors.success : AppColors.textTertiary,
      ),
      label: Text(label),
      backgroundColor: isGranted ? AppColors.successContainer.withValues(alpha: 0.3) : AppColors.surfaceVariant,
      side: BorderSide(color: isGranted ? AppColors.success.withValues(alpha: 0.3) : AppColors.border),
      labelStyle: AppTypography.labelSmall.copyWith(
        color: isGranted ? AppColors.textPrimary : AppColors.textTertiary,
        fontWeight: isGranted ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  // TAB 2: Clinic Settings Form
  Widget _buildClinicProfileTab(bool canEdit, UserModel user, ClinicDetails? clinic, bool isLoading) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        final cardPadding = constraints.maxWidth < 400
            ? const EdgeInsets.all(AppSpacing.md)
            : (constraints.maxWidth < 600
                ? const EdgeInsets.all(AppSpacing.lg)
                : AppSpacing.paddingXl);

        return SingleChildScrollView(
          child: AppCard(
            padding: cardPadding,
            child: Form(
              key: _profileFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Clinic Profile Information', style: AppTypography.titleLarge),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Official practice details used on diagnostic reports and patient invoices.', style: AppTypography.bodyMedium),
                  const SizedBox(height: AppSpacing.lg),

                  AppTextField(
                    controller: _nameController,
                    label: 'Clinic Name *',
                    enabled: canEdit && !isLoading,
                    validator: AppValidators.clinicName,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  AppDropdown<String>(
                    label: 'Clinic Specialization *',
                    value: _selectedClinicType,
                    enabled: canEdit && !isLoading,
                    items: const [
                      DropdownMenuItem(value: 'Multi-Speciality Practice', child: Text('Multi-Speciality Practice')),
                      DropdownMenuItem(value: 'Solo Dental Practice', child: Text('Solo Dental Practice')),
                      DropdownMenuItem(value: 'Orthodontics Center', child: Text('Orthodontics Center')),
                      DropdownMenuItem(value: 'Oral Surgery & Hospital Unit', child: Text('Oral Surgery & Hospital Unit')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedClinicType = v);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  AppTextField(
                    controller: _addressController,
                    label: 'Address *',
                    enabled: canEdit && !isLoading,
                    validator: (v) => AppValidators.requiredField(v, 'Address'),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  if (!isNarrow)
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _cityController,
                            label: 'City *',
                            enabled: canEdit && !isLoading,
                            validator: (v) => AppValidators.requiredField(v, 'City'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AppTextField(
                            controller: _stateController,
                            label: 'State *',
                            enabled: canEdit && !isLoading,
                            validator: (v) => AppValidators.requiredField(v, 'State'),
                          ),
                        ),
                      ],
                    )
                  else ...[
                    AppTextField(
                      controller: _cityController,
                      label: 'City *',
                      enabled: canEdit && !isLoading,
                      validator: (v) => AppValidators.requiredField(v, 'City'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _stateController,
                      label: 'State *',
                      enabled: canEdit && !isLoading,
                      validator: (v) => AppValidators.requiredField(v, 'State'),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),

                  if (!isNarrow)
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _postalController,
                            label: 'Postal Code *',
                            enabled: canEdit && !isLoading,
                            validator: AppValidators.postalCode,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AppTextField(
                            controller: _countryController,
                            label: 'Country *',
                            enabled: canEdit && !isLoading,
                            validator: (v) => AppValidators.requiredField(v, 'Country'),
                          ),
                        ),
                      ],
                    )
                  else ...[
                    AppTextField(
                      controller: _postalController,
                      label: 'Postal Code *',
                      enabled: canEdit && !isLoading,
                      validator: AppValidators.postalCode,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _countryController,
                      label: 'Country *',
                      enabled: canEdit && !isLoading,
                      validator: (v) => AppValidators.requiredField(v, 'Country'),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),

                  if (!isNarrow)
                    Row(
                      children: [
                        Expanded(
                          child: AppPhoneField(
                            controller: _phoneController,
                            label: 'Clinic Phone *',
                            enabled: canEdit && !isLoading,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AppEmailField(
                            controller: _emailController,
                            label: 'Public Clinic Email *',
                            enabled: canEdit && !isLoading,
                          ),
                        ),
                      ],
                    )
                  else ...[
                    AppPhoneField(
                      controller: _phoneController,
                      label: 'Clinic Phone *',
                      enabled: canEdit && !isLoading,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppEmailField(
                      controller: _emailController,
                      label: 'Public Clinic Email *',
                      enabled: canEdit && !isLoading,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),

                  AppTextField(
                    controller: _websiteController,
                    label: 'Clinic Website (Optional)',
                    hint: 'https://apexdental.com',
                    enabled: canEdit && !isLoading,
                    validator: AppValidators.website,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  if (canEdit && clinic != null)
                    Align(
                      alignment: isNarrow ? Alignment.center : Alignment.centerRight,
                      child: PrimaryButton(
                        text: 'Save Clinic Profile',
                        isLoading: isLoading,
                        width: isNarrow ? null : 200,
                        icon: AppIcons.save,
                        onPressed: () => _saveProfile(user, clinic),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // TAB 3: Operational & AI Rules
  Widget _buildOperationalTab(bool canEdit, UserModel user, bool isLoading) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        final cardPadding = constraints.maxWidth < 400
            ? const EdgeInsets.all(AppSpacing.md)
            : (constraints.maxWidth < 600
                ? const EdgeInsets.all(AppSpacing.lg)
                : AppSpacing.paddingXl);

        return SingleChildScrollView(
          child: AppCard(
            padding: cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Operational & AI Scanning Policies', style: AppTypography.titleLarge),
                const SizedBox(height: AppSpacing.xs),
                Text('Configure practice timezone, daily capacity, and diagnostic access rules.', style: AppTypography.bodyMedium),
                const SizedBox(height: AppSpacing.lg),

                AppDropdown<String>(
                  label: 'Clinic Timezone *',
                  value: _selectedTimezone,
                  enabled: canEdit && !isLoading,
                  items: const [
                    DropdownMenuItem(value: 'UTC+05:30 (India Standard Time)', child: Text('UTC+05:30 (India Standard Time)')),
                    DropdownMenuItem(value: 'UTC+00:00 (Greenwich Mean Time)', child: Text('UTC+00:00 (Greenwich Mean Time)')),
                    DropdownMenuItem(value: 'UTC-05:00 (Eastern Time US)', child: Text('UTC-05:00 (Eastern Time US)')),
                    DropdownMenuItem(value: 'UTC+04:00 (Gulf Standard Time)', child: Text('UTC+04:00 (Gulf Standard Time)')),
                    DropdownMenuItem(value: 'UTC+08:00 (Singapore / HK)', child: Text('UTC+08:00 (Singapore / HK)')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedTimezone = v);
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                if (!isNarrow)
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: TextEditingController(text: _openingTime),
                          label: 'Opening Time',
                          enabled: canEdit && !isLoading,
                          onChanged: (v) => _openingTime = v,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppTextField(
                          controller: TextEditingController(text: _closingTime),
                          label: 'Closing Time',
                          enabled: canEdit && !isLoading,
                          onChanged: (v) => _closingTime = v,
                        ),
                      ),
                    ],
                  )
                else ...[
                  AppTextField(
                    controller: TextEditingController(text: _openingTime),
                    label: 'Opening Time',
                    enabled: canEdit && !isLoading,
                    onChanged: (v) => _openingTime = v,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: TextEditingController(text: _closingTime),
                    label: 'Closing Time',
                    enabled: canEdit && !isLoading,
                    onChanged: (v) => _closingTime = v,
                  ),
                ],
                const SizedBox(height: AppSpacing.md),

                SwitchListTile(
                  title: const Text('Automated Patient Reminders'),
                  subtitle: const Text('Dispatch SMS / WhatsApp appointment reminders before scheduled visits'),
                  value: _enableReminders,
                  onChanged: canEdit && !isLoading ? (v) => setState(() => _enableReminders = v) : null,
                  contentPadding: EdgeInsets.zero,
                ),
                const Divider(),

                SwitchListTile(
                  title: const Text('Allow Staff Patient Record Export'),
                  subtitle: const Text('Permit clinic staff members to download full patient radiological records'),
                  value: _allowExport,
                  onChanged: canEdit && !isLoading ? (v) => setState(() => _allowExport = v) : null,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: AppSpacing.xl),

                if (canEdit)
                  Align(
                    alignment: isNarrow ? Alignment.center : Alignment.centerRight,
                    child: PrimaryButton(
                      text: 'Save Operational Settings',
                      isLoading: isLoading,
                      width: isNarrow ? null : 240,
                      icon: AppIcons.successOutline,
                      onPressed: () => _saveOperationalSettings(user),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
