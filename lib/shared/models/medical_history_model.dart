import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

enum AllergyStatus {
  recorded,
  noKnownAllergies,
  notRecorded,
}

extension AllergyStatusExtension on AllergyStatus {
  String get displayName {
    switch (this) {
      case AllergyStatus.recorded:
        return 'Known Allergies Recorded';
      case AllergyStatus.noKnownAllergies:
        return 'No Known Allergies (NKA - Confirmed)';
      case AllergyStatus.notRecorded:
        return 'Allergy Information Not Recorded / Not Reviewed';
    }
  }

  String get label => displayName;

  Color get color {
    switch (this) {
      case AllergyStatus.recorded:
        return AppColors.error;
      case AllergyStatus.noKnownAllergies:
        return AppColors.success;
      case AllergyStatus.notRecorded:
        return AppColors.warning;
    }
  }

  Color get containerColor {
    switch (this) {
      case AllergyStatus.recorded:
        return AppColors.errorContainer;
      case AllergyStatus.noKnownAllergies:
        return AppColors.successContainer;
      case AllergyStatus.notRecorded:
        return AppColors.warningContainer;
    }
  }
}

enum AllergySeverity {
  mild,
  moderate,
  severe,
  critical,
}

extension AllergySeverityExtension on AllergySeverity {
  String get displayName {
    switch (this) {
      case AllergySeverity.mild:
        return 'Mild';
      case AllergySeverity.moderate:
        return 'Moderate';
      case AllergySeverity.severe:
        return 'Severe';
      case AllergySeverity.critical:
        return 'Critical / Anaphylactic';
    }
  }

  Color get badgeColor {
    switch (this) {
      case AllergySeverity.mild:
        return AppColors.info;
      case AllergySeverity.moderate:
        return AppColors.warning;
      case AllergySeverity.severe:
        return AppColors.error;
      case AllergySeverity.critical:
        return const Color(0xFF991B1B);
    }
  }
}

enum AllergyCategory {
  medication,
  material,
  food,
  environmental,
  chemical,
  other,
}

extension AllergyCategoryExtension on AllergyCategory {
  String get displayName {
    switch (this) {
      case AllergyCategory.medication:
        return 'Medication / Drug';
      case AllergyCategory.material:
        return 'Dental Material / Latex';
      case AllergyCategory.food:
        return 'Food';
      case AllergyCategory.environmental:
        return 'Environmental';
      case AllergyCategory.chemical:
        return 'Antiseptic / Chemical';
      case AllergyCategory.other:
        return 'Other';
    }
  }
}

class MedicalAllergyItem extends Equatable {
  final String id;
  final String substance;
  final AllergyCategory category;
  final String reaction;
  final AllergySeverity severity;
  final String? diagnosedDate;
  final String? clinicalNotes;

  const MedicalAllergyItem({
    this.id = '',
    required this.substance,
    this.category = AllergyCategory.medication,
    required this.reaction,
    this.severity = AllergySeverity.moderate,
    this.diagnosedDate,
    this.clinicalNotes,
  });

  String get effectiveId => id.isNotEmpty ? id : 'alg-${substance.hashCode.abs()}';
  String get allergen => substance;

  MedicalAllergyItem copyWith({
    String? id,
    String? substance,
    AllergyCategory? category,
    String? reaction,
    AllergySeverity? severity,
    String? diagnosedDate,
    String? clinicalNotes,
  }) {
    return MedicalAllergyItem(
      id: id ?? this.id,
      substance: substance ?? this.substance,
      category: category ?? this.category,
      reaction: reaction ?? this.reaction,
      severity: severity ?? this.severity,
      diagnosedDate: diagnosedDate ?? this.diagnosedDate,
      clinicalNotes: clinicalNotes ?? this.clinicalNotes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        substance,
        category,
        reaction,
        severity,
        diagnosedDate,
        clinicalNotes,
      ];
}

enum MedicalConditionStatus {
  active,
  controlled,
  inRemission,
  resolved,
}

extension MedicalConditionStatusExtension on MedicalConditionStatus {
  String get displayName {
    switch (this) {
      case MedicalConditionStatus.active:
        return 'Active';
      case MedicalConditionStatus.controlled:
        return 'Controlled';
      case MedicalConditionStatus.inRemission:
        return 'In Remission';
      case MedicalConditionStatus.resolved:
        return 'Resolved';
    }
  }

