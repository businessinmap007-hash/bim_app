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
}
