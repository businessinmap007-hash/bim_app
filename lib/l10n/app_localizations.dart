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

  /// No description provided for @postsCreateChoicePost.
  ///
  /// In ar, this message translates to:
  /// **'منشور جديد'**
  String get postsCreateChoicePost;

  /// No description provided for @postsCreateChoiceJob.
  ///
  /// In ar, this message translates to:
  /// **'وظيفة جديدة'**
  String get postsCreateChoiceJob;

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
  /// **'العنوان (اختياري)'**
  String get postsTitleLabel;

  /// No description provided for @postsBodyLabel.
  ///
  /// In ar, this message translates to:
  /// **'النص'**
  String get postsBodyLabel;

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