  Color get color {
    switch (this) {
      case MedicalConditionStatus.active:
        return AppColors.error;
      case MedicalConditionStatus.controlled:
        return AppColors.success;
      case MedicalConditionStatus.inRemission:
        return AppColors.info;
      case MedicalConditionStatus.resolved:
        return AppColors.textTertiary;
    }
  }
}

class MedicalConditionItem extends Equatable {
  final String id;
  final String name;
  final MedicalConditionStatus status;
  final String? dateDiagnosed;
  final String? clinicalNotes;
  final bool requiresDentalPremedication;

  const MedicalConditionItem({
    this.id = '',
    required this.name,
    this.status = MedicalConditionStatus.active,
    this.dateDiagnosed,
    this.clinicalNotes,
    this.requiresDentalPremedication = false,
  });

  String get effectiveId => id.isNotEmpty ? id : 'cnd-${name.hashCode.abs()}';

  MedicalConditionItem copyWith({
    String? id,
    String? name,
    MedicalConditionStatus? status,
    String? dateDiagnosed,
    String? clinicalNotes,
    bool? requiresDentalPremedication,
  }) {
    return MedicalConditionItem(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      dateDiagnosed: dateDiagnosed ?? this.dateDiagnosed,
      clinicalNotes: clinicalNotes ?? this.clinicalNotes,
      requiresDentalPremedication: requiresDentalPremedication ?? this.requiresDentalPremedication,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        status,
        dateDiagnosed,
        clinicalNotes,
        requiresDentalPremedication,
      ];
}

enum MedicationStatus {
  current,
  historical,
}

extension MedicationStatusExtension on MedicationStatus {
  String get displayName {
    switch (this) {
      case MedicationStatus.current:
        return 'Current / Active';
      case MedicationStatus.historical:
        return 'Discontinued / Historical';
    }
  }
}

class MedicationItem extends Equatable {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final MedicationStatus status;
  final String? startDate;
  final String? endDate;
  final String? prescribingPhysician;
  final String? notes;

  const MedicationItem({
    this.id = '',
    required this.name,
    required this.dosage,
    required this.frequency,
    this.status = MedicationStatus.current,
    this.startDate,
    this.endDate,
    this.prescribingPhysician,
    this.notes,
  });

  String get effectiveId => id.isNotEmpty ? id : 'med-${name.hashCode.abs()}';

  bool get isCurrent => status == MedicationStatus.current;

  MedicationItem copyWith({
    String? id,
    String? name,
    String? dosage,
    String? frequency,
    MedicationStatus? status,
    String? startDate,
    String? endDate,
    String? prescribingPhysician,
    String? notes,
  }) {
    return MedicationItem(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      prescribingPhysician: prescribingPhysician ?? this.prescribingPhysician,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        dosage,
        frequency,
        status,
        startDate,
        endDate,
        prescribingPhysician,
        notes,
      ];
}

class PastMedicalHistoryItem extends Equatable {
  final String id;
  final String event;
  final String type; // 'Surgery', 'Hospitalization', 'Trauma', 'Procedure', 'Major Illness'
  final String? approximateDate;
  final String? facility;
  final String? notes;

  const PastMedicalHistoryItem({
    this.id = '',
    required this.event,
    this.type = 'Surgery',
    this.approximateDate,
    this.facility,
    this.notes,
  });

  String get effectiveId => id.isNotEmpty ? id : 'pmh-${event.hashCode.abs()}';

  PastMedicalHistoryItem copyWith({
    String? id,
    String? event,
    String? type,
    String? approximateDate,
    String? facility,
    String? notes,
  }) {
    return PastMedicalHistoryItem(
      id: id ?? this.id,
      event: event ?? this.event,
      type: type ?? this.type,
      approximateDate: approximateDate ?? this.approximateDate,
      facility: facility ?? this.facility,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        event,
        type,
        approximateDate,
        facility,
        notes,
      ];
}

class PastDentalHistory extends Equatable {
  final List<String> previousProcedures;
  final List<String> oralHealthConcerns;
  final List<String> treatmentComplications;
  final String? brushingFrequency;
  final String? flossingFrequency;
  final String? lastDentalCleaningDate;
  final String? notes;

  const PastDentalHistory({
    this.previousProcedures = const [],
    this.oralHealthConcerns = const [],
    this.treatmentComplications = const [],
    this.brushingFrequency = 'Twice daily',
    this.flossingFrequency = 'Once daily',
    this.lastDentalCleaningDate,
    this.notes,
  });

