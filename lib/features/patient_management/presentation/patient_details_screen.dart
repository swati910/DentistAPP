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
import '../../../shared/models/medical_history_model.dart';
import '../../../shared/models/patient_model.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/widgets/cards/app_card.dart';
import '../../../shared/widgets/dialogs/confirmation_dialog.dart';
import '../../../shared/widgets/feedback/app_empty_state.dart';
import '../../../shared/widgets/feedback/app_error_state.dart';
import '../../../shared/widgets/feedback/app_loading.dart';
import '../../../shared/widgets/layouts/responsive_scaffold.dart';
import '../data/patient_repository.dart';
import '../view_model/patient_bloc.dart';
import '../view_model/patient_event.dart';
import '../view_model/patient_state.dart';
import 'widgets/add_clinical_note_dialog.dart';
import 'widgets/ai_scan_card.dart';
import 'widgets/dental_chart_view.dart';
import 'widgets/patient_medical_history_tab.dart';
import 'widgets/schedule_appointment_dialog.dart';

class PatientDetailsScreen extends StatelessWidget {
  final PatientModel? patient;
  final String? patientId;
  final UserModel? currentUser;

  const PatientDetailsScreen({
    super.key,
    this.patient,
    this.patientId,
    this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveId = patient?.id ?? patientId ?? 'pat-001';

    return BlocProvider(
      create: (context) => PatientBloc(
        repository: MockPatientRepository(),
      )..add(SelectPatientRequested(effectiveId)),
      child: _PatientDetailsView(
        initialPatient: patient,
        patientId: effectiveId,
        currentUser: currentUser,
      ),
    );
  }
}

class _PatientDetailsView extends StatefulWidget {
  final PatientModel? initialPatient;
  final String patientId;
  final UserModel? currentUser;

  const _PatientDetailsView({
    this.initialPatient,
    required this.patientId,
    this.currentUser,
  });

  @override
  State<_PatientDetailsView> createState() => _PatientDetailsViewState();
}

class _PatientDetailsViewState extends State<_PatientDetailsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final UserModel _defaultUser = const UserModel(
    id: 'usr-01',
    email: 'admin@apexdental.com',
    firstName: 'Elena',
    lastName: 'Rostova',
    role: UserRole.administrator,
    permissions: UserPermissions(canInviteUsers: true),
  );

