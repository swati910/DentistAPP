import 'package:equatable/equatable.dart';
import '../../../shared/models/medical_history_model.dart';
import '../../../shared/models/patient_model.dart';
import '../../../shared/models/user_model.dart';

abstract class PatientEvent extends Equatable {
  const PatientEvent();

  @override
  List<Object?> get props => [];
}

class LoadPatientsRequested extends PatientEvent {
  const LoadPatientsRequested();
}

class SearchQueryChanged extends PatientEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class StatusFilterChanged extends PatientEvent {
  final PatientStatus? status;

  const StatusFilterChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class RiskFilterChanged extends PatientEvent {
  final PatientRiskLevel? risk;

  const RiskFilterChanged(this.risk);

  @override
  List<Object?> get props => [risk];
}

class SortOrderChanged extends PatientEvent {
  final String sortBy; // 'recent', 'name', 'risk', 'age'

  const SortOrderChanged(this.sortBy);

  @override
  List<Object?> get props => [sortBy];
}

class SelectPatientRequested extends PatientEvent {
  final String patientId;

  const SelectPatientRequested(this.patientId);

  @override
  List<Object?> get props => [patientId];
}

class RegisterPatientSubmitted extends PatientEvent {
  final PatientModel patient;
  final UserModel currentUser;

  const RegisterPatientSubmitted({
    required this.patient,
    required this.currentUser,
  });

  @override
  List<Object?> get props => [patient, currentUser];
}

class UpdatePatientSubmitted extends PatientEvent {
  final PatientModel patient;
  final UserModel currentUser;

  const UpdatePatientSubmitted({
    required this.patient,
    required this.currentUser,
  });

  @override
  List<Object?> get props => [patient, currentUser];
}

class ArchivePatientRequested extends PatientEvent {
  final String patientId;
  final UserModel currentUser;

  const ArchivePatientRequested({
    required this.patientId,
    required this.currentUser,
  });

  @override
  List<Object?> get props => [patientId, currentUser];
}

class AddClinicalNoteSubmitted extends PatientEvent {
  final String patientId;
  final String title;
  final String content;
  final UserModel currentUser;

  const AddClinicalNoteSubmitted({
    required this.patientId,
    required this.title,
    required this.content,
    required this.currentUser,
  });

  @override
  List<Object?> get props => [patientId, title, content, currentUser];
}

class ScheduleAppointmentSubmitted extends PatientEvent {
  final String patientId;
  final DateTime date;
  final String timeSlot;
  final String procedure;
  final String dentistName;
  final UserModel currentUser;

  const ScheduleAppointmentSubmitted({
    required this.patientId,
    required this.date,
    required this.timeSlot,
    required this.procedure,
    required this.dentistName,
    required this.currentUser,
  });

  @override
  List<Object?> get props => [
        patientId,
        date,
        timeSlot,
        procedure,
        dentistName,
        currentUser,
      ];
}

class AddOrUpdateMedicalAllergySubmitted extends PatientEvent {
  final String patientId;
  final MedicalAllergyItem allergy;
  final UserModel currentUser;

  const AddOrUpdateMedicalAllergySubmitted({
    required this.patientId,
    required this.allergy,
    required this.currentUser,
  });

  @override
  List<Object?> get props => [patientId, allergy, currentUser];
}

class DeleteMedicalAllergySubmitted extends PatientEvent {
  final String patientId;
  final String allergyId;
  final UserModel currentUser;

  const DeleteMedicalAllergySubmitted({
    required this.patientId,
    required this.allergyId,
    required this.currentUser,
  });

  @override
  List<Object?> get props => [patientId, allergyId, currentUser];
}

class UpdatePatientAllergyStatusSubmitted extends PatientEvent {
  final String patientId;
  final AllergyStatus status;
  final UserModel currentUser;
  final String? notes;

  const UpdatePatientAllergyStatusSubmitted({
    required this.patientId,
    required this.status,
    required this.currentUser,
    this.notes,
  });

  @override
  List<Object?> get props => [patientId, status, currentUser, notes];
}

class AddOrUpdateMedicalConditionSubmitted extends PatientEvent {
  final String patientId;
  final MedicalConditionItem condition;
  final UserModel currentUser;

  const AddOrUpdateMedicalConditionSubmitted({
    required this.patientId,
    required this.condition,
    required this.currentUser,
  });

  @override
  List<Object?> get props => [patientId, condition, currentUser];
}

class DeleteMedicalConditionSubmitted extends PatientEvent {
  final String patientId;
  final String conditionId;
  final UserModel currentUser;

  const DeleteMedicalConditionSubmitted({
    required this.patientId,
    required this.conditionId,
    required this.currentUser,
  });

  @override
  List<Object?> get props => [patientId, conditionId, currentUser];
}

class AddOrUpdateMedicationSubmitted extends PatientEvent {
  final String patientId;
  final MedicationItem medication;
  final UserModel currentUser;

  const AddOrUpdateMedicationSubmitted({
    required this.patientId,
    required this.medication,
    required this.currentUser,
  });

  @override
  List<Object?> get props => [patientId, medication, currentUser];
}

class DeleteMedicationSubmitted extends PatientEvent {
  final String patientId;
  final String medicationId;
  final UserModel currentUser;

  const DeleteMedicationSubmitted({
    required this.patientId,
    required this.medicationId,
    required this.currentUser,
  });

  @override
  List<Object?> get props => [patientId, medicationId, currentUser];
}

class AddOrUpdatePastMedicalHistorySubmitted extends PatientEvent {
  final String patientId;
  final PastMedicalHistoryItem item;
  final UserModel currentUser;

  const AddOrUpdatePastMedicalHistorySubmitted({
    required this.patientId,
    required this.item,
    required this.currentUser,
  });

  @override
  List<Object?> get props => [patientId, item, currentUser];
}

class DeletePastMedicalHistorySubmitted extends PatientEvent {
  final String patientId;
  final String itemId;
  final UserModel currentUser;

  const DeletePastMedicalHistorySubmitted({
    required this.patientId,
    required this.itemId,
    required this.currentUser,
  });

  @override
  List<Object?> get props => [patientId, itemId, currentUser];
}

class UpdatePastDentalHistorySubmitted extends PatientEvent {
  final String patientId;
  final PastDentalHistory dentalHistory;
  final UserModel currentUser;

  const UpdatePastDentalHistorySubmitted({
    required this.patientId,
    required this.dentalHistory,
    required this.currentUser,
  });

  @override
  List<Object?> get props => [patientId, dentalHistory, currentUser];
}

class UpdateAdditionalMedicalInfoSubmitted extends PatientEvent {
  final String patientId;
  final AdditionalMedicalInfo additionalInfo;
  final UserModel currentUser;

  const UpdateAdditionalMedicalInfoSubmitted({
    required this.patientId,
    required this.additionalInfo,
    required this.currentUser,
  });

  @override
  List<Object?> get props => [patientId, additionalInfo, currentUser];
}

