import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_dental_app/app/theme/app_theme.dart';
import 'package:ai_dental_app/features/authentication/data/auth_repository.dart';
import 'package:ai_dental_app/features/authentication/view_model/auth_bloc.dart';
import 'package:ai_dental_app/features/clinic_settings/data/clinic_settings_repository.dart';
import 'package:ai_dental_app/features/clinic_settings/presentation/profile_screen.dart';
import 'package:ai_dental_app/features/clinic_settings/view_model/clinic_settings_bloc.dart';

void main() {
  group('ProfileScreen & Clinic Settings Integration Tests', () {
    testWidgets('renders Profile screen with User Profile and Clinic Settings tabs', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => AuthBloc(authRepository: MockAuthRepository()),
            ),
            BlocProvider(
              create: (_) => ClinicSettingsBloc(repository: MockClinicSettingsRepository()),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ProfileScreen(initialTabIndex: 0),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      // Tab 1: User Profile is active
      expect(find.text('User Profile'), findsOneWidget);
      expect(find.text('Clinic Settings'), findsOneWidget);
      expect(find.text('Operational & AI Rules'), findsOneWidget);

      // Verify User Profile content
      expect(find.text('Authorized Clinical Permissions'), findsOneWidget);
      expect(find.text('Password & Recovery'), findsOneWidget);

      // Tap Clinic Settings tab
      final clinicTab = find.text('Clinic Settings');
      await tester.tap(clinicTab);
      await tester.pumpAndSettle();

      // Verify Clinic Profile form is displayed
      expect(find.text('Clinic Profile Information'), findsOneWidget);
      expect(find.text('Clinic Name *'), findsOneWidget);
      expect(find.text('Address *'), findsOneWidget);
      expect(find.text('Save Clinic Profile'), findsOneWidget);
    });

    testWidgets('initialTabIndex 1 opens directly to Clinic Settings', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => AuthBloc(authRepository: MockAuthRepository()),
            ),
            BlocProvider(
              create: (_) => ClinicSettingsBloc(repository: MockClinicSettingsRepository()),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ProfileScreen(initialTabIndex: 1),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      // Should open directly with Clinic Settings form visible
      expect(find.text('Clinic Profile Information'), findsOneWidget);
      expect(find.text('Save Clinic Profile'), findsOneWidget);
    });
  });
}