  PastDentalHistory copyWith({
    List<String>? previousProcedures,
    List<String>? oralHealthConcerns,
    List<String>? treatmentComplications,
    String? brushingFrequency,
    String? flossingFrequency,
    String? lastDentalCleaningDate,
    String? notes,
  }) {
    return PastDentalHistory(
      previousProcedures: previousProcedures ?? this.previousProcedures,
      oralHealthConcerns: oralHealthConcerns ?? this.oralHealthConcerns,
      treatmentComplications: treatmentComplications ?? this.treatmentComplications,
      brushingFrequency: brushingFrequency ?? this.brushingFrequency,
      flossingFrequency: flossingFrequency ?? this.flossingFrequency,
      lastDentalCleaningDate: lastDentalCleaningDate ?? this.lastDentalCleaningDate,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        previousProcedures,
        oralHealthConcerns,
        treatmentComplications,
        brushingFrequency,
        flossingFrequency,
        lastDentalCleaningDate,
        notes,
      ];
}

class AdditionalMedicalInfo extends Equatable {
  final List<String> familyMedicalHistory;
  final String? smokingStatus;
  final String? alcoholConsumption;
  final bool hasBleedingDisorder;
  final String? pregnancyStatus;
  final DateTime? lastReviewedDate;
  final String? reviewedByDoctor;
  final String? generalNotes;

  const AdditionalMedicalInfo({
    this.familyMedicalHistory = const [],
    this.smokingStatus,
    this.alcoholConsumption,
    this.hasBleedingDisorder = false,
    this.pregnancyStatus,
    this.lastReviewedDate,
    this.reviewedByDoctor,
    this.generalNotes,
  });

  AdditionalMedicalInfo copyWith({
    List<String>? familyMedicalHistory,
    String? smokingStatus,
    String? alcoholConsumption,
    bool? hasBleedingDisorder,
    String? pregnancyStatus,
    DateTime? lastReviewedDate,
    String? reviewedByDoctor,
    String? generalNotes,
  }) {
    return AdditionalMedicalInfo(
      familyMedicalHistory: familyMedicalHistory ?? this.familyMedicalHistory,
      smokingStatus: smokingStatus ?? this.smokingStatus,
      alcoholConsumption: alcoholConsumption ?? this.alcoholConsumption,
      hasBleedingDisorder: hasBleedingDisorder ?? this.hasBleedingDisorder,
      pregnancyStatus: pregnancyStatus ?? this.pregnancyStatus,
      lastReviewedDate: lastReviewedDate ?? this.lastReviewedDate,
      reviewedByDoctor: reviewedByDoctor ?? this.reviewedByDoctor,
      generalNotes: generalNotes ?? this.generalNotes,
    );
  }

  @override
  List<Object?> get props => [
        familyMedicalHistory,
        smokingStatus,
        alcoholConsumption,
        hasBleedingDisorder,
        pregnancyStatus,
        lastReviewedDate,
        reviewedByDoctor,
        generalNotes,
      ];
}

class MedicalHistoryAuditEntry extends Equatable {
  final String id;
  final String recordId;
  final String category; // 'Allergy', 'Condition', 'Medication', 'Surgical', 'Dental', 'Additional', 'Status'
  final String action; // 'Created', 'Updated', 'Deleted', 'Reviewed'
  final String performedById;
  final String performedByName;
  final DateTime timestamp;
  final String summary;

  const MedicalHistoryAuditEntry({
    required this.id,
    required this.recordId,
    required this.category,
    required this.action,
    required this.performedById,
    required this.performedByName,
    required this.timestamp,
    required this.summary,
  });

  @override
  List<Object?> get props => [
        id,
        recordId,
        category,
        action,
        performedById,
        performedByName,
        timestamp,
        summary,
      ];
}

class MedicalHistoryModel extends Equatable {
  final AllergyStatus allergyStatus;
  final List<MedicalAllergyItem> allergies;
  final List<MedicalConditionItem> medicalConditions;
  final List<MedicationItem> medications;
  final List<PastMedicalHistoryItem> pastMedicalHistory;
  final PastDentalHistory dentalHistory;
  final AdditionalMedicalInfo additionalInfo;
  final List<MedicalHistoryAuditEntry> auditTrail;
  final String? reviewedByClinicianName;
  final String? reviewedByClinicianRole;
  final DateTime? lastReviewedDate;
  final DateTime? lastUpdated;

