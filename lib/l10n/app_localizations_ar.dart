// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'BIM';

  @override
  String get appTagline => 'كل الأعمال في مكان واحد';

  @override
  String get commonLoading => 'جاري التحميل...';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonSubmit => 'إرسال';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonNext => 'التالي';

  @override
  String get commonBack => 'رجوع';

  @override
  String get commonSomethingWentWrong => 'حدث خطأ ما، حاول مرة أخرى.';

  @override
  String get commonNoInternet => 'لا يوجد اتصال بالإنترنت.';

  @override
  String get authChooseAccountType => 'اختر نوع الحساب';

  @override
  String get authAccountTypeCustomer => 'عميل';

  @override
  String get authAccountTypeBusiness => 'صاحب نشاط تجاري';

  @override
  String get authLogin => 'تسجيل الدخول';

  @override
  String get authRegister => 'إنشاء حساب';

  @override
  String get authWelcomeBack => 'أهلاً بعودتك';

  @override
  String get authEmailOrPhone => 'البريد الإلكتروني أو رقم الهاتف';

  @override
  String get authPassword => 'كلمة المرور';

  @override
  String get authConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get authForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get authDontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get authAlreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get authLogout => 'تسجيل الخروج';

  @override
  String get authName => 'الاسم';

  @override
  String get authInvalidCredentials => 'بيانات الدخول غير صحيحة.';

  @override
  String get validationRequired => 'هذا الحقل مطلوب.';

  @override
  String get validationInvalidEmail => 'البريد الإلكتروني غير صحيح.';

  @override
  String get validationPasswordPolicy =>
      'من 8 إلى 20 حرفًا، بحرف كبير وحرف صغير ورقم على الأقل.';

  @override
  String get validationPasswordMismatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get homeCustomerTitle => 'الرئيسية';

  @override
  String get homeBusinessTitle => 'لوحة النشاط';

  @override
  String get categoriesEmpty => 'لا توجد تصنيفات متاحة حاليًا.';

  @override
  String get specialtiesEmpty => 'لا توجد تخصصات متاحة في هذا التصنيف.';

  @override
  String get businessSearchHint => 'ابحث باسم النشاط...';

  @override
  String get businessListEmpty => 'لا توجد أنشطة مطابقة.';

  @override
  String get businessOpenNow => 'مفتوح الآن';

  @override
  String get businessClosedNow => 'مغلق الآن';

  @override
  String get businessCallForPrice => 'اتصل للسعر';

  @override
  String businessCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نشاط',
      many: '$count نشاطًا',
      few: '$count أنشطة',
      two: 'نشاطان',
      one: 'نشاط واحد',
      zero: 'لا يوجد نشاط',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsLanguageArabic => 'العربية';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsAppearance => 'المظهر';

  @override
  String get settingsAppearanceLight => 'فاتح';

  @override
  String get settingsAppearanceDark => 'داكن';

  @override
  String get settingsAppearanceSystem => 'حسب النظام';

  @override
  String get settingsAccountSection => 'إعدادات الحساب';

  @override
  String get settingsServicesSection => 'إعدادات الخدمات';

  @override
  String get settingsComingSoon => 'قريبًا';

  @override
  String get categoryPickerFieldLabel => 'التصنيف';

  @override
  String get categoryPickerChooseHint => 'اختر التصنيف';

  @override
  String get categoryPickerChooseRoot => 'اختر القسم الرئيسي';

  @override
  String get mediaCapturedByCamera => 'تم التقاط هذه الصورة بالكاميرا';

  @override
  String get mediaFromGallery => 'تم رفع هذه الصورة من المعرض';

  @override
  String get mediaAddFromCamera => 'التقاط بالكاميرا';

  @override
  String get mediaAddFromGallery => 'اختيار من المعرض';

  @override
  String get mediaRemove => 'إزالة';

  @override
  String get mediaCrop => 'قص الصورة';

  @override
  String get mediaWatermarkTitle => 'العلامة المائية';

  @override
  String get mediaWatermarkUseMobile => 'رقم الموبايل';

  @override
  String get mediaWatermarkUseBusinessName => 'اسم النشاط';

  @override
  String get mediaWatermarkSettingsHint =>
      'اختر مصدر نص العلامة المائية من ملفك الشخصي — سيُضاف تلقائيًا لكل صورة تضيفها، دون كتابته في كل مرة.';

  @override
  String get mediaWatermarkDisabledHint => 'العلامة المائية غير مفعّلة حاليًا.';

  @override
  String get mediaWatermarkOpenSettings => 'تفعيلها من الإعدادات';

  @override
  String get mediaWatermarkRepeatCount => 'عدد التكرار';

  @override
  String get mediaComposerTitle => 'عرض الصور والعلامة المائية';

  @override
  String get mediaEmpty => 'لا توجد صور بعد — أضف صورة بالكاميرا أو من المعرض.';

  @override
  String get cropTitle => 'قص الصورة';

  @override
  String get cropAspectOriginal => 'الأصلي';

  @override
  String get cropAspectSquare => 'مربع';

  @override
  String get cropAspectPortrait => 'عمودي';

  @override
  String get cropAspectLandscape => 'أفقي';

  @override
  String get cropConfirm => 'تم';

  @override
  String get businessRatingNoReviews => 'لا توجد تقييمات بعد';

  @override
  String get businessTabPosts => 'المنشورات';

  @override
  String get businessTabMenu => 'القائمة';

  @override
  String get businessTabServices => 'الخدمات';

  @override
  String get businessPostsEmpty => 'لا توجد منشورات بعد';

  @override
  String get businessMenuEmpty => 'لا توجد أصناف بعد';

  @override
  String get businessServicesEmpty => 'لا توجد خدمات بعد';

  @override
  String get businessActionBook => 'احجز';

  @override
  String get businessActionOrder => 'اطلب';

  @override
  String get businessOutOfStock => 'غير متوفر حاليًا';

  @override
  String get businessNoContentYet => 'لا يوجد محتوى لعرضه بعد';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get profileName => 'الاسم';

  @override
  String get profilePhone => 'رقم الموبايل';

  @override
  String get profileLocation => 'الموقع';

  @override
  String get profileLocationNotSet => 'لم يتم تحديد الموقع بعد';

  @override
  String get profileLocationSet => 'تم تحديد الموقع';

  @override
  String get profileUseCurrentLocation => 'تحديد موقعي الحالي';

  @override
  String get profileLocationPermissionDenied =>
      'تحتاج للسماح بالوصول للموقع من إعدادات الجهاز.';

  @override
  String get profilePhotoCamera => 'التقاط بالكاميرا';

  @override
  String get profilePhotoGallery => 'اختيار من المعرض';

  @override
  String get profilePhotoRemove => 'إزالة الصورة';

  @override
  String get profileSaved => 'تم حفظ التغييرات.';

  @override
  String get profilePrivacyNote =>
      'بياناتك دي (رقمك وموقعك) متتشافش لحد — بتظهر بس للنشاط التجاري وقت ما تستخدم خدمة فعلية معاه، زي الحجز أو الطلب.';

  @override
  String get profileSave => 'حفظ';

  @override
  String get navCategories => 'التصنيفات';

  @override
  String get navSearch => 'البحث';

  @override
  String get navProfile => 'حسابي';

  @override
  String get searchEmptyHint => 'اكتب اسم النشاط اللي بتدور عليه';

  @override
  String get profileEmail => 'البريد الإلكتروني';

  @override
  String get profileNameEnglish => 'الاسم بالإنجليزية';

  @override
  String get profileAbout => 'نبذة عن النشاط';

  @override
  String get profileAccountType => 'نوع الحساب';

  @override
  String get profileAccountTypeClient => 'عميل';

  @override
  String get profileAccountTypeBusiness => 'نشاط تجاري';

  @override
  String get profileSpecialty => 'التخصص';

  @override
  String get profileSpecialtyNotSet => 'لم يتم اختيار تخصص';

  @override
  String get profileCategory => 'التصنيف الرئيسي';

  @override
  String get profileCategoryNotSet => 'لم يتم تحديد تصنيف رئيسي';

  @override
  String get profileConvertToBusiness => 'تحويل الحساب إلى نشاط تجاري';

  @override
  String get profileConvertToBusinessHint =>
      'اختر تخصص نشاطك التجاري لإتمام التحويل — لا يمكن التراجع عن هذا التحويل من هنا.';

  @override
  String get profileConvertConfirm => 'تأكيد التحويل';

  @override
  String get profileConvertSuccess => 'تم تحويل حسابك إلى نشاط تجاري بنجاح.';

  @override
  String get profileOptionsTitle => 'خصائص النشاط';

  @override
  String get profileOptionsEmpty => 'لا توجد خصائص متاحة لتخصصك الحالي.';

  @override
  String get profileOptionsSave => 'حفظ الخصائص';

  @override
  String get profileAdministrativeLocation => 'المنطقة الإدارية';

  @override
  String get locationFieldLabel => 'الدولة / المحافظة / المدينة';

  @override
  String get locationChooseHint => 'اختر الدولة والمحافظة والمدينة';

  @override
  String get locationChooseCountry => 'اختر الدولة';

  @override
  String get locationEmpty => 'لا توجد نتائج';

  @override
  String get locationSearchCity => 'ابحث عن مدينة';

  @override
  String get profileAlbumsTitle => 'ألبومات الصور';

  @override
  String get profileAlbumsEmpty => 'لا توجد ألبومات بعد.';

  @override
  String get profileAlbumsAdd => 'ألبوم جديد';

  @override
  String get profileAlbumsNewTitle => 'اسم الألبوم';

  @override
  String get profileAlbumsCreate => 'إنشاء';

  @override
  String get profileAlbumsAddPhoto => 'إضافة صورة';

  @override
  String get profileAlbumsDelete => 'حذف الألبوم';

  @override
  String get profileAlbumsDeleteConfirm => 'هل تريد حذف هذا الألبوم وكل صوره؟';
}
