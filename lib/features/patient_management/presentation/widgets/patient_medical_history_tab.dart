import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/models/medical_history_model.dart';
import '../../../../shared/models/patient_model.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/dialogs/confirmation_dialog.dart';
import '../../view_model/patient_bloc.dart';
import '../../view_model/patient_event.dart';
import 'allergy_status_dialog.dart';
import 'medical_history_audit_trail_dialog.dart';
import 'medical_history_details_dialog.dart';
import 'medical_history_form_dialog.dart';

class PatientMedicalHistoryTab extends StatelessWidget {
  final PatientModel patient;
  final UserModel? currentUser;
  final VoidCallback? onEditRequested;

  const PatientMedicalHistoryTab({
    super.key,
    required this.patient,
    this.currentUser,
    this.onEditRequested,
  });

  UserModel get _activeUser =>
      currentUser ??
      const UserModel(
        id: 'usr-default',
        email: 'dentist@apexdental.com',
        firstName: 'Dr. Marcus',
        lastName: 'Vance',
        role: UserRole.dentist,
        permissions: UserPermissions(canEditMedicalHistory: true),
      );

  bool get _canManage => _activeUser.canManageMedicalHistory;

  @override
  Widget build(BuildContext context) {
    final medHistory = patient.resolvedMedicalHistory;

    return SingleChildScrollView(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 768;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Action Toolbar
              _buildTopHeaderToolbar(context, medHistory, isNarrow),
              const SizedBox(height: AppSpacing.md),

              // 1. Critical Allergy Alert Banner & Details
              _buildAllergySection(context, medHistory, isNarrow),
              const SizedBox(height: AppSpacing.lg),

              // 2. Existing Medical Conditions
              _buildConditionsSection(context, medHistory, isNarrow),
              const SizedBox(height: AppSpacing.lg),

              // 3. Current & Historical Medications
              _buildMedicationsSection(context, medHistory, isNarrow),
              const SizedBox(height: AppSpacing.lg),

              // 4. Past Medical & Surgical History
              _buildPastSurgicalSection(context, medHistory, isNarrow),
              const SizedBox(height: AppSpacing.lg),

              // 5. Dental Precedents & Oral Health History
              _buildDentalHistorySection(context, medHistory, isNarrow),
              const SizedBox(height: AppSpacing.lg),

              // 6. Additional Medical & Lifestyle Information
              _buildAdditionalInfoSection(context, medHistory, isNarrow),
              const SizedBox(height: AppSpacing.lg),

              // 7. Clinical Review Verification Footer
              _buildReviewFooter(context, medHistory),
              const SizedBox(height: AppSpacing.xl),
            ],
          );
        },
      ),
    );
  }

  // ==========================================
  // TOP ACTION TOOLBAR
  // ==========================================
  Widget _buildTopHeaderToolbar(
    BuildContext context,
    MedicalHistoryModel medHistory,
    bool isNarrow,
  ) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.sm,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.medical_information_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Clinical Medical Record',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              if (!_canManage) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: AppSpacing.borderRadiusSm,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    'READ-ONLY',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              if (_canManage)
                ElevatedButton.icon(
                  onPressed: () => _openAddMedicalRecordDialog(context),
                  icon: const Icon(Icons.add_circle_outline, size: 16),
                  label: const Text('Add Medical History'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              OutlinedButton.icon(
                onPressed: () => _openAllergyStatusDialog(context, medHistory),
                icon: const Icon(Icons.verified_user_outlined, size: 16),
                label: const Text('Allergy Status'),
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _openAuditTrailDialog(context, medHistory),
                icon: const Icon(Icons.history_edu_outlined, size: 16),
                label: Text('Audit Trail (${medHistory.auditTrail.length})'),
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 1: ALLERGIES
  // ==========================================
  Widget _buildAllergySection(
    BuildContext context,
    MedicalHistoryModel medHistory,
    bool isNarrow,
  ) {
    final status = medHistory.allergyStatus;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderColor: status == AllergyStatus.recorded
          ? AppColors.error.withAlpha(120)
          : (status == AllergyStatus.noKnownAllergies
              ? AppColors.success.withAlpha(120)
              : AppColors.warning.withAlpha(120)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: status.containerColor,
              borderRadius: AppSpacing.borderRadiusSm,
              border: Border.all(color: status.color.withAlpha(90)),
            ),
            child: Row(
              children: [
                Icon(
                  status == AllergyStatus.recorded
                      ? Icons.warning_rounded
                      : (status == AllergyStatus.noKnownAllergies
                          ? Icons.check_circle_outline_rounded
                          : Icons.help_outline_rounded),
                  color: status.color,
                  size: 22,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status.displayName.toUpperCase(),
                        style: AppTypography.labelMedium.copyWith(
                          color: status.color,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        status == AllergyStatus.recorded
                            ? 'Patient has ${medHistory.allergies.length} documented clinical allergies. Review reactions and contraindicated drugs prior to treatment.'
                            : (status == AllergyStatus.noKnownAllergies
                                ? 'Patient explicitly confirmed No Known Allergies during clinical triage.'
                                : 'Allergy history has not been confirmed for this patient. Verify with patient or guardian before administering antibiotics, anesthetics, or materials.'),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_canManage)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    tooltip: 'Change Allergy Status',
                    onPressed: () => _openAllergyStatusDialog(context, medHistory),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Header Row with Add Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.emergency_outlined, color: AppColors.error, size: 20),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Documented Medical Allergies',
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (_canManage)
                OutlinedButton.icon(
                  onPressed: () => _openAddAllergyDialog(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Allergy'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: AppColors.error,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          if (medHistory.allergies.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withAlpha(60),
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Row(
                children: [
                  Icon(
                    status == AllergyStatus.noKnownAllergies
                        ? Icons.verified_rounded
                        : Icons.info_outline_rounded,
                    color: status == AllergyStatus.noKnownAllergies ? AppColors.success : AppColors.textTertiary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      status == AllergyStatus.noKnownAllergies
                          ? 'No adverse drug or substance allergies currently recorded in patient chart.'
                          : 'No allergy records logged. Triage review required.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: medHistory.allergies.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final allergy = medHistory.allergies[index];
                return _buildAllergyItemCard(context, allergy, isNarrow);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAllergyItemCard(BuildContext context, MedicalAllergyItem allergy, bool isNarrow) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withAlpha(50),
        borderRadius: AppSpacing.borderRadiusSm,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.sm,
                  runSpacing: 4,
                  children: [
                    Text(
                      allergy.substance,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: AppSpacing.borderRadiusSm,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        allergy.category.displayName,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: allergy.severity.badgeColor.withAlpha(25),
                        borderRadius: AppSpacing.borderRadiusSm,
                        border: Border.all(color: allergy.severity.badgeColor.withAlpha(80)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shield_rounded, size: 12, color: allergy.severity.badgeColor),
                          const SizedBox(width: 4),
                          Text(
                            allergy.severity.displayName.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: allergy.severity.badgeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Action Buttons
              _buildCardActions(
                onView: () => _openViewAllergyDetails(context, allergy),
                onEdit: _canManage ? () => _openEditAllergyDialog(context, allergy) : null,
                onDelete: _canManage
                    ? () => _confirmDelete(
                          context,
                          title: 'Delete Allergy Record',
                          message: 'Are you sure you want to remove the allergy record for "${allergy.substance}"? This action will be logged in the clinical audit trail.',
                          onConfirm: () {
                            context.read<PatientBloc>().add(
                                  DeleteMedicalAllergySubmitted(
                                    patientId: patient.id,
                                    allergyId: allergy.effectiveId,
                                    currentUser: _activeUser,
                                  ),
                                );
                          },
                        )
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clinical Reaction: ',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Expanded(
                child: Text(
                  allergy.reaction,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          if (allergy.diagnosedDate != null && allergy.diagnosedDate!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Diagnosed / First Observed: ${allergy.diagnosedDate}',
              style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary),
            ),
          ],
          if (allergy.clinicalNotes != null && allergy.clinicalNotes!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.errorContainer.withAlpha(40),
                borderRadius: AppSpacing.borderRadiusSm,
                border: Border.all(color: AppColors.error.withAlpha(40)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 14, color: AppColors.error),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Precaution: ${allergy.clinicalNotes}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 2: MEDICAL CONDITIONS
  // ==========================================
  Widget _buildConditionsSection(
    BuildContext context,
    MedicalHistoryModel medHistory,
    bool isNarrow,
  ) {
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
                    const Icon(Icons.healing_outlined, color: AppColors.primary, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Existing Medical & Systemic Conditions',
                        style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              if (_canManage)
                OutlinedButton.icon(
                  onPressed: () => _openAddConditionDialog(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Condition'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Chronic systemic illnesses requiring clinical vigilance during dental surgery, local anesthesia, or restorative treatment.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),

          if (medHistory.medicalConditions.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withAlpha(60),
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Text(
                'No chronic medical conditions currently documented for this patient.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: medHistory.medicalConditions.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final condition = medHistory.medicalConditions[index];
                return _buildConditionCard(context, condition, isNarrow);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConditionCard(BuildContext context, MedicalConditionItem condition, bool isNarrow) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withAlpha(50),
        borderRadius: AppSpacing.borderRadiusSm,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.sm,
                  children: [
                    Text(
                      condition.name,
                      style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: condition.status.color.withAlpha(25),
                        borderRadius: AppSpacing.borderRadiusSm,
                        border: Border.all(color: condition.status.color.withAlpha(70)),
                      ),
                      child: Text(
                        condition.status.displayName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: condition.status.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildCardActions(
                onView: () => _openViewConditionDetails(context, condition),
                onEdit: _canManage ? () => _openEditConditionDialog(context, condition) : null,
                onDelete: _canManage
                    ? () => _confirmDelete(
                          context,
                          title: 'Delete Medical Condition',
                          message: 'Are you sure you want to remove "${condition.name}" from the patient\'s active records? This will be logged in the audit trail.',
                          onConfirm: () {
                            context.read<PatientBloc>().add(
                                  DeleteMedicalConditionSubmitted(
                                    patientId: patient.id,
                                    conditionId: condition.effectiveId,
                                    currentUser: _activeUser,
                                  ),
                                );
                          },
                        )
                    : null,
              ),
            ],
          ),
          if (condition.dateDiagnosed != null && condition.dateDiagnosed!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Onset / Diagnosed: ${condition.dateDiagnosed}',
              style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary),
            ),
          ],
          if (condition.clinicalNotes != null && condition.clinicalNotes!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              condition.clinicalNotes!,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
          if (condition.requiresDentalPremedication) ...[
            const SizedBox(height: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warningContainer,
                borderRadius: AppSpacing.borderRadiusSm,
                border: Border.all(color: AppColors.warning),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shield_outlined, size: 14, color: AppColors.warning),
                  const SizedBox(width: 6),
                  Text(
                    'ANTIBIOTIC PREMEDICATION REQUIRED BEFORE INVASIVE PROCEDURES',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 3: MEDICATIONS
  // ==========================================
  Widget _buildMedicationsSection(
    BuildContext context,
    MedicalHistoryModel medHistory,
    bool isNarrow,
  ) {
    final currentMeds = medHistory.currentMedications;
    final historicalMeds = medHistory.historicalMedications;

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
                    const Icon(Icons.medication_outlined, color: AppColors.primary, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Current & Prescribed Medications',
                        style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              if (_canManage)
                OutlinedButton.icon(
                  onPressed: () => _openAddMedicationDialog(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Medication'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Prescription drugs, anticoagulants, over-the-counter supplements, and active pharmacotherapy.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),

          // Current Medications
          Text(
            'Currently Active Medications (${currentMeds.length})',
            style: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          if (currentMeds.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withAlpha(60),
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Text(
                'No currently active medications reported by patient.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: currentMeds.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.xs),
              itemBuilder: (context, index) {
                final med = currentMeds[index];
                return _buildMedicationCard(context, med, isNarrow, isHistorical: false);
              },
            ),
          ],

          if (historicalMeds.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'Discontinued & Past Medications (${historicalMeds.length})',
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: historicalMeds.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.xs),
              itemBuilder: (context, index) {
                final med = historicalMeds[index];
                return _buildMedicationCard(context, med, isNarrow, isHistorical: true);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMedicationCard(
    BuildContext context,
    MedicationItem med,
    bool isNarrow, {
    bool isHistorical = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isHistorical ? AppColors.surfaceVariant.withAlpha(30) : AppColors.surfaceVariant.withAlpha(60),
        borderRadius: AppSpacing.borderRadiusSm,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.sm,
                  runSpacing: 4,
                  children: [
                    Text(
                      med.name,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isHistorical ? AppColors.textSecondary : AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: AppSpacing.borderRadiusSm,
                      ),
                      child: Text(
                        '${med.dosage} • ${med.frequency}',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isHistorical ? AppColors.surfaceVariant : AppColors.successContainer,
                        borderRadius: AppSpacing.borderRadiusSm,
                      ),
                      child: Text(
                        isHistorical ? 'DISCONTINUED' : 'ACTIVE',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isHistorical ? AppColors.textTertiary : AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildCardActions(
                onView: () => _openViewMedicationDetails(context, med),
                onEdit: _canManage ? () => _openEditMedicationDialog(context, med) : null,
                onDelete: _canManage
                    ? () => _confirmDelete(
                          context,
                          title: 'Delete Medication Record',
                          message: 'Are you sure you want to remove "${med.name}" from the patient\'s medication record? This will be logged in the audit trail.',
                          onConfirm: () {
                            context.read<PatientBloc>().add(
                                  DeleteMedicationSubmitted(
                                    patientId: patient.id,
                                    medicationId: med.effectiveId,
                                    currentUser: _activeUser,
                                  ),
                                );
                          },
                        )
                    : null,
              ),
            ],
          ),
          if (med.prescribingPhysician != null && med.prescribingPhysician!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Prescribing Doctor: ${med.prescribingPhysician}',
              style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
          if (med.notes != null && med.notes!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Clinical Notes: ${med.notes}',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 4: PAST MEDICAL & SURGICAL HISTORY
  // ==========================================
  Widget _buildPastSurgicalSection(
    BuildContext context,
    MedicalHistoryModel medHistory,
    bool isNarrow,
  ) {
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
                    const Icon(Icons.local_hospital_outlined, color: AppColors.primary, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Past Medical & Surgical History',
                        style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              if (_canManage)
                OutlinedButton.icon(
                  onPressed: () => _openAddPastHistoryDialog(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Procedure / Event'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Previous surgical procedures, inpatient hospitalizations, and major medical interventions.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),

          if (medHistory.pastMedicalHistory.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withAlpha(60),
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Text(
                'No past surgeries or hospitalizations documented in patient chart.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: medHistory.pastMedicalHistory.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final item = medHistory.pastMedicalHistory[index];
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withAlpha(50),
                    borderRadius: AppSpacing.borderRadiusSm,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: AppSpacing.sm,
                              children: [
                                Text(
                                  item.event,
                                  style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer,
                                    borderRadius: AppSpacing.borderRadiusSm,
                                  ),
                                  child: Text(
                                    item.type.toUpperCase(),
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildCardActions(
                            onView: () => _openViewPastHistoryDetails(context, item),
                            onEdit: _canManage ? () => _openEditPastHistoryDialog(context, item) : null,
                            onDelete: _canManage
                                ? () => _confirmDelete(
                                      context,
                                      title: 'Delete Past History Item',
                                      message: 'Are you sure you want to remove "${item.event}"? This will be logged in the audit trail.',
                                      onConfirm: () {
                                        context.read<PatientBloc>().add(
                                              DeletePastMedicalHistorySubmitted(
                                                patientId: patient.id,
                                                itemId: item.effectiveId,
                                                currentUser: _activeUser,
                                              ),
                                            );
                                      },
                                    )
                                : null,
                          ),
                        ],
                      ),
                      if (item.approximateDate != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Date / Period: ${item.approximateDate}${item.facility != null ? ' • ${item.facility}' : ''}',
                          style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                      if (item.notes != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.notes!,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 5: DENTAL HISTORY
  // ==========================================
  Widget _buildDentalHistorySection(
    BuildContext context,
    MedicalHistoryModel medHistory,
    bool isNarrow,
  ) {
    final dental = medHistory.dentalHistory;

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
                    const Icon(Icons.medical_services_outlined, color: AppColors.primary, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Dental History & Precedents',
                        style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              if (_canManage)
                OutlinedButton.icon(
                  onPressed: () => _openEditDentalHistoryDialog(context, dental),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit Dental History'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Prior restorative procedures, past dental complications, and baseline oral hygiene habits.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),

          // Previous procedures
          Text(
            'Previous Dental Procedures',
            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          if (dental.previousProcedures.isEmpty)
            Text(
              'No prior restorative records documented.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
            )
          else
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: dental.previousProcedures
                  .map((p) => Chip(
                        label: Text(p, style: const TextStyle(fontSize: 12)),
                        backgroundColor: AppColors.primaryContainer.withAlpha(50),
                        side: BorderSide(color: AppColors.primary.withAlpha(40)),
                      ))
                  .toList(),
            ),
          const SizedBox(height: AppSpacing.md),

          // Oral Health Concerns
          Text(
            'Oral Health Concerns & Symptoms',
            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          if (dental.oralHealthConcerns.isEmpty)
            Text(
              'No active concerns reported.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
            )
          else
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: dental.oralHealthConcerns
                  .map((c) => Chip(
                        label: Text(c, style: const TextStyle(fontSize: 12)),
                        backgroundColor: AppColors.warningContainer.withAlpha(40),
                        side: BorderSide(color: AppColors.warning.withAlpha(70)),
                      ))
                  .toList(),
            ),
          const SizedBox(height: AppSpacing.md),

          // Dental Complications
          if (dental.treatmentComplications.isNotEmpty) ...[
            Text(
              'Past Treatment Complications',
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 4),
            ...dental.treatmentComplications.map((comp) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.report_problem_outlined, size: 16, color: AppColors.error),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        comp,
                        style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: AppSpacing.md),
          ],

          // Daily Hygiene habits
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withAlpha(40),
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Brushing Routine', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold)),
                      Text(dental.brushingFrequency ?? 'Twice daily', style: AppTypography.bodySmall),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Flossing Routine', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold)),
                      Text(dental.flossingFrequency ?? 'Daily', style: AppTypography.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 6: ADDITIONAL CLINICAL & LIFESTYLE INFO
  // ==========================================
  Widget _buildAdditionalInfoSection(
    BuildContext context,
    MedicalHistoryModel medHistory,
    bool isNarrow,
  ) {
    final additional = medHistory.additionalInfo;

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
                    const Icon(Icons.family_restroom_outlined, color: AppColors.primary, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Family Medical History & Lifestyle Factors',
                        style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              if (_canManage)
                OutlinedButton.icon(
                  onPressed: () => _openEditAdditionalInfoDialog(context, additional),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit Family & Lifestyle'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Family history
          Text(
            'Hereditary Systemic Conditions',
            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          if (additional.familyMedicalHistory.isEmpty)
            Text(
              'No significant hereditary systemic illnesses reported.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
            )
          else
            ...additional.familyMedicalHistory.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  children: [
                    const Icon(Icons.fiber_manual_record, size: 8, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item, style: AppTypography.bodySmall),
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: AppSpacing.md),

          // Lifestyle factors
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withAlpha(50),
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tobacco / Smoking', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(
                        additional.smokingStatus ?? 'Non-smoker',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withAlpha(50),
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Alcohol Use', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(
                        additional.alcoholConsumption ?? 'Non-drinker',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: additional.hasBleedingDisorder
                        ? AppColors.errorContainer
                        : AppColors.surfaceVariant.withAlpha(50),
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bleeding Tendency', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(
                        additional.hasBleedingDisorder
                            ? 'ALERT: Bleeding disorder recorded'
                            : 'Negative (Normal clotting history)',
                        style: AppTypography.bodySmall.copyWith(
                          color: additional.hasBleedingDisorder ? AppColors.error : AppColors.textPrimary,
                          fontWeight: additional.hasBleedingDisorder ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (additional.pregnancyStatus != null && additional.pregnancyStatus!.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withAlpha(40),
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pregnancy Status', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(additional.pregnancyStatus!, style: AppTypography.bodySmall),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (additional.generalNotes != null && additional.generalNotes!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'General Remarks: ${additional.generalNotes}',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 7: CLINICAL REVIEW FOOTER
  // ==========================================
  Widget _buildReviewFooter(BuildContext context, MedicalHistoryModel medHistory) {
    final dateFormat = DateFormat('MMMM dd, yyyy • hh:mm a');
    final reviewedDate = medHistory.lastReviewedDate ??
        medHistory.additionalInfo.lastReviewedDate ??
        DateTime.now().subtract(const Duration(days: 14));
    final doctor = medHistory.reviewedByClinicianName ??
        medHistory.additionalInfo.reviewedByDoctor ??
        patient.assignedDentistName ??
        'Dr. Marcus Vance, BDS, MDS';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withAlpha(50),
        borderRadius: AppSpacing.borderRadiusSm,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user_outlined, color: AppColors.primary, size: 24),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Clinically Reviewed by $doctor',
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Record Last Updated: ${dateFormat.format(reviewedDate)} • HIPAA Encrypted Health Information',
                  style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (_canManage)
            TextButton.icon(
              onPressed: () => _openAddMedicalRecordDialog(context),
              icon: const Icon(Icons.add_circle_outline, size: 16),
              label: const Text('Add Clinical Entry'),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // ROW ACTIONS HELPER
  // ==========================================
  Widget _buildCardActions({
    required VoidCallback onView,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.visibility_outlined, size: 18),
          tooltip: 'View Details',
          visualDensity: VisualDensity.compact,
          onPressed: onView,
        ),
        if (onEdit != null)
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            tooltip: 'Edit Record',
            visualDensity: VisualDensity.compact,
            onPressed: onEdit,
          ),
        if (onDelete != null)
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
            tooltip: 'Delete Record',
            visualDensity: VisualDensity.compact,
            onPressed: onDelete,
          ),
      ],
    );
  }

  // ==========================================
  // DIALOG HANDLERS
  // ==========================================

  void _openAddMedicalRecordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => MedicalHistoryFormDialog(
        patient: patient,
        currentUser: _activeUser,
        initialCategory: MedicalRecordCategory.allergy,
        lockCategory: false,
        onSaveAllergy: (item) {
          context.read<PatientBloc>().add(
                AddOrUpdateMedicalAllergySubmitted(
                  patientId: patient.id,
                  allergy: item,
                  currentUser: _activeUser,
                ),
              );
        },
        onSaveCondition: (item) {
          context.read<PatientBloc>().add(
                AddOrUpdateMedicalConditionSubmitted(
                  patientId: patient.id,
                  condition: item,
                  currentUser: _activeUser,
                ),
              );
        },
        onSaveMedication: (item) {
          context.read<PatientBloc>().add(
                AddOrUpdateMedicationSubmitted(
                  patientId: patient.id,
                  medication: item,
                  currentUser: _activeUser,
                ),
              );
        },
        onSavePastHistory: (item) {
          context.read<PatientBloc>().add(
                AddOrUpdatePastMedicalHistorySubmitted(
                  patientId: patient.id,
                  item: item,
                  currentUser: _activeUser,
                ),
              );
        },
        onSaveDentalHistory: (item) {
          context.read<PatientBloc>().add(
                UpdatePastDentalHistorySubmitted(
                  patientId: patient.id,
                  dentalHistory: item,
                  currentUser: _activeUser,
                ),
              );
        },
        onSaveAdditionalInfo: (item) {
          context.read<PatientBloc>().add(
                UpdateAdditionalMedicalInfoSubmitted(
                  patientId: patient.id,
                  additionalInfo: item,
                  currentUser: _activeUser,
                ),
              );
        },
      ),
    );
  }

  void _openAddAllergyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => MedicalHistoryFormDialog(
        patient: patient,
        currentUser: _activeUser,
        initialCategory: MedicalRecordCategory.allergy,
        lockCategory: true,
        onSaveAllergy: (item) {
          context.read<PatientBloc>().add(
                AddOrUpdateMedicalAllergySubmitted(
                  patientId: patient.id,
                  allergy: item,
                  currentUser: _activeUser,
                ),
              );
        },
      ),
    );
  }

  void _openEditAllergyDialog(BuildContext context, MedicalAllergyItem allergy) {
    showDialog(
      context: context,
      builder: (dialogCtx) => MedicalHistoryFormDialog(
        patient: patient,
        currentUser: _activeUser,
        initialCategory: MedicalRecordCategory.allergy,
        lockCategory: true,
        initialAllergy: allergy,
        onSaveAllergy: (item) {
          context.read<PatientBloc>().add(
                AddOrUpdateMedicalAllergySubmitted(
                  patientId: patient.id,
                  allergy: item,
                  currentUser: _activeUser,
                ),
              );
        },
      ),
    );
  }

  void _openViewAllergyDetails(BuildContext context, MedicalAllergyItem allergy) {
    showDialog(
      context: context,
      builder: (ctx) => MedicalHistoryDetailsDialog(
        categoryTitle: 'Medical Allergy',
        recordTitle: allergy.substance,
        icon: Icons.warning_amber_rounded,
        statusColor: allergy.severity.badgeColor,
        statusLabel: allergy.severity.displayName,
        recordId: allergy.effectiveId,
        canEdit: _canManage,
        attributes: {
          'Substance': allergy.substance,
          'Allergy Type': allergy.category.displayName,
          'Reaction / Symptoms': allergy.reaction,
          'Severity': allergy.severity.displayName,
          'Date Identified': allergy.diagnosedDate,
        },
        clinicalNotes: allergy.clinicalNotes,
        onEdit: () => _openEditAllergyDialog(context, allergy),
      ),
    );
  }

  void _openAddConditionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => MedicalHistoryFormDialog(
        patient: patient,
        currentUser: _activeUser,
        initialCategory: MedicalRecordCategory.condition,
        lockCategory: true,
        onSaveCondition: (item) {
          context.read<PatientBloc>().add(
                AddOrUpdateMedicalConditionSubmitted(
                  patientId: patient.id,
                  condition: item,
                  currentUser: _activeUser,
                ),
              );
        },
      ),
    );
  }

  void _openEditConditionDialog(BuildContext context, MedicalConditionItem condition) {
    showDialog(
      context: context,
      builder: (dialogCtx) => MedicalHistoryFormDialog(
        patient: patient,
        currentUser: _activeUser,
        initialCategory: MedicalRecordCategory.condition,
        lockCategory: true,
        initialCondition: condition,
        onSaveCondition: (item) {
          context.read<PatientBloc>().add(
                AddOrUpdateMedicalConditionSubmitted(
                  patientId: patient.id,
                  condition: item,
                  currentUser: _activeUser,
                ),
              );
        },
      ),
    );
  }

  void _openViewConditionDetails(BuildContext context, MedicalConditionItem condition) {
    showDialog(
      context: context,
      builder: (ctx) => MedicalHistoryDetailsDialog(
        categoryTitle: 'Medical Condition',
        recordTitle: condition.name,
        icon: Icons.healing_outlined,
        statusColor: condition.status.color,
        statusLabel: condition.status.displayName,
        recordId: condition.effectiveId,
        canEdit: _canManage,
        attributes: {
          'Condition Name': condition.name,
          'Current Status': condition.status.displayName,
          'Diagnosis Date': condition.dateDiagnosed,
          'Dental Premedication': condition.requiresDentalPremedication
              ? 'REQUIRED (Infective Endocarditis Prophylaxis)'
              : 'Not required for routine care',
        },
        clinicalNotes: condition.clinicalNotes,
        onEdit: () => _openEditConditionDialog(context, condition),
      ),
    );
  }

  void _openAddMedicationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => MedicalHistoryFormDialog(
        patient: patient,
        currentUser: _activeUser,
        initialCategory: MedicalRecordCategory.medication,
        lockCategory: true,
        onSaveMedication: (item) {
          context.read<PatientBloc>().add(
                AddOrUpdateMedicationSubmitted(
                  patientId: patient.id,
                  medication: item,
                  currentUser: _activeUser,
                ),
              );
        },
      ),
    );
  }

  void _openEditMedicationDialog(BuildContext context, MedicationItem medication) {
    showDialog(
      context: context,
      builder: (dialogCtx) => MedicalHistoryFormDialog(
        patient: patient,
        currentUser: _activeUser,
        initialCategory: MedicalRecordCategory.medication,
        lockCategory: true,
        initialMedication: medication,
        onSaveMedication: (item) {
          context.read<PatientBloc>().add(
                AddOrUpdateMedicationSubmitted(
                  patientId: patient.id,
                  medication: item,
                  currentUser: _activeUser,
                ),
              );
        },
      ),
    );
  }

  void _openViewMedicationDetails(BuildContext context, MedicationItem medication) {
    showDialog(
      context: context,
      builder: (ctx) => MedicalHistoryDetailsDialog(
        categoryTitle: 'Current / Past Medication',
        recordTitle: medication.name,
        icon: Icons.medication_outlined,
        statusColor: medication.isCurrent ? AppColors.success : AppColors.textSecondary,
        statusLabel: medication.status.displayName,
        recordId: medication.effectiveId,
        canEdit: _canManage,
        attributes: {
          'Medication Name': medication.name,
          'Dosage': medication.dosage,
          'Frequency': medication.frequency,
          'Status': medication.status.displayName,
          'Start Date': medication.startDate,
          'End Date': medication.endDate,
          'Prescribing Doctor': medication.prescribingPhysician,
        },
        clinicalNotes: medication.notes,
        onEdit: () => _openEditMedicationDialog(context, medication),
      ),
    );
  }

  void _openAddPastHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => MedicalHistoryFormDialog(
        patient: patient,
        currentUser: _activeUser,
        initialCategory: MedicalRecordCategory.surgical,
        lockCategory: true,
        onSavePastHistory: (item) {
          context.read<PatientBloc>().add(
                AddOrUpdatePastMedicalHistorySubmitted(
                  patientId: patient.id,
                  item: item,
                  currentUser: _activeUser,
                ),
              );
        },
      ),
    );
  }

  void _openEditPastHistoryDialog(BuildContext context, PastMedicalHistoryItem item) {
    showDialog(
      context: context,
      builder: (dialogCtx) => MedicalHistoryFormDialog(
        patient: patient,
        currentUser: _activeUser,
        initialCategory: MedicalRecordCategory.surgical,
        lockCategory: true,
        initialPastHistory: item,
        onSavePastHistory: (item) {
          context.read<PatientBloc>().add(
                AddOrUpdatePastMedicalHistorySubmitted(
                  patientId: patient.id,
                  item: item,
                  currentUser: _activeUser,
                ),
              );
        },
      ),
    );
  }

  void _openViewPastHistoryDetails(BuildContext context, PastMedicalHistoryItem item) {
    showDialog(
      context: context,
      builder: (ctx) => MedicalHistoryDetailsDialog(
        categoryTitle: 'Past Medical / Surgical History',
        recordTitle: item.event,
        icon: Icons.local_hospital_outlined,
        recordId: item.effectiveId,
        canEdit: _canManage,
        attributes: {
          'Event / Procedure': item.event,
          'History Type': item.type,
          'Approximate Date': item.approximateDate,
          'Hospital / Facility': item.facility,
        },
        clinicalNotes: item.notes,
        onEdit: () => _openEditPastHistoryDialog(context, item),
      ),
    );
  }

  void _openEditDentalHistoryDialog(BuildContext context, PastDentalHistory dental) {
    showDialog(
      context: context,
      builder: (dialogCtx) => MedicalHistoryFormDialog(
        patient: patient,
        currentUser: _activeUser,
        initialCategory: MedicalRecordCategory.dental,
        lockCategory: true,
        initialDentalHistory: dental,
        onSaveDentalHistory: (item) {
          context.read<PatientBloc>().add(
                UpdatePastDentalHistorySubmitted(
                  patientId: patient.id,
                  dentalHistory: item,
                  currentUser: _activeUser,
                ),
              );
        },
      ),
    );
  }

  void _openEditAdditionalInfoDialog(BuildContext context, AdditionalMedicalInfo info) {
    showDialog(
      context: context,
      builder: (dialogCtx) => MedicalHistoryFormDialog(
        patient: patient,
        currentUser: _activeUser,
        initialCategory: MedicalRecordCategory.additional,
        lockCategory: true,
        initialAdditionalInfo: info,
        onSaveAdditionalInfo: (item) {
          context.read<PatientBloc>().add(
                UpdateAdditionalMedicalInfoSubmitted(
                  patientId: patient.id,
                  additionalInfo: item,
                  currentUser: _activeUser,
                ),
              );
        },
      ),
    );
  }

  void _openAllergyStatusDialog(BuildContext context, MedicalHistoryModel medHistory) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AllergyStatusDialog(
        currentStatus: medHistory.allergyStatus,
        patientName: patient.fullName,
        hasRecordedAllergies: medHistory.allergies.isNotEmpty,
        onSave: (newStatus, notes) {
          context.read<PatientBloc>().add(
                UpdatePatientAllergyStatusSubmitted(
                  patientId: patient.id,
                  status: newStatus,
                  currentUser: _activeUser,
                  notes: notes,
                ),
              );
        },
      ),
    );
  }

  void _openAuditTrailDialog(BuildContext context, MedicalHistoryModel medHistory) {
    showDialog(
      context: context,
      builder: (dialogCtx) => MedicalHistoryAuditTrailDialog(
        patientName: patient.fullName,
        patientNumber: patient.patientNumber,
        auditTrail: medHistory.auditTrail,
      ),
    );
  }

  void _confirmDelete(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: 'Delete Record',
        isDestructive: true,
        onConfirm: () {
          Navigator.of(ctx).pop();
          onConfirm();
        },
      ),
    );
  }
}
