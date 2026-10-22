import '../../../core/errors/app_exception.dart';
import '../../../shared/models/medical_history_model.dart';
import '../../../shared/models/patient_model.dart';
import '../../../shared/models/user_model.dart';

abstract class PatientRepository {
  Future<List<PatientModel>> getPatients({
    String? query,
    PatientStatus? status,
    PatientRiskLevel? risk,
    String? sortBy,
  });

  Future<PatientModel> getPatientById(String id);

  Future<PatientModel> registerPatient({
    required PatientModel patient,
    required UserModel currentUser,
  });

  Future<PatientModel> updatePatient({
    required PatientModel patient,
    required UserModel currentUser,
  });

  Future<bool> archivePatient({
    required String patientId,
    required UserModel currentUser,
  });

  Future<ClinicalNote> addClinicalNote({
    required String patientId,
    required String title,
    required String content,
    required UserModel currentUser,
  });

  Future<PatientAppointment> scheduleAppointment({
    required String patientId,
    required DateTime date,
    required String timeSlot,
    required String procedure,
    required String dentistName,
    required UserModel currentUser,
  });

  Future<Map<String, dynamic>> getPatientStatistics();

  Future<PatientModel> addOrUpdateMedicalAllergy({
    required String patientId,
    required MedicalAllergyItem allergy,
    required UserModel currentUser,
  });

  Future<PatientModel> deleteMedicalAllergy({
    required String patientId,
    required String allergyId,
    required UserModel currentUser,
  });

  Future<PatientModel> updatePatientAllergyStatus({
    required String patientId,
    required AllergyStatus status,
    required UserModel currentUser,
    String? notes,
  });

  Future<PatientModel> addOrUpdateMedicalCondition({
    required String patientId,
    required MedicalConditionItem condition,
    required UserModel currentUser,
  });

  Future<PatientModel> deleteMedicalCondition({
    required String patientId,
    required String conditionId,
    required UserModel currentUser,
  });

  Future<PatientModel> addOrUpdateMedication({
    required String patientId,
    required MedicationItem medication,
    required UserModel currentUser,
  });

  Future<PatientModel> deleteMedication({
    required String patientId,
    required String medicationId,
    required UserModel currentUser,
  });

  Future<PatientModel> addOrUpdatePastMedicalHistoryItem({
    required String patientId,
    required PastMedicalHistoryItem item,
    required UserModel currentUser,
  });

  Future<PatientModel> deletePastMedicalHistoryItem({
    required String patientId,
    required String itemId,
    required UserModel currentUser,
  });

  Future<PatientModel> updatePastDentalHistory({
    required String patientId,
    required PastDentalHistory dentalHistory,
    required UserModel currentUser,
  });

  Future<PatientModel> updateAdditionalMedicalInfo({
    required String patientId,
    required AdditionalMedicalInfo additionalInfo,
    required UserModel currentUser,
  });
}

class MockPatientRepository implements PatientRepository {
  static final MockPatientRepository _instance = MockPatientRepository._internal();
  factory MockPatientRepository() => _instance;

  static late List<PatientModel> _sharedPatients;
  static bool _isInitialized = false;

  MockPatientRepository._internal() {
    if (!_isInitialized) {
      resetToInitial();
    }
  }

