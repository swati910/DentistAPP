import 'package:ai_dental_app/app/theme/app_theme.dart';
import 'package:ai_dental_app/core/errors/app_exception.dart';
import 'package:ai_dental_app/core/state/view_state.dart';
import 'package:ai_dental_app/features/patient_management/data/patient_repository.dart';
import 'package:ai_dental_app/features/patient_management/presentation/widgets/allergy_status_dialog.dart';
import 'package:ai_dental_app/features/patient_management/presentation/widgets/medical_history_audit_trail_dialog.dart';
import 'package:ai_dental_app/features/patient_management/presentation/widgets/medical_history_form_dialog.dart';
import 'package:ai_dental_app/features/patient_management/presentation/widgets/patient_medical_history_tab.dart';
import 'package:ai_dental_app/features/patient_management/view_model/patient_bloc.dart';
import 'package:ai_dental_app/features/patient_management/view_model/patient_event.dart';
import 'package:ai_dental_app/shared/models/medical_history_model.dart';
import 'package:ai_dental_app/shared/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockPatientRepository repository;

  final dentistUser = const UserModel(
    id: 'usr-dentist-01',
    email: 'dr.marcus@apexdental.com',
    firstName: 'Marcus',
    lastName: 'Vance',
    role: UserRole.dentist,
    permissions: UserPermissions(canEditMedicalHistory: true),
  );

  final authorizedStaffUser = const UserModel(
    id: 'usr-staff-auth',
    email: 'triage@apexdental.com',
    firstName: 'Pooja',
    lastName: 'Sharma',
    role: UserRole.staff,
    permissions: UserPermissions(canEditMedicalHistory: true),
  );

  final unauthorizedStaffUser = const UserModel(
    id: 'usr-staff-unauth',
    email: 'reception@apexdental.com',
    firstName: 'Kavita',
    lastName: 'Patel',
    role: UserRole.staff,
    permissions: UserPermissions(canEditMedicalHistory: false),
  );

  setUp(() {
    MockPatientRepository.resetToInitial();
    repository = MockPatientRepository();
  });

  group('Patient Medical History Repository CRUD & RBAC Tests', () {
    test('Dentist can add a new allergy and it logs an audit trail entry', () async {
      final initialPatient = repository.getPatientByIdSync('pat-001');
      final initialCount = initialPatient.resolvedMedicalHistory.allergies.length;

      const newAllergy = MedicalAllergyItem(
        substance: 'Latex',
        category: AllergyCategory.material,
        reaction: 'Contact dermatitis and localized erythema',
        severity: AllergySeverity.moderate,
        diagnosedDate: '2023-08-12',
      );

      final updatedPatient = await repository.addOrUpdateMedicalAllergy(
        patientId: 'pat-001',
        allergy: newAllergy,
        currentUser: dentistUser,
      );

      final medHistory = updatedPatient.resolvedMedicalHistory;
      expect(medHistory.allergies.length, initialCount + 1);
      expect(medHistory.allergies.any((a) => a.substance == 'Latex'), isTrue);
      expect(medHistory.allergyStatus, AllergyStatus.recorded);
      expect(updatedPatient.allergies.contains('Latex'), isTrue);

      // Verify Audit Trail
      expect(medHistory.auditTrail, isNotEmpty);
      final audit = medHistory.auditTrail.first;
      expect(audit.category, 'Allergy');
      expect(audit.action, 'Created');
      expect(audit.performedById, dentistUser.id);
      expect(audit.summary, contains('Latex'));
    });

    test('Updating an existing allergy modifies in-place without creating duplicate', () async {
      final initialPatient = repository.getPatientByIdSync('pat-001');
      final existingAllergy = initialPatient.resolvedMedicalHistory.allergies.first;
      final initialCount = initialPatient.resolvedMedicalHistory.allergies.length;

      final modifiedAllergy = existingAllergy.copyWith(
        severity: AllergySeverity.critical,
        reaction: 'Severe anaphylaxis requiring epinephrine',
      );

      final updatedPatient = await repository.addOrUpdateMedicalAllergy(
        patientId: 'pat-001',
        allergy: modifiedAllergy,
        currentUser: dentistUser,
      );

      final allergies = updatedPatient.resolvedMedicalHistory.allergies;
      expect(allergies.length, initialCount); // No duplicate!
      final found = allergies.firstWhere((a) => a.effectiveId == existingAllergy.effectiveId);
      expect(found.severity, AllergySeverity.critical);
      expect(found.reaction, contains('Severe anaphylaxis'));

      // Verify Audit Trail
      final audit = updatedPatient.resolvedMedicalHistory.auditTrail.first;
      expect(audit.action, 'Updated');
      expect(audit.performedByName, dentistUser.fullName);
    });

    test('Deleting an allergy removes it and records audit trail', () async {
      final initialPatient = repository.getPatientByIdSync('pat-001');
      final allergyToDelete = initialPatient.resolvedMedicalHistory.allergies.first;
      final initialCount = initialPatient.resolvedMedicalHistory.allergies.length;

      final updatedPatient = await repository.deleteMedicalAllergy(
        patientId: 'pat-001',
        allergyId: allergyToDelete.effectiveId,
        currentUser: dentistUser,
      );

      final allergies = updatedPatient.resolvedMedicalHistory.allergies;
      expect(allergies.length, initialCount - 1);
      expect(allergies.any((a) => a.effectiveId == allergyToDelete.effectiveId), isFalse);

      final audit = updatedPatient.resolvedMedicalHistory.auditTrail.first;
      expect(audit.action, 'Deleted');
      expect(audit.summary, contains(allergyToDelete.substance));
    });

    test('Adding and editing medical conditions maintains patient data integrity', () async {
      const condition = MedicalConditionItem(
        name: 'Type 1 Diabetes Mellitus',
        status: MedicalConditionStatus.controlled,
        dateDiagnosed: '2015-04',
        clinicalNotes: 'Insulin pump in situ; check morning blood glucose chairside.',
        requiresDentalPremedication: false,
      );

      final updatedPatient = await repository.addOrUpdateMedicalCondition(
        patientId: 'pat-001',
        condition: condition,
        currentUser: dentistUser,
      );

      expect(updatedPatient.resolvedMedicalHistory.medicalConditions.any((c) => c.name == 'Type 1 Diabetes Mellitus'), isTrue);
      expect(updatedPatient.chronicConditions.contains('Type 1 Diabetes Mellitus'), isTrue);

      final saved = updatedPatient.resolvedMedicalHistory.medicalConditions.firstWhere((c) => c.name == 'Type 1 Diabetes Mellitus');
      final modifiedCondition = saved.copyWith(status: MedicalConditionStatus.active);

      final secondUpdate = await repository.addOrUpdateMedicalCondition(
        patientId: 'pat-001',
        condition: modifiedCondition,
        currentUser: dentistUser,
      );

      final updatedItem = secondUpdate.resolvedMedicalHistory.medicalConditions.firstWhere((c) => c.effectiveId == saved.effectiveId);
      expect(updatedItem.status, MedicalConditionStatus.active);
    });

    test('Adding and updating medication manages current and historical lists properly', () async {
      const med = MedicationItem(
        name: 'Amoxicillin',
        dosage: '500 mg',
        frequency: 'TID for 7 days',
        status: MedicationStatus.current,
        prescribingPhysician: 'Dr. Marcus Vance',
      );

      final updatedPatient = await repository.addOrUpdateMedication(
        patientId: 'pat-001',
        medication: med,
        currentUser: dentistUser,
      );

      final currentMeds = updatedPatient.resolvedMedicalHistory.currentMedications;
      expect(currentMeds.any((m) => m.name == 'Amoxicillin'), isTrue);
      expect(updatedPatient.currentMedications.contains('Amoxicillin'), isTrue);

      // Discontinue medication
      final savedMed = updatedPatient.resolvedMedicalHistory.medications.firstWhere((m) => m.name == 'Amoxicillin');
      final discontinuedMed = savedMed.copyWith(status: MedicationStatus.historical);

      final secondUpdate = await repository.addOrUpdateMedication(
        patientId: 'pat-001',
        medication: discontinuedMed,
        currentUser: dentistUser,
      );

      expect(secondUpdate.resolvedMedicalHistory.currentMedications.any((m) => m.name == 'Amoxicillin'), isFalse);
      expect(secondUpdate.resolvedMedicalHistory.historicalMedications.any((m) => m.name == 'Amoxicillin'), isTrue);
    });

    test('Adding and deleting surgical / past history records', () async {
      const surgery = PastMedicalHistoryItem(
        event: 'Total Knee Arthroplasty (Left)',
        type: 'Orthopedic Surgery',
        approximateDate: '2022-11',
        facility: 'Fortis Hospital',
        notes: 'Joint replacement intact; antibiotic prophylaxis required.',
      );

      final updatedPatient = await repository.addOrUpdatePastMedicalHistoryItem(
        patientId: 'pat-001',
        item: surgery,
        currentUser: dentistUser,
      );

      final pastItems = updatedPatient.resolvedMedicalHistory.pastMedicalHistory;
      expect(pastItems.any((p) => p.event == 'Total Knee Arthroplasty (Left)'), isTrue);
      final savedItem = pastItems.firstWhere((p) => p.event == 'Total Knee Arthroplasty (Left)');

      final afterDelete = await repository.deletePastMedicalHistoryItem(
        patientId: 'pat-001',
        itemId: savedItem.effectiveId,
        currentUser: dentistUser,
      );

      expect(afterDelete.resolvedMedicalHistory.pastMedicalHistory.any((p) => p.effectiveId == savedItem.effectiveId), isFalse);
    });

    test('Updating patient allergy status explicitly updates review metadata', () async {
      final updatedPatient = await repository.updatePatientAllergyStatus(
        patientId: 'pat-001',
        status: AllergyStatus.noKnownAllergies,
        currentUser: dentistUser,
        notes: 'Verified verbally with patient on today\'s visit.',
      );

      expect(updatedPatient.resolvedMedicalHistory.allergyStatus, AllergyStatus.noKnownAllergies);
      expect(updatedPatient.resolvedMedicalHistory.reviewedByClinicianName, dentistUser.fullName);
    });

    test('Unauthorized staff cannot modify medical records and throws UnauthorizedException', () async {
      const testAllergy = MedicalAllergyItem(
        substance: 'Codeine',
        reaction: 'Nausea',
      );

      expect(
        () => repository.addOrUpdateMedicalAllergy(
          patientId: 'pat-001',
          allergy: testAllergy,
          currentUser: unauthorizedStaffUser,
        ),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('Authorized staff with permission CAN modify medical records', () async {
      const testAllergy = MedicalAllergyItem(
        substance: 'Codeine',
        reaction: 'Severe nausea',
      );

      final updated = await repository.addOrUpdateMedicalAllergy(
        patientId: 'pat-001',
        allergy: testAllergy,
        currentUser: authorizedStaffUser,
      );

      expect(updated.resolvedMedicalHistory.allergies.any((a) => a.substance == 'Codeine'), isTrue);
    });

    test('Validation rejects blank substance or condition name', () async {
      const blankAllergy = MedicalAllergyItem(
        substance: '   ',
        reaction: 'None',
      );

      expect(
        () => repository.addOrUpdateMedicalAllergy(
          patientId: 'pat-001',
          allergy: blankAllergy,
          currentUser: dentistUser,
        ),
        throwsA(isA<ValidationException>()),
      );

      const blankCondition = MedicalConditionItem(
        name: '',
      );

      expect(
        () => repository.addOrUpdateMedicalCondition(
          patientId: 'pat-001',
          condition: blankCondition,
          currentUser: dentistUser,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Attempting to delete non-existent item throws NotFoundException', () async {
      expect(
        () => repository.deleteMedicalAllergy(
          patientId: 'pat-001',
          allergyId: 'alg-non-existent-999',
          currentUser: dentistUser,
        ),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('Patient BLoC Medical History Event Tests', () {
    test('AddOrUpdateMedicalAllergySubmitted updates selectedPatient and sets isActionSuccess', () async {
      final bloc = PatientBloc(repository: repository);
      bloc.add(const SelectPatientRequested('pat-001'));
      await Future.delayed(const Duration(milliseconds: 400));

      const allergy = MedicalAllergyItem(
        substance: 'Erythromycin',
        category: AllergyCategory.medication,
        reaction: 'Gastric cramps',
        severity: AllergySeverity.mild,
      );

      bloc.add(
        AddOrUpdateMedicalAllergySubmitted(
          patientId: 'pat-001',
          allergy: allergy,
          currentUser: dentistUser,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 450));

      expect(bloc.state.isActionSuccess, isTrue);
      expect(bloc.state.successMessage, contains('Erythromycin'));
      expect(bloc.state.selectedPatient?.resolvedMedicalHistory.allergies.any((a) => a.substance == 'Erythromycin'), isTrue);

      await bloc.close();
    });

    test('DeleteMedicalAllergySubmitted removes allergy and updates selectedPatient', () async {
      final bloc = PatientBloc(repository: repository);
      bloc.add(const SelectPatientRequested('pat-001'));
      await Future.delayed(const Duration(milliseconds: 400));

      final existingAllergy = bloc.state.selectedPatient!.resolvedMedicalHistory.allergies.first;

      bloc.add(
        DeleteMedicalAllergySubmitted(
          patientId: 'pat-001',
          allergyId: existingAllergy.effectiveId,
          currentUser: dentistUser,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 450));

      expect(bloc.state.isActionSuccess, isTrue);
      expect(bloc.state.selectedPatient?.resolvedMedicalHistory.allergies.any((a) => a.effectiveId == existingAllergy.effectiveId), isFalse);

      await bloc.close();
    });

    test('Unauthorized user action emits Status.error with permission error message', () async {
      final bloc = PatientBloc(repository: repository);
      bloc.add(const SelectPatientRequested('pat-001'));
      await Future.delayed(const Duration(milliseconds: 400));

      const allergy = MedicalAllergyItem(
        substance: 'Aspirin',
        reaction: 'Bronchospasm',
      );

      bloc.add(
        AddOrUpdateMedicalAllergySubmitted(
          patientId: 'pat-001',
          allergy: allergy,
          currentUser: unauthorizedStaffUser,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 450));

      expect(bloc.state.status, Status.error);
      expect(bloc.state.errorMessage, contains('permission'));

      await bloc.close();
    });
  });

  group('Patient Medical History Widget Tests', () {
    Widget buildTestWidget({
      required Widget child,
      UserModel? user,
      PatientBloc? bloc,
    }) {
      return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => bloc ?? (PatientBloc(repository: repository)..add(const SelectPatientRequested('pat-001'))),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(size: Size(1440, 900)),
              child: child,
            ),
          ),
        ),
      );
    }

    testWidgets('PatientMedicalHistoryTab renders action buttons for authorized dentist', (tester) async {
      final patient = repository.getPatientByIdSync('pat-001');

      await tester.binding.setSurfaceSize(const Size(1440, 900));
      await tester.pumpWidget(
        buildTestWidget(
          child: PatientMedicalHistoryTab(
            patient: patient,
            currentUser: dentistUser,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Top action buttons
      expect(find.text('Add Medical History'), findsOneWidget);
      expect(find.text('Allergy Status'), findsOneWidget);
      expect(find.textContaining('Audit Trail'), findsOneWidget);

      // Section level buttons
      expect(find.text('Add Allergy'), findsOneWidget);
      expect(find.text('Add Condition'), findsOneWidget);
      expect(find.text('Add Medication'), findsOneWidget);
      expect(find.text('Add Procedure / Event'), findsOneWidget);
      expect(find.text('Edit Dental History'), findsOneWidget);
      expect(find.text('Edit Family & Lifestyle'), findsOneWidget);
    });

    testWidgets('PatientMedicalHistoryTab hides add/edit buttons for unauthorized staff and shows READ-ONLY badge', (tester) async {
      final patient = repository.getPatientByIdSync('pat-001');

      await tester.binding.setSurfaceSize(const Size(1440, 900));
      await tester.pumpWidget(
        buildTestWidget(
          child: PatientMedicalHistoryTab(
            patient: patient,
            currentUser: unauthorizedStaffUser,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('READ-ONLY'), findsOneWidget);
      expect(find.text('Add Medical History'), findsNothing);
      expect(find.text('Add Allergy'), findsNothing);
      expect(find.text('Add Condition'), findsNothing);
      expect(find.text('Add Medication'), findsNothing);
    });

    testWidgets('Tapping Add Medical History opens MedicalHistoryFormDialog', (tester) async {
      final patient = repository.getPatientByIdSync('pat-001');

      await tester.binding.setSurfaceSize(const Size(1440, 900));
      await tester.pumpWidget(
        buildTestWidget(
          child: PatientMedicalHistoryTab(
            patient: patient,
            currentUser: dentistUser,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final addBtn = find.text('Add Medical History');
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      expect(find.byType(MedicalHistoryFormDialog), findsOneWidget);
      expect(find.text('Record Category *'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save Record'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(MedicalHistoryFormDialog), findsNothing);
    });

    testWidgets('Tapping Audit Trail opens MedicalHistoryAuditTrailDialog', (tester) async {
      final patient = repository.getPatientByIdSync('pat-001');

      await tester.binding.setSurfaceSize(const Size(1440, 900));
      await tester.pumpWidget(
        buildTestWidget(
          child: PatientMedicalHistoryTab(
            patient: patient,
            currentUser: dentistUser,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final auditBtn = find.textContaining('Audit Trail');
      await tester.tap(auditBtn);
      await tester.pumpAndSettle();

      expect(find.byType(MedicalHistoryAuditTrailDialog), findsOneWidget);
      expect(find.text('Clinical Audit Trail & Log'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.byType(MedicalHistoryAuditTrailDialog), findsNothing);
    });

    testWidgets('AllergyStatusDialog requires explicit confirmation checkbox for No Known Allergies', (tester) async {
      bool saved = false;
      AllergyStatus? savedStatus;

      await tester.binding.setSurfaceSize(const Size(1440, 900));
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: AllergyStatusDialog(
              currentStatus: AllergyStatus.notRecorded,
              patientName: 'Ananya Deshmukh',
              hasRecordedAllergies: false,
              onSave: (st, notes) {
                saved = true;
                savedStatus = st;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Select NKA option
      await tester.tap(find.text(AllergyStatus.noKnownAllergies.displayName));
      await tester.pumpAndSettle();

      // Confirmation box should appear
      expect(find.text('Clinical Safety Confirmation *'), findsOneWidget);

      // Confirm Status button should be disabled until checkbox is checked
      final confirmBtn = find.widgetWithText(ElevatedButton, 'Confirm Status');
      // Tapping while disabled should not trigger save
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();
      expect(saved, isFalse);

      // Now check the confirmation checkbox
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();

      // Tap confirm status button
      await tester.tap(find.text('Confirm Status'));
      await tester.pumpAndSettle();

      expect(saved, isTrue);
      expect(savedStatus, AllergyStatus.noKnownAllergies);
    });
  });
}