  UserModel get _activeUser => widget.currentUser ?? _defaultUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openAddNoteDialog(BuildContext context, PatientModel patient) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AddClinicalNoteDialog(
        patientName: patient.fullName,
        onSave: (title, content) {
          context.read<PatientBloc>().add(
                AddClinicalNoteSubmitted(
                  patientId: patient.id,
                  title: title,
                  content: content,
                  currentUser: _activeUser,
                ),
              );
        },
      ),
    );
  }

  void _openScheduleDialog(BuildContext context, PatientModel patient) {
    showDialog(
      context: context,
      builder: (dialogCtx) => ScheduleAppointmentDialog(
        patientName: patient.fullName,
        defaultDentist: patient.assignedDentistName,
        onSchedule: (date, slot, procedure, dentist) {
          context.read<PatientBloc>().add(
                ScheduleAppointmentSubmitted(
                  patientId: patient.id,
                  date: date,
                  timeSlot: slot,
                  procedure: procedure,
                  dentistName: dentist,
                  currentUser: _activeUser,
                ),
              );
        },
      ),
    );
  }

  void _confirmArchivePatient(BuildContext context, PatientModel patient) {
    showDialog(
      context: context,
      builder: (dialogCtx) => ConfirmationDialog(
        title: 'Archive Patient Record',
        message: 'Are you sure you want to archive ${patient.fullName} (${patient.patientNumber})? The record will remain accessible under archived filters.',
        confirmText: 'Archive Record',
        isDestructive: true,
        onConfirm: () {
          Navigator.of(dialogCtx).pop();
          context.read<PatientBloc>().add(
                ArchivePatientRequested(
                  patientId: patient.id,
                  currentUser: _activeUser,
                ),
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return ResponsiveScaffold(
      title: 'Patient Profile',
      currentRoute: RouteNames.patients,
      showDrawer: false,
      actions: [
        IconButton(
          icon: const Icon(AppIcons.back),
          tooltip: 'Back to Patients',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      body: BlocConsumer<PatientBloc, PatientState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.status == Status.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!), backgroundColor: AppColors.error),
            );
          }
          if (state.isActionSuccess && state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!), backgroundColor: AppColors.success),
            );
          }
        },
        builder: (context, state) {
          final patient = state.selectedPatient ?? widget.initialPatient;

          if (state.status == Status.loading && patient == null) {
            return const Center(child: AppLoading(message: 'Loading patient records...'));
          }

          if (state.status == Status.error && patient == null) {
            return Center(
              child: AppErrorState(
                title: 'Unable to Load Patient Profile',
                message: state.errorMessage ?? 'Patient record not found.',
                onRetry: () => context.read<PatientBloc>().add(SelectPatientRequested(widget.patientId)),
              ),
            );
          }

          if (patient == null) {
            return const Center(
              child: AppEmptyState(
                title: 'Patient Record Not Found',
                message: 'No patient record matches the provided identifier.',
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderHero(context, patient, isDesktop),
              const SizedBox(height: AppSpacing.lg),
              _buildTabBar(),
              const SizedBox(height: AppSpacing.lg),
              _buildTabContent(context, patient, isDesktop),
              const SizedBox(height: AppSpacing.xxl),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderHero(BuildContext context, PatientModel patient, bool isDesktop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;

        return AppCard(
          padding: EdgeInsets.all(isNarrow ? AppSpacing.md : AppSpacing.lg),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: isNarrow ? 26 : 36,
                    backgroundColor: AppColors.primaryContainer,
                    child: Text(
                      patient.initials,
                      style: (isNarrow ? AppTypography.titleMedium : AppTypography.headlineMedium).copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: isNarrow ? AppSpacing.md : AppSpacing.lg),
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
                              patient.fullName,
                              style: (isNarrow ? AppTypography.titleLarge : AppTypography.headlineSmall)
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: AppSpacing.borderRadiusSm,
                              ),
                              child: Text(
                                patient.patientNumber,
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: patient.status.color.withAlpha(25),
                                borderRadius: AppSpacing.borderRadiusSm,
                                border: Border.all(color: patient.status.color.withAlpha(60)),
                              ),
                              child: Text(
                                patient.status.displayName,
                                style: AppTypography.labelSmall.copyWith(
                                  color: patient.status.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isNarrow)
                              _buildCompactRiskBadge(patient.riskLevel),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              '${patient.age} yrs (${DateFormat('MMM dd, yyyy').format(patient.dateOfBirth)})',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                            ),
                            Text('•', style: TextStyle(color: AppColors.textTertiary)),
                            Text(
                              patient.gender.displayName,
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                            ),
                            Text('•', style: TextStyle(color: AppColors.textTertiary)),
                            Text(
                              'Blood: ${patient.bloodGroup}',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                            ),
                            Text('•', style: TextStyle(color: AppColors.textTertiary)),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(AppIcons.phone, size: 14, color: AppColors.textTertiary),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    patient.phone,
                                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (patient.allergies.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.errorContainer,
                              borderRadius: AppSpacing.borderRadiusSm,
                              border: Border.all(color: AppColors.error.withAlpha(60)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.error),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'CRITICAL ALLERGY ALERT: ${patient.allergies.join(", ")}',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!isNarrow) ...[
                    const SizedBox(width: AppSpacing.xs),
                    _buildRiskIndicator(patient.riskLevel),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const Divider(),
              const SizedBox(height: AppSpacing.sm),

              // Action Toolbar
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                alignment: WrapAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _openScheduleDialog(context, patient),
                    icon: const Icon(Icons.calendar_today_rounded, size: 16),
                    label: const Text('Book Appointment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _openAddNoteDialog(context, patient),
                    icon: const Icon(Icons.note_add_outlined, size: 16),
                    label: const Text('Add Note'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final bloc = context.read<PatientBloc>();
                      final result = await Navigator.of(context).pushNamed(
                        RouteNames.editPatient,
                        arguments: patient,
                      );
                      if (result == true) {
                        bloc.add(SelectPatientRequested(patient.id));
                      }
                    },
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit Profile'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _confirmArchivePatient(context, patient),
                    icon: const Icon(Icons.archive_outlined, size: 16),
                    label: const Text('Archive'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRiskIndicator(PatientRiskLevel risk) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: risk.containerColor,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: risk.color.withAlpha(80)),
      ),
      child: Column(
        children: [
          Icon(Icons.shield_outlined, color: risk.color, size: 24),
          const SizedBox(height: 2),
          Text(
            risk.displayName,
            style: AppTypography.labelSmall.copyWith(
              color: risk.color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactRiskBadge(PatientRiskLevel risk) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: risk.containerColor,
        borderRadius: AppSpacing.borderRadiusSm,
        border: Border.all(color: risk.color.withAlpha(80)),
      ),
      child: Text(
        risk.displayName.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          color: risk.color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusSm,
        border: Border.all(color: AppColors.border),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        tabs: const [
          Tab(icon: Icon(Icons.badge_outlined), text: 'Overview'),
          Tab(icon: Icon(Icons.healing_outlined), text: 'Medical History'),
          Tab(icon: Icon(Icons.psychology_alt_outlined), text: 'AI Vision Insights'),
          Tab(icon: Icon(Icons.grid_view_rounded), text: 'Dental Odontogram'),
          Tab(icon: Icon(Icons.event_available_rounded), text: 'Appointments & Visits'),
          Tab(icon: Icon(Icons.speaker_notes_outlined), text: 'Clinical Notes'),
        ],
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, PatientModel patient, bool isDesktop) {
    return SizedBox(
      height: 720,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(patient, isDesktop),
          PatientMedicalHistoryTab(
            patient: patient,
            currentUser: _activeUser,
            onEditRequested: () async {
              final updated = await Navigator.of(context).pushNamed(
                RouteNames.editPatient,
                arguments: patient,
              );
              if (!context.mounted) return;
              if (updated is PatientModel) {
                context.read<PatientBloc>().add(SelectPatientRequested(patient.id));
              }
            },
          ),
          _buildAiVisionTab(patient),
          _buildOdontogramTab(patient),
          _buildAppointmentsTab(context, patient),
          _buildClinicalNotesTab(context, patient),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(PatientModel patient, bool isDesktop) {
    return SingleChildScrollView(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isTabletOrDesktop = constraints.maxWidth >= 768;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Chief Complaint & Medical Alerts
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.medical_services_outlined, color: AppColors.primary, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text('Chief Dental Complaint', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      patient.chiefComplaint.isNotEmpty ? patient.chiefComplaint : 'Routine comprehensive dental checkup and prophylactic cleaning.',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Row 2: Medical Summary & Attending Clinical Care Team (Insurance removed)
              if (isTabletOrDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildMedicalConditionsCard(patient)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _buildClinicalCareTeamCard(patient)),
                  ],
                )
              else
                Column(
                  children: [
                    _buildMedicalConditionsCard(patient),
                    const SizedBox(height: AppSpacing.md),
                    _buildClinicalCareTeamCard(patient),
                  ],
                ),
              const SizedBox(height: AppSpacing.md),

              // Row 3: Address & Emergency Contact
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: constraints.maxWidth >= 600
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildAddressColumn(patient)),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(child: _buildEmergencyContactColumn(patient)),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAddressColumn(patient),
                          const SizedBox(height: AppSpacing.md),
                          _buildEmergencyContactColumn(patient),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMedicalConditionsCard(PatientModel patient) {
    final medHistory = patient.resolvedMedicalHistory;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Medical & Allergy Summary',
                  style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: medHistory.allergyStatus.containerColor,
                  borderRadius: AppSpacing.borderRadiusSm,
                  border: Border.all(color: medHistory.allergyStatus.color.withAlpha(80)),
                ),
                child: Text(
                  medHistory.allergyStatus == AllergyStatus.recorded
                      ? '${medHistory.allergies.length} ALLERGIES'
                      : (medHistory.allergyStatus == AllergyStatus.noKnownAllergies ? 'NKA' : 'UNREVIEWED'),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: medHistory.allergyStatus.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (medHistory.allergies.isNotEmpty) ...[
            Text('Allergies: ', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: medHistory.allergies
                  .map((a) => Chip(
                        label: Text(a.substance, style: const TextStyle(fontSize: 11)),
                        backgroundColor: AppColors.errorContainer.withAlpha(60),
                        side: BorderSide(color: AppColors.error.withAlpha(60)),
                      ))
                  .toList(),
            ),
          ] else ...[
            Text(
              medHistory.allergyStatus == AllergyStatus.noKnownAllergies
                  ? 'No known allergies reported (confirmed).'
                  : 'Allergy history not recorded / pending triage.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary, fontStyle: FontStyle.italic),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Text('Chronic Conditions', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.xs),
          if (patient.chronicConditions.isEmpty)
            Text('None reported by patient.', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary))
          else
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: patient.chronicConditions
                  .map((c) => Chip(
                        label: Text(c, style: const TextStyle(fontSize: 11)),
                        backgroundColor: AppColors.warningContainer.withAlpha(60),
                        side: BorderSide(color: AppColors.warning.withAlpha(60)),
                      ))
                  .toList(),
            ),
          const SizedBox(height: AppSpacing.md),
          TextButton.icon(
            onPressed: () => _tabController.animateTo(1),
            icon: const Icon(Icons.arrow_forward, size: 14),
            label: const Text('Open Medical History Tab'),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalCareTeamCard(PatientModel patient) {
    final dateFormat = DateFormat('EEE, MMM dd, yyyy');

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('Attending Clinical Team', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Text(
                  'DENTAL CARE TEAM',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            patient.assignedDentistName ?? 'Unassigned Dental Practitioner',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
          Text(
            'Lead Attending Dentist & Treatment Coordinator',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Next Scheduled Appointment', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            patient.nextAppointmentDate != null
                ? dateFormat.format(patient.nextAppointmentDate!)
                : 'No upcoming visits scheduled',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => _tabController.animateTo(1),
            icon: const Icon(Icons.healing_outlined, size: 16),
            label: const Text('View Full Medical History'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(40),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressColumn(PatientModel patient) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Residential Address', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${patient.address}, ${patient.city}, ${patient.state} - ${patient.postalCode}',
          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildEmergencyContactColumn(PatientModel patient) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Emergency Contact', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${patient.emergencyContactName} (${patient.emergencyRelationship}) • ${patient.emergencyContactPhone}',
          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildAiVisionTab(PatientModel patient) {
    if (patient.aiScans.isEmpty) {
      return const AppEmptyState(
        title: 'No AI Radiograph Scans Yet',
        message: 'Upload bitewing, panoramic OPG, or periapical x-rays to generate instant AI pathology detections.',
        icon: Icons.psychology_alt_outlined,
      );
    }

    return ListView.separated(
      itemCount: patient.aiScans.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final scan = patient.aiScans[index];
        return AiScanCard(scan: scan);
      },
    );
  }

  Widget _buildOdontogramTab(PatientModel patient) {
    return SingleChildScrollView(
      child: Column(
        children: [
          DentalChartView(teethRecords: patient.teethRecords),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTab(BuildContext context, PatientModel patient) {
    final dateFormat = DateFormat('EEEE, MMMM dd, yyyy');

    if (patient.appointments.isEmpty) {
      return AppEmptyState(
        title: 'No Scheduled Appointments',
        message: 'Patient currently has no active or past appointment records.',
        actionText: 'Book Chair Appointment',
        onAction: () => _openScheduleDialog(context, patient),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              Text(
                'Clinical Chair Sessions (${patient.appointments.length})',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _openScheduleDialog(context, patient),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Schedule Visit'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: patient.appointments.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final apt = patient.appointments[index];
              final isScheduled = apt.status == 'Scheduled';

              return AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isScheduled ? AppColors.primaryContainer : AppColors.surfaceVariant,
                        borderRadius: AppSpacing.borderRadiusSm,
                      ),
                      child: Icon(
                        isScheduled ? Icons.event_available_rounded : Icons.check_circle_outline_rounded,
                        color: isScheduled ? AppColors.primary : AppColors.textTertiary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  apt.procedure,
                                  style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isScheduled ? AppColors.primaryContainer : AppColors.successContainer,
                                  borderRadius: AppSpacing.borderRadiusSm,
                                ),
                                child: Text(
                                  apt.status,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: isScheduled ? AppColors.primary : AppColors.success,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${dateFormat.format(apt.date)} • ${apt.timeSlot}',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                          ),
                          Text(
                            'Attending Dentist: ${apt.dentistName}',
                            style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary),
                          ),
                          if (apt.notes != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Remarks: ${apt.notes}',
                              style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalNotesTab(BuildContext context, PatientModel patient) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    if (patient.clinicalNotes.isEmpty) {
      return AppEmptyState(
        title: 'No Clinical Notes Recorded',
        message: 'Document diagnostic notes, restorative observations, and treatment records.',
        actionText: 'Add Clinical Note',
        onAction: () => _openAddNoteDialog(context, patient),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              Text(
                'Practitioner Clinical Remarks (${patient.clinicalNotes.length})',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _openAddNoteDialog(context, patient),
                icon: const Icon(Icons.note_add_outlined, size: 16),
                label: const Text('Add Clinical Note'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: patient.clinicalNotes.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final note = patient.clinicalNotes[index];

              return AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  note.title,
                                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (note.isFlagged) ...[
                                const SizedBox(width: AppSpacing.sm),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.errorContainer,
                                    borderRadius: AppSpacing.borderRadiusSm,
                                  ),
                                  child: Text(
                                    'FLAGGED',
                                    style: AppTypography.labelSmall.copyWith(color: AppColors.error, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          dateFormat.format(note.date),
                          style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Recorded by ${note.authorName} (${note.authorRole})',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Divider(),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      note.content,
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