  static void resetToInitial() {
    _sharedPatients = [
      PatientModel(
        id: 'pat-001',
        patientNumber: 'PT-2026-0042',
        firstName: 'Ananya',
        lastName: 'Deshmukh',
        email: 'ananya.deshmukh@gmail.com',
        phone: '+91 98234 11223',
        dateOfBirth: DateTime(1994, 5, 14),
        gender: PatientGender.female,
        bloodGroup: 'O+',
        address: '74 Coral Heights, Indiranagar',
        city: 'Bengaluru',
        state: 'Karnataka',
        postalCode: '560038',
        emergencyContactName: 'Rahul Deshmukh',
        emergencyContactPhone: '+91 98234 99887',
        emergencyRelationship: 'Spouse',
        allergies: const ['Penicillin', 'Sulfa Drugs'],
        chronicConditions: const ['Mild Asthma'],
        currentMedications: const ['Salbutamol Inhaler (PRN)'],
        chiefComplaint: 'Sensitivity in upper right premolar and routine dental prophylaxis.',
        riskLevel: PatientRiskLevel.medium,
        status: PatientStatus.active,
        insuranceProvider: 'Star Health Dental Plus',
        insurancePolicyNumber: 'SH-DT-994821',
        isInsuranceActive: true,
        assignedDentistId: 'usr-02',
        assignedDentistName: 'Dr. Marcus Vance',
        lastVisitDate: DateTime.now().subtract(const Duration(days: 14)),
        nextAppointmentDate: DateTime.now().add(const Duration(days: 7)),
        totalAiScans: 4,
        recentAiRiskScore: 78,
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        teethRecords: const [
          ToothRecord(toothNumber: 14, condition: ToothCondition.caries, notes: 'Class II occlusal-distal lesion detected by AI', surface: 'Distal-Occlusal'),
          ToothRecord(toothNumber: 16, condition: ToothCondition.treated, notes: 'Composite restoration (2025) intact', surface: 'Occlusal'),
          ToothRecord(toothNumber: 36, condition: ToothCondition.rootCanal, notes: 'RCT with porcelain fused to metal crown'),
          ToothRecord(toothNumber: 46, condition: ToothCondition.healthy),
        ],
        aiScans: [
          AiScanRecord(
            id: 'scn-101',
            scanDate: DateTime.now().subtract(const Duration(days: 14)),
            scanType: 'Bitewing X-Ray (Right Quad)',
            overallHealthScore: 78,
            summary: 'Localized enamel demineralization on Tooth #14 distal edge with 92% AI diagnostic confidence.',
            isReviewedByDentist: true,
            reviewedByDentistName: 'Dr. Marcus Vance',
            findings: const [
              AiFinding(
                id: 'fnd-1',
                toothNumber: 14,
                findingType: 'Interproximal Caries',
                confidenceScore: 0.92,
                severity: PatientRiskLevel.medium,
                description: 'Sub-surface radiolucency in distal enamel margin of tooth 14 extending to dentino-enamel junction.',
                recommendation: 'Restorative composite restoration (Class II) indicated.',
              ),
              AiFinding(
                id: 'fnd-2',
                toothNumber: 15,
                findingType: 'Early Demineralization',
                confidenceScore: 0.86,
                severity: PatientRiskLevel.low,
                description: 'Incipient surface micro-pore loss in mesial enamel.',
                recommendation: 'High-fluoride remineralizing varnish treatment.',
              ),
            ],
          ),
        ],
        appointments: [
          PatientAppointment(
            id: 'apt-01',
            patientId: 'pat-001',
            dentistName: 'Dr. Marcus Vance',
            date: DateTime.now().add(const Duration(days: 7, hours: 2)),
            timeSlot: '10:30 AM - 11:15 AM',
            procedure: 'Class II Composite Filling #14',
            status: 'Scheduled',
            notes: 'Patient allergic to Penicillin. Use alternative antibiotic if prophylaxis needed.',
          ),
          PatientAppointment(
            id: 'apt-00',
            patientId: 'pat-001',
            dentistName: 'Dr. Marcus Vance',
            date: DateTime.now().subtract(const Duration(days: 14)),
            timeSlot: '02:00 PM - 02:45 PM',
            procedure: 'Dental Exam & AI Radiograph Scan',
            status: 'Completed',
            notes: 'Comprehensive bitewings captured and processed.',
          ),
        ],
        clinicalNotes: [
          ClinicalNote(
            id: 'not-01',
            patientId: 'pat-001',
            authorName: 'Dr. Marcus Vance',
            authorRole: 'Lead Dentist',
            date: DateTime.now().subtract(const Duration(days: 14)),
            title: 'AI Radiograph Review & Treatment Plan',
            content: 'Reviewed AI bitewing scan scn-101. Confirmed Class II carious lesion on 14-DO. Scheduled for composite restoration under local anesthesia. Noted Penicillin allergy.',
            isFlagged: true,
          ),
          ClinicalNote(
            id: 'not-02',
            patientId: 'pat-001',
            authorName: 'Sarah Jenkins',
            authorRole: 'Clinic Staff',
            date: DateTime.now().subtract(const Duration(days: 14, hours: 2)),
            title: 'Insurance Pre-Authorization',
            content: 'Star Health pre-auth submitted for conservative restorative procedures. Approval reference #STAR-99214 confirmed.',
          ),
        ],
        medicalHistory: MedicalHistoryModel(
          allergyStatus: AllergyStatus.recorded,
          allergies: const [
            MedicalAllergyItem(
              substance: 'Penicillin G / Beta-lactams',
              category: AllergyCategory.medication,
              reaction: 'Severe urticaria, facial angioedema, and bronchospasm',
              severity: AllergySeverity.critical,
              diagnosedDate: 'May 2018',
              clinicalNotes: 'Strictly contraindicate all amoxicillin and penicillin derivatives. Use Clindamycin or Azithromycin for dental prophylaxis.',
            ),
            MedicalAllergyItem(
              substance: 'Sulfa Drugs (Sulfamethoxazole)',
              category: AllergyCategory.medication,
              reaction: 'Maculopapular cutaneous rash and localized pruritus',
              severity: AllergySeverity.moderate,
              diagnosedDate: 'August 2021',
              clinicalNotes: 'Avoid sulfonamide antimicrobial mouthwashes and topicals.',
            ),
          ],
          medicalConditions: const [
            MedicalConditionItem(
              name: 'Mild Extrinsic Asthma',
              status: MedicalConditionStatus.controlled,
              dateDiagnosed: 'March 2016',
              clinicalNotes: 'Triggered by cold aerosols and pollen. Patient must have active Salbutamol rescue inhaler chairside before dental treatment.',
              requiresDentalPremedication: false,
            ),
          ],
          medications: const [
            MedicationItem(
              name: 'Salbutamol Inhaler (Albuterol)',
              dosage: '100 mcg / actuation',
              frequency: '1-2 puffs PRN as needed for acute wheeze',
              status: MedicationStatus.current,
              startDate: '2016-03-10',
              prescribingPhysician: 'Dr. Arvind Sen, Pulmonology',
              notes: 'Patient confirmed inhaler is present in handbag for today\'s appointment.',
            ),
            MedicationItem(
              name: 'Cholecalciferol (Vitamin D3)',
              dosage: '60,000 IU',
              frequency: 'Once monthly with milk',
              status: MedicationStatus.current,
              startDate: '2024-01-15',
              notes: 'Supplementation for bone mineral density support.',
            ),
          ],
          pastMedicalHistory: const [
            PastMedicalHistoryItem(
              event: 'Laparoscopic Appendectomy',
              type: 'Surgical Procedure',
              approximateDate: 'May 2019',
              facility: 'Manipal Hospital Bengaluru',
              notes: 'General anesthesia uneventful with normal airway recovery and zero hyperthermia complications.',
            ),
          ],
          dentalHistory: const PastDentalHistory(
            previousProcedures: [
              'Class I composite restoration on tooth 16 (2025)',
              'Annual ultrasonic scaling and prophylactic polishing',
            ],
            oralHealthConcerns: [
              'Dentin hypersensitivity in right premolars',
              'Transient cold sensitivity upon drinking refrigerated liquids',
            ],
            treatmentComplications: [
              'No local anesthesia complications reported.',
            ],
            brushingFrequency: 'Twice daily with potassium nitrate desensitizing toothpaste',
            flossingFrequency: '3-4 times per week with waxed dental floss',
            lastDentalCleaningDate: 'October 2025',
          ),
          additionalInfo: AdditionalMedicalInfo(
            familyMedicalHistory: const [
              'Father: Type 2 Diabetes Mellitus (Controlled)',
              'Maternal Grandmother: Hypertension',
            ],
            smokingStatus: 'Non-smoker (Never smoked)',
            alcoholConsumption: 'Occasional social (1-2 drinks/month)',
            hasBleedingDisorder: false,
            pregnancyStatus: 'Not pregnant',
            lastReviewedDate: DateTime.now().subtract(const Duration(days: 14)),
            reviewedByDoctor: 'Dr. Marcus Vance, BDS, MDS',
            generalNotes: 'Patient demonstrates excellent oral health compliance and responds attentively to preventive guidance.',
          ),
        ),
      ),
      PatientModel(
        id: 'pat-002',
        patientNumber: 'PT-2026-0043',
        firstName: 'Vikramaditya',
        lastName: 'Rao',
        email: 'vikram.rao@techcorp.in',
        phone: '+91 99887 66554',
        dateOfBirth: DateTime(1982, 11, 28),
        gender: PatientGender.male,
        bloodGroup: 'B+',
        address: '12 Palm Meadows, Whitefield',
        city: 'Bengaluru',
        state: 'Karnataka',
        postalCode: '560066',
        emergencyContactName: 'Geetha Rao',
        emergencyContactPhone: '+91 99887 11223',
        emergencyRelationship: 'Sister',
        allergies: const ['Latex'],
        chronicConditions: const ['Hypertension (Stage 1)'],
        currentMedications: const ['Amlodipine 5mg OD'],
        chiefComplaint: 'Severe throbbing pain in lower left molar, exacerbated by hot drinks.',
        riskLevel: PatientRiskLevel.high,
        status: PatientStatus.active,
        insuranceProvider: 'Max Bupa Health Care',
        insurancePolicyNumber: 'MB-DENT-88412',
        isInsuranceActive: true,
        assignedDentistId: 'usr-02',
        assignedDentistName: 'Dr. Marcus Vance',
        lastVisitDate: DateTime.now().subtract(const Duration(days: 3)),
        nextAppointmentDate: DateTime.now().add(const Duration(days: 2)),
        totalAiScans: 6,
        recentAiRiskScore: 94,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        teethRecords: const [
          ToothRecord(toothNumber: 36, condition: ToothCondition.periodontalIssue, notes: 'Periapical lucency with deep carious pulp involvement'),
          ToothRecord(toothNumber: 18, condition: ToothCondition.missing, notes: 'Extracted in 2021'),
          ToothRecord(toothNumber: 28, condition: ToothCondition.missing, notes: 'Extracted in 2021'),
        ],
        aiScans: [
          AiScanRecord(
            id: 'scn-102',
            scanDate: DateTime.now().subtract(const Duration(days: 3)),
            scanType: 'Panoramic OPG Full Arch',
            overallHealthScore: 62,
            summary: 'Deep pulpal caries in tooth 36 with active periapical pathology. Urgent endodontic therapy indicated.',
            isReviewedByDentist: true,
            reviewedByDentistName: 'Dr. Marcus Vance',
            findings: const [
              AiFinding(
                id: 'fnd-3',
                toothNumber: 36,
                findingType: 'Pulpal Involvement / Periapical Lucency',
                confidenceScore: 0.97,
                severity: PatientRiskLevel.high,
                description: 'Large radiolucency invading pulp chamber and distal root apex radiolucency indicative of acute apical abscess/periodontitis.',
                recommendation: 'Immediate Root Canal Treatment (RCT) followed by ceramic crown.',
              ),
            ],
          ),
        ],
        appointments: [
          PatientAppointment(
            id: 'apt-02',
            patientId: 'pat-002',
            dentistName: 'Dr. Marcus Vance',
            date: DateTime.now().add(const Duration(days: 2, hours: 4)),
            timeSlot: '03:00 PM - 04:00 PM',
            procedure: 'Endodontic Canal Cleaning & Shaping #36 (Step 1)',
            status: 'Scheduled',
            notes: 'Latex allergy strictly observed - use non-latex dam.',
          ),
        ],
        clinicalNotes: [
          ClinicalNote(
            id: 'not-03',
            patientId: 'pat-002',
            authorName: 'Dr. Marcus Vance',
            authorRole: 'Lead Dentist',
            date: DateTime.now().subtract(const Duration(days: 3)),
            title: 'Emergency Consult - Acute Irreversible Pulpitis #36',
            content: 'Patient presented with severe nocturnal pain. Vitality test negative on 36. Cold test produced prolonged intense lingering ache. Prescribed analgesics and non-latex protocol logged.',
            isFlagged: true,
          ),
        ],
        medicalHistory: MedicalHistoryModel(
          allergyStatus: AllergyStatus.recorded,
          allergies: const [
            MedicalAllergyItem(
              substance: 'Natural Rubber Latex',
              category: AllergyCategory.material,
              reaction: 'Type IV contact dermatitis with localized erythematous papules and pruritus',
              severity: AllergySeverity.moderate,
              diagnosedDate: 'November 2020',
              clinicalNotes: 'Mandatory non-latex clinical protocol: use powder-free nitrile examination gloves and non-latex rubber dam sheet for root canal isolation.',
            ),
          ],
          medicalConditions: const [
            MedicalConditionItem(
              name: 'Essential Hypertension (Stage 1)',
              status: MedicalConditionStatus.controlled,
              dateDiagnosed: 'July 2022',
              clinicalNotes: 'Baseline BP 134/86 mmHg. Limit vasoconstrictor dose to maximum 0.04mg epinephrine (2 cartridges of 1:100,000 lidocaine) per visit. Aspirate carefully.',
              requiresDentalPremedication: false,
            ),
          ],
          medications: const [
            MedicationItem(
              name: 'Amlodipine Besylate',
              dosage: '5 mg',
              frequency: 'Once daily (OD) in morning',
              status: MedicationStatus.current,
              startDate: '2022-07-20',
              prescribingPhysician: 'Dr. K. Narayanan, MD (Cardiology)',
              notes: 'Patient reports strict adherence. Monitor for drug-induced gingival hyperplasia.',
            ),
            MedicationItem(
              name: 'Ibuprofen',
              dosage: '400 mg',
              frequency: 'Three times daily (TDS) PRN for dental pulpitis pain',
              status: MedicationStatus.current,
              startDate: '2026-10-18',
              notes: 'Short term analgesia for acute irreversible pulpitis until canal extirpation.',
            ),
          ],
          pastMedicalHistory: const [
            PastMedicalHistoryItem(
              event: 'Right Inguinal Hernia Mesh Repair',
              type: 'Surgical Procedure',
              approximateDate: 'October 2021',
              facility: 'Aster CMI Hospital Bengaluru',
              notes: 'Open mesh repair under spinal anesthesia. Recovery uneventful with no prosthetic infection.',
            ),
          ],
          dentalHistory: const PastDentalHistory(
            previousProcedures: [
              'Surgical extraction of impacted third molars (teeth 18, 28) in 2021',
              'Deep ultrasonic scaling and localized subgingival curettage',
            ],
            oralHealthConcerns: [
              'Severe acute throbbing nocturnal pulpalgia on lower left molar (#36)',
              'Localized deep periodontal pocketing in posterior quadrants',
            ],
            treatmentComplications: [
              'Delayed socket hemostasis noted during 2021 wisdom tooth extraction; required pressure packs and oxidized cellulose hemostatic plug.',
            ],
            brushingFrequency: 'Twice daily with medium bristle brush',
            flossingFrequency: 'Infrequent (less than once a week)',
            lastDentalCleaningDate: 'May 2025',
          ),
          additionalInfo: AdditionalMedicalInfo(
            familyMedicalHistory: const [
              'Mother: Hypertension and Post-Menopausal Osteoporosis',
              'Brother: Early-onset Coronary Artery Disease',
            ],
            smokingStatus: 'Former smoker (10 pack-years; quit smoking in May 2023)',
            alcoholConsumption: 'Non-drinker',
            hasBleedingDisorder: false,
            lastReviewedDate: DateTime.now().subtract(const Duration(days: 3)),
            reviewedByDoctor: 'Dr. Marcus Vance, BDS, MDS',
            generalNotes: 'Requires careful hemostasis management following dental surgical procedures due to historical bleeding tendency.',
          ),
        ),
      ),
      PatientModel(
        id: 'pat-003',
        patientNumber: 'PT-2026-0044',
        firstName: 'Kavita',
        lastName: 'Mehta',
        email: 'kavita.mehta@sunrise.org',
        phone: '+91 97112 33445',
        dateOfBirth: DateTime(1999, 8, 21),
        gender: PatientGender.female,
        bloodGroup: 'A+',
        address: '502 Skylark Apts, Koramangala',
        city: 'Bengaluru',
        state: 'Karnataka',
        postalCode: '560034',
        emergencyContactName: 'Manish Mehta',
        emergencyContactPhone: '+91 97112 99001',
        emergencyRelationship: 'Father',
        allergies: const [],
        chronicConditions: const [],
        currentMedications: const [],
        chiefComplaint: 'Consultation for clear aligner orthodontic therapy & aesthetic smile contouring.',
        riskLevel: PatientRiskLevel.low,
        status: PatientStatus.active,
        insuranceProvider: 'HDFC ERGO Health',
        insurancePolicyNumber: 'HDFC-D-55102',
        isInsuranceActive: true,
        assignedDentistId: 'usr-04',
        assignedDentistName: 'Dr. Arjun Patel',
        lastVisitDate: DateTime.now().subtract(const Duration(days: 25)),
        nextAppointmentDate: DateTime.now().add(const Duration(days: 12)),
        totalAiScans: 3,
        recentAiRiskScore: 92,
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
        teethRecords: const [
          ToothRecord(toothNumber: 11, condition: ToothCondition.healthy, notes: 'Mild rotation'),
          ToothRecord(toothNumber: 21, condition: ToothCondition.healthy, notes: 'Mild crowding'),
        ],
        aiScans: [
          AiScanRecord(
            id: 'scn-103',
            scanDate: DateTime.now().subtract(const Duration(days: 25)),
            scanType: '3D Orthodontic Smile Analysis',
            overallHealthScore: 94,
            summary: 'Excellent bone support and periodontal status. Mild anterior crowding amenable to clear aligners.',
            isReviewedByDentist: true,
            reviewedByDentistName: 'Dr. Arjun Patel',
            findings: const [
              AiFinding(
                id: 'fnd-4',
                toothNumber: 21,
                findingType: 'Orthodontic Rotation',
                confidenceScore: 0.95,
                severity: PatientRiskLevel.low,
                description: '12-degree distal rotation of upper left central incisor.',
                recommendation: 'Clear aligner series (approx 14 aligner trays estimated).',
              ),
            ],
          ),
        ],
        appointments: [
          PatientAppointment(
            id: 'apt-03',
            patientId: 'pat-003',
            dentistName: 'Dr. Arjun Patel',
            date: DateTime.now().add(const Duration(days: 12, hours: 1)),
            timeSlot: '11:00 AM - 12:00 PM',
            procedure: 'Aligner Tray Delivery & Attachment Placement',
            status: 'Scheduled',
          ),
        ],
        clinicalNotes: [
          ClinicalNote(
            id: 'not-04',
            patientId: 'pat-003',
            authorName: 'Dr. Arjun Patel',
            authorRole: 'Orthodontist',
            date: DateTime.now().subtract(const Duration(days: 25)),
            title: 'Aligner ClinCheck Staging Completed',
            content: '3D simulation approved. Predicted treatment duration: 7 months with bi-weekly tray changes.',
          ),
        ],
        medicalHistory: MedicalHistoryModel(
          allergyStatus: AllergyStatus.noKnownAllergies,
          allergies: const [],
          medicalConditions: const [],
          medications: const [],
          pastMedicalHistory: const [],
          dentalHistory: const PastDentalHistory(
            previousProcedures: [
              'Orthodontic 3D intraoral digital impressions',
              'Biannual prophylactic scaling and polish',
            ],
            oralHealthConcerns: [
              'Mild maxillary anterior dental rotation and alignment concern',
            ],
            treatmentComplications: [],
            brushingFrequency: 'Twice daily with fluoridated toothpaste',
            flossingFrequency: 'Daily before bedtime',
            lastDentalCleaningDate: 'September 2025',
          ),
          additionalInfo: AdditionalMedicalInfo(
            familyMedicalHistory: const [
              'No hereditary systemic illnesses or periodontal disorders reported',
            ],
            smokingStatus: 'Non-smoker',
            alcoholConsumption: 'Non-drinker',
            hasBleedingDisorder: false,
            pregnancyStatus: 'Not pregnant',
            lastReviewedDate: DateTime.now().subtract(const Duration(days: 25)),
            reviewedByDoctor: 'Dr. Arjun Patel, BDS, MOrth',
            generalNotes: 'Healthy orthodontic candidate. Explicitly confirmed No Known Allergies (NKA) during clinical intake.',
          ),
        ),
      ),
      PatientModel(
        id: 'pat-004',
        patientNumber: 'PT-2026-0045',
        firstName: 'Rohan',
        lastName: 'Nambiar',
        email: 'rohan.nambiar@apexcorp.com',
        phone: '+91 98450 77889',
        dateOfBirth: DateTime(1968, 3, 10),
        gender: PatientGender.male,
        bloodGroup: 'AB+',
        address: '88 Lavelle Road',
        city: 'Bengaluru',
        state: 'Karnataka',
        postalCode: '560001',
        emergencyContactName: 'Sunita Nambiar',
        emergencyContactPhone: '+91 98450 11229',
        emergencyRelationship: 'Spouse',
        allergies: const ['Local Anesthetics (Epinephrine sensitivity)'],
        chronicConditions: const ['Type 2 Diabetes (HbA1c 6.8%)', 'Hyperlipidemia'],
        currentMedications: const ['Metformin 500mg BD', 'Atorvastatin 10mg HS'],
        chiefComplaint: 'Implant crown seating review and generalized bleeding gums upon brushing.',
        riskLevel: PatientRiskLevel.high,
        status: PatientStatus.active,
        insuranceProvider: 'Religare Care Dental',
        insurancePolicyNumber: 'REL-DT-33829',
        isInsuranceActive: false,
        assignedDentistId: 'usr-02',
        assignedDentistName: 'Dr. Marcus Vance',
        lastVisitDate: DateTime.now().subtract(const Duration(days: 40)),
        nextAppointmentDate: null,
        totalAiScans: 5,
        recentAiRiskScore: 71,
        createdAt: DateTime.now().subtract(const Duration(days: 300)),
        teethRecords: const [
          ToothRecord(toothNumber: 46, condition: ToothCondition.implant, notes: 'Titanium implant integrated with zirconia crown'),
          ToothRecord(toothNumber: 31, condition: ToothCondition.periodontalIssue, notes: 'Generalized marginal gingivitis'),
          ToothRecord(toothNumber: 41, condition: ToothCondition.periodontalIssue, notes: 'Plaque retention & subgingival calculus'),
        ],
        aiScans: [
          AiScanRecord(
            id: 'scn-104',
            scanDate: DateTime.now().subtract(const Duration(days: 40)),
            scanType: 'Periapical & Periodontal Radiograph',
            overallHealthScore: 71,
            summary: 'Stable implant osseointegration at tooth 46. Moderate horizontal bone loss in lower anterior region.',
            isReviewedByDentist: true,
            reviewedByDentistName: 'Dr. Marcus Vance',
            findings: const [
              AiFinding(
                id: 'fnd-5',
                toothNumber: 31,
                findingType: 'Subgingival Calculus & Marginal Bone Loss',
                confidenceScore: 0.91,
                severity: PatientRiskLevel.medium,
                description: 'Calculus spur visible on mesial surface with 3mm bone reduction.',
                recommendation: 'Full mouth ultrasonic scaling, root planing and chlorhexidine irrigation.',
              ),
            ],
          ),
        ],
        appointments: const [],
        clinicalNotes: [
          ClinicalNote(
            id: 'not-05',
            patientId: 'pat-004',
            authorName: 'Dr. Marcus Vance',
            authorRole: 'Lead Dentist',
            date: DateTime.now().subtract(const Duration(days: 40)),
            title: 'Periodontal Evaluation & Implant Check',
            content: 'Implant 46 stable with zero mobility. Gingival bleeding index elevated at 28%. Advised strict glycemic control and interdental flossing.',
            isFlagged: true,
          ),
        ],
        medicalHistory: MedicalHistoryModel(
          allergyStatus: AllergyStatus.recorded,
          allergies: const [
            MedicalAllergyItem(
              substance: 'Epinephrine / Vasoconstrictor Additive',
              category: AllergyCategory.medication,
              reaction: 'Marked tachycardia, palpitations, diaphoresis, and severe tremor',
              severity: AllergySeverity.moderate,
              diagnosedDate: 'January 2022',
              clinicalNotes: 'Avoid standard 1:100k or 1:80k epinephrine dental carpules. Use 3% Mepivacaine plain or 4% Prilocaine plain for infiltration and blocks.',
            ),
          ],
          medicalConditions: const [
            MedicalConditionItem(
              name: 'Type 2 Diabetes Mellitus',
              status: MedicalConditionStatus.controlled,
              dateDiagnosed: 'February 2017',
              clinicalNotes: 'Recent HbA1c 6.8% (Target < 7.0%). Schedule morning dental appointments; monitor for delayed periodontal wound healing.',
              requiresDentalPremedication: false,
            ),
            MedicalConditionItem(
              name: 'Primary Hyperlipidemia',
              status: MedicalConditionStatus.controlled,
              dateDiagnosed: 'February 2017',
              clinicalNotes: 'Under statin management. Monitored lipid panel.',
              requiresDentalPremedication: false,
            ),
          ],
          medications: const [
            MedicationItem(
              name: 'Metformin Hydrochloride',
              dosage: '500 mg',
              frequency: 'Twice daily (BD) with breakfast and dinner',
              status: MedicationStatus.current,
              startDate: '2017-02-15',
              prescribingPhysician: 'Dr. S. K. Gupta, Endocrinologist',
              notes: 'Patient advised to take morning dose with food on appointment day.',
            ),
            MedicationItem(
              name: 'Atorvastatin Calcium',
              dosage: '10 mg',
              frequency: 'Once daily (OD) at bedtime (HS)',
              status: MedicationStatus.current,
              startDate: '2017-02-15',
              prescribingPhysician: 'Dr. S. K. Gupta, Endocrinologist',
            ),
          ],
          pastMedicalHistory: const [
            PastMedicalHistoryItem(
              event: 'Coronary Angiography (Diagnostic)',
              type: 'Procedure',
              approximateDate: 'November 2022',
              facility: 'Narayana Institute of Cardiac Sciences',
              notes: 'Mild non-obstructive plaque (<30%); medical management continued without stent.',
            ),
          ],
          dentalHistory: const PastDentalHistory(
            previousProcedures: [
              'Titanium dental implant placement at tooth 46 with zirconia abutment (2024)',
              'Crown lengthening procedure',
            ],
            oralHealthConcerns: [
              'Gingival bleeding upon interproximal brushing',
              'Subgingival calculus retention in anterior mandible',
            ],
            treatmentComplications: [
              'Epinephrine tachycardia with standard lidocaine 2% carpules (Jan 2022).',
            ],
            brushingFrequency: 'Twice daily with electric sonic toothbrush',
            flossingFrequency: 'Interdental brush use once daily',
            lastDentalCleaningDate: 'May 2026',
          ),
          additionalInfo: AdditionalMedicalInfo(
            familyMedicalHistory: const [
              'Father: Type 2 Diabetes with diabetic retinopathy',
              'Mother: Hypertension',
            ],
            smokingStatus: 'Non-smoker',
            alcoholConsumption: 'Occasional wine (1 glass/week)',
            hasBleedingDisorder: false,
            lastReviewedDate: DateTime.now().subtract(const Duration(days: 40)),
            reviewedByDoctor: 'Dr. Marcus Vance, BDS, MDS',
            generalNotes: 'Implant 46 stable. Strict non-epinephrine anesthetic protocol indicated.',
          ),
        ),
      ),
      PatientModel(
        id: 'pat-005',
        patientNumber: 'PT-2026-0046',
        firstName: 'Zoya',
        lastName: 'Qureshi',
        email: 'zoya.qureshi@craftstudio.in',
        phone: '+91 96200 44556',
        dateOfBirth: DateTime(2017, 12, 5),
        gender: PatientGender.female,
        bloodGroup: 'O-',
        address: '24 Richmond Circle',
        city: 'Bengaluru',
        state: 'Karnataka',
        postalCode: '560025',
        emergencyContactName: 'Farhan Qureshi',
        emergencyContactPhone: '+91 96200 88990',
        emergencyRelationship: 'Father',
        allergies: const [],
        chronicConditions: const [],
        currentMedications: const [],
        chiefComplaint: 'Pediatric preventive checkup and pit & fissure sealants.',
        riskLevel: PatientRiskLevel.low,
        status: PatientStatus.active,
        insuranceProvider: 'Bajaj Allianz Family Dental',
        insurancePolicyNumber: 'BA-PED-44109',
        isInsuranceActive: true,
        assignedDentistId: 'usr-04',
        assignedDentistName: 'Dr. Arjun Patel',
        lastVisitDate: DateTime.now().subtract(const Duration(days: 60)),
        nextAppointmentDate: DateTime.now().add(const Duration(days: 30)),
        totalAiScans: 2,
        recentAiRiskScore: 98,
        createdAt: DateTime.now().subtract(const Duration(days: 150)),
        teethRecords: const [
          ToothRecord(toothNumber: 55, condition: ToothCondition.healthy),
          ToothRecord(toothNumber: 65, condition: ToothCondition.healthy),
        ],
        aiScans: [
          AiScanRecord(
            id: 'scn-105',
            scanDate: DateTime.now().subtract(const Duration(days: 60)),
            scanType: 'Pediatric Bitewing',
            overallHealthScore: 98,
            summary: 'Zero active carious lesions detected. Normal primary dentition eruption sequence.',
            isReviewedByDentist: true,
            reviewedByDentistName: 'Dr. Arjun Patel',
            findings: const [],
          ),
        ],
        appointments: [
          PatientAppointment(
            id: 'apt-05',
            patientId: 'pat-005',
            dentistName: 'Dr. Arjun Patel',
            date: DateTime.now().add(const Duration(days: 30, hours: 2)),
            timeSlot: '04:30 PM - 05:00 PM',
            procedure: '6-Month Pediatric Fluoride Application',
            status: 'Scheduled',
          ),
        ],
        clinicalNotes: [
          ClinicalNote(
            id: 'not-06',
            patientId: 'pat-005',
            authorName: 'Dr. Arjun Patel',
            authorRole: 'Dentist',
            date: DateTime.now().subtract(const Duration(days: 60)),
            title: 'Pediatric Preventive Sealants Completed',
            content: 'Applied resin pit and fissure sealants on primary molars 55, 65. Cooperative patient.',
          ),
        ],
        medicalHistory: MedicalHistoryModel(
          allergyStatus: AllergyStatus.notRecorded,
          allergies: const [],
          medicalConditions: const [],
          medications: const [],
          pastMedicalHistory: const [],
          dentalHistory: const PastDentalHistory(
            previousProcedures: [
              'Pit and fissure sealants placed on teeth 55, 65',
            ],
            oralHealthConcerns: [],
            treatmentComplications: [],
            brushingFrequency: 'Twice daily under parental supervision',
            flossingFrequency: 'Parent-assisted weekly',
            lastDentalCleaningDate: 'August 2026',
          ),
          additionalInfo: AdditionalMedicalInfo(
            familyMedicalHistory: const [],
            smokingStatus: 'Not applicable (Pediatric patient)',
            alcoholConsumption: 'None',
            hasBleedingDisorder: false,
            lastReviewedDate: DateTime.now().subtract(const Duration(days: 60)),
            reviewedByDoctor: 'Dr. Arjun Patel, BDS, MOrth',
            generalNotes: 'Pediatric patient. Comprehensive allergy review with parents pending at next recall.',
          ),
        ),
      ),
      PatientModel(
        id: 'pat-006',
        patientNumber: 'PT-2026-0047',
        firstName: 'Tanvi',
        lastName: 'Kapoor',
        email: 'tanvi.kapoor@globaledge.com',
        phone: '+91 97400 11998',
        dateOfBirth: DateTime(1991, 7, 19),
        gender: PatientGender.female,
        bloodGroup: 'A-',
        address: '108 Embassy Golf Links',
        city: 'Bengaluru',
        state: 'Karnataka',
        postalCode: '560071',
        emergencyContactName: 'Sanjay Kapoor',
        emergencyContactPhone: '+91 97400 99881',
        emergencyRelationship: 'Spouse',
        allergies: const ['Aspirin / NSAIDs'],
        chronicConditions: const [],
        currentMedications: const [],
        chiefComplaint: 'Post-whitening sensitivity check and night guard fitting for bruxism.',
        riskLevel: PatientRiskLevel.low,
        status: PatientStatus.inactive,
        insuranceProvider: 'Cigna Global Health',
        insurancePolicyNumber: 'CG-IN-90812',
        isInsuranceActive: true,
        assignedDentistId: 'usr-02',
        assignedDentistName: 'Dr. Marcus Vance',
        lastVisitDate: DateTime.now().subtract(const Duration(days: 120)),
        nextAppointmentDate: null,
        totalAiScans: 2,
        recentAiRiskScore: 89,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        teethRecords: const [
          ToothRecord(toothNumber: 13, condition: ToothCondition.treated, notes: 'In-office laser bleaching completed'),
          ToothRecord(toothNumber: 23, condition: ToothCondition.treated, notes: 'In-office laser bleaching completed'),
        ],
        aiScans: const [],
        appointments: const [],
        clinicalNotes: const [],
      ),
    ];
    _isInitialized = true;
  }

