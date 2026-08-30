import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'BIM'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In ar, this message translates to:
  /// **'كل الأعمال في مكان واحد'**
  String get appTagline;

  /// No description provided for @commonLoading.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل...'**
  String get commonLoading;

  /// No description provided for @commonRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get commonCancel;

  /// No description provided for @commonSubmit.
  ///
  /// In ar, this message translates to:
  /// **'إرسال'**
  String get commonSubmit;

  /// No description provided for @commonSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get commonSave;

  /// No description provided for @commonNext.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get commonNext;

  /// No description provided for @commonBack.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get commonBack;

  /// No description provided for @commonSomethingWentWrong.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ ما، حاول مرة أخرى.'**
  String get commonSomethingWentWrong;

  /// No description provided for @commonNoInternet.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال بالإنترنت.'**
  String get commonNoInternet;

  /// No description provided for @authChooseAccountType.
  ///
  /// In ar, this message translates to:
  /// **'اختر نوع الحساب'**
  String get authChooseAccountType;

  /// No description provided for @authAccountTypeCustomer.
  ///
  /// In ar, this message translates to:
  /// **'عميل'**
  String get authAccountTypeCustomer;

  /// No description provided for @authAccountTypeBusiness.
  ///
  /// In ar, this message translates to:
  /// **'صاحب نشاط تجاري'**
  String get authAccountTypeBusiness;

  /// No description provided for @authLogin.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get authLogin;

  /// No description provided for @authRegister.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get authRegister;

  /// No description provided for @authWelcomeBack.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً بعودتك'**
  String get authWelcomeBack;

  /// No description provided for @authEmailOrPhone.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني أو رقم الهاتف'**
  String get authEmailOrPhone;

  /// No description provided for @authPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get authPassword;

  /// No description provided for @authConfirmPassword.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get authConfirmPassword;

  /// No description provided for @authForgotPassword.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get authForgotPassword;

  /// No description provided for @authDontHaveAccount.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟'**
  String get authDontHaveAccount;

  /// No description provided for @authAlreadyHaveAccount.
  ///
  /// In ar, this message translates to:
  /// **'لديك حساب بالفعل؟'**
  String get authAlreadyHaveAccount;

  /// No description provided for @authLogout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get authLogout;

  /// No description provided for @authName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get authName;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In ar, this message translates to:
  /// **'بيانات الدخول غير صحيحة.'**
  String get authInvalidCredentials;

  /// No description provided for @validationRequired.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب.'**
  String get validationRequired;

  /// No description provided for @validationInvalidEmail.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني غير صحيح.'**
  String get validationInvalidEmail;

  /// No description provided for @validationPasswordPolicy.
  ///
  /// In ar, this message translates to:
  /// **'من 8 إلى 20 حرفًا، بحرف كبير وحرف صغير ورقم على الأقل.'**
  String get validationPasswordPolicy;

  /// No description provided for @validationPasswordMismatch.
  ///
  /// In ar, this message translates to:
  /// **'كلمتا المرور غير متطابقتين.'**
  String get validationPasswordMismatch;

  /// No description provided for @homeCustomerTitle.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get homeCustomerTitle;

  /// No description provided for @homeBusinessTitle.
  ///
  /// In ar, this message translates to:
  /// **'لوحة النشاط'**
  String get homeBusinessTitle;

  /// No description provided for @categoriesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تصنيفات متاحة حاليًا.'**
  String get categoriesEmpty;

  /// No description provided for @specialtiesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تخصصات متاحة في هذا التصنيف.'**
  String get specialtiesEmpty;

  /// No description provided for @businessSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث باسم النشاط...'**
  String get businessSearchHint;

  /// No description provided for @businessListEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أنشطة مطابقة.'**
  String get businessListEmpty;

  /// No description provided for @businessOpenNow.
  ///
  /// In ar, this message translates to:
  /// **'مفتوح الآن'**
  String get businessOpenNow;

  /// No description provided for @businessClosedNow.
  ///
  /// In ar, this message translates to:
  /// **'مغلق الآن'**
  String get businessClosedNow;

  /// No description provided for @businessCallForPrice.
  ///
  /// In ar, this message translates to:
  /// **'اتصل للسعر'**
  String get businessCallForPrice;

  /// No description provided for @businessCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لا يوجد نشاط} one{نشاط واحد} two{نشاطان} few{{count} أنشطة} many{{count} نشاطًا} other{{count} نشاط}}'**
  String businessCount(int count);

  /// No description provided for @settingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageArabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get settingsLanguageArabic;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
