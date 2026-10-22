import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_dental_app/app/router/route_names.dart';
import 'package:ai_dental_app/app/theme/app_theme.dart';
import 'package:ai_dental_app/features/patient_management/presentation/register_patient_screen.dart';

void main() {
  group('RegisterPatientScreen Stepper Form Tests', () {
    testWidgets('Stepper renders step indicator and progresses through steps with validation', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const RegisterPatientScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Step 1: Demographics is active
      expect(find.text('Step 1: Demographics'), findsOneWidget);
      expect(find.text('1. Personal Information & Identity'), findsOneWidget);

      // Verify Next Step button exists
      final nextButton = find.text('Next Step');
      expect(nextButton, findsOneWidget);

      // Try tapping Next without filling required fields -> should fail validation and stay on Step 1
      await tester.tap(nextButton);
      await tester.pumpAndSettle();
      expect(find.text('First Name is required'), findsOneWidget);
      expect(find.text('Last Name is required'), findsOneWidget);

      // Fill in Step 1 fields
      await tester.enterText(find.widgetWithText(TextField, 'e.g. Ananya'), 'Meera');
      await tester.enterText(find.widgetWithText(TextField, 'e.g. Deshmukh'), 'Nair');
      await tester.enterText(find.widgetWithText(TextField, '+91 98765 43210'), '+91 98111 22334');
      await tester.pumpAndSettle();

      // Tap Next Step -> should advance to Step 2
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Step 2: Address & Emergency Contact
      expect(find.text('2. Residential Address & Emergency Contact'), findsOneWidget);
      expect(find.text('Street Address (Optional)'), findsOneWidget);

      // Verify user can advance from Step 2 WITHOUT filling Street Address (Street Address is optional!)
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Step 3: Clinical Profile
      expect(find.text('3. Clinical History & Practitioner Assignment'), findsOneWidget);

      // Verify Insurance section is completely absent from the form
      expect(find.text('Patient has Active Dental Insurance Coverage'), findsNothing);
      expect(find.text('Insurance Provider / Payer'), findsNothing);
      expect(find.text('Policy / Member ID'), findsNothing);

      // Fill Chief Complaint
      await tester.enterText(
        find.widgetWithText(TextField, 'e.g. Sensitivity in upper right premolar, routine scaling...'),
        'Routine dental checkup',
      );
      await tester.pumpAndSettle();

      // Advance to Step 4: Final Review & Confirmation
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Step 4: Review
      expect(find.text('4. Final Review & Confirmation'), findsOneWidget);
      expect(find.text('Patient Demographics'), findsOneWidget);
      expect(find.text('Meera Nair'), findsOneWidget);
      expect(find.text('None provided (Optional)'), findsOneWidget); // Verifies optional address display in review
      expect(find.text('Insurance'), findsNothing); // Verifies insurance is completely excluded from review

      // Verify navigation backward preserves data
      final backButton = find.text('Back');
      expect(backButton, findsOneWidget);
      await tester.ensureVisible(backButton);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Should be back on Step 3
      expect(find.text('3. Clinical History & Practitioner Assignment'), findsOneWidget);

      await tester.ensureVisible(backButton);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Should be back on Step 2
      expect(find.text('2. Residential Address & Emergency Contact'), findsOneWidget);

      await tester.ensureVisible(backButton);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Should be back on Step 1 with entered data preserved
      expect(find.text('1. Personal Information & Identity'), findsOneWidget);
      expect(find.text('Meera'), findsOneWidget);
      expect(find.text('Nair'), findsOneWidget);
      expect(find.text('+91 98111 22334'), findsOneWidget);
    });

    testWidgets('Submitting registration at Step 4 without street address succeeds', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          routes: {
            RouteNames.patients: (context) => const Scaffold(body: Text('Patients Page')),
          },
          home: const RegisterPatientScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Step 1: Fill required demographics
      await tester.enterText(find.widgetWithText(TextField, 'e.g. Ananya'), 'Aarav');
      await tester.enterText(find.widgetWithText(TextField, 'e.g. Deshmukh'), 'Sharma');
      await tester.enterText(find.widgetWithText(TextField, '+91 98765 43210'), '+91 99887 76655');
      await tester.pumpAndSettle();

      // Next to Step 2
      final nextButton = find.text('Next Step');
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Step 2: Leave Street Address empty
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Step 3: Enter complaint
      await tester.enterText(
        find.widgetWithText(TextField, 'e.g. Sensitivity in upper right premolar, routine scaling...'),
        'Wisdom tooth pain',
      );
      await tester.pumpAndSettle();

      // Next to Step 4
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Step 4: Submit button is 'Register Patient'
      final submitButtons = find.widgetWithText(ElevatedButton, 'Register Patient');
      expect(submitButtons, findsWidgets);
      await tester.ensureVisible(submitButtons.first);
      await tester.tap(submitButtons.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Verifies navigation to Patients Page succeeds after submission
      expect(find.text('Patients Page'), findsOneWidget);
    });
  });
}
