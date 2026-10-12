import '../../../../l10n/app_localizations.dart';

String specialtyKindLabel(AppLocalizations l10n, String kind) => switch (kind) {
  'checkup' => l10n.dentalKindCheckup,
  'preventive' => l10n.dentalKindPreventive,
  'restorative' => l10n.dentalKindRestorative,
  'endodontic' => l10n.dentalKindEndodontic,
  'periodontal' => l10n.dentalKindPeriodontal,
  'surgical' => l10n.dentalKindSurgical,
  'prosthetic' => l10n.dentalKindProsthetic,
  'orthodontic' => l10n.dentalKindOrthodontic,
  'cosmetic' => l10n.dentalKindCosmetic,
  'pediatric' => l10n.dentalKindPediatric,
  'injectables' => l10n.skinKindInjectables,
  'face_lifting' => l10n.skinKindFaceLifting,
  'laser' => l10n.skinKindLaser,
  'scars' => l10n.skinKindScars,
  'peels' => l10n.skinKindPeels,
  'skin_disease' => l10n.skinKindSkinDisease,
  'hair' => l10n.skinKindHair,
  _ => l10n.skinKindBody,
};

String formatServiceMoney(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

/// A price, or «السعر بعد الكشف» when the clinic quotes after seeing the patient.
String servicePriceText(AppLocalizations l10n, double? price) =>
    price == null ? l10n.specialtyPriceAfterExam : '${formatServiceMoney(price)} ${l10n.invCurrency}';
