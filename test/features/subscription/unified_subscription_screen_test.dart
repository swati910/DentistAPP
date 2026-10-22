import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_dental_app/app/theme/app_theme.dart';
import 'package:ai_dental_app/features/subscription/data/subscription_repository.dart';
import 'package:ai_dental_app/features/subscription/presentation/unified_subscription_screen.dart';
import 'package:ai_dental_app/features/subscription/view_model/subscription_bloc.dart';

void main() {
  group('UnifiedSubscriptionScreen Tests', () {
    testWidgets('renders both Current Plan and Available Plans on a single unified page', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: BlocProvider(
            create: (_) => SubscriptionBloc(repository: MockSubscriptionRepository()),
            child: const UnifiedSubscriptionScreen(),
          ),
        ),
      );

      // Initial loading
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      // Section A: Current Plan is displayed
      expect(find.text('Current Plan & Billing Status'), findsOneWidget);
      expect(find.text('CURRENT PLAN'), findsOneWidget);
      expect(find.text('Upgrade Plan'), findsOneWidget);

      // Section B: Available Plans are displayed on the same page
      expect(find.text('Available Practice Plans'), findsOneWidget);
      expect(find.text('Professional Clinic'), findsWidgets);
      expect(find.text('Current Active Plan'), findsOneWidget);
    });
  });
}
