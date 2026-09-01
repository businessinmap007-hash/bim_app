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
  String get businessFollow => 'متابعة';

  @override
  String get businessUnfollow => 'إلغاء المتابعة';

  @override
  String businessFollowersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count متابع',
      many: '$count متابعًا',
      few: '$count متابعين',
      two: 'متابعان',
      one: 'متابع واحد',
      zero: 'لا يوجد متابعون',
    );
    return '$_temp0';
  }

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

  @override
  String get bookingSettingsTitle => 'إدارة الحجز';

  @override
  String get bookingSettingsPricesTab => 'الأسعار';

  @override
  String get bookingSettingsUnitsTab => 'الوحدات';

  @override
  String get bookingSettingsHoursTab => 'ساعات العمل';

  @override
  String get bookingSettingsAddPrice => 'إضافة سعر';

  @override
  String get bookingSettingsAddUnit => 'إضافة وحدة';

  @override
  String get bookingSettingsService => 'الخدمة';

  @override
  String get bookingSettingsItemType => 'نوع الخدمة';

  @override
  String get bookingSettingsLineOption => 'النوع';

  @override
  String get bookingSettingsLineOptionHint => 'مثال: غرفة مزدوجة';

  @override
  String get bookingSettingsPrice => 'السعر';

  @override
  String get bookingSettingsCode => 'الرقم / الكود';

  @override
  String get bookingSettingsCapacity => 'السعة';

  @override
  String get bookingSettingsPricesEmpty =>
      'لا توجد أسعار بعد — أضف سعرًا لكل نوع تقدّمه.';

  @override
  String get bookingSettingsUnitsEmpty => 'لا توجد وحدات بعد.';

  @override
  String get bookingSettingsDelete => 'حذف';

  @override
  String get bookingSettingsDeleteConfirm => 'هل تريد الحذف؟';

  @override
  String get bookingSettingsClosed => 'مغلق';

  @override
  String get bookingSettingsOpenTime => 'وقت الفتح';

  @override
  String get bookingSettingsCloseTime => 'وقت الإغلاق';

  @override
  String get bookingSettingsSaveHours => 'حفظ المواعيد';

  @override
  String get bookingSettingsHoursSaved => 'تم حفظ المواعيد.';

  @override
  String get bookingSettingsOpenNow => 'مفتوح الآن';

  @override
  String get bookingSettingsClosedNow => 'مغلق الآن';

  @override
  String get weekdaySunday => 'الأحد';

  @override
  String get weekdayMonday => 'الإثنين';

  @override
  String get weekdayTuesday => 'الثلاثاء';

  @override
  String get weekdayWednesday => 'الأربعاء';

  @override
  String get weekdayThursday => 'الخميس';

  @override
  String get weekdayFriday => 'الجمعة';

  @override
  String get weekdaySaturday => 'السبت';

  @override
  String get postsMyPostsTitle => 'منشوراتي';

  @override
  String get postsTabFollowing => 'المتابَعون';

  @override
  String get postsTabMine => 'منشوراتي';

  @override
  String get postsTabJobs => 'وظائفي';

  @override
  String get postsFeedEmpty =>
      'لا توجد منشورات بعد — تابع نشاطًا تجاريًا لترى منشوراته هنا.';

  @override
  String get postsMineEmpty => 'لم تنشر أي شيء بعد.';

  @override
  String get postsJobsEmpty => 'لم تنشر أي وظيفة بعد.';

  @override
  String get postsCreateChoicePost => 'منشور جديد';

  @override
  String get postsCreateChoiceJob => 'وظيفة جديدة';

  @override
  String get postsCreateTitle => 'منشور جديد';

  @override
  String get postsPublish => 'نشر';

  @override
  String get postsTitleLabel => 'العنوان (اختياري)';

  @override
  String get postsBodyLabel => 'النص';

  @override
  String get postsDeleteConfirmTitle => 'هل تريد حذف هذا المنشور؟';

  @override
  String get postsDelete => 'حذف';

  @override
  String get postsJobsClosed => 'مغلقة';

  @override
  String postsJobsApplicantsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count متقدم',
      many: '$count متقدمًا',
      few: '$count متقدمين',
      two: 'متقدمان',
      one: 'متقدم واحد',
      zero: 'لا يوجد متقدمون',
    );
    return '$_temp0';
  }

  @override
  String get jobsCreateTitle => 'وظيفة جديدة';

  @override
  String get jobsTitleLabel => 'المسمى الوظيفي';

  @override
  String get jobsBodyLabel => 'وصف الوظيفة';

  @override
  String get jobsRequirementsLabel => 'المتطلبات (اختياري)';

  @override
  String get jobsSalaryLabel => 'الراتب (اختياري)';

  @override
  String get cartTitle => 'السلة';

  @override
  String get cartEmpty => 'السلة فارغة.';

  @override
  String get cartAdd => 'أضف للسلة';

  @override
  String get cartAddedToCart => 'تمت الإضافة للسلة.';

  @override
  String get cartQty => 'الكمية';

  @override
  String get cartRemove => 'إزالة';

  @override
  String get cartVariantChoose => 'اختر النوع';

  @override
  String get cartExtrasChoose => 'إضافات';

  @override
  String cartItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صنف',
      many: '$count صنفًا',
      few: '$count أصناف',
      two: 'صنفان',
      one: 'صنف واحد',
      zero: 'لا توجد أصناف',
    );
    return '$_temp0';
  }

  @override
  String get cartSubtotal => 'الإجمالي الفرعي';

  @override
  String get cartServiceFee => 'رسوم الخدمة';

  @override
  String get cartTax => 'الضريبة';

  @override
  String get cartDeliveryFee => 'رسوم التوصيل';

  @override
  String get cartDiscount => 'الخصم';

  @override
  String get cartFinalTotal => 'الإجمالي';

  @override
  String get cartCheckout => 'إتمام الطلب';

  @override
  String get cartCheckoutTitle => 'إتمام الطلب';

  @override
  String get cartFulfillmentType => 'طريقة الاستلام';

  @override
  String get cartFulfillmentDelivery => 'توصيل';

  @override
  String get cartFulfillmentPickup => 'استلام من المكان';

  @override
  String get cartFulfillmentDineIn => 'تناول في المكان';

  @override
  String get cartAddressLabel => 'العنوان';

  @override
  String get cartAddressHint => 'اكتب عنوان التوصيل';

  @override
  String get cartNotesLabel => 'ملاحظات (اختياري)';

  @override
  String get cartPaymentMethod => 'طريقة الدفع';

  @override
  String get cartPaymentCash => 'نقدًا عند الاستلام';

  @override
  String get cartPlaceOrder => 'تأكيد الطلب';

  @override
  String get cartOrderPlaced => 'تم إرسال الطلب بنجاح.';

  @override
  String get cartGoToCart => 'الذهاب للسلة';

  @override
  String get bookingScreenTitle => 'الحجز';

  @override
  String get bookingSubmit => 'احجز الآن';

  @override
  String get bookingChooseUnit => 'اختر الوحدة';

  @override
  String get bookingUnitEmpty => 'لا توجد وحدات متاحة حاليًا.';

  @override
  String get bookingModifiersTitle => 'إضافات';

  @override
  String get bookingFrom => 'من';

  @override
  String get bookingTo => 'إلى';

  @override
  String get bookingChoosePlaceholder => 'اختر...';

  @override
  String get bookingChannelInPerson => 'حضوريًا';

  @override
  String get bookingChannelOnline => 'أونلاين';

  @override
  String get bookingVisitAtBusiness => 'في المكان';

  @override
  String get bookingVisitAtCustomer => 'عندك';

  @override
  String get bookingSuccess => 'تم إرسال طلب الحجز بنجاح.';

  @override
  String get bookingDatetimeLabel => 'موعد الحجز';

  @override
  String get bookingCapacityLabel => 'السعة';

  @override
  String get bookingUnitRequired => 'اختر الوحدة أولًا.';

  @override
  String get bookingDateRequired => 'حدد الموعد أولًا.';
}
