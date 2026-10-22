import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/models/medical_history_model.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';

class AllergyStatusDialog extends StatefulWidget {
  final AllergyStatus currentStatus;
  final String patientName;
  final bool hasRecordedAllergies;
  final Function(AllergyStatus newStatus, String? notes) onSave;

  const AllergyStatusDialog({
    super.key,
    required this.currentStatus,
    required this.patientName,
    required this.hasRecordedAllergies,
    required this.onSave,
  });

  @override
  State<AllergyStatusDialog> createState() => _AllergyStatusDialogState();
}

class _AllergyStatusDialogState extends State<AllergyStatusDialog> {
  late AllergyStatus _selectedStatus;
  bool _confirmedNka = false;
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentStatus;
    if (_selectedStatus == AllergyStatus.noKnownAllergies) {
      _confirmedNka = true;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    if (_selectedStatus == AllergyStatus.noKnownAllergies && !_confirmedNka) {
      return false;
    }
    return true;
  }

  void _handleSubmit() {
    if (!_canSubmit) return;
    setState(() => _isSubmitting = true);
    widget.onSave(_selectedStatus, _notesController.text.trim());
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusLg),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                    child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Update Patient Allergy Status',
                          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Patient: ${widget.patientName}',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: AppSpacing.lg),

              Text(
                'Clinical Allergy Status *',
                style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.sm),

              _buildStatusCard(
                status: AllergyStatus.recorded,
                title: AllergyStatus.recorded.displayName,
                subtitle: 'Patient has documented adverse drug or substance reactions.',
                color: AppColors.error,
              ),
              const SizedBox(height: AppSpacing.sm),

              _buildStatusCard(
                status: AllergyStatus.noKnownAllergies,
                title: AllergyStatus.noKnownAllergies.displayName,
                subtitle: 'Explicit clinical verification that patient has no drug or material allergies.',
                color: AppColors.success,
              ),
              const SizedBox(height: AppSpacing.sm),

              _buildStatusCard(
                status: AllergyStatus.notRecorded,
                title: AllergyStatus.notRecorded.displayName,
                subtitle: 'Patient has not yet been clinically screened or status is unknown.',
                color: AppColors.warning,
              ),

              // Explicit NKA Confirmation Box
              if (_selectedStatus == AllergyStatus.noKnownAllergies) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.successContainer.withAlpha(80),
                    borderRadius: AppSpacing.borderRadiusSm,
                    border: Border.all(color: AppColors.success.withAlpha(120)),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: CheckboxListTile(
                      value: _confirmedNka,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(
                        'Clinical Safety Confirmation *',
                        style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.success),
                      ),
                      subtitle: Text(
                        'I have explicitly reviewed allergy history with the patient and verified that they have No Known Allergies (NKA).',
                        style: AppTypography.bodySmall,
                      ),
                      onChanged: (val) {
                        setState(() => _confirmedNka = val ?? false);
                      },
                    ),
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _notesController,
                label: 'Clinical Review Notes / Attestation',
                hint: 'e.g. Verbal confirmation during initial triage, confirmed by guardian.',
                maxLines: 2,
              ),

              const SizedBox(height: AppSpacing.lg),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.md),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  PrimaryButton(
                    text: 'Confirm Status',
                    isLoading: _isSubmitting,
                    onPressed: _canSubmit ? _handleSubmit : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required AllergyStatus status,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final isSelected = _selectedStatus == status;

    return InkWell(
      onTap: () {
        setState(() => _selectedStatus = status);
      },
      borderRadius: AppSpacing.borderRadiusSm,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(20) : AppColors.surfaceVariant.withAlpha(30),
          borderRadius: AppSpacing.borderRadiusSm,
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : AppColors.textTertiary,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
