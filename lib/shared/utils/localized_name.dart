/// The app's own language first, the other name if that one is blank — the
/// same rule as the backend's `User`/`Option`/`OptionGroup::displayName()`
/// and `HasLocalizedFields::loc()`. Every bilingual (`nameAr`/`nameEn`)
/// model in this app should be displayed through this, never `.nameAr`
/// directly, or a business's own vocabulary chips/headings stay Arabic no
/// matter which language the rest of the screen is in.
String localizedName(String nameAr, String? nameEn, bool isEnglish) {
  if (isEnglish && nameEn != null && nameEn.isNotEmpty) return nameEn;
  return nameAr.isNotEmpty ? nameAr : (nameEn ?? '');
}
