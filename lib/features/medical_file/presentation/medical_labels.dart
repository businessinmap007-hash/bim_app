import '../../../l10n/app_localizations.dart';
import '../data/medical_file.dart';

String medicalSectionLabel(AppLocalizations l10n, MedicalSection section) => switch (section) {
  MedicalSection.conditions => l10n.medicalSectionConditions,
  MedicalSection.allergies => l10n.medicalSectionAllergies,
  MedicalSection.medications => l10n.medicalSectionMedications,
  MedicalSection.surgeries => l10n.medicalSectionSurgeries,
};
