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

  /// No description provided for @commonRefresh.
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get commonRefresh;

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

  /// No description provided for @commonDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get commonDelete;

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

  /// No description provided for @notificationsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات.'**
  String get notificationsEmpty;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الكل كمقروء'**
  String get notificationsMarkAllRead;

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

  /// No description provided for @authForgotPasswordTitle.
  ///
  /// In ar, this message translates to:
  /// **'استعادة كلمة المرور'**
  String get authForgotPasswordTitle;

  /// No description provided for @authForgotPasswordInstructions.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريدك الإلكتروني وسنرسل لك رمز تحقق لإعادة تعيين كلمة المرور.'**
  String get authForgotPasswordInstructions;

  /// No description provided for @authSendCode.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الرمز'**
  String get authSendCode;

  /// No description provided for @authResendCode.
  ///
  /// In ar, this message translates to:
  /// **'إعادة إرسال الرمز'**
  String get authResendCode;

  /// No description provided for @authVerificationCode.
  ///
  /// In ar, this message translates to:
  /// **'رمز التحقق'**
  String get authVerificationCode;

  /// No description provided for @authCodeSentMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رمز التحقق إلى بريدك الإلكتروني.'**
  String get authCodeSentMessage;

  /// No description provided for @authNewPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الجديدة'**
  String get authNewPassword;

  /// No description provided for @authResetPassword.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تعيين كلمة المرور'**
  String get authResetPassword;

  /// No description provided for @authBackToLogin.
  ///
  /// In ar, this message translates to:
  /// **'الرجوع لتسجيل الدخول'**
  String get authBackToLogin;

  /// No description provided for @authResetPasswordSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تغيير كلمة المرور بنجاح، يمكنك تسجيل الدخول الآن.'**
  String get authResetPasswordSuccess;

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

  /// No description provided for @businessFollow.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get businessFollow;

  /// No description provided for @businessUnfollow.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء المتابعة'**
  String get businessUnfollow;

  /// No description provided for @businessFollowersCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لا يوجد متابعون} one{متابع واحد} two{متابعان} few{{count} متابعين} many{{count} متابعًا} other{{count} متابع}}'**
  String businessFollowersCount(int count);

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

  /// No description provided for @settingsAppearance.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get settingsAppearance;

  /// No description provided for @settingsAppearanceLight.
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get settingsAppearanceLight;

  /// No description provided for @settingsAppearanceDark.
  ///
  /// In ar, this message translates to:
  /// **'داكن'**
  String get settingsAppearanceDark;

  /// No description provided for @settingsAppearanceSystem.
  ///
  /// In ar, this message translates to:
  /// **'حسب النظام'**
  String get settingsAppearanceSystem;

  /// No description provided for @settingsAccountSection.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الحساب'**
  String get settingsAccountSection;

  /// No description provided for @settingsServicesSection.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الخدمات'**
  String get settingsServicesSection;

  /// No description provided for @settingsComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'قريبًا'**
  String get settingsComingSoon;

  /// No description provided for @categoryPickerFieldLabel.
  ///
  /// In ar, this message translates to:
  /// **'التصنيف'**
  String get categoryPickerFieldLabel;

  /// No description provided for @categoryPickerChooseHint.
  ///
  /// In ar, this message translates to:
  /// **'اختر التصنيف'**
  String get categoryPickerChooseHint;

  /// No description provided for @categoryPickerChooseRoot.
  ///
  /// In ar, this message translates to:
  /// **'اختر القسم الرئيسي'**
  String get categoryPickerChooseRoot;

  /// No description provided for @mediaCapturedByCamera.
  ///
  /// In ar, this message translates to:
  /// **'تم التقاط هذه الصورة بالكاميرا'**
  String get mediaCapturedByCamera;

  /// No description provided for @mediaFromGallery.
  ///
  /// In ar, this message translates to:
  /// **'تم رفع هذه الصورة من المعرض'**
  String get mediaFromGallery;

  /// No description provided for @mediaAddFromCamera.
  ///
  /// In ar, this message translates to:
  /// **'التقاط بالكاميرا'**
  String get mediaAddFromCamera;

  /// No description provided for @mediaAddFromGallery.
  ///
  /// In ar, this message translates to:
  /// **'اختيار من المعرض'**
  String get mediaAddFromGallery;

  /// No description provided for @mediaRemove.
  ///
  /// In ar, this message translates to:
  /// **'إزالة'**
  String get mediaRemove;

  /// No description provided for @mediaCrop.
  ///
  /// In ar, this message translates to:
  /// **'قص الصورة'**
  String get mediaCrop;

  /// No description provided for @mediaWatermarkTitle.
  ///
  /// In ar, this message translates to:
  /// **'العلامة المائية'**
  String get mediaWatermarkTitle;

  /// No description provided for @mediaWatermarkUseMobile.
  ///
  /// In ar, this message translates to:
  /// **'رقم الموبايل'**
  String get mediaWatermarkUseMobile;

  /// No description provided for @mediaWatermarkUseBusinessName.
  ///
  /// In ar, this message translates to:
  /// **'اسم النشاط'**
  String get mediaWatermarkUseBusinessName;

  /// No description provided for @mediaWatermarkSettingsHint.
  ///
  /// In ar, this message translates to:
  /// **'اختر مصدر نص العلامة المائية من ملفك الشخصي — سيُضاف تلقائيًا لكل صورة تضيفها، دون كتابته في كل مرة.'**
  String get mediaWatermarkSettingsHint;

  /// No description provided for @mediaWatermarkDisabledHint.
  ///
  /// In ar, this message translates to:
  /// **'العلامة المائية غير مفعّلة حاليًا.'**
  String get mediaWatermarkDisabledHint;

  /// No description provided for @mediaWatermarkOpenSettings.
  ///
  /// In ar, this message translates to:
  /// **'تفعيلها من الإعدادات'**
  String get mediaWatermarkOpenSettings;

  /// No description provided for @mediaWatermarkRepeatCount.
  ///
  /// In ar, this message translates to:
  /// **'عدد التكرار'**
  String get mediaWatermarkRepeatCount;

  /// No description provided for @mediaComposerTitle.
  ///
  /// In ar, this message translates to:
  /// **'عرض الصور والعلامة المائية'**
  String get mediaComposerTitle;

  /// No description provided for @mediaEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد صور بعد — أضف صورة بالكاميرا أو من المعرض.'**
  String get mediaEmpty;

  /// No description provided for @cropTitle.
  ///
  /// In ar, this message translates to:
  /// **'قص الصورة'**
  String get cropTitle;

  /// No description provided for @cropAspectOriginal.
  ///
  /// In ar, this message translates to:
  /// **'الأصلي'**
  String get cropAspectOriginal;

  /// No description provided for @cropAspectSquare.
  ///
  /// In ar, this message translates to:
  /// **'مربع'**
  String get cropAspectSquare;

  /// No description provided for @cropAspectPortrait.
  ///
  /// In ar, this message translates to:
  /// **'عمودي'**
  String get cropAspectPortrait;

  /// No description provided for @cropAspectLandscape.
  ///
  /// In ar, this message translates to:
  /// **'أفقي'**
  String get cropAspectLandscape;

  /// No description provided for @cropConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تم'**
  String get cropConfirm;

  /// No description provided for @businessRatingNoReviews.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تقييمات بعد'**
  String get businessRatingNoReviews;

  /// No description provided for @businessTabPosts.
  ///
  /// In ar, this message translates to:
  /// **'المنشورات'**
  String get businessTabPosts;

  /// No description provided for @businessTabMenu.
  ///
  /// In ar, this message translates to:
  /// **'القائمة'**
  String get businessTabMenu;

  /// No description provided for @businessTabServices.
  ///
  /// In ar, this message translates to:
  /// **'الخدمات'**
  String get businessTabServices;

  /// No description provided for @businessPostsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد منشورات بعد'**
  String get businessPostsEmpty;

  /// No description provided for @businessMenuEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أصناف بعد'**
  String get businessMenuEmpty;

  /// No description provided for @businessServicesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد خدمات بعد'**
  String get businessServicesEmpty;

  /// No description provided for @businessActionBook.
  ///
  /// In ar, this message translates to:
  /// **'احجز'**
  String get businessActionBook;

  /// No description provided for @businessActionOrder.
  ///
  /// In ar, this message translates to:
  /// **'اطلب'**
  String get businessActionOrder;

  /// No description provided for @businessOutOfStock.
  ///
  /// In ar, this message translates to:
  /// **'غير متوفر حاليًا'**
  String get businessOutOfStock;

  /// No description provided for @businessNoContentYet.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد محتوى لعرضه بعد'**
  String get businessNoContentYet;

  /// No description provided for @profileTitle.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get profileTitle;

  /// No description provided for @profileName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get profileName;

  /// No description provided for @profilePhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الموبايل'**
  String get profilePhone;

  /// No description provided for @profileLocation.
  ///
  /// In ar, this message translates to:
  /// **'الموقع'**
  String get profileLocation;

  /// No description provided for @profileLocationNotSet.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تحديد الموقع بعد'**
  String get profileLocationNotSet;

  /// No description provided for @profileLocationSet.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديد الموقع'**
  String get profileLocationSet;

  /// No description provided for @profileUseCurrentLocation.
  ///
  /// In ar, this message translates to:
  /// **'تحديد موقعي الحالي'**
  String get profileUseCurrentLocation;

  /// No description provided for @profileLocationPermissionDenied.
  ///
  /// In ar, this message translates to:
  /// **'تحتاج للسماح بالوصول للموقع من إعدادات الجهاز.'**
  String get profileLocationPermissionDenied;

  /// No description provided for @profilePhotoCamera.
  ///
  /// In ar, this message translates to:
  /// **'التقاط بالكاميرا'**
  String get profilePhotoCamera;

  /// No description provided for @profilePhotoGallery.
  ///
  /// In ar, this message translates to:
  /// **'اختيار من المعرض'**
  String get profilePhotoGallery;

  /// No description provided for @profilePhotoRemove.
  ///
  /// In ar, this message translates to:
  /// **'إزالة الصورة'**
  String get profilePhotoRemove;

  /// No description provided for @profileSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ التغييرات.'**
  String get profileSaved;

  /// No description provided for @profilePrivacyNote.
  ///
  /// In ar, this message translates to:
  /// **'بياناتك دي (رقمك وموقعك) متتشافش لحد — بتظهر بس للنشاط التجاري وقت ما تستخدم خدمة فعلية معاه، زي الحجز أو الطلب.'**
  String get profilePrivacyNote;

  /// No description provided for @profileSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get profileSave;

  /// No description provided for @navCategories.
  ///
  /// In ar, this message translates to:
  /// **'التصنيفات'**
  String get navCategories;

  /// No description provided for @navSearch.
  ///
  /// In ar, this message translates to:
  /// **'البحث'**
  String get navSearch;

  /// No description provided for @navProfile.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get navProfile;

  /// No description provided for @searchEmptyHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب اسم النشاط اللي بتدور عليه'**
  String get searchEmptyHint;

  /// No description provided for @profileEmail.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get profileEmail;

  /// No description provided for @profileNameEnglish.
  ///
  /// In ar, this message translates to:
  /// **'الاسم بالإنجليزية'**
  String get profileNameEnglish;

  /// No description provided for @profileAbout.
  ///
  /// In ar, this message translates to:
  /// **'نبذة عن النشاط'**
  String get profileAbout;

  /// No description provided for @profileAccountType.
  ///
  /// In ar, this message translates to:
  /// **'نوع الحساب'**
  String get profileAccountType;

  /// No description provided for @profileAccountTypeClient.
  ///
  /// In ar, this message translates to:
  /// **'عميل'**
  String get profileAccountTypeClient;

  /// No description provided for @profileAccountTypeBusiness.
  ///
  /// In ar, this message translates to:
  /// **'نشاط تجاري'**
  String get profileAccountTypeBusiness;

  /// No description provided for @profileSpecialty.
  ///
  /// In ar, this message translates to:
  /// **'التخصص'**
  String get profileSpecialty;

  /// No description provided for @profileSpecialtyNotSet.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم اختيار تخصص'**
  String get profileSpecialtyNotSet;

  /// No description provided for @profileCategory.
  ///
  /// In ar, this message translates to:
  /// **'التصنيف الرئيسي'**
  String get profileCategory;

  /// No description provided for @profileCategoryNotSet.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تحديد تصنيف رئيسي'**
  String get profileCategoryNotSet;

  /// No description provided for @profileConvertToBusiness.
  ///
  /// In ar, this message translates to:
  /// **'تحويل الحساب إلى نشاط تجاري'**
  String get profileConvertToBusiness;

  /// No description provided for @profileConvertToBusinessHint.
  ///
  /// In ar, this message translates to:
  /// **'اختر تخصص نشاطك التجاري لإتمام التحويل — لا يمكن التراجع عن هذا التحويل من هنا.'**
  String get profileConvertToBusinessHint;

  /// No description provided for @profileConvertConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد التحويل'**
  String get profileConvertConfirm;

  /// No description provided for @profileConvertSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تحويل حسابك إلى نشاط تجاري بنجاح.'**
  String get profileConvertSuccess;

  /// No description provided for @profileOptionsTitle.
  ///
  /// In ar, this message translates to:
  /// **'خصائص النشاط'**
  String get profileOptionsTitle;

  /// No description provided for @profileOptionsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد خصائص متاحة لتخصصك الحالي.'**
  String get profileOptionsEmpty;

  /// No description provided for @profileOptionsSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الخصائص'**
  String get profileOptionsSave;

  /// No description provided for @profileAdministrativeLocation.
  ///
  /// In ar, this message translates to:
  /// **'المنطقة الإدارية'**
  String get profileAdministrativeLocation;

  /// No description provided for @locationFieldLabel.
  ///
  /// In ar, this message translates to:
  /// **'الدولة / المحافظة / المدينة'**
  String get locationFieldLabel;

  /// No description provided for @locationChooseHint.
  ///
  /// In ar, this message translates to:
  /// **'اختر الدولة والمحافظة والمدينة'**
  String get locationChooseHint;

  /// No description provided for @locationChooseCountry.
  ///
  /// In ar, this message translates to:
  /// **'اختر الدولة'**
  String get locationChooseCountry;

  /// No description provided for @locationEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج'**
  String get locationEmpty;

  /// No description provided for @locationSearchCity.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن مدينة'**
  String get locationSearchCity;

  /// No description provided for @profileAlbumsTitle.
  ///
  /// In ar, this message translates to:
  /// **'ألبومات الصور'**
  String get profileAlbumsTitle;

  /// No description provided for @profileAlbumsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد ألبومات بعد.'**
  String get profileAlbumsEmpty;

  /// No description provided for @profileAlbumsAdd.
  ///
  /// In ar, this message translates to:
  /// **'ألبوم جديد'**
  String get profileAlbumsAdd;

  /// No description provided for @profileAlbumsNewTitle.
  ///
  /// In ar, this message translates to:
  /// **'اسم الألبوم'**
  String get profileAlbumsNewTitle;

  /// No description provided for @profileAlbumsCreate.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء'**
  String get profileAlbumsCreate;

  /// No description provided for @profileAlbumsAddPhoto.
  ///
  /// In ar, this message translates to:
  /// **'إضافة صورة'**
  String get profileAlbumsAddPhoto;

  /// No description provided for @profileAlbumsDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف الألبوم'**
  String get profileAlbumsDelete;

  /// No description provided for @profileAlbumsDeleteConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد حذف هذا الألبوم وكل صوره؟'**
  String get profileAlbumsDeleteConfirm;

  /// No description provided for @bookingSettingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الحجز'**
  String get bookingSettingsTitle;

  /// No description provided for @bookingSettingsPricesTab.
  ///
  /// In ar, this message translates to:
  /// **'الأسعار'**
  String get bookingSettingsPricesTab;

  /// No description provided for @bookingSettingsUnitsTab.
  ///
  /// In ar, this message translates to:
  /// **'الوحدات'**
  String get bookingSettingsUnitsTab;

  /// No description provided for @bookingSettingsHoursTab.
  ///
  /// In ar, this message translates to:
  /// **'ساعات العمل'**
  String get bookingSettingsHoursTab;

  /// No description provided for @bookingSettingsAddPrice.
  ///
  /// In ar, this message translates to:
  /// **'إضافة سعر'**
  String get bookingSettingsAddPrice;

  /// No description provided for @bookingSettingsAddUnit.
  ///
  /// In ar, this message translates to:
  /// **'إضافة وحدة'**
  String get bookingSettingsAddUnit;

  /// No description provided for @bookingSettingsService.
  ///
  /// In ar, this message translates to:
  /// **'الخدمة'**
  String get bookingSettingsService;

  /// No description provided for @bookingSettingsItemType.
  ///
  /// In ar, this message translates to:
  /// **'نوع الخدمة'**
  String get bookingSettingsItemType;

  /// No description provided for @bookingSettingsLineOption.
  ///
  /// In ar, this message translates to:
  /// **'النوع'**
  String get bookingSettingsLineOption;

  /// No description provided for @bookingSettingsLineOptionHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: غرفة مزدوجة'**
  String get bookingSettingsLineOptionHint;

  /// No description provided for @bookingSettingsPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get bookingSettingsPrice;

  /// No description provided for @bookingSettingsCode.
  ///
  /// In ar, this message translates to:
  /// **'الرقم / الكود'**
  String get bookingSettingsCode;

  /// No description provided for @bookingSettingsCapacity.
  ///
  /// In ar, this message translates to:
  /// **'السعة'**
  String get bookingSettingsCapacity;

  /// No description provided for @bookingSettingsPricesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أسعار بعد — أضف سعرًا لكل نوع تقدّمه.'**
  String get bookingSettingsPricesEmpty;

  /// No description provided for @bookingSettingsUnitsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد وحدات بعد.'**
  String get bookingSettingsUnitsEmpty;

  /// No description provided for @bookingSettingsDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get bookingSettingsDelete;

  /// No description provided for @bookingSettingsDeleteConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد الحذف؟'**
  String get bookingSettingsDeleteConfirm;

  /// No description provided for @bookingSettingsClosed.
  ///
  /// In ar, this message translates to:
  /// **'مغلق'**
  String get bookingSettingsClosed;

  /// No description provided for @bookingSettingsOpenTime.
  ///
  /// In ar, this message translates to:
  /// **'وقت الفتح'**
  String get bookingSettingsOpenTime;

  /// No description provided for @bookingSettingsCloseTime.
  ///
  /// In ar, this message translates to:
  /// **'وقت الإغلاق'**
  String get bookingSettingsCloseTime;

  /// No description provided for @bookingSettingsSaveHours.
  ///
  /// In ar, this message translates to:
  /// **'حفظ المواعيد'**
  String get bookingSettingsSaveHours;

  /// No description provided for @bookingSettingsHoursSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ المواعيد.'**
  String get bookingSettingsHoursSaved;

  /// No description provided for @bookingSettingsOpenNow.
  ///
  /// In ar, this message translates to:
  /// **'مفتوح الآن'**
  String get bookingSettingsOpenNow;

  /// No description provided for @bookingSettingsClosedNow.
  ///
  /// In ar, this message translates to:
  /// **'مغلق الآن'**
  String get bookingSettingsClosedNow;

  /// No description provided for @weekdaySunday.
  ///
  /// In ar, this message translates to:
  /// **'الأحد'**
  String get weekdaySunday;

  /// No description provided for @weekdayMonday.
  ///
  /// In ar, this message translates to:
  /// **'الإثنين'**
  String get weekdayMonday;

  /// No description provided for @weekdayTuesday.
  ///
  /// In ar, this message translates to:
  /// **'الثلاثاء'**
  String get weekdayTuesday;

  /// No description provided for @weekdayWednesday.
  ///
  /// In ar, this message translates to:
  /// **'الأربعاء'**
  String get weekdayWednesday;

  /// No description provided for @weekdayThursday.
  ///
  /// In ar, this message translates to:
  /// **'الخميس'**
  String get weekdayThursday;

  /// No description provided for @weekdayFriday.
  ///
  /// In ar, this message translates to:
  /// **'الجمعة'**
  String get weekdayFriday;

  /// No description provided for @weekdaySaturday.
  ///
  /// In ar, this message translates to:
  /// **'السبت'**
  String get weekdaySaturday;

  /// No description provided for @postsMyPostsTitle.
  ///
  /// In ar, this message translates to:
  /// **'منشوراتي'**
  String get postsMyPostsTitle;

  /// No description provided for @postsTabFollowing.
  ///
  /// In ar, this message translates to:
  /// **'المتابَعون'**
  String get postsTabFollowing;

  /// No description provided for @postsTabMine.
  ///
  /// In ar, this message translates to:
  /// **'منشوراتي'**
  String get postsTabMine;

  /// No description provided for @postsTabJobs.
  ///
  /// In ar, this message translates to:
  /// **'وظائفي'**
  String get postsTabJobs;

  /// No description provided for @myFollowsTitle.
  ///
  /// In ar, this message translates to:
  /// **'المتابَعون'**
  String get myFollowsTitle;

  /// No description provided for @myFollowsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'أنت لا تتابع أي حساب بعد.'**
  String get myFollowsEmpty;

  /// No description provided for @postsFeedEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد منشورات بعد — تابع نشاطًا تجاريًا لترى منشوراته هنا.'**
  String get postsFeedEmpty;

  /// No description provided for @postsMineEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لم تنشر أي شيء بعد.'**
  String get postsMineEmpty;

  /// No description provided for @postsJobsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لم تنشر أي وظيفة بعد.'**
  String get postsJobsEmpty;

  /// No description provided for @postsCreateTitle.
  ///
  /// In ar, this message translates to:
  /// **'منشور جديد'**
  String get postsCreateTitle;

  /// No description provided for @postsPublish.
  ///
  /// In ar, this message translates to:
  /// **'نشر'**
  String get postsPublish;

  /// No description provided for @postsTitleLabel.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get postsTitleLabel;

  /// No description provided for @postsBodyLabel.
  ///
  /// In ar, this message translates to:
  /// **'النص'**
  String get postsBodyLabel;

  /// No description provided for @postsMaxImagesReached.
  ///
  /// In ar, this message translates to:
  /// **'بحد أقصى {max} صور لكل منشور.'**
  String postsMaxImagesReached(int max);

  /// No description provided for @postsDeleteConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد حذف هذا المنشور؟'**
  String get postsDeleteConfirmTitle;

  /// No description provided for @postsDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get postsDelete;

  /// No description provided for @postsJobsClosed.
  ///
  /// In ar, this message translates to:
  /// **'مغلقة'**
  String get postsJobsClosed;

  /// No description provided for @postsJobsApplicantsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لا يوجد متقدمون} one{متقدم واحد} two{متقدمان} few{{count} متقدمين} many{{count} متقدمًا} other{{count} متقدم}}'**
  String postsJobsApplicantsCount(int count);

  /// No description provided for @jobsCreateTitle.
  ///
  /// In ar, this message translates to:
  /// **'وظيفة جديدة'**
  String get jobsCreateTitle;

  /// No description provided for @jobsTitleLabel.
  ///
  /// In ar, this message translates to:
  /// **'المسمى الوظيفي'**
  String get jobsTitleLabel;

  /// No description provided for @jobsBodyLabel.
  ///
  /// In ar, this message translates to:
  /// **'وصف الوظيفة'**
  String get jobsBodyLabel;

  /// No description provided for @jobsRequirementsLabel.
  ///
  /// In ar, this message translates to:
  /// **'المتطلبات (اختياري)'**
  String get jobsRequirementsLabel;

  /// No description provided for @jobsSalaryLabel.
  ///
  /// In ar, this message translates to:
  /// **'الراتب (اختياري)'**
  String get jobsSalaryLabel;

  /// No description provided for @cartTitle.
  ///
  /// In ar, this message translates to:
  /// **'السلة'**
  String get cartTitle;

  /// No description provided for @cartEmpty.
  ///
  /// In ar, this message translates to:
  /// **'السلة فارغة.'**
  String get cartEmpty;

  /// No description provided for @cartAdd.
  ///
  /// In ar, this message translates to:
  /// **'أضف للسلة'**
  String get cartAdd;

  /// No description provided for @cartAddedToCart.
  ///
  /// In ar, this message translates to:
  /// **'تمت الإضافة للسلة.'**
  String get cartAddedToCart;

  /// No description provided for @cartQty.
  ///
  /// In ar, this message translates to:
  /// **'الكمية'**
  String get cartQty;

  /// No description provided for @cartRemove.
  ///
  /// In ar, this message translates to:
  /// **'إزالة'**
  String get cartRemove;

  /// No description provided for @cartVariantChoose.
  ///
  /// In ar, this message translates to:
  /// **'اختر النوع'**
  String get cartVariantChoose;

  /// No description provided for @cartExtrasChoose.
  ///
  /// In ar, this message translates to:
  /// **'إضافات'**
  String get cartExtrasChoose;

  /// No description provided for @cartItemsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لا توجد أصناف} one{صنف واحد} two{صنفان} few{{count} أصناف} many{{count} صنفًا} other{{count} صنف}}'**
  String cartItemsCount(int count);

  /// No description provided for @cartSubtotal.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي الفرعي'**
  String get cartSubtotal;

  /// No description provided for @cartServiceFee.
  ///
  /// In ar, this message translates to:
  /// **'رسوم الخدمة'**
  String get cartServiceFee;

  /// No description provided for @cartTax.
  ///
  /// In ar, this message translates to:
  /// **'الضريبة'**
  String get cartTax;

  /// No description provided for @cartDeliveryFee.
  ///
  /// In ar, this message translates to:
  /// **'رسوم التوصيل'**
  String get cartDeliveryFee;

  /// No description provided for @cartDiscount.
  ///
  /// In ar, this message translates to:
  /// **'الخصم'**
  String get cartDiscount;

  /// No description provided for @cartFinalTotal.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get cartFinalTotal;

  /// No description provided for @cartCheckout.
  ///
  /// In ar, this message translates to:
  /// **'إتمام الطلب'**
  String get cartCheckout;

  /// No description provided for @cartCheckoutTitle.
  ///
  /// In ar, this message translates to:
  /// **'إتمام الطلب'**
  String get cartCheckoutTitle;

  /// No description provided for @cartFulfillmentType.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الاستلام'**
  String get cartFulfillmentType;

  /// No description provided for @cartFulfillmentDelivery.
  ///
  /// In ar, this message translates to:
  /// **'توصيل'**
  String get cartFulfillmentDelivery;

  /// No description provided for @cartFulfillmentPickup.
  ///
  /// In ar, this message translates to:
  /// **'استلام من المكان'**
  String get cartFulfillmentPickup;

  /// No description provided for @cartFulfillmentDineIn.
  ///
  /// In ar, this message translates to:
  /// **'تناول في المكان'**
  String get cartFulfillmentDineIn;

  /// No description provided for @cartAddressLabel.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get cartAddressLabel;

  /// No description provided for @cartAddressHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب عنوان التوصيل'**
  String get cartAddressHint;

  /// No description provided for @cartNotesLabel.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات (اختياري)'**
  String get cartNotesLabel;

  /// No description provided for @cartPaymentMethod.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الدفع'**
  String get cartPaymentMethod;

  /// No description provided for @cartPaymentCash.
  ///
  /// In ar, this message translates to:
  /// **'نقدًا عند الاستلام'**
  String get cartPaymentCash;

  /// No description provided for @cartPlaceOrder.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الطلب'**
  String get cartPlaceOrder;

  /// No description provided for @cartOrderPlaced.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال الطلب بنجاح.'**
  String get cartOrderPlaced;

  /// No description provided for @cartGoToCart.
  ///
  /// In ar, this message translates to:
  /// **'الذهاب للسلة'**
  String get cartGoToCart;

  /// No description provided for @bookingScreenTitle.
  ///
  /// In ar, this message translates to:
  /// **'الحجز'**
  String get bookingScreenTitle;

  /// No description provided for @bookingSubmit.
  ///
  /// In ar, this message translates to:
  /// **'احجز الآن'**
  String get bookingSubmit;

  /// No description provided for @bookingChooseUnit.
  ///
  /// In ar, this message translates to:
  /// **'اختر الوحدة'**
  String get bookingChooseUnit;

  /// No description provided for @bookingUnitEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد وحدات متاحة حاليًا.'**
  String get bookingUnitEmpty;

  /// No description provided for @bookingModifiersTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافات'**
  String get bookingModifiersTitle;

  /// No description provided for @bookingFrom.
  ///
  /// In ar, this message translates to:
  /// **'من'**
  String get bookingFrom;

  /// No description provided for @bookingTo.
  ///
  /// In ar, this message translates to:
  /// **'إلى'**
  String get bookingTo;

  /// No description provided for @bookingChoosePlaceholder.
  ///
  /// In ar, this message translates to:
  /// **'اختر...'**
  String get bookingChoosePlaceholder;

  /// No description provided for @bookingChannelInPerson.
  ///
  /// In ar, this message translates to:
  /// **'حضوريًا'**
  String get bookingChannelInPerson;

  /// No description provided for @bookingChannelOnline.
  ///
  /// In ar, this message translates to:
  /// **'أونلاين'**
  String get bookingChannelOnline;

  /// No description provided for @bookingVisitAtBusiness.
  ///
  /// In ar, this message translates to:
  /// **'في المكان'**
  String get bookingVisitAtBusiness;

  /// No description provided for @bookingVisitAtCustomer.
  ///
  /// In ar, this message translates to:
  /// **'عندك'**
  String get bookingVisitAtCustomer;

  /// No description provided for @bookingSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال طلب الحجز بنجاح.'**
  String get bookingSuccess;

  /// No description provided for @bookingDatetimeLabel.
  ///
  /// In ar, this message translates to:
  /// **'موعد الحجز'**
  String get bookingDatetimeLabel;

  /// No description provided for @bookingCapacityLabel.
  ///
  /// In ar, this message translates to:
  /// **'السعة'**
  String get bookingCapacityLabel;

  /// No description provided for @bookingUnitRequired.
  ///
  /// In ar, this message translates to:
  /// **'اختر الوحدة أولًا.'**
  String get bookingUnitRequired;

  /// No description provided for @bookingDateRequired.
  ///
  /// In ar, this message translates to:
  /// **'حدد الموعد أولًا.'**
  String get bookingDateRequired;

  /// No description provided for @bookingUnitUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'غير متاحة في هذه المواعيد'**
  String get bookingUnitUnavailable;

  /// No description provided for @ordersBookingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلباتي وحجوزاتي'**
  String get ordersBookingsTitle;

  /// No description provided for @ordersTab.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات'**
  String get ordersTab;

  /// No description provided for @bookingsTab.
  ///
  /// In ar, this message translates to:
  /// **'الحجوزات'**
  String get bookingsTab;

  /// No description provided for @ordersEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات بعد.'**
  String get ordersEmpty;

  /// No description provided for @bookingsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد حجوزات بعد.'**
  String get bookingsEmpty;

  /// No description provided for @ordersCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الطلب'**
  String get ordersCancel;

  /// No description provided for @ordersReorder.
  ///
  /// In ar, this message translates to:
  /// **'اطلب مرة أخرى'**
  String get ordersReorder;

  /// No description provided for @ordersReordered.
  ///
  /// In ar, this message translates to:
  /// **'تمت إضافة العناصر إلى السلة.'**
  String get ordersReordered;

  /// No description provided for @ordersReorderedWithSkipped.
  ///
  /// In ar, this message translates to:
  /// **'تمت إضافة العناصر المتاحة إلى السلة، وتعذّر توفير بعضها.'**
  String get ordersReorderedWithSkipped;

  /// No description provided for @ordersCancelled.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء الطلب.'**
  String get ordersCancelled;

  /// No description provided for @ordersCancelConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد إلغاء هذا الطلب؟'**
  String get ordersCancelConfirm;

  /// No description provided for @bookingsCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الحجز'**
  String get bookingsCancel;

  /// No description provided for @bookingsCancelled.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء الحجز.'**
  String get bookingsCancelled;

  /// No description provided for @bookingsCancelConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد إلغاء هذا الحجز؟'**
  String get bookingsCancelConfirm;

  /// No description provided for @orderStatusPending.
  ///
  /// In ar, this message translates to:
  /// **'قيد الانتظار'**
  String get orderStatusPending;

  /// No description provided for @orderStatusCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get orderStatusCompleted;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغي'**
  String get orderStatusCancelled;

  /// No description provided for @bookingStatusPending.
  ///
  /// In ar, this message translates to:
  /// **'قيد الانتظار'**
  String get bookingStatusPending;

  /// No description provided for @bookingStatusAccepted.
  ///
  /// In ar, this message translates to:
  /// **'مقبول'**
  String get bookingStatusAccepted;

  /// No description provided for @bookingStatusRejected.
  ///
  /// In ar, this message translates to:
  /// **'مرفوض'**
  String get bookingStatusRejected;

  /// No description provided for @bookingStatusCancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغي'**
  String get bookingStatusCancelled;

  /// No description provided for @bookingStatusInProgress.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التنفيذ'**
  String get bookingStatusInProgress;

  /// No description provided for @bookingStatusCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get bookingStatusCompleted;

  /// No description provided for @ratingsReviewsTitle.
  ///
  /// In ar, this message translates to:
  /// **'التقييمات'**
  String get ratingsReviewsTitle;

  /// No description provided for @ratingsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تقييمات بعد.'**
  String get ratingsEmpty;

  /// No description provided for @ratingsLeaveReview.
  ///
  /// In ar, this message translates to:
  /// **'أضف تقييمك'**
  String get ratingsLeaveReview;

  /// No description provided for @ratingsSubmit.
  ///
  /// In ar, this message translates to:
  /// **'إرسال التقييم'**
  String get ratingsSubmit;

  /// No description provided for @ratingsCommentHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب تعليقك (اختياري)'**
  String get ratingsCommentHint;

  /// No description provided for @ratingsSubmitted.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال تقييمك بنجاح.'**
  String get ratingsSubmitted;

  /// No description provided for @ratingsSelectStarsError.
  ///
  /// In ar, this message translates to:
  /// **'اختر عدد النجوم أولًا.'**
  String get ratingsSelectStarsError;

  /// No description provided for @walletTitle.
  ///
  /// In ar, this message translates to:
  /// **'المحفظة'**
  String get walletTitle;

  /// No description provided for @walletAvailableBalance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد المتاح'**
  String get walletAvailableBalance;

  /// No description provided for @walletLockedBalance.
  ///
  /// In ar, this message translates to:
  /// **'رصيد محجوز'**
  String get walletLockedBalance;

  /// No description provided for @walletTransactionsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الحركات'**
  String get walletTransactionsTitle;

  /// No description provided for @walletTransactionsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد حركات بعد.'**
  String get walletTransactionsEmpty;

  /// No description provided for @chatTitle.
  ///
  /// In ar, this message translates to:
  /// **'المحادثة'**
  String get chatTitle;

  /// No description provided for @chatOpenChat.
  ///
  /// In ar, this message translates to:
  /// **'محادثة'**
  String get chatOpenChat;

  /// No description provided for @chatEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد رسائل بعد.'**
  String get chatEmpty;

  /// No description provided for @chatMessageHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب رسالة...'**
  String get chatMessageHint;

  /// No description provided for @chatLocked.
  ///
  /// In ar, this message translates to:
  /// **'انتهت المحادثة ولم يعد بالإمكان إرسال رسائل.'**
  String get chatLocked;

  /// No description provided for @agendaTitle.
  ///
  /// In ar, this message translates to:
  /// **'أجندتي'**
  String get agendaTitle;

  /// No description provided for @agendaEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عناصر في هذا اليوم.'**
  String get agendaEmpty;

  /// No description provided for @agendaAddTask.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مهمة'**
  String get agendaAddTask;

  /// No description provided for @agendaTaskTitle.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get agendaTaskTitle;

  /// No description provided for @agendaTaskNotes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات (اختياري)'**
  String get agendaTaskNotes;

  /// No description provided for @agendaStartTime.
  ///
  /// In ar, this message translates to:
  /// **'وقت البدء'**
  String get agendaStartTime;

  /// No description provided for @agendaEndTime.
  ///
  /// In ar, this message translates to:
  /// **'وقت الانتهاء (اختياري)'**
  String get agendaEndTime;

  /// No description provided for @agendaToday.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get agendaToday;

  /// No description provided for @agendaDeleteConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد حذف هذه المهمة؟'**
  String get agendaDeleteConfirm;

  /// No description provided for @agendaTitleRequired.
  ///
  /// In ar, this message translates to:
  /// **'أدخل عنوان المهمة.'**
  String get agendaTitleRequired;

  /// No description provided for @cartShareCart.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة السلة'**
  String get cartShareCart;

  /// No description provided for @cartShareInstructions.
  ///
  /// In ar, this message translates to:
  /// **'شارك هذا الرمز مع أصدقائك ليضيفوا طلباتهم:'**
  String get cartShareInstructions;

  /// No description provided for @cartShareCopied.
  ///
  /// In ar, this message translates to:
  /// **'تم نسخ الرمز.'**
  String get cartShareCopied;

  /// No description provided for @cartJoinSharedCart.
  ///
  /// In ar, this message translates to:
  /// **'الانضمام لسلة مشتركة'**
  String get cartJoinSharedCart;

  /// No description provided for @cartJoinTokenHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رمز المشاركة'**
  String get cartJoinTokenHint;

  /// No description provided for @cartJoinAction.
  ///
  /// In ar, this message translates to:
  /// **'انضمام'**
  String get cartJoinAction;

  /// No description provided for @sharedCartTitle.
  ///
  /// In ar, this message translates to:
  /// **'سلة مشتركة'**
  String get sharedCartTitle;

  /// No description provided for @sharedCartParticipants.
  ///
  /// In ar, this message translates to:
  /// **'المشاركون'**
  String get sharedCartParticipants;

  /// No description provided for @sharedCartAddItems.
  ///
  /// In ar, this message translates to:
  /// **'إضافة عناصر'**
  String get sharedCartAddItems;

  /// No description provided for @sharedCartLeave.
  ///
  /// In ar, this message translates to:
  /// **'مغادرة السلة'**
  String get sharedCartLeave;

  /// No description provided for @sharedCartLeaveConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد مغادرة هذه السلة المشتركة؟'**
  String get sharedCartLeaveConfirm;

  /// No description provided for @sharedCartCancelCart.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء السلة'**
  String get sharedCartCancelCart;

  /// No description provided for @sharedCartCancelConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد إلغاء هذه السلة المشتركة بالكامل؟'**
  String get sharedCartCancelConfirm;

  /// No description provided for @sharedCartHostBadge.
  ///
  /// In ar, this message translates to:
  /// **'المضيف'**
  String get sharedCartHostBadge;

  /// No description provided for @staffTitle.
  ///
  /// In ar, this message translates to:
  /// **'الموظفون'**
  String get staffTitle;

  /// No description provided for @staffEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد موظفون بعد.'**
  String get staffEmpty;

  /// No description provided for @staffAdd.
  ///
  /// In ar, this message translates to:
  /// **'إضافة موظف'**
  String get staffAdd;

  /// No description provided for @staffEdit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الموظف'**
  String get staffEdit;

  /// No description provided for @staffPhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم هاتف الموظف'**
  String get staffPhone;

  /// No description provided for @staffJobTitle.
  ///
  /// In ar, this message translates to:
  /// **'المسمى الوظيفي (اختياري)'**
  String get staffJobTitle;

  /// No description provided for @staffCapabilities.
  ///
  /// In ar, this message translates to:
  /// **'الصلاحيات'**
  String get staffCapabilities;

  /// No description provided for @staffCapabilitiesRequired.
  ///
  /// In ar, this message translates to:
  /// **'اختر صلاحية واحدة على الأقل.'**
  String get staffCapabilitiesRequired;

  /// No description provided for @staffActive.
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get staffActive;

  /// No description provided for @staffInactiveBadge.
  ///
  /// In ar, this message translates to:
  /// **'غير نشط'**
  String get staffInactiveBadge;

  /// No description provided for @staffRemove.
  ///
  /// In ar, this message translates to:
  /// **'إزالة'**
  String get staffRemove;

  /// No description provided for @staffRemoveConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد إزالة هذا الموظف؟'**
  String get staffRemoveConfirm;

  /// No description provided for @staffPhoneRequired.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم هاتف الموظف.'**
  String get staffPhoneRequired;

  /// No description provided for @finesTitle.
  ///
  /// In ar, this message translates to:
  /// **'الغرامات'**
  String get finesTitle;

  /// No description provided for @finesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد غرامات.'**
  String get finesEmpty;

  /// No description provided for @finesFrozenAmount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المجمّد'**
  String get finesFrozenAmount;

  /// No description provided for @finesCollectedAmount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المحصَّل'**
  String get finesCollectedAmount;

  /// No description provided for @finesAppealStatementHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب سبب اعتراضك'**
  String get finesAppealStatementHint;

  /// No description provided for @finesSubmitAppeal.
  ///
  /// In ar, this message translates to:
  /// **'تقديم الاعتراض'**
  String get finesSubmitAppeal;

  /// No description provided for @finesAppealSubmitted.
  ///
  /// In ar, this message translates to:
  /// **'تم تقديم اعتراضك، سيُراجَع قريبًا.'**
  String get finesAppealSubmitted;

  /// No description provided for @finesAppealPending.
  ///
  /// In ar, this message translates to:
  /// **'اعتراضك قيد المراجعة.'**
  String get finesAppealPending;

  /// No description provided for @finesAppealStatementRequired.
  ///
  /// In ar, this message translates to:
  /// **'اكتب سبب اعتراضك أولًا.'**
  String get finesAppealStatementRequired;

  /// No description provided for @finesStatusFrozen.
  ///
  /// In ar, this message translates to:
  /// **'مجمّدة (نافذة اعتراض)'**
  String get finesStatusFrozen;

  /// No description provided for @finesStatusAppealed.
  ///
  /// In ar, this message translates to:
  /// **'قيد الاعتراض'**
  String get finesStatusAppealed;

  /// No description provided for @finesStatusUpheld.
  ///
  /// In ar, this message translates to:
  /// **'مؤيَّدة (مستحقة الخصم)'**
  String get finesStatusUpheld;

  /// No description provided for @finesStatusOverturned.
  ///
  /// In ar, this message translates to:
  /// **'ملغاة باعتراض'**
  String get finesStatusOverturned;

  /// No description provided for @finesStatusCollected.
  ///
  /// In ar, this message translates to:
  /// **'محصَّلة'**
  String get finesStatusCollected;

  /// No description provided for @finesStatusCancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغاة'**
  String get finesStatusCancelled;

  /// No description provided for @projectsTitle.
  ///
  /// In ar, this message translates to:
  /// **'المشاريع'**
  String get projectsTitle;

  /// No description provided for @projectsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مشاريع بعد.'**
  String get projectsEmpty;

  /// No description provided for @projectTasksEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مهام بعد.'**
  String get projectTasksEmpty;

  /// No description provided for @projectsAdd.
  ///
  /// In ar, this message translates to:
  /// **'مشروع جديد'**
  String get projectsAdd;

  /// No description provided for @projectTitleLabel.
  ///
  /// In ar, this message translates to:
  /// **'عنوان المشروع'**
  String get projectTitleLabel;

  /// No description provided for @projectDescription.
  ///
  /// In ar, this message translates to:
  /// **'الوصف (اختياري)'**
  String get projectDescription;

  /// No description provided for @projectReference.
  ///
  /// In ar, this message translates to:
  /// **'المرجع (اختياري)'**
  String get projectReference;

  /// No description provided for @projectStartsOn.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ البدء (اختياري)'**
  String get projectStartsOn;

  /// No description provided for @projectDueOn.
  ///
  /// In ar, this message translates to:
  /// **'الموعد النهائي (اختياري)'**
  String get projectDueOn;

  /// No description provided for @projectTitleRequired.
  ///
  /// In ar, this message translates to:
  /// **'أدخل عنوان المشروع.'**
  String get projectTitleRequired;

  /// No description provided for @projectOverdueBadge.
  ///
  /// In ar, this message translates to:
  /// **'متأخر'**
  String get projectOverdueBadge;

  /// No description provided for @projectTasksTitle.
  ///
  /// In ar, this message translates to:
  /// **'المهام'**
  String get projectTasksTitle;

  /// No description provided for @projectAddTask.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مهمة'**
  String get projectAddTask;

  /// No description provided for @projectDeleteConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد حذف هذا المشروع؟ سيتم حذف كل مهامه.'**
  String get projectDeleteConfirm;

  /// No description provided for @taskTitleLabel.
  ///
  /// In ar, this message translates to:
  /// **'عنوان المهمة'**
  String get taskTitleLabel;

  /// No description provided for @taskNotes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات (اختياري)'**
  String get taskNotes;

  /// No description provided for @taskRequiresPhoto.
  ///
  /// In ar, this message translates to:
  /// **'يتطلب صورة إثبات عند الإنهاء'**
  String get taskRequiresPhoto;

  /// No description provided for @taskTitleRequired.
  ///
  /// In ar, this message translates to:
  /// **'أدخل عنوان المهمة.'**
  String get taskTitleRequired;

  /// No description provided for @taskCriticalBadge.
  ///
  /// In ar, this message translates to:
  /// **'حرجة'**
  String get taskCriticalBadge;

  /// No description provided for @taskDeleteConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد حذف هذه المهمة؟'**
  String get taskDeleteConfirm;

  /// No description provided for @taskProgressLabel.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الإنجاز'**
  String get taskProgressLabel;

  /// No description provided for @taskMarkDone.
  ///
  /// In ar, this message translates to:
  /// **'تحديد كمكتملة'**
  String get taskMarkDone;

  /// No description provided for @projectStatusPlanning.
  ///
  /// In ar, this message translates to:
  /// **'تخطيط'**
  String get projectStatusPlanning;

  /// No description provided for @projectStatusActive.
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get projectStatusActive;

  /// No description provided for @projectStatusOnHold.
  ///
  /// In ar, this message translates to:
  /// **'متوقف مؤقتًا'**
  String get projectStatusOnHold;

  /// No description provided for @projectStatusCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get projectStatusCompleted;

  /// No description provided for @projectStatusCancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغي'**
  String get projectStatusCancelled;

  /// No description provided for @taskStatusPending.
  ///
  /// In ar, this message translates to:
  /// **'قيد الانتظار'**
  String get taskStatusPending;

  /// No description provided for @taskStatusInProgress.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التنفيذ'**
  String get taskStatusInProgress;

  /// No description provided for @taskStatusBlocked.
  ///
  /// In ar, this message translates to:
  /// **'معلّقة'**
  String get taskStatusBlocked;

  /// No description provided for @taskStatusDone.
  ///
  /// In ar, this message translates to:
  /// **'مكتملة'**
  String get taskStatusDone;

  /// No description provided for @projectProgressTitle.
  ///
  /// In ar, this message translates to:
  /// **'تقدّم المشروع'**
  String get projectProgressTitle;

  /// No description provided for @projectProgressEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد خطة تقدّم لهذه العملية بعد.'**
  String get projectProgressEmpty;

  /// No description provided for @projectViewProgress.
  ///
  /// In ar, this message translates to:
  /// **'عرض تقدّم المشروع'**
  String get projectViewProgress;

  /// No description provided for @tripSearchTitle.
  ///
  /// In ar, this message translates to:
  /// **'بحث الرحلات'**
  String get tripSearchTitle;

  /// No description provided for @tripOrigin.
  ///
  /// In ar, this message translates to:
  /// **'من'**
  String get tripOrigin;

  /// No description provided for @tripDestination.
  ///
  /// In ar, this message translates to:
  /// **'إلى'**
  String get tripDestination;

  /// No description provided for @tripChooseGovernorate.
  ///
  /// In ar, this message translates to:
  /// **'اختر المحافظة'**
  String get tripChooseGovernorate;

  /// No description provided for @tripDateOptional.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ (اختياري)'**
  String get tripDateOptional;

  /// No description provided for @tripSearchAction.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get tripSearchAction;

  /// No description provided for @tripSearchEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد رحلات مطابقة.'**
  String get tripSearchEmpty;

  /// No description provided for @tripSearchFieldsRequired.
  ///
  /// In ar, this message translates to:
  /// **'اختر محافظتي الانطلاق والوصول.'**
  String get tripSearchFieldsRequired;

  /// No description provided for @tripReserve.
  ///
  /// In ar, this message translates to:
  /// **'حجز'**
  String get tripReserve;

  /// No description provided for @tripUnits.
  ///
  /// In ar, this message translates to:
  /// **'عدد الوحدات'**
  String get tripUnits;

  /// No description provided for @tripReservationNotes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات (اختياري)'**
  String get tripReservationNotes;

  /// No description provided for @tripReserved.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء الحجز، بانتظار تأكيد الناقل.'**
  String get tripReserved;

  /// No description provided for @myReservationsTitle.
  ///
  /// In ar, this message translates to:
  /// **'حجوزات الرحلات'**
  String get myReservationsTitle;

  /// No description provided for @myReservationsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد حجوزات بعد.'**
  String get myReservationsEmpty;

  /// No description provided for @tripReservationCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الحجز'**
  String get tripReservationCancel;

  /// No description provided for @tripReservationCancelConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد إلغاء هذا الحجز؟'**
  String get tripReservationCancelConfirm;

  /// No description provided for @tripReservationCancelled.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء الحجز.'**
  String get tripReservationCancelled;

  /// No description provided for @tripStatusPending.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار التأكيد'**
  String get tripStatusPending;

  /// No description provided for @tripStatusConfirmed.
  ///
  /// In ar, this message translates to:
  /// **'مؤكد'**
  String get tripStatusConfirmed;

  /// No description provided for @tripStatusCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get tripStatusCompleted;

  /// No description provided for @tripStatusCancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغي'**
  String get tripStatusCancelled;

  /// No description provided for @tripStatusBlocked.
  ///
  /// In ar, this message translates to:
  /// **'حجز يدوي'**
  String get tripStatusBlocked;

  /// No description provided for @tripModeFreight.
  ///
  /// In ar, this message translates to:
  /// **'شحن بضائع'**
  String get tripModeFreight;

  /// No description provided for @tripModePassenger.
  ///
  /// In ar, this message translates to:
  /// **'نقل ركاب'**
  String get tripModePassenger;

  /// No description provided for @tripModeLimousine.
  ///
  /// In ar, this message translates to:
  /// **'ليموزين'**
  String get tripModeLimousine;

  /// No description provided for @tripModeDistribution.
  ///
  /// In ar, this message translates to:
  /// **'توزيع'**
  String get tripModeDistribution;

  /// No description provided for @clinicBookAppointment.
  ///
  /// In ar, this message translates to:
  /// **'حجز موعد'**
  String get clinicBookAppointment;

  /// No description provided for @clinicNoOpenSlots.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد فترات متاحة حاليًا.'**
  String get clinicNoOpenSlots;

  /// No description provided for @clinicBookSlot.
  ///
  /// In ar, this message translates to:
  /// **'حجز الموعد'**
  String get clinicBookSlot;

  /// No description provided for @clinicReasonHint.
  ///
  /// In ar, this message translates to:
  /// **'سبب الزيارة (اختياري)'**
  String get clinicReasonHint;

  /// No description provided for @clinicAppointmentBooked.
  ///
  /// In ar, this message translates to:
  /// **'تم حجز الموعد.'**
  String get clinicAppointmentBooked;

  /// No description provided for @myClinicAppointmentsTitle.
  ///
  /// In ar, this message translates to:
  /// **'مواعيد العيادة'**
  String get myClinicAppointmentsTitle;

  /// No description provided for @myClinicAppointmentsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مواعيد بعد.'**
  String get myClinicAppointmentsEmpty;

  /// No description provided for @clinicAppointmentCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الموعد'**
  String get clinicAppointmentCancel;

  /// No description provided for @clinicAppointmentCancelConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد إلغاء هذا الموعد؟'**
  String get clinicAppointmentCancelConfirm;

  /// No description provided for @clinicAppointmentCancelled.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء الموعد.'**
  String get clinicAppointmentCancelled;

  /// No description provided for @clinicStatusRequested.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار التأكيد'**
  String get clinicStatusRequested;

  /// No description provided for @clinicStatusConfirmed.
  ///
  /// In ar, this message translates to:
  /// **'مؤكد'**
  String get clinicStatusConfirmed;

  /// No description provided for @clinicStatusCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get clinicStatusCompleted;

  /// No description provided for @clinicStatusCancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغي'**
  String get clinicStatusCancelled;

  /// No description provided for @clinicStatusNoShow.
  ///
  /// In ar, this message translates to:
  /// **'لم يحضر'**
  String get clinicStatusNoShow;

  /// No description provided for @trainingPlansTitle.
  ///
  /// In ar, this message translates to:
  /// **'خطط التدريب'**
  String get trainingPlansTitle;

  /// No description provided for @trainingPlansEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد خطط تدريب بعد.'**
  String get trainingPlansEmpty;

  /// No description provided for @trainingStatusActive.
  ///
  /// In ar, this message translates to:
  /// **'نشطة'**
  String get trainingStatusActive;

  /// No description provided for @trainingStatusPaused.
  ///
  /// In ar, this message translates to:
  /// **'متوقفة مؤقتًا'**
  String get trainingStatusPaused;

  /// No description provided for @trainingStatusCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتملة'**
  String get trainingStatusCompleted;

  /// No description provided for @trainingStatusCancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغاة'**
  String get trainingStatusCancelled;

  /// No description provided for @trainingTabExercises.
  ///
  /// In ar, this message translates to:
  /// **'التمارين'**
  String get trainingTabExercises;

  /// No description provided for @trainingTabMeals.
  ///
  /// In ar, this message translates to:
  /// **'الوجبات'**
  String get trainingTabMeals;

  /// No description provided for @trainingTabProgress.
  ///
  /// In ar, this message translates to:
  /// **'التقدّم'**
  String get trainingTabProgress;

  /// No description provided for @trainingTabBodyReports.
  ///
  /// In ar, this message translates to:
  /// **'تقارير الجسم'**
  String get trainingTabBodyReports;

  /// No description provided for @trainingExercisesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تمارين بعد.'**
  String get trainingExercisesEmpty;

  /// No description provided for @trainingMealsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد وجبات بعد.'**
  String get trainingMealsEmpty;

  /// No description provided for @trainingSetsLabel.
  ///
  /// In ar, this message translates to:
  /// **'المجموعات'**
  String get trainingSetsLabel;

  /// No description provided for @trainingRepsLabel.
  ///
  /// In ar, this message translates to:
  /// **'التكرارات'**
  String get trainingRepsLabel;

  /// No description provided for @trainingRestLabel.
  ///
  /// In ar, this message translates to:
  /// **'الراحة'**
  String get trainingRestLabel;

  /// No description provided for @trainingCompleteRound.
  ///
  /// In ar, this message translates to:
  /// **'إتمام جولة'**
  String get trainingCompleteRound;

  /// No description provided for @trainingRoundCompleted.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الجولة.'**
  String get trainingRoundCompleted;

  /// No description provided for @trainingAllRoundsDone.
  ///
  /// In ar, this message translates to:
  /// **'اكتملت كل الجولات اليوم'**
  String get trainingAllRoundsDone;

  /// No description provided for @trainingLogProgress.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل التقدّم'**
  String get trainingLogProgress;

  /// No description provided for @trainingWeightHint.
  ///
  /// In ar, this message translates to:
  /// **'الوزن (كجم)'**
  String get trainingWeightHint;

  /// No description provided for @trainingNotesHint.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات (اختياري)'**
  String get trainingNotesHint;

  /// No description provided for @trainingProgressLogged.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل تقدّمك.'**
  String get trainingProgressLogged;

  /// No description provided for @trainingProgressEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تسجيلات بعد.'**
  String get trainingProgressEmpty;

  /// No description provided for @trainingWeeklySummaryTitle.
  ///
  /// In ar, this message translates to:
  /// **'هذا الأسبوع'**
  String get trainingWeeklySummaryTitle;

  /// No description provided for @trainingAdherence.
  ///
  /// In ar, this message translates to:
  /// **'الالتزام'**
  String get trainingAdherence;

  /// No description provided for @trainingTargetRounds.
  ///
  /// In ar, this message translates to:
  /// **'الجولات المستهدفة'**
  String get trainingTargetRounds;

  /// No description provided for @trainingCompletedRoundsLabel.
  ///
  /// In ar, this message translates to:
  /// **'الجولات المكتملة'**
  String get trainingCompletedRoundsLabel;

  /// No description provided for @trainingActiveDays.
  ///
  /// In ar, this message translates to:
  /// **'أيام النشاط'**
  String get trainingActiveDays;

  /// No description provided for @trainingCheckIns.
  ///
  /// In ar, this message translates to:
  /// **'عدد التسجيلات'**
  String get trainingCheckIns;

  /// No description provided for @trainingLatestWeight.
  ///
  /// In ar, this message translates to:
  /// **'آخر وزن'**
  String get trainingLatestWeight;

  /// No description provided for @trainingBodyReportsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد قراءات مسجلة بعد.'**
  String get trainingBodyReportsEmpty;

  /// No description provided for @mealBreakfast.
  ///
  /// In ar, this message translates to:
  /// **'فطار'**
  String get mealBreakfast;

  /// No description provided for @mealLunch.
  ///
  /// In ar, this message translates to:
  /// **'غداء'**
  String get mealLunch;

  /// No description provided for @mealDinner.
  ///
  /// In ar, this message translates to:
  /// **'عشاء'**
  String get mealDinner;

  /// No description provided for @mealSnack.
  ///
  /// In ar, this message translates to:
  /// **'سناك'**
  String get mealSnack;

  /// No description provided for @bodyReportWeight.
  ///
  /// In ar, this message translates to:
  /// **'الوزن'**
  String get bodyReportWeight;

  /// No description provided for @bodyReportMuscle.
  ///
  /// In ar, this message translates to:
  /// **'الكتلة العضلية'**
  String get bodyReportMuscle;

  /// No description provided for @bodyReportFat.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الدهون'**
  String get bodyReportFat;

  /// No description provided for @bodyReportWater.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الماء'**
  String get bodyReportWater;

  /// No description provided for @bodyReportBone.
  ///
  /// In ar, this message translates to:
  /// **'كتلة العظام'**
  String get bodyReportBone;

  /// No description provided for @bodyReportVisceralFat.
  ///
  /// In ar, this message translates to:
  /// **'الدهون الحشوية'**
  String get bodyReportVisceralFat;

  /// No description provided for @prescriptionsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الروشتات'**
  String get prescriptionsTitle;

  /// No description provided for @prescriptionsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد روشتات بعد.'**
  String get prescriptionsEmpty;

  /// No description provided for @prescriptionStatusIssued.
  ///
  /// In ar, this message translates to:
  /// **'صدرت'**
  String get prescriptionStatusIssued;

  /// No description provided for @prescriptionStatusSent.
  ///
  /// In ar, this message translates to:
  /// **'أُرسلت للصيدلية'**
  String get prescriptionStatusSent;

  /// No description provided for @prescriptionStatusPreparing.
  ///
  /// In ar, this message translates to:
  /// **'قيد التجهيز'**
  String get prescriptionStatusPreparing;

  /// No description provided for @prescriptionStatusReady.
  ///
  /// In ar, this message translates to:
  /// **'جاهزة'**
  String get prescriptionStatusReady;

  /// No description provided for @prescriptionStatusDispensed.
  ///
  /// In ar, this message translates to:
  /// **'تم الصرف'**
  String get prescriptionStatusDispensed;

  /// No description provided for @prescriptionStatusCancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغاة'**
  String get prescriptionStatusCancelled;

  /// No description provided for @prescriptionDiagnosisLabel.
  ///
  /// In ar, this message translates to:
  /// **'التشخيص'**
  String get prescriptionDiagnosisLabel;

  /// No description provided for @prescriptionConditionLabel.
  ///
  /// In ar, this message translates to:
  /// **'حالة المريض'**
  String get prescriptionConditionLabel;

  /// No description provided for @prescriptionNotesLabel.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات'**
  String get prescriptionNotesLabel;

  /// No description provided for @prescriptionPharmacyLabel.
  ///
  /// In ar, this message translates to:
  /// **'الصيدلية'**
  String get prescriptionPharmacyLabel;

  /// No description provided for @prescriptionMedicineTotalLabel.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get prescriptionMedicineTotalLabel;

  /// No description provided for @prescriptionSharedWithTitle.
  ///
  /// In ar, this message translates to:
  /// **'تمت مشاركتها مع'**
  String get prescriptionSharedWithTitle;

  /// No description provided for @prescriptionItemsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الأدوية'**
  String get prescriptionItemsTitle;

  /// No description provided for @prescriptionDosageLabel.
  ///
  /// In ar, this message translates to:
  /// **'الجرعة'**
  String get prescriptionDosageLabel;

  /// No description provided for @prescriptionQuantityLabel.
  ///
  /// In ar, this message translates to:
  /// **'الكمية'**
  String get prescriptionQuantityLabel;

  /// No description provided for @prescriptionFoodBefore.
  ///
  /// In ar, this message translates to:
  /// **'قبل الأكل'**
  String get prescriptionFoodBefore;

  /// No description provided for @prescriptionFoodWith.
  ///
  /// In ar, this message translates to:
  /// **'مع الأكل'**
  String get prescriptionFoodWith;

  /// No description provided for @prescriptionFoodAfter.
  ///
  /// In ar, this message translates to:
  /// **'بعد الأكل'**
  String get prescriptionFoodAfter;

  /// No description provided for @prescriptionSlotMorning.
  ///
  /// In ar, this message translates to:
  /// **'الصباح'**
  String get prescriptionSlotMorning;

  /// No description provided for @prescriptionSlotEvening.
  ///
  /// In ar, this message translates to:
  /// **'المساء'**
  String get prescriptionSlotEvening;

  /// No description provided for @prescriptionDurationDays.
  ///
  /// In ar, this message translates to:
  /// **'يوم/أيام'**
  String get prescriptionDurationDays;

  /// No description provided for @prescriptionDurationWeeks.
  ///
  /// In ar, this message translates to:
  /// **'أسبوع/أسابيع'**
  String get prescriptionDurationWeeks;

  /// No description provided for @prescriptionDurationMonths.
  ///
  /// In ar, this message translates to:
  /// **'شهر/أشهر'**
  String get prescriptionDurationMonths;

  /// No description provided for @prescriptionImagesTitle.
  ///
  /// In ar, this message translates to:
  /// **'الصور'**
  String get prescriptionImagesTitle;

  /// No description provided for @prescriptionSendToPharmacy.
  ///
  /// In ar, this message translates to:
  /// **'إرسال إلى صيدلية'**
  String get prescriptionSendToPharmacy;

  /// No description provided for @prescriptionSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال الوصفة إلى الصيدلية.'**
  String get prescriptionSent;

  /// No description provided for @prescriptionFulfillmentDelivery.
  ///
  /// In ar, this message translates to:
  /// **'توصيل'**
  String get prescriptionFulfillmentDelivery;

  /// No description provided for @prescriptionFulfillmentPickup.
  ///
  /// In ar, this message translates to:
  /// **'استلام'**
  String get prescriptionFulfillmentPickup;

  /// No description provided for @prescriptionDeliveryAddressHint.
  ///
  /// In ar, this message translates to:
  /// **'عنوان التوصيل'**
  String get prescriptionDeliveryAddressHint;

  /// No description provided for @prescriptionCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الوصفة'**
  String get prescriptionCancel;

  /// No description provided for @prescriptionCancelConfirm.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء هذه الوصفة؟'**
  String get prescriptionCancelConfirm;

  /// No description provided for @prescriptionCancelled.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء الوصفة.'**
  String get prescriptionCancelled;

  /// No description provided for @prescriptionScheduleReminders.
  ///
  /// In ar, this message translates to:
  /// **'جدولة التذكيرات'**
  String get prescriptionScheduleReminders;

  /// No description provided for @prescriptionRemindersLabel.
  ///
  /// In ar, this message translates to:
  /// **'تذكيرًا تمت جدولتها'**
  String get prescriptionRemindersLabel;

  /// No description provided for @prescriptionShareWithDoctor.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة مع طبيب آخر'**
  String get prescriptionShareWithDoctor;

  /// No description provided for @prescriptionShared.
  ///
  /// In ar, this message translates to:
  /// **'تمت مشاركة الوصفة.'**
  String get prescriptionShared;

  /// No description provided for @prescriptionSendPickPharmacyTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر صيدلية'**
  String get prescriptionSendPickPharmacyTitle;

  /// No description provided for @prescriptionSharePickDoctorTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر طبيبًا'**
  String get prescriptionSharePickDoctorTitle;

  /// No description provided for @prescriptionSupersededLabel.
  ///
  /// In ar, this message translates to:
  /// **'استُبدلت بنسخة معدّلة'**
  String get prescriptionSupersededLabel;

  /// No description provided for @prescriptionRemovePhotoConfirm.
  ///
  /// In ar, this message translates to:
  /// **'حذف هذه الصورة؟'**
  String get prescriptionRemovePhotoConfirm;

  /// No description provided for @offersTitle.
  ///
  /// In ar, this message translates to:
  /// **'العروض'**
  String get offersTitle;

  /// No description provided for @offersEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عروض الآن.'**
  String get offersEmpty;

  /// No description provided for @offersSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن عرض...'**
  String get offersSearchHint;

  /// No description provided for @offerSortBoosted.
  ///
  /// In ar, this message translates to:
  /// **'مميز'**
  String get offerSortBoosted;

  /// No description provided for @offerSortLatest.
  ///
  /// In ar, this message translates to:
  /// **'الأحدث'**
  String get offerSortLatest;

  /// No description provided for @offerSortLowestPrice.
  ///
  /// In ar, this message translates to:
  /// **'الأقل سعرًا'**
  String get offerSortLowestPrice;

  /// No description provided for @offerFollowBusiness.
  ///
  /// In ar, this message translates to:
  /// **'متابعة هذا البائع'**
  String get offerFollowBusiness;

  /// No description provided for @offerUnfollowBusiness.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء المتابعة'**
  String get offerUnfollowBusiness;

  /// No description provided for @offerFollowed.
  ///
  /// In ar, this message translates to:
  /// **'سنخبرك بعروض هذا البائع القادمة.'**
  String get offerFollowed;

  /// No description provided for @offerUnfollowed.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء المتابعة.'**
  String get offerUnfollowed;

  /// No description provided for @myOfferFollowsTitle.
  ///
  /// In ar, this message translates to:
  /// **'البائعون المتابَعون'**
  String get myOfferFollowsTitle;

  /// No description provided for @myOfferFollowsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا تتابع أي بائع بعد.'**
  String get myOfferFollowsEmpty;

  /// No description provided for @offerAvailableQuantityLabel.
  ///
  /// In ar, this message translates to:
  /// **'الكمية المتاحة'**
  String get offerAvailableQuantityLabel;

  /// No description provided for @offerEndsAtLabel.
  ///
  /// In ar, this message translates to:
  /// **'ينتهى'**
  String get offerEndsAtLabel;

  /// No description provided for @disputesTitle.
  ///
  /// In ar, this message translates to:
  /// **'نزاعاتي'**
  String get disputesTitle;

  /// No description provided for @disputesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نزاعات.'**
  String get disputesEmpty;

  /// No description provided for @disputeStatusOpen.
  ///
  /// In ar, this message translates to:
  /// **'مفتوح'**
  String get disputeStatusOpen;

  /// No description provided for @disputeStatusMutualResolution.
  ///
  /// In ar, this message translates to:
  /// **'فترة التراضي'**
  String get disputeStatusMutualResolution;

  /// No description provided for @disputeStatusUnderReview.
  ///
  /// In ar, this message translates to:
  /// **'قيد التحكيم'**
  String get disputeStatusUnderReview;

  /// No description provided for @disputeStatusResolved.
  ///
  /// In ar, this message translates to:
  /// **'تم الفصل'**
  String get disputeStatusResolved;

  /// No description provided for @disputeStatusClosed.
  ///
  /// In ar, this message translates to:
  /// **'مغلق'**
  String get disputeStatusClosed;

  /// No description provided for @disputeStatusCancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغى'**
  String get disputeStatusCancelled;

  /// No description provided for @disputeStatusExpired.
  ///
  /// In ar, this message translates to:
  /// **'منتهي'**
  String get disputeStatusExpired;

  /// No description provided for @disputeRoleOpener.
  ///
  /// In ar, this message translates to:
  /// **'أنت من فتح هذا النزاع'**
  String get disputeRoleOpener;

  /// No description provided for @disputeRoleRespondent.
  ///
  /// In ar, this message translates to:
  /// **'فُتح ضدك'**
  String get disputeRoleRespondent;

  /// No description provided for @disputeReasonNotDelivered.
  ///
  /// In ar, this message translates to:
  /// **'لم يُسلَّم'**
  String get disputeReasonNotDelivered;

  /// No description provided for @disputeReasonNotAsDescribed.
  ///
  /// In ar, this message translates to:
  /// **'غير مطابق للوصف'**
  String get disputeReasonNotAsDescribed;

  /// No description provided for @disputeReasonQuality.
  ///
  /// In ar, this message translates to:
  /// **'مشكلة في الجودة'**
  String get disputeReasonQuality;

  /// No description provided for @disputeReasonLate.
  ///
  /// In ar, this message translates to:
  /// **'تأخير'**
  String get disputeReasonLate;

  /// No description provided for @disputeReasonCancelledByBusiness.
  ///
  /// In ar, this message translates to:
  /// **'ألغاه النشاط التجاري'**
  String get disputeReasonCancelledByBusiness;

  /// No description provided for @disputeReasonNoShow.
  ///
  /// In ar, this message translates to:
  /// **'لم يحضر'**
  String get disputeReasonNoShow;

  /// No description provided for @disputeReasonOvercharged.
  ///
  /// In ar, this message translates to:
  /// **'تحصيل زائد'**
  String get disputeReasonOvercharged;

  /// No description provided for @disputeReasonDamage.
  ///
  /// In ar, this message translates to:
  /// **'تلف'**
  String get disputeReasonDamage;

  /// No description provided for @disputeReasonOther.
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get disputeReasonOther;

  /// No description provided for @disputeOpenTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإبلاغ عن مشكلة'**
  String get disputeOpenTitle;

  /// No description provided for @disputeReasonLabel.
  ///
  /// In ar, this message translates to:
  /// **'السبب'**
  String get disputeReasonLabel;

  /// No description provided for @disputeDetailsHint.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل إضافية (اختياري)'**
  String get disputeDetailsHint;

  /// No description provided for @disputeOpened.
  ///
  /// In ar, this message translates to:
  /// **'تم فتح النزاع.'**
  String get disputeOpened;

  /// No description provided for @disputeCooperate.
  ///
  /// In ar, this message translates to:
  /// **'أنا منخرط فى التسوية'**
  String get disputeCooperate;

  /// No description provided for @disputeCooperated.
  ///
  /// In ar, this message translates to:
  /// **'تم التسجيل كمنخرط.'**
  String get disputeCooperated;

  /// No description provided for @disputeRequestArbitration.
  ///
  /// In ar, this message translates to:
  /// **'طلب التحكيم'**
  String get disputeRequestArbitration;

  /// No description provided for @disputeArbitrationRequested.
  ///
  /// In ar, this message translates to:
  /// **'تم طلب التحكيم.'**
  String get disputeArbitrationRequested;

  /// No description provided for @disputeArbitrationFeeLabel.
  ///
  /// In ar, this message translates to:
  /// **'رسم الجلسة'**
  String get disputeArbitrationFeeLabel;

  /// No description provided for @disputeArbitrationBalanceLabel.
  ///
  /// In ar, this message translates to:
  /// **'رصيدك'**
  String get disputeArbitrationBalanceLabel;

  /// No description provided for @disputeAgreeSettlement.
  ///
  /// In ar, this message translates to:
  /// **'اتفقنا — إنهاء النزاع'**
  String get disputeAgreeSettlement;

  /// No description provided for @disputeWithdrawSettlement.
  ///
  /// In ar, this message translates to:
  /// **'سحب الموافقة'**
  String get disputeWithdrawSettlement;

  /// No description provided for @disputeSettlementAgreed.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الموافقة.'**
  String get disputeSettlementAgreed;

  /// No description provided for @disputeSettlementWithdrawn.
  ///
  /// In ar, this message translates to:
  /// **'تم سحب الموافقة.'**
  String get disputeSettlementWithdrawn;

  /// No description provided for @disputeSettlementCompleteLabel.
  ///
  /// In ar, this message translates to:
  /// **'وافق الطرفان — تمت تسوية النزاع.'**
  String get disputeSettlementCompleteLabel;

  /// No description provided for @disputeSettlementWaitingLabel.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار موافقة الطرف الآخر.'**
  String get disputeSettlementWaitingLabel;

  /// No description provided for @disputeCounterpartyLabel.
  ///
  /// In ar, this message translates to:
  /// **'الطرف الآخر'**
  String get disputeCounterpartyLabel;

  /// No description provided for @disputeCooperationTitle.
  ///
  /// In ar, this message translates to:
  /// **'الانخراط فى التسوية'**
  String get disputeCooperationTitle;

  /// No description provided for @disputeCooperationClientLabel.
  ///
  /// In ar, this message translates to:
  /// **'العميل'**
  String get disputeCooperationClientLabel;

  /// No description provided for @disputeCooperationBusinessLabel.
  ///
  /// In ar, this message translates to:
  /// **'النشاط التجاري'**
  String get disputeCooperationBusinessLabel;

  /// No description provided for @disputeCooperationPending.
  ///
  /// In ar, this message translates to:
  /// **'لم يحدث بعد'**
  String get disputeCooperationPending;

  /// No description provided for @disputeMyObligationsTitle.
  ///
  /// In ar, this message translates to:
  /// **'ما عليّ في هذا النزاع'**
  String get disputeMyObligationsTitle;

  /// No description provided for @disputeObligationsTitle.
  ///
  /// In ar, this message translates to:
  /// **'مستحقات النزاعات'**
  String get disputeObligationsTitle;

  /// No description provided for @disputeSettleObligations.
  ///
  /// In ar, this message translates to:
  /// **'السداد من المحفظة'**
  String get disputeSettleObligations;

  /// No description provided for @disputeObligationSettled.
  ///
  /// In ar, this message translates to:
  /// **'تم السداد.'**
  String get disputeObligationSettled;

  /// No description provided for @disputeObligationsBlockedNotice.
  ///
  /// In ar, this message translates to:
  /// **'عليك مستحقات نزاعات غير مسددة تمنعك من عمليات جديدة.'**
  String get disputeObligationsBlockedNotice;

  /// No description provided for @disputeOwedByMeTitle.
  ///
  /// In ar, this message translates to:
  /// **'عليّ'**
  String get disputeOwedByMeTitle;

  /// No description provided for @disputeOwedToMeTitle.
  ///
  /// In ar, this message translates to:
  /// **'لي'**
  String get disputeOwedToMeTitle;

  /// No description provided for @disputeObligationsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد مستحق.'**
  String get disputeObligationsEmpty;

  /// No description provided for @disputeClosePurgeAction.
  ///
  /// In ar, this message translates to:
  /// **'حذف هذه المحادثة'**
  String get disputeClosePurgeAction;

  /// No description provided for @disputeClosurePurgeConfirm.
  ///
  /// In ar, this message translates to:
  /// **'حذف هذه المحادثة نهائيًا؟ يبقى سجل الحكم فقط.'**
  String get disputeClosurePurgeConfirm;

  /// No description provided for @disputeClosurePurged.
  ///
  /// In ar, this message translates to:
  /// **'تم الطلب.'**
  String get disputeClosurePurged;

  /// No description provided for @disputeRoomTitle.
  ///
  /// In ar, this message translates to:
  /// **'غرفة النزاع'**
  String get disputeRoomTitle;

  /// No description provided for @disputeConductTitle.
  ///
  /// In ar, this message translates to:
  /// **'قواعد الغرفة'**
  String get disputeConductTitle;

  /// No description provided for @disputeConductAccept.
  ///
  /// In ar, this message translates to:
  /// **'أوافق'**
  String get disputeConductAccept;

  /// No description provided for @disputeConductDecline.
  ///
  /// In ar, this message translates to:
  /// **'لا أوافق'**
  String get disputeConductDecline;

  /// No description provided for @disputeRoomLocked.
  ///
  /// In ar, this message translates to:
  /// **'هذه الغرفة مغلقة.'**
  String get disputeRoomLocked;

  /// No description provided for @disputeRoomPurgedNotice.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف هذه المحادثة.'**
  String get disputeRoomPurgedNotice;

  /// No description provided for @disputeSettlementPaymentsTitle.
  ///
  /// In ar, this message translates to:
  /// **'دفع خارج المنصة'**
  String get disputeSettlementPaymentsTitle;

  /// No description provided for @disputeProposePayment.
  ///
  /// In ar, this message translates to:
  /// **'اقتراح دفعة'**
  String get disputeProposePayment;

  /// No description provided for @disputePayerLabel.
  ///
  /// In ar, this message translates to:
  /// **'من يدفع'**
  String get disputePayerLabel;

  /// No description provided for @disputePayerClient.
  ///
  /// In ar, this message translates to:
  /// **'العميل'**
  String get disputePayerClient;

  /// No description provided for @disputePayerBusiness.
  ///
  /// In ar, this message translates to:
  /// **'النشاط التجاري'**
  String get disputePayerBusiness;

  /// No description provided for @disputeAmountHint.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ'**
  String get disputeAmountHint;

  /// No description provided for @disputeMethodHint.
  ///
  /// In ar, this message translates to:
  /// **'وسيلة الدفع (اختياري)'**
  String get disputeMethodHint;

  /// No description provided for @disputeNoteHint.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة (اختياري)'**
  String get disputeNoteHint;

  /// No description provided for @disputePropose.
  ///
  /// In ar, this message translates to:
  /// **'اقتراح'**
  String get disputePropose;

  /// No description provided for @disputeAccept.
  ///
  /// In ar, this message translates to:
  /// **'قبول'**
  String get disputeAccept;

  /// No description provided for @disputeReject.
  ///
  /// In ar, this message translates to:
  /// **'رفض'**
  String get disputeReject;

  /// No description provided for @disputeConfirmReceived.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الاستلام'**
  String get disputeConfirmReceived;

  /// No description provided for @disputeWithdraw.
  ///
  /// In ar, this message translates to:
  /// **'سحب'**
  String get disputeWithdraw;

  /// No description provided for @disputeNoSettlementPayments.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مقترحات دفع بعد.'**
  String get disputeNoSettlementPayments;

  /// No description provided for @disputeHistoryTitle.
  ///
  /// In ar, this message translates to:
  /// **'السجل'**
  String get disputeHistoryTitle;

  /// No description provided for @addressesTitle.
  ///
  /// In ar, this message translates to:
  /// **'عناويني'**
  String get addressesTitle;

  /// No description provided for @addressesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عناوين محفوظة بعد.'**
  String get addressesEmpty;

  /// No description provided for @addressAddTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة عنوان'**
  String get addressAddTitle;

  /// No description provided for @addressEditTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل العنوان'**
  String get addressEditTitle;

  /// No description provided for @addressLineHint.
  ///
  /// In ar, this message translates to:
  /// **'الشارع، المبنى، الدور...'**
  String get addressLineHint;

  /// No description provided for @addressZipHint.
  ///
  /// In ar, this message translates to:
  /// **'الرمز البريدي (اختياري)'**
  String get addressZipHint;

  /// No description provided for @addressMakePrimary.
  ///
  /// In ar, this message translates to:
  /// **'اجعله العنوان الأساسي'**
  String get addressMakePrimary;

  /// No description provided for @addressDeleteConfirm.
  ///
  /// In ar, this message translates to:
  /// **'حذف هذا العنوان؟'**
  String get addressDeleteConfirm;

  /// No description provided for @addressPickTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر عنوان التوصيل'**
  String get addressPickTitle;

  /// No description provided for @addressUseNewLabel.
  ///
  /// In ar, this message translates to:
  /// **'كتابة عنوان آخر'**
  String get addressUseNewLabel;

  /// No description provided for @commentsTitle.
  ///
  /// In ar, this message translates to:
  /// **'التعليقات'**
  String get commentsTitle;

  /// No description provided for @commentsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تعليقات بعد.'**
  String get commentsEmpty;

  /// No description provided for @commentComposeHint.
  ///
  /// In ar, this message translates to:
  /// **'أضف تعليقًا...'**
  String get commentComposeHint;

  /// No description provided for @commentReplyHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب ردًا...'**
  String get commentReplyHint;

  /// No description provided for @commentPrivateToggle.
  ///
  /// In ar, this message translates to:
  /// **'يظهر لصاحب المنشور فقط'**
  String get commentPrivateToggle;

  /// No description provided for @commentPrivateBadge.
  ///
  /// In ar, this message translates to:
  /// **'خاص'**
  String get commentPrivateBadge;

  /// No description provided for @commentRepliesLabel.
  ///
  /// In ar, this message translates to:
  /// **'ردود'**
  String get commentRepliesLabel;

  /// No description provided for @commentViewReplies.
  ///
  /// In ar, this message translates to:
  /// **'عرض الردود'**
  String get commentViewReplies;

  /// No description provided for @commentHideReplies.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء الردود'**
  String get commentHideReplies;

  /// No description provided for @commentReplyAction.
  ///
  /// In ar, this message translates to:
  /// **'رد'**
  String get commentReplyAction;

  /// No description provided for @commentEditAction.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get commentEditAction;

  /// No description provided for @commentDeleteAction.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get commentDeleteAction;

  /// No description provided for @commentDeleteConfirm.
  ///
  /// In ar, this message translates to:
  /// **'حذف هذا التعليق؟'**
  String get commentDeleteConfirm;

  /// No description provided for @commentSend.
  ///
  /// In ar, this message translates to:
  /// **'نشر'**
  String get commentSend;

  /// No description provided for @guaranteeTitle.
  ///
  /// In ar, this message translates to:
  /// **'ضماني'**
  String get guaranteeTitle;

  /// No description provided for @guaranteeNoneYet.
  ///
  /// In ar, this message translates to:
  /// **'لم تُفعّل ضمانًا بعد.'**
  String get guaranteeNoneYet;

  /// No description provided for @guaranteeLockedAmountLabel.
  ///
  /// In ar, this message translates to:
  /// **'المحجوز'**
  String get guaranteeLockedAmountLabel;

  /// No description provided for @guaranteeCoverageLabel.
  ///
  /// In ar, this message translates to:
  /// **'التغطية'**
  String get guaranteeCoverageLabel;

  /// No description provided for @guaranteeAvailableCoverageLabel.
  ///
  /// In ar, this message translates to:
  /// **'التغطية المتاحة'**
  String get guaranteeAvailableCoverageLabel;

  /// No description provided for @guaranteeUsedCoverageLabel.
  ///
  /// In ar, this message translates to:
  /// **'المستخدَم'**
  String get guaranteeUsedCoverageLabel;

  /// No description provided for @guaranteeTrustScoreLabel.
  ///
  /// In ar, this message translates to:
  /// **'درجة الثقة'**
  String get guaranteeTrustScoreLabel;

  /// No description provided for @guaranteeCompletedOpsLabel.
  ///
  /// In ar, this message translates to:
  /// **'العمليات المكتملة'**
  String get guaranteeCompletedOpsLabel;

  /// No description provided for @guaranteeLevelsTitle.
  ///
  /// In ar, this message translates to:
  /// **'مستويات التغطية'**
  String get guaranteeLevelsTitle;

  /// No description provided for @guaranteeActivate.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل'**
  String get guaranteeActivate;

  /// No description provided for @guaranteeUpgrade.
  ///
  /// In ar, this message translates to:
  /// **'ترقية'**
  String get guaranteeUpgrade;

  /// No description provided for @guaranteeCurrentLevelBadge.
  ///
  /// In ar, this message translates to:
  /// **'الحالي'**
  String get guaranteeCurrentLevelBadge;

  /// No description provided for @guaranteeAutoActivate.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل أفضل مستوى متاح'**
  String get guaranteeAutoActivate;

  /// No description provided for @guaranteeUnlock.
  ///
  /// In ar, this message translates to:
  /// **'فكّ الضمان'**
  String get guaranteeUnlock;

  /// No description provided for @guaranteeUnlockConfirm.
  ///
  /// In ar, this message translates to:
  /// **'فكّ ضمانك وإعادة المبلغ المحجوز إلى محفظتك؟'**
  String get guaranteeUnlockConfirm;

  /// No description provided for @guaranteeUnlocked.
  ///
  /// In ar, this message translates to:
  /// **'تم فكّ الضمان.'**
  String get guaranteeUnlocked;

  /// No description provided for @guaranteeActivated.
  ///
  /// In ar, this message translates to:
  /// **'تم تفعيل الضمان.'**
  String get guaranteeActivated;

  /// No description provided for @guaranteeNoChange.
  ///
  /// In ar, this message translates to:
  /// **'لا تغيير — رصيدك لا يكفي مستوى أعلى بعد.'**
  String get guaranteeNoChange;

  /// No description provided for @guaranteeTransactionsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الحركات'**
  String get guaranteeTransactionsTitle;

  /// No description provided for @guaranteeTransactionsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد حركات بعد.'**
  String get guaranteeTransactionsEmpty;

  /// No description provided for @guaranteeRequiredLockedLabel.
  ///
  /// In ar, this message translates to:
  /// **'يتطلب'**
  String get guaranteeRequiredLockedLabel;

  /// No description provided for @jobsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الوظائف'**
  String get jobsTitle;

  /// No description provided for @jobsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد وظائف متاحة الآن.'**
  String get jobsEmpty;

  /// No description provided for @jobsSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن وظيفة...'**
  String get jobsSearchHint;

  /// No description provided for @jobsAllCategories.
  ///
  /// In ar, this message translates to:
  /// **'كل المجالات'**
  String get jobsAllCategories;

  /// No description provided for @jobSalaryLabel.
  ///
  /// In ar, this message translates to:
  /// **'الراتب'**
  String get jobSalaryLabel;

  /// No description provided for @jobRequirementsLabel.
  ///
  /// In ar, this message translates to:
  /// **'المتطلبات'**
  String get jobRequirementsLabel;

  /// No description provided for @jobInterviewLabel.
  ///
  /// In ar, this message translates to:
  /// **'المقابلة'**
  String get jobInterviewLabel;

  /// No description provided for @jobApplicantsLabel.
  ///
  /// In ar, this message translates to:
  /// **'متقدّم'**
  String get jobApplicantsLabel;

  /// No description provided for @jobApply.
  ///
  /// In ar, this message translates to:
  /// **'تقديم'**
  String get jobApply;

  /// No description provided for @jobApplied.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال طلبك.'**
  String get jobApplied;

  /// No description provided for @jobFollowsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات الوظائف'**
  String get jobFollowsTitle;

  /// No description provided for @jobFollowsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا تتابع أي مجال بعد.'**
  String get jobFollowsEmpty;

  /// No description provided for @jobFollowAdd.
  ///
  /// In ar, this message translates to:
  /// **'متابعة مجال'**
  String get jobFollowAdd;

  /// No description provided for @jobFollowPickTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر مجالًا لمتابعته'**
  String get jobFollowPickTitle;

  /// No description provided for @jobUnfollow.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء المتابعة'**
  String get jobUnfollow;

  /// No description provided for @jobFollowed.
  ///
  /// In ar, this message translates to:
  /// **'تمت متابعة هذا المجال.'**
  String get jobFollowed;

  /// No description provided for @agendaSettingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'التذكيرات ومواعيد الوجبات'**
  String get agendaSettingsTitle;

  /// No description provided for @agendaSettingsMealTimesSection.
  ///
  /// In ar, this message translates to:
  /// **'مواعيد الوجبات'**
  String get agendaSettingsMealTimesSection;

  /// No description provided for @agendaSettingsMealTimesHint.
  ///
  /// In ar, this message translates to:
  /// **'الجرعات الدوائية المرتبطة بالوجبات تُجدول حول هذه المواعيد.'**
  String get agendaSettingsMealTimesHint;

  /// No description provided for @agendaSettingsBreakfast.
  ///
  /// In ar, this message translates to:
  /// **'الإفطار'**
  String get agendaSettingsBreakfast;

  /// No description provided for @agendaSettingsLunch.
  ///
  /// In ar, this message translates to:
  /// **'الغداء'**
  String get agendaSettingsLunch;

  /// No description provided for @agendaSettingsDinner.
  ///
  /// In ar, this message translates to:
  /// **'العشاء'**
  String get agendaSettingsDinner;

  /// No description provided for @agendaSettingsMealTimesSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ مواعيد الوجبات.'**
  String get agendaSettingsMealTimesSaved;

  /// No description provided for @agendaSettingsRemindersSection.
  ///
  /// In ar, this message translates to:
  /// **'التذكيرات'**
  String get agendaSettingsRemindersSection;

  /// No description provided for @agendaSettingsRemindersHint.
  ///
  /// In ar, this message translates to:
  /// **'متى تريد أن يتم تذكيرك قبل موعد أو عنصر في الأجندة.'**
  String get agendaSettingsRemindersHint;

  /// No description provided for @agendaSettingsFirstLead.
  ///
  /// In ar, this message translates to:
  /// **'التذكير الأول بالموعد'**
  String get agendaSettingsFirstLead;

  /// No description provided for @agendaSettingsSecondLead.
  ///
  /// In ar, this message translates to:
  /// **'التذكير الثاني بالموعد'**
  String get agendaSettingsSecondLead;

  /// No description provided for @agendaSettingsSecondLeadNone.
  ///
  /// In ar, this message translates to:
  /// **'بدون'**
  String get agendaSettingsSecondLeadNone;

  /// No description provided for @agendaSettingsAgendaLead.
  ///
  /// In ar, this message translates to:
  /// **'تذكير عنصر الأجندة'**
  String get agendaSettingsAgendaLead;

  /// No description provided for @agendaSettingsAgendaLeadNone.
  ///
  /// In ar, this message translates to:
  /// **'في نفس الوقت'**
  String get agendaSettingsAgendaLeadNone;

  /// No description provided for @agendaSettingsRemindersSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ تفضيلات التذكير.'**
  String get agendaSettingsRemindersSaved;

  /// No description provided for @agendaSettingsSecondLeadError.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن يكون التذكير الثاني أقرب من الأول.'**
  String get agendaSettingsSecondLeadError;

  /// No description provided for @durationMinutes.
  ///
  /// In ar, this message translates to:
  /// **'{count} د'**
  String durationMinutes(int count);

  /// No description provided for @durationHours.
  ///
  /// In ar, this message translates to:
  /// **'{count} س'**
  String durationHours(int count);

  /// No description provided for @durationDays.
  ///
  /// In ar, this message translates to:
  /// **'{count} يوم'**
  String durationDays(int count);

  /// No description provided for @depositsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الضمانات المجمّدة'**
  String get depositsTitle;

  /// No description provided for @depositsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد ضمانات.'**
  String get depositsEmpty;

  /// No description provided for @depositsAllStatuses.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get depositsAllStatuses;

  /// No description provided for @depositStatusFrozen.
  ///
  /// In ar, this message translates to:
  /// **'مجمّد'**
  String get depositStatusFrozen;

  /// No description provided for @depositStatusInProgress.
  ///
  /// In ar, this message translates to:
  /// **'قيد التنفيذ'**
  String get depositStatusInProgress;

  /// No description provided for @depositStatusReleased.
  ///
  /// In ar, this message translates to:
  /// **'تم الإفراج'**
  String get depositStatusReleased;

  /// No description provided for @depositStatusRefunded.
  ///
  /// In ar, this message translates to:
  /// **'تم الاسترداد'**
  String get depositStatusRefunded;

  /// No description provided for @depositStatusSplit.
  ///
  /// In ar, this message translates to:
  /// **'مقسوم'**
  String get depositStatusSplit;

  /// No description provided for @depositRoleClient.
  ///
  /// In ar, this message translates to:
  /// **'أنت دفعت'**
  String get depositRoleClient;

  /// No description provided for @depositRoleBusiness.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ محجوز لك'**
  String get depositRoleBusiness;

  /// No description provided for @depositMyAmount.
  ///
  /// In ar, this message translates to:
  /// **'نصيبي'**
  String get depositMyAmount;

  /// No description provided for @depositTotalAmount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ الإجمالي'**
  String get depositTotalAmount;

  /// No description provided for @depositClientShare.
  ///
  /// In ar, this message translates to:
  /// **'نصيب العميل'**
  String get depositClientShare;

  /// No description provided for @depositBusinessShare.
  ///
  /// In ar, this message translates to:
  /// **'نصيب النشاط'**
  String get depositBusinessShare;

  /// No description provided for @depositCounterparty.
  ///
  /// In ar, this message translates to:
  /// **'الطرف الآخر'**
  String get depositCounterparty;

  /// No description provided for @depositCreatedAt.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الإنشاء'**
  String get depositCreatedAt;

  /// No description provided for @depositReleasedAt.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الإفراج'**
  String get depositReleasedAt;

  /// No description provided for @depositRefundedAt.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الاسترداد'**
  String get depositRefundedAt;

  /// No description provided for @depositBookingLabel.
  ///
  /// In ar, this message translates to:
  /// **'الحجز'**
  String get depositBookingLabel;

  /// No description provided for @myRatingTitle.
  ///
  /// In ar, this message translates to:
  /// **'تقييمي'**
  String get myRatingTitle;

  /// No description provided for @myRatingObjectiveSection.
  ///
  /// In ar, this message translates to:
  /// **'سجل العمليات'**
  String get myRatingObjectiveSection;

  /// No description provided for @myRatingTotalOperations.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي العمليات'**
  String get myRatingTotalOperations;

  /// No description provided for @myRatingSuccessRate.
  ///
  /// In ar, this message translates to:
  /// **'نسبة النجاح'**
  String get myRatingSuccessRate;

  /// No description provided for @myRatingCancelRate.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الإلغاء'**
  String get myRatingCancelRate;

  /// No description provided for @myRatingDisputeRate.
  ///
  /// In ar, this message translates to:
  /// **'نسبة النزاعات'**
  String get myRatingDisputeRate;

  /// No description provided for @myRatingFaultRate.
  ///
  /// In ar, this message translates to:
  /// **'قرارات ضدك'**
  String get myRatingFaultRate;

  /// No description provided for @myRatingVindicationRate.
  ///
  /// In ar, this message translates to:
  /// **'قرارات لصالحك'**
  String get myRatingVindicationRate;

  /// No description provided for @myRatingReviewsSection.
  ///
  /// In ar, this message translates to:
  /// **'التقييمات'**
  String get myRatingReviewsSection;

  /// No description provided for @myRatingStarsAverage.
  ///
  /// In ar, this message translates to:
  /// **'متوسط التقييم'**
  String get myRatingStarsAverage;

  /// No description provided for @myRatingReviewCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لا توجد تقييمات بعد} =1{تقييم واحد} =2{تقييمان} few{{count} تقييمات} many{{count} تقييمًا} other{{count} تقييم}}'**
  String myRatingReviewCount(int count);

  /// No description provided for @myRatingConsentSection.
  ///
  /// In ar, this message translates to:
  /// **'رسوم الخدمة'**
  String get myRatingConsentSection;

  /// No description provided for @myRatingConsentEnabledLabel.
  ///
  /// In ar, this message translates to:
  /// **'تقييمك مفتوح — تُطبَّق رسوم الخدمة على عملياتك الخاصة.'**
  String get myRatingConsentEnabledLabel;

  /// No description provided for @myRatingConsentDisabledLabel.
  ///
  /// In ar, this message translates to:
  /// **'تقييمك مغلق — التعامل مجاني، لكن تقييمك وتقييمات الآخرين لك تبقى مخفية حتى تفتحه.'**
  String get myRatingConsentDisabledLabel;

  /// No description provided for @myRatingEnableButton.
  ///
  /// In ar, this message translates to:
  /// **'افتح تقييمي'**
  String get myRatingEnableButton;

  /// No description provided for @myRatingEnableConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'فتح تقييمك؟'**
  String get myRatingEnableConfirmTitle;

  /// No description provided for @myRatingEnableConfirmBody.
  ///
  /// In ar, this message translates to:
  /// **'هذا يجعل عملياتك ظاهرة بتقييم ومراجعات، وستبدأ رسوم الخدمة على عملياتك الخاصة من الآن. تقدر تغلقه تاني في أي وقت.'**
  String get myRatingEnableConfirmBody;

  /// No description provided for @myRatingEnableConfirm.
  ///
  /// In ar, this message translates to:
  /// **'فتحه'**
  String get myRatingEnableConfirm;

  /// No description provided for @myRatingEnabledMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم فتح تقييمك. ستُطبَّق رسوم الخدمة على عملياتك من الآن.'**
  String get myRatingEnabledMessage;

  /// No description provided for @myRatingDisableButton.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق تقييمي'**
  String get myRatingDisableButton;

  /// No description provided for @myRatingDisableConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق تقييمك؟'**
  String get myRatingDisableConfirmTitle;

  /// No description provided for @myRatingDisableConfirmBody.
  ///
  /// In ar, this message translates to:
  /// **'سيتم إخفاء سجل عملياتك وتقييماتك مرة أخرى، وستتوقف رسوم الخدمة عن الانطباق على عملياتك الجديدة.'**
  String get myRatingDisableConfirmBody;

  /// No description provided for @myRatingDisableConfirm.
  ///
  /// In ar, this message translates to:
  /// **'إغلاقه'**
  String get myRatingDisableConfirm;

  /// No description provided for @myRatingDisabledMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم إغلاق تقييمك.'**
  String get myRatingDisabledMessage;

  /// No description provided for @myRatingHiddenHint.
  ///
  /// In ar, this message translates to:
  /// **'مخفي أثناء إغلاق تقييمك.'**
  String get myRatingHiddenHint;

  /// No description provided for @merchantAccountTitle.
  ///
  /// In ar, this message translates to:
  /// **'حساب Merchant'**
  String get merchantAccountTitle;

  /// No description provided for @merchantAccountHint.
  ///
  /// In ar, this message translates to:
  /// **'حساب Fawry فرعي مخصص يحوّل مدفوعاتك إليك مباشرة بدلًا من الحساب المشترك للمنصة.'**
  String get merchantAccountHint;

  /// No description provided for @merchantAccountStatusActive.
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get merchantAccountStatusActive;

  /// No description provided for @merchantAccountStatusPending.
  ///
  /// In ar, this message translates to:
  /// **'الطلب قيد المراجعة'**
  String get merchantAccountStatusPending;

  /// No description provided for @merchantAccountStatusRejected.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض الطلب'**
  String get merchantAccountStatusRejected;

  /// No description provided for @merchantAccountStatusNone.
  ///
  /// In ar, this message translates to:
  /// **'لم يُنشأ بعد'**
  String get merchantAccountStatusNone;

  /// No description provided for @merchantAccountRoutingDisabledNote.
  ///
  /// In ar, this message translates to:
  /// **'التحويل المباشر غير مفعّل على مستوى المنصة بعد — الطلبات تُراجَع وتُدرَج في الانتظار.'**
  String get merchantAccountRoutingDisabledNote;

  /// No description provided for @merchantAccountNoteHint.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة لفريق المراجعة (اختياري)'**
  String get merchantAccountNoteHint;

  /// No description provided for @merchantAccountApplyButton.
  ///
  /// In ar, this message translates to:
  /// **'التقدّم بطلب حساب Merchant'**
  String get merchantAccountApplyButton;

  /// No description provided for @merchantAccountApplied.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال طلبك وسيتم مراجعته.'**
  String get merchantAccountApplied;

  /// No description provided for @menuManagementTitle.
  ///
  /// In ar, this message translates to:
  /// **'قائمتي'**
  String get menuManagementTitle;

  /// No description provided for @menuSectionsTitle.
  ///
  /// In ar, this message translates to:
  /// **'أقسام القائمة'**
  String get menuSectionsTitle;

  /// No description provided for @menuSectionsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أقسام بعد.'**
  String get menuSectionsEmpty;

  /// No description provided for @menuSectionAdd.
  ///
  /// In ar, this message translates to:
  /// **'إضافة قسم'**
  String get menuSectionAdd;

  /// No description provided for @menuSectionEditTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل القسم'**
  String get menuSectionEditTitle;

  /// No description provided for @menuSectionAddTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة قسم'**
  String get menuSectionAddTitle;

  /// No description provided for @menuSectionDeleteConfirm.
  ///
  /// In ar, this message translates to:
  /// **'حذف هذا القسم؟ الأصناف بداخله تحتفظ ببياناتها لكنها تفقد قسمها.'**
  String get menuSectionDeleteConfirm;

  /// No description provided for @menuItemsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الأصناف'**
  String get menuItemsTitle;

  /// No description provided for @menuItemsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أصناف بعد.'**
  String get menuItemsEmpty;

  /// No description provided for @menuItemsSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن صنف...'**
  String get menuItemsSearchHint;

  /// No description provided for @menuItemsAllSections.
  ///
  /// In ar, this message translates to:
  /// **'كل الأقسام'**
  String get menuItemsAllSections;

  /// No description provided for @menuItemAdd.
  ///
  /// In ar, this message translates to:
  /// **'إضافة صنف'**
  String get menuItemAdd;

  /// No description provided for @menuItemEditTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الصنف'**
  String get menuItemEditTitle;

  /// No description provided for @menuItemAddTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة صنف'**
  String get menuItemAddTitle;

  /// No description provided for @menuItemDeleteConfirm.
  ///
  /// In ar, this message translates to:
  /// **'حذف هذا الصنف؟'**
  String get menuItemDeleteConfirm;

  /// No description provided for @menuItemNameArHint.
  ///
  /// In ar, this message translates to:
  /// **'الاسم (عربي)'**
  String get menuItemNameArHint;

  /// No description provided for @menuItemNameEnHint.
  ///
  /// In ar, this message translates to:
  /// **'الاسم (إنجليزي، اختياري)'**
  String get menuItemNameEnHint;

  /// No description provided for @menuItemDescriptionArHint.
  ///
  /// In ar, this message translates to:
  /// **'الوصف (عربي، اختياري)'**
  String get menuItemDescriptionArHint;

  /// No description provided for @menuItemDescriptionEnHint.
  ///
  /// In ar, this message translates to:
  /// **'الوصف (إنجليزي، اختياري)'**
  String get menuItemDescriptionEnHint;

  /// No description provided for @menuItemSectionLabel.
  ///
  /// In ar, this message translates to:
  /// **'القسم'**
  String get menuItemSectionLabel;

  /// No description provided for @menuItemNoSection.
  ///
  /// In ar, this message translates to:
  /// **'بدون قسم'**
  String get menuItemNoSection;

  /// No description provided for @menuItemBasePriceHint.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get menuItemBasePriceHint;

  /// No description provided for @menuItemSupplyPriceHint.
  ///
  /// In ar, this message translates to:
  /// **'سعر التكلفة (اختياري)'**
  String get menuItemSupplyPriceHint;

  /// No description provided for @menuItemBrandNameHint.
  ///
  /// In ar, this message translates to:
  /// **'الماركة (اختياري)'**
  String get menuItemBrandNameHint;

  /// No description provided for @menuItemSortOrderHint.
  ///
  /// In ar, this message translates to:
  /// **'ترتيب العرض'**
  String get menuItemSortOrderHint;

  /// No description provided for @menuItemActiveLabel.
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get menuItemActiveLabel;

  /// No description provided for @menuItemImagesSection.
  ///
  /// In ar, this message translates to:
  /// **'الصور'**
  String get menuItemImagesSection;

  /// No description provided for @menuItemAddImage.
  ///
  /// In ar, this message translates to:
  /// **'إضافة صورة'**
  String get menuItemAddImage;

  /// No description provided for @menuItemVariantsSection.
  ///
  /// In ar, this message translates to:
  /// **'الخيارات'**
  String get menuItemVariantsSection;

  /// No description provided for @menuItemAddVariant.
  ///
  /// In ar, this message translates to:
  /// **'إضافة خيار'**
  String get menuItemAddVariant;

  /// No description provided for @menuItemEditVariant.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الخيار'**
  String get menuItemEditVariant;

  /// No description provided for @menuItemVariantTypeHint.
  ///
  /// In ar, this message translates to:
  /// **'النوع (مثال: الحجم)'**
  String get menuItemVariantTypeHint;

  /// No description provided for @menuItemVariantPriceHint.
  ///
  /// In ar, this message translates to:
  /// **'السعر الكامل (اختياري)'**
  String get menuItemVariantPriceHint;

  /// No description provided for @menuItemVariantPriceDeltaHint.
  ///
  /// In ar, this message translates to:
  /// **'فرق السعر (اختياري)'**
  String get menuItemVariantPriceDeltaHint;

  /// No description provided for @menuItemVariantDefaultLabel.
  ///
  /// In ar, this message translates to:
  /// **'الاختيار الافتراضي'**
  String get menuItemVariantDefaultLabel;

  /// No description provided for @menuItemExtrasSection.
  ///
  /// In ar, this message translates to:
  /// **'الإضافات'**
  String get menuItemExtrasSection;

  /// No description provided for @menuItemAddExtra.
  ///
  /// In ar, this message translates to:
  /// **'إضافة إضافة'**
  String get menuItemAddExtra;

  /// No description provided for @menuItemEditExtra.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الإضافة'**
  String get menuItemEditExtra;

  /// No description provided for @menuItemExtraGroupHint.
  ///
  /// In ar, this message translates to:
  /// **'المجموعة (اختياري)'**
  String get menuItemExtraGroupHint;

  /// No description provided for @menuItemExtraPriceHint.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get menuItemExtraPriceHint;

  /// No description provided for @menuItemExtraMaxQtyHint.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأقصى للكمية'**
  String get menuItemExtraMaxQtyHint;

  /// No description provided for @menuItemDeleteRowConfirm.
  ///
  /// In ar, this message translates to:
  /// **'حذف هذا؟'**
  String get menuItemDeleteRowConfirm;

  /// No description provided for @menuNameRequired.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسمًا.'**
  String get menuNameRequired;

  /// No description provided for @menuPriceRequired.
  ///
  /// In ar, this message translates to:
  /// **'أدخل سعرًا صحيحًا.'**
  String get menuPriceRequired;

  /// No description provided for @retailListingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'منتجاتي'**
  String get retailListingsTitle;

  /// No description provided for @retailListingsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد منتجات مضافة بعد.'**
  String get retailListingsEmpty;

  /// No description provided for @retailListingsSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في منتجاتي...'**
  String get retailListingsSearchHint;

  /// No description provided for @retailListingAdd.
  ///
  /// In ar, this message translates to:
  /// **'إضافة منتج'**
  String get retailListingAdd;

  /// No description provided for @retailListingPickTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر منتجًا'**
  String get retailListingPickTitle;

  /// No description provided for @retailListingLookupHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في الكتالوج...'**
  String get retailListingLookupHint;

  /// No description provided for @retailListingLookupEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد منتجات مطابقة.'**
  String get retailListingLookupEmpty;

  /// No description provided for @retailListingEditTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الإدراج'**
  String get retailListingEditTitle;

  /// No description provided for @retailListingPriceHint.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get retailListingPriceHint;

  /// No description provided for @retailListingStockHint.
  ///
  /// In ar, this message translates to:
  /// **'المخزون (اختياري)'**
  String get retailListingStockHint;

  /// No description provided for @retailListingSkuHint.
  ///
  /// In ar, this message translates to:
  /// **'رمز المنتج SKU (اختياري)'**
  String get retailListingSkuHint;

  /// No description provided for @retailListingActiveLabel.
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get retailListingActiveLabel;

  /// No description provided for @retailListingDeleteConfirm.
  ///
  /// In ar, this message translates to:
  /// **'إزالة هذا المنتج من منتجاتك؟'**
  String get retailListingDeleteConfirm;

  /// No description provided for @retailPriceRequired.
  ///
  /// In ar, this message translates to:
  /// **'أدخل سعرًا صحيحًا.'**
  String get retailPriceRequired;

  /// No description provided for @accountDeletionTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف حسابي'**
  String get accountDeletionTitle;

  /// No description provided for @accountDeletionHint.
  ///
  /// In ar, this message translates to:
  /// **'لديك {days} يومًا لتغيير رأيك — تسجيل الدخول مرة أخرى خلال هذه المدة يستعيد كل شيء كما كان.'**
  String accountDeletionHint(int days);

  /// No description provided for @accountDeletionBlockersTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكنك حذف حسابك الآن'**
  String get accountDeletionBlockersTitle;

  /// No description provided for @accountDeletionPasswordHint.
  ///
  /// In ar, this message translates to:
  /// **'أكّد كلمة المرور'**
  String get accountDeletionPasswordHint;

  /// No description provided for @accountDeletionReasonHint.
  ///
  /// In ar, this message translates to:
  /// **'السبب (اختياري)'**
  String get accountDeletionReasonHint;

  /// No description provided for @accountDeletionRequestButton.
  ///
  /// In ar, this message translates to:
  /// **'حذف حسابي'**
  String get accountDeletionRequestButton;

  /// No description provided for @accountDeletionConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف حسابك؟'**
  String get accountDeletionConfirmTitle;

  /// No description provided for @accountDeletionConfirmBody.
  ///
  /// In ar, this message translates to:
  /// **'سيتم تسجيل خروجك من كل الأجهزة فورًا. يمكنك استعادة حسابك بتسجيل الدخول مرة أخرى خلال مهلة الاسترجاع — بعدها يُحذف نهائيًا.'**
  String get accountDeletionConfirmBody;

  /// No description provided for @accountDeletionConfirmButton.
  ///
  /// In ar, this message translates to:
  /// **'احذفه'**
  String get accountDeletionConfirmButton;

  /// No description provided for @accountDeletionRequested.
  ///
  /// In ar, this message translates to:
  /// **'تم جدولة حذف حسابك. سجّل الدخول مرة أخرى خلال مهلة الاسترجاع لاستعادته.'**
  String get accountDeletionRequested;

  /// No description provided for @restoreAccountTitle.
  ///
  /// In ar, this message translates to:
  /// **'استعادة حسابك'**
  String get restoreAccountTitle;

  /// No description provided for @restoreAccountHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريد وكلمة مرور الحساب الذي حذفته — يعمل هذا فقط خلال مهلة الاسترجاع.'**
  String get restoreAccountHint;

  /// No description provided for @restoreAccountButton.
  ///
  /// In ar, this message translates to:
  /// **'استعادة الحساب'**
  String get restoreAccountButton;

  /// No description provided for @restoreAccountLinkFromLogin.
  ///
  /// In ar, this message translates to:
  /// **'حذفت حسابك بالخطأ؟'**
  String get restoreAccountLinkFromLogin;

  /// No description provided for @clinicManagementTitle.
  ///
  /// In ar, this message translates to:
  /// **'عيادتي'**
  String get clinicManagementTitle;

  /// No description provided for @clinicQueueTab.
  ///
  /// In ar, this message translates to:
  /// **'المواعيد'**
  String get clinicQueueTab;

  /// No description provided for @clinicSlotsTab.
  ///
  /// In ar, this message translates to:
  /// **'الفتحات'**
  String get clinicSlotsTab;

  /// No description provided for @clinicQueueEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مواعيد.'**
  String get clinicQueueEmpty;

  /// No description provided for @clinicQueueAllStatuses.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get clinicQueueAllStatuses;

  /// No description provided for @clinicActionConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get clinicActionConfirm;

  /// No description provided for @clinicActionReject.
  ///
  /// In ar, this message translates to:
  /// **'رفض'**
  String get clinicActionReject;

  /// No description provided for @clinicActionComplete.
  ///
  /// In ar, this message translates to:
  /// **'إكمال'**
  String get clinicActionComplete;

  /// No description provided for @clinicActionNoShow.
  ///
  /// In ar, this message translates to:
  /// **'لم يحضر'**
  String get clinicActionNoShow;

  /// No description provided for @clinicActionReschedule.
  ///
  /// In ar, this message translates to:
  /// **'تغيير الموعد'**
  String get clinicActionReschedule;

  /// No description provided for @clinicRescheduleTitle.
  ///
  /// In ar, this message translates to:
  /// **'تغيير موعد الحجز'**
  String get clinicRescheduleTitle;

  /// No description provided for @clinicRescheduleConfirm.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الموعد الجديد'**
  String get clinicRescheduleConfirm;

  /// No description provided for @clinicSlotsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد فتحات مفتوحة.'**
  String get clinicSlotsEmpty;

  /// No description provided for @clinicAddSlots.
  ///
  /// In ar, this message translates to:
  /// **'إضافة فتحات'**
  String get clinicAddSlots;

  /// No description provided for @clinicSlotsSpecificTab.
  ///
  /// In ar, this message translates to:
  /// **'تواريخ محددة'**
  String get clinicSlotsSpecificTab;

  /// No description provided for @clinicSlotsRecurringTab.
  ///
  /// In ar, this message translates to:
  /// **'أسبوعي متكرر'**
  String get clinicSlotsRecurringTab;

  /// No description provided for @clinicSlotAddDate.
  ///
  /// In ar, this message translates to:
  /// **'إضافة تاريخ ووقت'**
  String get clinicSlotAddDate;

  /// No description provided for @clinicSlotPendingCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} في الانتظار'**
  String clinicSlotPendingCount(int count);

  /// No description provided for @clinicPublishButton.
  ///
  /// In ar, this message translates to:
  /// **'نشر'**
  String get clinicPublishButton;

  /// No description provided for @clinicWeekdaysLabel.
  ///
  /// In ar, this message translates to:
  /// **'أيام الأسبوع'**
  String get clinicWeekdaysLabel;

  /// No description provided for @clinicStartTimeHint.
  ///
  /// In ar, this message translates to:
  /// **'من'**
  String get clinicStartTimeHint;

  /// No description provided for @clinicEndTimeHint.
  ///
  /// In ar, this message translates to:
  /// **'إلى'**
  String get clinicEndTimeHint;

  /// No description provided for @clinicIntervalHint.
  ///
  /// In ar, this message translates to:
  /// **'الفاصل الزمني (دقائق)'**
  String get clinicIntervalHint;

  /// No description provided for @clinicWeeksHint.
  ///
  /// In ar, this message translates to:
  /// **'التكرار لمدة (أسابيع)'**
  String get clinicWeeksHint;

  /// No description provided for @clinicGenerateButton.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء'**
  String get clinicGenerateButton;

  /// No description provided for @clinicSlotsPublished.
  ///
  /// In ar, this message translates to:
  /// **'تم نشر {created} فتحة{skipped, plural, =0{} other{، وتخطي {skipped}}}.'**
  String clinicSlotsPublished(int created, int skipped);

  /// No description provided for @clinicSlotDeleteConfirm.
  ///
  /// In ar, this message translates to:
  /// **'إزالة هذه الفتحة؟'**
  String get clinicSlotDeleteConfirm;

  /// No description provided for @clinicWeekday0.
  ///
  /// In ar, this message translates to:
  /// **'أحد'**
  String get clinicWeekday0;

  /// No description provided for @clinicWeekday1.
  ///
  /// In ar, this message translates to:
  /// **'اثنين'**
  String get clinicWeekday1;

  /// No description provided for @clinicWeekday2.
  ///
  /// In ar, this message translates to:
  /// **'ثلاثاء'**
  String get clinicWeekday2;

  /// No description provided for @clinicWeekday3.
  ///
  /// In ar, this message translates to:
  /// **'أربعاء'**
  String get clinicWeekday3;

  /// No description provided for @clinicWeekday4.
  ///
  /// In ar, this message translates to:
  /// **'خميس'**
  String get clinicWeekday4;

  /// No description provided for @clinicWeekday5.
  ///
  /// In ar, this message translates to:
  /// **'جمعة'**
  String get clinicWeekday5;

  /// No description provided for @clinicWeekday6.
  ///
  /// In ar, this message translates to:
  /// **'سبت'**
  String get clinicWeekday6;

  /// No description provided for @clinicSelectWeekdaysError.
  ///
  /// In ar, this message translates to:
  /// **'اختر يومًا واحدًا على الأقل.'**
  String get clinicSelectWeekdaysError;

  /// No description provided for @trainingTemplatesTitle.
  ///
  /// In ar, this message translates to:
  /// **'قوالبي'**
  String get trainingTemplatesTitle;

  /// No description provided for @trainingTemplatesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد قوالب بعد.'**
  String get trainingTemplatesEmpty;

  /// No description provided for @trainingTemplateAdd.
  ///
  /// In ar, this message translates to:
  /// **'إضافة قالب'**
  String get trainingTemplateAdd;

  /// No description provided for @trainingTemplateAddTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة قالب'**
  String get trainingTemplateAddTitle;

  /// No description provided for @trainingTemplateEditTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل القالب'**
  String get trainingTemplateEditTitle;

  /// No description provided for @trainingTemplateTitleHint.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get trainingTemplateTitleHint;

  /// No description provided for @trainingTemplateGoalHint.
  ///
  /// In ar, this message translates to:
  /// **'الهدف (اختياري)'**
  String get trainingTemplateGoalHint;

  /// No description provided for @trainingTemplateNotesHint.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات (اختياري)'**
  String get trainingTemplateNotesHint;

  /// No description provided for @trainingTemplateDeleteConfirm.
  ///
  /// In ar, this message translates to:
  /// **'حذف هذا القالب؟'**
  String get trainingTemplateDeleteConfirm;

  /// No description provided for @trainingTemplateExercisesSection.
  ///
  /// In ar, this message translates to:
  /// **'التمارين'**
  String get trainingTemplateExercisesSection;

  /// No description provided for @trainingTemplateAddExercise.
  ///
  /// In ar, this message translates to:
  /// **'إضافة تمرين'**
  String get trainingTemplateAddExercise;

  /// No description provided for @trainingTemplateMealsSection.
  ///
  /// In ar, this message translates to:
  /// **'الوجبات'**
  String get trainingTemplateMealsSection;

  /// No description provided for @trainingTemplateAddMeal.
  ///
  /// In ar, this message translates to:
  /// **'إضافة وجبة'**
  String get trainingTemplateAddMeal;

  /// No description provided for @trainingExerciseNameHint.
  ///
  /// In ar, this message translates to:
  /// **'اسم التمرين'**
  String get trainingExerciseNameHint;

  /// No description provided for @trainingExerciseDayHint.
  ///
  /// In ar, this message translates to:
  /// **'اليوم (اختياري)'**
  String get trainingExerciseDayHint;

  /// No description provided for @trainingExerciseDayAny.
  ///
  /// In ar, this message translates to:
  /// **'أي يوم'**
  String get trainingExerciseDayAny;

  /// No description provided for @trainingExerciseSetsHint.
  ///
  /// In ar, this message translates to:
  /// **'المجموعات (اختياري)'**
  String get trainingExerciseSetsHint;

  /// No description provided for @trainingExerciseRepsHint.
  ///
  /// In ar, this message translates to:
  /// **'التكرارات (اختياري)'**
  String get trainingExerciseRepsHint;

  /// No description provided for @trainingExerciseRestHint.
  ///
  /// In ar, this message translates to:
  /// **'الراحة، ثوانٍ (اختياري)'**
  String get trainingExerciseRestHint;

  /// No description provided for @trainingMealTypeLabel.
  ///
  /// In ar, this message translates to:
  /// **'نوع الوجبة'**
  String get trainingMealTypeLabel;

  /// No description provided for @trainingMealNameHint.
  ///
  /// In ar, this message translates to:
  /// **'اسم الوجبة'**
  String get trainingMealNameHint;

  /// No description provided for @trainingMealCaloriesHint.
  ///
  /// In ar, this message translates to:
  /// **'السعرات (اختياري)'**
  String get trainingMealCaloriesHint;

  /// No description provided for @trainingRemoveRowConfirm.
  ///
  /// In ar, this message translates to:
  /// **'حذف هذا؟'**
  String get trainingRemoveRowConfirm;

  /// No description provided for @businessPricesTitle.
  ///
  /// In ar, this message translates to:
  /// **'أسعاري'**
  String get businessPricesTitle;

  /// No description provided for @businessPricesSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'سعر كل نوع تقدّمه — يخصّك أنت فقط.'**
  String get businessPricesSubtitle;

  /// No description provided for @businessPricesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أسعار بعد.'**
  String get businessPricesEmpty;

  /// No description provided for @businessPricesAdd.
  ///
  /// In ar, this message translates to:
  /// **'إضافة سعر'**
  String get businessPricesAdd;

  /// No description provided for @businessPricesFilterAll.
  ///
  /// In ar, this message translates to:
  /// **'كل الخدمات'**
  String get businessPricesFilterAll;

  /// No description provided for @businessPriceDeleteConfirm.
  ///
  /// In ar, this message translates to:
  /// **'حذف هذا السعر؟'**
  String get businessPriceDeleteConfirm;

  /// No description provided for @businessPriceEditTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل السعر'**
  String get businessPriceEditTitle;

  /// No description provided for @businessPriceAddTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة سعر'**
  String get businessPriceAddTitle;

  /// No description provided for @priceFieldService.
  ///
  /// In ar, this message translates to:
  /// **'الخدمة'**
  String get priceFieldService;

  /// No description provided for @priceFieldServiceHint.
  ///
  /// In ar, this message translates to:
  /// **'اختر الخدمة'**
  String get priceFieldServiceHint;

  /// No description provided for @priceFieldItemType.
  ///
  /// In ar, this message translates to:
  /// **'نوع العنصر'**
  String get priceFieldItemType;

  /// No description provided for @priceFieldItemTypePickServiceFirst.
  ///
  /// In ar, this message translates to:
  /// **'اختر الخدمة أولًا'**
  String get priceFieldItemTypePickServiceFirst;

  /// No description provided for @priceFieldItemTypeEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أنواع مسموحة'**
  String get priceFieldItemTypeEmpty;

  /// No description provided for @priceFieldItemTypeHint.
  ///
  /// In ar, this message translates to:
  /// **'اختر النوع'**
  String get priceFieldItemTypeHint;

  /// No description provided for @priceFieldPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get priceFieldPrice;

  /// No description provided for @priceFieldCurrency.
  ///
  /// In ar, this message translates to:
  /// **'العملة'**
  String get priceFieldCurrency;

  /// No description provided for @priceFieldActive.
  ///
  /// In ar, this message translates to:
  /// **'مفعّل'**
  String get priceFieldActive;

  /// No description provided for @priceChargeModeLabel.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الاحتساب'**
  String get priceChargeModeLabel;

  /// No description provided for @priceChargeModeStandard.
  ///
  /// In ar, this message translates to:
  /// **'سعر عادي'**
  String get priceChargeModeStandard;

  /// No description provided for @priceChargeModeFree.
  ///
  /// In ar, this message translates to:
  /// **'مجانية — يُحتسب الأكل فقط'**
  String get priceChargeModeFree;

  /// No description provided for @priceChargeModeReservationFee.
  ///
  /// In ar, this message translates to:
  /// **'رسوم حجز ثابتة'**
  String get priceChargeModeReservationFee;

  /// No description provided for @priceChargeModeMinimum.
  ///
  /// In ar, this message translates to:
  /// **'حد أدنى للطلب'**
  String get priceChargeModeMinimum;

  /// No description provided for @priceFieldChargeAmount.
  ///
  /// In ar, this message translates to:
  /// **'قيمة الرسوم / الحد الأدنى'**
  String get priceFieldChargeAmount;

  /// No description provided for @priceFieldDuration.
  ///
  /// In ar, this message translates to:
  /// **'مدة الموعد (بالدقائق)'**
  String get priceFieldDuration;

  /// No description provided for @priceFieldDurationHint.
  ///
  /// In ar, this message translates to:
  /// **'اتركه فارغًا إن لم يكن للموعد مدة ثابتة'**
  String get priceFieldDurationHint;

  /// No description provided for @priceDiscountEnable.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الخصم'**
  String get priceDiscountEnable;

  /// No description provided for @priceFieldDiscountPercent.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الخصم %'**
  String get priceFieldDiscountPercent;

  /// No description provided for @priceVocabTitle.
  ///
  /// In ar, this message translates to:
  /// **'ما الذي تبيعه هنا؟'**
  String get priceVocabTitle;

  /// No description provided for @priceLineLabel.
  ///
  /// In ar, this message translates to:
  /// **'النوع'**
  String get priceLineLabel;

  /// No description provided for @priceLineNone.
  ///
  /// In ar, this message translates to:
  /// **'— بدون تحديد —'**
  String get priceLineNone;

  /// No description provided for @priceModifiersLabel.
  ///
  /// In ar, this message translates to:
  /// **'ما يميّزه'**
  String get priceModifiersLabel;

  /// No description provided for @priceModifierAdjustHint.
  ///
  /// In ar, this message translates to:
  /// **'يُضاف إلى سعر الوحدة — اتركه فارغًا إن كان لا يغيّر السعر'**
  String get priceModifierAdjustHint;

  /// No description provided for @priceNoServicesWarning.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد خدمات متاحة لنشاطك بعد.'**
  String get priceNoServicesWarning;

  /// No description provided for @offerCompareButton.
  ///
  /// In ar, this message translates to:
  /// **'قارن الأسعار'**
  String get offerCompareButton;

  /// No description provided for @offerCompareTitle.
  ///
  /// In ar, this message translates to:
  /// **'مقارنة الأسعار'**
  String get offerCompareTitle;

  /// No description provided for @offerCompareSortLabel.
  ///
  /// In ar, this message translates to:
  /// **'ترتيب حسب'**
  String get offerCompareSortLabel;

  /// No description provided for @offerCompareSortLowest.
  ///
  /// In ar, this message translates to:
  /// **'الأقل سعرًا'**
  String get offerCompareSortLowest;

  /// No description provided for @offerCompareSortHighest.
  ///
  /// In ar, this message translates to:
  /// **'الأعلى سعرًا'**
  String get offerCompareSortHighest;

  /// No description provided for @offerCompareSortBestValue.
  ///
  /// In ar, this message translates to:
  /// **'الأفضل قيمة'**
  String get offerCompareSortBestValue;

  /// No description provided for @offerCompareSortRanking.
  ///
  /// In ar, this message translates to:
  /// **'الأعلى تقييمًا'**
  String get offerCompareSortRanking;

  /// No description provided for @offerCompareEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عروض لهذا العنصر بعد.'**
  String get offerCompareEmpty;

  /// No description provided for @offerCompareBestPrice.
  ///
  /// In ar, this message translates to:
  /// **'أفضل سعر'**
  String get offerCompareBestPrice;

  /// No description provided for @offerCompareRefundable.
  ///
  /// In ar, this message translates to:
  /// **'قابل للاسترجاع'**
  String get offerCompareRefundable;

  /// No description provided for @shopProductsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسوّق المنتجات'**
  String get shopProductsTitle;

  /// No description provided for @shopProductsSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن منتج...'**
  String get shopProductsSearchHint;

  /// No description provided for @shopProductsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد منتجات.'**
  String get shopProductsEmpty;

  /// No description provided for @shopProductsFilterAllBrands.
  ///
  /// In ar, this message translates to:
  /// **'كل العلامات'**
  String get shopProductsFilterAllBrands;

  /// No description provided for @shopProductsSellersLabel.
  ///
  /// In ar, this message translates to:
  /// **'بائع'**
  String get shopProductsSellersLabel;

  /// No description provided for @productOffersEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد بائعون حاليًا.'**
  String get productOffersEmpty;

  /// No description provided for @productOffersStockLabel.
  ///
  /// In ar, this message translates to:
  /// **'المخزون'**
  String get productOffersStockLabel;

  /// No description provided for @clinicWritePrescription.
  ///
  /// In ar, this message translates to:
  /// **'كتابة روشتة'**
  String get clinicWritePrescription;

  /// No description provided for @clinicViewPrescription.
  ///
  /// In ar, this message translates to:
  /// **'عرض الروشتة'**
  String get clinicViewPrescription;

  /// No description provided for @prescriptionsIssuedTitle.
  ///
  /// In ar, this message translates to:
  /// **'الروشتات الصادرة'**
  String get prescriptionsIssuedTitle;

  /// No description provided for @prescriptionsIssuedEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لم تصدر أي روشتة بعد.'**
  String get prescriptionsIssuedEmpty;

  /// No description provided for @prescriptionIssueTitle.
  ///
  /// In ar, this message translates to:
  /// **'إصدار روشتة'**
  String get prescriptionIssueTitle;

  /// No description provided for @prescriptionReviseTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الروشتة'**
  String get prescriptionReviseTitle;

  /// No description provided for @prescriptionIssueSubmit.
  ///
  /// In ar, this message translates to:
  /// **'إصدار الروشتة'**
  String get prescriptionIssueSubmit;

  /// No description provided for @prescriptionReviseSubmit.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التعديل'**
  String get prescriptionReviseSubmit;

  /// No description provided for @prescriptionReviseAction.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get prescriptionReviseAction;

  /// No description provided for @medicineSearchTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة دواء'**
  String get medicineSearchTitle;

  /// No description provided for @medicineSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث باسم الدواء...'**
  String get medicineSearchHint;

  /// No description provided for @medicineNoResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج. أضفه كدواء جديد بالأسفل.'**
  String get medicineNoResults;

  /// No description provided for @medicineAddNew.
  ///
  /// In ar, this message translates to:
  /// **'إضافة دواء جديد'**
  String get medicineAddNew;

  /// No description provided for @medicineAddTitle.
  ///
  /// In ar, this message translates to:
  /// **'دواء جديد'**
  String get medicineAddTitle;

  /// No description provided for @medicineNameHint.
  ///
  /// In ar, this message translates to:
  /// **'اسم الدواء'**
  String get medicineNameHint;

  /// No description provided for @medicineStrengthHint.
  ///
  /// In ar, this message translates to:
  /// **'التركيز (اختياري)'**
  String get medicineStrengthHint;

  /// No description provided for @medicineInstructionsHint.
  ///
  /// In ar, this message translates to:
  /// **'تعليمات (اختياري)'**
  String get medicineInstructionsHint;

  /// No description provided for @medicineFrequencyLabel.
  ///
  /// In ar, this message translates to:
  /// **'عدد المرات يوميًا'**
  String get medicineFrequencyLabel;

  /// No description provided for @medicineFoodTimingLabel.
  ///
  /// In ar, this message translates to:
  /// **'توقيت الأكل'**
  String get medicineFoodTimingLabel;

  /// No description provided for @medicineTimeSlotsLabel.
  ///
  /// In ar, this message translates to:
  /// **'وقت اليوم'**
  String get medicineTimeSlotsLabel;

  /// No description provided for @medicineDurationLabel.
  ///
  /// In ar, this message translates to:
  /// **'المدة'**
  String get medicineDurationLabel;

  /// No description provided for @medicineAddItem.
  ///
  /// In ar, this message translates to:
  /// **'إضافة دواء'**
  String get medicineAddItem;

  /// No description provided for @medicineAtLeastOneItem.
  ///
  /// In ar, this message translates to:
  /// **'أضف دواءً واحدًا على الأقل.'**
  String get medicineAtLeastOneItem;

  /// No description provided for @pharmacyQueueTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلبات الصيدلية'**
  String get pharmacyQueueTitle;

  /// No description provided for @pharmacyQueueFilterAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get pharmacyQueueFilterAll;

  /// No description provided for @pharmacyQueueEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد وصفات مُرسلة إليك بعد.'**
  String get pharmacyQueueEmpty;

  /// No description provided for @pharmacyPriceAction.
  ///
  /// In ar, this message translates to:
  /// **'تسعير'**
  String get pharmacyPriceAction;

  /// No description provided for @pharmacyPrepareAction.
  ///
  /// In ar, this message translates to:
  /// **'بدء التجهيز'**
  String get pharmacyPrepareAction;

  /// No description provided for @pharmacyMarkReadyAction.
  ///
  /// In ar, this message translates to:
  /// **'جاهزة'**
  String get pharmacyMarkReadyAction;

  /// No description provided for @pharmacyDispenseAction.
  ///
  /// In ar, this message translates to:
  /// **'صرف'**
  String get pharmacyDispenseAction;

  /// No description provided for @pharmacyRejectAction.
  ///
  /// In ar, this message translates to:
  /// **'رفض'**
  String get pharmacyRejectAction;

  /// No description provided for @pharmacyRejectConfirm.
  ///
  /// In ar, this message translates to:
  /// **'رفض هذه الوصفة وإعادتها للمريض؟'**
  String get pharmacyRejectConfirm;

  /// No description provided for @pharmacyPreparingStarted.
  ///
  /// In ar, this message translates to:
  /// **'بدأ التجهيز.'**
  String get pharmacyPreparingStarted;

  /// No description provided for @pharmacyMarkedReady.
  ///
  /// In ar, this message translates to:
  /// **'أصبحت جاهزة للمريض.'**
  String get pharmacyMarkedReady;

  /// No description provided for @pharmacyDispensed.
  ///
  /// In ar, this message translates to:
  /// **'تم الصرف.'**
  String get pharmacyDispensed;

  /// No description provided for @pharmacyRejected.
  ///
  /// In ar, this message translates to:
  /// **'تم الرفض وإعادتها للمريض.'**
  String get pharmacyRejected;

  /// No description provided for @pharmacyPriceTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسعير الوصفة'**
  String get pharmacyPriceTitle;

  /// No description provided for @pharmacyUnitPriceLabel.
  ///
  /// In ar, this message translates to:
  /// **'سعر الوحدة'**
  String get pharmacyUnitPriceLabel;

  /// No description provided for @pharmacyBilledQuantityLabel.
  ///
  /// In ar, this message translates to:
  /// **'الكمية'**
  String get pharmacyBilledQuantityLabel;

  /// No description provided for @pharmacyPriced.
  ///
  /// In ar, this message translates to:
  /// **'تم تسعير الوصفة.'**
  String get pharmacyPriced;

  /// No description provided for @pharmacyCurrencyLabel.
  ///
  /// In ar, this message translates to:
  /// **'جنيه'**
  String get pharmacyCurrencyLabel;

  /// No description provided for @businessOffersTitle.
  ///
  /// In ar, this message translates to:
  /// **'عروضي'**
  String get businessOffersTitle;

  /// No description provided for @businessOfferAdd.
  ///
  /// In ar, this message translates to:
  /// **'أضف عرضًا'**
  String get businessOfferAdd;

  /// No description provided for @businessOffersEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عروض بعد.'**
  String get businessOffersEmpty;

  /// No description provided for @businessOffersFilterAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get businessOffersFilterAll;

  /// No description provided for @businessOfferStatusActive.
  ///
  /// In ar, this message translates to:
  /// **'فعّال'**
  String get businessOfferStatusActive;

  /// No description provided for @businessOfferStatusPaused.
  ///
  /// In ar, this message translates to:
  /// **'متوقف'**
  String get businessOfferStatusPaused;

  /// No description provided for @businessOfferStatusExpired.
  ///
  /// In ar, this message translates to:
  /// **'منتهي'**
  String get businessOfferStatusExpired;

  /// No description provided for @businessOfferStatusCancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغى'**
  String get businessOfferStatusCancelled;

  /// No description provided for @businessOffersUsage.
  ///
  /// In ar, this message translates to:
  /// **'{active} من {max} عروض فعّالة مستخدمة'**
  String businessOffersUsage(int active, int max);

  /// No description provided for @businessOfferPause.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف'**
  String get businessOfferPause;

  /// No description provided for @businessOfferActivate.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل'**
  String get businessOfferActivate;

  /// No description provided for @businessOfferDeleteConfirm.
  ///
  /// In ar, this message translates to:
  /// **'حذف هذا العرض؟'**
  String get businessOfferDeleteConfirm;

  /// No description provided for @businessOfferBoostAction.
  ///
  /// In ar, this message translates to:
  /// **'تعزيز'**
  String get businessOfferBoostAction;

  /// No description provided for @businessOfferBoostTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعزيز هذا العرض'**
  String get businessOfferBoostTitle;

  /// No description provided for @businessOfferBoostDuration.
  ///
  /// In ar, this message translates to:
  /// **'{days} يوم'**
  String businessOfferBoostDuration(int days);

  /// No description provided for @businessOfferBoosted.
  ///
  /// In ar, this message translates to:
  /// **'تم تعزيز العرض.'**
  String get businessOfferBoosted;

  /// No description provided for @businessOfferBoostPurchasesTitle.
  ///
  /// In ar, this message translates to:
  /// **'عمليات التعزيز'**
  String get businessOfferBoostPurchasesTitle;

  /// No description provided for @businessOfferBoostPurchasesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عمليات تعزيز بعد.'**
  String get businessOfferBoostPurchasesEmpty;

  /// No description provided for @businessOfferAddTitle.
  ///
  /// In ar, this message translates to:
  /// **'عرض جديد'**
  String get businessOfferAddTitle;

  /// No description provided for @businessOfferEditTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل العرض'**
  String get businessOfferEditTitle;

  /// No description provided for @businessOfferTypeLabel.
  ///
  /// In ar, this message translates to:
  /// **'على ماذا هذا العرض؟'**
  String get businessOfferTypeLabel;

  /// No description provided for @businessOfferTypeMenuItem.
  ///
  /// In ar, this message translates to:
  /// **'صنف من المنيو'**
  String get businessOfferTypeMenuItem;

  /// No description provided for @businessOfferTypeProduct.
  ///
  /// In ar, this message translates to:
  /// **'منتج'**
  String get businessOfferTypeProduct;

  /// No description provided for @businessOfferTypeService.
  ///
  /// In ar, this message translates to:
  /// **'خدمة'**
  String get businessOfferTypeService;

  /// No description provided for @businessOfferPickItem.
  ///
  /// In ar, this message translates to:
  /// **'اختر الصنف'**
  String get businessOfferPickItem;

  /// No description provided for @businessOfferPickItemFirst.
  ///
  /// In ar, this message translates to:
  /// **'اختر الصنف الذي سيكون عليه العرض أولًا.'**
  String get businessOfferPickItemFirst;

  /// No description provided for @businessOfferNoItemsFound.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أصناف.'**
  String get businessOfferNoItemsFound;

  /// No description provided for @businessOfferCurrentPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر الحالي: {price} {currency}'**
  String businessOfferCurrentPrice(String price, String currency);

  /// No description provided for @businessOfferTitleLabel.
  ///
  /// In ar, this message translates to:
  /// **'عنوان العرض (اختياري)'**
  String get businessOfferTitleLabel;

  /// No description provided for @businessOfferFinalPriceLabel.
  ///
  /// In ar, this message translates to:
  /// **'سعر العرض'**
  String get businessOfferFinalPriceLabel;

  /// No description provided for @businessOfferPriceTooHigh.
  ///
  /// In ar, this message translates to:
  /// **'سعر العرض لا بد أن يقل عن السعر الحالي ({price} {currency}).'**
  String businessOfferPriceTooHigh(String price, String currency);

  /// No description provided for @businessOfferEndConditionLabel.
  ///
  /// In ar, this message translates to:
  /// **'ينتهي هذا العرض...'**
  String get businessOfferEndConditionLabel;

  /// No description provided for @businessOfferEndsAtLabel.
  ///
  /// In ar, this message translates to:
  /// **'في تاريخ محدد'**
  String get businessOfferEndsAtLabel;

  /// No description provided for @businessOfferPickEndDate.
  ///
  /// In ar, this message translates to:
  /// **'اختر تاريخ الانتهاء.'**
  String get businessOfferPickEndDate;

  /// No description provided for @businessOfferWhileStockLasts.
  ///
  /// In ar, this message translates to:
  /// **'حتى نفاد الكمية'**
  String get businessOfferWhileStockLasts;

  /// No description provided for @businessOfferLimitedQuantity.
  ///
  /// In ar, this message translates to:
  /// **'بعد كمية محدودة'**
  String get businessOfferLimitedQuantity;

  /// No description provided for @businessOfferQuantityLabel.
  ///
  /// In ar, this message translates to:
  /// **'الكمية'**
  String get businessOfferQuantityLabel;

  /// No description provided for @businessOfferRefundableLabel.
  ///
  /// In ar, this message translates to:
  /// **'قابل للاسترجاع'**
  String get businessOfferRefundableLabel;

  /// No description provided for @drawerSectionProfile.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات البروفايل'**
  String get drawerSectionProfile;

  /// No description provided for @drawerSectionJobsPosts.
  ///
  /// In ar, this message translates to:
  /// **'الوظائف والمنشورات'**
  String get drawerSectionJobsPosts;

  /// No description provided for @drawerSectionMyServices.
  ///
  /// In ar, this message translates to:
  /// **'خدماتي'**
  String get drawerSectionMyServices;

  /// No description provided for @chatsListTitle.
  ///
  /// In ar, this message translates to:
  /// **'المحادثات'**
  String get chatsListTitle;

  /// No description provided for @chatsListEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد محادثات بعد.'**
  String get chatsListEmpty;

  /// No description provided for @chatRenameGroup.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تسمية المجموعة'**
  String get chatRenameGroup;

  /// No description provided for @chatDeleteGroupConfirm.
  ///
  /// In ar, this message translates to:
  /// **'حذف هذه المجموعة للجميع؟'**
  String get chatDeleteGroupConfirm;

  /// No description provided for @chatLeaveGroupConfirm.
  ///
  /// In ar, this message translates to:
  /// **'مغادرة هذه المجموعة؟'**
  String get chatLeaveGroupConfirm;

  /// No description provided for @chatLeaveAction.
  ///
  /// In ar, this message translates to:
  /// **'مغادرة'**
  String get chatLeaveAction;

  /// No description provided for @chatDeleteConfirm.
  ///
  /// In ar, this message translates to:
  /// **'حذف هذه المحادثة؟ لا يمكن التراجع عن هذا.'**
  String get chatDeleteConfirm;

  /// No description provided for @offerPerformanceTitle.
  ///
  /// In ar, this message translates to:
  /// **'أداء العروض'**
  String get offerPerformanceTitle;

  /// No description provided for @offerPerformanceEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد نشاط على عروضك بعد.'**
  String get offerPerformanceEmpty;

  /// No description provided for @offerPerformanceByOffer.
  ///
  /// In ar, this message translates to:
  /// **'حسب العرض'**
  String get offerPerformanceByOffer;

  /// No description provided for @offerEventView.
  ///
  /// In ar, this message translates to:
  /// **'مشاهدات'**
  String get offerEventView;

  /// No description provided for @offerEventClick.
  ///
  /// In ar, this message translates to:
  /// **'نقرات'**
  String get offerEventClick;

  /// No description provided for @offerEventLead.
  ///
  /// In ar, this message translates to:
  /// **'استفسارات'**
  String get offerEventLead;

  /// No description provided for @offerEventConversion.
  ///
  /// In ar, this message translates to:
  /// **'تحويلات'**
  String get offerEventConversion;

  /// No description provided for @offerEventShare.
  ///
  /// In ar, this message translates to:
  /// **'مشاركات'**
  String get offerEventShare;

  /// No description provided for @offerEventSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get offerEventSave;

  /// No description provided for @tableScanTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلب طاولة'**
  String get tableScanTitle;

  /// No description provided for @tableScanHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الكود المطبوع على طاولتك للانضمام إلى طلبها.'**
  String get tableScanHint;

  /// No description provided for @tableScanCodeLabel.
  ///
  /// In ar, this message translates to:
  /// **'كود الطاولة'**
  String get tableScanCodeLabel;

  /// No description provided for @tableScanJoin.
  ///
  /// In ar, this message translates to:
  /// **'انضمام للطاولة'**
  String get tableScanJoin;

  /// No description provided for @tableCallStaff.
  ///
  /// In ar, this message translates to:
  /// **'نداء الطاقم'**
  String get tableCallStaff;

  /// No description provided for @tableCallWaiter.
  ///
  /// In ar, this message translates to:
  /// **'نداء النادل'**
  String get tableCallWaiter;

  /// No description provided for @tableCallBill.
  ///
  /// In ar, this message translates to:
  /// **'طلب الحساب'**
  String get tableCallBill;

  /// No description provided for @tableCallAssistance.
  ///
  /// In ar, this message translates to:
  /// **'طلب مساعدة'**
  String get tableCallAssistance;

  /// No description provided for @tableCallSent.
  ///
  /// In ar, this message translates to:
  /// **'تم الإرسال إلى الطاقم.'**
  String get tableCallSent;

  /// No description provided for @myTripSchedulesTitle.
  ///
  /// In ar, this message translates to:
  /// **'خطوط سيري'**
  String get myTripSchedulesTitle;

  /// No description provided for @incomingReservationsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الحجوزات الواردة'**
  String get incomingReservationsTitle;

  /// No description provided for @tripScheduleAdd.
  ///
  /// In ar, this message translates to:
  /// **'نشر خط سير'**
  String get tripScheduleAdd;

  /// No description provided for @tripScheduleAddTitle.
  ///
  /// In ar, this message translates to:
  /// **'خط سير جديد'**
  String get tripScheduleAddTitle;

  /// No description provided for @tripSchedulesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد خطوط سير منشورة بعد.'**
  String get tripSchedulesEmpty;

  /// No description provided for @tripScheduleDeleteConfirm.
  ///
  /// In ar, this message translates to:
  /// **'حذف خط السير هذا؟'**
  String get tripScheduleDeleteConfirm;

  /// No description provided for @tripScheduleModeLabel.
  ///
  /// In ar, this message translates to:
  /// **'نوع الرحلة'**
  String get tripScheduleModeLabel;

  /// No description provided for @tripSchedulePatternLabel.
  ///
  /// In ar, this message translates to:
  /// **'تعمل هذه الرحلة...'**
  String get tripSchedulePatternLabel;

  /// No description provided for @tripSchedulePatternWeekly.
  ///
  /// In ar, this message translates to:
  /// **'أسبوعيًا في يوم ثابت'**
  String get tripSchedulePatternWeekly;

  /// No description provided for @tripSchedulePatternOneOff.
  ///
  /// In ar, this message translates to:
  /// **'في تاريخ محدد'**
  String get tripSchedulePatternOneOff;

  /// No description provided for @tripSchedulePatternOnDemand.
  ///
  /// In ar, this message translates to:
  /// **'عند الطلب'**
  String get tripSchedulePatternOnDemand;

  /// No description provided for @tripScheduleDayLabel.
  ///
  /// In ar, this message translates to:
  /// **'يوم الأسبوع'**
  String get tripScheduleDayLabel;

  /// No description provided for @tripScheduleDateLabel.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get tripScheduleDateLabel;

  /// No description provided for @tripScheduleDatePickRequired.
  ///
  /// In ar, this message translates to:
  /// **'اختر تاريخًا لهذه الرحلة.'**
  String get tripScheduleDatePickRequired;

  /// No description provided for @tripScheduleDepartureTimeLabel.
  ///
  /// In ar, this message translates to:
  /// **'وقت الانطلاق'**
  String get tripScheduleDepartureTimeLabel;

  /// No description provided for @tripScheduleCapacityLabel.
  ///
  /// In ar, this message translates to:
  /// **'السعة'**
  String get tripScheduleCapacityLabel;

  /// No description provided for @tripSchedulePriceLabel.
  ///
  /// In ar, this message translates to:
  /// **'السعر لكل وحدة'**
  String get tripSchedulePriceLabel;

  /// No description provided for @tripScheduleDepositLabel.
  ///
  /// In ar, this message translates to:
  /// **'العربون لكل وحدة (اختياري)'**
  String get tripScheduleDepositLabel;

  /// No description provided for @incomingReservationsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد حجوزات بعد.'**
  String get incomingReservationsEmpty;

  /// No description provided for @tripReservationStatusAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get tripReservationStatusAll;

  /// No description provided for @tripReservationStatusPending.
  ///
  /// In ar, this message translates to:
  /// **'قيد الانتظار'**
  String get tripReservationStatusPending;

  /// No description provided for @tripReservationStatusConfirmed.
  ///
  /// In ar, this message translates to:
  /// **'مؤكد'**
  String get tripReservationStatusConfirmed;

  /// No description provided for @tripReservationStatusCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get tripReservationStatusCompleted;

  /// No description provided for @tripReservationStatusCancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغى'**
  String get tripReservationStatusCancelled;

  /// No description provided for @tripReservationClient.
  ///
  /// In ar, this message translates to:
  /// **'عميل #{id}'**
  String tripReservationClient(int id);

  /// No description provided for @tripReservationUnitsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} وحدة'**
  String tripReservationUnitsCount(int count);

  /// No description provided for @tripReservationConfirmAction.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get tripReservationConfirmAction;

  /// No description provided for @tripReservationCompleteAction.
  ///
  /// In ar, this message translates to:
  /// **'إكمال'**
  String get tripReservationCompleteAction;

  /// No description provided for @tripReservationRejectAction.
  ///
  /// In ar, this message translates to:
  /// **'رفض'**
  String get tripReservationRejectAction;

  /// No description provided for @myTrainingClientsTitle.
  ///
  /// In ar, this message translates to:
  /// **'عملاء تدريبي'**
  String get myTrainingClientsTitle;

  /// No description provided for @trainingClientsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد خطط عملاء بعد.'**
  String get trainingClientsEmpty;

  /// No description provided for @trainingPlanStatusActive.
  ///
  /// In ar, this message translates to:
  /// **'نشطة'**
  String get trainingPlanStatusActive;

  /// No description provided for @trainingPlanStatusPaused.
  ///
  /// In ar, this message translates to:
  /// **'متوقفة'**
  String get trainingPlanStatusPaused;

  /// No description provided for @trainingPlanStatusCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتملة'**
  String get trainingPlanStatusCompleted;

  /// No description provided for @trainingPlanStatusCancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغاة'**
  String get trainingPlanStatusCancelled;

  /// No description provided for @mealTypeBreakfast.
  ///
  /// In ar, this message translates to:
  /// **'فطار'**
  String get mealTypeBreakfast;

  /// No description provided for @mealTypeLunch.
  ///
  /// In ar, this message translates to:
  /// **'غداء'**
  String get mealTypeLunch;

  /// No description provided for @mealTypeDinner.
  ///
  /// In ar, this message translates to:
  /// **'عشاء'**
  String get mealTypeDinner;

  /// No description provided for @mealTypeSnack.
  ///
  /// In ar, this message translates to:
  /// **'وجبة خفيفة'**
  String get mealTypeSnack;

  /// No description provided for @trainingAddExercise.
  ///
  /// In ar, this message translates to:
  /// **'إضافة تمرين'**
  String get trainingAddExercise;

  /// No description provided for @trainingExerciseName.
  ///
  /// In ar, this message translates to:
  /// **'اسم التمرين'**
  String get trainingExerciseName;

  /// No description provided for @trainingAnyDay.
  ///
  /// In ar, this message translates to:
  /// **'أي يوم'**
  String get trainingAnyDay;

  /// No description provided for @trainingSets.
  ///
  /// In ar, this message translates to:
  /// **'المجموعات'**
  String get trainingSets;

  /// No description provided for @trainingReps.
  ///
  /// In ar, this message translates to:
  /// **'التكرارات'**
  String get trainingReps;

  /// No description provided for @trainingAddMeal.
  ///
  /// In ar, this message translates to:
  /// **'إضافة وجبة'**
  String get trainingAddMeal;

  /// No description provided for @trainingMealName.
  ///
  /// In ar, this message translates to:
  /// **'اسم الوجبة'**
  String get trainingMealName;

  /// No description provided for @trainingCalories.
  ///
  /// In ar, this message translates to:
  /// **'السعرات الحرارية'**
  String get trainingCalories;

  /// No description provided for @trainingAddBodyReport.
  ///
  /// In ar, this message translates to:
  /// **'إضافة قراءة شهرية'**
  String get trainingAddBodyReport;

  /// No description provided for @trainingBodyReportHint.
  ///
  /// In ar, this message translates to:
  /// **'قراءة واحدة لكل شهر — إرسال نفس الشهر مرة أخرى يحدّثها.'**
  String get trainingBodyReportHint;

  /// No description provided for @trainingWeightKg.
  ///
  /// In ar, this message translates to:
  /// **'الوزن (كجم)'**
  String get trainingWeightKg;

  /// No description provided for @trainingMuscleKg.
  ///
  /// In ar, this message translates to:
  /// **'الكتلة العضلية (كجم)'**
  String get trainingMuscleKg;

  /// No description provided for @trainingFatPercent.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الدهون %'**
  String get trainingFatPercent;

  /// No description provided for @trainingWaterPercent.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الماء %'**
  String get trainingWaterPercent;

  /// No description provided for @trainingExercisesSection.
  ///
  /// In ar, this message translates to:
  /// **'التمارين'**
  String get trainingExercisesSection;

  /// No description provided for @trainingMealsSection.
  ///
  /// In ar, this message translates to:
  /// **'الوجبات'**
  String get trainingMealsSection;

  /// No description provided for @trainingBodyReportsSection.
  ///
  /// In ar, this message translates to:
  /// **'تركيب الجسم'**
  String get trainingBodyReportsSection;
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
