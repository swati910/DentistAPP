import 'package:ai_dental_app/app/theme/app_theme.dart';
import 'package:ai_dental_app/features/authentication/data/auth_repository.dart';
import 'package:ai_dental_app/features/authentication/presentation/login_screen.dart';
import 'package:ai_dental_app/features/authentication/view_model/auth_bloc.dart';
import 'package:ai_dental_app/features/clinic_onboarding/data/clinic_onboarding_repository.dart';
import 'package:ai_dental_app/features/clinic_onboarding/presentation/clinic_onboarding_screen.dart';
import 'package:ai_dental_app/features/clinic_onboarding/view_model/clinic_onboarding_bloc.dart';
import 'package:ai_dental_app/features/clinic_settings/data/clinic_settings_repository.dart';
import 'package:ai_dental_app/features/clinic_settings/presentation/profile_screen.dart';
import 'package:ai_dental_app/features/clinic_settings/view_model/clinic_settings_bloc.dart';
import 'package:ai_dental_app/features/payment/data/payment_repository.dart';
import 'package:ai_dental_app/features/payment/presentation/payment_checkout_screen.dart';
import 'package:ai_dental_app/features/payment/view_model/payment_bloc.dart';
import 'package:ai_dental_app/features/patient_management/data/patient_repository.dart';
import 'package:ai_dental_app/features/patient_management/presentation/patient_details_screen.dart';
import 'package:ai_dental_app/features/patient_management/presentation/patient_list_screen.dart';
import 'package:ai_dental_app/features/patient_management/presentation/register_patient_screen.dart';
import 'package:ai_dental_app/features/patient_management/view_model/patient_bloc.dart';
import 'package:ai_dental_app/features/patient_management/view_model/patient_event.dart';
import 'package:ai_dental_app/features/subscription/data/subscription_repository.dart';
import 'package:ai_dental_app/features/subscription/presentation/unified_subscription_screen.dart';
import 'package:ai_dental_app/features/subscription/view_model/subscription_bloc.dart';
import 'package:ai_dental_app/features/user_management/data/user_management_repository.dart';
import 'package:ai_dental_app/features/user_management/presentation/invite_user_screen.dart';
import 'package:ai_dental_app/features/user_management/presentation/user_list_screen.dart';
import 'package:ai_dental_app/features/user_management/view_model/user_management_bloc.dart';
import 'package:ai_dental_app/shared/models/patient_model.dart';
import 'package:ai_dental_app/shared/models/subscription_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const representativeWidths = [
    320.0, // Small mobile
    375.0, // Standard mobile (iPhone SE / compact)
    390.0, // Standard mobile (iPhone 14/15)
    430.0, // Large mobile (iPhone Pro Max / Plus)
    768.0, // Tablet portrait (iPad Mini / 10-inch)
    820.0, // Tablet portrait (iPad Air)
    1024.0, // Small laptop / Tablet landscape
    1280.0, // Standard Laptop
    1440.0, // Desktop display
    1920.0, // Large desktop monitor
  ];

  final testPatient = PatientModel(
    id: 'pat-audit-01',
    patientNumber: 'PT-2026-0001',
    firstName: 'Priya',
    lastName: 'Nambiar',
    email: 'priya.nambiar@example.com',
    phone: '+91 98765 43210',
    dateOfBirth: DateTime(1988, 4, 12),
    gender: PatientGender.female,
    bloodGroup: 'B+',
    address: 'Flat 402, Green Glen Heights, Bellandur',
    city: 'Bengaluru',
    state: 'Karnataka',
    postalCode: '560103',
    emergencyContactName: 'Rohan Nambiar',
    emergencyContactPhone: '+91 98765 00112',
    chiefComplaint: 'Mild sensitivity in upper right molar quadrant during mastication.',
    allergies: ['Penicillin Allergy'],
    chronicConditions: ['Type 2 Diabetes', 'Hypertension'],
    assignedDentistName: 'Dr. Elena Rostova',
    insuranceProvider: 'Star Health Dental Shield',
    insurancePolicyNumber: 'SH-DNT-998821',
    status: PatientStatus.active,
    riskLevel: PatientRiskLevel.medium,
    createdAt: DateTime.now().subtract(const Duration(days: 90)),
  );

  const testPlan = SubscriptionPlan(
    id: 'plan-pro',
    name: 'Professional Clinic',
    monthlyPrice: 3999,
    currency: '₹',
    billingPeriod: 'month',
    features: [
      'Up to 5 Dentists',
      '15 Staff Logins',
      'Unlimited AI Scans & Diagnostics',
      'Advanced Periodontal Charting',
    ],
    limits: {'Dentists': '5', 'Staff Seats': '15'},
  );

  Widget createTestHarness({required Widget child}) {
    final mockAuth = MockAuthRepository();
    final mockPatient = MockPatientRepository();
    final mockSettings = MockClinicSettingsRepository();
    final mockUsers = MockUserManagementRepository();
    final mockOnboarding = MockClinicOnboardingRepository();
    final mockSubscription = MockSubscriptionRepository();
    final mockPayment = MockPaymentRepository();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(authRepository: mockAuth)),
        BlocProvider(create: (_) => PatientBloc(repository: mockPatient)..add(const LoadPatientsRequested())),
        BlocProvider(create: (_) => ClinicSettingsBloc(repository: mockSettings)),
        BlocProvider(create: (_) => UserManagementBloc(repository: mockUsers)),
        BlocProvider(create: (_) => ClinicOnboardingBloc(repository: mockOnboarding)),
        BlocProvider(create: (_) => SubscriptionBloc(repository: mockSubscription)),
        BlocProvider(
          create: (_) => PaymentBloc(
            paymentRepository: mockPayment,
            subscriptionRepository: mockSubscription,
          ),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: child,
      ),
    );
  }

  group('Project-Wide Responsive UI Audit - All Screen Viewports', () {
    testWidgets('LoginScreen adapts across all 10 device categories without overflow', (tester) async {
      for (final width in representativeWidths) {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(createTestHarness(child: const LoginScreen()));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'Overflow detected at width $width on LoginScreen');
      }
    });

    testWidgets('RegisterPatientScreen stepper adapts across all 10 device categories without overflow', (tester) async {
      for (final width in representativeWidths) {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(createTestHarness(child: const RegisterPatientScreen()));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'Overflow detected at width $width on RegisterPatientScreen');
      }
    });

    testWidgets('PatientListScreen adapts metrics and table/cards across all 10 device categories', (tester) async {
      for (final width in representativeWidths) {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(createTestHarness(child: const PatientListScreen()));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'Overflow detected at width $width on PatientListScreen');
      }
    });

    testWidgets('PatientDetailsScreen header, tabs, and odontogram adapt across all 10 device categories', (tester) async {
      for (final width in representativeWidths) {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(createTestHarness(child: PatientDetailsScreen(patient: testPatient)));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'Overflow detected at width $width on PatientDetailsScreen');
      }
    });

    testWidgets('Clinic Settings & ProfileScreen adapts across all 10 device categories', (tester) async {
      for (final width in representativeWidths) {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(createTestHarness(child: const ProfileScreen()));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'Overflow detected at width $width on ProfileScreen');
      }
    });

    testWidgets('UserListScreen adapts table and cards across all 10 device categories', (tester) async {
      for (final width in representativeWidths) {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(createTestHarness(child: const UserListScreen()));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'Overflow detected at width $width on UserListScreen');
      }
    });

    testWidgets('InviteUserScreen adapts across all 10 device categories', (tester) async {
      for (final width in representativeWidths) {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(createTestHarness(child: const InviteUserScreen()));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'Overflow detected at width $width on InviteUserScreen');
      }
    });

    testWidgets('ClinicOnboardingScreen multi-step form adapts across all 10 device categories', (tester) async {
      for (final width in representativeWidths) {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(createTestHarness(child: const ClinicOnboardingScreen()));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'Overflow detected at width $width on ClinicOnboardingScreen');
      }
    });

    testWidgets('UnifiedSubscriptionScreen adapts plan tiers across all 10 device categories', (tester) async {
      for (final width in representativeWidths) {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(createTestHarness(child: const UnifiedSubscriptionScreen()));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'Overflow detected at width $width on UnifiedSubscriptionScreen');
      }
    });

    testWidgets('PaymentCheckoutScreen adapts summary and gateway controls across all 10 device categories', (tester) async {
      for (final width in representativeWidths) {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(createTestHarness(child: const PaymentCheckoutScreen(plan: testPlan)));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'Overflow detected at width $width on PaymentCheckoutScreen');
      }
    });
  });
}
