import 'package:equatable/equatable.dart';

class OnboardingFormData extends Equatable {
  // Step 1: Clinic Details
  final String clinicName;
  final String clinicType;
  final String clinicEmail;
  final String clinicPhone;
  final String address;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String website;

  // Step 2: Administrator Details
  final String adminFirstName;
  final String adminLastName;
  final String adminEmail;
  final String adminPhone;
  final String adminRole;
  final String password;
  final String confirmPassword;

  // Step 3: Contact Details
  final bool useAdminAsPrimaryContact;
  final String primaryContactName;
  final String primaryPhone;
  final String primaryEmail;
  final String alternatePhone;
  final String preferredContactMethod;

  // Step 4: Review & Legal
  final bool termsAccepted;

  const OnboardingFormData({
    this.clinicName = '',
    this.clinicType = 'Multi-Speciality Practice',
    this.clinicEmail = '',
    this.clinicPhone = '',
    this.address = '',
    this.city = '',
    this.state = '',
    this.country = 'India',
    this.postalCode = '',
    this.website = '',
    this.adminFirstName = '',
    this.adminLastName = '',
    this.adminEmail = '',
    this.adminPhone = '',
    this.adminRole = 'Clinic Director / Owner',
    this.password = '',
    this.confirmPassword = '',
    this.useAdminAsPrimaryContact = false,
    this.primaryContactName = '',
    this.primaryPhone = '',
    this.primaryEmail = '',
    this.alternatePhone = '',
    this.preferredContactMethod = 'Email',
    this.termsAccepted = true,
  });

  OnboardingFormData copyWith({
    String? clinicName,
    String? clinicType,
    String? clinicEmail,
    String? clinicPhone,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? website,
    String? adminFirstName,
    String? adminLastName,
    String? adminEmail,
    String? adminPhone,
    String? adminRole,
    String? password,
    String? confirmPassword,
    bool? useAdminAsPrimaryContact,
    String? primaryContactName,
    String? primaryPhone,
    String? primaryEmail,
    String? alternatePhone,
    String? preferredContactMethod,
    bool? termsAccepted,
  }) {
    return OnboardingFormData(
      clinicName: clinicName ?? this.clinicName,
      clinicType: clinicType ?? this.clinicType,
      clinicEmail: clinicEmail ?? this.clinicEmail,
      clinicPhone: clinicPhone ?? this.clinicPhone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      website: website ?? this.website,
      adminFirstName: adminFirstName ?? this.adminFirstName,
      adminLastName: adminLastName ?? this.adminLastName,
      adminEmail: adminEmail ?? this.adminEmail,
      adminPhone: adminPhone ?? this.adminPhone,
      adminRole: adminRole ?? this.adminRole,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      useAdminAsPrimaryContact: useAdminAsPrimaryContact ?? this.useAdminAsPrimaryContact,
      primaryContactName: primaryContactName ?? this.primaryContactName,
      primaryPhone: primaryPhone ?? this.primaryPhone,
      primaryEmail: primaryEmail ?? this.primaryEmail,
      alternatePhone: alternatePhone ?? this.alternatePhone,
      preferredContactMethod: preferredContactMethod ?? this.preferredContactMethod,
      termsAccepted: termsAccepted ?? this.termsAccepted,
    );
  }

  @override
  List<Object?> get props => [
        clinicName,
        clinicType,
        clinicEmail,
        clinicPhone,
        address,
        city,
        state,
        country,
        postalCode,
        website,
        adminFirstName,
        adminLastName,
        adminEmail,
        adminPhone,
        adminRole,
        password,
        confirmPassword,
        useAdminAsPrimaryContact,
        primaryContactName,
        primaryPhone,
        primaryEmail,
        alternatePhone,
        preferredContactMethod,
        termsAccepted,
      ];
}
