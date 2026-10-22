import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/models/medical_history_model.dart';
import '../../../../shared/widgets/feedback/app_empty_state.dart';

class MedicalHistoryAuditTrailDialog extends StatelessWidget {
  final String patientName;
  final String patientNumber;
  final List<MedicalHistoryAuditEntry> auditTrail;

  const MedicalHistoryAuditTrailDialog({
    super.key,
    required this.patientName,
    required this.patientNumber,
    required this.auditTrail,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusLg),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 650),
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
                    child: const Icon(Icons.history_edu_outlined, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Clinical Audit Trail & Log',
                          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Patient: $patientName ($patientNumber) • Regulatory Accountability Log',
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

              // Content
              Expanded(
                child: auditTrail.isEmpty
                    ? const Center(
                        child: AppEmptyState(
                          title: 'No Audit Modifications Recorded',
                          message: 'All current clinical history was created with initial intake records.',
                          icon: Icons.history_rounded,
                        ),
                      )
                    : ListView.separated(
                        itemCount: auditTrail.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = auditTrail[index];
                          final formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(item.timestamp);

                          Color actionColor;
                          switch (item.action.toLowerCase()) {
                            case 'created':
                              actionColor = AppColors.success;
                              break;
                            case 'updated':
                              actionColor = AppColors.primary;
                              break;
                            case 'deleted':
                              actionColor = AppColors.error;
                              break;
                            default:
                              actionColor = AppColors.info;
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: actionColor.withAlpha(25),
                                    borderRadius: AppSpacing.borderRadiusSm,
                                    border: Border.all(color: actionColor.withAlpha(90)),
                                  ),
                                  child: Text(
                                    item.action.toUpperCase(),
                                    style: AppTypography.labelSmall.copyWith(
                                      color: actionColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
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
                                          Text(
                                            item.category,
                                            style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            formattedDate,
                                            style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        item.summary,
                                        style: AppTypography.bodySmall,
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'By: ${item.performedByName} (ID: ${item.performedById})',
                                        style: AppTypography.labelSmall.copyWith(
                                          color: AppColors.textTertiary,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: AppSpacing.md),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.md),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
