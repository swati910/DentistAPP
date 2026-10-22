import 'package:ai_dental_app/core/state/view_state.dart';
import 'package:ai_dental_app/features/clinic_onboarding/data/clinic_onboarding_repository.dart';
import 'package:ai_dental_app/features/clinic_onboarding/domain/onboarding_form_data.dart';
import 'package:ai_dental_app/features/clinic_onboarding/view_model/clinic_onboarding_bloc.dart';
import 'package:ai_dental_app/features/clinic_onboarding/view_model/clinic_onboarding_event.dart';
import 'package:ai_dental_app/features/clinic_onboarding/view_model/clinic_onboarding_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClinicOnboardingBloc Tests', () {
    late MockClinicOnboardingRepository mockRepo;

    setUp(() {
      mockRepo = MockClinicOnboardingRepository();
    });

    test('preserves form data when step changes', () {
      final bloc = ClinicOnboardingBloc(repository: mockRepo);
      const testData = OnboardingFormData(clinicName: 'Tooth Fairy Clinic');

      bloc.add(const FormDataUpdated(testData));
      bloc.add(const StepChanged(1));

      expectLater(
        bloc.stream,
        emitsInOrder([
          const ClinicOnboardingState(currentStep: 0, formData: testData),
          const ClinicOnboardingState(currentStep: 1, formData: testData),
        ]),
      );
    });

    blocTest<ClinicOnboardingBloc, ClinicOnboardingState>(
      'submits clinic onboarding and receives created ClinicDetails',
      build: () => ClinicOnboardingBloc(repository: mockRepo),
      wait: const Duration(milliseconds: 1200),
      seed: () => const ClinicOnboardingState(
        currentStep: 3,
        formData: OnboardingFormData(
          clinicName: 'Apex Dental',
          clinicType: 'Solo Dental Practice',
          clinicEmail: 'clinic@apexdental.com',
          clinicPhone: '+91 80 4123 4567',
          city: 'Bengaluru',
          state: 'Karnataka',
          country: 'India',
          postalCode: '560001',
          adminFirstName: 'Elena',
          adminLastName: 'Rostova',
          adminEmail: 'elena@apexdental.com',
          adminPhone: '+91 98765 43210',
          adminRole: 'Clinic Owner / Chief Dentist',
          password: 'Password123!',
          confirmPassword: 'Password123!',
          primaryContactName: 'Dr. Elena Rostova',
          primaryPhone: '+91 98765 43210',
          primaryEmail: 'elena@apexdental.com',
          preferredContactMethod: 'Email',
          termsAccepted: true,
        ),
      ),
      act: (bloc) => bloc.add(SubmitOnboardingRequested()),
      expect: () => [
        predicate<ClinicOnboardingState>((state) => state.status == Status.loading),
        predicate<ClinicOnboardingState>((state) {
          return state.status == Status.success &&
              state.createdClinic != null &&
              state.createdClinic!.name == 'Apex Dental';
        }),
      ],
    );

    test('resets onboarding flow to step 0 with clean form data', () {
      final bloc = ClinicOnboardingBloc(repository: mockRepo);
      bloc.add(const StepChanged(3));
      bloc.add(ResetOnboardingFlow());

      expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<ClinicOnboardingState>((s) => s.currentStep == 3),
          predicate<ClinicOnboardingState>((s) => s.currentStep == 0 && s.formData == const OnboardingFormData()),
        ]),
      );
    });
  });
}