  List<PatientModel> get _patients => _sharedPatients;

  PatientModel getPatientByIdSync(String id) {
    return _patients.firstWhere((p) => p.id == id);
  }

  @override
  Future<List<PatientModel>> getPatients({
    String? query,
    PatientStatus? status,
    PatientRiskLevel? risk,
    String? sortBy,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));

    var results = List<PatientModel>.from(_patients);

    // Apply Search Query Filter
    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      results = results.where((p) {
        return p.fullName.toLowerCase().contains(q) ||
            p.patientNumber.toLowerCase().contains(q) ||
            p.email.toLowerCase().contains(q) ||
            p.phone.toLowerCase().contains(q) ||
            (p.assignedDentistName?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    // Apply Status Filter
    if (status != null) {
      results = results.where((p) => p.status == status).toList();
    }

    // Apply Risk Filter
    if (risk != null) {
      results = results.where((p) => p.riskLevel == risk).toList();
    }

    // Apply Sorting
    if (sortBy != null) {
      switch (sortBy.toLowerCase()) {
        case 'name':
          results.sort((a, b) => a.fullName.compareTo(b.fullName));
          break;
        case 'risk':
          final riskOrder = {
            PatientRiskLevel.high: 3,
            PatientRiskLevel.medium: 2,
            PatientRiskLevel.low: 1,
          };
          results.sort((a, b) => (riskOrder[b.riskLevel] ?? 0).compareTo(riskOrder[a.riskLevel] ?? 0));
          break;
        case 'age':
          results.sort((a, b) => a.dateOfBirth.compareTo(b.dateOfBirth));
          break;
        case 'recent':
        default:
          results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
      }
    }

    return List.unmodifiable(results);
  }

  @override
  Future<PatientModel> getPatientById(String id) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final patient = _patients.firstWhere(
      (p) => p.id == id,
      orElse: () => throw const NotFoundException('Patient record not found in system.'),
    );
    return patient;
  }

  @override
  Future<PatientModel> registerPatient({
    required PatientModel patient,
    required UserModel currentUser,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Validation
    if (patient.firstName.trim().isEmpty || patient.lastName.trim().isEmpty) {
      throw const ValidationException('First and last names are mandatory.');
    }

    if (patient.phone.trim().isEmpty) {
      throw const ValidationException('Patient phone number is required.');
    }

    // Check duplicate phone/email (only against distinct non-empty values)
    final cleanPhone = patient.phone.replaceAll(RegExp(r'[^\d+]'), '');
    final cleanEmail = patient.email.trim().toLowerCase();

    final exists = _patients.any((p) {
      final pPhone = p.phone.replaceAll(RegExp(r'[^\d+]'), '');
      final pEmail = p.email.trim().toLowerCase();

      final phoneMatch = cleanPhone.isNotEmpty && pPhone.isNotEmpty && cleanPhone == pPhone;
      final emailMatch = cleanEmail.isNotEmpty && pEmail.isNotEmpty && cleanEmail == pEmail;
      return phoneMatch || emailMatch;
    });

    if (exists) {
      throw const ValidationException('A patient with this email or phone number is already registered.');
    }

    final newPatientNumber = 'PT-${DateTime.now().year}-${(_patients.length + 42).toString().padLeft(4, '0')}';
    final newId = 'pat-${DateTime.now().millisecondsSinceEpoch}';

    final createdPatient = patient.copyWith(
      id: newId,
      patientNumber: newPatientNumber,
      createdAt: DateTime.now(),
      status: PatientStatus.active,
    );

    _patients.insert(0, createdPatient);
    return createdPatient;
  }

  @override
  Future<PatientModel> updatePatient({
    required PatientModel patient,
    required UserModel currentUser,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final index = _patients.indexWhere((p) => p.id == patient.id);
    if (index == -1) {
      throw const NotFoundException('Cannot update non-existent patient.');
    }

    final cleanPhone = patient.phone.replaceAll(RegExp(r'[^\d+]'), '');
    final cleanEmail = patient.email.trim().toLowerCase();

    final exists = _patients.any((p) {
      if (p.id == patient.id) return false;
      final pPhone = p.phone.replaceAll(RegExp(r'[^\d+]'), '');
      final pEmail = p.email.trim().toLowerCase();

      final phoneMatch = cleanPhone.isNotEmpty && pPhone.isNotEmpty && cleanPhone == pPhone;
      final emailMatch = cleanEmail.isNotEmpty && pEmail.isNotEmpty && cleanEmail == pEmail;
      return phoneMatch || emailMatch;
    });

    if (exists) {
      throw const ValidationException('Another patient with this email or phone number already exists.');
    }

    _patients[index] = patient;
    return _patients[index];
  }

  @override
  Future<bool> archivePatient({
    required String patientId,
    required UserModel currentUser,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _patients.indexWhere((p) => p.id == patientId);
    if (index == -1) {
      throw const NotFoundException('Patient record not found.');
    }

    _patients[index] = _patients[index].copyWith(status: PatientStatus.archived);
    return true;
  }

  @override
  Future<ClinicalNote> addClinicalNote({
    required String patientId,
    required String title,
    required String content,
    required UserModel currentUser,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));

    if (title.trim().isEmpty || content.trim().isEmpty) {
      throw const ValidationException('Note title and clinical remarks cannot be blank.');
    }

    final index = _patients.indexWhere((p) => p.id == patientId);
    if (index == -1) {
      throw const NotFoundException('Patient not found.');
    }

    final newNote = ClinicalNote(
      id: 'not-${DateTime.now().millisecondsSinceEpoch}',
      patientId: patientId,
      authorName: currentUser.fullName,
      authorRole: currentUser.role.displayName,
      date: DateTime.now(),
      title: title.trim(),
      content: content.trim(),
      isFlagged: false,
    );

    final updatedNotes = List<ClinicalNote>.from(_patients[index].clinicalNotes)..insert(0, newNote);
    _patients[index] = _patients[index].copyWith(clinicalNotes: updatedNotes);

    return newNote;
  }

  @override
  Future<PatientAppointment> scheduleAppointment({
    required String patientId,
    required DateTime date,
    required String timeSlot,
    required String procedure,
    required String dentistName,
    required UserModel currentUser,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));

    final index = _patients.indexWhere((p) => p.id == patientId);
    if (index == -1) {
      throw const NotFoundException('Patient record not found.');
    }

    final newAppointment = PatientAppointment(
      id: 'apt-${DateTime.now().millisecondsSinceEpoch}',
      patientId: patientId,
      dentistName: dentistName,
      date: date,
      timeSlot: timeSlot,
      procedure: procedure,
      status: 'Scheduled',
    );

    final updatedAppointments = List<PatientAppointment>.from(_patients[index].appointments)..insert(0, newAppointment);
    _patients[index] = _patients[index].copyWith(
      appointments: updatedAppointments,
      nextAppointmentDate: date,
    );

    return newAppointment;
  }

  @override
  Future<Map<String, dynamic>> getPatientStatistics() async {
    await Future.delayed(const Duration(milliseconds: 200));

    final total = _patients.length;
    final active = _patients.where((p) => p.status == PatientStatus.active).length;
    final highRisk = _patients.where((p) => p.riskLevel == PatientRiskLevel.high).length;
    final insured = _patients.where((p) => p.isInsuranceActive).length;

    return {
      'totalPatients': total,
      'activePatients': active,
      'highRiskPatients': highRisk,
      'insuredPatients': insured,
    };
  }
  @override
  Future<PatientModel> addOrUpdateMedicalAllergy({
    required String patientId,
    required MedicalAllergyItem allergy,
    required UserModel currentUser,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _ensurePermission(currentUser);

    if (allergy.allergen.trim().isEmpty) {
      throw const ValidationException('Allergy name or substance cannot be blank.');
    }

    final index = _findPatientIndex(patientId);
    final patient = _patients[index];
    final history = patient.resolvedMedicalHistory;
    final allergies = List<MedicalAllergyItem>.from(history.allergies);

    final existingIndex = allergies.indexWhere(
      (a) => (allergy.id.isNotEmpty && a.id == allergy.id) || a.effectiveId == allergy.effectiveId,
    );

    final isUpdate = existingIndex != -1;
    final savedId = isUpdate
        ? allergies[existingIndex].effectiveId
        : (allergy.id.isNotEmpty ? allergy.id : 'alg-${DateTime.now().millisecondsSinceEpoch}');

    final resolvedAllergy = allergy.copyWith(id: savedId);

    if (isUpdate) {
      allergies[existingIndex] = resolvedAllergy;
    } else {
      allergies.add(resolvedAllergy);
    }

    final auditEntry = MedicalHistoryAuditEntry(
      id: 'aud-${DateTime.now().millisecondsSinceEpoch}',
      recordId: savedId,
      category: 'Allergy',
      action: isUpdate ? 'Updated' : 'Created',
      performedById: currentUser.id,
      performedByName: currentUser.fullName,
      timestamp: DateTime.now(),
      summary: '${isUpdate ? "Updated" : "Added"} allergy: ${resolvedAllergy.allergen} (${resolvedAllergy.severity.name})',
    );

    final updatedHistory = history.copyWith(
      allergyStatus: AllergyStatus.recorded,
      allergies: allergies,
      reviewedByClinicianName: currentUser.fullName,
      reviewedByClinicianRole: currentUser.role.displayName,
      lastReviewedDate: DateTime.now(),
      auditTrail: [auditEntry, ...history.auditTrail],
    );

    final updatedPatient = patient.copyWith(
      medicalHistory: updatedHistory,
      allergies: allergies.map((a) => a.allergen).toList(),
    );

    _patients[index] = updatedPatient;
    return updatedPatient;
  }

  @override
  Future<PatientModel> deleteMedicalAllergy({
    required String patientId,
    required String allergyId,
    required UserModel currentUser,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _ensurePermission(currentUser);

    final index = _findPatientIndex(patientId);
    final patient = _patients[index];
    final history = patient.resolvedMedicalHistory;
    final allergies = List<MedicalAllergyItem>.from(history.allergies);

    final itemIndex = allergies.indexWhere((a) => a.effectiveId == allergyId || a.id == allergyId);
    if (itemIndex == -1) {
      throw const NotFoundException('Allergy record not found or does not belong to this patient.');
    }

    final deletedItem = allergies.removeAt(itemIndex);

    final auditEntry = MedicalHistoryAuditEntry(
      id: 'aud-${DateTime.now().millisecondsSinceEpoch}',
      recordId: deletedItem.effectiveId,
      category: 'Allergy',
      action: 'Deleted',
      performedById: currentUser.id,
      performedByName: currentUser.fullName,
      timestamp: DateTime.now(),
      summary: 'Deleted allergy record: ${deletedItem.allergen}',
    );

    final updatedStatus = allergies.isEmpty ? AllergyStatus.notRecorded : history.allergyStatus;

    final updatedHistory = history.copyWith(
      allergyStatus: updatedStatus,
      allergies: allergies,
      reviewedByClinicianName: currentUser.fullName,
      reviewedByClinicianRole: currentUser.role.displayName,
      lastReviewedDate: DateTime.now(),
      auditTrail: [auditEntry, ...history.auditTrail],
    );

    final updatedPatient = patient.copyWith(
      medicalHistory: updatedHistory,
      allergies: allergies.map((a) => a.allergen).toList(),
    );

    _patients[index] = updatedPatient;
    return updatedPatient;
  }

  @override
  Future<PatientModel> updatePatientAllergyStatus({
    required String patientId,
    required AllergyStatus status,
    required UserModel currentUser,
    String? notes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _ensurePermission(currentUser);

    final index = _findPatientIndex(patientId);
    final patient = _patients[index];
    final history = patient.resolvedMedicalHistory;

    final auditEntry = MedicalHistoryAuditEntry(
      id: 'aud-${DateTime.now().millisecondsSinceEpoch}',
      recordId: 'allergy-status',
      category: 'Allergy Status',
      action: 'Updated',
      performedById: currentUser.id,
      performedByName: currentUser.fullName,
      timestamp: DateTime.now(),
      summary: 'Changed allergy status to "${status.label}"${notes != null && notes.isNotEmpty ? ": $notes" : ""}',
    );

    final updatedHistory = history.copyWith(
      allergyStatus: status,
      reviewedByClinicianName: currentUser.fullName,
      reviewedByClinicianRole: currentUser.role.displayName,
      lastReviewedDate: DateTime.now(),
      auditTrail: [auditEntry, ...history.auditTrail],
    );

    final updatedPatient = patient.copyWith(medicalHistory: updatedHistory);
    _patients[index] = updatedPatient;
    return updatedPatient;
  }

  @override
  Future<PatientModel> addOrUpdateMedicalCondition({
    required String patientId,
    required MedicalConditionItem condition,
    required UserModel currentUser,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _ensurePermission(currentUser);

    if (condition.name.trim().isEmpty) {
      throw const ValidationException('Medical condition name cannot be blank.');
    }

    final index = _findPatientIndex(patientId);
    final patient = _patients[index];
    final history = patient.resolvedMedicalHistory;
    final conditions = List<MedicalConditionItem>.from(history.medicalConditions);

    final existingIndex = conditions.indexWhere(
      (c) => (condition.id.isNotEmpty && c.id == condition.id) || c.effectiveId == condition.effectiveId,
    );

    final isUpdate = existingIndex != -1;
    final savedId = isUpdate
        ? conditions[existingIndex].effectiveId
        : (condition.id.isNotEmpty ? condition.id : 'cnd-${DateTime.now().millisecondsSinceEpoch}');

    final resolvedCondition = condition.copyWith(id: savedId);

    if (isUpdate) {
      conditions[existingIndex] = resolvedCondition;
    } else {
      conditions.add(resolvedCondition);
    }

    final auditEntry = MedicalHistoryAuditEntry(
      id: 'aud-${DateTime.now().millisecondsSinceEpoch}',
      recordId: savedId,
      category: 'Medical Condition',
      action: isUpdate ? 'Updated' : 'Created',
      performedById: currentUser.id,
      performedByName: currentUser.fullName,
      timestamp: DateTime.now(),
      summary: '${isUpdate ? "Updated" : "Added"} condition: ${resolvedCondition.name} (${resolvedCondition.status.name})',
    );

    final updatedHistory = history.copyWith(
      medicalConditions: conditions,
      reviewedByClinicianName: currentUser.fullName,
      reviewedByClinicianRole: currentUser.role.displayName,
      lastReviewedDate: DateTime.now(),
      auditTrail: [auditEntry, ...history.auditTrail],
    );

    final updatedPatient = patient.copyWith(
      medicalHistory: updatedHistory,
      chronicConditions: conditions.map((c) => c.name).toList(),
    );

    _patients[index] = updatedPatient;
    return updatedPatient;
  }

  @override
  Future<PatientModel> deleteMedicalCondition({
    required String patientId,
    required String conditionId,
    required UserModel currentUser,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _ensurePermission(currentUser);

    final index = _findPatientIndex(patientId);
    final patient = _patients[index];
    final history = patient.resolvedMedicalHistory;
    final conditions = List<MedicalConditionItem>.from(history.medicalConditions);

    final itemIndex = conditions.indexWhere((c) => c.effectiveId == conditionId || c.id == conditionId);
    if (itemIndex == -1) {
      throw const NotFoundException('Condition record not found or does not belong to this patient.');
    }

    final deletedItem = conditions.removeAt(itemIndex);

    final auditEntry = MedicalHistoryAuditEntry(
      id: 'aud-${DateTime.now().millisecondsSinceEpoch}',
      recordId: deletedItem.effectiveId,
      category: 'Medical Condition',
      action: 'Deleted',
      performedById: currentUser.id,
      performedByName: currentUser.fullName,
      timestamp: DateTime.now(),
      summary: 'Deleted medical condition: ${deletedItem.name}',
    );

    final updatedHistory = history.copyWith(
      medicalConditions: conditions,
      reviewedByClinicianName: currentUser.fullName,
      reviewedByClinicianRole: currentUser.role.displayName,
      lastReviewedDate: DateTime.now(),
      auditTrail: [auditEntry, ...history.auditTrail],
    );

    final updatedPatient = patient.copyWith(
      medicalHistory: updatedHistory,
      chronicConditions: conditions.map((c) => c.name).toList(),
    );

    _patients[index] = updatedPatient;
    return updatedPatient;
  }

  @override
  Future<PatientModel> addOrUpdateMedication({
    required String patientId,
    required MedicationItem medication,
    required UserModel currentUser,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _ensurePermission(currentUser);

    if (medication.name.trim().isEmpty) {
      throw const ValidationException('Medication name cannot be blank.');
    }

    final index = _findPatientIndex(patientId);
    final patient = _patients[index];
    final history = patient.resolvedMedicalHistory;
    final medications = List<MedicationItem>.from(history.medications);

    final existingIndex = medications.indexWhere(
      (m) => (medication.id.isNotEmpty && m.id == medication.id) || m.effectiveId == medication.effectiveId,
    );

    final isUpdate = existingIndex != -1;
    final savedId = isUpdate
        ? medications[existingIndex].effectiveId
        : (medication.id.isNotEmpty ? medication.id : 'med-${DateTime.now().millisecondsSinceEpoch}');

    final resolvedMedication = medication.copyWith(id: savedId);

    if (isUpdate) {
      medications[existingIndex] = resolvedMedication;
    } else {
      medications.add(resolvedMedication);
    }

    final auditEntry = MedicalHistoryAuditEntry(
      id: 'aud-${DateTime.now().millisecondsSinceEpoch}',
      recordId: savedId,
      category: 'Medication',
      action: isUpdate ? 'Updated' : 'Created',
      performedById: currentUser.id,
      performedByName: currentUser.fullName,
      timestamp: DateTime.now(),
      summary: '${isUpdate ? "Updated" : "Added"} medication: ${resolvedMedication.name} (${resolvedMedication.status.name})',
    );

    final updatedHistory = history.copyWith(
      medications: medications,
      reviewedByClinicianName: currentUser.fullName,
      reviewedByClinicianRole: currentUser.role.displayName,
      lastReviewedDate: DateTime.now(),
      auditTrail: [auditEntry, ...history.auditTrail],
    );

    final currentMeds = medications
        .where((m) => m.status == MedicationStatus.current)
        .map((m) => m.name)
        .toList();

    final updatedPatient = patient.copyWith(
      medicalHistory: updatedHistory,
      currentMedications: currentMeds,
    );

    _patients[index] = updatedPatient;
    return updatedPatient;
  }

  @override
  Future<PatientModel> deleteMedication({
    required String patientId,
    required String medicationId,
    required UserModel currentUser,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _ensurePermission(currentUser);

    final index = _findPatientIndex(patientId);
    final patient = _patients[index];
    final history = patient.resolvedMedicalHistory;
    final medications = List<MedicationItem>.from(history.medications);

    final itemIndex = medications.indexWhere((m) => m.effectiveId == medicationId || m.id == medicationId);
    if (itemIndex == -1) {
      throw const NotFoundException('Medication record not found or does not belong to this patient.');
    }

    final deletedItem = medications.removeAt(itemIndex);

    final auditEntry = MedicalHistoryAuditEntry(
      id: 'aud-${DateTime.now().millisecondsSinceEpoch}',
      recordId: deletedItem.effectiveId,
      category: 'Medication',
      action: 'Deleted',
      performedById: currentUser.id,
      performedByName: currentUser.fullName,
      timestamp: DateTime.now(),
      summary: 'Deleted medication record: ${deletedItem.name}',
    );

    final updatedHistory = history.copyWith(
      medications: medications,
      reviewedByClinicianName: currentUser.fullName,
      reviewedByClinicianRole: currentUser.role.displayName,
      lastReviewedDate: DateTime.now(),
      auditTrail: [auditEntry, ...history.auditTrail],
    );

    final currentMeds = medications
        .where((m) => m.status == MedicationStatus.current)
        .map((m) => m.name)
        .toList();

    final updatedPatient = patient.copyWith(
      medicalHistory: updatedHistory,
      currentMedications: currentMeds,
    );

    _patients[index] = updatedPatient;
    return updatedPatient;
  }

  @override
  Future<PatientModel> addOrUpdatePastMedicalHistoryItem({
    required String patientId,
    required PastMedicalHistoryItem item,
    required UserModel currentUser,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _ensurePermission(currentUser);

    if (item.event.trim().isEmpty) {
      throw const ValidationException('Medical event or procedure name cannot be blank.');
    }

    final index = _findPatientIndex(patientId);
    final patient = _patients[index];
    final history = patient.resolvedMedicalHistory;
    final pastItems = List<PastMedicalHistoryItem>.from(history.pastMedicalHistory);

    final existingIndex = pastItems.indexWhere(
      (p) => (item.id.isNotEmpty && p.id == item.id) || p.effectiveId == item.effectiveId,
    );

    final isUpdate = existingIndex != -1;
    final savedId = isUpdate
        ? pastItems[existingIndex].effectiveId
        : (item.id.isNotEmpty ? item.id : 'pmh-${DateTime.now().millisecondsSinceEpoch}');

    final resolvedItem = item.copyWith(id: savedId);

    if (isUpdate) {
      pastItems[existingIndex] = resolvedItem;
    } else {
      pastItems.add(resolvedItem);
    }

    final auditEntry = MedicalHistoryAuditEntry(
      id: 'aud-${DateTime.now().millisecondsSinceEpoch}',
      recordId: savedId,
      category: 'Past Medical History',
      action: isUpdate ? 'Updated' : 'Created',
      performedById: currentUser.id,
      performedByName: currentUser.fullName,
      timestamp: DateTime.now(),
      summary: '${isUpdate ? "Updated" : "Added"} surgical/medical event: ${resolvedItem.event}',
    );

    final updatedHistory = history.copyWith(
      pastMedicalHistory: pastItems,
      reviewedByClinicianName: currentUser.fullName,
      reviewedByClinicianRole: currentUser.role.displayName,
      lastReviewedDate: DateTime.now(),
      auditTrail: [auditEntry, ...history.auditTrail],
    );

    final updatedPatient = patient.copyWith(medicalHistory: updatedHistory);
    _patients[index] = updatedPatient;
    return updatedPatient;
  }

  @override
  Future<PatientModel> deletePastMedicalHistoryItem({
    required String patientId,
    required String itemId,
    required UserModel currentUser,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _ensurePermission(currentUser);

    final index = _findPatientIndex(patientId);
    final patient = _patients[index];
    final history = patient.resolvedMedicalHistory;
    final pastItems = List<PastMedicalHistoryItem>.from(history.pastMedicalHistory);

    final itemIndex = pastItems.indexWhere((p) => p.effectiveId == itemId || p.id == itemId);
    if (itemIndex == -1) {
      throw const NotFoundException('Past medical history item not found or does not belong to this patient.');
    }

    final deletedItem = pastItems.removeAt(itemIndex);

    final auditEntry = MedicalHistoryAuditEntry(
      id: 'aud-${DateTime.now().millisecondsSinceEpoch}',
      recordId: deletedItem.effectiveId,
      category: 'Past Medical History',
      action: 'Deleted',
      performedById: currentUser.id,
      performedByName: currentUser.fullName,
      timestamp: DateTime.now(),
      summary: 'Deleted past history item: ${deletedItem.event}',
    );

    final updatedHistory = history.copyWith(
      pastMedicalHistory: pastItems,
      reviewedByClinicianName: currentUser.fullName,
      reviewedByClinicianRole: currentUser.role.displayName,
      lastReviewedDate: DateTime.now(),
      auditTrail: [auditEntry, ...history.auditTrail],
    );

    final updatedPatient = patient.copyWith(medicalHistory: updatedHistory);
    _patients[index] = updatedPatient;
    return updatedPatient;
  }

  @override
  Future<PatientModel> updatePastDentalHistory({
    required String patientId,
    required PastDentalHistory dentalHistory,
    required UserModel currentUser,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _ensurePermission(currentUser);

    final index = _findPatientIndex(patientId);
    final patient = _patients[index];
    final history = patient.resolvedMedicalHistory;

    final auditEntry = MedicalHistoryAuditEntry(
      id: 'aud-${DateTime.now().millisecondsSinceEpoch}',
      recordId: 'dental-history',
      category: 'Dental History',
      action: 'Updated',
      performedById: currentUser.id,
      performedByName: currentUser.fullName,
      timestamp: DateTime.now(),
      summary: 'Updated dental precedents and oral hygiene parameters.',
    );

    final updatedHistory = history.copyWith(
      dentalHistory: dentalHistory,
      reviewedByClinicianName: currentUser.fullName,
      reviewedByClinicianRole: currentUser.role.displayName,
      lastReviewedDate: DateTime.now(),
      auditTrail: [auditEntry, ...history.auditTrail],
    );

    final updatedPatient = patient.copyWith(medicalHistory: updatedHistory);
    _patients[index] = updatedPatient;
    return updatedPatient;
  }

  @override
  Future<PatientModel> updateAdditionalMedicalInfo({
    required String patientId,
    required AdditionalMedicalInfo additionalInfo,
    required UserModel currentUser,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _ensurePermission(currentUser);

    final index = _findPatientIndex(patientId);
    final patient = _patients[index];
    final history = patient.resolvedMedicalHistory;

    final auditEntry = MedicalHistoryAuditEntry(
      id: 'aud-${DateTime.now().millisecondsSinceEpoch}',
      recordId: 'additional-info',
      category: 'Additional Clinical Info',
      action: 'Updated',
      performedById: currentUser.id,
      performedByName: currentUser.fullName,
      timestamp: DateTime.now(),
      summary: 'Updated family history, bleeding risk, and lifestyle notes.',
    );

    final updatedHistory = history.copyWith(
      additionalInfo: additionalInfo,
      reviewedByClinicianName: currentUser.fullName,
      reviewedByClinicianRole: currentUser.role.displayName,
      lastReviewedDate: DateTime.now(),
      auditTrail: [auditEntry, ...history.auditTrail],
    );

    final updatedPatient = patient.copyWith(medicalHistory: updatedHistory);
    _patients[index] = updatedPatient;
    return updatedPatient;
  }

  void _ensurePermission(UserModel user) {
    if (!user.canManageMedicalHistory) {
      throw const UnauthorizedException('Unauthorized: You do not have permission to modify clinical medical history.');
    }
  }

  int _findPatientIndex(String patientId) {
    final index = _patients.indexWhere((p) => p.id == patientId);
    if (index == -1) {
      throw const NotFoundException('Patient record not found.');
    }
    return index;
  }
}
