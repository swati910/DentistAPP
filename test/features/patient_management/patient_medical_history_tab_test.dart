import 'package:ai_dental_app/app/router/app_router.dart';
import 'package:ai_dental_app/app/theme/app_theme.dart';
import 'package:ai_dental_app/features/authentication/data/auth_repository.dart';
import 'package:ai_dental_app/features/authentication/view_model/auth_bloc.dart';
import 'package:ai_dental_app/features/patient_management/data/patient_repository.dart';
import 'package:ai_dental_app/features/patient_management/presentation/patient_details_screen.dart';
import 'package:ai_dental_app/features/patient_management/presentation/patient_list_screen.dart';
import 'package:ai_dental_app/features/patient_management/view_model/patient_bloc.dart';
import 'package:ai_dental_app/features/patient_management/view_model/patient_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockPatientRepository patientRepository;
  late MockAuthRepository authRepository;

  setUp(() {
    MockPatientRepository.resetToInitial();
    patientRepository = MockPatientRepository();
    authRepository = MockAuthRepository();
  });

  Widget buildTestApp({
    required Widget child,
    Size size = const Size(1440, 900),
    PatientBloc? customPatientBloc,
  }) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(authRepository: authRepository)),
        BlocProvider(
          create: (_) => customPatientBloc ?? PatientBloc(repository: patientRepository),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: MediaQuery(
          data: MediaQueryData(size: size),
          child: child,
        ),
      ),
    );
  }

  Future<void> settleScreen(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
  }

  group('Patient Medical History Tab & Detail Screen Tests', () {
    testWidgets('PatientDetailsScreen renders Medical History tab and Overview tab', (tester) async {
      final patient = patientRepository.getPatientByIdSync('pat-001');

      await tester.binding.setSurfaceSize(const Size(1440, 900));
      await tester.pumpWidget(
        buildTestApp(child: PatientDetailsScreen(patient: patient)),
      );
      await settleScreen(tester);

      // Check Tabs exist
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Medical History'), findsOneWidget);
      expect(find.text('AI Vision Insights'), findsOneWidget);
      expect(find.text('Dental Odontogram'), findsOneWidget);
      expect(find.text('Appointments & Visits'), findsOneWidget);
      expect(find.text('Clinical Notes'), findsOneWidget);

      // Verify "Insurance" tab does NOT exist
      expect(find.text('Insurance'), findsNothing);
      expect(find.text('Insurance Details'), findsNothing);
      expect(find.text('Insurance Coverage'), findsNothing);
    });

    testWidgets('Insurance is completely removed from PatientDetailsScreen Overview', (tester) async {
      final patient = patientRepository.getPatientByIdSync('pat-001');

      await tester.binding.setSurfaceSize(const Size(1440, 900));
      await tester.pumpWidget(
        buildTestApp(child: PatientDetailsScreen(patient: patient)),
      );
      await settleScreen(tester);

      // Verify that insurance provider and policy number are NOT displayed
      expect(find.text('Star Health Dental Plus'), findsNothing);
      expect(find.text('SH-DT-994821'), findsNothing);
      expect(find.text('Insurance Provider'), findsNothing);
      expect(find.text('Policy / Member ID'), findsNothing);

      // Verify Clinical Care Team card replaced it
      expect(find.text('Attending Clinical Team'), findsOneWidget);
      expect(find.text('View Full Medical History'), findsOneWidget);
    });

    testWidgets('Medical History Tab displays recorded allergies, conditions, and medications for pat-001', (tester) async {
      final patient = patientRepository.getPatientByIdSync('pat-001');

      await tester.binding.setSurfaceSize(const Size(1440, 1000));
      await tester.pumpWidget(
        buildTestApp(child: PatientDetailsScreen(patient: patient)),
      );
      await settleScreen(tester);

      // Switch to Medical History Tab
      await tester.tap(find.text('Medical History'));
      await settleScreen(tester);

      // Verify allergy alert banner and items
      expect(find.text('KNOWN ALLERGIES RECORDED'), findsOneWidget);
      expect(find.textContaining('Penicillin G / Beta-lactams'), findsOneWidget);
      expect(find.textContaining('Sulfa Drugs (Sulfamethoxazole)'), findsOneWidget);
      expect(find.textContaining('CRITICAL / ANAPHYLACTIC'), findsOneWidget);

      // Verify medical conditions
      expect(find.text('Existing Medical & Systemic Conditions'), findsOneWidget);
      expect(find.text('Mild Extrinsic Asthma'), findsOneWidget);

      // Verify medications
      expect(find.textContaining('Current & Prescribed Medications'), findsOneWidget);
      expect(find.text('Salbutamol Inhaler (Albuterol)'), findsOneWidget);

      // Verify past medical & surgical history
      expect(find.text('Past Medical & Surgical History'), findsOneWidget);
      expect(find.text('Laparoscopic Appendectomy'), findsOneWidget);

      // Verify dental history
      expect(find.text('Dental History & Precedents'), findsOneWidget);

      // Verify review footer
      expect(find.textContaining('Clinically Reviewed by'), findsOneWidget);
      expect(find.textContaining('HIPAA Encrypted Health Information'), findsOneWidget);
    });

    testWidgets('pat-003 with explicitly confirmed noKnownAllergies displays confirmed NKA banner', (tester) async {
      final patient = patientRepository.getPatientByIdSync('pat-003');

      await tester.binding.setSurfaceSize(const Size(1440, 1000));
      await tester.pumpWidget(
        buildTestApp(child: PatientDetailsScreen(patient: patient)),
      );
      await settleScreen(tester);

      // Switch to Medical History Tab
      await tester.tap(find.text('Medical History'));
      await settleScreen(tester);

      // Verify confirmed NKA banner
      expect(find.textContaining('NO KNOWN ALLERGIES'), findsOneWidget);
      expect(find.textContaining('No adverse drug or substance allergies currently recorded'), findsOneWidget);

      // Should not claim unreviewed or missing
      expect(find.text('Allergy history has not been confirmed for this patient'), findsNothing);
    });

    testWidgets('pat-005 with notRecorded allergy status displays unreviewed triage warning, NOT No Known Allergies', (tester) async {
      final patient = patientRepository.getPatientByIdSync('pat-005');

      await tester.binding.setSurfaceSize(const Size(1440, 1000));
      await tester.pumpWidget(
        buildTestApp(child: PatientDetailsScreen(patient: patient)),
      );
      await settleScreen(tester);

      // Switch to Medical History Tab
      await tester.tap(find.text('Medical History'));
      await settleScreen(tester);

      // Must display unreviewed warning
      expect(find.textContaining('NOT RECORDED'), findsOneWidget);
      expect(find.textContaining('Verify with patient or guardian before administering'), findsOneWidget);

      // Critical clinical rule: Must NOT display "No Known Allergies"
      expect(find.text('NO KNOWN ALLERGIES (NKA - CONFIRMED)'), findsNothing);
      expect(find.text('No adverse drug or substance allergies currently recorded in patient chart.'), findsNothing);
    });

    testWidgets('Direct ID navigation loads patient from repository correctly', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      await tester.pumpWidget(
        buildTestApp(child: const PatientDetailsScreen(patientId: 'pat-002')),
      );
      await settleScreen(tester);

      // pat-002 is Vikramaditya Rao
      expect(find.textContaining('Vikramaditya Rao'), findsOneWidget);
      expect(find.text('PT-2026-0043'), findsOneWidget);

      // Switch to Medical History Tab
      await tester.tap(find.text('Medical History'));
      await settleScreen(tester);

      // pat-002 has Natural Rubber Latex allergy and Essential Hypertension
      expect(find.textContaining('Natural Rubber Latex'), findsOneWidget);
      expect(find.text('Essential Hypertension (Stage 1)'), findsOneWidget);
      expect(find.text('Amlodipine Besylate'), findsOneWidget);
      expect(find.text('Right Inguinal Hernia Mesh Repair'), findsOneWidget);
    });

    testWidgets('PatientListScreen row click navigates to PatientDetailsScreen', (tester) async {
      final listBloc = PatientBloc(repository: patientRepository)
        ..add(const LoadPatientsRequested());

      await tester.binding.setSurfaceSize(const Size(1440, 900));
      await tester.pumpWidget(
        buildTestApp(
          child: const PatientListScreen(),
          customPatientBloc: listBloc,
        ),
      );
      await settleScreen(tester);

      // Find the first patient row by clicking on the patient name
      expect(find.text('Ananya Deshmukh'), findsOneWidget);
      await tester.tap(find.text('Ananya Deshmukh'));
      await settleScreen(tester);

      // Verify we navigated to PatientDetailsScreen
      expect(find.text('PT-2026-0042'), findsOneWidget);
      expect(find.text('Medical History'), findsOneWidget);
      expect(find.text('Chief Dental Complaint'), findsOneWidget);
    });

    testWidgets('PatientDetailsScreen without arguments renders safely without assertion errors', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      await tester.pumpWidget(
        buildTestApp(child: const PatientDetailsScreen()),
      );
      await settleScreen(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('Medical History'), findsOneWidget);
    });
  });
}
