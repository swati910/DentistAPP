import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';

class MedicalHistoryDetailsDialog extends StatelessWidget {
  final String categoryTitle;
  final String recordTitle;
  final IconData icon;
  final Color? statusColor;
  final String? statusLabel;
  final Map<String, String?> attributes;
  final String? clinicalNotes;
  final String? recordId;
  final VoidCallback? onEdit;
  final bool canEdit;

  const MedicalHistoryDetailsDialog({
    super.key,
    required this.categoryTitle,
    required this.recordTitle,
    required this.icon,
    this.statusColor,
    this.statusLabel,
    required this.attributes,
    this.clinicalNotes,
    this.recordId,
    this.onEdit,
    this.canEdit = true,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusLg),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 680),
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
                      color: (statusColor ?? AppColors.primary).withAlpha(30),
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                    child: Icon(icon, color: statusColor ?? AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoryTitle.toUpperCase(),
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          recordTitle,
                          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (recordId != null && recordId!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Record ID: $recordId',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
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

              // Details Body
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Badge
                      if (statusLabel != null && statusLabel!.isNotEmpty) ...[
                        Row(
                          children: [
                            Text(
                              'Clinical Status: ',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (statusColor ?? AppColors.primary).withAlpha(35),
                                borderRadius: AppSpacing.borderRadiusSm,
                                border: Border.all(color: (statusColor ?? AppColors.primary).withAlpha(100)),
                              ),
                              child: Text(
                                statusLabel!,
                                style: AppTypography.labelSmall.copyWith(
                                  color: statusColor ?? AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],

                      // Attribute key-value pairs
                      ...attributes.entries.where((e) => e.value != null && e.value!.isNotEmpty).map((e) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 150,
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
                                  e.value!,
                                  style: AppTypography.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      // Clinical Notes
                      if (clinicalNotes != null && clinicalNotes!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        const Divider(),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Clinical Remarks & Treatment Precautions',
                          style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant.withAlpha(50),
                            borderRadius: AppSpacing.borderRadiusSm,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            clinicalNotes!,
                            style: AppTypography.bodyMedium,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.md),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                  if (canEdit && onEdit != null) ...[
                    const SizedBox(width: AppSpacing.md),
                    PrimaryButton(
                      text: 'Edit Record',
                      icon: Icons.edit_outlined,
                      onPressed: () {
                        Navigator.of(context).pop();
                        onEdit!();
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
