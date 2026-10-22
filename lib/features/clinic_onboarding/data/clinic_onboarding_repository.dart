import '../../../core/errors/app_exception.dart';
import '../../../shared/models/clinic_model.dart';
import '../domain/onboarding_form_data.dart';

abstract class ClinicOnboardingRepository {
  Future<ClinicDetails> submitClinicOnboarding(OnboardingFormData data);
}

class MockClinicOnboardingRepository implements ClinicOnboardingRepository {
  @override
  Future<ClinicDetails> submitClinicOnboarding(OnboardingFormData data) async {
    await Future.delayed(const Duration(milliseconds: 900));

    if (data.clinicName.toLowerCase().contains('fail')) {
      throw const ServerException('Registration failed due to a server collision. Please retry with a valid clinic name.');
    }

    final primaryEmail = data.primaryEmail.isNotEmpty
        ? data.primaryEmail
        : (data.clinicEmail.isNotEmpty ? data.clinicEmail : data.adminEmail);

    final primaryPhone = data.primaryPhone.isNotEmpty
        ? data.primaryPhone
        : (data.clinicPhone.isNotEmpty ? data.clinicPhone : data.adminPhone);

    final contactName = data.primaryContactName.isNotEmpty
        ? data.primaryContactName
        : '${data.adminFirstName} ${data.adminLastName}'.trim();

    return ClinicDetails(
      id: 'cln-${DateTime.now().millisecondsSinceEpoch}',
      name: data.clinicName,
      clinicType: data.clinicType,
      address: data.address,
      city: data.city,
      state: data.state,
      country: data.country,
      postalCode: data.postalCode,
      website: data.website.isNotEmpty ? data.website : null,
      primaryContactName: contactName,
      primaryPhone: primaryPhone,
      primaryEmail: primaryEmail,
      alternatePhone: data.alternatePhone.isNotEmpty ? data.alternatePhone : null,
      status: ClinicStatus.pending,
      onboardingStatus: InternalOnboardingStatus.verificationPending,
      isEmailVerified: false,
      isSubscriptionActive: false,
    );
  }
}
