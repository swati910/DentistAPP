import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/models/medical_history_model.dart';
import '../../../../shared/models/patient_model.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/dialogs/confirmation_dialog.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';

enum MedicalRecordCategory {
  allergy('Medical Allergy', Icons.warning_amber_rounded),
  condition('Medical Condition', Icons.favorite_border_rounded),
  medication('Current / Past Medication', Icons.medication_outlined),
  surgical('Past Medical & Surgical History', Icons.local_hospital_outlined),
  dental('Dental History & Oral Hygiene', Icons.cleaning_services_outlined),
  additional('Family & Social Medical History', Icons.people_outline_rounded);

  final String label;
  final IconData icon;
  const MedicalRecordCategory(this.label, this.icon);
}

class MedicalHistoryFormDialog extends StatefulWidget {
  final PatientModel patient;
  final UserModel currentUser;
  final MedicalRecordCategory initialCategory;
  final bool lockCategory;

  // Edit instances
  final MedicalAllergyItem? initialAllergy;
  final MedicalConditionItem? initialCondition;
  final MedicationItem? initialMedication;
  final PastMedicalHistoryItem? initialPastHistory;
  final PastDentalHistory? initialDentalHistory;
  final AdditionalMedicalInfo? initialAdditionalInfo;

  // Callbacks
  final void Function(MedicalAllergyItem item)? onSaveAllergy;
  final void Function(MedicalConditionItem item)? onSaveCondition;
  final void Function(MedicationItem item)? onSaveMedication;
  final void Function(PastMedicalHistoryItem item)? onSavePastHistory;
  final void Function(PastDentalHistory item)? onSaveDentalHistory;
  final void Function(AdditionalMedicalInfo item)? onSaveAdditionalInfo;

  const MedicalHistoryFormDialog({
    super.key,
    required this.patient,
    required this.currentUser,
    this.initialCategory = MedicalRecordCategory.allergy,
    this.lockCategory = false,
    this.initialAllergy,
    this.initialCondition,
    this.initialMedication,
    this.initialPastHistory,
    this.initialDentalHistory,
    this.initialAdditionalInfo,
    this.onSaveAllergy,
    this.onSaveCondition,
    this.onSaveMedication,
    this.onSavePastHistory,
    this.onSaveDentalHistory,
    this.onSaveAdditionalInfo,
  });

  bool get isEditMode =>
      initialAllergy != null ||
      initialCondition != null ||
      initialMedication != null ||
      initialPastHistory != null ||
      initialDentalHistory != null ||
      initialAdditionalInfo != null;

  @override
  State<MedicalHistoryFormDialog> createState() => _MedicalHistoryFormDialogState();
}

