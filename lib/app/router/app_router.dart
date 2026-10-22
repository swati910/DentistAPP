import 'package:flutter/material.dart';
import '../../features/authentication/presentation/login_screen.dart';
import '../../features/clinic_onboarding/presentation/clinic_onboarding_screen.dart';
import '../../features/clinic_settings/presentation/profile_screen.dart';
import '../../features/onboarding_status/presentation/onboarding_status_screen.dart';
import '../../features/password_recovery/presentation/forgot_password_screen.dart';
import '../../features/password_recovery/presentation/new_password_screen.dart';
import '../../features/password_recovery/presentation/password_reset_success_screen.dart';
import '../../features/password_recovery/presentation/reset_code_screen.dart';
import '../../features/payment/presentation/payment_checkout_screen.dart';
import '../../features/subscription/presentation/unified_subscription_screen.dart';
import '../../features/patient_management/presentation/patient_details_screen.dart';
import '../../features/patient_management/presentation/patient_list_screen.dart';
import '../../features/patient_management/presentation/register_patient_screen.dart';
import '../../features/user_management/presentation/invite_user_screen.dart';
import '../../features/user_management/presentation/user_list_screen.dart';
import '../../features/verification/presentation/email_verification_screen.dart';
import '../../features/verification/presentation/otp_verification_screen.dart';
import '../../shared/models/patient_model.dart';
import '../../shared/models/subscription_model.dart';
import 'route_names.dart';

/// Centralized route generator for the Dental Application
class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.initial:
      case RouteNames.login:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );

      case RouteNames.forgotPassword:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ForgotPasswordScreen(),
        );

      case RouteNames.resetCode:
        String? resetToken;
        if (settings.arguments is String) {
          resetToken = settings.arguments as String;
        } else if (settings.arguments is Map) {
          final map = settings.arguments as Map;
          resetToken = map['token'] as String?;
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ResetCodeScreen(token: resetToken),
        );

      case RouteNames.newPassword:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const NewPasswordScreen(),
        );

      case RouteNames.passwordResetSuccess:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PasswordResetSuccessScreen(),
        );

      case RouteNames.clinicOnboarding:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ClinicOnboardingScreen(),
        );

      case RouteNames.emailVerification:
        String email = 'contact@apexdental.com';
        String? token;
        if (settings.arguments is String) {
          email = settings.arguments as String;
        } else if (settings.arguments is Map) {
          final map = settings.arguments as Map;
          email = map['email'] as String? ?? email;
          token = map['token'] as String?;
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => EmailVerificationScreen(email: email, token: token),
        );

      case RouteNames.otpVerification:
        final email = settings.arguments as String? ?? 'contact@apexdental.com';
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OtpVerificationScreen(email: email),
        );

      case RouteNames.onboardingStatus:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const OnboardingStatusScreen(),
        );

      case RouteNames.subscriptionPlans:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const UnifiedSubscriptionScreen(),
        );

      case RouteNames.subscriptionCheckout:
        final plan = settings.arguments as SubscriptionPlan? ??
            const SubscriptionPlan(
              id: 'plan-pro',
              name: 'Professional Clinic',
              monthlyPrice: 3999,
              currency: '₹',
              billingPeriod: 'month',
              features: ['Unlimited AI Diagnostics', 'Multi-user access'],
              limits: {'Dentists': 5, 'Staff Seats': 15},
            );
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => PaymentCheckoutScreen(plan: plan),
        );

      case RouteNames.subscriptionStatus:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const UnifiedSubscriptionScreen(),
        );

      case RouteNames.profile:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ProfileScreen(initialTabIndex: 0),
        );

      case RouteNames.clinicSettings:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ProfileScreen(initialTabIndex: 1),
        );

      case RouteNames.users:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const UserListScreen(),
        );

      case RouteNames.inviteUser:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const InviteUserScreen(),
        );

      case RouteNames.patients:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PatientListScreen(),
        );

      case RouteNames.registerPatient:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const RegisterPatientScreen(),
        );

      case RouteNames.patientDetails:
        PatientModel? patient;
        String? patientId;
        if (settings.arguments is PatientModel) {
          patient = settings.arguments as PatientModel;
        } else if (settings.arguments is String) {
          patientId = settings.arguments as String;
        } else if (settings.arguments is Map) {
          final map = settings.arguments as Map;
          patient = map['patient'] as PatientModel?;
          patientId = map['id'] as String? ?? map['patientId'] as String?;
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => PatientDetailsScreen(
            patient: patient,
            patientId: patientId ?? patient?.id ?? 'pat-001',
          ),
        );

      case RouteNames.editPatient:
        final patient = settings.arguments as PatientModel;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RegisterPatientScreen(patientToEdit: patient),
        );

      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
