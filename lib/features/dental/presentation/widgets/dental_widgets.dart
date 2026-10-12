import '../../../../l10n/app_localizations.dart';

String dentalKindLabel(AppLocalizations l10n, String kind) => switch (kind) {
  'checkup' => l10n.dentalKindCheckup,
  'preventive' => l10n.dentalKindPreventive,
  'restorative' => l10n.dentalKindRestorative,
  'endodontic' => l10n.dentalKindEndodontic,
  'periodontal' => l10n.dentalKindPeriodontal,
  'surgical' => l10n.dentalKindSurgical,
  'prosthetic' => l10n.dentalKindProsthetic,
  'orthodontic' => l10n.dentalKindOrthodontic,
  'cosmetic' => l10n.dentalKindCosmetic,
  _ => l10n.dentalKindPediatric,
};

String formatDentalMoney(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

/// A price, or «السعر بعد الكشف» when the clinic quotes after seeing the patient.
String dentalPriceText(AppLocalizations l10n, double? price) =>
    price == null ? l10n.dentalPriceAfterExam : '${formatDentalMoney(price)} ${l10n.invCurrency}';