  const MedicalHistoryModel({
    this.allergyStatus = AllergyStatus.notRecorded,
    this.allergies = const [],
    this.medicalConditions = const [],
    this.medications = const [],
    this.pastMedicalHistory = const [],
    this.dentalHistory = const PastDentalHistory(),
    this.additionalInfo = const AdditionalMedicalInfo(),
    this.auditTrail = const [],
    this.reviewedByClinicianName,
    this.reviewedByClinicianRole,
    this.lastReviewedDate,
    this.lastUpdated,
  });

  List<MedicationItem> get currentMedications =>
      medications.where((m) => m.isCurrent).toList();

  List<MedicationItem> get historicalMedications =>
      medications.where((m) => !m.isCurrent).toList();

  bool get hasKnownAllergies =>
      allergyStatus == AllergyStatus.recorded && allergies.isNotEmpty;

  bool get hasNoKnownAllergiesConfirmed =>
      allergyStatus == AllergyStatus.noKnownAllergies;

  bool get isAllergyInfoNotRecorded =>
      allergyStatus == AllergyStatus.notRecorded;

  MedicalHistoryModel copyWith({
    AllergyStatus? allergyStatus,
    List<MedicalAllergyItem>? allergies,
    List<MedicalConditionItem>? medicalConditions,
    List<MedicationItem>? medications,
    List<PastMedicalHistoryItem>? pastMedicalHistory,
    PastDentalHistory? dentalHistory,
    AdditionalMedicalInfo? additionalInfo,
    List<MedicalHistoryAuditEntry>? auditTrail,
    String? reviewedByClinicianName,
    String? reviewedByClinicianRole,
    DateTime? lastReviewedDate,
    DateTime? lastUpdated,
  }) {
    return MedicalHistoryModel(
      allergyStatus: allergyStatus ?? this.allergyStatus,
      allergies: allergies ?? this.allergies,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      medications: medications ?? this.medications,
      pastMedicalHistory: pastMedicalHistory ?? this.pastMedicalHistory,
      dentalHistory: dentalHistory ?? this.dentalHistory,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      auditTrail: auditTrail ?? this.auditTrail,
      reviewedByClinicianName: reviewedByClinicianName ?? this.reviewedByClinicianName,
      reviewedByClinicianRole: reviewedByClinicianRole ?? this.reviewedByClinicianRole,
      lastReviewedDate: lastReviewedDate ?? this.lastReviewedDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Creates a fallback MedicalHistoryModel from legacy string lists
  factory MedicalHistoryModel.fromLegacyLists({
    required List<String> allergies,
    required List<String> chronicConditions,
    required List<String> currentMedications,
  }) {
    AllergyStatus status;
    List<MedicalAllergyItem> allergyItems = [];

    if (allergies.isNotEmpty) {
      status = AllergyStatus.recorded;
      allergyItems = allergies.asMap().entries.map((entry) {
        final index = entry.key;
        final name = entry.value;
        AllergyCategory cat = AllergyCategory.medication;
        if (name.toLowerCase().contains('latex')) {
          cat = AllergyCategory.material;
        } else if (name.toLowerCase().contains('peanut') || name.toLowerCase().contains('egg')) {
          cat = AllergyCategory.food;
        }
        return MedicalAllergyItem(
          id: 'alg-legacy-$index',
          substance: name,
          category: cat,
          reaction: 'Reported clinical adverse reaction',
          severity: AllergySeverity.moderate,
        );
      }).toList();
    } else {
      // By clinical rule: missing allergy data does NOT mean No Known Allergies!
      status = AllergyStatus.notRecorded;
    }

    final conditions = chronicConditions.asMap().entries.map((entry) {
      return MedicalConditionItem(
        id: 'cnd-legacy-${entry.key}',
        name: entry.value,
        status: MedicalConditionStatus.active,
      );
    }).toList();

    final meds = currentMedications.asMap().entries.map((entry) {
      return MedicationItem(
        id: 'med-legacy-${entry.key}',
        name: entry.value,
        dosage: 'As prescribed',
        frequency: 'Daily',
        status: MedicationStatus.current,
      );
    }).toList();

    return MedicalHistoryModel(
      allergyStatus: status,
      allergies: allergyItems,
      medicalConditions: conditions,
      medications: meds,
    );
  }

  @override
  List<Object?> get props => [
        allergyStatus,
        allergies,
        medicalConditions,
        medications,
        pastMedicalHistory,
        dentalHistory,
        additionalInfo,
        auditTrail,
        reviewedByClinicianName,
        reviewedByClinicianRole,
        lastReviewedDate,
        lastUpdated,
      ];
}