class _MedicalHistoryFormDialogState extends State<MedicalHistoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late MedicalRecordCategory _selectedCategory;
  bool _isSubmitting = false;
  bool _isDirty = false;

  // Allergy controllers
  late TextEditingController _allergySubstanceController;
  late TextEditingController _allergyReactionController;
  late TextEditingController _allergyDateController;
  late TextEditingController _allergyNotesController;
  AllergyCategory _allergyCategory = AllergyCategory.medication;
  AllergySeverity _allergySeverity = AllergySeverity.moderate;

  // Condition controllers
  late TextEditingController _conditionNameController;
  late TextEditingController _conditionDiagnosedDateController;
  late TextEditingController _conditionNotesController;
  MedicalConditionStatus _conditionStatus = MedicalConditionStatus.active;
  bool _conditionPremedication = false;

  // Medication controllers
  late TextEditingController _medicationNameController;
  late TextEditingController _medicationDosageController;
  late TextEditingController _medicationFrequencyController;
  late TextEditingController _medicationStartDateController;
  late TextEditingController _medicationEndDateController;
  late TextEditingController _medicationPhysicianController;
  late TextEditingController _medicationNotesController;
  MedicationStatus _medicationStatus = MedicationStatus.current;

  // Surgical / Past History controllers
  late TextEditingController _pastEventController;
  late TextEditingController _pastTypeController;
  late TextEditingController _pastDateController;
  late TextEditingController _pastFacilityController;
  late TextEditingController _pastNotesController;

  // Dental History controllers
  late TextEditingController _dentalProceduresController;
  late TextEditingController _dentalConcernsController;
  late TextEditingController _dentalComplicationsController;
  late TextEditingController _dentalBrushingController;
  late TextEditingController _dentalFlossingController;
  late TextEditingController _dentalLastCleaningController;

  // Additional / Family History controllers
  late TextEditingController _familyHistoryController;
  late TextEditingController _smokingStatusController;
  late TextEditingController _alcoholController;
  late TextEditingController _pregnancyController;
  late TextEditingController _generalNotesController;
  bool _hasBleedingDisorder = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;

    // Initialize Allergy
    final a = widget.initialAllergy;
    _allergySubstanceController = TextEditingController(text: a?.substance ?? '');
    _allergyReactionController = TextEditingController(text: a?.reaction ?? '');
    _allergyDateController = TextEditingController(text: a?.diagnosedDate ?? '');
    _allergyNotesController = TextEditingController(text: a?.clinicalNotes ?? '');
    if (a != null) {
      _allergyCategory = a.category;
      _allergySeverity = a.severity;
    }

    // Initialize Condition
    final c = widget.initialCondition;
    _conditionNameController = TextEditingController(text: c?.name ?? '');
    _conditionDiagnosedDateController = TextEditingController(text: c?.dateDiagnosed ?? '');
    _conditionNotesController = TextEditingController(text: c?.clinicalNotes ?? '');
    if (c != null) {
      _conditionStatus = c.status;
      _conditionPremedication = c.requiresDentalPremedication;
    }

    // Initialize Medication
    final m = widget.initialMedication;
    _medicationNameController = TextEditingController(text: m?.name ?? '');
    _medicationDosageController = TextEditingController(text: m?.dosage ?? '');
    _medicationFrequencyController = TextEditingController(text: m?.frequency ?? '');
    _medicationStartDateController = TextEditingController(text: m?.startDate ?? '');
    _medicationEndDateController = TextEditingController(text: m?.endDate ?? '');
    _medicationPhysicianController = TextEditingController(text: m?.prescribingPhysician ?? '');
    _medicationNotesController = TextEditingController(text: m?.notes ?? '');
    if (m != null) {
      _medicationStatus = m.status;
    }

    // Initialize Past History
    final p = widget.initialPastHistory;
    _pastEventController = TextEditingController(text: p?.event ?? '');
    _pastTypeController = TextEditingController(text: p?.type ?? 'Surgical Procedure');
    _pastDateController = TextEditingController(text: p?.approximateDate ?? '');
    _pastFacilityController = TextEditingController(text: p?.facility ?? '');
    _pastNotesController = TextEditingController(text: p?.notes ?? '');

    // Initialize Dental History
    final d = widget.initialDentalHistory;
    _dentalProceduresController = TextEditingController(text: d?.previousProcedures.join('\n') ?? '');
    _dentalConcernsController = TextEditingController(text: d?.oralHealthConcerns.join('\n') ?? '');
    _dentalComplicationsController = TextEditingController(text: d?.treatmentComplications.join('\n') ?? '');
    _dentalBrushingController = TextEditingController(text: d?.brushingFrequency ?? '');
    _dentalFlossingController = TextEditingController(text: d?.flossingFrequency ?? '');
    _dentalLastCleaningController = TextEditingController(text: d?.lastDentalCleaningDate ?? '');

    // Initialize Additional Info
    final info = widget.initialAdditionalInfo;
    _familyHistoryController = TextEditingController(text: info?.familyMedicalHistory.join('\n') ?? '');
    _smokingStatusController = TextEditingController(text: info?.smokingStatus ?? 'Non-smoker');
    _alcoholController = TextEditingController(text: info?.alcoholConsumption ?? 'None');
    _pregnancyController = TextEditingController(text: info?.pregnancyStatus ?? 'Not pregnant');
    _generalNotesController = TextEditingController(text: info?.generalNotes ?? '');
    _hasBleedingDisorder = info?.hasBleedingDisorder ?? false;
  }

  @override
  void dispose() {
    _allergySubstanceController.dispose();
    _allergyReactionController.dispose();
    _allergyDateController.dispose();
    _allergyNotesController.dispose();

    _conditionNameController.dispose();
    _conditionDiagnosedDateController.dispose();
    _conditionNotesController.dispose();

    _medicationNameController.dispose();
    _medicationDosageController.dispose();
    _medicationFrequencyController.dispose();
    _medicationStartDateController.dispose();
    _medicationEndDateController.dispose();
    _medicationPhysicianController.dispose();
    _medicationNotesController.dispose();

    _pastEventController.dispose();
    _pastTypeController.dispose();
    _pastDateController.dispose();
    _pastFacilityController.dispose();
    _pastNotesController.dispose();

    _dentalProceduresController.dispose();
    _dentalConcernsController.dispose();
    _dentalComplicationsController.dispose();
    _dentalBrushingController.dispose();
    _dentalFlossingController.dispose();
    _dentalLastCleaningController.dispose();

    _familyHistoryController.dispose();
    _smokingStatusController.dispose();
    _alcoholController.dispose();
    _pregnancyController.dispose();
    _generalNotesController.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  void _handleCancel() {
    if (_isDirty) {
      showDialog(
        context: context,
        builder: (ctx) => ConfirmationDialog(
          title: 'Discard Unsaved Changes?',
          message: 'You have entered changes in this medical record. Are you sure you want to discard them?',
          confirmText: 'Discard Changes',
          isDestructive: true,
          onConfirm: () {
            Navigator.of(ctx).pop();
            Navigator.of(context).pop();
          },
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      final formatted = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      controller.text = formatted;
      _markDirty();
    }
  }

  void _handleSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isSubmitting = true);

    switch (_selectedCategory) {
      case MedicalRecordCategory.allergy:
        final allergy = MedicalAllergyItem(
          id: widget.initialAllergy?.id ?? '',
          substance: _allergySubstanceController.text.trim(),
          category: _allergyCategory,
          reaction: _allergyReactionController.text.trim().isEmpty
              ? 'Adverse reaction not specified'
              : _allergyReactionController.text.trim(),
          severity: _allergySeverity,
          diagnosedDate: _allergyDateController.text.trim().isEmpty ? null : _allergyDateController.text.trim(),
          clinicalNotes: _allergyNotesController.text.trim().isEmpty ? null : _allergyNotesController.text.trim(),
        );
        widget.onSaveAllergy?.call(allergy);
        break;

      case MedicalRecordCategory.condition:
        final condition = MedicalConditionItem(
          id: widget.initialCondition?.id ?? '',
          name: _conditionNameController.text.trim(),
          status: _conditionStatus,
          dateDiagnosed: _conditionDiagnosedDateController.text.trim().isEmpty ? null : _conditionDiagnosedDateController.text.trim(),
          clinicalNotes: _conditionNotesController.text.trim().isEmpty ? null : _conditionNotesController.text.trim(),
          requiresDentalPremedication: _conditionPremedication,
        );
        widget.onSaveCondition?.call(condition);
        break;

      case MedicalRecordCategory.medication:
        final medication = MedicationItem(
          id: widget.initialMedication?.id ?? '',
          name: _medicationNameController.text.trim(),
          dosage: _medicationDosageController.text.trim().isEmpty ? 'As prescribed' : _medicationDosageController.text.trim(),
          frequency: _medicationFrequencyController.text.trim().isEmpty ? 'Per clinician instruction' : _medicationFrequencyController.text.trim(),
          status: _medicationStatus,
          startDate: _medicationStartDateController.text.trim().isEmpty ? null : _medicationStartDateController.text.trim(),
          endDate: _medicationEndDateController.text.trim().isEmpty ? null : _medicationEndDateController.text.trim(),
          prescribingPhysician: _medicationPhysicianController.text.trim().isEmpty ? null : _medicationPhysicianController.text.trim(),
          notes: _medicationNotesController.text.trim().isEmpty ? null : _medicationNotesController.text.trim(),
        );
        widget.onSaveMedication?.call(medication);
        break;

      case MedicalRecordCategory.surgical:
        final pastItem = PastMedicalHistoryItem(
          id: widget.initialPastHistory?.id ?? '',
          event: _pastEventController.text.trim(),
          type: _pastTypeController.text.trim().isEmpty ? 'Surgical Procedure' : _pastTypeController.text.trim(),
          approximateDate: _pastDateController.text.trim().isEmpty ? null : _pastDateController.text.trim(),
          facility: _pastFacilityController.text.trim().isEmpty ? null : _pastFacilityController.text.trim(),
          notes: _pastNotesController.text.trim().isEmpty ? null : _pastNotesController.text.trim(),
        );
        widget.onSavePastHistory?.call(pastItem);
        break;

      case MedicalRecordCategory.dental:
        final dental = PastDentalHistory(
          previousProcedures: _dentalProceduresController.text
              .split('\n')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          oralHealthConcerns: _dentalConcernsController.text
              .split('\n')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          treatmentComplications: _dentalComplicationsController.text
              .split('\n')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          brushingFrequency: _dentalBrushingController.text.trim(),
          flossingFrequency: _dentalFlossingController.text.trim(),
          lastDentalCleaningDate: _dentalLastCleaningController.text.trim().isEmpty ? null : _dentalLastCleaningController.text.trim(),
        );
        widget.onSaveDentalHistory?.call(dental);
        break;

      case MedicalRecordCategory.additional:
        final addInfo = AdditionalMedicalInfo(
          familyMedicalHistory: _familyHistoryController.text
              .split('\n')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          smokingStatus: _smokingStatusController.text.trim(),
          alcoholConsumption: _alcoholController.text.trim(),
          hasBleedingDisorder: _hasBleedingDisorder,
          pregnancyStatus: _pregnancyController.text.trim(),
          generalNotes: _generalNotesController.text.trim().isEmpty ? null : _generalNotesController.text.trim(),
          lastReviewedDate: DateTime.now(),
          reviewedByDoctor: '${widget.currentUser.fullName} (${widget.currentUser.role.displayName})',
        );
        widget.onSaveAdditionalInfo?.call(addInfo);
        break;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditMode
        ? 'Edit ${_selectedCategory.label}'
        : 'Add ${_selectedCategory.label}';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusLg),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 780),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                    child: Icon(_selectedCategory.icon, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Patient: ${widget.patient.fullName} (${widget.patient.patientNumber})',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Close',
                    onPressed: _handleCancel,
                  ),
                ],
              ),
              const Divider(height: AppSpacing.lg),

              // Category Selector (only in Add mode if not locked)
              if (!widget.isEditMode && !widget.lockCategory) ...[
                Text(
                  'Record Category *',
                  style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.xs),
                DropdownButtonFormField<MedicalRecordCategory>(
                  initialValue: _selectedCategory,
                  isExpanded: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    border: OutlineInputBorder(borderRadius: AppSpacing.borderRadiusSm),
                  ),
                  items: MedicalRecordCategory.values.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Row(
                        children: [
                          Icon(cat.icon, size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(cat.label),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (cat) {
                    if (cat != null) {
                      setState(() {
                        _selectedCategory = cat;
                        _markDirty();
                      });
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // Scrollable Form Body
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: _buildCategoryFields(),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.md),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _isSubmitting ? null : _handleCancel,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  PrimaryButton(
                    text: widget.isEditMode ? 'Update Record' : 'Save Record',
                    isLoading: _isSubmitting,
                    onPressed: _handleSubmit,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFields() {
    switch (_selectedCategory) {
      case MedicalRecordCategory.allergy:
        return _buildAllergyForm();
      case MedicalRecordCategory.condition:
        return _buildConditionForm();
      case MedicalRecordCategory.medication:
        return _buildMedicationForm();
      case MedicalRecordCategory.surgical:
        return _buildSurgicalForm();
      case MedicalRecordCategory.dental:
        return _buildDentalForm();
      case MedicalRecordCategory.additional:
        return _buildAdditionalForm();
    }
  }

  // 1. ALLERGY FORM
  Widget _buildAllergyForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: _allergySubstanceController,
          label: 'Allergen / Substance Name *',
          hint: 'e.g. Penicillin, Latex, Lidocaine, Sulfa Drugs',
          onChanged: (_) => _markDirty(),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Allergen substance name is required.';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.md),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Allergy Classification', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSpacing.xs),
                  DropdownButtonFormField<AllergyCategory>(
                    initialValue: _allergyCategory,
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      border: OutlineInputBorder(borderRadius: AppSpacing.borderRadiusSm),
                    ),
                    items: AllergyCategory.values.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat.displayName));
                    }).toList(),
                    onChanged: (cat) {
                      if (cat != null) {
                        setState(() => _allergyCategory = cat);
                        _markDirty();
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Severity Level', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSpacing.xs),
                  DropdownButtonFormField<AllergySeverity>(
                    initialValue: _allergySeverity,
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      border: OutlineInputBorder(borderRadius: AppSpacing.borderRadiusSm),
                    ),
                    items: AllergySeverity.values.map((sev) {
                      return DropdownMenuItem(
                        value: sev,
                        child: Row(
                          children: [
                            Container(width: 10, height: 10, decoration: BoxDecoration(color: sev.badgeColor, shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Text(sev.displayName),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (sev) {
                      if (sev != null) {
                        setState(() => _allergySeverity = sev);
                        _markDirty();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        AppTextField(
          controller: _allergyReactionController,
          label: 'Reaction / Symptoms',
          hint: 'e.g. Urticaria, Facial angioedema, Bronchospasm, Anaphylaxis',
          onChanged: (_) => _markDirty(),
        ),
        const SizedBox(height: AppSpacing.md),

        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _allergyDateController,
                label: 'Date Identified',
                hint: 'YYYY-MM-DD or Year',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today_rounded, size: 18),
                  onPressed: () => _pickDate(_allergyDateController),
                ),
                onChanged: (_) => _markDirty(),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        AppTextField(
          controller: _allergyNotesController,
          label: 'Clinical Precautions & Dental Implications',
          hint: 'e.g. Avoid all beta-lactam antibiotics. Cross-reactivity caution.',
          maxLines: 3,
          onChanged: (_) => _markDirty(),
        ),
      ],
    );
  }

  // 2. CONDITION FORM
  Widget _buildConditionForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: _conditionNameController,
          label: 'Condition / Diagnosis Name *',
          hint: 'e.g. Type 2 Diabetes Mellitus, Hypertension, Asthma',
          onChanged: (_) => _markDirty(),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Condition name is required.';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.md),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Status', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSpacing.xs),
                  DropdownButtonFormField<MedicalConditionStatus>(
                    initialValue: _conditionStatus,
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      border: OutlineInputBorder(borderRadius: AppSpacing.borderRadiusSm),
                    ),
                    items: MedicalConditionStatus.values.map((st) {
                      return DropdownMenuItem(value: st, child: Text(st.displayName));
                    }).toList(),
                    onChanged: (st) {
                      if (st != null) {
                        setState(() => _conditionStatus = st);
                        _markDirty();
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppTextField(
                controller: _conditionDiagnosedDateController,
                label: 'Diagnosis Date',
                hint: 'e.g. 2018 or March 2020',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today_rounded, size: 18),
                  onPressed: () => _pickDate(_conditionDiagnosedDateController),
                ),
                onChanged: (_) => _markDirty(),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        CheckboxListTile(
          value: _conditionPremedication,
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Requires Antibiotic Premedication before invasive dental procedures',
            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            'For infective endocarditis prevention, prosthetic cardiac valves, or immunosuppression',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          onChanged: (val) {
            setState(() => _conditionPremedication = val ?? false);
            _markDirty();
          },
        ),
        const SizedBox(height: AppSpacing.md),

        AppTextField(
          controller: _conditionNotesController,
          label: 'Management Notes & Dental Treatment Considerations',
          hint: 'e.g. Morning appointments recommended. Blood glucose checked chairside.',
          maxLines: 3,
          onChanged: (_) => _markDirty(),
        ),
      ],
    );
  }

  // 3. MEDICATION FORM
  Widget _buildMedicationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: _medicationNameController,
          label: 'Medication Name *',
          hint: 'e.g. Amoxicillin, Metformin, Lisinopril, Warfarin',
          onChanged: (_) => _markDirty(),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Medication name is required.';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.md),

        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _medicationDosageController,
                label: 'Dosage',
                hint: 'e.g. 500 mg, 10 mg/mL, 1 puff',
                onChanged: (_) => _markDirty(),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppTextField(
                controller: _medicationFrequencyController,
                label: 'Frequency',
                hint: 'e.g. Once daily, BID with food, PRN',
                onChanged: (_) => _markDirty(),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Medication Status', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSpacing.xs),
                  DropdownButtonFormField<MedicationStatus>(
                    initialValue: _medicationStatus,
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      border: OutlineInputBorder(borderRadius: AppSpacing.borderRadiusSm),
                    ),
                    items: MedicationStatus.values.map((st) {
                      return DropdownMenuItem(value: st, child: Text(st.displayName));
                    }).toList(),
                    onChanged: (st) {
                      if (st != null) {
                        setState(() => _medicationStatus = st);
                        _markDirty();
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppTextField(
                controller: _medicationStartDateController,
                label: 'Start Date',
                hint: 'YYYY-MM-DD',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today_rounded, size: 18),
                  onPressed: () => _pickDate(_medicationStartDateController),
                ),
                onChanged: (_) => _markDirty(),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _medicationEndDateController,
                label: 'End Date (if discontinued)',
                hint: 'YYYY-MM-DD',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today_rounded, size: 18),
                  onPressed: () => _pickDate(_medicationEndDateController),
                ),
                onChanged: (_) => _markDirty(),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppTextField(
                controller: _medicationPhysicianController,
                label: 'Prescribing Physician',
                hint: 'e.g. Dr. A. Sen, Cardiology',
                onChanged: (_) => _markDirty(),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        AppTextField(
          controller: _medicationNotesController,
          label: 'Clinical Notes & Dental Bleeding/Dry Mouth Risks',
          hint: 'e.g. Anticoagulant precautions; verify INR before extractions.',
          maxLines: 3,
          onChanged: (_) => _markDirty(),
        ),
      ],
    );
  }

  // 4. SURGICAL / PAST HISTORY FORM
  Widget _buildSurgicalForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: _pastEventController,
          label: 'Procedure or Medical Event *',
          hint: 'e.g. Appendectomy, Knee Arthroplasty, Coronary Stenting',
          onChanged: (_) => _markDirty(),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Event or procedure title is required.';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.md),

        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _pastTypeController,
                label: 'History Type',
                hint: 'e.g. Surgical Procedure, Hospitalization, Major Illness',
                onChanged: (_) => _markDirty(),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppTextField(
                controller: _pastDateController,
                label: 'Date or Approximate Year',
                hint: 'e.g. May 2019, 2021',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today_rounded, size: 18),
                  onPressed: () => _pickDate(_pastDateController),
                ),
                onChanged: (_) => _markDirty(),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        AppTextField(
          controller: _pastFacilityController,
          label: 'Hospital or Medical Facility',
          hint: 'e.g. City General Hospital, Apollo Bengaluru',
          onChanged: (_) => _markDirty(),
        ),
        const SizedBox(height: AppSpacing.md),

        AppTextField(
          controller: _pastNotesController,
          label: 'Outcome, Anesthesia Complications & Notes',
          hint: 'e.g. Uneventful recovery. No history of malignant hyperthermia.',
          maxLines: 3,
          onChanged: (_) => _markDirty(),
        ),
      ],
    );
  }

  // 5. DENTAL HISTORY FORM
  Widget _buildDentalForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: _dentalProceduresController,
          label: 'Previous Dental Procedures (one per line)',
          hint: 'e.g.\nClass II composite on 14 (2024)\nRoot canal treatment on 36 (2021)',
          maxLines: 3,
          onChanged: (_) => _markDirty(),
        ),
        const SizedBox(height: AppSpacing.md),

        AppTextField(
          controller: _dentalConcernsController,
          label: 'Patient Oral Health Concerns (one per line)',
          hint: 'e.g.\nCold sensitivity in lower molars\nGum bleeding during flossing',
          maxLines: 3,
          onChanged: (_) => _markDirty(),
        ),
        const SizedBox(height: AppSpacing.md),

        AppTextField(
          controller: _dentalComplicationsController,
          label: 'Previous Treatment Complications & Anesthesia Reactions',
          hint: 'e.g. Vasovagal syncope during local anesthesia (2018), or none',
          maxLines: 2,
          onChanged: (_) => _markDirty(),
        ),
        const SizedBox(height: AppSpacing.md),

        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _dentalBrushingController,
                label: 'Brushing Frequency',
                hint: 'e.g. Twice daily with soft bristles',
                onChanged: (_) => _markDirty(),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppTextField(
                controller: _dentalFlossingController,
                label: 'Flossing Frequency',
                hint: 'e.g. 3-4 times per week, Daily',
                onChanged: (_) => _markDirty(),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        AppTextField(
          controller: _dentalLastCleaningController,
          label: 'Last Professional Dental Prophylaxis / Cleaning',
          hint: 'e.g. October 2025',
          onChanged: (_) => _markDirty(),
        ),
      ],
    );
  }

  // 6. ADDITIONAL & FAMILY HISTORY FORM
  Widget _buildAdditionalForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: _familyHistoryController,
          label: 'Family Medical History (one item per line)',
          hint: 'e.g.\nFather: Type 2 Diabetes, Coronary Artery Disease\nMother: Osteoporosis',
          maxLines: 3,
          onChanged: (_) => _markDirty(),
        ),
        const SizedBox(height: AppSpacing.md),

        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _smokingStatusController,
                label: 'Smoking / Tobacco Use',
                hint: 'e.g. Non-smoker, 5 cigs/day, Former (quit 2020)',
                onChanged: (_) => _markDirty(),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppTextField(
                controller: _alcoholController,
                label: 'Alcohol Consumption',
                hint: 'e.g. None, Occasional social, Moderate',
                onChanged: (_) => _markDirty(),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _pregnancyController,
                label: 'Pregnancy / Nursing Status',
                hint: 'e.g. Not pregnant, 2nd Trimester, Nursing',
                onChanged: (_) => _markDirty(),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        CheckboxListTile(
          value: _hasBleedingDisorder,
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Patient has documented Bleeding Disorder or Hemostatic Risk',
            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            'e.g. Hemophilia, Von Willebrand disease, Thrombocytopenia',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          onChanged: (val) {
            setState(() => _hasBleedingDisorder = val ?? false);
            _markDirty();
          },
        ),
        const SizedBox(height: AppSpacing.md),

        AppTextField(
          controller: _generalNotesController,
          label: 'General Clinical & Lifestyle Remarks',
          hint: 'e.g. Requires chair inclined at 45 degrees due to cervical spondylosis.',
          maxLines: 3,
          onChanged: (_) => _markDirty(),
        ),
      ],
    );
  }
}
