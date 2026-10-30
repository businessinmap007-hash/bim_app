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
  String get commonRefresh => 'تحديث';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonOk => 'تمام';

  @override
  String get commonSubmit => 'إرسال';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonClear => 'مسح';

  @override
  String get commonNext => 'التالي';

  @override
  String get commonBack => 'رجوع';

  @override
  String get commonSomethingWentWrong => 'حدث خطأ ما، حاول مرة أخرى.';

  @override
  String get commonNoInternet => 'لا يوجد اتصال بالإنترنت.';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get notificationsEmpty => 'لا توجد إشعارات.';

  @override
  String get notificationsMarkAllRead => 'تحديد الكل كمقروء';

  @override
  String get notificationsClearAll => 'مسح الكل';

  @override
  String get notificationsClearAllConfirm =>
      'مسح كل الإشعارات؟ لا يمكن التراجع عن هذا.';

  @override
  String notificationsFrom(String name) {
    return 'من: $name';
  }

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
  String get authForgotPasswordTitle => 'استعادة كلمة المرور';

  @override
  String get authForgotPasswordInstructions =>
      'أدخل بريدك الإلكتروني وسنرسل لك رمز تحقق لإعادة تعيين كلمة المرور.';

  @override
  String get authSendCode => 'إرسال الرمز';

  @override
  String get authResendCode => 'إعادة إرسال الرمز';

  @override
  String get authVerificationCode => 'رمز التحقق';

  @override
  String get authCodeSentMessage => 'تم إرسال رمز التحقق إلى بريدك الإلكتروني.';

  @override
  String get authNewPassword => 'كلمة المرور الجديدة';

  @override
  String get authResetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get authBackToLogin => 'الرجوع لتسجيل الدخول';

  @override
  String get authResetPasswordSuccess =>
      'تم تغيير كلمة المرور بنجاح، يمكنك تسجيل الدخول الآن.';

  @override
  String get authDontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get authAlreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get authLogout => 'تسجيل الخروج';

  @override
  String get authChangePassword => 'تغيير كلمة المرور';

  @override
  String get authCurrentPassword => 'كلمة المرور الحالية';

  @override
  String get authChangePasswordSuccess =>
      'تم تغيير كلمة المرور، وتم تسجيل الخروج من باقي الأجهزة.';

  @override
  String get authLogoutAll => 'تسجيل الخروج من كل الأجهزة';

  @override
  String get authLogoutAllBody =>
      'سيتم تسجيل خروجك من هذا الجهاز ومن كل الأجهزة الأخرى المسجّل دخولك عليها. هل تريد المتابعة؟';

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
  String get categoriesRecommendedTitle => 'أعمال موصى بها';

  @override
  String get categoriesTopRatedTitle => 'الأعلى تقييمًا';

  @override
  String get categoriesRecommendedEmpty => 'لا توجد أعمال بعد.';

  @override
  String get categoriesServiceTypeAll => 'الكل';

  @override
  String get businessSearchHint => 'ابحث باسم النشاط...';

  @override
  String get businessListEmpty => 'لا توجد أنشطة مطابقة.';

  @override
  String get childOfferingsTitle => 'الأصناف والأسعار';

  @override
  String get childOfferingsAll => 'الكل';

  @override
  String get childOfferingsEmpty => 'لا توجد أصناف مطابقة.';

  @override
  String get businessFilterByLocation => 'فلترة حسب الموقع';

  @override
  String get businessFilterGovernorate => 'المحافظة';

  @override
  String get businessFilterCity => 'المدينة';

  @override
  String get businessFilterAnyCity => 'كل المدن';

  @override
  String get businessFilterClearLocation => 'إزالة فلتر الموقع';

  @override
  String get businessFilterChooseGovernorate => 'اختر المحافظة';

  @override
  String get businessFilterByAttributes => 'الخيارات';

  @override
  String businessFilterAttributesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count خيار',
      many: '$count خيارًا',
      few: '$count خيارات',
      two: 'خياران',
      one: 'خيار واحد',
    );
    return '$_temp0';
  }

  @override
  String get businessFilterAttributesEmpty =>
      'لا توجد خيارات متاحة لهذا التصنيف بعد.';

  @override
  String businessFilterAttributeBusinessCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نشاط',
      many: '$count نشاطًا',
      few: '$count أنشطة',
      two: 'نشاطان',
      one: 'نشاط واحد',
      zero: 'لا يوجد نشاط بهذا الخيار',
    );
    return '$_temp0';
  }

  @override
  String get businessFilterAttributesClear => 'مسح الكل';

  @override
  String get businessFilterAttributesApply => 'تطبيق';

  @override
  String get businessOpenNow => 'مفتوح الآن';

  @override
  String get businessClosedNow => 'مغلق الآن';

  @override
  String get businessCallForPrice => 'تفاصيل أكثر';

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
  String get settingsAppSettings => 'إعدادات التطبيق';

  @override
  String get settingsAccountSubtitle =>
      'المعلومات، البزنس، الخدمات، الموظفون، العلامة المائية، الأمان';

  @override
  String get settingsAppSubtitle => 'اللغة، المظهر، الشكل، الإشعارات';

  @override
  String get accountInfoTitle => 'معلومات الحساب';

  @override
  String get accountInfoSubtitle =>
      'الاسم، البريد، الهاتف، العنوان، الموقع، التواصل الاجتماعي';

  @override
  String get businessSettingsTitle => 'إعدادات البزنس';

  @override
  String get businessSettingsSubtitle =>
      'التصنيف، شروط المتجر، التسليم والاستلام، الخصائص';

  @override
  String get servicesSettingsSubtitle => 'خدماتك وتسعير التوصيل والموصّلون';

  @override
  String get staffSettingsTitle => 'إعدادات الموظفين';

  @override
  String get accountSecuritySection => 'الأمان والحساب';

  @override
  String get setupRequiredBadge => 'مطلوب';

  @override
  String get setupIncompleteTitle => 'أكمل إعداد حسابك';

  @override
  String get setupIncompleteBody =>
      'لن تظهر منتجاتك للعملاء حتى تحدد كيف تسلّم الطلبات وكيف تُستلم (شروط المتجر ← التسليم والاستلام).';

  @override
  String get settingsMenuDisplay => 'طريقة عرض المنيو';

  @override
  String get notificationSettingsTitle => 'الإشعارات';

  @override
  String get notificationSettingsSubtitle => 'ما هو فعّال وما هو صامت';

  @override
  String get notificationSettingsHint =>
      'أوقف نوعًا من الإشعارات ليصير صامتًا: يصلك في صندوق الإشعارات لكن لا يظهر على الشاشة ولا يصدر صوتًا.';

  @override
  String get notificationActive => 'فعّال';

  @override
  String get notificationSilent => 'صامت';

  @override
  String get notificationLockedNote =>
      'تنبيهات الأموال ورسائل المنصّة لا تُكتم أبدًا.';

  @override
  String get notificationOnThisPhone => 'على هذا الهاتف';

  @override
  String setupChooseAtLeastOne(String group) {
    return 'اختر خيارًا واحدًا على الأقل في «$group».';
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
  String get settingsCategoriesLayoutSection => 'شكل شاشة التصنيفات';

  @override
  String get settingsLayoutIconRow => 'صف أيقونات مضغوط';

  @override
  String get settingsLayoutTabsAndRows => 'تبويبات وصفوف معاينة';

  @override
  String get settingsLayoutBarAndMenu => 'شريط وقائمة منسدلة';

  @override
  String get accountDataSection => 'بياناتك الأساسية';

  @override
  String get settingsAccountSection => 'إعدادات الحساب';

  @override
  String get settingsServicesSection => 'إعدادات الخدمات';

  @override
  String get settingsNoServicesForCategory =>
      'لا توجد خدمات منصّة متاحة لتصنيف نشاطك الحالي.';

  @override
  String get profileActivitySettingsSection => 'إعدادات النشاط';

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
  String get productWatermarkTitle => 'ضع علامتي المائية على الصور';

  @override
  String productWatermarkOn(String text) {
    return 'ستُختم بـ: $text — لحماية الصور من السرقة';
  }

  @override
  String get productWatermarkOff => 'تُضاف الصور كما هي بلا علامة';

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
  String get businessTabMenu => 'منيو';

  @override
  String get businessTabBooking => 'الحجز';

  @override
  String get businessTabAbout => 'عن النشاط';

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
  String businessMenuAvailableQuantity(int quantity) {
    return 'متاح $quantity';
  }

  @override
  String get menuCardBestseller => 'الأكثر طلبًا';

  @override
  String menuCardPriceFrom(String price) {
    return 'من $price';
  }

  @override
  String menuCardPricePerUnit(String price, String unit) {
    return '$price جنيه / $unit';
  }

  @override
  String get menuCardViewOptions => 'اختر';

  @override
  String get menuCardAddShort => 'أضف';

  @override
  String get menuCardSpecsTitle => 'المواصفات';

  @override
  String get businessNoContentYet => 'لا يوجد محتوى لعرضه بعد';

  @override
  String get businessInfoTitle => 'معلومات النشاط';

  @override
  String get businessInfoPhone => 'رقم الهاتف';

  @override
  String get businessInfoAddress => 'العنوان';

  @override
  String get businessInfoCountry => 'الدولة';

  @override
  String get businessInfoLocation => 'الموقع';

  @override
  String get businessInfoOpenInMaps => 'فتح في الخرائط';

  @override
  String get businessInfoCheckIn => 'موعد تسجيل الوصول';

  @override
  String get businessInfoCheckOut => 'موعد تسجيل المغادرة';

  @override
  String get businessInfoHours => 'ساعات العمل';

  @override
  String get businessInfoAlbums => 'ألبوم الصور';

  @override
  String get businessInfoNoAlbums => 'لا توجد صور بعد.';

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
  String get profileLocationNoMatch =>
      'لم نتمكن من تحديد المحافظة والمدينة من موقعك، برجاء الاختيار يدويًا.';

  @override
  String get profilePhotoCamera => 'التقاط بالكاميرا';

  @override
  String get profilePhotoGallery => 'اختيار من المعرض';

  @override
  String get profilePhotoView => 'عرض الصورة';

  @override
  String get coverCropTitle => 'ضبط صورة الغلاف';

  @override
  String get coverCropHint =>
      'اسحب وكبّر لتضع الجزء المطلوب داخل الإطار — هكذا سيظهر الغلاف بالضبط. العلامة الحمراء هي المنتصف.';

  @override
  String get coverCropCentre => 'توسيط الصورة';

  @override
  String get profileCoverAdjust => 'ضبط الغلاف الحالي';

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
  String get profileSocialLinks => 'روابط التواصل الاجتماعي';

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
  String get locationFieldLabel => 'المحافظة / المدينة';

  @override
  String get locationGovernorateLabel => 'المحافظة';

  @override
  String get locationCityLabel => 'المدينة / القرية / الحي';

  @override
  String get locationChooseCityHint => 'اختر المدينة';

  @override
  String get locationChooseHint => 'اختر المحافظة والمدينة';

  @override
  String get locationChooseGovernorate => 'اختر المحافظة';

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
  String get depositAsPaymentRequest => 'اطلب من النشاط اعتماد ديبوزتي كدفعة';

  @override
  String get depositAsPaymentRequested =>
      'تم إرسال طلبك. يبقى الديبوزت مجمّدًا إلى أن يردّ النشاط.';

  @override
  String get depositAsPaymentAsked =>
      'يطلب العميل أن يُعتمد ديبوزته المجمّد كدفعة بدل التحويل خارج التطبيق.';

  @override
  String get depositAsPaymentAccept => 'اعتمد الديبوزت كدفعة';

  @override
  String get depositAsPaymentDecline => 'ارفض';

  @override
  String get depositAsPaymentTaken => 'اعتُمد الديبوزت كدفعة.';

  @override
  String get depositAsPaymentDeclined =>
      'رفض النشاط. ادفع القيمة مباشرة كالمعتاد.';

  @override
  String get bookingTermsDepositAsPayment =>
      'أقبل الديبوزت المجمّد كدفعة عندما يطلب العميل';

  @override
  String get bookingTermsDepositAsPaymentHint =>
      'اختياري. بدل التحويل خارج التطبيق، يجوز للعميل أن يطلب اعتماد الديبوزت المجمّد كدفعة، ولك القبول أو الرفض في كل مرة.';

  @override
  String get depositNotPartOfPrice =>
      'الديبوزت إجراء لضمان الجدية وليس جزءًا من السعر: يُرد بمجرد دفع العميل كامل القيمة مباشرة. رسوم المنصة تُخصم من كل محفظة بشكل منفصل.';

  @override
  String get roomsTitle => 'الغرف';

  @override
  String roomsOpenCount(String n) {
    return '$n متاحة';
  }

  @override
  String get roomsHint =>
      'قائمة الفندق الخاصة. العميل يحجز نوع الغرفة ولا يرى هذه الأرقام قبل بدء إقامته. اكتب أرقامًا أو مدى مثل 101-110.';

  @override
  String get roomsNumbersField => 'أرقام الغرف';

  @override
  String get roomsAdd => 'أضف';

  @override
  String get roomMaintenance => 'إغلاق للصيانة';

  @override
  String get roomsReopen => 'إعادة فتح';

  @override
  String get bookingRoom => 'الغرفة';

  @override
  String get bookingRoomOnStart => 'تُعيَّن عند بدء الإقامة';

  @override
  String get bookingRoomAssign => 'اختر';

  @override
  String get bookingRoomChange => 'تغيير';

  @override
  String get bookingRoomNoFree =>
      'لا توجد غرفة متاحة من هذا النوع لهذه الليالي.';

  @override
  String get bookingRoomNone => 'هذا النوع ليس له غرف مسجّلة.';

  @override
  String bookingRoomYours(String number) {
    return 'غرفتك: $number';
  }

  @override
  String get bookingTermsTitle => 'شروط الحجز';

  @override
  String get bookingTermsIntro =>
      'حدّد كيف تؤمّن حجوزاتك. كل حجز ينتظر موافقتك قبل أن يتأكد.';

  @override
  String get bookingTermsEnabled => 'اطلب تأمينًا على الحجز';

  @override
  String get bookingTermsEnabledHint => 'بدونه يتم الحجز دون ديبوزت.';

  @override
  String get bookingTermsModeTitle => 'طريقة التأمين';

  @override
  String get bookingTermsModeDeposit => 'تجميد ديبوزت';

  @override
  String get bookingTermsModeDepositHint =>
      'يُجمَّد مبلغ من محفظة العميل ومقابله من محفظتك، ويُفرج عنهما بموافقة الطرفين.';

  @override
  String get bookingTermsModeGuarantee => 'تجميد ضمان العميل';

  @override
  String get bookingTermsModeGuaranteeHint =>
      'يقوم ضمان العميل مقام المال، فإن لم يكفِ طُلب منه ديبوزت.';

  @override
  String get bookingTermsModeExternal => 'تحويل خارج التطبيق';

  @override
  String get bookingTermsModeExternalHint =>
      'يحوّل العميل المبلغ إليك مباشرة، ويؤكد الطرفان ذلك. المنصة لا تتحمّل أي مسؤولية عن التحويل.';

  @override
  String get bookingTermsRecommended => 'مفضّل';

  @override
  String get bookingTermsPercentTitle => 'قيمة الديبوزت';

  @override
  String bookingTermsPercentValue(String percent) {
    return '$percent٪ من قيمة الحجز';
  }

  @override
  String get bookingTermsBaseTitle => 'تُحسب على';

  @override
  String get bookingTermsBaseFirstDay => 'قيمة أول يوم';

  @override
  String get bookingTermsBaseTotal => 'إجمالي الحجز';

  @override
  String get bookingTermsCounterTitle => 'ما تجمّده أنت مقابله';

  @override
  String bookingTermsCounterValue(String percent) {
    return '$percent٪ من الديبوزت';
  }

  @override
  String get bookingTermsCounterHint =>
      'نسبة من ديبوزت العميل تُجمَّد من محفظتك، فتلتزم أنت أيضًا.';

  @override
  String get bookingTermsGuaranteeTitle => 'حجم الضمان المطلوب';

  @override
  String get bookingTermsGuaranteeSame => 'بقدر الديبوزت';

  @override
  String bookingTermsGuaranteeTimes(String n) {
    return '$n× قيمة حجز اليوم';
  }

  @override
  String get bookingTermsGuaranteeHint => 'يمكن أن يكون أضعاف قيمة حجز اليوم.';

  @override
  String get bookingTermsExternalNote =>
      'يحوّل العميل الديبوزت مباشرة، وتؤكد أنت أنه وصلك قبل بدء الإقامة.';

  @override
  String get bookingTermsForfeitTitle =>
      'عند تخلّف العميل يُخصم الديبوزت كاملًا لصالحي';

  @override
  String get bookingTermsForfeitHint =>
      'شرط معلن يراه العميل عند الحجز، ويرجع إليه المحكّم عند الخلاف.';

  @override
  String bookingTermsExampleTitle(String value) {
    return 'مثال: حجز يوم بـ$value';
  }

  @override
  String bookingTermsExampleDeposit(String amount) {
    return 'الديبوزت: $amount';
  }

  @override
  String bookingTermsExampleCustomer(String amount) {
    return 'يُجمَّد من العميل: $amount';
  }

  @override
  String bookingTermsExampleBusiness(String amount) {
    return 'يُجمَّد منك: $amount';
  }

  @override
  String bookingTermsExampleExternal(String amount) {
    return 'يحوّله العميل مباشرة: $amount';
  }

  @override
  String bookingTermsExampleGuarantee(String amount) {
    return 'ضمان العميل المطلوب: $amount';
  }

  @override
  String get bookingTermsSpecificWarning =>
      'لديك شروط مخصصة لخدمات معيّنة، وهي تتقدّم على هذه.';

  @override
  String get bookingTermsApprovalNote => 'كل حجز ينتظر موافقتك قبل أن يتأكد.';

  @override
  String get bookingTermsSaved => 'تم حفظ شروط الحجز';

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
  String get bookingSettingsApplyAllLabel => 'كل الأيام';

  @override
  String get bookingSettingsApplyToWeek => 'طبّق على الأسبوع';

  @override
  String get bookingSettingsApplyHint =>
      'يملأ القائمة فقط — عدّل أي يوم بعدها، ثم احفظ.';

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
  String get bookingSettingsDescription => 'الوصف';

  @override
  String get bookingSettingsStatus => 'الحالة';

  @override
  String get bookingSettingsStatusAvailable => 'متاحة';

  @override
  String get bookingSettingsStatusMaintenance => 'مغلقة للصيانة';

  @override
  String get bookingSettingsStatusBooked => 'محجوزة الآن';

  @override
  String get bookingSettingsGridView => 'عرض شبكي';

  @override
  String get bookingSettingsListView => 'عرض قائمة';

  @override
  String get bookingSettingsEditUnit => 'تعديل الوحدة';

  @override
  String get bookingSettingsCheckInTime => 'موعد تسجيل الدخول';

  @override
  String get bookingSettingsCheckOutTime => 'موعد المغادرة';

  @override
  String get bookingSettingsSaveCheckTimes => 'حفظ مواعيد الدخول والمغادرة';

  @override
  String get bookingSettingsCheckTimesSaved =>
      'تم حفظ مواعيد الدخول والمغادرة.';

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
  String get myFollowsTitle => 'المتابَعون';

  @override
  String get myFollowsEmpty => 'أنت لا تتابع أي حساب بعد.';

  @override
  String get postsFeedEmpty =>
      'لا توجد منشورات بعد — تابع نشاطًا تجاريًا لترى منشوراته هنا.';

  @override
  String get postsMineEmpty => 'لم تنشر أي شيء بعد.';

  @override
  String get postsJobsEmpty => 'لم تنشر أي وظيفة بعد.';

  @override
  String get postsCreateTitle => 'منشور جديد';

  @override
  String get postsPublish => 'نشر';

  @override
  String get postsTitleLabel => 'العنوان';

  @override
  String get postsBodyLabel => 'النص';

  @override
  String postsMaxImagesReached(int max) {
    return 'بحد أقصى $max صور لكل منشور.';
  }

  @override
  String get postsDeleteConfirmTitle => 'هل تريد حذف هذا المنشور؟';

  @override
  String get postsDelete => 'حذف';

  @override
  String get postsReadMore => 'المزيد';

  @override
  String get postsShare => 'مشاركة';

  @override
  String get postsEdit => 'تعديل';

  @override
  String get postsEditTitle => 'تعديل المنشور';

  @override
  String get postsReplacePhotos => 'استبدال الصور';

  @override
  String get postsKeepCurrentPhotos => 'الاحتفاظ بالصور الحالية';

  @override
  String get postsSaveChanges => 'حفظ';

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
  String get postsLinkItem => 'ربط بعنصر من عندك (اختياري)';

  @override
  String get postsLinkItemSheetTitle => 'اختر عنصراً للإعلان عنه';

  @override
  String get jobsTitleLabel => 'المسمى الوظيفي';

  @override
  String get jobsStatsPosted => 'وظائف معلنة';

  @override
  String get jobsStatsOpen => 'مفتوحة الآن';

  @override
  String get jobsStatsApplicants => 'المتقدّمون';

  @override
  String get jobsStatsApproved => 'تم قبولهم';

  @override
  String jobsPlatformSummary(int open, int hiring) {
    return '$open وظيفة مفتوحة من $hiring جهة توظّف';
  }

  @override
  String get jobsPickTitleHint => 'اختر المسمى الوظيفي';

  @override
  String get jobsTitleOther => 'مسمى آخر';

  @override
  String get jobsAllTitles => 'كل المسميات';

  @override
  String get jobsBodyLabel => 'وصف الوظيفة';

  @override
  String get jobsRequirementsLabel => 'المتطلبات (اختياري)';

  @override
  String get jobsSalaryLabel => 'الراتب (اختياري)';

  @override
  String get jobsPublishAction => 'نشر الوظيفة';

  @override
  String get cartTitle => 'السلة';

  @override
  String get cartEmpty => 'السلة فارغة.';

  @override
  String get cartAdd => 'أضف للسلة';

  @override
  String get cartBuyNow => 'شراء مباشر';

  @override
  String get cartAddedToCart => 'تمت الإضافة للسلة.';

  @override
  String get cartQty => 'الكمية';

  @override
  String get cartRemove => 'إزالة';

  @override
  String get cartVariantChoose => 'اختر النوع';

  @override
  String cartPaymentInstalments(int count, String monthly, String date) {
    return 'تقسيط على $count شهر — $monthly شهريًا، أول دفعة $date';
  }

  @override
  String cartPaymentInstalmentsDown(
    int count,
    String first,
    String monthly,
    String date,
  ) {
    return 'تقسيط على $count شهر — الدفعة الأولى $first (بالمقدم) ثم $monthly شهريًا، أول دفعة $date';
  }

  @override
  String variantInstallmentNoteDown(int months, String down, String monthly) {
    return 'مقدم $down + $months شهر — $monthly شهريًا';
  }

  @override
  String get techPricingInstallmentDown => 'الدفعة المقدمة (اختياري)';

  @override
  String get techPricingInstallmentDownInvalid =>
      'الدفعة المقدمة لازم تكون أقل من السعر.';

  @override
  String ordersInstallmentsPaidSummary(String paid, String remaining) {
    return 'المدفوع $paid · المتبقي $remaining';
  }

  @override
  String get ordersInstallmentCollect => 'تحصيل';

  @override
  String get ordersInstallmentUndo => 'تراجع عن التحصيل';

  @override
  String cartOrderPlacedPaidNow(String paid) {
    return 'المدفوع الآن: $paid';
  }

  @override
  String get businessReportsTabCash => 'كاش';

  @override
  String get businessReportsTabInstallments => 'تقسيط';

  @override
  String get businessReportsInstOrders => 'طلبات التقسيط';

  @override
  String get businessReportsInstContractTotal => 'إجمالي التقسيط';

  @override
  String get businessReportsInstCollected => 'تم تحصيله';

  @override
  String get businessReportsInstRemaining => 'المتبقي للتحصيل';

  @override
  String get businessReportsInstOverdue => 'متأخر';

  @override
  String get businessReportsInstByMonth => 'المستحق بالشهر';

  @override
  String get businessReportsInstUpcoming => 'الأقساط القادمة';

  @override
  String get businessReportsInstNone => 'لا توجد أقساط مستحقة.';

  @override
  String businessReportsInstPayments(int count) {
    return '$count دفعة';
  }

  @override
  String businessReportsInstLine(int seq, int count, int order) {
    return 'قسط $seq من $count · طلب #$order';
  }

  @override
  String get ordersInstallmentsTitle => 'جدول الدفعات';

  @override
  String get ordersInstallmentPaid => 'تم السداد';

  @override
  String get techPricingInstallmentMonths => 'عدد الأشهر';

  @override
  String get techPricingInstallmentMonthsRequired =>
      'اكتب عدد أشهر التقسيط (شهران فأكثر).';

  @override
  String variantInstallmentNote(int months, String monthly) {
    return '$months شهر — $monthly شهريًا';
  }

  @override
  String techPricingPriceBy(String group) {
    return 'السعر حسب $group';
  }

  @override
  String get cartPaymentChoose => 'اختر طريقة الدفع';

  @override
  String get techPricingPriceFor => 'السعر';

  @override
  String get cartExtrasChoose => 'إضافات';

  @override
  String get menuItemDetailTitle => 'تفاصيل المنتج';

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
  String get cartStoreNotReady =>
      'لم يحدد هذا المتجر طريقة التسليم والاستلام بعد، فلا يمكنك إتمام طلب منه الآن.';

  @override
  String get cartFulfillmentType => 'طريقة الاستلام';

  @override
  String get cartFulfillmentDelivery => 'توصيل';

  @override
  String get cartFulfillmentPickup => 'استلام من المكان';

  @override
  String get cartFulfillmentShipping => 'شحن';

  @override
  String get cartFulfillmentFactoryPickup => 'استلام أرض المصنع';

  @override
  String get cartFulfillmentDineIn => 'تناول في المكان';

  @override
  String get businessFulfillmentPrompt => 'عايز تستلم طلبك إزاي؟';

  @override
  String get cartOutOfStockPolicyPrompt =>
      'لو حاجة في طلبك نفذت، تحب نعمل إيه؟';

  @override
  String get cartOutOfStockSubstitute => 'بديل (نختار الأقرب)';

  @override
  String get cartOutOfStockRemove => 'احذف الصنف الناقص بس';

  @override
  String get cartOutOfStockCancel => 'الغِ الطلب كله';

  @override
  String orderLineSubstituted(String note) {
    return 'تم الاستبدال بـ: $note';
  }

  @override
  String get orderLineRemoved => 'غير متاح — تم حذفه';

  @override
  String get cartAddressLabel => 'العنوان';

  @override
  String get cartAddressHint => 'اكتب عنوان التوصيل';

  @override
  String get cartPickupTimeLabel => 'موعد الاستلام';

  @override
  String get cartPickupTimeChoose => 'اختر موعد الاستلام';

  @override
  String get cartPickupTimeRequired => 'حدد الموعد الذي ستستلم فيه الطلب.';

  @override
  String get cartNotesLabel => 'ملاحظات (اختياري)';

  @override
  String get cartPaymentMethod => 'طريقة الدفع';

  @override
  String get cartPaymentCash => 'الدفع عند الاستلام';

  @override
  String get cartPaymentCashInStore => 'الدفع نقدًا فى المحل';

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
  String get bookingTotalLabel => 'الإجمالي';

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
  String get maxChildrenLabel => 'أقصى عدد أطفال في الغرفة';

  @override
  String get maxChildrenHelp =>
      'بجانب البالغين، من عمر سنتين (الرضيع في سرير أطفال). فارغ = لم يُحدَّد';

  @override
  String roomOccupancy(int adults, int children) {
    return '$adults بالغ + $children طفل';
  }

  @override
  String get bookingUnitRequired => 'اختر الوحدة أولًا.';

  @override
  String get bookingDateRequired => 'حدد الموعد أولًا.';

  @override
  String get bookingUnitUnavailable => 'غير متاحة في هذه المواعيد';

  @override
  String get ordersBookingsTitle => 'طلباتي وحجوزاتي';

  @override
  String get ordersTab => 'الطلبات';

  @override
  String get bookingsTab => 'الحجوزات';

  @override
  String get businessOrdersTitle => 'الطلبات الواردة';

  @override
  String get businessReportsTitle => 'التقارير';

  @override
  String get businessReportsRange7d => '7 أيام';

  @override
  String get businessReportsRange30d => '30 يوم';

  @override
  String get businessReportsRange90d => '90 يوم';

  @override
  String get businessReportsTotalOrders => 'إجمالي الطلبات';

  @override
  String get businessReportsTotalRevenue => 'الإيرادات';

  @override
  String get businessReportsCompleted => 'مكتملة';

  @override
  String get businessReportsCancelled => 'ملغاة';

  @override
  String get businessReportsPending => 'قيد الانتظار';

  @override
  String get businessReportsAverageOrderValue => 'متوسط قيمة الطلب';

  @override
  String get businessReportsDailyOrdersChartTitle => 'الطلبات يوميًا';

  @override
  String get businessReportsDailyRevenueChartTitle => 'الإيرادات يوميًا';

  @override
  String get businessReportsByFulfillmentType => 'حسب طريقة التنفيذ';

  @override
  String get businessReportsEmpty => 'لا توجد طلبات في هذه الفترة.';

  @override
  String get businessOrdersFilterAll => 'الكل';

  @override
  String get businessOrdersFilterPending => 'قيد الانتظار';

  @override
  String get businessOrdersFilterCompleted => 'مكتملة';

  @override
  String get businessOrdersFilterCancelled => 'ملغاة';

  @override
  String get businessOrdersEmpty => 'لا توجد طلبات بعد.';

  @override
  String businessOrdersItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عنصر',
      many: '$count عنصرًا',
      few: '$count عناصر',
      two: 'عنصران',
      one: 'عنصر واحد',
      zero: 'لا عناصر',
    );
    return '$_temp0';
  }

  @override
  String get businessOrdersStatusPending => 'جديد';

  @override
  String get businessOrdersStatusAccepted => 'مقبول';

  @override
  String get businessOrdersStatusPreparing => 'قيد التحضير';

  @override
  String get businessOrdersStatusReady => 'جاهز';

  @override
  String get businessOrdersStatusCompleted => 'مكتمل';

  @override
  String get businessOrdersStatusCancelled => 'ملغى';

  @override
  String get businessOrdersItemsSection => 'الأصناف';

  @override
  String get businessOrdersTotal => 'الإجمالي';

  @override
  String get businessOrdersNotes => 'ملاحظات';

  @override
  String get businessOrdersDepositCovered => 'مغطّى بضمان أو ديبوزيت';

  @override
  String get businessOrdersDepositUncovered => 'بلا ضمان أو ديبوزيت';

  @override
  String get paymentConfirmSectionTitle => 'تأكيد الدفع';

  @override
  String get shippingRatesTitle => 'أسعار الشحن';

  @override
  String get shippingDaysHint =>
      'أيام الشحن لهذه الوجهة (بدون تحديد = كل الأيام)';

  @override
  String get shippingRunsToday => 'اليوم';

  @override
  String get shippingRunsTomorrow => 'غدًا';

  @override
  String get shippingRatesHint =>
      'سعر الشحن من محافظتك إلى كل محافظة. اترك الحقل فارغًا لو لا تشحن إليها.';

  @override
  String get shippingOrdersTitle => 'طلبات الشحن';

  @override
  String get shippingOrdersEmpty => 'لا توجد طلبات شحن.';

  @override
  String get shippingPickCompany => 'اختر شركة الشحن';

  @override
  String get shippingChangeCompany => 'تغيير شركة الشحن';

  @override
  String get shippingPickerTitle => 'شركات الشحن المتاحة';

  @override
  String get shippingNoCompanies => 'لا توجد شركة شحن تخدم محافظة العميل بعد.';

  @override
  String get shippingSetAppointment => 'حدد موعد الشحن';

  @override
  String get shippingChangeAppointment => 'تعديل الموعد';

  @override
  String get shippingMarkShipped => 'تم الشحن';

  @override
  String get shippingMarkDelivered => 'تم التسليم';

  @override
  String get shippingStatusAwaitingCompany => 'بانتظار اختيار شركة الشحن';

  @override
  String get shippingStatusAwaitingAppointment => 'بانتظار تحديد موعد الشحن';

  @override
  String get shippingStatusShipped => 'تم شحن الطلب';

  @override
  String get shippingStatusDelivered => 'تم تسليم الطلب';

  @override
  String get shippingAppointmentSuitable => 'الموعد مناسب';

  @override
  String get shippingAppointmentConfirmed => 'وافقت على الموعد';

  @override
  String get businessMyLocation => 'مدينتي';

  @override
  String get registerAddressLabel => 'العنوان (الشارع، المبنى...)';

  @override
  String get checkoutNeedAddress => 'اختر عنوان التوصيل أولًا.';

  @override
  String get addressSaveAndUse => 'حفظ العنوان واستخدامه';

  @override
  String get shippingAppointmentNotSuitable =>
      'الموعد غير مناسب — تواصل مع الشركة';

  @override
  String get shippingCheckoutNote =>
      'طلبك لمحافظة أخرى: يُشحن عبر شركة شحن يختارها التاجر، ويُضاف سعر الشحن لفاتورتك.';

  @override
  String get shippingSaved => 'تم الحفظ.';

  @override
  String shippingStatusScheduled(String when) {
    return 'موعد الشحن: $when';
  }

  @override
  String shippingCompanyLine(String name) {
    return 'شركة الشحن: $name';
  }

  @override
  String shippingFeeLine(String fee) {
    return 'رسوم الشحن: $fee';
  }

  @override
  String get deliveryQuoteEnterAmountTitle => 'رسوم التوصيل لهذا الطلب';

  @override
  String get deliveryQuoteAmountLabel => 'المبلغ';

  @override
  String get deliveryQuoteProposeButton => 'اقترح رسوم التوصيل';

  @override
  String get deliveryQuoteSend => 'إرسال';

  @override
  String get deliveryQuoteFeeLocked =>
      'رسوم التوصيل لم تُعتمد بعد — لا يمكن بدء الاستلام.';

  @override
  String get deliveryQuoteAwaitingCourier =>
      'الطلب خارج مدينة النشاط — بانتظار موصّل يحدد رسوم التوصيل.';

  @override
  String get deliveryQuoteAccept => 'قبول الرسوم';

  @override
  String get deliveryQuoteDecline => 'رفض';

  @override
  String get deliveryQuoteMerchantSuitable => 'التاجر يرى أن الرسوم مناسبة';

  @override
  String get deliveryQuoteMerchantNotSuitable =>
      'التاجر يرى أن الرسوم غير مناسبة';

  @override
  String get deliveryQuoteRecommendSuitable => 'مناسبة';

  @override
  String get deliveryQuoteRecommendNotSuitable => 'غير مناسبة';

  @override
  String get deliveryQuoteNoteLabel => 'ملاحظة للعميل (اختياري)';

  @override
  String get deliveryQuoteCheckoutLater =>
      'رسوم التوصيل: يحددها الموصّل بعد قبول طلبك، وتوافق عليها أنت.';

  @override
  String get deliveryQuoteSaved => 'تم إرسال ردّك.';

  @override
  String deliveryQuoteWaitingCustomer(String amount) {
    return 'بانتظار رد العميل على $amount';
  }

  @override
  String deliveryQuoteProposedTitle(String amount) {
    return 'اقترح الموصّل رسوم توصيل $amount';
  }

  @override
  String deliveryQuoteRecommendTitle(String amount) {
    return 'الموصّل اقترح $amount — هل هي مناسبة؟';
  }

  @override
  String get orderDeliveryFeeRow => 'رسوم التوصيل';

  @override
  String get bookingPaymentBusinessStatusLabel => 'استلام النشاط للمبلغ';

  @override
  String get bookingPaymentBusinessButton => 'تأكيد استلام المبلغ نقدًا';

  @override
  String get bookingPaymentBusinessConfirmed => 'تم تأكيد استلام المبلغ';

  @override
  String get bookingPaymentDepositHint =>
      'تأكيدك يُعد موافقة على فك التأمين، ويُفك عند تأكيد الطرفين.';

  @override
  String get paymentConfirmCompleteHint =>
      'أكّد استلام مبلغ الطلب أولًا لتتمكن من إكمال الطلب.';

  @override
  String get paymentConfirmReviewHint =>
      'يفتح التقييم بعد تأكيد الدفع من جميع الأطراف.';

  @override
  String get trustSectionTitle => 'الثقة';

  @override
  String get trustCustomer => 'أثق في العميل';

  @override
  String get trustBusiness => 'أثق في التاجر';

  @override
  String get trustDriver => 'أثق في الموصّل';

  @override
  String get trustsYouNote => 'يثق بك';

  @override
  String get businessOrdersDepositReleased =>
      'تم فك التأمين بعد تأكيد جميع الأطراف';

  @override
  String get paymentConfirmCustomerStatusLabel => 'دفع العميل';

  @override
  String get paymentConfirmMerchantStatusLabel => 'استلام التاجر لمبلغ الطلب';

  @override
  String get paymentConfirmDriverStatusLabel => 'استلام الموصّل لرسوم التوصيل';

  @override
  String get paymentConfirmStatusConfirmed => 'تم التأكيد';

  @override
  String get paymentConfirmStatusPending => 'لم يتم التأكيد بعد';

  @override
  String get paymentConfirmCustomerButton => 'أكدت أنني دفعت نقدًا';

  @override
  String get paymentConfirmCustomerConfirmed => 'تم تأكيد دفعك';

  @override
  String get paymentConfirmMerchantButton => 'تأكيد استلام مبلغ الطلب نقدًا';

  @override
  String get paymentConfirmMerchantConfirmed => 'تم تأكيد استلام مبلغ الطلب';

  @override
  String get businessOrdersReject => 'رفض';

  @override
  String get businessOrdersAccept => 'قبول';

  @override
  String get businessOrdersRejectConfirm => 'رفض هذا الطلب؟ سيتم إشعار العميل.';

  @override
  String get businessOrdersNoDepositWarning =>
      'هذا الطلب بلا ضمان أو ديبوزيت من العميل. هل تريد قبوله على مسؤوليتك؟';

  @override
  String get businessOrdersMarkPreparing => 'بدء التحضير';

  @override
  String get businessOrdersMarkReady => 'تم التجهيز';

  @override
  String get businessOrdersItemUnavailable => 'علّم كغير متاح';

  @override
  String get businessOrdersItemUnavailableTitle => 'هذا الصنف غير متاح';

  @override
  String get businessOrdersItemUnavailableSubstituteNoteLabel =>
      'استبدلته بإيه؟';

  @override
  String get businessOrdersItemUnavailableSubstituteNoteHint =>
      'مثال: بيبسي بدل كوكاكولا';

  @override
  String get businessOrdersItemUnavailableRemoveConfirm =>
      'سيتم حذف هذا الصنف من الطلب وتحديث الإجمالي. سيتم إشعار العميل.';

  @override
  String businessOrdersItemUnavailableCancelConfirm(int id) {
    return 'العميل اختار إلغاء الطلب كله لو نفذ صنف. سيتم إلغاء الطلب رقم #$id بالكامل.';
  }

  @override
  String get businessOrdersItemUnavailableNoPolicy =>
      'العميل لم يحدد ماذا يفعل لو نفذ صنف. تواصل معه مباشرة عبر شات الطلب.';

  @override
  String get businessOrdersItemUnavailableDone => 'تم — وصل إشعار للعميل.';

  @override
  String get ordersEmpty => 'لا توجد طلبات بعد.';

  @override
  String get bookingsEmpty => 'لا توجد حجوزات بعد.';

  @override
  String get ordersCancel => 'إلغاء الطلب';

  @override
  String get bookingMoneyTitle => 'ما يلزمك مقدّماً لهذا الحجز';

  @override
  String get bookingMoneyDeposit => 'تأمين يُحجز من محفظتك';

  @override
  String get bookingMoneyGuarantee => 'مغطّى بضمانك';

  @override
  String get bookingMoneyFee => 'رسوم الخدمة';

  @override
  String get bookingMoneyTotal => 'المطلوب من محفظتك';

  @override
  String get bookingMoneyBalance => 'رصيد محفظتك';

  @override
  String get bookingMoneyReady => 'رصيدك يكفي';

  @override
  String get bookingMoneyShort => 'رصيدك لا يكفي';

  @override
  String get bookingMoneyFeeNonRefundable =>
      'رسوم الخدمة لا تُسترد بعد بدء تنفيذ الحجز.';

  @override
  String get bookingMoneyOtherPending => 'الطرف الآخر لم يستوفِ ما عليه بعد.';

  @override
  String get orderDriverTitle => 'المندوب الذي يوصّل طلبك';

  @override
  String get orderDriverCall => 'اتصال بالمندوب';

  @override
  String get ordersReorder => 'اطلب مرة أخرى';

  @override
  String get ordersReordered => 'تمت إضافة العناصر إلى السلة.';

  @override
  String get ordersReorderedWithSkipped =>
      'تمت إضافة العناصر المتاحة إلى السلة، وتعذّر توفير بعضها.';

  @override
  String get ordersCancelled => 'تم إلغاء الطلب.';

  @override
  String get ordersCancelConfirm => 'هل تريد إلغاء هذا الطلب؟';

  @override
  String get bookingsCancel => 'إلغاء الحجز';

  @override
  String get bookingsCancelled => 'تم إلغاء الحجز.';

  @override
  String get bookingsCancelConfirm => 'هل تريد إلغاء هذا الحجز؟';

  @override
  String get bookingsConfirmReadiness => 'تأكيد الاستعداد';

  @override
  String get bookingsConfirmed => 'تم حفظ التأكيد.';

  @override
  String get bookingsDepositSettlement => 'تسوية الضمان';

  @override
  String get bookingsAgreeRelease => 'تأكيد نجاح المعاملة';

  @override
  String get bookingsAgreeRefund => 'المعاملة لم تتم';

  @override
  String get bookingsAgreementSaved => 'تم حفظ إجابتك.';

  @override
  String get bookingsWaitingOtherPartyRelease =>
      'في انتظار تأكيد الطرف الآخر على فكّ الضمان.';

  @override
  String get bookingsWaitingOtherPartyRefund =>
      'في انتظار تأكيد الطرف الآخر على استرجاع المبلغ.';

  @override
  String get bookingsDepositReleased => 'تم فكّ الضمان.';

  @override
  String get bookingsDepositRefunded => 'تم استرجاع المبلغ.';

  @override
  String get pendingSettlementTitle => 'قرار مطلوب';

  @override
  String get pendingSettlementSubtitle =>
      'لازم تحدّد قبل ما تكمّل استخدام التطبيق.';

  @override
  String pendingSettlementQuestion(String name) {
    return 'هل نجحت المعاملة مع $name؟';
  }

  @override
  String pendingSettlementRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'باقي $count قرارات بعد ده',
      one: 'باقي قرار واحد بعد ده',
    );
    return '$_temp0';
  }

  @override
  String get orderStatusPending => 'قيد الانتظار';

  @override
  String get orderStatusCompleted => 'مكتمل';

  @override
  String get orderStatusCancelled => 'ملغي';

  @override
  String get orderTrackerPlaced => 'تم استلام الطلب';

  @override
  String get orderTrackerAccepted => 'تم القبول';

  @override
  String get orderTrackerPreparing => 'قيد التحضير';

  @override
  String get orderTrackerReady => 'جاهز';

  @override
  String get orderTrackerCompletedPickup => 'تم الاستلام';

  @override
  String get orderTrackerCompletedDineIn => 'تم التقديم';

  @override
  String get orderTrackerDriverAssigned => 'تم تعيين الموصّل';

  @override
  String get orderTrackerPickedUpByDriver => 'استلمها الموصّل';

  @override
  String get orderTrackerDelivered => 'تم التوصيل';

  @override
  String get orderTrackerCancelledTitle => 'تم إلغاء هذا الطلب';

  @override
  String get bookingStatusPending => 'قيد الانتظار';

  @override
  String get bookingStatusAccepted => 'مقبول';

  @override
  String get bookingStatusRejected => 'مرفوض';

  @override
  String get bookingStatusCancelled => 'ملغي';

  @override
  String get bookingStatusInProgress => 'جارٍ التنفيذ';

  @override
  String get bookingStatusCompleted => 'مكتمل';

  @override
  String get businessBookingsTitle => 'الحجوزات الواردة';

  @override
  String get businessBookingsFilterAll => 'الكل';

  @override
  String get businessBookingsFilterPending => 'بانتظار الرد';

  @override
  String get businessBookingsFilterAccepted => 'مقبول';

  @override
  String get businessBookingsFilterInProgress => 'جارٍ التنفيذ';

  @override
  String get businessBookingsFilterCompleted => 'مكتمل';

  @override
  String get businessBookingsFilterCancelled => 'ملغي';

  @override
  String get businessBookingsEmpty => 'لا توجد حجوزات بعد.';

  @override
  String get businessBookingsCustomer => 'العميل';

  @override
  String get businessBookingsUnit => 'الوحدة';

  @override
  String get businessBookingsQuantity => 'الكمية';

  @override
  String get businessBookingsPartySize => 'عدد الأفراد';

  @override
  String get businessBookingsNotes => 'ملاحظات';

  @override
  String get businessBookingsDateTime => 'الموعد';

  @override
  String get businessBookingsPrice => 'السعر';

  @override
  String get businessBookingsAccept => 'قبول';

  @override
  String get businessBookingsReject => 'رفض';

  @override
  String get businessBookingsRejectConfirm =>
      'رفض هذا الحجز؟ سيتم إخطار العميل.';

  @override
  String get businessBookingsConfirm => 'تأكيد الاستعداد';

  @override
  String get businessBookingsStart => 'بدء التنفيذ';

  @override
  String get businessBookingsComplete => 'إكمال';

  @override
  String get ratingsReviewsTitle => 'التقييمات';

  @override
  String get ratingsEmpty => 'لا توجد تقييمات بعد.';

  @override
  String get ratingsLeaveReview => 'أضف تقييمك';

  @override
  String get ratingsSubmit => 'إرسال التقييم';

  @override
  String get ratingsCommentHint => 'اكتب تعليقك (اختياري)';

  @override
  String get ratingsSubmitted => 'تم إرسال تقييمك بنجاح.';

  @override
  String get ratingsSelectStarsError => 'اختر عدد النجوم أولًا.';

  @override
  String get financeTitle => 'الأمور المالية';

  @override
  String get walletTitle => 'المحفظة';

  @override
  String get walletAvailableBalance => 'الرصيد المتاح';

  @override
  String get walletLockedBalance => 'رصيد محجوز';

  @override
  String get walletTransactionsTitle => 'الحركات';

  @override
  String get walletTabAll => 'الكل';

  @override
  String get walletTypeDeposit => 'إيداع';

  @override
  String get walletTypeWithdraw => 'سحب';

  @override
  String get walletTypeTransfer => 'تحويل';

  @override
  String get walletTypeHold => 'حجز';

  @override
  String get walletTypeRelease => 'تحرير';

  @override
  String get walletTypeRefund => 'استرداد';

  @override
  String get walletTypePlatformFee => 'رسوم';

  @override
  String get walletTypeAdjustment => 'تسوية';

  @override
  String get walletTransactionsEmpty => 'لا توجد حركات بعد.';

  @override
  String get walletPinCreateTitle => 'اختر رمز محفظتك';

  @override
  String walletPinCreateHint(int length) {
    return 'اختر رمز مكوّن من $length أرقام لحماية إجراءات المحفظة زي ده.';
  }

  @override
  String get walletPinEnterTitle => 'أدخل رمز محفظتك';

  @override
  String get walletPinFieldHint => 'الرمز';

  @override
  String get walletPinConfirmHint => 'تأكيد الرمز';

  @override
  String get walletPinMismatch => 'الرمزان غير متطابقين.';

  @override
  String get walletPinWrong => 'رمز خاطئ.';

  @override
  String get chatTitle => 'المحادثة';

  @override
  String get chatOpenChat => 'محادثة';

  @override
  String get chatEmpty => 'لا توجد رسائل بعد.';

  @override
  String get chatMessageHint => 'اكتب رسالة...';

  @override
  String get chatLocked => 'انتهت المحادثة ولم يعد بالإمكان إرسال رسائل.';

  @override
  String get threadAccessConsentPrompt =>
      'هل توافق على اطلاع الإدارة على هذه المحادثة عند الحاجة (مثلاً فى نزاع)؟ قرارك، فى أي وقت.';

  @override
  String get threadAccessApprove => 'أوافق';

  @override
  String get threadAccessDecline => 'لا أوافق';

  @override
  String get threadAccessStatusApproved =>
      'وافقت على اطلاع الإدارة على هذه المحادثة';

  @override
  String get threadAccessStatusDeclined =>
      'لم توافق على اطلاع الإدارة على هذه المحادثة';

  @override
  String get threadAccessSheetTitle => 'خصوصية المحادثة';

  @override
  String get agendaTitle => 'أجندتي';

  @override
  String get agendaEmpty => 'لا توجد عناصر في هذا اليوم.';

  @override
  String get agendaAddTask => 'إضافة مهمة';

  @override
  String get agendaTaskTitle => 'العنوان';

  @override
  String get agendaTaskNotes => 'ملاحظات (اختياري)';

  @override
  String get agendaStartTime => 'وقت البدء';

  @override
  String get agendaEndTime => 'وقت الانتهاء (اختياري)';

  @override
  String get agendaToday => 'اليوم';

  @override
  String get agendaDeleteConfirm => 'هل تريد حذف هذه المهمة؟';

  @override
  String get agendaTitleRequired => 'أدخل عنوان المهمة.';

  @override
  String get agendaWeekView => 'عرض الأسبوع';

  @override
  String get agendaDayView => 'عرض اليوم';

  @override
  String get agendaNothing => 'لا شيء';

  @override
  String get agendaRepeat => 'التكرار';

  @override
  String get agendaRepeatNone => 'بلا تكرار';

  @override
  String get agendaRepeatDaily => 'يومياً';

  @override
  String get agendaRepeatWeekly => 'أسبوعياً';

  @override
  String get agendaRepeatWeeks => 'عدد الأسابيع';

  @override
  String get agendaRepeatFromToday => 'يبدأ التكرار من اليوم.';

  @override
  String get agendaRemindMe => 'ذكّرني';

  @override
  String get agendaWeekdaysRequired => 'اختر يوماً واحداً على الأقل.';

  @override
  String agendaRecurringResult(int created, int skipped) {
    return 'أُضيفت $created مهمة، وتم تخطي $skipped لتعارضها مع مواعيد أخرى.';
  }

  @override
  String get agendaFeedTitle => 'مزامنة مع تقويم الهاتف';

  @override
  String get agendaFeedHint =>
      'انسخ الرابط واشترك به في تقويم جوجل أو أبل ليظهر جدولك هناك تلقائياً.';

  @override
  String get agendaFeedCopy => 'نسخ الرابط';

  @override
  String get agendaFeedCopied => 'تم نسخ الرابط.';

  @override
  String get agendaFeedRotate => 'إنشاء رابط جديد';

  @override
  String get agendaFeedRotateConfirm =>
      'الرابط القديم سيتوقف عن العمل في كل التقاويم المشتركة به. هل تريد المتابعة؟';

  @override
  String get cartShareCart => 'مشاركة السلة';

  @override
  String get cartShareInstructions =>
      'شارك هذا الرمز مع أصدقائك ليضيفوا طلباتهم:';

  @override
  String get cartShareCopied => 'تم نسخ الرمز.';

  @override
  String get cartJoinSharedCart => 'الانضمام لسلة مشتركة';

  @override
  String get cartJoinTokenHint => 'أدخل رمز المشاركة';

  @override
  String get cartJoinAction => 'انضمام';

  @override
  String get sharedCartTitle => 'سلة مشتركة';

  @override
  String get sharedCartParticipants => 'المشاركون';

  @override
  String get sharedCartAddItems => 'إضافة عناصر';

  @override
  String get sharedCartLeave => 'مغادرة السلة';

  @override
  String get sharedCartLeaveConfirm => 'هل تريد مغادرة هذه السلة المشتركة؟';

  @override
  String get sharedCartCancelCart => 'إلغاء السلة';

  @override
  String get sharedCartCancelConfirm =>
      'هل تريد إلغاء هذه السلة المشتركة بالكامل؟';

  @override
  String get sharedCartHostBadge => 'المضيف';

  @override
  String get sharedCartInviteFriend => 'ادعُ صديق';

  @override
  String get sharedCartInviteHint => 'رقم موبايله أو إيميله';

  @override
  String get sharedCartInviteAction => 'ادعُ';

  @override
  String sharedCartInviteSent(String name) {
    return 'اتبعتت الدعوة لـ $name.';
  }

  @override
  String get sharedCartShowQr => 'اعرض كود QR';

  @override
  String get sharedCartQrHint =>
      'خلّي صاحبك يمسح الكود ده بتطبيق BIM، أو أي كاميرا، عشان ينضم للسلة.';

  @override
  String get sharedCartCopyLink => 'انسخ الرابط';

  @override
  String get qrScanTitle => 'امسح كود QR';

  @override
  String get qrScanHint => 'وجّه الكاميرا على كود QR الخاص بسلة صاحبك المشتركة';

  @override
  String get qrScanCameraUnavailable =>
      'الكاميرا مش متاحة. اتأكد من إذن الكاميرا للتطبيق وحاول تاني.';

  @override
  String get deliveryAssignDriverTitle => 'اختر الدليفري';

  @override
  String get deliveryNoDriversYet => 'لم تُضِف أي دليفري إلى نشاطك بعد.';

  @override
  String get deliveryDriverOnDuty => 'متاح';

  @override
  String get deliveryDriverOffDuty => 'غير متاح';

  @override
  String deliveryDriverBusy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'يحمل $count طلبات',
      one: 'يحمل طلبًا واحدًا',
    );
    return '$_temp0';
  }

  @override
  String deliveryDriverDistance(String km) {
    return 'على بعد $km كم';
  }

  @override
  String get deliveryAssign => 'إسناد';

  @override
  String get deliveryMyDriversTitle => 'موصّليّ';

  @override
  String get deliveryTakeOffDuty => 'إيقاف مؤقت';

  @override
  String get deliveryTakeOnDuty => 'إعادة تفعيل';

  @override
  String get deliveryNearbyFreelancersSection => 'موصّلون أحرار قريبون';

  @override
  String get deliveryNearbyFreelancersHint =>
      'للعرض فقط — لا يمكنك إسناد طلب لهم مباشرة، يقبلونه بأنفسهم من قائمة الطلبات المتاحة إذا تركت الطلب بلا موصّل من فريقك.';

  @override
  String get deliveryNoNearbyFreelancers =>
      'لا يوجد موصّلون أحرار قريبون حاليًا.';

  @override
  String get deliveryLocationNeededForFreelancers =>
      'حدّد موقع نشاطك من الإعدادات لرؤية الموصّلين الأحرار القريبين.';

  @override
  String get deliveryPickupQrTitle => 'رمز الاستلام';

  @override
  String deliveryPickupQrHint(String driver) {
    return 'أظهر هذا الرمز لـ $driver عند وصوله لاستلام الطلب';
  }

  @override
  String get deliveryPickupQrHintGeneric =>
      'أظهر هذا الرمز للموصّل عند وصوله لاستلام الطلب';

  @override
  String get deliveryShowPickupQrAgain => 'إظهار كود الاستلام';

  @override
  String get deliveryDeliveryQrTitle => 'رمز التسليم';

  @override
  String get deliveryDeliveryQrHint =>
      'أظهر هذا الرمز للعميل ليؤكد استلامه لطلبه';

  @override
  String get deliveryDashboardTitle => 'التوصيل';

  @override
  String get deliveryBecomeDriverTitle => 'كن مندوب توصيل';

  @override
  String get deliveryBecomeDriverHint =>
      'سجّل لترى طلبات التوصيل المتاحة وتقبلها، أو ينضمّك أحد الأنشطة إليه مباشرة.';

  @override
  String get deliveryBecomeDriver => 'سجّل كمندوب توصيل';

  @override
  String get deliveryOnDutySwitch => 'متاح لاستلام طلبات توصيل';

  @override
  String get deliveryDeliveredCount => 'طلبات تم توصيلها';

  @override
  String get deliveryFastDeliveryCount => 'توصيل سريع ⚡';

  @override
  String get deliveryMyActiveOrders => 'طلباتي الحالية';

  @override
  String get deliveryNoActiveOrders => 'لا توجد طلبات توصيل جارية حاليًا.';

  @override
  String get deliveryScanPickupTitle => 'امسح رمز الاستلام';

  @override
  String get deliveryScanPickupHint =>
      'وجّه الكاميرا نحو رمز الاستلام الخاص بالمحل';

  @override
  String get deliveryPickupConfirmed => 'تم تأكيد الاستلام — الطلب معك الآن.';

  @override
  String get deliveryShowDeliveryQr => 'أظهر رمز التسليم للعميل';

  @override
  String get deliveryCompleted => 'اكتمل هذا الطلب.';

  @override
  String get myWorkDriverRole => 'موصّل';

  @override
  String get deliveryResetPickupCode => 'إعادة تعيين الكود';

  @override
  String get deliveryResetPickupCodeConfirm =>
      'سيتوقف الكود الحالي عن العمل ويُنشأ كود جديد. متابعة؟';

  @override
  String get deliveryAvailableOrdersTitle => 'الطلبات المتاحة';

  @override
  String get deliveryAvailableOrdersEmpty =>
      'لا توجد طلبات متاحة الآن. اسحب للتحديث.';

  @override
  String get deliveryAcceptOrder => 'قبول التوصيل';

  @override
  String get deliveryOrderAccepted => 'تم قبول الطلب — ستجده في توصيلاتي.';

  @override
  String deliveryFeeLine(String fee) {
    return 'رسوم التوصيل: $fee';
  }

  @override
  String deliveryOrderTotalLine(String total) {
    return 'إجمالي الطلب: $total';
  }

  @override
  String get deliveryFeeSettingsTitle => 'رسوم التوصيل';

  @override
  String get deliveryFeeBusinessHint =>
      'مبلغ ثابت يُضاف تلقائيًا على فاتورة العميل عند اختيار التوصيل. اتركه فارغًا لتوصيل مجاني.';

  @override
  String get deliveryFeeDriverHint =>
      'مبلغ ثابت تطلبه كموصّل حر. يُطبَّق فقط لو لم يحدد المحل رسومًا للتوصيل، ولا يغيّر رسومًا حددها المحل.';

  @override
  String get deliveryFeeAmountLabel => 'رسوم التوصيل';

  @override
  String get deliveryFeeSaved => 'تم حفظ رسوم التوصيل.';

  @override
  String get deliveryFeeInvalid => 'أدخل مبلغًا صحيحًا.';

  @override
  String get deliveryFeeClear => 'بلا رسوم';

  @override
  String get paymentConfirmDriverButton => 'تأكيد استلام رسوم التوصيل نقدًا';

  @override
  String get paymentConfirmDriverConfirmed => 'تم تأكيد استلام رسوم التوصيل';

  @override
  String get deliveryCustomerSection => 'العميل';

  @override
  String get deliveryOpenInMaps => 'افتح في الخرائط';

  @override
  String get deliveryCalculateDistance => 'احسب المسافة';

  @override
  String deliveryDistanceValue(String km) {
    return 'المسافة: $km كم';
  }

  @override
  String get deliverySendEtaToCustomer => 'إرسال الموعد المتوقع للعميل';

  @override
  String get deliveryEtaDialogTitle => 'تحديد الموعد المتوقع للتسليم';

  @override
  String get deliveryEtaInMinutes => 'خلال (دقائق)';

  @override
  String get deliveryEtaAtTime => 'اختر وقتًا محددًا';

  @override
  String get deliveryEtaSent => 'تم إرسال الموعد المتوقع للعميل.';

  @override
  String get deliveryScanReceiptTitle => 'امسح لتأكيد الاستلام';

  @override
  String get deliveryScanReceiptHint =>
      'وجّه الكاميرا نحو رمز التسليم الخاص بالمندوب';

  @override
  String get deliveryReceiptConfirmed => 'تم تأكيد الاستلام — شكرًا لك!';

  @override
  String get sharedCartInviteGroup => 'ادعُ مجموعة';

  @override
  String get sharedCartNoGroupsYet =>
      'لسه معملتش أي مجموعة تواصل. اعمل واحدة الأول من القائمة الجانبية.';

  @override
  String sharedCartGroupInviteSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'اتبعتت الدعوة لـ $count شخص.',
      many: 'اتبعتت الدعوة لـ $count شخصًا.',
      few: 'اتبعتت الدعوة لـ $count أشخاص.',
      two: 'اتبعتت الدعوة لشخصين.',
      one: 'اتبعتت الدعوة لشخص واحد.',
      zero: 'محدش جديد يتدعى — كلهم موجودين بالفعل.',
    );
    return '$_temp0';
  }

  @override
  String get sharedCartSelectMembers => 'اختار مين تحب تدعوه';

  @override
  String get sharedCartSelectAll => 'اختار الكل';

  @override
  String get contactGroupsTitle => 'مجموعات التواصل';

  @override
  String get contactGroupsEmpty =>
      'لسه معملتش أي مجموعة تواصل. اعمل واحدة عشان تدعو نفس الدائرة من الأصدقاء لسلة مشتركة دفعة واحدة.';

  @override
  String get contactGroupsCreate => 'مجموعة جديدة';

  @override
  String get contactGroupNameHint => 'زي: العيلة، أصدقاء دمياط';

  @override
  String get commonCreate => 'إنشاء';

  @override
  String contactGroupMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عضو',
      many: '$count عضوًا',
      few: '$count أعضاء',
      two: 'عضوان',
      one: 'عضو واحد',
      zero: 'لا يوجد أعضاء',
    );
    return '$_temp0';
  }

  @override
  String get contactGroupAddMember => 'إضافة عضو';

  @override
  String get contactGroupAddAction => 'إضافة';

  @override
  String get contactGroupRename => 'إعادة تسمية المجموعة';

  @override
  String get contactGroupDeleteConfirm =>
      'هل تريد حذف هذه المجموعة؟ ده مش بيأثر على أي سلة اتشاركت قبل كده.';

  @override
  String get contactGroupNoMembers =>
      'لسه مفيش أعضاء. أضف حد برقم موبايله أو إيميله.';

  @override
  String get businessGroupsTitle => 'مجموعات العروض';

  @override
  String get businessGroupsEmpty =>
      'لا توجد مجموعات بعد. أنشئ مجموعة لاستهداف نفس دائرة الأنشطة بعروضك دفعة واحدة.';

  @override
  String get businessGroupsCreate => 'مجموعة جديدة';

  @override
  String get businessGroupNameHint => 'مثال: محلات الخضار، مصانع الأثاث';

  @override
  String get businessGroupRename => 'إعادة تسمية المجموعة';

  @override
  String get businessGroupDeleteConfirm =>
      'حذف هذه المجموعة؟ لن يؤثر هذا على أي منتج قيّدته لها بالفعل.';

  @override
  String get businessGroupNoMembers => 'لا توجد أنشطة بعد. أضف نشاطًا بالبحث.';

  @override
  String get businessGroupAddToOffersGroup => 'إضافة إلى مجموعة عروض';

  @override
  String businessGroupMemberAdded(String business, String group) {
    return 'تمت إضافة $business إلى \"$group\".';
  }

  @override
  String get retailListingAddBusinessGroup => 'إضافة مجموعة';

  @override
  String get retailListingBusinessGroupPickerTitle => 'اختر مجموعة أنشطة';

  @override
  String get retailListingBusinessGroupPickerEmpty => 'لا توجد مجموعات بعد.';

  @override
  String get staffTeamSettingsTitle => 'إعدادات الموظفين';

  @override
  String get staffTitle => 'الموظفون';

  @override
  String get staffEmpty => 'لا يوجد موظفون بعد.';

  @override
  String get staffAdd => 'إضافة موظف';

  @override
  String get staffEdit => 'تعديل الموظف';

  @override
  String get staffPhone => 'رقم هاتف الموظف';

  @override
  String get staffJobTitle => 'المسمى الوظيفي (اختياري)';

  @override
  String get staffCapabilities => 'الصلاحيات';

  @override
  String get staffCapabilitiesRequired => 'اختر صلاحية واحدة على الأقل.';

  @override
  String get staffActive => 'نشط';

  @override
  String get staffInactiveBadge => 'غير نشط';

  @override
  String get staffPendingBadge => 'بانتظار القبول';

  @override
  String get staffInvitationsTitle => 'دعوات العمل';

  @override
  String get staffInvitationsEmpty => 'لا توجد دعوات بانتظار ردك.';

  @override
  String get staffInvitationAccept => 'قبول';

  @override
  String get staffInvitationDecline => 'رفض';

  @override
  String get staffInvitationAccepted => 'تم قبول الدعوة.';

  @override
  String get staffInvitationDeclined => 'تم رفض الدعوة.';

  @override
  String get staffInvitationSentTitle => 'تم إرسال الدعوة';

  @override
  String get staffInvitationSentPending => 'بانتظار قبول الموظف للانضمام.';

  @override
  String get staffRemove => 'إزالة';

  @override
  String get staffRemoveConfirm => 'هل تريد إزالة هذا الموظف؟';

  @override
  String get staffPhoneRequired => 'أدخل رقم هاتف الموظف.';

  @override
  String get staffActivityTitle => 'سجل نشاط الموظفين';

  @override
  String get staffActivityEmpty => 'لا يوجد نشاط في هذه الفترة.';

  @override
  String get staffActivityFrom => 'من';

  @override
  String get staffActivityTo => 'إلى';

  @override
  String get staffActivityToday => 'اليوم';

  @override
  String get staffActivityFilter => 'فلترة';

  @override
  String get staffActivityStaffLabel => 'الموظف';

  @override
  String get staffActivityAllStaff => 'الجميع';

  @override
  String get staffActivityOwnerBadge => 'صاحب النشاط';

  @override
  String staffActivityOperationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عملية',
      many: '$count عملية',
      few: '$count عمليات',
      two: 'عمليتان',
      one: 'عملية واحدة',
      zero: 'لا عمليات في هذه الفترة',
    );
    return '$_temp0';
  }

  @override
  String get staffActivityActionAccepted => 'قبِل';

  @override
  String get staffActivityActionRejected => 'رفض';

  @override
  String get staffActivityActionPreparing => 'بدأ التجهيز';

  @override
  String get staffActivityActionReady => 'جهّز';

  @override
  String get staffActivityActionCompleted => 'أكمل';

  @override
  String get staffActivityActionStarted => 'بدأ التنفيذ';

  @override
  String get staffActivityActionConfirmed => 'أكّد الاستعداد';

  @override
  String get staffActivityActionItemUnavailable => 'أبلغ عن نفاد صنف';

  @override
  String get staffActivitySubjectOrder => 'طلب';

  @override
  String get staffActivitySubjectBooking => 'حجز';

  @override
  String get staffGroupsTitle => 'فرق العمل';

  @override
  String get staffGroupsEmptyGroup => 'لا يوجد أحد فى هذه المجموعة.';

  @override
  String get staffAssignTask => 'طلبه لمهمة';

  @override
  String get staffAttendancePresent => 'حاضر الآن';

  @override
  String get staffAttendanceCheckedOut => 'انصرف';

  @override
  String get staffAttendanceNotCheckedIn => 'لم يسجّل حضوره اليوم';

  @override
  String staffAttendancePresentSince(String time) {
    return 'حاضر منذ $time';
  }

  @override
  String staffAttendanceCheckedOutAt(String time) {
    return 'انصرف في $time';
  }

  @override
  String get myWorkTitle => 'أعمالي';

  @override
  String get myWorkEmpty => 'لا تعمل لدى أى نشاط تجارى حاليًا.';

  @override
  String get attendanceCheckIn => 'تسجيل حضور';

  @override
  String get attendanceCheckOut => 'تسجيل انصراف';

  @override
  String get attendanceVerificationSettingsTitle => 'التحقق من الحضور';

  @override
  String get attendanceVerificationToggleLabel => 'التحقق بالموقع وكود QR';

  @override
  String get attendanceVerificationToggleHint =>
      'عند التفعيل، يحتاج الموظف لمسح كود من شاشة فى مقر النشاط والتواجد بالقرب منه لتسجيل الحضور أو الانصراف.';

  @override
  String get attendanceOpenDisplayScreen => 'فتح شاشة تسجيل الحضور';

  @override
  String get attendanceQrDisplayTitle => 'شاشة تسجيل الحضور';

  @override
  String get attendanceQrDisplayHint =>
      'اطلب من الموظف مسح هذا الكود لتسجيل الحضور أو الانصراف — يتجدد الكود تلقائيًا';

  @override
  String get attendanceScanQrTitle => 'امسح كود الحضور';

  @override
  String get attendanceScanQrHint =>
      'وجّه الكاميرا على كود الحضور المعروض فى مقر العمل';

  @override
  String get attendanceLocationRequired =>
      'التحقق من الحضور يحتاج إذن الوصول لموقعك.';

  @override
  String get finesTitle => 'الغرامات';

  @override
  String get finesEmpty => 'لا توجد غرامات.';

  @override
  String get finesFrozenAmount => 'المبلغ المجمّد';

  @override
  String get finesCollectedAmount => 'المبلغ المحصَّل';

  @override
  String get finesAppealStatementHint => 'اكتب سبب اعتراضك';

  @override
  String get finesSubmitAppeal => 'تقديم الاعتراض';

  @override
  String get finesAppealSubmitted => 'تم تقديم اعتراضك، سيُراجَع قريبًا.';

  @override
  String get finesAppealPending => 'اعتراضك قيد المراجعة.';

  @override
  String get finesAppealStatementRequired => 'اكتب سبب اعتراضك أولًا.';

  @override
  String get finesStatusFrozen => 'مجمّدة (نافذة اعتراض)';

  @override
  String get finesStatusAppealed => 'قيد الاعتراض';

  @override
  String get finesStatusUpheld => 'مؤيَّدة (مستحقة الخصم)';

  @override
  String get finesStatusOverturned => 'ملغاة باعتراض';

  @override
  String get finesStatusCollected => 'محصَّلة';

  @override
  String get finesStatusCancelled => 'ملغاة';

  @override
  String get projectsTitle => 'المشاريع';

  @override
  String get projectsEmpty => 'لا توجد مشاريع بعد.';

  @override
  String get projectTasksEmpty => 'لا توجد مهام بعد.';

  @override
  String get projectsAdd => 'مشروع جديد';

  @override
  String get projectTitleLabel => 'عنوان المشروع';

  @override
  String get projectDescription => 'الوصف (اختياري)';

  @override
  String get projectReference => 'المرجع (اختياري)';

  @override
  String get projectStartsOn => 'تاريخ البدء (اختياري)';

  @override
  String get projectDueOn => 'الموعد النهائي (اختياري)';

  @override
  String get projectTitleRequired => 'أدخل عنوان المشروع.';

  @override
  String get projectOverdueBadge => 'متأخر';

  @override
  String get projectTasksTitle => 'المهام';

  @override
  String get projectAddTask => 'إضافة مهمة';

  @override
  String get projectDeleteConfirm =>
      'هل تريد حذف هذا المشروع؟ سيتم حذف كل مهامه.';

  @override
  String get taskTitleLabel => 'عنوان المهمة';

  @override
  String get taskNotes => 'ملاحظات (اختياري)';

  @override
  String get taskRequiresPhoto => 'يتطلب صورة إثبات عند الإنهاء';

  @override
  String get taskTitleRequired => 'أدخل عنوان المهمة.';

  @override
  String get taskCriticalBadge => 'حرجة';

  @override
  String get taskDeleteConfirm => 'هل تريد حذف هذه المهمة؟';

  @override
  String get taskProgressLabel => 'نسبة الإنجاز';

  @override
  String get taskMarkDone => 'تحديد كمكتملة';

  @override
  String get projectStatusPlanning => 'تخطيط';

  @override
  String get projectStatusActive => 'نشط';

  @override
  String get projectStatusOnHold => 'متوقف مؤقتًا';

  @override
  String get projectStatusCompleted => 'مكتمل';

  @override
  String get projectStatusCancelled => 'ملغي';

  @override
  String get taskStatusPending => 'قيد الانتظار';

  @override
  String get taskStatusInProgress => 'جارٍ التنفيذ';

  @override
  String get taskStatusBlocked => 'معلّقة';

  @override
  String get taskStatusDone => 'مكتملة';

  @override
  String get projectProgressTitle => 'تقدّم المشروع';

  @override
  String get projectProgressEmpty => 'لا توجد خطة تقدّم لهذه العملية بعد.';

  @override
  String get projectViewProgress => 'عرض تقدّم المشروع';

  @override
  String get tripSearchTitle => 'بحث الرحلات';

  @override
  String get tripOrigin => 'من';

  @override
  String get tripDestination => 'إلى';

  @override
  String get tripChooseGovernorate => 'اختر المحافظة';

  @override
  String get tripDateOptional => 'التاريخ (اختياري)';

  @override
  String get tripSearchAction => 'بحث';

  @override
  String get tripSearchEmpty => 'لا توجد رحلات مطابقة.';

  @override
  String get tripSearchFieldsRequired => 'اختر محافظتي الانطلاق والوصول.';

  @override
  String get tripReserve => 'حجز';

  @override
  String get tripUnits => 'عدد الوحدات';

  @override
  String get tripReservationNotes => 'ملاحظات (اختياري)';

  @override
  String get tripReserved => 'تم إنشاء الحجز، بانتظار تأكيد الناقل.';

  @override
  String get myReservationsTitle => 'حجوزات الرحلات';

  @override
  String get myReservationsEmpty => 'لا توجد حجوزات بعد.';

  @override
  String get tripReservationCancel => 'إلغاء الحجز';

  @override
  String get tripReservationCancelConfirm => 'هل تريد إلغاء هذا الحجز؟';

  @override
  String get tripReservationCancelled => 'تم إلغاء الحجز.';

  @override
  String get tripStatusPending => 'بانتظار التأكيد';

  @override
  String get tripStatusConfirmed => 'مؤكد';

  @override
  String get tripStatusCompleted => 'مكتمل';

  @override
  String get tripStatusCancelled => 'ملغي';

  @override
  String get tripStatusBlocked => 'حجز يدوي';

  @override
  String get tripModeFreight => 'شحن بضائع';

  @override
  String get tripModePassenger => 'نقل ركاب';

  @override
  String get tripModeLimousine => 'ليموزين';

  @override
  String get tripModeDistribution => 'توزيع';

  @override
  String get clinicBookAppointment => 'حجز موعد';

  @override
  String get billVisitFee => 'رسم الزيارة';

  @override
  String get billServices => 'تكلفة الخدمات';

  @override
  String get billServicesAfterVisit =>
      'تظهر تكلفة الخدمات بعد الانتهاء من الزيارة، ويمكن زيادتها أو إنقاصها.';

  @override
  String get billTotal => 'الإجمالي';

  @override
  String get billPaid => 'المدفوع';

  @override
  String get billRemaining => 'المتبقي';

  @override
  String get billRecordPayment => 'تسجيل دفعة';

  @override
  String get billAmount => 'المبلغ';

  @override
  String get billKindVisitFee => 'رسم الزيارة';

  @override
  String get billKindService => 'خدمة';

  @override
  String get billNote => 'ملاحظة (اختياري)';

  @override
  String get billFinalPrice => 'السعر النهائي';

  @override
  String get billFinalPriceHint => 'اتركه فارغاً للسعر المُعلَن';

  @override
  String get billSave => 'حفظ';

  @override
  String get billConfirm => 'تأكيد';

  @override
  String get billDispute => 'اعتراض';

  @override
  String get billDisputeNote => 'ما الذي تعترض عليه؟ (اختياري)';

  @override
  String get billConfirmed => 'مؤكَّدة من المريض';

  @override
  String get billDisputed => 'اعترض عليها المريض';

  @override
  String get billAwaitingYou => 'بانتظار تأكيدك';

  @override
  String get billAwaitingPatient => 'بانتظار تأكيد المريض';

  @override
  String get billNextInstallment => 'القسط عند الجلسة القادمة';

  @override
  String get billInstallmentHint => 'اتركه فارغًا لطلب كل المتبقي';

  @override
  String get billCarriedOver => 'قسط مستحق';

  @override
  String billCarriedOverLine(String amount, String due) {
    return 'متبقٍ على المريض $amount من زيارات سابقة — يُطلب $due مع هذه الجلسة.';
  }

  @override
  String get billOwedTitle => 'مستحق من زيارات سابقة';

  @override
  String billOwedBody(String amount, String due) {
    return 'عليك متبقٍ $amount لهذه العيادة — يُطلب $due مع موعدك القادم.';
  }

  @override
  String get clinicKindNoSlots => 'لا مواعيد متاحة لهذا النوع الآن';

  @override
  String get clinicPickService => 'الخدمات المطلوبة (اختياري)';

  @override
  String get clinicPickKind => 'نوع الزيارة';

  @override
  String get clinicRequestBooking => 'اطلب الحجز';

  @override
  String get clinicPatientLabel => 'المريض';

  @override
  String get clinicForMe => 'لي';

  @override
  String get clinicForOther => 'لشخص آخر';

  @override
  String get clinicAttendeeName => 'اسم المريض';

  @override
  String get clinicAttendeePhone => 'رقم الهاتف (اختياري)';

  @override
  String clinicAttendeeFor(Object name) {
    return 'لـ $name';
  }

  @override
  String get clinicNoOpenSlots => 'لا توجد فترات متاحة حاليًا.';

  @override
  String get clinicPickDay => 'اليوم';

  @override
  String get clinicPickTime => 'الوقت';

  @override
  String get clinicPickSlotHint => 'اختر يومًا ووقتًا للحجز';

  @override
  String get clinicBookSlot => 'حجز الموعد';

  @override
  String get clinicReasonHint => 'سبب الزيارة (اختياري)';

  @override
  String get clinicAppointmentBooked => 'تم حجز الموعد.';

  @override
  String get myClinicAppointmentsTitle => 'مواعيد العيادة';

  @override
  String get myClinicAppointmentsEmpty => 'لا توجد مواعيد بعد.';

  @override
  String get clinicAppointmentCancel => 'إلغاء الموعد';

  @override
  String get clinicAppointmentCancelConfirm => 'هل تريد إلغاء هذا الموعد؟';

  @override
  String get clinicAppointmentCancelled => 'تم إلغاء الموعد.';

  @override
  String get clinicStatusRequested => 'بانتظار التأكيد';

  @override
  String get clinicStatusConfirmed => 'مؤكد';

  @override
  String get clinicStatusCompleted => 'مكتمل';

  @override
  String get clinicStatusCancelled => 'ملغي';

  @override
  String get clinicStatusNoShow => 'لم يحضر';

  @override
  String get trainingPlansTitle => 'خطط التدريب';

  @override
  String get trainingPlansEmpty => 'لا توجد خطط تدريب بعد.';

  @override
  String get trainingStatusActive => 'نشطة';

  @override
  String get trainingStatusPaused => 'متوقفة مؤقتًا';

  @override
  String get trainingStatusCompleted => 'مكتملة';

  @override
  String get trainingStatusCancelled => 'ملغاة';

  @override
  String get trainingTabExercises => 'التمارين';

  @override
  String get trainingPlanPendingPrompt => 'خطة تدريب جديدة بانتظار قبولك';

  @override
  String get trainingPlanAccepted => 'تم قبول الخطة.';

  @override
  String get trainingPlanDeclined => 'تم رفض الخطة.';

  @override
  String get trainingTabMeals => 'الوجبات';

  @override
  String get trainingTabProgress => 'التقدّم';

  @override
  String get trainingTabBodyReports => 'تقارير الجسم';

  @override
  String get trainingExercisesEmpty => 'لا توجد تمارين بعد.';

  @override
  String get trainingMealsEmpty => 'لا توجد وجبات بعد.';

  @override
  String get trainingSetsLabel => 'المجموعات';

  @override
  String get trainingRepsLabel => 'التكرارات';

  @override
  String get trainingRestLabel => 'الراحة';

  @override
  String get trainingCompleteRound => 'إتمام جولة';

  @override
  String get trainingRoundCompleted => 'تم تسجيل الجولة.';

  @override
  String get trainingAllRoundsDone => 'اكتملت كل الجولات اليوم';

  @override
  String get trainingLogProgress => 'تسجيل التقدّم';

  @override
  String get trainingWeightHint => 'الوزن (كجم)';

  @override
  String get trainingNotesHint => 'ملاحظات (اختياري)';

  @override
  String get trainingProgressLogged => 'تم تسجيل تقدّمك.';

  @override
  String get trainingProgressEmpty => 'لا توجد تسجيلات بعد.';

  @override
  String get trainingWeeklySummaryTitle => 'هذا الأسبوع';

  @override
  String get trainingAdherence => 'الالتزام';

  @override
  String get trainingTargetRounds => 'الجولات المستهدفة';

  @override
  String get trainingCompletedRoundsLabel => 'الجولات المكتملة';

  @override
  String get trainingActiveDays => 'أيام النشاط';

  @override
  String get trainingCheckIns => 'عدد التسجيلات';

  @override
  String get trainingLatestWeight => 'آخر وزن';

  @override
  String get trainingBodyReportsEmpty => 'لا توجد قراءات مسجلة بعد.';

  @override
  String get mealBreakfast => 'الإفطار';

  @override
  String get mealLunch => 'الغداء';

  @override
  String get mealDinner => 'العشاء';

  @override
  String get mealSnack => 'سناك';

  @override
  String get bodyReportWeight => 'الوزن';

  @override
  String get bodyReportMuscle => 'الكتلة العضلية';

  @override
  String get bodyReportFat => 'نسبة الدهون';

  @override
  String get bodyReportWater => 'نسبة الماء';

  @override
  String get bodyReportBone => 'كتلة العظام';

  @override
  String get bodyReportVisceralFat => 'الدهون الحشوية';

  @override
  String get prescriptionsTitle => 'الروشتات';

  @override
  String get prescriptionsEmpty => 'لا توجد روشتات بعد.';

  @override
  String get prescriptionStatusRequested => 'بانتظار رد الصيدلية';

  @override
  String get prescriptionStatusQuoted => 'عرض سعر جاهز';

  @override
  String get medicineRequestTitle => 'طلب دواء بدون روشتة';

  @override
  String get medicineRequestDirectLabel => 'طلب دواء مباشر';

  @override
  String get medicineRequestExplainer =>
      'لو مش قادر تقرأ اسم الدواء بالظبط، ابعت صورة الروشتة أو اكتب اللي محتاجه، والصيدلية هترد عليك بالأصناف والسعر.';

  @override
  String get medicineRequestPharmacyLabel => 'الصيدلية';

  @override
  String get medicineRequestPickPharmacyTitle => 'اختر صيدلية';

  @override
  String get medicineRequestNoteLabel => 'ملاحظة (اختياري لو أرفقت صورة)';

  @override
  String get medicineRequestNoteHint => 'مثال: محتاج حاجة للصداع والكحة';

  @override
  String get medicineRequestAttachPhoto => 'إرفاق صورة الروشتة';

  @override
  String get medicineRequestChangePhoto => 'تغيير الصورة';

  @override
  String get medicineRequestTakePhoto => 'التقاط صورة';

  @override
  String get medicineRequestChooseFromGallery => 'اختيار من المعرض';

  @override
  String get medicineRequestSubmit => 'إرسال الطلب';

  @override
  String get medicineRequestNeedsNoteOrPhoto =>
      'اكتب ملاحظة أو أرفق صورة الروشتة.';

  @override
  String get medicineRequestCustomerNoteLabel => 'ملاحظة العميل';

  @override
  String get medicineRequestQuoteTitle => 'تسعير الطلب';

  @override
  String get medicineRequestQuoteAction => 'تسعير الطلب';

  @override
  String get medicineRequestAddLine => 'إضافة صنف';

  @override
  String get medicineRequestNeedsOneLine => 'أضف صنفًا واحدًا على الأقل.';

  @override
  String get medicineRequestQuoted => 'تم إرسال السعر.';

  @override
  String get medicineRequestDeclineTitle => 'رفض الطلب';

  @override
  String get medicineRequestDeclineNoteHint => 'سبب الرفض (اختياري)';

  @override
  String get medicineRequestDeclineAction => 'رفض الطلب';

  @override
  String get medicineRequestDeclined => 'تم رفض الطلب.';

  @override
  String get medicineRequestConfirmAction => 'تأكيد السعر والموافقة';

  @override
  String get medicineRequestConfirmed => 'تم تأكيد الطلب — جارٍ تجهيزه.';

  @override
  String get prescriptionStatusIssued => 'صدرت';

  @override
  String get prescriptionStatusSent => 'أُرسلت للصيدلية';

  @override
  String get prescriptionStatusPreparing => 'قيد التجهيز';

  @override
  String get prescriptionStatusReady => 'جاهزة';

  @override
  String get prescriptionStatusDispensed => 'تم الصرف';

  @override
  String get prescriptionStatusCancelled => 'ملغاة';

  @override
  String get prescriptionDiagnosisLabel => 'التشخيص';

  @override
  String get prescriptionConditionLabel => 'حالة المريض';

  @override
  String get prescriptionNotesLabel => 'ملاحظات';

  @override
  String get prescriptionPharmacyLabel => 'الصيدلية';

  @override
  String get prescriptionMedicineTotalLabel => 'الإجمالي';

  @override
  String get prescriptionSharedWithTitle => 'تمت مشاركتها مع';

  @override
  String get prescriptionItemsTitle => 'الأدوية';

  @override
  String get prescriptionDosageLabel => 'الجرعة';

  @override
  String get prescriptionQuantityLabel => 'الكمية';

  @override
  String get prescriptionFoodBefore => 'قبل الأكل';

  @override
  String get prescriptionFoodWith => 'مع الأكل';

  @override
  String get prescriptionFoodAfter => 'بعد الأكل';

  @override
  String get prescriptionSlotMorning => 'الصباح';

  @override
  String get prescriptionSlotEvening => 'المساء';

  @override
  String get prescriptionDurationDays => 'يوم/أيام';

  @override
  String get prescriptionDurationWeeks => 'أسبوع/أسابيع';

  @override
  String get prescriptionDurationMonths => 'شهر/أشهر';

  @override
  String get prescriptionImagesTitle => 'الصور';

  @override
  String get prescriptionSendToPharmacy => 'إرسال إلى صيدلية';

  @override
  String get prescriptionSent => 'تم إرسال الوصفة إلى الصيدلية.';

  @override
  String get prescriptionFulfillmentDelivery => 'توصيل';

  @override
  String get prescriptionFulfillmentPickup => 'استلام';

  @override
  String get prescriptionDeliveryAddressHint => 'عنوان التوصيل';

  @override
  String get prescriptionCancel => 'إلغاء الوصفة';

  @override
  String get prescriptionCancelConfirm => 'إلغاء هذه الوصفة؟';

  @override
  String get prescriptionCancelled => 'تم إلغاء الوصفة.';

  @override
  String get prescriptionScheduleReminders => 'جدولة التذكيرات';

  @override
  String get prescriptionRemindersLabel => 'تذكيرًا تمت جدولتها';

  @override
  String get prescriptionShareWithDoctor => 'مشاركة مع طبيب آخر';

  @override
  String get prescriptionShared => 'تمت مشاركة الوصفة.';

  @override
  String get prescriptionSendPickPharmacyTitle => 'اختر صيدلية';

  @override
  String get prescriptionSharePickDoctorTitle => 'اختر طبيبًا';

  @override
  String get prescriptionSupersededLabel => 'استُبدلت بنسخة معدّلة';

  @override
  String get prescriptionRemovePhotoConfirm => 'حذف هذه الصورة؟';

  @override
  String get offersTitle => 'العروض';

  @override
  String get offersEmpty => 'لا توجد عروض الآن.';

  @override
  String get offersAllCategories => 'الكل';

  @override
  String get offersOpenNow => 'مفتوح الآن';

  @override
  String get offersSearchHint => 'ابحث عن عرض...';

  @override
  String get offerSortBoosted => 'مميز';

  @override
  String get offerSortLatest => 'الأحدث';

  @override
  String get offerSortLowestPrice => 'الأقل سعرًا';

  @override
  String get offerFollowBusiness => 'متابعة هذا البائع';

  @override
  String get offerUnfollowBusiness => 'إلغاء المتابعة';

  @override
  String get offerFollowed => 'سنخبرك بعروض هذا البائع القادمة.';

  @override
  String get offerUnfollowed => 'تم إلغاء المتابعة.';

  @override
  String get myOfferFollowsTitle => 'البائعون المتابَعون';

  @override
  String get myOfferFollowsEmpty => 'لا تتابع أي بائع بعد.';

  @override
  String get offerAvailableQuantityLabel => 'الكمية المتاحة';

  @override
  String get offerEndsAtLabel => 'ينتهى';

  @override
  String get disputesTitle => 'نزاعاتي';

  @override
  String get disputesEmpty => 'لا توجد نزاعات.';

  @override
  String get disputeStatusOpen => 'مفتوح';

  @override
  String get disputeStatusMutualResolution => 'فترة التراضي';

  @override
  String get disputeStatusUnderReview => 'قيد التحكيم';

  @override
  String get disputeStatusResolved => 'تم الفصل';

  @override
  String get disputeStatusClosed => 'مغلق';

  @override
  String get disputeStatusCancelled => 'ملغى';

  @override
  String get disputeStatusExpired => 'منتهي';

  @override
  String get disputeRoleOpener => 'أنت من فتح هذا النزاع';

  @override
  String get disputeRoleRespondent => 'فُتح ضدك';

  @override
  String get disputeReasonNotDelivered => 'لم يُسلَّم';

  @override
  String get disputeReasonNotAsDescribed => 'غير مطابق للوصف';

  @override
  String get disputeReasonQuality => 'مشكلة في الجودة';

  @override
  String get disputeReasonLate => 'تأخير';

  @override
  String get disputeReasonCancelledByBusiness => 'ألغاه النشاط التجاري';

  @override
  String get disputeReasonNoShow => 'لم يحضر';

  @override
  String get disputeReasonOvercharged => 'تحصيل زائد';

  @override
  String get disputeReasonDamage => 'تلف';

  @override
  String get disputeReasonOther => 'أخرى';

  @override
  String get disputeOpenTitle => 'الإبلاغ عن مشكلة';

  @override
  String get disputeReasonLabel => 'السبب';

  @override
  String get disputeDetailsHint => 'تفاصيل إضافية (اختياري)';

  @override
  String get disputeOpened => 'تم فتح النزاع.';

  @override
  String get disputeCooperate => 'أنا منخرط فى التسوية';

  @override
  String get disputeCooperated => 'تم التسجيل كمنخرط.';

  @override
  String get disputeRequestArbitration => 'طلب التحكيم';

  @override
  String get disputeArbitrationRequested => 'تم طلب التحكيم.';

  @override
  String get disputeArbitrationFeeLabel => 'رسم الجلسة';

  @override
  String get disputeArbitrationBalanceLabel => 'رصيدك';

  @override
  String get disputeAgreeSettlement => 'اتفقنا — إنهاء النزاع';

  @override
  String get disputeWithdrawSettlement => 'سحب الموافقة';

  @override
  String get disputeSettlementAgreed => 'تم تسجيل الموافقة.';

  @override
  String get disputeSettlementWithdrawn => 'تم سحب الموافقة.';

  @override
  String get disputeSettlementCompleteLabel =>
      'وافق الطرفان — تمت تسوية النزاع.';

  @override
  String get disputeSettlementWaitingLabel => 'بانتظار موافقة الطرف الآخر.';

  @override
  String get disputeCounterpartyLabel => 'الطرف الآخر';

  @override
  String get disputeCooperationTitle => 'الانخراط فى التسوية';

  @override
  String get disputeCooperationClientLabel => 'العميل';

  @override
  String get disputeCooperationBusinessLabel => 'النشاط التجاري';

  @override
  String get disputeCooperationPending => 'لم يحدث بعد';

  @override
  String get disputeMyObligationsTitle => 'ما عليّ في هذا النزاع';

  @override
  String get disputeObligationsTitle => 'مستحقات النزاعات';

  @override
  String get disputeSettleObligations => 'السداد من المحفظة';

  @override
  String get disputeObligationSettled => 'تم السداد.';

  @override
  String get disputeObligationsBlockedNotice =>
      'عليك مستحقات نزاعات غير مسددة تمنعك من عمليات جديدة.';

  @override
  String get disputeOwedByMeTitle => 'عليّ';

  @override
  String get disputeOwedToMeTitle => 'لي';

  @override
  String get disputeObligationsEmpty => 'لا يوجد مستحق.';

  @override
  String get disputeClosePurgeAction => 'حذف هذه المحادثة';

  @override
  String get disputeClosurePurgeConfirm =>
      'حذف هذه المحادثة نهائيًا؟ يبقى سجل الحكم فقط.';

  @override
  String get disputeClosurePurged => 'تم الطلب.';

  @override
  String get disputeRoomTitle => 'غرفة النزاع';

  @override
  String get disputeConductTitle => 'قواعد الغرفة';

  @override
  String get disputeConductAccept => 'أوافق';

  @override
  String get disputeConductDecline => 'لا أوافق';

  @override
  String get disputeRoomLocked => 'هذه الغرفة مغلقة.';

  @override
  String get disputeRoomPurgedNotice => 'تم حذف هذه المحادثة.';

  @override
  String get disputeSettlementPaymentsTitle => 'دفع خارج المنصة';

  @override
  String get disputeProposePayment => 'اقتراح دفعة';

  @override
  String get disputePayerLabel => 'من يدفع';

  @override
  String get disputePayerClient => 'العميل';

  @override
  String get disputePayerBusiness => 'النشاط التجاري';

  @override
  String get disputeAmountHint => 'المبلغ';

  @override
  String get disputeMethodHint => 'وسيلة الدفع (اختياري)';

  @override
  String get disputeNoteHint => 'ملاحظة (اختياري)';

  @override
  String get disputePropose => 'اقتراح';

  @override
  String get disputeAccept => 'قبول';

  @override
  String get disputeReject => 'رفض';

  @override
  String get disputeConfirmReceived => 'تأكيد الاستلام';

  @override
  String get disputeWithdraw => 'سحب';

  @override
  String get disputeNoSettlementPayments => 'لا توجد مقترحات دفع بعد.';

  @override
  String get disputeHistoryTitle => 'السجل';

  @override
  String get addressesTitle => 'عناويني';

  @override
  String get addressesEmpty => 'لا توجد عناوين محفوظة بعد.';

  @override
  String get addressAddTitle => 'إضافة عنوان';

  @override
  String get addressEditTitle => 'تعديل العنوان';

  @override
  String get addressLineHint => 'الشارع، المبنى، الدور...';

  @override
  String get addressZipHint => 'الرمز البريدي (اختياري)';

  @override
  String get addressMakePrimary => 'اجعله العنوان الأساسي';

  @override
  String get addressDeleteConfirm => 'حذف هذا العنوان؟';

  @override
  String get addressPickTitle => 'اختر عنوان التوصيل';

  @override
  String get addressUseNewLabel => 'كتابة عنوان آخر';

  @override
  String get commentsTitle => 'التعليقات';

  @override
  String get commentsEmpty => 'لا توجد تعليقات بعد.';

  @override
  String get commentComposeHint => 'أضف تعليقًا...';

  @override
  String get commentReplyHint => 'اكتب ردًا...';

  @override
  String get commentPrivateToggle => 'يظهر لصاحب المنشور فقط';

  @override
  String get commentPrivateBadge => 'خاص';

  @override
  String get commentRepliesLabel => 'ردود';

  @override
  String get commentViewReplies => 'عرض الردود';

  @override
  String get commentHideReplies => 'إخفاء الردود';

  @override
  String get commentReplyAction => 'رد';

  @override
  String get commentEditAction => 'تعديل';

  @override
  String get commentDeleteAction => 'حذف';

  @override
  String get commentDeleteConfirm => 'حذف هذا التعليق؟';

  @override
  String get commentSend => 'نشر';

  @override
  String get guaranteeTitle => 'ضماني';

  @override
  String get guaranteeNoneYet => 'لم تُفعّل ضمانًا بعد.';

  @override
  String get guaranteeLockedAmountLabel => 'المحجوز';

  @override
  String get guaranteeCoverageLabel => 'التغطية';

  @override
  String get guaranteeAvailableCoverageLabel => 'التغطية المتاحة';

  @override
  String get guaranteeUsedCoverageLabel => 'المستخدَم';

  @override
  String get guaranteeTrustScoreLabel => 'درجة الثقة';

  @override
  String get guaranteeCompletedOpsLabel => 'العمليات المكتملة';

  @override
  String get guaranteeLevelsTitle => 'مستويات التغطية';

  @override
  String get guaranteeActivate => 'تفعيل';

  @override
  String get guaranteeUpgrade => 'ترقية';

  @override
  String get guaranteeCurrentLevelBadge => 'الحالي';

  @override
  String get guaranteeAutoActivate => 'تفعيل أفضل مستوى متاح';

  @override
  String get guaranteeUnlock => 'فكّ الضمان';

  @override
  String get guaranteeUnlockConfirm =>
      'فكّ ضمانك وإعادة المبلغ المحجوز إلى محفظتك؟';

  @override
  String get guaranteeUnlocked => 'تم فكّ الضمان.';

  @override
  String get guaranteeActivated => 'تم تفعيل الضمان.';

  @override
  String get guaranteeNoChange => 'لا تغيير — رصيدك لا يكفي مستوى أعلى بعد.';

  @override
  String get guaranteeTransactionsTitle => 'الحركات';

  @override
  String get guaranteeTransactionsEmpty => 'لا توجد حركات بعد.';

  @override
  String get guaranteeRequiredLockedLabel => 'يتطلب';

  @override
  String get jobsTitle => 'الوظائف';

  @override
  String get jobsEmpty => 'لا توجد وظائف متاحة الآن.';

  @override
  String get jobsSearchHint => 'ابحث عن وظيفة...';

  @override
  String get jobsAllCategories => 'كل المجالات';

  @override
  String get jobSalaryLabel => 'الراتب';

  @override
  String get jobRequirementsLabel => 'المتطلبات';

  @override
  String get jobInterviewLabel => 'المقابلة';

  @override
  String get jobApplicantsLabel => 'متقدّم';

  @override
  String get jobApply => 'تقديم';

  @override
  String get jobApplied => 'تم إرسال طلبك.';

  @override
  String get jobFollowsTitle => 'تنبيهات الوظائف';

  @override
  String get jobFollowsEmpty => 'لا تتابع أي مجال بعد.';

  @override
  String get jobFollowAdd => 'متابعة مجال';

  @override
  String get jobFollowPickTitle => 'اختر مجالًا لمتابعته';

  @override
  String get jobUnfollow => 'إلغاء المتابعة';

  @override
  String get jobFollowed => 'تمت متابعة هذا المجال.';

  @override
  String get agendaLocalRemindersTitle => 'تذكيرات على هذا الهاتف';

  @override
  String get agendaLocalRemindersHint =>
      'يعرض هاتفك تذكيرات مهامك وجرعات أدويتك بنفسه وبكلماتك أنت — لا تخرج منه.';

  @override
  String agendaReminderBody(String time) {
    return 'الساعة $time';
  }

  @override
  String get agendaSettingsTitle => 'التذكيرات ومواعيد الوجبات';

  @override
  String get agendaSettingsMealTimesSection => 'مواعيد الوجبات';

  @override
  String get agendaSettingsMealTimesHint =>
      'الجرعات الدوائية المرتبطة بالوجبات تُجدول حول هذه المواعيد.';

  @override
  String get agendaSettingsBreakfast => 'الإفطار';

  @override
  String get agendaSettingsLunch => 'الغداء';

  @override
  String get agendaSettingsDinner => 'العشاء';

  @override
  String get agendaSettingsMealTimesSaved => 'تم حفظ مواعيد الوجبات.';

  @override
  String get agendaSettingsRemindersSection => 'التذكيرات';

  @override
  String get agendaSettingsRemindersHint =>
      'متى تريد أن يتم تذكيرك قبل موعد أو عنصر في الأجندة.';

  @override
  String get agendaSettingsFirstLead => 'التذكير الأول بالموعد';

  @override
  String get agendaSettingsSecondLead => 'التذكير الثاني بالموعد';

  @override
  String get agendaSettingsSecondLeadNone => 'بدون';

  @override
  String get agendaSettingsAgendaLead => 'تذكير عنصر الأجندة';

  @override
  String get agendaSettingsAgendaLeadNone => 'في نفس الوقت';

  @override
  String get agendaSettingsRemindersSaved => 'تم حفظ تفضيلات التذكير.';

  @override
  String get agendaSettingsSecondLeadError =>
      'يجب أن يكون التذكير الثاني أقرب من الأول.';

  @override
  String durationMinutes(int count) {
    return '$count د';
  }

  @override
  String durationHours(int count) {
    return '$count س';
  }

  @override
  String durationDays(int count) {
    return '$count يوم';
  }

  @override
  String get depositsTitle => 'الضمانات المجمّدة';

  @override
  String get depositsEmpty => 'لا توجد ضمانات.';

  @override
  String get depositsAllStatuses => 'الكل';

  @override
  String get depositStatusFrozen => 'مجمّد';

  @override
  String get depositStatusInProgress => 'قيد التنفيذ';

  @override
  String get depositStatusReleased => 'تم الإفراج';

  @override
  String get depositStatusRefunded => 'تم الاسترداد';

  @override
  String get depositStatusSplit => 'مقسوم';

  @override
  String get depositRoleClient => 'أنت دفعت';

  @override
  String get depositRoleBusiness => 'المبلغ محجوز لك';

  @override
  String get depositMyAmount => 'نصيبي';

  @override
  String get depositTotalAmount => 'المبلغ الإجمالي';

  @override
  String get depositClientShare => 'نصيب العميل';

  @override
  String get depositBusinessShare => 'نصيب النشاط';

  @override
  String get depositCounterparty => 'الطرف الآخر';

  @override
  String get depositCreatedAt => 'تاريخ الإنشاء';

  @override
  String get depositReleasedAt => 'تاريخ الإفراج';

  @override
  String get depositRefundedAt => 'تاريخ الاسترداد';

  @override
  String get depositBookingLabel => 'الحجز';

  @override
  String get myRatingTitle => 'تقييمي';

  @override
  String get myRatingObjectiveSection => 'سجل العمليات';

  @override
  String get myRatingTotalOperations => 'إجمالي العمليات';

  @override
  String get myRatingSuccessRate => 'نسبة النجاح';

  @override
  String get myRatingCancelRate => 'نسبة الإلغاء';

  @override
  String get myRatingDisputeRate => 'نسبة النزاعات';

  @override
  String get myRatingFaultRate => 'قرارات ضدك';

  @override
  String get myRatingVindicationRate => 'قرارات لصالحك';

  @override
  String get myRatingReviewsSection => 'التقييمات';

  @override
  String get myRatingStarsAverage => 'متوسط التقييم';

  @override
  String myRatingReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تقييم',
      many: '$count تقييمًا',
      few: '$count تقييمات',
      two: 'تقييمان',
      one: 'تقييم واحد',
      zero: 'لا توجد تقييمات بعد',
    );
    return '$_temp0';
  }

  @override
  String get myRatingConsentSection => 'رسوم الخدمة';

  @override
  String get myRatingConsentEnabledLabel =>
      'تقييمك مفتوح — تُطبَّق رسوم الخدمة على عملياتك الخاصة.';

  @override
  String get myRatingConsentDisabledLabel =>
      'تقييمك مغلق — التعامل مجاني، لكن تقييمك وتقييمات الآخرين لك تبقى مخفية حتى تفتحه.';

  @override
  String get myRatingEnableButton => 'افتح تقييمي';

  @override
  String get myRatingEnableConfirmTitle => 'فتح تقييمك؟';

  @override
  String get myRatingEnableConfirmBody =>
      'هذا يجعل عملياتك ظاهرة بتقييم ومراجعات، وستبدأ رسوم الخدمة على عملياتك الخاصة من الآن. تقدر تغلقه تاني في أي وقت.';

  @override
  String get myRatingEnableConfirm => 'فتحه';

  @override
  String get myRatingEnabledMessage =>
      'تم فتح تقييمك. ستُطبَّق رسوم الخدمة على عملياتك من الآن.';

  @override
  String get myRatingDisableButton => 'إغلاق تقييمي';

  @override
  String get myRatingDisableConfirmTitle => 'إغلاق تقييمك؟';

  @override
  String get myRatingDisableConfirmBody =>
      'سيتم إخفاء سجل عملياتك وتقييماتك مرة أخرى، وستتوقف رسوم الخدمة عن الانطباق على عملياتك الجديدة.';

  @override
  String get myRatingDisableConfirm => 'إغلاقه';

  @override
  String get myRatingDisabledMessage => 'تم إغلاق تقييمك.';

  @override
  String get myRatingHiddenHint => 'مخفي أثناء إغلاق تقييمك.';

  @override
  String get merchantAccountTitle => 'حساب التاجر';

  @override
  String get merchantAccountHint =>
      'حساب Fawry فرعي مخصص يحوّل مدفوعاتك إليك مباشرة بدلًا من الحساب المشترك للمنصة.';

  @override
  String get merchantAccountStatusActive => 'نشط';

  @override
  String get merchantAccountStatusPending => 'الطلب قيد المراجعة';

  @override
  String get merchantAccountStatusRejected => 'تم رفض الطلب';

  @override
  String get merchantAccountStatusNone => 'لم يُنشأ بعد';

  @override
  String get merchantAccountRoutingDisabledNote =>
      'التحويل المباشر غير مفعّل على مستوى المنصة بعد — الطلبات تُراجَع وتُدرَج في الانتظار.';

  @override
  String get merchantAccountNoteHint => 'ملاحظة لفريق المراجعة (اختياري)';

  @override
  String get merchantAccountApplyButton => 'التقدّم بطلب حساب Merchant';

  @override
  String get merchantAccountApplied => 'تم إرسال طلبك وسيتم مراجعته.';

  @override
  String get menuManagementTitle => 'قائمتي';

  @override
  String get marketCatalogTitle => 'التسعير بالجملة';

  @override
  String get marketCatalogNotApplicable =>
      'هذه الشاشة مخصّصة لتجار السلع الجاهزة (كالسوبر ماركت والخضار والفاكهة).';

  @override
  String get marketCatalogEmpty => 'لا توجد أقسام متاحة لتصنيف نشاطك.';

  @override
  String marketCatalogFilledOf(int filled, int total) {
    return '$filled من $total مُسعَّر';
  }

  @override
  String get marketCatalogSave => 'حفظ';

  @override
  String marketCatalogSaved(int saved) {
    String _temp0 = intl.Intl.pluralLogic(
      saved,
      locale: localeName,
      other: 'تم حفظ $saved صنف',
      many: 'تم حفظ $saved صنفًا',
      few: 'تم حفظ $saved أصناف',
      two: 'تم حفظ صنفين',
      one: 'تم حفظ صنف واحد',
      zero: 'لم يتغيّر شيء',
    );
    return '$_temp0';
  }

  @override
  String marketCatalogCleared(int cleared) {
    return '، وتعطيل $cleared صنفًا فُرِّغ';
  }

  @override
  String get marketCatalogQuantity => 'الكمية';

  @override
  String get marketCatalogSupplyPrice => 'سعر التوريد';

  @override
  String get marketCatalogSalePrice => 'سعر البيع';

  @override
  String get marketCatalogBrand => 'العلامة التجارية / المورد';

  @override
  String get marketCatalogUnit => 'الوحدة';

  @override
  String marketCatalogDefaultMargin(String margin) {
    return 'هامش الربح الافتراضي $margin% مُفعَّل — اكتب سعر التوريد فقط وسيُحسب سعر البيع تلقائيًا.';
  }

  @override
  String get marketCatalogLowStockSettings => 'تنبيه اقتراب النفاد';

  @override
  String get marketCatalogLowStockSettingsHint =>
      'عند وصول كمية أي صنف إلى هذا الحد أو أقل، تصلك رسالة تنبيه لطلب كمية إضافية من موردك. الرقم عام لكل الأصناف بصرف النظر عن وحدة البيع (كيلو، عبوة...). اتركه فارغًا للتنبيه فقط عند النفاد التام.';

  @override
  String get marketCatalogLowStockThreshold => 'التنبيه عند وصول الكمية إلى';

  @override
  String get marketCatalogLowStockNoAlert => 'بلا تنبيه مسبق — عند الصفر فقط';

  @override
  String get marketCatalogLowStockSaved => 'تم حفظ إعداد التنبيه.';

  @override
  String get menuSectionsTitle => 'أقسام القائمة';

  @override
  String get menuSectionsEmpty => 'لا توجد أقسام بعد.';

  @override
  String get menuSectionAdd => 'إضافة قسم';

  @override
  String get menuSectionEditTitle => 'تعديل القسم';

  @override
  String get menuSectionAddTitle => 'إضافة قسم';

  @override
  String get menuSectionDeleteConfirm =>
      'حذف هذا القسم؟ الأصناف بداخله تحتفظ ببياناتها لكنها تفقد قسمها.';

  @override
  String get menuItemsTitle => 'الأصناف';

  @override
  String get menuItemsEmpty => 'لا توجد أصناف بعد.';

  @override
  String get menuItemsSearchHint => 'ابحث عن صنف...';

  @override
  String get menuItemsAllSections => 'كل الأقسام';

  @override
  String get menuItemsAddBrandRow => 'إضافة علامة تجارية';

  @override
  String get menuItemsUnbranchedSection => 'أصناف أخرى';

  @override
  String menuItemsQuantityShort(int quantity) {
    return 'الكمية المتاحة: $quantity';
  }

  @override
  String get menuItemsDisplayModeLabel => 'طريقة العرض';

  @override
  String get menuItemsDisplayModeList => 'قائمة';

  @override
  String get menuItemsDisplayModeGrid => 'شبكة';

  @override
  String get menuItemsManageTypesAction => 'إدارة الأصناف';

  @override
  String get menuItemsManageSectionsAction => 'إدارة الأقسام';

  @override
  String get menuTypeSelectionSubtitle =>
      'اختر الأصناف التي تقدمها من نشاطك — تقدر تضيف أصناف تانية من هنا في أي وقت.';

  @override
  String menuTypeSelectionContinue(int count) {
    return 'متابعة ($count)';
  }

  @override
  String get menuTypeSelectionSaved => 'تم تحديث الأصناف';

  @override
  String get menuItemAdd => 'إضافة صنف';

  @override
  String get menuItemsAddPrice => 'إضافة سعر';

  @override
  String get menuItemEditTitle => 'تعديل الصنف';

  @override
  String get menuItemAddTitle => 'إضافة صنف';

  @override
  String get menuItemDeleteConfirm => 'حذف هذا الصنف؟';

  @override
  String get techPricingTitle => 'التسعير والتفاصيل';

  @override
  String get techPricingProductLabel => 'المنتج';

  @override
  String get techPricingPickProduct => 'اختر منتجًا حقيقيًا';

  @override
  String get techPricingSearchHint => 'ابحث عن الموديل...';

  @override
  String get techPricingNoResults => 'لا توجد نتائج';

  @override
  String get techPricingConditionLabel => 'حالة المنتج';

  @override
  String get techPricingAddAnother => 'إضافة موديل آخر';

  @override
  String get techPricingAddProduct => 'إضافة منتج';

  @override
  String get techPricingUnitDetails => 'لهذه الوحدة بالذات';

  @override
  String get techPricingItemDetails => 'تفاصيل الصنف';

  @override
  String get menuSearchTitle => 'بحث ومقارنة';

  @override
  String get menuSearchHint => 'ابحث بالاسم أو الموديل…';

  @override
  String get menuSearchFilters => 'الفلاتر';

  @override
  String menuSearchFiltersCount(int n) {
    return 'الفلاتر ($n)';
  }

  @override
  String get menuSearchApply => 'عرض النتائج';

  @override
  String get menuSearchReset => 'مسح الكل';

  @override
  String get menuSearchFrom => 'من';

  @override
  String get menuSearchTo => 'إلى';

  @override
  String menuSearchRangeHint(String min, String max) {
    return '$min – $max';
  }

  @override
  String menuSearchResults(int n) {
    return '$n نتيجة';
  }

  @override
  String get menuSearchEmpty => 'لا توجد نتائج بهذه المواصفات.';

  @override
  String get menuSearchNoKinds => 'لا توجد منتجات بمواصفات معروضة بعد.';

  @override
  String get menuSearchPickKind => 'اختر نوع المنتج لتظهر فلاتره';

  @override
  String get menuSearchAllKinds => 'الكل';

  @override
  String get menuSearchSortPriceAsc => 'الأرخص أولًا';

  @override
  String get menuSearchSortPriceDesc => 'الأغلى أولًا';

  @override
  String get menuSearchSortNewest => 'الأحدث';

  @override
  String get menuSearchCompare => 'قارن الأسعار';

  @override
  String get menuCompareTitle => 'مقارنة الأسعار';

  @override
  String menuCompareShops(int n) {
    return '$n محل يبيعه';
  }

  @override
  String get menuCompareCheapest => 'الأرخص';

  @override
  String menuCompareMore(String amount) {
    return '+$amount عن الأرخص';
  }

  @override
  String get menuCompareOpenShop => 'افتح المحل';

  @override
  String techPricingFieldNotNumber(String field) {
    return '«$field» رقم صحيح';
  }

  @override
  String get techPricingAllBrands => 'الكل';

  @override
  String get techPricingPending => 'قيد المراجعة';

  @override
  String get techPricingNotFound => 'الموديل مش موجود؟ أضفه بنفسك';

  @override
  String get techPricingNewModelTitle => 'إضافة موديل جديد';

  @override
  String get techPricingNewModelNote =>
      'هيظهر في متجرك فورًا، ولباقي التجار بعد مراجعة الإدارة.';

  @override
  String get techPricingBrandLabel => 'الماركة';

  @override
  String get techPricingOtherBrand => 'ماركة أخرى';

  @override
  String get techPricingBrandNameHint => 'اسم الماركة';

  @override
  String get techPricingSeriesLabel => 'السلسلة (اختياري)';

  @override
  String get techPricingModelLabel => 'اسم الموديل';

  @override
  String get techPricingProcessorLabel => 'المعالج';

  @override
  String get techPricingRamLabel => 'الرام (جيجا)';

  @override
  String get techPricingStorageLabel => 'سعة التخزين';

  @override
  String get techPricingScreenLabel => 'مقاس الشاشة (بوصة)';

  @override
  String get techPricingOsLabel => 'نظام التشغيل';

  @override
  String get techPricingModelRequired => 'اكتب اسم الموديل واختر الماركة';

  @override
  String get techDetailTotal => 'الإجمالي';

  @override
  String get techPricingPhotosLabel => 'صور المنتج';

  @override
  String get techPricingTakePhoto => 'التقاط بالكاميرا';

  @override
  String get techPricingFromGallery => 'من المعرض';

  @override
  String get techPricingUsedCameraOnly =>
      'المنتج المستعمل يُصوَّر بالكاميرا مباشرة — صورة حقيقية للقطعة نفسها بدون تعديل.';

  @override
  String get techPricingRearCameraLabel => 'الكاميرا الخلفية (ميجابكسل)';

  @override
  String get techPricingFrontCameraLabel => 'الكاميرا الأمامية (ميجابكسل)';

  @override
  String get techPricingBatteryLabel => 'البطارية (مللي أمبير)';

  @override
  String get menuFilterAllBrands => 'كل الماركات';

  @override
  String get menuBundlesTitle => 'باقات المنيو';

  @override
  String get menuBundlesEmpty => 'لا توجد باقات بعد.';

  @override
  String get menuBundleAdd => 'إضافة باقة';

  @override
  String get menuBundleEditTitle => 'تعديل الباقة';

  @override
  String get menuBundleDeleteConfirm => 'حذف هذه الباقة؟';

  @override
  String get menuBundleFormError => 'اكتب اسمًا وسعرًا، واختر صنفين على الأقل.';

  @override
  String get menuBundlePricingMode => 'طريقة التسعير';

  @override
  String get menuBundlePricingFixed => 'سعر ثابت';

  @override
  String get menuBundlePricingDiscountPercent => 'خصم % عن مجموع الأصناف';

  @override
  String get menuBundlePricingDiscountFixed => 'خصم مبلغ عن مجموع الأصناف';

  @override
  String get menuBundleFixedPrice => 'سعر الباقة';

  @override
  String get menuBundleDiscountPercent => 'نسبة الخصم';

  @override
  String get menuBundleDiscountFixed => 'مبلغ الخصم';

  @override
  String get menuBundleComponents => 'الأصناف المكوّنة';

  @override
  String get menuBundleComponentsHint =>
      'اختر صنفين على الأقل — التركيبة ثابتة ولا يقدر العميل يستبدلها.';

  @override
  String get menuBundleComponentsSubtotal => 'مجموع أسعار الأصناف';

  @override
  String get menuBundleFinalPrice => 'سعر الباقة';

  @override
  String get menuItemNameArHint => 'الاسم (عربي)';

  @override
  String get menuItemNameEnHint => 'الاسم (إنجليزي، اختياري)';

  @override
  String get menuItemDescriptionArHint => 'الوصف (عربي، اختياري)';

  @override
  String get menuItemDescriptionEnHint => 'الوصف (إنجليزي، اختياري)';

  @override
  String get menuItemSectionLabel => 'القسم';

  @override
  String get menuItemNoSection => 'بدون قسم';

  @override
  String get menuItemBranchLabel => 'النوع';

  @override
  String get menuItemNoBranch => '— بدون تحديد —';

  @override
  String get menuItemNotSpecified => 'غير محدد';

  @override
  String get menuItemAvailableQuantityHint => 'الكمية المتاحة (اختياري)';

  @override
  String get menuItemBasePriceHint => 'السعر';

  @override
  String get menuItemSaleUnitLabel => 'يُباع بـ';

  @override
  String get menuItemSaleUnitByItem => 'بالقطعة';

  @override
  String get menuItemSupplyPriceHint => 'سعر التكلفة (اختياري)';

  @override
  String get menuItemSupplyPriceHelper => 'لحسابك الداخلي فقط — لا يظهر للعميل';

  @override
  String get menuItemBrandNameHint => 'الماركة (اختياري)';

  @override
  String get menuItemBrandLabel => 'الماركة';

  @override
  String get menuItemNoBrand => '— بدون تحديد —';

  @override
  String get menuItemSortOrderHint => 'ترتيب العرض';

  @override
  String get menuItemActiveLabel => 'نشط';

  @override
  String get itemPhotoSetCover => 'اعرض هذه الصورة على الكارت';

  @override
  String get itemPhotoIsCover => 'هذه صورة الكارت';

  @override
  String get itemPhotoCoverBadge => 'صورة الكارت';

  @override
  String get itemPhotoCropAdjust => 'اضبط الجزء الظاهر منها';

  @override
  String get itemPhotoCropTitle => 'الجزء الظاهر من الصورة';

  @override
  String get itemPhotoCropHint =>
      'اسحب الصورة لتضع المنتج في المنتصف، وكبّر لتترك الجزء الفارغ خارج الكارت. هكذا ستظهر على الكارت.';

  @override
  String get itemPhotoCropListPreview => 'في القائمة';

  @override
  String get itemPhotoCropReset => 'الصورة كاملة';

  @override
  String get menuItemImagesSection => 'الصور';

  @override
  String get menuItemAddImage => 'إضافة صورة';

  @override
  String get menuItemVariantsSection => 'الخيارات';

  @override
  String get menuItemAddVariant => 'إضافة خيار';

  @override
  String get menuItemEditVariant => 'تعديل الخيار';

  @override
  String get menuItemVariantTypeHint => 'النوع (مثال: الحجم)';

  @override
  String get menuItemVariantPriceHint => 'السعر الكامل (اختياري)';

  @override
  String get menuItemVariantPriceDeltaHint => 'فرق السعر (اختياري)';

  @override
  String get menuItemVariantDefaultLabel => 'الاختيار الافتراضي';

  @override
  String get menuItemExtraGroupsSection => 'مجموعات الإضافات';

  @override
  String get menuItemAddExtraGroup => 'إضافة مجموعة';

  @override
  String get menuItemEditExtraGroup => 'تعديل المجموعة';

  @override
  String get menuItemExtraGroupNameHint => 'اسم المجموعة (مثال: الصوصات)';

  @override
  String get menuItemExtraGroupSelectionLabel => 'طريقة الاختيار';

  @override
  String get menuItemExtraGroupSelectionSingle => 'اختيار واحد (راديو بوتون)';

  @override
  String get menuItemExtraGroupSelectionMultiple => 'اختيار متعدد (تشيك بوكس)';

  @override
  String get menuItemExtraGroupNone => 'بدون مجموعة';

  @override
  String get menuItemExtrasSection => 'الإضافات';

  @override
  String get menuItemAddExtra => 'إضافة إضافة';

  @override
  String get menuItemEditExtra => 'تعديل الإضافة';

  @override
  String get menuItemExtraGroupHint => 'المجموعة (اختياري)';

  @override
  String get menuItemExtraPriceHint => 'السعر';

  @override
  String get menuItemExtraMaxQtyHint => 'الحد الأقصى للكمية';

  @override
  String get menuItemDeleteRowConfirm => 'حذف هذا؟';

  @override
  String get menuNameRequired => 'أدخل اسمًا.';

  @override
  String get menuPriceRequired => 'أدخل سعرًا صحيحًا.';

  @override
  String get retailVariantGroupsTitle => 'تنويعات المنتج';

  @override
  String get retailVariantGroupsEmpty =>
      'لا توجد تنويعات بعد. أنشئ منتجًا واحدًا بألوان أو مقاسات مختلفة بدل عرضها منفصلة.';

  @override
  String get retailVariantGroupsDeleteConfirm =>
      'حذف هذا المنتج؟ التنويعات نفسها (المنتجات) تبقى في قائمتك منفصلة.';

  @override
  String get retailVariantGroupsNewTitle => 'منتج جديد بتنويعات';

  @override
  String get retailVariantGroupsEditTitle => 'تعديل التنويعات';

  @override
  String get retailVariantGroupsNameLabel => 'اسم المنتج (مثال: قميص كلاسيك)';

  @override
  String get retailVariantGroupsOptionsTitle => 'التنويعات';

  @override
  String get retailVariantGroupsLabelHint => 'التنويعة (مثال: أزرق - M)';

  @override
  String get retailVariantGroupsAddOption => 'إضافة تنويعة من منتجاتي';

  @override
  String get retailVariantGroupsNeedTwo =>
      'أدخل اسمًا واختر تنويعتين على الأقل.';

  @override
  String get retailVariantGroupsPickListingTitle => 'اختر منتجًا من منتجاتك';

  @override
  String get retailVariantGroupsSearchHint => 'ابحث بالاسم';

  @override
  String get retailStorefrontChooseVariantTitle => 'اختر التنويعة';

  @override
  String get retailListingsTitle => 'منتجاتي';

  @override
  String get retailListingsProductsTab => 'المنتجات';

  @override
  String get retailListingsVisibilityTab => 'من يشاهدها';

  @override
  String get retailListingsEmpty => 'لا توجد منتجات مضافة بعد.';

  @override
  String get retailListingsSearchHint => 'ابحث في منتجاتي...';

  @override
  String get retailListingAdd => 'إضافة منتج';

  @override
  String get retailListingPickTitle => 'اختر منتجًا';

  @override
  String get retailListingLookupHint => 'ابحث في الكتالوج...';

  @override
  String get retailListingLookupEmpty => 'لا توجد منتجات مطابقة.';

  @override
  String get retailListingEditTitle => 'تعديل الإدراج';

  @override
  String get retailListingPriceHint => 'السعر';

  @override
  String get retailListingStockHint => 'المخزون (اختياري)';

  @override
  String retailListingAvailableQtyBadge(String qty) {
    return 'المتاح: $qty';
  }

  @override
  String get retailListingMinOrderQtyLabel =>
      'الحد الأدنى للكمية بالطلب (اختياري)';

  @override
  String get retailListingMinOrderQtyHint =>
      'مثال: ٢٠ — لن يستطيع المشتري طلب أقل من هذه الكمية';

  @override
  String retailListingMinOrderQtyBadge(String qty) {
    return 'الحد الأدنى $qty';
  }

  @override
  String get retailListingMaxOrderQtyLabel =>
      'الحد الأقصى للكمية بالطلب (اختياري)';

  @override
  String get retailListingMaxOrderQtyHint =>
      'مثال: ١٠٠ — لن يستطيع مشترٍ واحد طلب أكثر من هذه الكمية في نفس الطلب';

  @override
  String retailListingMaxOrderQtyBadge(String qty) {
    return 'الحد الأقصى $qty';
  }

  @override
  String get retailListingMaxBelowMinError =>
      'يجب أن يكون الحد الأقصى أكبر من أو يساوي الحد الأدنى.';

  @override
  String get retailListingUnitLabel => 'الوحدة (اختياري)';

  @override
  String get retailListingUnitHint => 'اكتب وحدتك الخاصة';

  @override
  String get retailListingUnitOther => 'أخرى...';

  @override
  String get retailExtrasTitle => 'إضافات المنتج';

  @override
  String get retailExtrasHint => 'مثل: ضمان سنة، ضمان سنتين، تركيب';

  @override
  String get retailExtrasName => 'اسم الإضافة';

  @override
  String get retailExtrasPrice => 'السعر';

  @override
  String get retailExtrasGroup => 'المجموعة (اختياري، مثل: الضمان)';

  @override
  String get retailExtrasSingle => 'اختيار واحد فقط من المجموعة';

  @override
  String get retailExtrasAdd => 'إضافة بند';

  @override
  String get retailVariantConditionLabel => 'حالة المنتج';

  @override
  String get retailVariantPaymentLabel => 'الدفع والسداد';

  @override
  String get retailVariantNone => 'بدون';

  @override
  String get retailVariantDescriptionHint => 'وصف هذا السعر (اختياري)';

  @override
  String get retailVariantAddAnotherPrice => 'إضافة سعر آخر لنفس المنتج';

  @override
  String get retailVariantFilterTitle => 'تصفية الأسعار';

  @override
  String get retailVariantFilterClear => 'عرض الكل';

  @override
  String get retailListingSkuHint => 'رمز المنتج SKU (اختياري)';

  @override
  String get retailListingActiveLabel => 'نشط';

  @override
  String get retailListingDeleteConfirm => 'إزالة هذا المنتج من منتجاتك؟';

  @override
  String get retailPriceRequired => 'أدخل سعرًا صحيحًا.';

  @override
  String get retailListingGovernoratesLabel => 'المحافظات';

  @override
  String get retailListingGovernoratesAllHint =>
      'كل المحافظات — بلا قيود جغرافية';

  @override
  String retailListingGovernoratesSelectedHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count محافظة مختارة',
      one: 'محافظة واحدة مختارة',
    );
    return '$_temp0';
  }

  @override
  String get retailListingChooseGovernorates => 'اختر المحافظات';

  @override
  String get retailListingGovernoratesPickerTitle => 'اختر المحافظات';

  @override
  String get retailListingGovernoratesSelectAll => 'تحديد الكل';

  @override
  String get retailListingGovernoratesClearAll => 'مسح';

  @override
  String get retailListingVisibilityLabel => 'من يرى هذا المنتج';

  @override
  String get retailListingVisibilityPublic => 'الجميع';

  @override
  String get retailListingVisibilityPublicHint =>
      'يظهر لكل عميل، مثل باقي منتجاتك.';

  @override
  String get retailListingVisibilityRestricted => 'بيع الجملة';

  @override
  String get retailListingVisibilityRestrictedHint =>
      'بيع الجملة: مخفي عن الجميع إلا أنواع المحلات أو الشركات التي تحددها بالأسفل — سعر جملة لا يراه سواهم.';

  @override
  String get retailListingRestrictedBadge => 'بيع الجملة';

  @override
  String get retailListingAudienceShopTypesLabel => 'أنواع المحلات';

  @override
  String get retailListingAudienceBusinessesLabel => 'شركات/محلات بعينها';

  @override
  String get retailListingAddShopType => 'إضافة نوع محل';

  @override
  String get retailListingAddBusiness => 'إضافة شركة';

  @override
  String get retailListingAudienceEmpty => 'لم يتم اختيار أحد بعد.';

  @override
  String get retailListingAudienceRequired =>
      'اختر نوع محل واحدًا أو شركة واحدة على الأقل.';

  @override
  String get retailListingBusinessSearchTitle => 'اختر شركة';

  @override
  String get retailListingBusinessSearchHint => 'ابحث باسم النشاط...';

  @override
  String get retailListingBusinessSearchEmpty => 'لا توجد نتائج مطابقة.';

  @override
  String get retailListingsFeedEmpty => 'لا توجد منتجات بعد.';

  @override
  String retailStorefrontMinQtyLabel(String qty) {
    return 'الحد الأدنى للطلب: $qty';
  }

  @override
  String retailStorefrontMaxQtyLabel(String qty) {
    return 'الحد الأقصى للطلب: $qty';
  }

  @override
  String retailStorefrontQtyBelowMin(String min) {
    return 'الحد الأدنى للطلب $min';
  }

  @override
  String retailStorefrontQtyOutOfRange(String min, String max) {
    return 'اطلب كمية بين $min و $max';
  }

  @override
  String get retailStorefrontQuantityLabel => 'الكمية';

  @override
  String get retailStorefrontEmpty => 'لا توجد منتجات لدى هذا النشاط بعد.';

  @override
  String get accountDeletionTitle => 'حذف حسابي';

  @override
  String accountDeletionHint(int days) {
    return 'لديك $days يومًا لتغيير رأيك — تسجيل الدخول مرة أخرى خلال هذه المدة يستعيد كل شيء كما كان.';
  }

  @override
  String get accountDeletionBlockersTitle => 'لا يمكنك حذف حسابك الآن';

  @override
  String get accountDeletionPasswordHint => 'أكّد كلمة المرور';

  @override
  String get accountDeletionReasonHint => 'السبب (اختياري)';

  @override
  String get accountDeletionRequestButton => 'حذف حسابي';

  @override
  String get accountDeletionConfirmTitle => 'حذف حسابك؟';

  @override
  String get accountDeletionConfirmBody =>
      'سيتم تسجيل خروجك من كل الأجهزة فورًا. يمكنك استعادة حسابك بتسجيل الدخول مرة أخرى خلال مهلة الاسترجاع — بعدها يُحذف نهائيًا.';

  @override
  String get accountDeletionConfirmButton => 'احذفه';

  @override
  String get accountDeletionRequested =>
      'تم جدولة حذف حسابك. سجّل الدخول مرة أخرى خلال مهلة الاسترجاع لاستعادته.';

  @override
  String get restoreAccountTitle => 'استعادة حسابك';

  @override
  String get restoreAccountHint =>
      'أدخل بريد وكلمة مرور الحساب الذي حذفته — يعمل هذا فقط خلال مهلة الاسترجاع.';

  @override
  String get restoreAccountButton => 'استعادة الحساب';

  @override
  String get restoreAccountLinkFromLogin => 'حذفت حسابك بالخطأ؟';

  @override
  String get clinicManagementTitle => 'عيادتي';

  @override
  String get clinicQueueTab => 'المواعيد';

  @override
  String get clinicSlotsTab => 'الفتحات';

  @override
  String get clinicQueueEmpty => 'لا توجد مواعيد.';

  @override
  String get clinicQueueAllStatuses => 'الكل';

  @override
  String get clinicActionConfirm => 'تأكيد';

  @override
  String get clinicActionReject => 'رفض';

  @override
  String get clinicActionComplete => 'إكمال';

  @override
  String get clinicActionNoShow => 'لم يحضر';

  @override
  String get clinicActionReschedule => 'تغيير الموعد';

  @override
  String get clinicRescheduleTitle => 'تغيير موعد الحجز';

  @override
  String get clinicRescheduleConfirm => 'حفظ الموعد الجديد';

  @override
  String get clinicSlotsEmpty => 'لا توجد فتحات مفتوحة.';

  @override
  String get clinicAddSlots => 'إضافة فتحات';

  @override
  String get clinicSlotsSpecificTab => 'تواريخ محددة';

  @override
  String get clinicSlotsRecurringTab => 'أسبوعي متكرر';

  @override
  String get clinicSlotAddDate => 'إضافة تاريخ ووقت';

  @override
  String clinicSlotPendingCount(int count) {
    return '$count في الانتظار';
  }

  @override
  String get clinicPublishButton => 'نشر';

  @override
  String get clinicWeekdaysLabel => 'أيام الأسبوع';

  @override
  String get clinicStartTimeHint => 'من';

  @override
  String get clinicEndTimeHint => 'إلى';

  @override
  String get clinicIntervalHint => 'الفاصل الزمني (دقائق)';

  @override
  String get clinicWeeksHint => 'التكرار لمدة (أسابيع)';

  @override
  String get clinicGenerateButton => 'إنشاء';

  @override
  String clinicSlotsPublished(int created, int skipped) {
    String _temp0 = intl.Intl.pluralLogic(
      skipped,
      locale: localeName,
      other: '، وتخطي $skipped',
      zero: '',
    );
    return 'تم نشر $created فتحة$_temp0.';
  }

  @override
  String get clinicSlotDeleteConfirm => 'إزالة هذه الفتحة؟';

  @override
  String get clinicWeekday0 => 'أحد';

  @override
  String get clinicWeekday1 => 'اثنين';

  @override
  String get clinicWeekday2 => 'ثلاثاء';

  @override
  String get clinicWeekday3 => 'أربعاء';

  @override
  String get clinicWeekday4 => 'خميس';

  @override
  String get clinicWeekday5 => 'جمعة';

  @override
  String get clinicWeekday6 => 'سبت';

  @override
  String get clinicSelectWeekdaysError => 'اختر يومًا واحدًا على الأقل.';

  @override
  String get trainingTemplatesTitle => 'قوالبي';

  @override
  String get trainingTemplatesEmpty => 'لا توجد قوالب بعد.';

  @override
  String get trainingTemplateAdd => 'إضافة قالب';

  @override
  String get trainingTemplateAddTitle => 'إضافة قالب';

  @override
  String get trainingTemplateEditTitle => 'تعديل القالب';

  @override
  String get trainingTemplateTitleHint => 'العنوان';

  @override
  String get trainingTemplateGoalHint => 'الهدف (اختياري)';

  @override
  String get trainingTemplateNotesHint => 'ملاحظات (اختياري)';

  @override
  String get trainingTemplateDeleteConfirm => 'حذف هذا القالب؟';

  @override
  String get trainingTemplateExercisesSection => 'التمارين';

  @override
  String get trainingTemplateAddExercise => 'إضافة تمرين';

  @override
  String get trainingTemplateMealsSection => 'الوجبات';

  @override
  String get trainingTemplateAddMeal => 'إضافة وجبة';

  @override
  String get trainingExerciseNameHint => 'اسم التمرين';

  @override
  String get trainingExerciseDayHint => 'اليوم (اختياري)';

  @override
  String get trainingExerciseDayAny => 'أي يوم';

  @override
  String get trainingExerciseSetsHint => 'المجموعات (اختياري)';

  @override
  String get trainingExerciseRepsHint => 'التكرارات (اختياري)';

  @override
  String get trainingExerciseRestHint => 'الراحة، ثوانٍ (اختياري)';

  @override
  String get trainingMealTypeLabel => 'نوع الوجبة';

  @override
  String get trainingMealNameHint => 'اسم الوجبة';

  @override
  String get trainingMealCaloriesHint => 'السعرات (اختياري)';

  @override
  String get trainingRemoveRowConfirm => 'حذف هذا؟';

  @override
  String get businessPricesTitle => 'أسعاري';

  @override
  String get businessPricesSubtitle => 'سعر كل نوع تقدّمه — يخصّك أنت فقط.';

  @override
  String get businessPricesEmpty => 'لا توجد أسعار بعد.';

  @override
  String get businessPricesAdd => 'إضافة سعر';

  @override
  String get businessPricesFilterAll => 'كل الخدمات';

  @override
  String get businessPriceDeleteConfirm => 'حذف هذا السعر؟';

  @override
  String get businessPriceEditTitle => 'تعديل السعر';

  @override
  String get businessPriceAddTitle => 'إضافة سعر';

  @override
  String get priceFieldService => 'الخدمة';

  @override
  String get priceFieldServiceHint => 'اختر الخدمة';

  @override
  String get priceFieldItemType => 'نوع العنصر';

  @override
  String get priceFieldItemTypePickServiceFirst => 'اختر الخدمة أولًا';

  @override
  String get priceFieldItemTypeEmpty => 'لا توجد أنواع مسموحة';

  @override
  String get priceFieldItemTypeHint => 'اختر النوع';

  @override
  String get priceFieldPrice => 'السعر';

  @override
  String get priceFieldCurrency => 'العملة';

  @override
  String get priceFieldActive => 'مفعّل';

  @override
  String get priceChargeModeLabel => 'طريقة الاحتساب';

  @override
  String get priceChargeModeStandard => 'سعر عادي';

  @override
  String get priceChargeModeFree => 'مجانية — يُحتسب الأكل فقط';

  @override
  String get priceChargeModeReservationFee => 'رسوم حجز ثابتة';

  @override
  String get priceChargeModeMinimum => 'حد أدنى للطلب';

  @override
  String get priceFieldChargeAmount => 'قيمة الرسوم / الحد الأدنى';

  @override
  String get priceFieldDuration => 'مدة الموعد (بالدقائق)';

  @override
  String get priceFieldDurationHint =>
      'اتركه فارغًا إن لم يكن للموعد مدة ثابتة';

  @override
  String get priceDiscountEnable => 'تفعيل الخصم';

  @override
  String get priceFieldDiscountPercent => 'نسبة الخصم %';

  @override
  String get priceVocabTitle => 'ما الذي تبيعه هنا؟';

  @override
  String get priceLineLabel => 'النوع';

  @override
  String get priceLineNone => '— بدون تحديد —';

  @override
  String get priceModifiersLabel => 'ما يميّزه';

  @override
  String get priceModifierAdjustHint =>
      'يُضاف إلى سعر الوحدة — اتركه فارغًا إن كان لا يغيّر السعر';

  @override
  String get priceNoServicesWarning => 'لا توجد خدمات متاحة لنشاطك بعد.';

  @override
  String get offerCompareButton => 'قارن الأسعار';

  @override
  String get offerCompareTitle => 'مقارنة الأسعار';

  @override
  String get offerCompareSortLabel => 'ترتيب حسب';

  @override
  String get offerCompareSortLowest => 'الأقل سعرًا';

  @override
  String get offerCompareSortHighest => 'الأعلى سعرًا';

  @override
  String get offerCompareSortBestValue => 'الأفضل قيمة';

  @override
  String get offerCompareSortRanking => 'الأعلى تقييمًا';

  @override
  String get offerCompareEmpty => 'لا توجد عروض لهذا العنصر بعد.';

  @override
  String get offerCompareBestPrice => 'أفضل سعر';

  @override
  String get offerCompareRefundable => 'قابل للاسترجاع';

  @override
  String get shopProductsTitle => 'تسوّق المنتجات';

  @override
  String get shopProductsSearchHint => 'ابحث عن منتج...';

  @override
  String get shopProductsEmpty => 'لا توجد منتجات.';

  @override
  String get shopProductsFilterAllBrands => 'كل العلامات';

  @override
  String get shopProductsSellersLabel => 'بائع';

  @override
  String get productOffersEmpty => 'لا يوجد بائعون حاليًا.';

  @override
  String get productOffersStockLabel => 'المخزون';

  @override
  String get clinicWritePrescription => 'كتابة روشتة';

  @override
  String get clinicViewPrescription => 'عرض الروشتة';

  @override
  String get prescriptionsIssuedTitle => 'الروشتات الصادرة';

  @override
  String get prescriptionsIssuedEmpty => 'لم تصدر أي روشتة بعد.';

  @override
  String get prescriptionIssueTitle => 'إصدار روشتة';

  @override
  String get prescriptionReviseTitle => 'تعديل الروشتة';

  @override
  String get prescriptionIssueSubmit => 'إصدار الروشتة';

  @override
  String get prescriptionReviseSubmit => 'حفظ التعديل';

  @override
  String get prescriptionReviseAction => 'تعديل';

  @override
  String get medicineSearchTitle => 'إضافة دواء';

  @override
  String get medicineSearchHint => 'ابحث باسم الدواء...';

  @override
  String get medicineNoResults => 'لا توجد نتائج. أضفه كدواء جديد بالأسفل.';

  @override
  String get medicineAddNew => 'إضافة دواء جديد';

  @override
  String get medicineAddTitle => 'دواء جديد';

  @override
  String get medicineNameHint => 'اسم الدواء';

  @override
  String get medicineStrengthHint => 'التركيز (اختياري)';

  @override
  String get medicineInstructionsHint => 'تعليمات (اختياري)';

  @override
  String get medicineFrequencyLabel => 'عدد المرات يوميًا';

  @override
  String get medicineFoodTimingLabel => 'توقيت الأكل';

  @override
  String get medicineTimeSlotsLabel => 'وقت اليوم';

  @override
  String get medicineDurationLabel => 'المدة';

  @override
  String get medicineAddItem => 'إضافة دواء';

  @override
  String get medicineAtLeastOneItem => 'أضف دواءً واحدًا على الأقل.';

  @override
  String get pharmacyQueueTitle => 'طلبات الصيدلية';

  @override
  String get pharmacyQueueFilterAll => 'الكل';

  @override
  String get pharmacyQueueEmpty => 'لا توجد وصفات مُرسلة إليك بعد.';

  @override
  String get pharmacyPriceAction => 'تسعير';

  @override
  String get pharmacyPrepareAction => 'بدء التجهيز';

  @override
  String get pharmacyMarkReadyAction => 'جاهزة';

  @override
  String get pharmacyDispenseAction => 'صرف';

  @override
  String get pharmacyRejectAction => 'رفض';

  @override
  String get pharmacyRejectConfirm => 'رفض هذه الوصفة وإعادتها للمريض؟';

  @override
  String get pharmacyPreparingStarted => 'بدأ التجهيز.';

  @override
  String get pharmacyMarkedReady => 'أصبحت جاهزة للمريض.';

  @override
  String get pharmacyDispensed => 'تم الصرف.';

  @override
  String get pharmacyRejected => 'تم الرفض وإعادتها للمريض.';

  @override
  String get pharmacyPriceTitle => 'تسعير الوصفة';

  @override
  String get pharmacyUnitPriceLabel => 'سعر الوحدة';

  @override
  String get pharmacyBilledQuantityLabel => 'الكمية';

  @override
  String get pharmacyPriced => 'تم تسعير الوصفة.';

  @override
  String get pharmacyCurrencyLabel => 'جنيه';

  @override
  String get businessOffersTitle => 'عروضي';

  @override
  String get businessOfferAdd => 'أضف عرضًا';

  @override
  String get businessOffersEmpty => 'لا توجد عروض بعد.';

  @override
  String get businessOffersFilterAll => 'الكل';

  @override
  String get businessOfferStatusActive => 'فعّال';

  @override
  String get businessOfferStatusPaused => 'متوقف';

  @override
  String get businessOfferStatusExpired => 'منتهي';

  @override
  String get businessOfferStatusCancelled => 'ملغى';

  @override
  String businessOffersUsage(int active, int max) {
    return '$active من $max عروض فعّالة مستخدمة';
  }

  @override
  String get businessOfferPause => 'إيقاف';

  @override
  String get businessOfferActivate => 'تفعيل';

  @override
  String get businessOfferDeleteConfirm => 'حذف هذا العرض؟';

  @override
  String get businessOfferBoostAction => 'تعزيز';

  @override
  String get businessOfferBoostTitle => 'تعزيز هذا العرض';

  @override
  String businessOfferBoostDuration(int days) {
    return '$days يوم';
  }

  @override
  String get businessOfferBoosted => 'تم تعزيز العرض.';

  @override
  String get businessOfferBoostPurchasesTitle => 'عمليات التعزيز';

  @override
  String get businessOfferBoostPurchasesEmpty => 'لا توجد عمليات تعزيز بعد.';

  @override
  String get businessOfferAddTitle => 'عرض جديد';

  @override
  String get businessOfferEditTitle => 'تعديل العرض';

  @override
  String get businessOfferTypeLabel => 'على ماذا هذا العرض؟';

  @override
  String get businessOfferTypeMenuItem => 'صنف من المنيو';

  @override
  String get businessOfferTypeProduct => 'منتج';

  @override
  String get businessOfferTypeService => 'خدمة';

  @override
  String get businessOfferPickItem => 'اختر الصنف';

  @override
  String get businessOfferPickItemFirst =>
      'اختر الصنف الذي سيكون عليه العرض أولًا.';

  @override
  String get businessOfferNoItemsFound => 'لا توجد أصناف.';

  @override
  String businessOfferCurrentPrice(String price, String currency) {
    return 'السعر الحالي: $price $currency';
  }

  @override
  String get businessOfferTitleLabel => 'عنوان العرض (اختياري)';

  @override
  String get businessOfferFinalPriceLabel => 'سعر العرض';

  @override
  String businessOfferPriceTooHigh(String price, String currency) {
    return 'سعر العرض لا بد أن يقل عن السعر الحالي ($price $currency).';
  }

  @override
  String get businessOfferEndConditionLabel => 'ينتهي هذا العرض...';

  @override
  String get businessOfferEndsAtLabel => 'في تاريخ محدد';

  @override
  String get businessOfferPickEndDate => 'اختر تاريخ الانتهاء.';

  @override
  String get businessOfferWhileStockLasts => 'حتى نفاد الكمية';

  @override
  String get businessOfferLimitedQuantity => 'بعد كمية محدودة';

  @override
  String get businessOfferQuantityLabel => 'الكمية';

  @override
  String get businessOfferRefundableLabel => 'قابل للاسترجاع';

  @override
  String get drawerSectionProfile => 'إعدادات البروفايل';

  @override
  String get drawerSectionJobsPosts => 'الوظائف والمنشورات';

  @override
  String get drawerSectionMyServices => 'خدماتي';

  @override
  String get chatsListTitle => 'المحادثات';

  @override
  String get chatsListEmpty => 'لا توجد محادثات بعد.';

  @override
  String get chatRenameGroup => 'إعادة تسمية المجموعة';

  @override
  String get chatDeleteGroupConfirm => 'حذف هذه المجموعة للجميع؟';

  @override
  String get chatLeaveGroupConfirm => 'مغادرة هذه المجموعة؟';

  @override
  String get chatLeaveAction => 'مغادرة';

  @override
  String get chatDeleteConfirm => 'حذف هذه المحادثة؟ لا يمكن التراجع عن هذا.';

  @override
  String get offerPerformanceTitle => 'أداء العروض';

  @override
  String get offerPerformanceEmpty => 'لا يوجد نشاط على عروضك بعد.';

  @override
  String get offerPerformanceByOffer => 'حسب العرض';

  @override
  String get offerEventView => 'مشاهدات';

  @override
  String get offerEventClick => 'نقرات';

  @override
  String get offerEventLead => 'استفسارات';

  @override
  String get offerEventConversion => 'تحويلات';

  @override
  String get offerEventShare => 'مشاركات';

  @override
  String get offerEventSave => 'حفظ';

  @override
  String get tableScanTitle => 'طلب طاولة';

  @override
  String get tableScanHint =>
      'أدخل الكود المطبوع على طاولتك للانضمام إلى طلبها.';

  @override
  String get tableScanCodeLabel => 'كود الطاولة';

  @override
  String get tableScanJoin => 'انضمام للطاولة';

  @override
  String get tableCallStaff => 'نداء الطاقم';

  @override
  String get tableCallWaiter => 'نداء النادل';

  @override
  String get tableCallBill => 'طلب الحساب';

  @override
  String get tableCallAssistance => 'طلب مساعدة';

  @override
  String get tableCallsTitle => 'نداءات الطاولات';

  @override
  String get tableCallsEmpty => 'لا توجد طاولة تنادي الآن.';

  @override
  String tableCallTable(String label) {
    return 'طاولة $label';
  }

  @override
  String get tableCallResolve => 'تمت الخدمة';

  @override
  String get tableCallSent => 'تم الإرسال إلى الطاقم.';

  @override
  String get myTripSchedulesTitle => 'خطوط سيري';

  @override
  String get incomingReservationsTitle => 'الحجوزات الواردة';

  @override
  String get tripScheduleAdd => 'نشر خط سير';

  @override
  String get tripScheduleAddTitle => 'خط سير جديد';

  @override
  String get tripSchedulesEmpty => 'لا توجد خطوط سير منشورة بعد.';

  @override
  String get tripScheduleDeleteConfirm => 'حذف خط السير هذا؟';

  @override
  String get tripScheduleModeLabel => 'نوع الرحلة';

  @override
  String get tripScheduleVehicleLabel => 'نوع المركبة';

  @override
  String get tripScheduleInternational => 'رحلة دولية (بين دولتين)';

  @override
  String get tripChooseCountry => 'اختر الدولة';

  @override
  String get tripSchedulePatternLabel => 'تعمل هذه الرحلة...';

  @override
  String get tripSchedulePatternWeekly => 'أسبوعيًا في يوم ثابت';

  @override
  String get tripSchedulePatternOneOff => 'في تاريخ محدد';

  @override
  String get tripSchedulePatternOnDemand => 'عند الطلب';

  @override
  String get tripScheduleDayLabel => 'يوم الأسبوع';

  @override
  String get tripScheduleDateLabel => 'التاريخ';

  @override
  String get tripScheduleDatePickRequired => 'اختر تاريخًا لهذه الرحلة.';

  @override
  String get tripScheduleDepartureTimeLabel => 'وقت الانطلاق';

  @override
  String get tripScheduleReturnTimeLabel => 'وقت العودة';

  @override
  String get tripScheduleNotesLabel => 'ملاحظات';

  @override
  String tripReturnAt(String time) {
    return 'العودة $time';
  }

  @override
  String get tripScheduleCapacityLabel => 'السعة';

  @override
  String get tripSchedulePriceLabel => 'السعر لكل وحدة';

  @override
  String get tripScheduleDepositLabel => 'العربون لكل وحدة (اختياري)';

  @override
  String get tripScheduleStopsTitle => 'نقاط التوقف على الطريق (اختياري)';

  @override
  String get tripScheduleStopLabel => 'اسم النقطة';

  @override
  String get tripScheduleStopAddress => 'العنوان';

  @override
  String get tripScheduleAddStop => '+ أضف نقطة';

  @override
  String get tripScheduleStopBusinessHint =>
      'يمكنك اختيار نشاط تجاري مسجّل (عيادة، محل...) بدلاً من كتابة العنوان يدويًا — يُستخدم موقعه الفعلي (GPS) عند التنفيذ.';

  @override
  String get tripScheduleStopPickBusiness => 'اختر من الأنشطة المسجّلة';

  @override
  String get tripScheduleStopClearBusiness => 'إلغاء الربط';

  @override
  String get tripScheduleStopUsesGps =>
      'سيُستخدم موقع النشاط (GPS) بدلاً من هذا العنوان';

  @override
  String get tripScheduleStopPickBusinessTitle => 'اختر نشاطًا تجاريًا';

  @override
  String get tripScheduleStopSearchHint => 'اكتب اسم النشاط للبحث';

  @override
  String get tripScheduleStopSearchEmpty => 'لا توجد نتائج مطابقة.';

  @override
  String get tripRunStart => 'بدء رحلة';

  @override
  String get tripRunsTitle => 'الرحلات الجارية';

  @override
  String get tripRunEmpty => 'لا توجد رحلات بعد.';

  @override
  String get tripRunStartTitle => 'بدء تنفيذ الرحلة';

  @override
  String get tripRunStartRequiresStops =>
      'أضف نقاط توقف لهذا الخط أولًا قبل بدء تنفيذ الرحلة.';

  @override
  String get tripRunPassengerCountLabel => 'عدد الركاب الفعلي';

  @override
  String get tripRunPassengerCountRequired => 'أدخل عدد الركاب الفعلي.';

  @override
  String tripRunPassengerCountDisplay(int count) {
    return 'عدد الركاب: $count';
  }

  @override
  String get tripRunManifestTitle => 'قائمة المنتجات المحمّلة';

  @override
  String get tripRunManifestItemLabel => 'اسم الصنف';

  @override
  String get tripRunManifestItemUnit => 'الوحدة (اختياري)';

  @override
  String get tripRunManifestItemQty => 'الكمية';

  @override
  String get tripRunAddManifestItem => '+ أضف صنفًا';

  @override
  String get tripRunManifestRequired => 'أضف صنفًا واحدًا على الأقل.';

  @override
  String get tripRunManifestQtyRequired => 'أدخل كمية صحيحة لكل صنف.';

  @override
  String get tripRunStartAction => 'بدء الرحلة';

  @override
  String get tripRunStatusInProgress => 'الرحلة جارية';

  @override
  String get tripRunStatusAwaitingReconciliation => 'بانتظار تسوية المنتجات';

  @override
  String get tripRunStatusCompleted => 'اكتملت المهمة';

  @override
  String tripRunHeadingTo(String stop) {
    return 'متجه إلى $stop';
  }

  @override
  String tripRunArrivedAt(String stop) {
    return 'وصل إلى $stop';
  }

  @override
  String get tripRunArrivedAction => 'لقد وصلت';

  @override
  String tripRunAdvanceToNext(String stop) {
    return 'تم الانتهاء، جاري الانتقال إلى $stop';
  }

  @override
  String get tripRunFinishAction => 'تم الانتهاء بالكامل';

  @override
  String get tripRunCompletedMessage => 'تم إنجاز المهمة بالكامل';

  @override
  String get tripRunNavigate => 'فتح في خرائط جوجل';

  @override
  String get tripRunReconcileTitle => 'تسوية المنتجات';

  @override
  String get tripRunReconcileDelivered => 'تم تسليمه';

  @override
  String get tripRunReconcileReturned => 'مرتجع';

  @override
  String get tripRunReconcileSubmit => 'إرسال التسوية';

  @override
  String get incomingReservationsEmpty => 'لا توجد حجوزات بعد.';

  @override
  String get tripReservationStatusAll => 'الكل';

  @override
  String get tripReservationStatusPending => 'قيد الانتظار';

  @override
  String get tripReservationStatusConfirmed => 'مؤكد';

  @override
  String get tripReservationStatusCompleted => 'مكتمل';

  @override
  String get tripReservationStatusCancelled => 'ملغى';

  @override
  String tripReservationClient(int id) {
    return 'عميل #$id';
  }

  @override
  String tripReservationUnitsCount(int count) {
    return '$count وحدة';
  }

  @override
  String get tripReservationConfirmAction => 'تأكيد';

  @override
  String get tripReservationCompleteAction => 'إكمال';

  @override
  String get tripReservationRejectAction => 'رفض';

  @override
  String get myTrainingClientsTitle => 'عملاء تدريبي';

  @override
  String get trainingClientsEmpty => 'لا توجد خطط عملاء بعد.';

  @override
  String get trainingTemplateApply => 'تطبيق على عميل';

  @override
  String get trainingApplyClientLabel => 'هاتف العميل أو بريده الإلكتروني';

  @override
  String get trainingApplyClientHint =>
      'اكتب الهاتف أو البريد كما هو مسجّل بالضبط، ثم اضغط بحث.';

  @override
  String get trainingApplyFind => 'بحث';

  @override
  String get trainingApplyClientNotFound =>
      'لا يوجد عميل بهذا الهاتف أو البريد بالضبط.';

  @override
  String get trainingApplyStart => 'تاريخ البداية';

  @override
  String get trainingApplyCreate => 'إنشاء الخطة وإرسالها للعميل';

  @override
  String get trainingApplyDone => 'تم إنشاء الخطة وأُرسلت للعميل ليقبلها.';

  @override
  String get trainingTemplateWeeks => 'مدة القالب (أسابيع)';

  @override
  String get trainingDayLabelHint => 'اسم اليوم (Push / Pull / Legs)';

  @override
  String trainingWeekOf(int w, int t) {
    return 'الأسبوع $w من $t';
  }

  @override
  String trainingWeekNumber(int w) {
    return 'الأسبوع $w';
  }

  @override
  String trainingWeightsThisWeek(String w) {
    return 'أوزان هذا الأسبوع: $w كجم';
  }

  @override
  String trainingWeightsNextWeek(String w) {
    return 'الأسبوع القادم: $w كجم';
  }

  @override
  String get trainingProgramTitle => 'البرنامج';

  @override
  String get trainingProgramWeeks => 'عدد الأسابيع';

  @override
  String get trainingProgramEvery => 'زيادة الوزن كل (أسبوع)';

  @override
  String get trainingProgramIncrement => 'مقدار الزيادة (كجم)';

  @override
  String get trainingProgramApply => 'تطبيق على كل التمارين';

  @override
  String get trainingProgramHint =>
      'تُحسب أوزان كل أسبوع تلقائياً من القاعدة، وتنطبق على كل تمرين له وزن.';

  @override
  String get trainingProgramSaved => 'تم تحديث البرنامج.';

  @override
  String get trainingSetWeightsHint => 'الأوزان لكل مجموعة (20-25-30)';

  @override
  String trainingLogSetTitle(int n) {
    return 'تسجيل المجموعة $n';
  }

  @override
  String get trainingSetReps => 'التكرارات';

  @override
  String get trainingSetWeight => 'الوزن (كجم)';

  @override
  String get trainingSetSkipDetails => 'تأكيد بدون تفاصيل';

  @override
  String get trainingTargetWeight => 'الوزن المستهدف (كجم)';

  @override
  String get trainingWeightLabel => 'الوزن';

  @override
  String get trainingKgUnit => 'كجم';

  @override
  String get trainingSessionDone =>
      'أحسنت! أنهيت تمارين اليوم وتم إبلاغ مدربك.';

  @override
  String get trainingMonthlySummary => 'الملخص الشهري';

  @override
  String get trainingMonthSessions => 'أيام مكتملة';

  @override
  String get trainingMonthSets => 'مجموعات';

  @override
  String get trainingMonthReps => 'تكرارات';

  @override
  String get trainingMonthVolume => 'الحجم (كجم)';

  @override
  String get trainingMonthExercises => 'التمارين';

  @override
  String trainingMonthSetsDone(int n) {
    return '$n مجموعة';
  }

  @override
  String get trainingMonthMaxWeight => 'أعلى وزن';

  @override
  String get trainingMonthNoData => 'لا توجد بيانات لهذا الشهر.';

  @override
  String trainingMonthWeight(String from, String to) {
    return 'الوزن: من $from إلى $to كجم';
  }

  @override
  String get trainingSessionsSection => 'الأيام المكتملة';

  @override
  String trainingDayLogTitle(String date) {
    return 'تفاصيل يوم $date';
  }

  @override
  String get trainingPhotoLibrary => 'مكتبة صوري';

  @override
  String get trainingPhotoLibraryEmpty =>
      'لا توجد صور في مكتبتك بعد. أضف صوراً لتستخدمها مع أكثر من متدرب.';

  @override
  String get trainingPhotoLibraryDeleteConfirm =>
      'حذف الصورة من مكتبتك؟ النسخ المرفقة بخطط المتدربين لن تتأثر.';

  @override
  String get trainingPhotoFromLibrary => 'من مكتبتي';

  @override
  String get trainingPhotoPickTitle => 'اختر صوراً من مكتبتك';

  @override
  String trainingPhotoAttach(int n) {
    return 'إرفاق ($n)';
  }

  @override
  String get trainingAddPhoto => 'إضافة صورة';

  @override
  String get trainingPhotoPrivateHint => 'الصور تظهر لك ولعميلك فقط.';

  @override
  String get trainingPickFromLibrary => 'اختيار من مكتبة التمارين';

  @override
  String get trainingLibrarySearch => 'ابحث عن تمرين';

  @override
  String get trainingLibraryAll => 'الكل';

  @override
  String get trainingLibraryEmpty => 'لا توجد تمارين مطابقة.';

  @override
  String trainingWeeklyAverage(int percent) {
    return 'متوسط التزام عملائك هذا الأسبوع: $percent%';
  }

  @override
  String trainingWeeklyRange(String from, String to) {
    return 'الأسبوع من $from إلى $to';
  }

  @override
  String trainingClientWeek(int done, int target, int days, int checkins) {
    return '$done من $target جولة · $days أيام نشطة · $checkins متابعات';
  }

  @override
  String get trainingClientNoSchedule => 'لا توجد تمارين مجدولة بعد';

  @override
  String get trainingPlanStatusActive => 'نشطة';

  @override
  String get trainingPlanStatusPaused => 'متوقفة';

  @override
  String get trainingPlanStatusCompleted => 'مكتملة';

  @override
  String get trainingPlanStatusCancelled => 'ملغاة';

  @override
  String get mealTypeBreakfast => 'فطار';

  @override
  String get mealTypeLunch => 'غداء';

  @override
  String get mealTypeDinner => 'عشاء';

  @override
  String get mealTypeSnack => 'وجبة خفيفة';

  @override
  String get trainingAddExercise => 'إضافة تمرين';

  @override
  String get trainingExerciseName => 'اسم التمرين';

  @override
  String get trainingAnyDay => 'أي يوم';

  @override
  String get trainingSets => 'المجموعات';

  @override
  String get trainingReps => 'التكرارات';

  @override
  String get trainingAddMeal => 'إضافة وجبة';

  @override
  String get trainingMealName => 'اسم الوجبة';

  @override
  String get trainingCalories => 'السعرات الحرارية';

  @override
  String get trainingAddBodyReport => 'إضافة قراءة شهرية';

  @override
  String get trainingBodyReportHint =>
      'قراءة واحدة لكل شهر — إرسال نفس الشهر مرة أخرى يحدّثها.';

  @override
  String get trainingWeightKg => 'الوزن (كجم)';

  @override
  String get trainingMuscleKg => 'الكتلة العضلية (كجم)';

  @override
  String get trainingFatPercent => 'نسبة الدهون %';

  @override
  String get trainingWaterPercent => 'نسبة الماء %';

  @override
  String get trainingExercisesSection => 'التمارين';

  @override
  String get trainingMealsSection => 'الوجبات';

  @override
  String get trainingBodyReportsSection => 'تركيب الجسم';

  @override
  String get storeTermsTitle => 'شروط المتجر';

  @override
  String get storeTermsCustomerTitle => 'شروط المتجر';

  @override
  String get storeTermsHint =>
      'حدّد سياسات متجرك مرة واحدة (الاستبدال، الحد الأدنى للطلب، التسليم…). تظهر للعميل فى صفحتك وعند الشراء، ويحتفظ كل طلب بالشروط وقت إتمامه.';

  @override
  String get storeTermsSave => 'حفظ';

  @override
  String get shopAddonsTitle => 'خدمات المحل';

  @override
  String get shopAddonsEmpty => 'نشاطك لا يقدّم خدمات إضافية.';

  @override
  String get shopAddonsHint =>
      'سعّر خدمات المحل مرة واحدة (مثل المشوى والمقلى والصينية). السعر لكل وحدة بيع (للكيلو مثلًا)، وتظهر لكل أصنافك ويختار العميل واحدة منها، وتظهر فى الفاتورة سطرًا مستقلًا. اترك الخانة فارغة لو لا تقدّم الخدمة.';

  @override
  String get shopAddonPriceHint => 'السعر';

  @override
  String get shopAddonsSaved => 'تم حفظ أسعار الخدمات.';

  @override
  String get cartLineBase => 'الصنف';

  @override
  String get paymentPlanCash => 'كاش';

  @override
  String paymentPlanMonths(int months) {
    return 'تقسيط على $months شهر';
  }

  @override
  String get storeTermsSavedDone => 'تم الحفظ';

  @override
  String get techPricingPlansTitle => 'خطط الدفع (أقساط)';

  @override
  String get techPricingPlansHint =>
      'السعر أعلاه هو سعر الكاش. أضف خطة تقسيط: عدد الأشهر، والمقدم إن وجد، وسعر الوحدة بالتقسيط. العميل يختار كاش أو إحدى الخطط.';

  @override
  String get techPricingPlanTotal => 'سعر الوحدة بالتقسيط';

  @override
  String get techPricingAddPlan => 'إضافة خطة تقسيط';

  @override
  String get techPricingPlanBelowCash => 'سعر التقسيط لا يقل عن سعر الكاش.';

  @override
  String get itemAddonsTitle => 'خدمات المحل على هذا الصنف';

  @override
  String get itemAddonsHint =>
      'اختر ما يتوفر لهذا الصنف من خدمات المحل (طريقة الطهي، التجهيز…). الأسعار تُحدَّد مرة واحدة من «خدمات المحل».';

  @override
  String weightGramsChip(int grams) {
    return '$grams جم';
  }

  @override
  String get weightKilo => 'كجم';

  @override
  String get weightChoose => 'الكمية (الوزن)';

  @override
  String cardInstalment(String monthly, int months) {
    return 'تقسيط من $monthly شهريًا على $months شهر';
  }

  @override
  String get menuInstalmentsOnly => 'بالتقسيط';

  @override
  String get menuSheetMapTitle => 'ربط الأعمدة';

  @override
  String get menuSheetMapHint =>
      'لكل عمود عندنا اختر رقم العمود المقابل له في ملفك. ما تتركه «بدون» لا يُقرأ، ولا يغيّر شيئًا في صنف موجود.';

  @override
  String get menuSheetMapFileColumns => 'أعمدة ملفك';

  @override
  String get menuSheetMapOurColumns => 'أعمدة التطبيق';

  @override
  String get menuSheetMapNone => '— بدون —';

  @override
  String menuSheetMapColumn(int n) {
    return 'عمود $n';
  }

  @override
  String get menuSheetMapPreview => 'معاينة بهذا الربط';

  @override
  String get menuSheetMapReset => 'الربط التلقائي';

  @override
  String menuSheetMapRows(int count) {
    return '$count صف في الملف';
  }

  @override
  String get menuSheetTitle => 'استيراد وتصدير المنيو';

  @override
  String get menuSheetExportHint =>
      'نزّل أصنافك في ملف Excel، عدّلها أو أضف عليها على الكمبيوتر أو الموبايل، ثم ارفع الملف هنا. الملف فيه رقم كل صنف: لو عدّلته يتحدث الصنف نفسه.';

  @override
  String get menuSheetExportItems => 'تصدير أصنافي (Excel)';

  @override
  String get menuSheetExportTemplate => 'نموذج فارغ (Excel)';

  @override
  String get menuSheetImport => 'اختيار ملف للاستيراد';

  @override
  String get menuSheetImportHint =>
      'ملف Excel أو CSV بنفس أعمدة النموذج. «النوع» من أنواع نشاطك، والمقاسات والإضافات والصور والباركود اختيارية — طريقة كتابتها في الورقة الثانية من النموذج. ترى معاينة قبل أي تغيير.';

  @override
  String get menuSheetPreviewTitle => 'معاينة — لم يتغير شيء بعد';

  @override
  String get menuSheetDoneTitle => 'تم الاستيراد';

  @override
  String menuSheetSummary(int created, int updated, int errors) {
    return 'جديد: $created — تحديث: $updated — أخطاء: $errors';
  }

  @override
  String get menuSheetConfirm => 'تأكيد الاستيراد';

  @override
  String menuSheetRow(int row) {
    return 'صف $row';
  }

  @override
  String get menuSheetActionCreate => 'جديد';

  @override
  String get menuSheetActionUpdate => 'تحديث';

  @override
  String get menuSheetActionSection => 'قسم';

  @override
  String get menuSheetActionError => 'خطأ';

  @override
  String get menuSheetEmpty => 'الملف فارغ أو بلا صفوف مقروءة.';

  @override
  String get menuSheetListsSheet => 'الأنواع والوحدات';

  @override
  String get menuSheetTypes => 'النوع';

  @override
  String get menuSheetGroup => 'المجموعة';

  @override
  String get menuSheetUnits => 'الوحدات';

  @override
  String get menuSheetHowTo => 'طريقة الكتابة';

  @override
  String get medicalFileTitle => 'ملفي الطبي';

  @override
  String get medicalFileLocalNote =>
      'محفوظ على هذا الموبايل فقط ومشفّر — لا يُرفع على السيرفر. تشاركه أنت مع الطبيب أو الصيدلي برمز QR لدقائق.';

  @override
  String get medicalBloodType => 'فصيلة الدم';

  @override
  String get medicalBloodUnknown => 'غير معروفة';

  @override
  String get medicalSectionConditions => 'أمراض مزمنة';

  @override
  String get medicalSectionAllergies => 'حساسية';

  @override
  String get medicalSectionMedications => 'أدوية أتناولها';

  @override
  String get medicalSectionSurgeries => 'عمليات سابقة';

  @override
  String get medicalNotes => 'ملاحظات';

  @override
  String get medicalAdd => 'إضافة';

  @override
  String get medicalEntryTitle => 'الاسم';

  @override
  String get medicalEntryDetail => 'تفاصيل (اختياري)';

  @override
  String get medicalEmptySection => 'لا شيء بعد';

  @override
  String get medicalShare => 'مشاركة مع طبيب أو صيدلي';

  @override
  String get medicalScan => 'قراءة ملف مريض';

  @override
  String get medicalShareChoose => 'اختر ما تشاركه';

  @override
  String medicalShareMinutes(int minutes) {
    return '$minutes دقيقة';
  }

  @override
  String get medicalShareCreate => 'إنشاء رمز المشاركة';

  @override
  String get medicalShareShowCode =>
      'اعرض هذا الرمز على الطبيب أو الصيدلي ليقرأه من تطبيقه.';

  @override
  String medicalShareExpires(String time) {
    return 'ينتهي $time';
  }

  @override
  String get medicalShareEnd => 'إنهاء المشاركة الآن';

  @override
  String get medicalShareEnded => 'انتهت المشاركة.';

  @override
  String get medicalScanHint =>
      'وجّه الكاميرا إلى رمز الملف الطبي على موبايل المريض';

  @override
  String medicalSharedBy(String name) {
    return 'الملف الطبي لـ $name';
  }

  @override
  String medicalSharedAt(String time) {
    return 'شاركه $time';
  }

  @override
  String get medicalViewNote => 'يُعرض هنا فقط ولا يُحفظ على هذا الموبايل.';

  @override
  String get medicalShareInvalid => 'هذا ليس رمز ملف طبي.';

  @override
  String get medicalShareUnreadable => 'تعذّر فتح الملف — ربما انتهت المشاركة.';

  @override
  String get medicalShareNothing => 'ملفك فارغ — أضف ما تريد مشاركته أولًا.';

  @override
  String get medicalBackupTitle => 'نسخة احتياطية مشفّرة';

  @override
  String get medicalBackupNone =>
      'لا توجد نسخة احتياطية — لو ضاع هاتفك أو بدّلته يضيع ملفك.';

  @override
  String medicalBackupLast(String time) {
    return 'آخر نسخة احتياطية: $time';
  }

  @override
  String get medicalBackupChanged =>
      'تغيّر الملف بعد آخر نسخة — خُذ نسخة جديدة.';

  @override
  String get medicalBackupNow => 'نسخ احتياطي الآن';

  @override
  String get medicalBackupRestore => 'استعادة من نسخة احتياطية';

  @override
  String get medicalBackupDelete => 'حذف النسخة الاحتياطية';

  @override
  String get medicalBackupPassphrase => 'كلمة سر النسخة الاحتياطية';

  @override
  String get medicalBackupPassphraseAgain => 'أعد كتابة كلمة السر';

  @override
  String get medicalBackupWarning =>
      'هذه الكلمة لا تُحفظ في أي مكان ولا يمكن استرجاعها. لو نسيتها لن يستطيع أحد فتح النسخة، ولا حتى نحن.';

  @override
  String get medicalBackupTooShort => 'كلمة السر 8 أحرف على الأقل.';

  @override
  String get medicalBackupMismatch => 'كلمتا السر غير متطابقتين.';

  @override
  String get medicalBackupWorking => 'جارٍ التشفير… قد يستغرق بضع ثوانٍ.';

  @override
  String get medicalBackupDone => 'تم أخذ النسخة الاحتياطية.';

  @override
  String get medicalBackupRestored => 'تمت الاستعادة.';

  @override
  String get medicalBackupNothing => 'لا توجد نسخة احتياطية لهذا الحساب.';

  @override
  String get medicalBackupWrong => 'كلمة السر خاطئة أو النسخة تالفة.';

  @override
  String get medicalBackupReplace =>
      'الملف الحالي على هذا الموبايل سيُستبدل بالنسخة الاحتياطية. متابعة؟';

  @override
  String get medicalBackupDeleted => 'حُذفت النسخة الاحتياطية.';

  @override
  String get medicalBackupDeleteConfirm =>
      'حذف النسخة الاحتياطية من السيرفر؟ ملفك على هذا الموبايل لا يتأثر.';

  @override
  String get rxArchiveTitle => 'روشتاتي المحفوظة على الهاتف';

  @override
  String get rxArchiveNote =>
      'نسخة من كل روشتة كتبها لك طبيب تُحفظ هنا تلقائيًا، وتبقى معك حتى لو اختفت من السيرفر. تُضاف للنسخة الاحتياطية المشفّرة.';

  @override
  String get rxArchiveEmpty =>
      'لا توجد روشتات محفوظة بعد — تظهر هنا بعد أن تفتح «وصفاتي».';

  @override
  String get rxArchiveOpen => 'روشتاتي على الهاتف';

  @override
  String get rxShowPharmacist => 'عرض على صيدلي (QR)';

  @override
  String get rxShowTitle => 'اعرض الروشتة على الصيدلي';

  @override
  String get rxShowHint =>
      'يقرأ الصيدلي الرمز من تطبيقه فيرى الروشتة ويتأكد أنها من الطبيب نفسه. الروشتة تصل إليه مشفّرة وتنتهي بعد دقائق.';

  @override
  String get rxShowCreate => 'إنشاء رمز العرض';

  @override
  String get rxPurgedNote =>
      'لم يعد السيرفر يحتفظ بالتشخيص والملاحظات لهذه الروشتة المنتهية — نسختك على هذا الهاتف هي الوحيدة الآن. احتفظ بنسخة احتياطية مشفّرة.';

  @override
  String get rxControlledRuleShort => 'روشتة بخط اليد وتُختم «تم الصرف»';

  @override
  String get rxControlledPickTitle => 'دواء ضمن جداول المواد المخدرة';

  @override
  String get rxControlledPickBody =>
      'لا يُكتب هذا الدواء إلا في روشتة بخط اليد، وتصوّرها هنا ليقارنها الصيدلي بالورقة التي مع المريض. حدّد عدد المرات التي سيُصرف فيها؛ وبعد آخر مرة يختم الصيدلي على الورقة «تم الصرف».';

  @override
  String get rxControlledPickOk => 'فهمت';

  @override
  String get rxDispenseTimes => 'عدد مرات الصرف';

  @override
  String get rxDispenseTimesHint =>
      'بعد آخر مرة يختم الصيدلي على الروشتة الورقية «تم الصرف».';

  @override
  String rxDispenseTimesValue(Object count) {
    return '$count مرة';
  }

  @override
  String rxFillingOf(Object limit, Object n) {
    return 'المرة $n من $limit';
  }

  @override
  String get rxFinalFilling =>
      'هذه آخر مرة صرف: بعد التسليم اختم الروشتة الورقية «تم الصرف».';

  @override
  String get rxMoreFillings =>
      'ستبقى الروشتة مفتوحة لمرات أخرى: أعدها للمريض بدون ختم «تم الصرف».';

  @override
  String rxFillingRecorded(Object limit, Object n) {
    return 'سُجّلت المرة $n من $limit.';
  }

  @override
  String get rxFinalRecorded =>
      'تم الصرف — اختم الروشتة الورقية الآن «تم الصرف».';

  @override
  String get rxControlledBadge => 'دواء مخدر';

  @override
  String get rxHandwrittenTitle => 'في الروشتة دواء مخدر';

  @override
  String get rxHandwrittenHint =>
      'منعًا للاحتيال صوّر الروشتة المكتوبة بخط يدك على الورق. الصيدلية تقارنها بالورقة التي مع المريض.';

  @override
  String get rxHandwrittenTake => 'صوّر الروشتة المكتوبة بخط يدك';

  @override
  String get rxHandwrittenRetake => 'أعد التصوير';

  @override
  String get rxHandwrittenRequired =>
      'أضف صورة الروشتة المكتوبة بخط اليد أولًا.';

  @override
  String get rxControlledComparePaper =>
      'دواء مخدر — قارن هذه الصورة بالروشتة الورقية التي مع المريض قبل الصرف.';

  @override
  String get rxControlledNoPaper =>
      'دواء مخدر وليس معه صورة روشتة بخط الطبيب — لا يمكن صرفه.';

  @override
  String get rxNoCopy => 'لا توجد نسخة موثّقة من هذه الروشتة على الهاتف.';

  @override
  String get rxShownTitle => 'روشتة معروضة عليك';

  @override
  String rxShownBy(String name) {
    return 'عرضها $name';
  }

  @override
  String rxIssuedBy(String name) {
    return 'الطبيب: $name';
  }

  @override
  String get rxVerifyWorking => 'جارٍ التحقق من الروشتة…';

  @override
  String get rxVerified => 'موثّقة — مطابقة تمامًا لما كتبه الطبيب';

  @override
  String get rxNotVerified =>
      'غير موثّقة — لا تطابق ما كتبه الطبيب. لا تصرفها.';

  @override
  String get rxCanDispense => 'لم تُصرف بعد ويمكن صرفها.';

  @override
  String get rxAlreadyDispensed => 'صُرفت من قبل — لا تصرفها مرة أخرى.';

  @override
  String get rxCancelledOrOther =>
      'لا يمكن صرفها: ملغاة أو أُرسلت لصيدلية أخرى.';

  @override
  String get rxSuperseded =>
      'عدّلها الطبيب بروشتة أحدث — هذه النسخة لم تعد صالحة.';

  @override
  String get rxDispenseNow => 'تسجيل صرف الروشتة';

  @override
  String get rxDispenseConfirm =>
      'تسجّل أن صيدليتك سلّمت الدواء للمريض الآن. لا يمكن التراجع، ولن تُصرف الروشتة من صيدلية أخرى.';

  @override
  String get rxDispensed => 'تم تسجيل الصرف.';

  @override
  String get rxCheckUnavailable =>
      'التحقق متاح لحسابات الصيدليات فقط — تعرض هنا ما أرسله المريض دون توثيق.';

  @override
  String rxItemDosage(String value) {
    return 'الجرعة: $value';
  }

  @override
  String rxItemQuantity(String value) {
    return 'الكمية: $value';
  }

  @override
  String get rxDiagnosis => 'التشخيص';

  @override
  String get rxNotes => 'ملاحظات الطبيب';

  @override
  String get stayReqButtonIssue => 'بلّغ عن مشكلة';

  @override
  String get stayReqButtonService => 'اطلب خدمة';

  @override
  String get stayReqIssueTitle => 'ما المشكلة في الغرفة؟';

  @override
  String get stayReqServiceTitle => 'ماذا تحتاج؟';

  @override
  String get stayReqNoteHint => 'ملاحظة (اختياري)';

  @override
  String get stayReqNoteHintRequired => 'صِف المشكلة';

  @override
  String get stayReqSend => 'إرسال للفندق';

  @override
  String get stayReqSent => 'وصل طلبك إلى الفندق';

  @override
  String get stayReqMine => 'طلباتك في هذه الإقامة';

  @override
  String get stayReqWithdraw => 'سحب الطلب';

  @override
  String get stayReqNotNow => 'الطلبات متاحة أثناء الإقامة فقط';

  @override
  String get stayReqStatusNew => 'في الانتظار';

  @override
  String get stayReqStatusInProgress => 'قيد التنفيذ';

  @override
  String get stayReqStatusDone => 'تم';

  @override
  String get stayReqStatusCancelled => 'أُلغي';

  @override
  String get stayReqScreenTitle => 'طلبات النزلاء';

  @override
  String get stayReqTabOpen => 'الجارية';

  @override
  String get stayReqTabDone => 'المنتهية';

  @override
  String get stayReqEmpty => 'لا توجد طلبات الآن';

  @override
  String stayReqRoom(String number) {
    return 'غرفة $number';
  }

  @override
  String get stayReqNoRoom => 'بدون رقم غرفة';

  @override
  String get stayReqStart => 'ابدأ التنفيذ';

  @override
  String get stayReqDone => 'تم التنفيذ';

  @override
  String get stayReqCannot => 'تعذّر';

  @override
  String get stayReqKindIssue => 'مشكلة';

  @override
  String get stayReqKindService => 'طلب خدمة';

  @override
  String get stayReqManageServices => 'الخدمات التي يطلبها النزيل';

  @override
  String get stayReqServicesIntro =>
      'ما يستطيع النزيل طلبه أثناء إقامته. أضف ما يقدّمه فندقك وأوقف ما لا تقدّمه.';

  @override
  String get stayReqServicesStarting =>
      'هذه قائمة المنصة المبدئية — عدّلها لتصير قائمتك.';

  @override
  String get stayReqAddServiceHint => 'اسم خدمة، أو عدة أسماء مفصولة بفاصلة';

  @override
  String get stayReqAdd => 'أضف';

  @override
  String get bookingDayUse => 'Day use';

  @override
  String get bookingStayByNight => 'إقامة بالليل';

  @override
  String get bookingDayUseDate => 'يوم Day use';

  @override
  String bookingDayUseWindow(String from, String to) {
    return 'من $from إلى $to';
  }

  @override
  String bookingDayUseTag(String from, String to) {
    return 'Day use · $from–$to';
  }

  @override
  String get dayUseSettingsTitle => 'Day use';

  @override
  String get dayUseSettingsHint =>
      'بيع الغرفة نفسها خلال اليوم بدون مبيت: نافذة وقت وسعر ثابت. يحجز الضيف التاريخ فقط.';

  @override
  String get dayUseEnable => 'أتح Day use لهذا النوع';

  @override
  String get dayUseFrom => 'من';

  @override
  String get dayUseTo => 'إلى';

  @override
  String get dayUsePrice => 'سعر Day use';

  @override
  String get bookingAddOnsTitle => 'إضافات الحجز';

  @override
  String get bookingAddOnsIntro =>
      'ما يضيفه النزيل على سعر الغرفة (كنظام الوجبات) وما تتميّز به غرفة بعينها (كالإطلالة). يُسعَّر كل شيء هنا مرة واحدة.';

  @override
  String get bookingAddOnsGuestChoice => 'ما يختاره النزيل';

  @override
  String get bookingAddOnsRoomFeatures => 'ما تتميّز به الغرفة';

  @override
  String get bookingAddOnsRoomFeaturesHint =>
      'يُسعَّر هنا مرة واحدة، ثم تحدد في كل غرفة أي ميزة تحملها فتُضاف إلى سعرها.';

  @override
  String get bookingAddOnsEmpty => 'لا توجد إضافات لهذا النشاط';

  @override
  String get addOnSelectionSingle => 'اختيار واحد';

  @override
  String get addOnSelectionMultiple => 'أكثر من اختيار';

  @override
  String get addOnPricePerNight => 'الزيادة لكل ليلة';

  @override
  String get addOnPriceFeature => 'الزيادة على سعر الغرفة';

  @override
  String get addOnPerPerson => 'لكل فرد';

  @override
  String get unitFeaturesTitle => 'مميزات الغرفة';

  @override
  String get unitFeaturesHint =>
      'حدد ما تحمله هذه الغرفة. تُسعَّر الميزة مرة في «إضافات الحجز» فيُضاف سعرها إلى سعر الغرفة.';

  @override
  String get bookingNoAddOn => 'بدون';

  @override
  String get bookingDayTitle => 'اليوم';

  @override
  String get bookingStartTime => 'وقت البداية';

  @override
  String get bookingTimeTitle => 'الوقت';

  @override
  String bookingDurationLabel(Object value) {
    return 'المدة: $value';
  }

  @override
  String get bookingDurHour => 'ساعة';

  @override
  String get bookingDurHourHalf => 'ساعة ونصف';

  @override
  String get bookingDurTwoHours => 'ساعتان';

  @override
  String bookingDurHours(Object n) {
    return '$n ساعات';
  }

  @override
  String get bookingBookNow => 'احجز الآن';

  @override
  String get bookingBookTable => 'احجز طاولة';

  @override
  String get bookingHourlyHint => 'اختر يومًا ووقتًا ثم الملعب أو القاعة';

  @override
  String get bookingTableHint => 'اختر يومًا ووقتًا لتظهر الطاولات المتاحة';

  @override
  String get bookingClosedDay => 'النشاط مغلق في هذا اليوم';

  @override
  String get bookingNoFreeTime => 'لا توجد أوقات متاحة في هذا اليوم';

  @override
  String get bookingPartySizeLabel => 'عدد الأفراد';

  @override
  String bookingPartyPeople(Object n) {
    return '$n أفراد';
  }

  @override
  String bookingTablesAt(Object time) {
    return 'الطاولات المتاحة الساعة $time';
  }

  @override
  String bookingSeatsUpTo(Object n) {
    return 'تتسع لـ $n أفراد';
  }

  @override
  String get bookingHourWord => 'ساعة';

  @override
  String get bookingNightWord => 'ليلة';

  @override
  String get bookingWhenStay => 'متى تريد الإقامة؟';

  @override
  String get bookingArrival => 'الوصول';

  @override
  String get bookingDeparture => 'المغادرة';

  @override
  String get bookingGuests => 'الضيوف';

  @override
  String bookingGuestsCount(Object n) {
    return '$n ضيوف';
  }

  @override
  String get bookingAvailableInDates => 'المتاح في هذه التواريخ';

  @override
  String bookingUnitsCount(Object n) {
    return '$n وحدات';
  }

  @override
  String get bookingNoUnitsInDates => 'لا توجد وحدات متاحة في هذه التواريخ.';

  @override
  String get bookingPickUnitToContinue => 'اختر وحدة للمتابعة';

  @override
  String get bookingContinue => 'متابعة';

  @override
  String get bookingServiceTitle => 'الخدمة';

  @override
  String get bookingPickDayTitle => 'اختر اليوم';

  @override
  String get bookingPickTimeTitle => 'اختر الوقت';

  @override
  String get bookingConfirmAppointment => 'تأكيد الموعد';

  @override
  String bookingMinutes(Object n) {
    return '$n دقيقة';
  }

  @override
  String get courseLevelTitle => 'المستوى';

  @override
  String get courseLevelAll => 'الكل';

  @override
  String get courseGroupsTitle => 'المجموعات المتاحة';

  @override
  String courseStartsOn(Object date) {
    return 'يبدأ $date';
  }

  @override
  String courseSeatsLeft(Object n) {
    return 'متبقٍ $n مقاعد';
  }

  @override
  String get courseSeatsFull => 'اكتملت المقاعد';

  @override
  String get coursePerCourse => 'ج / الكورس';

  @override
  String get courseEnroll => 'التحق بالكورس';

  @override
  String get courseNoGroups => 'لا توجد مجموعات مفتوحة حاليًا.';

  @override
  String get courseHint => 'اختر مجموعة';

  @override
  String get courseManageTitle => 'مجموعات الكورسات';

  @override
  String get courseAddGroup => 'إضافة مجموعة';

  @override
  String get courseEditGroup => 'تعديل المجموعة';

  @override
  String get courseOfCourse => 'الكورس';

  @override
  String get courseGroupName => 'اسم المجموعة';

  @override
  String get courseGroupLevel => 'المستوى';

  @override
  String get courseGroupLevelHint => 'مبتدئ / متوسط / متقدم';

  @override
  String get courseGroupSchedule => 'المواعيد (مثال: الأحد والثلاثاء · 7 م)';

  @override
  String get courseGroupStarts => 'البدء';

  @override
  String get courseGroupEnds => 'تاريخ الانتهاء (اختياري)';

  @override
  String get courseGroupEndsShort => 'الانتهاء';

  @override
  String get courseGroupSeats => 'عدد المقاعد';

  @override
  String get courseGroupOpen => 'مفتوحة للانضمام';

  @override
  String get courseGroupClosed => 'مغلقة';

  @override
  String courseTaken(Object seats, Object taken) {
    return '$taken من $seats مقعدًا';
  }

  @override
  String get courseNoCourses =>
      'لا توجد كورسات بعد — أضف كورسًا من «أسعاري» أولًا.';

  @override
  String get courseDeleteGroup => 'حذف المجموعة';

  @override
  String get courseNameRequired => 'اكتب اسم المجموعة.';

  @override
  String get arrivalNoticeTitle => 'تنبيه الحضور';

  @override
  String get arrivalNoticeIntro =>
      'يقرؤه العميل عند الحجز وبعده، ويُكرَّر في تذكير الموعد.';

  @override
  String get arrivalNoticeMinutes => 'يجب التواجد قبل الموعد بـ';

  @override
  String get arrivalNoticeNone => 'بدون';

  @override
  String get arrivalNoticeText => 'جملة إضافية (اختياري)';

  @override
  String get arrivalNoticePreview => 'هكذا يقرؤه العميل';

  @override
  String get queueYourTurn => 'دورك';

  @override
  String queueTurnNumber(Object n) {
    return 'الدور رقم $n';
  }

  @override
  String queueExpectedAt(Object time) {
    return 'الساعة تقريبًا $time';
  }

  @override
  String queueAhead(Object n) {
    return 'أمامك $n';
  }

  @override
  String get queueNoneAhead => 'لا أحد أمامك';

  @override
  String get queueFull => 'اكتمل دور هذا اليوم';

  @override
  String get queueClosed => 'النشاط مغلق في هذا اليوم';

  @override
  String get queueTake => 'احجز دوري';

  @override
  String queueTurnTaken(Object n, Object time) {
    return 'تم حجز دورك رقم $n — الساعة تقريبًا $time';
  }

  @override
  String get queueEstimateNote => 'الوقت تقريبي ويتغير مع سير الطابور.';

  @override
  String get bookingFlowTitle => 'طريقة الحجز';

  @override
  String get bookingFlowIntro => 'اختر كيف يحجز عملاؤك مواعيدهم معك.';

  @override
  String get bookingFlowSlots => 'بالموعد';

  @override
  String get bookingFlowSlotsSub =>
      'العميل يختار اليوم والوقت من الأوقات المتاحة.';

  @override
  String get bookingFlowQueue => 'بالدور';

  @override
  String get bookingFlowQueueSub =>
      'العميل يختار اليوم فقط ويأخذ الدور التالي مع الساعة التقريبية.';

  @override
  String get chairPickTitle => 'اختر الحلاق';

  @override
  String get chairAnyone => 'أي حلاق متاح';

  @override
  String chairWithPerson(Object name) {
    return 'مع $name';
  }

  @override
  String get chairsTitle => 'الكراسي والحلاقون';

  @override
  String get chairsIntro =>
      'كل كرسي له صف دور خاص به. يختار العميل الحلاق أو أيّ كرسي متاح.';

  @override
  String get chairAdd => 'إضافة كرسي';

  @override
  String get chairEdit => 'تعديل الكرسي';

  @override
  String get chairName => 'اسم الكرسي (مثال: كرسي ١)';

  @override
  String get chairPerson => 'اسم الحلاق';

  @override
  String get chairPhoto => 'صورة الحلاق';

  @override
  String get chairChoosePhoto => 'اختر صورة';

  @override
  String get chairRemovePhoto => 'إزالة الصورة';

  @override
  String get chairOpen => 'متاح للحجز';

  @override
  String get chairDelete => 'حذف الكرسي';

  @override
  String get chairsEmpty =>
      'لا توجد كراسي بعد. أضف كرسيًا وصورة الحلاق ليختاره العملاء.';

  @override
  String get chairNeedsName => 'اكتب اسم الكرسي أو اسم الحلاق.';

  @override
  String get chairClosed => 'مغلق';

  @override
  String get queueConsoleTitle => 'نداء الدور';

  @override
  String get queueNowServing => 'يُخدَم الآن';

  @override
  String get queueCalled => 'تم ندائه';

  @override
  String get queueWaiting => 'في الانتظار';

  @override
  String get queueCallNext => 'نادِ التالي';

  @override
  String get queueCallAgain => 'نادِه مرة أخرى';

  @override
  String get queueStart => 'ابدأ الخدمة';

  @override
  String get queueFinish => 'تمّت الخدمة';

  @override
  String get queueNobody => 'لا أحد في الانتظار';

  @override
  String get queueAddWalkIn => 'إضافة عميل بدون حجز';

  @override
  String get queueWalkInTitle => 'دور لعميل بدون حجز';

  @override
  String get queueWalkInName => 'اسم العميل';

  @override
  String get queueWalkInPhone => 'رقم الهاتف (اختياري)';

  @override
  String get queueWalkInService => 'الخدمة';

  @override
  String get queueWalkInAdd => 'أضف الدور';

  @override
  String queueWalkInAdded(Object n) {
    return 'أُضيف الدور رقم $n';
  }

  @override
  String queueTurnShort(Object n) {
    return 'دور $n';
  }

  @override
  String get queueWalkInTag => 'بدون حجز';

  @override
  String get queueNoChair => 'بدون كرسي محدد';

  @override
  String get queueCalledSent => 'تم نداء العميل';

  @override
  String get chairFromStaff => 'من فريق العمل (اختياري)';

  @override
  String get chairNotStaff => 'بدون — أكتب الاسم والصورة بنفسي';

  @override
  String get chairStaffHint =>
      'يظهر اسم الموظف وصورة حسابه على الكرسي، وما تكتبه أدناه يغلب عليهما.';

  @override
  String get myChairTitle => 'كرسيي';

  @override
  String get myChairServed => 'خدمتُهم اليوم';

  @override
  String get myChairNone =>
      'لم يُربط حسابك بكرسي في هذا النشاط بعد. اطلب من صاحب النشاط أن يضعك على كرسي.';

  @override
  String get bookingPickUnitTitle => 'اختر غرفتك';

  @override
  String bookingUnitsAvailableCount(int count) {
    return '$count متاحة';
  }

  @override
  String get bookingPerNight => '/ ليلة';

  @override
  String get bookingPerHour => '/ ساعة';

  @override
  String bookingPriceIncludes(String features) {
    return 'شامل $features';
  }

  @override
  String get bookingUnitNotPriced => 'لم تُسعَّر بعد';

  @override
  String bookingDayUseCardHint(String from, String to) {
    return 'بلا مبيت — من $from إلى $to';
  }

  @override
  String get bookingDayUseMealsTitle => 'وجبات (اختياري)';

  @override
  String get bookingDayUseMealsHint =>
      'يمكن اختيار أكثر من وجبة — تُضاف إلى سعر اليوم';

  @override
  String get bookingNightPrice => 'سعر الليلة';

  @override
  String bookingTimesNights(int count) {
    return '× $count ليلة';
  }

  @override
  String get bookingBasePriceLine => 'الغرفة';

  @override
  String get trainingFoodTable => 'جدول التغذية';

  @override
  String get trainingPickFood => 'اختر من جدول التغذية';

  @override
  String get trainingFoodSearch => 'ابحث عن صنف';

  @override
  String get trainingFoodServings => 'عدد الحصص';

  @override
  String trainingFoodKcal(int kcal) {
    return '$kcal سعرة';
  }

  @override
  String trainingFoodMacros(String p, String c, String f) {
    return 'بروتين $p · كربوهيدرات $c · دهون $f';
  }

  @override
  String get trainingAddOwnFood => 'أضف صنفًا خاصًا';

  @override
  String get trainingFoodName => 'اسم الصنف';

  @override
  String get trainingFoodServingLabel => 'الحصة (مثال: طبق 200 جم)';

  @override
  String get trainingFoodCalories => 'السعرات للحصة';

  @override
  String get trainingFoodProtein => 'بروتين (جم)';

  @override
  String get trainingFoodCarbs => 'كربوهيدرات (جم)';

  @override
  String get trainingFoodFat => 'دهون (جم)';

  @override
  String get trainingFoodSection => 'القسم';

  @override
  String get trainingFoodEmpty => 'لا توجد أصناف مطابقة';

  @override
  String get trainingFoodApprox => 'القيم تقريبية للحصة المذكورة.';

  @override
  String get trainingMine => 'من إضافتك';

  @override
  String get trainingEditEntry => 'تعديل';

  @override
  String get trainingDeleteOwnConfirm =>
      'حذف هذا العنصر؟ الخطط التي استخدمته تحتفظ بنسختها.';

  @override
  String get trainingAddOwnExercise => 'أضف تمرينًا خاصًا';

  @override
  String get trainingOwnExerciseTitle => 'تمرين خاص';

  @override
  String get trainingExerciseSection => 'القسم';

  @override
  String get trainingExerciseInstructions => 'تعليمات التنفيذ';

  @override
  String get trainingMealFromTable => 'من الجدول — السعرات محسوبة لك';

  @override
  String get trainingLibraryEquipment => 'المعدات';

  @override
  String get addOnPricePerDay => 'الزيادة على سعر اليوم';

  @override
  String get invTitle => 'طلبات الفحوصات';

  @override
  String get invOrderTests => 'طلب فحوصات';

  @override
  String get invMyOrdersEmpty => 'لا توجد طلبات فحوصات بعد.';

  @override
  String get invStatusIssued => 'صدر الطلب';

  @override
  String get invStatusSent => 'أُرسل لجهة';

  @override
  String get invStatusAccepted => 'تم القبول';

  @override
  String get invStatusReady => 'النتيجة جاهزة';

  @override
  String get invStatusDeclined => 'اعتُذر عنه';

  @override
  String get invStatusCancelled => 'مُلغى';

  @override
  String get invStepIssued => 'صدر الطلب';

  @override
  String get invStepSent => 'أُرسل لمعمل';

  @override
  String get invStepAccepted => 'تم الاستلام';

  @override
  String get invStepReady => 'النتيجة جاهزة';

  @override
  String invFromDoctor(String doctor) {
    return 'من $doctor';
  }

  @override
  String get invOwnRequest => 'طلب ذاتي';

  @override
  String get invKindLab => 'تحليل';

  @override
  String get invKindRadiology => 'أشعة';

  @override
  String invDoctorNote(String note) {
    return 'ملاحظة الطبيب: $note';
  }

  @override
  String get invShareTitle => 'شارك الطلب مع معمل مسجّل';

  @override
  String get invShareHint => 'سعر المجموعة كاملة عند كل جهة';

  @override
  String get invCoversAll => 'يغطي كل الفحوصات';

  @override
  String invCoversSome(int covers, int of) {
    return 'يغطي $covers من $of';
  }

  @override
  String get invShareNever => 'لا يصل الطلب لأي جهة إلا بعد أن تختارها أنت.';

  @override
  String invShareButton(String center) {
    return 'شارك مع $center';
  }

  @override
  String get invNoCenters => 'لا توجد جهات مسجّلة تجري هذه الفحوصات بعد.';

  @override
  String get invCancelOrder => 'إلغاء الطلب';

  @override
  String get invCancelConfirm => 'إلغاء هذا الطلب؟';

  @override
  String get invSent => 'تم إرسال الطلب إلى الجهة.';

  @override
  String get invResults => 'النتائج';

  @override
  String invCenterNote(String note) {
    return 'ملاحظة الجهة: $note';
  }

  @override
  String invAppointment(String when) {
    return 'الموعد: $when';
  }

  @override
  String get invTotal => 'الإجمالي';

  @override
  String get invNotPriced => 'غير مسعّر عند المركز';

  @override
  String get hospitalTabDepartments => 'الأقسام والأطباء';

  @override
  String get hospitalNoDepartments => 'لا توجد أقسام معروضة بعد.';

  @override
  String get hospitalNoDoctors => 'لا يوجد أطباء في هذا القسم بعد.';

  @override
  String hospitalDoctorCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أطباء',
      two: 'طبيبان',
      one: 'طبيب واحد',
      zero: 'لا أطباء',
    );
    return '$_temp0';
  }

  @override
  String get hospitalManageTitle => 'أقسام وأطباء المستشفى';

  @override
  String get hospitalManageHint =>
      'الأقسام هي التخصصات التي فعّلتها في إعدادات النشاط. أضف الأطباء تحت كل قسم.';

  @override
  String get hospitalManageNoDepartments =>
      'فعّل التخصصات الطبية أولًا من «إعدادات النشاط» لتظهر هنا كأقسام.';

  @override
  String get hospitalAddDoctor => 'إضافة طبيب';

  @override
  String get hospitalDoctorWithAccount => 'حساب على التطبيق';

  @override
  String get hospitalDoctorNoAccount => 'بدون حساب';

  @override
  String get hospitalSearchDoctorHint => 'ابحث عن الطبيب بالاسم';

  @override
  String get hospitalInviteNote =>
      'يظهر الطبيب في القسم بعد أن يوافق على دعوتك، ويستطيع المريض زيارة صفحته من تحت القسم.';

  @override
  String get hospitalDoctorName => 'اسم الطبيب';

  @override
  String get hospitalDoctorTitle => 'اللقب (اختياري)';

  @override
  String get hospitalDoctorPending => 'بانتظار موافقة الطبيب';

  @override
  String get hospitalDoctorRemoveConfirm => 'إزالة هذا الطبيب من القسم؟';

  @override
  String get hospitalInvitationsTitle => 'دعوات المستشفيات';

  @override
  String get hospitalInvitationsEmpty => 'لا توجد دعوات.';

  @override
  String get hospitalInvitationPendingSection => 'دعوات بانتظار ردك';

  @override
  String get hospitalInvitationActiveSection => 'تظهر ضمن أطباء';

  @override
  String get hospitalInvitationAccept => 'قبول';

  @override
  String get hospitalInvitationDecline => 'رفض';

  @override
  String get hospitalInvitationLeave => 'إنهاء الظهور';

  @override
  String get procKindSurgery => 'الجراحة العامة';

  @override
  String get procKindOrthopedic => 'العظام والمفاصل';

  @override
  String get procKindObstetrics => 'النساء والتوليد';

  @override
  String get procKindUrology => 'المسالك البولية والكلى';

  @override
  String get procKindEnt => 'الأنف والأذن والحنجرة';

  @override
  String get procKindOphthalmology => 'العيون';

  @override
  String get procKindCardiac => 'القلب والصدر والأوعية الدموية';

  @override
  String get procKindNeuro => 'المخ والأعصاب والعمود الفقري';

  @override
  String get procKindPlastic => 'التجميل والحروق';

  @override
  String get procKindPediatric => 'جراحة الأطفال';

  @override
  String get procKindOncology => 'جراحة الأورام';

  @override
  String get procKindBariatric => 'جراحة السمنة';

  @override
  String get procKindMaxillofacial => 'الوجه والفكين والأسنان';

  @override
  String get procKindEndoscopy => 'مناظير';

  @override
  String get procKindProcedure => 'إجراءات علاجية';

  @override
  String get procStatusRequested => 'بانتظار رد المستشفى';

  @override
  String get procStatusAccepted => 'تم تحديد الموعد';

  @override
  String get procStatusCompleted => 'تم';

  @override
  String get procStatusDeclined => 'اعتذر المستشفى';

  @override
  String get procStatusCancelled => 'ملغي';

  @override
  String get procPriceAfterAssessment => 'السعر بعد التقييم';

  @override
  String procScheduledAt(Object when) {
    return 'الموعد: $when';
  }

  @override
  String procPreferredDate(Object date) {
    return 'اليوم المفضل: $date';
  }

  @override
  String procHospitalNote(Object note) {
    return 'ملاحظة المستشفى: $note';
  }

  @override
  String get specialtyServicesTitle => 'خدمات العيادة';

  @override
  String get specialtyServicesHint =>
      'اختر الخدمات التي تقدمها عيادتك واكتب سعر كل خدمة. اترك السعر فارغاً ليظهر «السعر بعد الكشف».';

  @override
  String get specialtyPriceAfterExam => 'السعر بعد الكشف';

  @override
  String get specialtyAddOwn => 'إضافة خدمة';

  @override
  String get specialtyOwnName => 'اسم الخدمة';

  @override
  String get dentalKindCheckup => 'الأشعة والتشخيص';

  @override
  String get dentalKindPreventive => 'الوقاية والتنظيف';

  @override
  String get dentalKindRestorative => 'الحشو والترميم';

  @override
  String get dentalKindEndodontic => 'علاج الجذور (العصب)';

  @override
  String get dentalKindPeriodontal => 'اللثة';

  @override
  String get dentalKindSurgical => 'الجراحة والزراعة';

  @override
  String get dentalKindProsthetic => 'التركيبات';

  @override
  String get dentalKindOrthodontic => 'التقويم';

  @override
  String get dentalKindCosmetic => 'تجميل الأسنان';

  @override
  String get dentalKindPediatric => 'أسنان الأطفال';

  @override
  String get skinKindInjectables => 'الحقن التجميلية';

  @override
  String get skinKindFaceLifting => 'شد وتجديد الوجه بلا جراحة';

  @override
  String get skinKindLaser => 'الليزر';

  @override
  String get skinKindScars => 'الندبات والجروح';

  @override
  String get skinKindPeels => 'التقشير وعلاج البشرة';

  @override
  String get skinKindSkinDisease => 'الأمراض الجلدية';

  @override
  String get skinKindHair => 'الشعر وفروة الرأس';

  @override
  String get skinKindBody => 'الجسم';

  @override
  String get procTabTitle => 'الإجراءات الطبية';

  @override
  String get procNoneOffered => 'لا يعرض المستشفى إجراءات بعد.';

  @override
  String get procRequestSent => 'أُرسل طلبك إلى المستشفى.';

  @override
  String get procMyRequestsTitle => 'طلباتي من المستشفيات';

  @override
  String get procMyRequestsEmpty => 'لا توجد طلبات بعد.';

  @override
  String get procPickPreferredDate => 'اليوم المفضل (اختياري)';

  @override
  String get procAskButton => 'اطلب الإجراء';

  @override
  String get procAskNote =>
      'يردّ المستشفى بموعد، وقد يطلب تقييمك قبل تحديد السعر.';

  @override
  String get procCancelRequest => 'إلغاء الطلب';

  @override
  String get procManageTitle => 'إجراءات المستشفى الطبية';

  @override
  String get procManageHint =>
      'اختر ما يجريه المستشفى واكتب سعره. اترك السعر فارغًا ليظهر «السعر بعد التقييم».';

  @override
  String get procAddOwn => 'إضافة إجراء';

  @override
  String get procOwnName => 'اسم الإجراء';

  @override
  String get procRequestsTitle => 'طلبات الإجراءات';

  @override
  String get procTabUpcoming => 'القادمة';

  @override
  String get procRequestsEmpty => 'لا توجد طلبات.';

  @override
  String get procPickSchedule => 'موعد الإجراء';

  @override
  String get procQuoteTitle => 'سعر الإجراء بعد التقييم';

  @override
  String get procSkipQuote => 'بدون سعر';

  @override
  String get procAcceptSchedule => 'قبول وتحديد موعد';

  @override
  String get procMarkDone => 'تم الإجراء';

  @override
  String get importHubTitle => 'استيراد بياناتي';

  @override
  String get importHubIntro =>
      'أحضر بياناتك القديمة من ملف Excel أو CSV بدل أن تبدأ من الصفر: اختر ما تريد استيراده، ثم الملف، ثم اربط أعمدته بأعمدتنا.';

  @override
  String get importHubMenu => 'المنيو والأصناف';

  @override
  String get importHubMenuSub =>
      'الأقسام وأصنافها بأسعارها ومقاساتها وإضافاتها';

  @override
  String get importHubPatients => 'ملفات المرضى';

  @override
  String get importHubPatientsSub =>
      'المرضى وتاريخهم المرضي — تُحفظ على هذا الجهاز فقط';

  @override
  String get importHubUnits => 'الغرف والوحدات';

  @override
  String get importHubUnitsSub =>
      'الغرف أو الملاعب أو القاعات برقمها ونوعها وسعتها';

  @override
  String get unitsImportIntro =>
      'اختر الخدمة ونوع الوحدة مرة واحدة، ثم الملف: كل صف وحدة (رقمها واسمها ونوعها وسعتها وعددها). ما كان موجودًا بنفس الرقم يُترك كما هو.';

  @override
  String get unitsImportService => 'الخدمة';

  @override
  String get unitsImportType => 'نوع الوحدة';

  @override
  String get unitsImportKind => 'تصنيف الوحدة إن لم يحدّده الملف';

  @override
  String get unitsImportKindHelp =>
      'يُطابَق عمود «النوع» في الملف مع تصنيفاتك أولًا';

  @override
  String get unitsImportKindNone => 'بدون تصنيف';

  @override
  String get unitsImportNext => 'التالي: اختيار الملف';

  @override
  String get unitsImportNone => 'لا توجد خدمة بوحدات قابلة للحجز لهذا الحساب.';

  @override
  String get clinicStartVisit => 'بدء الكشف';

  @override
  String get clinicCreateFileShort => 'إنشاء ملف';

  @override
  String get importHubNothing => 'لا يوجد ما يمكن استيراده لهذا الحساب بعد.';

  @override
  String get importPickFile => 'اختيار ملف';

  @override
  String get importTemplate => 'نموذج جاهز';

  @override
  String get importFileEmpty => 'الملف فارغ أو لا يحوي صفوفًا بعد صف العناوين.';

  @override
  String get importFileUnreadable =>
      'تعذّرت قراءة هذا الملف. جرّب ملف Excel (xlsx) أو CSV.';

  @override
  String importFileInfo(Object count, Object name) {
    return '$name — $count صفًا';
  }

  @override
  String get importMapHint =>
      'اختر لكل عمود عندنا اسم العمود المقابل في ملفك. سنتذكر هذا الربط للملفات المشابهة.';

  @override
  String get importNotUsed => '— لا أستخدمه —';

  @override
  String get importUnnamedColumn => 'بلا اسم';

  @override
  String importRun(Object count) {
    return 'استيراد $count صف';
  }

  @override
  String get importRequiredMissing => 'اربط الأعمدة المطلوبة (*) أولًا.';

  @override
  String get importDone => 'تم الاستيراد';

  @override
  String importCreated(Object count) {
    return 'ملفات جديدة: $count';
  }

  @override
  String importMerged(Object count) {
    return 'أُضيف إلى ملفات موجودة: $count';
  }

  @override
  String importSkipped(Object count) {
    return 'تم تخطي $count صف:';
  }

  @override
  String importSkippedRow(Object reason, Object row) {
    return 'الصف $row: $reason';
  }

  @override
  String get patientFilesTitle => 'ملفات المرضى';

  @override
  String get patientFilesDeviceNote =>
      'هذه الملفات محفوظة على هذا الجهاز فقط ومشفّرة، ولا تُرفع إلى السيرفر.';

  @override
  String get patientFilesSearch => 'ابحث بالاسم أو الهاتف';

  @override
  String get patientFilesEmpty => 'لا توجد ملفات على هذا الجهاز بعد.';

  @override
  String get patientFilesImport => 'استيراد ملفات المرضى';

  @override
  String get patientFilesImportIntro =>
      'من ملف Excel أو CSV: اسم المريض مطلوب، وما عداه اختياري. الصفوف التي لها نفس الهاتف تُضم في ملف واحد بزياراتها، وما يوجد مسبقًا لا يتكرر.';

  @override
  String get patientFilesAdd => 'إضافة مريض';

  @override
  String patientFilesCount(Object count) {
    return '$count ملفًا';
  }

  @override
  String patientFileEntryCount(Object count) {
    return '$count سجلًا';
  }

  @override
  String get patientFileName => 'اسم المريض';

  @override
  String get patientFilePhone => 'رقم الهاتف';

  @override
  String get patientFileNationalId => 'الرقم القومي';

  @override
  String get patientFileBirth => 'تاريخ الميلاد';

  @override
  String get patientFileGender => 'النوع';

  @override
  String get patientFileChronic => 'الأمراض المزمنة';

  @override
  String get patientFileAllergies => 'الحساسية';

  @override
  String get patientFileNotes => 'ملاحظات';

  @override
  String get patientFileEdit => 'تعديل البيانات';

  @override
  String get patientFileDelete => 'حذف الملف';

  @override
  String get patientFileDeleteConfirm => 'حذف هذا الملف من الجهاز نهائيًا؟';

  @override
  String get patientFileAddEntry => 'إضافة سجل';

  @override
  String get patientFileEntryTitle =>
      'العنوان (التشخيص، اسم التحليل، الأشعة، الدواء)';

  @override
  String get patientFileEntryDetail => 'تفاصيل (اختياري)';

  @override
  String get patientFileNoEntries =>
      'لا توجد سجلات بعد. أضف زيارة أو تحليلًا أو أشعة أو دواءً.';

  @override
  String get patientFileSendCopy => 'إرسال نسخة للمريض';

  @override
  String get patientFileOpen => 'ملف المريض';

  @override
  String get patientFileCreate => 'إنشاء ملف للمريض';

  @override
  String get recordKindVisit => 'زيارة';

  @override
  String get recordKindTest => 'تحليل';

  @override
  String get recordKindRadiology => 'أشعة';

  @override
  String get recordKindMedicine => 'دواء';

  @override
  String get recordKindNote => 'ملاحظة';

  @override
  String get medicalSectionRecords => 'سجل الزيارات والتحاليل';

  @override
  String get medicalSaveToMyFile => 'حفظ نسخة في ملفي الطبي';

  @override
  String get medicalSavedToMyFile => 'تم الحفظ في ملفك الطبي على هذا الهاتف.';

  @override
  String get patientBackupTitle => 'نسخة احتياطية مشفّرة';

  @override
  String get patientBackupIntro =>
      'تُضغط ملفات المرضى وتُشفَّر على هذا الجهاز بكلمة سر لا يعرفها غيرك. احفظ النسخة كملف تضعه حيث تشاء (درايف، فلاشة، بريد)، أو على السيرفر الذي لا يستطيع قراءة شيء منها.';

  @override
  String get patientBackupPassphraseWarning =>
      'كلمة السر لا تُحفظ في أي مكان: إن نسيتها ضاعت النسخة ولا يمكن استرجاعها.';

  @override
  String get patientBackupNever => 'لم تُعمل نسخة احتياطية بعد';

  @override
  String patientBackupLast(Object when) {
    return 'آخر نسخة: $when';
  }

  @override
  String patientBackupChanged(Object changed, Object total) {
    return 'تغيّر بعدها $changed من $total ملفًا';
  }

  @override
  String get patientBackupToFile => 'حفظ نسخة في ملف';

  @override
  String get patientBackupToServer => 'حفظ نسخة على السيرفر (مشفّرة)';

  @override
  String get patientBackupRestoreTitle => 'استرجاع';

  @override
  String get patientBackupFromFile => 'استرجاع من ملف';

  @override
  String get patientBackupFromServer => 'استرجاع من السيرفر';

  @override
  String get patientBackupMergeNote =>
      'الاسترجاع يدمج: يضيف الملفات غير الموجودة، ولا يستبدل ملفًا إلا بنسخة أحدث منه.';

  @override
  String get patientBackupDeleteServerCopy => 'حذف نسخة السيرفر';

  @override
  String get patientBackupServerDeleted => 'حُذفت نسخة السيرفر.';

  @override
  String get patientBackupFileMade => 'تم تجهيز النسخة.';

  @override
  String get patientBackupServerDone => 'حُفظت النسخة على السيرفر.';

  @override
  String get patientBackupNoServerCopy => 'لا توجد نسخة على السيرفر.';

  @override
  String get patientBackupWrongPassphrase =>
      'كلمة السر غير صحيحة أو أن الملف ليس نسخة لملفات المرضى.';

  @override
  String get patientBackupFailed => 'تعذّر إتمام العملية.';

  @override
  String patientBackupRestored(Object added, Object updated) {
    return 'أُضيف $added ملفًا وتحدّث $updated.';
  }

  @override
  String get patientBackupChoosePassphrase => 'اختر كلمة سر للنسخة';

  @override
  String get patientBackupEnterPassphrase => 'أدخل كلمة سر النسخة';

  @override
  String get patientBackupPassphrase => 'كلمة السر';

  @override
  String get patientBackupPassphraseAgain => 'أعد كتابة كلمة السر';

  @override
  String patientBackupPassphraseShort(Object min) {
    return 'كلمة السر $min أحرف على الأقل.';
  }

  @override
  String get patientBackupPassphraseMismatch => 'كلمتا السر غير متطابقتين.';

  @override
  String get invWriteResults => 'كتابة النتائج';

  @override
  String get invResultsTextHint =>
      'اكتب نتيجة كل فحص هنا أو الصقها كما في جهاز المعمل: تُقرأ في التطبيق نصًّا وتوفّر مساحة. استخدم الصور لما ليس نصًّا فقط (فيلم أشعة، ورقة موقّعة).';

  @override
  String get invResultHint => 'مثال: Hb 13.2 g/dL (12–16)';

  @override
  String get invAddResultPhotos => 'إضافة صور (لما ليس نصًّا)';

  @override
  String invResultPhotosCount(Object count) {
    return '$count صورة مرفقة';
  }

  @override
  String get invSendResults => 'إرسال النتائج';

  @override
  String get invSaveToMyFile => 'حفظ نسخة في ملفي';

  @override
  String get invSavedToMyFile => 'حُفظت النتائج في ملفك الطبي على هذا الهاتف.';

  @override
  String get invShareWithDoctor => 'مشاركة النتائج مع الطبيب';

  @override
  String get invResultsAsText => 'النتائج';

  @override
  String get invIssuedTitle => 'الفحوصات التي طلبتها';

  @override
  String invIssuedFor(Object name) {
    return 'فحوصات $name';
  }

  @override
  String get invIssuedEmpty => 'لا توجد طلبات فحوصات.';

  @override
  String get invDoctorOrders => 'فحوصات المريض';

  @override
  String invDoctorOrdersReady(Object count) {
    return 'نتائج جاهزة ($count)';
  }

  @override
  String get invDoctorHiddenNote => 'لا يظهر اسم الطبيب للمعمل أو مركز الأشعة.';

  @override
  String get invKeepPhotosOnPhone => 'حفظ الصور على هذا الهاتف';

  @override
  String get invPhotosKept =>
      'تم حفظ الصور على هاتفك. ستُحذف نسخة السيرفر بعد أن يطّلع عليها الطبيب.';

  @override
  String get invPhotosKeptLocal => 'محفوظة على هذا الهاتف';

  @override
  String invPhotosExpire(Object date) {
    return 'ستُحذف صور النتائج من السيرفر في $date إن لم تحفظها على هاتفك.';
  }

  @override
  String get invPhotosPurgedNoCopy =>
      'حُذفت صور النتائج من السيرفر ولا توجد نسخة على هذا الهاتف.';

  @override
  String get invPhotosSaveFailed => 'تعذّر تنزيل الصور. حاول مرة أخرى.';

  @override
  String get invAddResultDicom => 'إرفاق أشعة DICOM';

  @override
  String invResultDicomCount(Object n) {
    return 'ملفات DICOM: $n';
  }

  @override
  String invDicomStudy(Object n) {
    return 'دراسة DICOM $n';
  }

  @override
  String get invDicomHint => 'ملف أشعة يُفتح ببرنامج عرض DICOM على هاتفك';

  @override
  String get invOpenDicom => 'فتح / مشاركة';

  @override
  String get invDicomOpenFailed => 'تعذّر تنزيل ملف الأشعة. حاول مرة أخرى.';

  @override
  String get invAddResultPdf => 'إرفاق تقرير PDF';

  @override
  String invResultPdfCount(Object count) {
    return '$count ملف PDF مرفق';
  }

  @override
  String invPdfReport(Object n) {
    return 'تقرير PDF $n';
  }

  @override
  String get invOpenPdf => 'فتح';

  @override
  String get invPdfOpenFailed => 'تعذّر فتح الملف.';

  @override
  String get invCurrency => 'ج';

  @override
  String get invIssueTitle => 'طلب فحوصات';

  @override
  String invIssueForPatient(String name) {
    return 'للمريض: $name';
  }

  @override
  String get invTabLab => 'تحاليل';

  @override
  String get invTabRadiology => 'أشعة';

  @override
  String get invSearchHint => 'ابحث في القائمة';

  @override
  String get invNotesLabel => 'ملاحظات (اختياري)';

  @override
  String invSelectedCount(int count) {
    return 'في الطلب: $count';
  }

  @override
  String get invNothingSelected => 'لم تختر فحصًا بعد';

  @override
  String get invSendToPatient => 'أرسل الطلب للمريض';

  @override
  String get invIssued => 'تم إرسال الطلب إلى المريض.';

  @override
  String get invCenterTitle => 'طلبات الفحوصات';

  @override
  String get invTabIncoming => 'واردة';

  @override
  String get invTabAccepted => 'قيد التنفيذ';

  @override
  String get invTabDone => 'مكتملة';

  @override
  String get invCenterEmpty => 'لا طلبات هنا.';

  @override
  String get invAccept => 'اقبل وحدد الموعد';

  @override
  String get invDecline => 'اعتذر';

  @override
  String get invAttachResults => 'ارفع النتيجة';

  @override
  String get invPickAppointment => 'اختر موعد التنفيذ';

  @override
  String get invResultsAttached => 'تم رفع النتيجة.';

  @override
  String get invPriceList => 'أسعار الفحوصات';

  @override
  String get invPriceListHint =>
      'اكتب سعرك لكل فحص تجريه، واترك الباقي فارغًا.';

  @override
  String get invPriceLabel => 'السعر';

  @override
  String get invPricesSaved => 'تم حفظ الأسعار.';

  @override
  String get invPickTests => 'اختر الفحوصات';

  @override
  String get invAttachPaper => 'صورة طلب الطبيب (اختياري)';

  @override
  String get invSendRequest => 'أرسل الطلب';

  @override
  String get invRequestSent => 'تم إرسال طلبك إلى الجهة.';

  @override
  String get invNoTests => 'لم تحدد هذه الجهة أسعار فحوصاتها بعد.';

  @override
  String get invKeepOrder => 'إبقاء الطلب';

  @override
  String get workingHoursTitle => 'ساعات العمل';

  @override
  String get workingHoursTileSubtitle =>
      'أيام الأسبوع، وقت الفتح والإغلاق، أو مفتوح 24 ساعة';

  @override
  String get workingHoursOpen24 => 'مفتوح 24 ساعة';

  @override
  String get bookingSettingsCheckTab => 'الدخول والخروج';

  @override
  String businessHoursClosesAt(String time) {
    return 'يُغلق الساعة $time';
  }

  @override
  String businessHoursClosesIn(String left) {
    return 'باقي $left على الإغلاق';
  }

  @override
  String businessHoursOpensAt(String time) {
    return 'يفتح الساعة $time';
  }

  @override
  String get businessHoursClosedToday => 'مغلق اليوم';

  @override
  String get clinicDayClosed => 'مغلق';

  @override
  String get clinicDayNoSlots => 'لا مواعيد';

  @override
  String get staffIsPhysician => 'طبيب معالج';

  @override
  String get staffIsPhysicianHint =>
      'يظهر اسمه على زياراته ووصفاته وطلبات الفحوصات، ويُختار عند الحجز، وله جدوله ويرى مرضاه فقط.';

  @override
  String get staffPhysicianBadge => 'طبيب';

  @override
  String get clinicPickPhysician => 'الطبيب';

  @override
  String get myAppointmentsTitle => 'مواعيدي';

  @override
  String clinicWithPhysician(Object name) {
    return 'الطبيب المعالج: $name';
  }

  @override
  String get clinicSlotsForPhysician => 'مواعيد الطبيب';

  @override
  String get clinicSlotsForHospital => 'المستشفى نفسه (بلا طبيب محدد)';

  @override
  String get treatingPhysicianLabel => 'الطبيب المعالج';

  @override
  String assigneeLine(String name) {
    return 'المسؤول: $name';
  }

  @override
  String get assigneeTitle => 'المسؤول';

  @override
  String get assigneeNobody => 'لم يُعيَّن أحد بعد';

  @override
  String get assigneeAssign => 'تعيين';

  @override
  String get assigneeChange => 'تغيير';

  @override
  String get assigneePickTitle => 'اختر المسؤول عن هذا العمل';

  @override
  String get assigneeRelease => 'بدون تعيين';

  @override
  String get staffIsProvider => 'يخدم العملاء مباشرة';

  @override
  String get staffIsProviderHint =>
      'يمكن تعيين الحجوزات عليه، ويرى حجوزاته المعيّنة له فقط.';

  @override
  String get staffProviderBadge => 'مقدّم خدمة';

  @override
  String get staffDepartment => 'القسم';

  @override
  String get staffNoDepartment => 'بدون قسم';

  @override
  String get procStatusAdvised => 'قرار الطبيب بانتظار ردّك';

  @override
  String procDecisionBy(String name) {
    return 'قرار الطبيب: $name';
  }

  @override
  String get procConfirmDecision => 'أؤكد الإجراء';

  @override
  String get procDeclineDecision => 'أعتذر';

  @override
  String get procDecisionAction => 'قرار إجراء جراحي';

  @override
  String get procDecisionTitle => 'قرار إجراء جراحي';

  @override
  String get procDecisionNotes => 'ملاحظات للمريض (اختياري)';

  @override
  String get procDecisionSend => 'إرسال القرار للمريض';

  @override
  String get procDecisionSent => 'تم إرسال القرار إلى المريض.';

  @override
  String get procDecisionNone => 'لم تحدّد المستشفى إجراءات بعد.';

  @override
  String get staffPhysicianBundle =>
      'يشمل: مواعيد العيادة، الوصفات الطبية، طلبات الفحوصات والأشعة، وقرارات الإجراءات الجراحية.';

  @override
  String get invPackage => 'باقة';

  @override
  String get invPackagesTitle => 'الباقات';

  @override
  String get invPackagesHeading => 'باقات';

  @override
  String invIncludes(String names) {
    return 'تشمل: $names';
  }

  @override
  String get invHomeCollection => 'سحب العينة من المنزل';

  @override
  String get invPickDay => 'اليوم';

  @override
  String get invPickTime => 'الوقت';

  @override
  String get invNoTimes => 'لا أوقات متاحة في هذا اليوم.';

  @override
  String get invChooseTime => 'اختر اليوم والوقت';

  @override
  String invRequestedAt(String when) {
    return 'الموعد المطلوب: $when';
  }

  @override
  String get invPackageAdd => 'إضافة باقة';

  @override
  String get invPackageEdit => 'تعديل الباقة';

  @override
  String get invPackageName => 'اسم الباقة';

  @override
  String get invPackagePrice => 'سعر الباقة';

  @override
  String get invPackageNote => 'ملاحظة (اختياري)';

  @override
  String get invPackageTests => 'التحاليل التي تشملها';

  @override
  String get invPackageSave => 'حفظ الباقة';

  @override
  String get invPackageHidden => 'مخفية عن المرضى';

  @override
  String get invPackageShow => 'تظهر للمرضى';

  @override
  String get invPackagesEmpty =>
      'لا توجد باقات بعد. أضف باقة بسعر واحد لعدّة تحاليل.';

  @override
  String get invPackageNeedTests =>
      'اختر تحليلًا واحدًا على الأقل واكتب السعر.';

  @override
  String get invPackagesHint =>
      'ما تسعّره هنا يراه المريض في صفحتك ويدفعه كما هو، لا كمجموع تحاليله.';

  @override
  String get invHomeFeeLabel => 'سعر سحب العينة من المنزل';

  @override
  String get invHomeFeeHint =>
      'اتركه فارغًا إن كان المعمل لا يسحب العينات من المنازل.';

  @override
  String get invHomeFeeSaved => 'تم حفظ السعر.';

  @override
  String get invPriceListActionPackages => 'الباقات';

  @override
  String externalDepositOwed(String amount) {
    return 'العربون المطلوب خارج المنصة: $amount ج';
  }

  @override
  String get externalDepositWaiting =>
      'لا يبدأ التنفيذ قبل أن تؤكد أنك استلمته أو تقبل الحجز بدونه.';

  @override
  String get externalDepositCash => 'استلمت كاش';

  @override
  String get externalDepositTransfer => 'استلمت تحويلًا';

  @override
  String get externalDepositWaive => 'قبول العربون — بلا دفع خارج المنصة';

  @override
  String get externalDepositReceived => 'تم تأكيد استلام العربون.';

  @override
  String get externalDepositWaived => 'قُبل الحجز بلا عربون.';

  @override
  String externalDepositCustomerNote(String amount) {
    return 'ادفع العربون ($amount ج) للنشاط مباشرة كاش أو تحويلًا. لا يبدأ التنفيذ حتى يؤكد النشاط استلامه.';
  }

  @override
  String get depositAsPaymentOffer =>
      'يمكنك قبول العربون المجمّد دفعةً من قيمة الحجز بدل الدفع خارج المنصة.';

  @override
  String get bookingsReschedule => 'تغيير الموعد';

  @override
  String get bookingsRescheduleTitle => 'اختر اليوم الجديد';

  @override
  String get bookingsRescheduled =>
      'تم تغيير الموعد. إن كان الحجز مقبولًا فبانتظار رد النشاط على الموعد الجديد.';

  @override
  String get visitDepositTitle => 'عربون الجدية';

  @override
  String visitDepositQuotedWalletPatient(String amount) {
    return 'يطلب النشاط عربونًا $amount ج يُجمَّد في محفظتك عند تأكيد الموعد، ويعود إليك بعد الزيارة.';
  }

  @override
  String visitDepositQuotedExternalPatient(String amount) {
    return 'يطلب النشاط عربونًا $amount ج تدفعه للنشاط مباشرة كاش أو تحويلًا خارج المنصة.';
  }

  @override
  String visitDepositQuotedWalletBusiness(String amount, String counter) {
    return 'العربون $amount ج يُجمَّد من المريض، وتُجمِّد أنت $counter ج عند التأكيد.';
  }

  @override
  String visitDepositQuotedExternalBusiness(String amount) {
    return 'العربون $amount ج يدفعه المريض إليك مباشرة، وتسجّل استلامه بعد التأكيد.';
  }

  @override
  String visitDepositHeld(String amount, String counter) {
    return 'عربون مجمّد: $amount ج من المريض و$counter ج من النشاط. يعود للطرفين بعد إتمام الزيارة.';
  }

  @override
  String visitDepositHeldClientOnly(String amount) {
    return 'عربون مجمّد: $amount ج من المريض. يعود إليه بعد إتمام الزيارة.';
  }

  @override
  String visitDepositPendingPatient(String amount) {
    return 'ادفع العربون ($amount ج) للنشاط مباشرة كاش أو تحويلًا خارج المنصة.';
  }

  @override
  String visitDepositPendingBusiness(String amount) {
    return 'العربون $amount ج مستحق خارج المنصة — سجّل استلامه أو اقبل بدونه.';
  }

  @override
  String get visitDepositReceivedCash => 'استلم النشاط العربون كاش.';

  @override
  String get visitDepositReceivedTransfer => 'استلم النشاط العربون تحويلًا.';

  @override
  String get visitDepositWaived => 'قبل النشاط الزيارة بلا عربون.';

  @override
  String get visitDepositReleased => 'أُعيد العربون للطرفين بعد الزيارة.';

  @override
  String get visitDepositRefunded => 'أُعيد العربون للطرفين.';

  @override
  String get visitDepositDisputed => 'العربون تحت نزاع مفتوح حتى يصدر قرار.';

  @override
  String get visitDepositResolved => 'فُصل في العربون بقرار تحكيم.';

  @override
  String get visitDepositGiveBack => 'إعادة العربون';

  @override
  String get visitDepositGiveBackDone => 'أُعيد العربون للطرفين.';

  @override
  String get visitDepositDispute => 'فتح نزاع على العربون';

  @override
  String get visitDepositDisputeOpened => 'فُتح النزاع على العربون.';

  @override
  String get bookingTermsNeedGuarantee =>
      'لتفعيل العربون المجمّد أو ضمان العميل يلزم أن يكون لنشاطك ضمان فعّال يقف خلف نصيبك. فعّل ضمانك أولًا، أو اختر «تحويل خارج المنصة».';

  @override
  String visitDepositFromGuarantee(String amount) {
    return 'منه $amount ج على ضمان المريض بدل المحفظة.';
  }

  @override
  String visitDepositBusinessFromGuarantee(String amount) {
    return 'وحصة النشاط ($amount ج) على ضمانه.';
  }

  @override
  String guaranteeBadgeTooltip(String level, String amount) {
    return 'مستوى الضمان: $level — يغطي حتى $amount ج';
  }

  @override
  String guaranteeBadgeTitle(String level) {
    return 'مستوى الضمان: $level';
  }

  @override
  String guaranteeBadgeBody(String amount) {
    return 'هذا مستوى ضمان الحساب على المنصة، ويغطي عملياته حتى $amount ج. فتعرف مع أي مستوى تتعامل.';
  }

  @override
  String orderDepositQuotedCustomer(String amount) {
    return 'يلزم لهذا الطلب غطاء $amount ج: يُجمَّد من ضمانك أولًا ثم من محفظتك عند قبول النشاط، ويعود بعد التسليم وتأكيد الدفع.';
  }

  @override
  String orderDepositQuotedBusiness(String amount) {
    return 'غطاء هذا الطلب $amount ج: يُجمَّد من ضمان العميل أولًا ثم محفظته عند قبولك، ويعود بعد التسليم وتأكيد الدفع.';
  }

  @override
  String orderDepositHeld(String amount) {
    return 'غطاء الطلب $amount ج مجمّد حتى التسليم وتأكيد الدفع.';
  }

  @override
  String get guarantorInviteButton => 'ادعُ ضامنًا من أصدقائك';

  @override
  String get guarantorSheetTitle => 'ضامن من أصدقائك';

  @override
  String guarantorSheetBody(String amount) {
    return 'ينقصك $amount ج لتغطية العربون. صديق له ضمان فعّال يُجمِّد جزءًا منه حتى تنتهي العملية ثم يعود إليه كاملًا.';
  }

  @override
  String get guarantorNoNeed =>
      'ضمانك ومحفظتك يغطيان العربون الآن. يمكنك مع ذلك دعوة صديق.';

  @override
  String get guarantorFieldHint => 'هاتف الصديق أو بريده';

  @override
  String get guarantorSend => 'إرسال الدعوة';

  @override
  String get guarantorSent => 'أُرسلت الدعوة.';

  @override
  String get guarantorStatusInvited => 'بانتظار رده';

  @override
  String guarantorStatusAccepted(String amount) {
    return 'قبل وجمّد $amount ج من ضمانه';
  }

  @override
  String get guarantorStatusDeclined => 'اعتذر';

  @override
  String get guarantorStatusReleased => 'عاد إليه ضمانه';

  @override
  String get guarantorStatusCancelled => 'أُلغيت الدعوة';

  @override
  String get guarantorRequestTitle => 'طلب ضمان';

  @override
  String guarantorRequestBody(String name) {
    return '$name يطلب أن تضمن عمليته: يُجمَّد جزء من ضمانك حتى تنتهي العملية ثم يعود إليك كاملًا، ولا يُخصم منه شيء.';
  }

  @override
  String guarantorAvailable(String amount) {
    return 'المتاح من ضمانك: $amount ج';
  }

  @override
  String get guarantorAmountLabel => 'المبلغ الذي تجمّده من ضمانك';

  @override
  String get guarantorAccept => 'أضمنه';

  @override
  String get guarantorDecline => 'اعتذر';

  @override
  String get guarantorAccepted => 'جُمِّد جزء من ضمانك لهذه العملية.';

  @override
  String get tripReservationNoShowAction => 'لم يحضر';

  @override
  String get tripReservationStatusNoShow => 'لم يحضر';

  @override
  String get tripStatusNoShow => 'لم تحضر';

  @override
  String get tripReserveWithFriend => 'احجز على أن يضمنك صديق';

  @override
  String get tripFriendPathHint =>
      'سيصل صديقك طلب ضمان بعد الحجز، ويؤكد الناقل بعد أن يقبل.';

  @override
  String tripDepositQuotedBusiness(String amount) {
    return 'عربون الجدية $amount ج يُجمَّد من الراكب عند تأكيدك الحجز.';
  }

  @override
  String tripDepositQuotedCustomer(String amount) {
    return 'الناقل يطلب عربون $amount ج؛ يُجمَّد من ضمانك أو محفظتك عندما يؤكد الناقل الحجز، ويعود إليك بعد الرحلة.';
  }

  @override
  String tripDepositHeld(String amount) {
    return 'العربون $amount ج مجمَّد، ويعود بعد إتمام الرحلة.';
  }

  @override
  String visitDepositQuotedWalletBusinessNoCounter(String amount) {
    return 'عربون $amount ج يُجمَّد من المريض عند تأكيدك.';
  }

  @override
  String get guarantorFromContacts => 'اختر من أصدقائك وعائلتك';

  @override
  String get guarantorOrByContact => 'أو ادعُ بالهاتف أو البريد:';

  @override
  String get tripOfflineRatingVisible => 'يظهر في التقييم (سُدّدت الرسوم)';

  @override
  String get tripOfflineNotCounted =>
      'خارج التطبيق — لا يظهر في التقييم ولا في العدّ حتى تُسدَّد الرسوم';

  @override
  String get tripOfflineShowInRatingAction => 'إظهاره في التقييم';

  @override
  String get tripOfflineAddTitle => 'إضافة راكب من خارج التطبيق';

  @override
  String get tripOfflineNameLabel => 'اسم الراكب';

  @override
  String get tripOfflinePhoneLabel => 'رقم الهاتف (اختياري)';

  @override
  String get tripOfflineUnitsLabel => 'عدد المقاعد';

  @override
  String get tripOfflineAdded => 'أُضيف الراكب وحُجز له المقعد.';

  @override
  String get tripAttendanceConfirmAction => 'تأكيد الحضور';

  @override
  String get tripAttendanceWaitingClient => 'بانتظار تأكيد العميل';

  @override
  String get tripAttendanceConfirmAsClient => 'وصلت — أؤكد حضوري';

  @override
  String get tripAttendanceWaitingCarrier =>
      'أكّدت حضورك، بانتظار تأكيد السائق';

  @override
  String get tripAttendanceBothConfirmed => 'تم تأكيد الحضور من الطرفين';

  @override
  String get tripReservationStatusBlocked => 'حجز يدوي';

  @override
  String get tripRunPartialTitle => 'بدء الرحلة ناقصة؟';

  @override
  String get tripRunPartialBody =>
      'الرحلة غير مكتملة أو لم يؤكّد كل الركاب حضورهم. هل تقرّ ببدء الرحلة كما هي؟';

  @override
  String get tripRunPartialConfirm => 'أقرّ وأبدأ';

  @override
  String get tripFullNotice => 'هذه الرحلة مكتملة.';

  @override
  String get parcelStatusRequested => 'بانتظار تسعير السائق';

  @override
  String get parcelStatusPriced => 'بانتظار قبولك للسعر';

  @override
  String get parcelStatusAccepted => 'مقبولة';

  @override
  String get parcelStatusLoaded => 'على السيارة';

  @override
  String get parcelStatusDelivered => 'سُلِّمت';

  @override
  String get parcelStatusRejected => 'مرفوضة';

  @override
  String get parcelStatusCancelled => 'ملغاة';

  @override
  String get parcelRequestTitle => 'إرسال طرد مع الرحلة';

  @override
  String get parcelDescriptionLabel => 'وصف الطرد';

  @override
  String get parcelDescriptionHelp =>
      'الحجم والوزن ومكانه (مثلًا: صندوق صغير، ٢٠ كجم، في شنطة السيارة)';

  @override
  String get parcelReceiverTitle => 'المستلم';

  @override
  String get parcelReceiverNoAccount => 'أو مستلم بلا حساب:';

  @override
  String get parcelReceiverName => 'اسم المستلم';

  @override
  String get parcelReceiverPhone => 'رقم هاتف المستلم';

  @override
  String get parcelReceiverRequired =>
      'اختر المستلم من قوائمك أو اكتب اسمه ورقم هاتفه.';

  @override
  String get parcelSendRequest => 'إرسال الطلب';

  @override
  String get parcelSealConfirm =>
      'الشحنة مغلّفة في كيس مختوم بعلامتي، يتلف عند فتحه';

  @override
  String get parcelSealNumber => 'رقم الختم (اختياري)';

  @override
  String get parcelSealRequired =>
      'غلّف الشحنة في كيس مختوم بعلامتك، ثم أكّد ذلك.';

  @override
  String get parcelSealPhotoTitle => 'صوّر الكيس المختوم';

  @override
  String get parcelSealPhotoBody =>
      'صوّر الكيس بالكاميرا قبل التحميل؛ الصورة دليل على حالته عند الاستلام. لو الكيس غير مختوم، ارفض الشحنة.';

  @override
  String get parcelSealTakePhoto => 'التقاط صورة';

  @override
  String get parcelRefuseUnsealed => 'غير مختومة — رفض';

  @override
  String get parcelSealAskTitle => 'هل ختم الكيس سليم؟';

  @override
  String get parcelSealAskBody =>
      'اسأل المستلم قبل التسليم. لو الختم مفتوح، تُسلَّم الشحنة ويُفتح نزاع تلقائيًا.';

  @override
  String get parcelSealIntact => 'سليم';

  @override
  String get parcelSealBroken => 'مفتوح';

  @override
  String get parcelSealed => 'مختومة';

  @override
  String parcelSealedNumber(String number) {
    return 'مختومة · رقم $number';
  }

  @override
  String get parcelSealIntactState => 'الختم سليم عند التسليم';

  @override
  String get parcelSealBrokenState =>
      'الختم كان مفتوحًا عند التسليم — فُتح نزاع';

  @override
  String get parcelRefusedUnsealed => 'رفضها السائق: غير مختومة';

  @override
  String get parcelRequestSent => 'أُرسل طلب الشحنة. سيحدد السائق سعرها.';

  @override
  String get parcelSendInstead => 'إرسال طرد مع هذه الرحلة';

  @override
  String get myParcelsTitle => 'شحناتي';

  @override
  String get myParcelsEmpty => 'لا شحنات بعد.';

  @override
  String get parcelAcceptPrice => 'أقبل السعر';

  @override
  String get parcelRegenerateCode => 'كود جديد';

  @override
  String get parcelCancel => 'إلغاء';

  @override
  String get parcelCodeHint =>
      'أعطِ هذا الكود للمستلم؛ يسلّمه للسائق عند الاستلام.';

  @override
  String parcelTakesSeats(int count) {
    return 'تأخذ $count مقعد';
  }

  @override
  String get carrierParcelsTitle => 'الشحنات';

  @override
  String get carrierParcelsEmpty => 'لا شحنات على خطوطك.';

  @override
  String get parcelSender => 'المرسل';

  @override
  String get parcelSetPrice => 'تحديد السعر';

  @override
  String get parcelPriceTitle => 'سعر الشحنة';

  @override
  String get parcelPriceLabel => 'السعر';

  @override
  String get parcelSeatsLabel => 'عدد المقاعد التي تشغلها';

  @override
  String get parcelSeatsHelp => '٠ إذا كانت في شنطة السيارة';

  @override
  String get parcelLoadAction => 'تحميل على السيارة';

  @override
  String get parcelDeliverAction => 'تسليم';

  @override
  String get parcelDeliverTitle => 'تسليم الشحنة';

  @override
  String get parcelDeliverCodeLabel => 'كود التسليم';

  @override
  String get parcelDeliverCodeHelp =>
      'اطلبه من المستلم — لا تُسلَّم الشحنة بدونه';

  @override
  String parcelDeliveredAt(String time) {
    return 'سُلِّمت: $time';
  }

  @override
  String get parcelStatusReturned => 'لم تُسلَّم (عادت)';

  @override
  String get parcelWhoPaysTitle => 'من يدفع للسائق (نقدًا)';

  @override
  String get parcelPayerSender => 'المرسل عند التسليم للسائق';

  @override
  String get parcelPayerReceiver => 'المستلم عند الاستلام';

  @override
  String get parcelPickupCodeHint =>
      'يمسح السائق هذا الـQR (أو يكتب كوده) ليستلم الشحنة منك.';

  @override
  String get parcelPickupTitle => 'استلام الشحنة من المرسل';

  @override
  String get parcelPickupHint => 'امسح QR المرسل أو اكتب كوده';

  @override
  String parcelExpectedArrival(String time) {
    return 'الوصول المتوقع (تقريبي): $time';
  }

  @override
  String get parcelExpectedArrivalPick => 'تحديد موعد الوصول التقريبي';

  @override
  String get parcelCashTitle => 'تحصيل المبلغ';

  @override
  String parcelCashBody(String amount, String currency) {
    return 'هل حصّلت $amount $currency نقدًا الآن؟ (يُسجَّل فقط)';
  }

  @override
  String get parcelCashNotYet => 'ليس بعد';

  @override
  String get parcelCashCollected => 'نعم، حصّلته';

  @override
  String get handoverScanQr => 'مسح QR';

  @override
  String get handoverOrTypeCode => 'أو اكتب الكود:';

  @override
  String get handoverCodeLabel => 'الكود';

  @override
  String get handoverConfirmTyped => 'تأكيد الكود المكتوب';

  @override
  String get clinicOptionsTitle => 'خيارات العيادة';

  @override
  String get clinicArrivalQrTitle => 'QR الوصول';

  @override
  String get clinicArrivalQrHint =>
      'يمسحه المريض عند وصوله ليُفعَّل دوره في الطابور. اختياري.';

  @override
  String get clinicArrivalQrRotate => 'كود جديد';

  @override
  String get clinicDayClosureTitle => 'اكتمل العدد اليوم';

  @override
  String get clinicDayClosureBody =>
      'يغلق الحجوزات الجديدة لهذا اليوم. اختياري — يمكنك بدلًا منه زيادة ساعات العمل.';

  @override
  String clinicDayClosureClosedOn(String date) {
    return 'مغلق للحجز الجديد في $date';
  }

  @override
  String get clinicArriveAction => 'وصلت — امسح QR العيادة';

  @override
  String get clinicArriveHint => 'امسح الكود المعروض في العيادة لتأكيد وصولك';

  @override
  String get clinicArriveDone => 'تم تسجيل وصولك. أنت الآن في الطابور.';

  @override
  String get tripFullBadge => 'مكتملة';

  @override
  String get handoverShowCode => 'إظهار الكود';

  @override
  String get handoverHideCode => 'إخفاء الكود';

  @override
  String get guestBookingTitle => 'إضافة ضيف';

  @override
  String get guestBookingAction => 'حجز للضيف';

  @override
  String get guestNameLabel => 'اسم الضيف';

  @override
  String get guestPhoneLabel => 'هاتف الضيف';

  @override
  String get guestPhoneHint => 'لو كان له حساب يُسجَّل الحجز على حسابه';

  @override
  String get guestLookupAction => 'بحث';

  @override
  String guestAccountFound(String name) {
    return 'له حساب: $name';
  }

  @override
  String get guestNoAccount =>
      'لا حساب بهذا الرقم — يُسجَّل باسمه فقط ولا يُحتسب في التقييم أو العدّاد.';

  @override
  String get guestOfferingLabel => 'الخدمة';

  @override
  String get guestUnitLabel => 'الوحدة';

  @override
  String get guestStartLabel => 'البداية';

  @override
  String get guestEndLabel => 'النهاية (اختياري)';

  @override
  String get guestPartySizeLabel => 'عدد الأفراد';

  @override
  String get guestBookingDone => 'تم الحجز للضيف';

  @override
  String get guestChip => 'ضيف خارج التطبيق';

  @override
  String returningCustomerBadge(int count) {
    return 'عميل سابق · $count تعاملات';
  }

  @override
  String get bookingAttendanceCustomerDone => 'العميل أكّد حضوره';

  @override
  String get bookingAttendanceCustomerWaiting => 'بانتظار تأكيد العميل لحضوره';

  @override
  String get bookingAttendanceBusinessDone => 'أكّدتَ الحضور';

  @override
  String get relationshipTitleBusiness => 'تعاملات هذا العميل معك';

  @override
  String get relationshipTitleCustomer => 'تعاملاتك مع هذا النشاط';

  @override
  String relationshipSummaryLine(int total, int completed, int notCompleted) {
    return '$total تعاملات · $completed ناجحة · $notCompleted لم تكتمل';
  }

  @override
  String get relationshipNoDisputes => 'لا نزاعات ولا مشاكل';

  @override
  String relationshipDisputes(int count, int open) {
    return 'نزاعات: $count ($open مفتوح)';
  }

  @override
  String get rideRequestTitle => 'اطلب ليموزين';

  @override
  String get rideRequestIntro =>
      'اكتب من أين إلى أين وبكم، والسائقون يردّون بأسعارهم وتختار أنسبها.';

  @override
  String get rideFromLabel => 'من';

  @override
  String get rideToLabel => 'إلى';

  @override
  String get ridePassengersLabel => 'عدد الركاب';

  @override
  String get rideWhenLabel => 'الموعد';

  @override
  String get rideWhenNow => 'الآن';

  @override
  String get rideWhenPick => 'اختر موعدًا';

  @override
  String get rideDistanceLabel => 'المسافة التقريبية (كم)';

  @override
  String get rideDistanceNeeded =>
      'المشوار داخل مدينة واحدة، اكتب المسافة التقريبية.';

  @override
  String rideDistanceKm(String km) {
    return 'المسافة نحو $km كم';
  }

  @override
  String rideSuggestedPrice(String price) {
    return 'السعر المقترح $price جنيه';
  }

  @override
  String get ridePriceLabel => 'السعر الذي تعرضه (جنيه)';

  @override
  String get rideDetailsLabel => 'ملاحظات للسائق (اختياري)';

  @override
  String get rideSubmit => 'انشر الطلب';

  @override
  String get rideFieldsRequired => 'اختر نقطة الانطلاق والوصول.';

  @override
  String get rideAllRequestsTitle => 'طلباتي';

  @override
  String get rideIncomingTitle => 'طلبات المشاوير';

  @override
  String get requestStatusOpen => 'مفتوح';

  @override
  String get requestStatusAccepted => 'تم الاختيار';

  @override
  String get requestStatusCancelled => 'ملغى';

  @override
  String get requestStatusExpired => 'انتهى';

  @override
  String requestOffersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عروض',
      one: 'عرض واحد',
      zero: 'لا عروض',
    );
    return '$_temp0';
  }

  @override
  String get requestsEmpty => 'لا طلبات بعد.';

  @override
  String get requestNoOffers => 'لا عروض بعد. سيصلك إشعار عند أول عرض.';

  @override
  String requestYourPrice(String price) {
    return 'سعرك $price جنيه';
  }

  @override
  String requestPassengersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ركاب',
      one: 'راكب واحد',
    );
    return '$_temp0';
  }

  @override
  String get requestOfferAccept => 'اقبل هذا العرض';

  @override
  String get requestOfferAcceptsYourPrice => 'يقبل سعرك';

  @override
  String requestOfferEta(int minutes) {
    return 'يصلك خلال $minutes دقيقة';
  }

  @override
  String get requestChangePrice => 'غيّر السعر';

  @override
  String get requestCancel => 'ألغِ الطلب';

  @override
  String get requestCancelConfirm =>
      'تُرفض العروض وتُخطر السائقين. ألغِ الطلب؟';

  @override
  String get requestCancelled => 'أُلغي الطلب.';

  @override
  String get requestBookingMade => 'تم اختيار العرض وأُنشئ حجزك.';

  @override
  String get requestOpenBooking => 'افتح الحجز';

  @override
  String get requestOfferPriceLabel => 'سعرك (جنيه)';

  @override
  String requestOfferAcceptBudget(String price) {
    return 'اقبل سعر العميل ($price جنيه)';
  }

  @override
  String get requestOfferMessageLabel => 'رسالة للعميل (اختياري)';

  @override
  String get requestOfferEtaLabel => 'أصل خلال (دقيقة)';

  @override
  String get requestOfferSend => 'أرسل عرضي';

  @override
  String get requestOfferWithdraw => 'اسحب عرضي';

  @override
  String get requestOfferSent => 'أُرسل عرضك.';

  @override
  String get requestOfferWithdrawn => 'سُحب عرضك.';

  @override
  String requestMyOffer(String price) {
    return 'عرضك: $price جنيه';
  }

  @override
  String requestCustomerPrice(String price) {
    return 'سعر العميل: $price جنيه';
  }

  @override
  String get requestsIncomingEmpty => 'لا طلبات مفتوحة في منطقتك الآن.';

  @override
  String requestFrom(String name) {
    return 'من $name';
  }

  @override
  String get techPricingRentPerDay => 'سعر اليوم (جنيه)';

  @override
  String get roomsTitleCar => 'السيارات';

  @override
  String get roomsTitleUnit => 'الوحدات';

  @override
  String get roomsHintCar =>
      'قائمة شركتك الخاصة. العميل يحجز نوع السيارة ولا يرى هذه الأرقام قبل بدء الإيجار. اكتب أرقام اللوحات.';

  @override
  String get roomsHintUnit =>
      'قائمتك الخاصة. العميل يحجز النوع ولا يرى هذه الرموز قبل البدء. اكتب رموزًا أو مدى مثل 1-10.';

  @override
  String get roomsNumbersFieldCar => 'أرقام اللوحات';

  @override
  String get roomsNumbersFieldUnit => 'رموز الوحدات';

  @override
  String get stayDiscountTitle => 'خصم الأسبوع والشهر';

  @override
  String get stayDiscountHint =>
      'كلما طالت المدة نقص السعر: نسبة تُخصم من الإجمالي لمدة 7 أيام فأكثر، ونسبة أكبر لمدة 30 يومًا فأكثر.';

  @override
  String get stayDiscountWeekly => 'خصم الأسبوع %';

  @override
  String get stayDiscountMonthly => 'خصم الشهر %';

  @override
  String get carWantedTitle => 'أريد سيارة';

  @override
  String get carWantedIntro =>
      'اكتب ما تريده وأصحاب المعارض والملاك في محافظتك يردّون بما عندهم. اختر أنسب عرض واحجز معاينة.';

  @override
  String get carDealBuy => 'شراء';

  @override
  String get carDealRent => 'إيجار';

  @override
  String get carTypeLabel => 'نوع السيارة';

  @override
  String get carBrandLabel => 'الماركة';

  @override
  String get carAnyChoice => 'أي';

  @override
  String get carYearMinLabel => 'من سنة';

  @override
  String get carMaxPriceBuy => 'أقصى سعر (جنيه)';

  @override
  String get carMaxPriceRent => 'أقصى سعر لليوم (جنيه)';

  @override
  String get carDaysLabel => 'عدد الأيام';

  @override
  String get carViewingWhen => 'موعد المعاينة (اختياري)';

  @override
  String get carWantedSubmit => 'انشر طلبي';

  @override
  String get carGovernorateRequired => 'اختر المحافظة والمدينة.';

  @override
  String get carWantedAcceptViewing => 'اقبل واحجز المعاينة';

  @override
  String carOfferItem(String name) {
    return 'السيارة: $name';
  }

  @override
  String get carOfferPickItem => 'اربط عرضك بسيارة من عندك (اختياري)';

  @override
  String get carOfferNoItem => 'بدون سيارة محددة';

  @override
  String carRentDaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أيام',
      one: 'يوم واحد',
    );
    return '$_temp0';
  }

  @override
  String carYearFrom(String year) {
    return 'من $year';
  }

  @override
  String carMaxPriceIs(String price) {
    return 'حتى $price جنيه';
  }

  @override
  String get requestsAnswerTitle => 'طلبات العملاء';

  @override
  String get requestKindRide => 'مشاوير';

  @override
  String get requestKindCar => 'سيارات';

  @override
  String get carDetailsLabel => 'ملاحظات (اختياري)';

  @override
  String get requestNewTitle => 'طلب جديد';

  @override
  String get hotelRoomsTitle => 'احجز غرفة';

  @override
  String get hotelRoomsFilter => 'فلتر';

  @override
  String hotelRoomsFilterCount(int count) {
    return 'فلتر · $count';
  }

  @override
  String get hotelRoomsClear => 'مسح الكل';

  @override
  String get hotelRoomsApply => 'أظهر الغرف';

  @override
  String get hotelRoomsClassLabel => 'تصنيف الفندق';

  @override
  String get hotelRoomsPriceLabel => 'السعر لليلة';

  @override
  String get hotelRoomsPriceFrom => 'من';

  @override
  String get hotelRoomsPriceTo => 'إلى';

  @override
  String get hotelRoomsCityChip => 'المدينة';

  @override
  String get hotelRoomsEmpty => 'لا غرف تناسب فلترك.';

  @override
  String hotelRoomsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count غرف',
      one: 'غرفة واحدة',
      zero: 'لا غرف',
    );
    return '$_temp0';
  }

  @override
  String hotelRoomsPricePerNight(String price, String currency) {
    return '$price $currency لليلة';
  }

  @override
  String get hotelRoomsOtherPrices => 'أسعار أخرى لنفس الغرفة';

  @override
  String get hotelRoomsCheaperThanHotel => 'أقل من سعر الفندق نفسه.';

  @override
  String get hotelRoomsSearchEntry => 'ابحث عن غرفة حسب التصنيف';

  @override
  String get hotelRoomsDatesLabel => 'تواريخ الإقامة';

  @override
  String get hotelRoomsDatesPick => 'اختر تاريخ الوصول والمغادرة';

  @override
  String hotelRoomsNights(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ليالٍ',
      one: 'ليلة واحدة',
    );
    return '$_temp0';
  }

  @override
  String hotelRoomsTotalFor(String total, String currency, String nights) {
    return 'الإجمالي $total $currency لـ$nights';
  }

  @override
  String get bookingChooseStay => 'اختر أيام الإقامة';

  @override
  String bookingStayNights(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ليالٍ',
      one: 'ليلة واحدة',
    );
    return '$_temp0';
  }

  @override
  String bookingStayCheckInOut(String checkIn, String checkOut) {
    return 'الحضور $checkIn والمغادرة $checkOut';
  }

  @override
  String get emptyReturnTitle => 'راجع فاضي';

  @override
  String get emptyReturnSectionTitle => 'سائقون راجعون فاضيين على هذا الخط';

  @override
  String get emptyReturnSectionHint =>
      'مشوار أرخص: السائق راجع على أي حال وهو من يحدد سعره.';

  @override
  String emptyReturnSaving(String percent) {
    return 'وفّر $percent٪';
  }

  @override
  String emptyReturnPriceEgp(String price) {
    return '$price جنيه';
  }

  @override
  String emptyReturnUsualFare(String price) {
    return 'السعر المعتاد $price جنيه';
  }

  @override
  String emptyReturnDeparts(String when) {
    return 'يتحرك $when';
  }

  @override
  String emptyReturnSeats(String n) {
    return 'حتى $n ركاب';
  }

  @override
  String get emptyReturnBook => 'احجز هذا المشوار';

  @override
  String get emptyReturnBookTitle => 'حجز مشوار راجع فاضي؟';

  @override
  String emptyReturnBookBody(String driver, String when, String price) {
    return '$driver · $when · $price جنيه. يتأكد الحجز بعد أن يقبله السائق.';
  }

  @override
  String get emptyReturnBooked => 'تم الحجز — بانتظار تأكيد السائق.';

  @override
  String get emptyReturnDriverIntro =>
      'راجع من غير ركاب؟ اعرض الطريق بسعر أقل واكسب من رحلة الرجوع.';

  @override
  String get emptyReturnPublishTitle => 'انشر رحلة رجوع';

  @override
  String get emptyReturnFrom => 'أنا راجع من';

  @override
  String get emptyReturnTo => 'إلى';

  @override
  String get emptyReturnWhen => 'موعد التحرك';

  @override
  String get emptyReturnPriceLabel => 'سعرك للسيارة كلها (جنيه)';

  @override
  String emptyReturnPriceHelp(String price, String ref) {
    return 'المقترح $price جنيه — المشوار المعتاد $ref جنيه ولا يجوز تجاوزه.';
  }

  @override
  String get emptyReturnSeatsLabel => 'عدد الركاب';

  @override
  String get emptyReturnNotesLabel => 'ملاحظات (اختياري)';

  @override
  String get emptyReturnPublish => 'انشر';

  @override
  String get emptyReturnPublished =>
      'تم النشر — العملاء على هذا الخط يستطيعون حجزه.';

  @override
  String get emptyReturnMineTitle => 'عروضي';

  @override
  String get emptyReturnNone => 'لم تنشر أي رحلة رجوع بعد.';

  @override
  String get emptyReturnCancel => 'إلغاء العرض';

  @override
  String get emptyReturnCancelled => 'تم إلغاء العرض.';

  @override
  String get emptyReturnStatusLive => 'ظاهر للعملاء';

  @override
  String get emptyReturnStatusPassed => 'انتهى موعده';

  @override
  String get emptyReturnStatusCancelled => 'ملغي';

  @override
  String get emptyReturnChooseCities => 'اختر المدينتين.';

  @override
  String get emptyReturnChooseWhen => 'اختر موعد التحرك.';

  @override
  String tripLegEveryDay(String day) {
    return 'كل $day';
  }

  @override
  String tripLegEveryDayAt(String day, String time) {
    return 'كل $day · $time';
  }

  @override
  String tripReservationWithCarrier(String name) {
    return 'مع $name';
  }

  @override
  String get requestsAvailableTitle => 'أستقبل الطلبات';

  @override
  String get requestsAvailableOn =>
      'تصلك طلبات العملاء. أوقفها حين تريد استراحة.';

  @override
  String get requestsAvailableOff =>
      'في استراحة: لا تصلك طلبات جديدة ولا تستطيع الرد، وعروض «راجع فاضي» لديك مخفية.';

  @override
  String get emptyReturnSuggestionsTitle => 'مشاويرك — اعرض طريق العودة';

  @override
  String emptyReturnSuggestionAfter(String when) {
    return 'بعد مشوارك $when';
  }

  @override
  String get emptyReturnSuggestionUse => 'اعرض طريق العودة';

  @override
  String emptyReturnForRide(String when) {
    return 'طريق العودة لمشوارك $when';
  }

  @override
  String get homeServiceTitle => 'أحتاج فنيًا';

  @override
  String get homeServiceIntro =>
      'اختر نوع الفني واكتب المشكلة. فنيّو هذا التخصص في محافظتك يرسلون لك أسعارهم وتختار منهم.';

  @override
  String get homeServiceTradeLabel => 'نوع الفني';

  @override
  String get homeServiceJobLabel => 'ما المشكلة؟';

  @override
  String get homeServiceNoAddress =>
      'تُرسل المدينة فقط. عنوانك يظهر للفني الذي تختاره فقط، بعد أن تقبل عرضه.';

  @override
  String get homeServiceWhenLabel => 'متى تريده؟ (اختياري)';

  @override
  String get homeServiceAnyTime => 'في أي وقت';

  @override
  String get homeServiceBudgetLabel => 'أقصى ما تدفعه (اختياري)';

  @override
  String homeServiceBudgetIs(String price) {
    return 'حتى $price جنيه';
  }

  @override
  String get homeServiceSubmit => 'اطلب عروض الأسعار';

  @override
  String get homeServiceTradeRequired => 'اختر نوع الفني ومدينتك.';

  @override
  String get homeServicePhotosLabel => 'صور المشكلة (اختياري، حتى 4)';

  @override
  String get homeServicePhotosHint =>
      'تظهر فقط للفنيين الذين وصلهم طلبك، وتُحذف بعد انتهاء الطلب أو الزيارة.';

  @override
  String get homeVisitAddressTitle => 'أين يأتي الفني؟';

  @override
  String get homeVisitAddressHint => 'يظهر هذا العنوان للفني الذي اخترته فقط.';

  @override
  String get homeVisitNoAddress => 'لا يوجد لك عنوان محفوظ. أضف عنوانك أولًا.';

  @override
  String get homeVisitAddAddress => 'إضافة عنوان';

  @override
  String get homeVisitChoose => 'اختر هذا العرض';

  @override
  String get homeVisitTitle => 'زيارة الفني';

  @override
  String get homeVisitAddress => 'العنوان';

  @override
  String get homeVisitOpenMap => 'افتح في الخرائط';

  @override
  String get homeVisitPhotos => 'صور المشكلة';

  @override
  String get requestKindHome => 'الفنيون';

  @override
  String get workQuoteTitle => 'اطلب عرض سعر من ورشة أو مصنع';

  @override
  String get workQuoteIntro =>
      'اكتب ما تريد تصنيعه أو إصلاحه. ورش ومصانع هذا التخصص ترسل لك سعرها وعدد الأيام التي تحتاجها، وتختار منها.';

  @override
  String get workQuoteTradeLabel => 'نوع الورشة أو المصنع';

  @override
  String get workQuoteWhatLabel => 'ماذا تريد؟ (باختصار)';

  @override
  String get workQuoteDetailsLabel => 'المواصفات: المقاسات والخامات والألوان…';

  @override
  String get workQuoteQuantityLabel => 'الكمية';

  @override
  String get workQuoteUnitLabel => 'الوحدة (قطعة، متر…)';

  @override
  String get workQuoteDeadlineLabel => 'أحتاجه قبل (اختياري)';

  @override
  String get workQuoteNationwide => 'يحق لأي ورشة أو مصنع في مصر الرد';

  @override
  String get workQuoteNationwideHelp =>
      'مغلق: ورش محافظتك فقط. مفعّل: مصانع المحافظات الأخرى التي توصّل تستطيع الرد أيضًا.';

  @override
  String get workQuoteSubmit => 'اطلب عروض الأسعار';

  @override
  String get workQuoteRequired =>
      'اختر النوع واكتب ما تريد والمواصفات (10 أحرف على الأقل) واختر مدينتك.';

  @override
  String workQuoteQuantityIs(String n, String unit) {
    return 'الكمية $n $unit';
  }

  @override
  String workQuoteDeadlineIs(String date) {
    return 'مطلوب قبل $date';
  }

  @override
  String get workQuoteNationwideShort => 'أي محافظة';

  @override
  String get workQuoteOfferDaysLabel => 'عدد الأيام التي أحتاجها للتنفيذ';

  @override
  String workQuoteOfferDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'جاهز خلال $days أيام',
      one: 'جاهز خلال يوم',
    );
    return '$_temp0';
  }

  @override
  String get requestKindQuote => 'عروض الأسعار';

  @override
  String get olTitle => 'إعلانات من المالك';

  @override
  String get olTileSubtitle =>
      'بيع أو أجّر سيارة أو شقة أو أي غرض مستعمل — بدون حساب بزنس';

  @override
  String get olCarsEntry =>
      'سيارات من المالك — اشترِ أو استأجر أو أعلن عن سيارتك';

  @override
  String get olPropertyEntry =>
      'شقق من المالك — اشترِ أو استأجر أو أعلن عن شقتك';

  @override
  String get olMine => 'إعلاناتي';

  @override
  String get olMyChats => 'محادثاتي';

  @override
  String get olAll => 'الكل';

  @override
  String get olSearchHint => 'ابحث في الإعلانات';

  @override
  String get olEmpty => 'لا توجد إعلانات هنا بعد.';

  @override
  String get olMineEmpty => 'لم تنشر أي إعلان بعد.';

  @override
  String get olChatsEmpty => 'لا توجد محادثات بعد.';

  @override
  String get olAdd => 'أضف إعلانًا';

  @override
  String get olDealSale => 'للبيع';

  @override
  String get olDealRent => 'للإيجار';

  @override
  String get olDealSwap => 'للتبديل';

  @override
  String get olPerDay => 'في اليوم';

  @override
  String get olPerWeek => 'في الأسبوع';

  @override
  String get olPerMonth => 'في الشهر';

  @override
  String get olPriceOpen => 'السعر بالاتفاق';

  @override
  String get olCurrency => 'جنيه';

  @override
  String get olFormTitleNew => 'إعلان جديد';

  @override
  String get olFormTitleEdit => 'تعديل الإعلان';

  @override
  String get olCategoryLabel => 'التصنيف';

  @override
  String get olTitleLabel => 'العنوان (3 أحرف على الأقل)';

  @override
  String get olDescriptionLabel => 'الوصف';

  @override
  String get olPriceLabel => 'السعر (جنيه)';

  @override
  String get olPriceOptionalLabel => 'القيمة (اختياري)';

  @override
  String get olPriceUnitLabel => 'مدة الإيجار';

  @override
  String get olPlaceRequired => 'اختر المحافظة والمدينة.';

  @override
  String get olNeedPhoto => 'أضف صورة واحدة على الأقل ليراه الناس.';

  @override
  String get olDetails => 'التفاصيل';

  @override
  String get olPhotosTitle => 'الصور (واحدة على الأقل)';

  @override
  String get olAddPhotoCamera => 'الكاميرا';

  @override
  String get olAddPhotoGallery => 'المعرض';

  @override
  String get olSave => 'انشر الإعلان';

  @override
  String get olSaveEdit => 'احفظ التعديلات';

  @override
  String olOwnerIs(String name) {
    return 'المعلن: $name';
  }

  @override
  String get olNoPhoneNote =>
      'رقم الهاتف مخفي. تحدثا هنا، وعند الاتفاق تبادلا الأرقام (تحصّل المنصة رسمًا).';

  @override
  String get olContact => 'راسل المالك';

  @override
  String get olReport => 'أبلغ عن الإعلان';

  @override
  String get olReported => 'وصلنا بلاغك، شكرًا.';

  @override
  String get olFinish => 'تم البيع أو التأجير — أنهِ الإعلان';

  @override
  String get olFinishHint => 'يختفي الإعلان الآن ويُحذف بعد 3 أيام.';

  @override
  String get olFinishSold => 'تم البيع';

  @override
  String get olFinishRented => 'تم التأجير';

  @override
  String get olFinishSwapped => 'تم التبديل';

  @override
  String get olFinishWithdrawn => 'سحبت الإعلان';

  @override
  String get olRenew => 'جدّد 60 يومًا';

  @override
  String get olDelete => 'احذف الآن';

  @override
  String get olDeleteConfirm => 'حذف الإعلان وصوره ومحادثاته؟';

  @override
  String get olEdit => 'تعديل';

  @override
  String get olStatusActive => 'ظاهر للناس';

  @override
  String get olStatusFlagged => 'مخفي: أبلغ عنه أشخاص';

  @override
  String get olStatusDone => 'منتهٍ';

  @override
  String get olStatusExpired => 'انتهت مدته';

  @override
  String get olNoPhotoHidden => 'لن يظهر قبل إضافة صورة';

  @override
  String olDeletesOn(String date) {
    return 'يُحذف في $date';
  }

  @override
  String olExpiresOn(String date) {
    return 'ظاهر حتى $date';
  }

  @override
  String olInquiriesCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n محادثات',
      one: 'محادثة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get olIAmBuyer => 'أنا المشتري';

  @override
  String get olIAmSeller => 'أنا البائع';

  @override
  String get olNumbersSwapped => 'تم تبادل الأرقام';

  @override
  String get olAsksToSwap => 'يطلب تبادل الأرقام';

  @override
  String get olWeAgree => 'اتفقنا — تبادل الأرقام';

  @override
  String olFeeLine(String fee, String share) {
    return 'رسوم المنصة $fee جنيه، نصيبك $share جنيه';
  }

  @override
  String olFeeLineOther(String fee) {
    return 'رسوم المنصة $fee جنيه (يدفعها الطرف الآخر)';
  }

  @override
  String get olRevealWaiting => 'بانتظار موافقة الطرف الآخر.';

  @override
  String olRevealAsked(String name) {
    return '$name يطلب تبادل الأرقام.';
  }

  @override
  String get olRevealAccept => 'أوافق وأدفع نصيبي';

  @override
  String get olRevealDecline => 'ليس الآن';

  @override
  String get olRevealWithdraw => 'سحب الطلب';

  @override
  String olPhoneIs(String name, String phone) {
    return 'رقم $name: $phone';
  }

  @override
  String get olCopy => 'نسخ';

  @override
  String get olListingEnded => 'انتهى هذا الإعلان.';

  @override
  String get reportTitle => 'إبلاغ';

  @override
  String get reportDetailsHint => 'تفاصيل إضافية (اختياري)';

  @override
  String get reportSend => 'إرسال البلاغ';

  @override
  String get reportSent => 'وصلنا بلاغك، شكرًا.';

  @override
  String get reportAction => 'إبلاغ';

  @override
  String get modTitle => 'الإشراف';

  @override
  String get modOpen => 'مفتوحة';

  @override
  String get modHandled => 'تمت معالجتها';

  @override
  String get modEmpty => 'لا توجد بلاغات.';

  @override
  String get modDismiss => 'تجاهل البلاغ';

  @override
  String get modRemove => 'إزالة';

  @override
  String get modRestore => 'استعادة';

  @override
  String get modRemovePostConfirm =>
      'إخفاء هذا المنشور؟ يمكنك استعادته لاحقًا.';

  @override
  String get modRemoveListingConfirm =>
      'حذف هذا الإعلان وصوره ومحادثاته نهائيًا؟';

  @override
  String get modStateLive => 'ظاهر';

  @override
  String get modStateHidden => 'مخفي';

  @override
  String get modStateGone => 'محذوف';

  @override
  String get modTypePost => 'منشور';

  @override
  String get modTypeListing => 'إعلان من المالك';

  @override
  String modByAuthor(String name) {
    return 'بواسطة $name';
  }

  @override
  String modReportsCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n بلاغًا',
      few: '$n بلاغات',
      two: 'بلاغان',
      one: 'بلاغ واحد',
    );
    return '$_temp0';
  }

  @override
  String get trainingPaidExpired => 'انتهى الشهر — الخطة مخفية عن العميل';

  @override
  String get trainingPaidHint =>
      'تُخصم رسوم الخدمة عند المشاركة وعند كل تجديد شهري. تعديل الخطة بعد انتهاء الشهر يجدّدها.';

  @override
  String get trainingRenew => 'تجديد شهر آخر';

  @override
  String get trainingRenewConfirm =>
      'تجديد الخطة شهرًا آخر؟ ستُخصم رسوم الخدمة مرة أخرى.';

  @override
  String get trainingRenewed => 'تم تجديد الخطة.';

  @override
  String trainingPaidUntil(String date) {
    return 'الشهر المدفوع حتى $date';
  }

  @override
  String get trainingEditDetails => 'تعديل بيانات الخطة';

  @override
  String get bodyCalcTitle => 'حاسبة الوزن المناسب';

  @override
  String get bodyCalcMale => 'ذكر';

  @override
  String get bodyCalcFemale => 'أنثى';

  @override
  String get bodyCalcAge => 'العمر (سنة)';

  @override
  String get bodyCalcHeight => 'الطول (سم)';

  @override
  String get bodyCalcWeight => 'الوزن (كجم)';

  @override
  String get bodyCalcActivity => 'مستوى النشاط';

  @override
  String get bodyCalcActSedentary => 'قليل الحركة (عمل مكتبي)';

  @override
  String get bodyCalcActLight => 'خفيف (تمرين 1–3 أيام)';

  @override
  String get bodyCalcActModerate => 'متوسط (تمرين 3–5 أيام)';

  @override
  String get bodyCalcActActive => 'عالٍ (تمرين 6–7 أيام)';

  @override
  String get bodyCalcActVery => 'شديد (تمرين مرتين يوميًا أو عمل شاق)';

  @override
  String get bodyCalcEnter => 'اكتب العمر والطول والوزن لتظهر النتيجة.';

  @override
  String get bodyCalcBmi => 'مؤشر كتلة الجسم';

  @override
  String get bodyCalcUnderweight => 'نحافة';

  @override
  String get bodyCalcNormal => 'وزن طبيعي';

  @override
  String get bodyCalcOverweight => 'وزن زائد';

  @override
  String get bodyCalcObese => 'سمنة';

  @override
  String get bodyCalcMinor =>
      'جداول البالغين لا تنطبق تحت 18 سنة. اسأل طبيبك عن الوزن المناسب لعمرك.';

  @override
  String get bodyCalcInRange => 'وزنك داخل المدى الصحي لطولك.';

  @override
  String get bodyCalcDisclaimer =>
      'تقدير تقريبي لا يغني عن رأي الطبيب أو أخصائي التغذية.';

  @override
  String bodyCalcHealthyRange(String min, String max) {
    return 'الوزن الصحي لطولك: من $min إلى $max كجم';
  }

  @override
  String bodyCalcIdeal(String kg) {
    return 'الوزن المثالي التقريبي: $kg كجم';
  }

  @override
  String bodyCalcLose(String kg) {
    return 'للوصول إلى المدى الصحي أنقص نحو $kg كجم.';
  }

  @override
  String bodyCalcGain(String kg) {
    return 'للوصول إلى المدى الصحي زد نحو $kg كجم.';
  }

  @override
  String bodyCalcBmr(String kcal) {
    return 'ما يحرقه جسمك في الراحة: $kcal سعر/يوم';
  }

  @override
  String bodyCalcMaintain(String kcal) {
    return 'سعرات تثبيت وزنك الحالي: $kcal سعر/يوم';
  }

  @override
  String get modOpenReport => 'فتح البلاغ والتعامل معه';

  @override
  String get modRelease => 'تحرير البلاغ';

  @override
  String modInHands(String name) {
    return '$name يتعامل مع هذا البلاغ الآن';
  }

  @override
  String modHandledBy(String name) {
    return 'أُغلق بواسطة $name';
  }

  @override
  String get trainingExpiredShort => 'انتهى الشهر';

  @override
  String get modTypeComment => 'تعليق';

  @override
  String get modRemoveCommentConfirm => 'إخفاء هذا التعليق عن الجميع؟';

  @override
  String get bodyCalcGoal => 'هدفك';

  @override
  String get bodyCalcGoalLose => 'إنقاص الوزن';

  @override
  String get bodyCalcGoalMaintain => 'تثبيت الوزن';

  @override
  String get bodyCalcGoalGain => 'زيادة الوزن';

  @override
  String get bodyCalcTape => 'قياسات إضافية (اختياري)';

  @override
  String get bodyCalcTapeHint =>
      'الخصر والرقبة (والأرداف للمرأة) لتقدير نسبة الدهون';

  @override
  String get bodyCalcWaist => 'الخصر (سم)';

  @override
  String get bodyCalcNeck => 'الرقبة (سم)';

  @override
  String get bodyCalcHip => 'الأرداف (سم)';

  @override
  String get bodyCalcComposition => 'تركيب الجسم';

  @override
  String get bodyCalcFatEssential => 'أساسي';

  @override
  String get bodyCalcFatAthletic => 'رياضي';

  @override
  String get bodyCalcFatFitness => 'لياقة';

  @override
  String get bodyCalcFatAverage => 'متوسط';

  @override
  String get bodyCalcFatHigh => 'مرتفع';

  @override
  String get bodyCalcFatFromTape =>
      'تقدير من قياسات الشريط (طريقة البحرية الأمريكية)';

  @override
  String get bodyCalcFatFromReport => 'من آخر تقرير قاسه مدربك';

  @override
  String get bodyCalcWhtOk => 'ضمن المعتاد';

  @override
  String get bodyCalcWhtHigh => 'مرتفع';

  @override
  String get bodyCalcNeeds => 'احتياجك اليومي';

  @override
  String get bodyCalcSave => 'حفظ القياس على هاتفي';

  @override
  String get bodyCalcSaved => 'تم حفظ القياس على هاتفك.';

  @override
  String get bodyCalcHistory => 'قياساتي المحفوظة';

  @override
  String get bodyCalcHistoryHint =>
      'محفوظة على هذا الهاتف فقط ولا تُرسل لأي جهة.';

  @override
  String get bodyCalcSinceBefore => 'عن القياس السابق';

  @override
  String bodyCalcFat(String p) {
    return 'نسبة الدهون: $p%';
  }

  @override
  String bodyCalcLean(String kg) {
    return 'الكتلة الخالية من الدهون: $kg كجم';
  }

  @override
  String bodyCalcMuscle(String kg) {
    return 'الكتلة العضلية المسجلة: $kg كجم';
  }

  @override
  String bodyCalcWht(String r, String verdict) {
    return 'الخصر ÷ الطول: $r — $verdict (المعتاد أقل من 0.5)';
  }

  @override
  String bodyCalcWhr(String r, String verdict) {
    return 'الخصر ÷ الأرداف: $r — $verdict';
  }

  @override
  String bodyCalcTarget(String goal, String kcal) {
    return 'سعراتك لهدف «$goal»: $kcal سعر/يوم';
  }

  @override
  String bodyCalcProtein(String min, String max) {
    return 'البروتين: من $min إلى $max جرام/يوم';
  }

  @override
  String bodyCalcWater(String l) {
    return 'الماء: نحو $l لتر/يوم';
  }

  @override
  String bodyCalcKgUnit(String kg) {
    return '$kg كجم';
  }

  @override
  String bodyCalcRecorded(String kg, String date) {
    return 'آخر وزن مسجّل في حسابك: $kg كجم ($date)';
  }

  @override
  String get olSeriousTitle => 'جدية الإعلان';

  @override
  String get olDepositAgreeFirst => 'وافق على حجز عربون الجدية لتنشر إعلانك.';

  @override
  String get olDepositNoBalance =>
      'رصيدك لا يكفي لعربون الجدية. اشحن محفظتك أولًا.';

  @override
  String olSeriousGuaranteeOk(String level) {
    return 'ضمانك ($level فأعلى) يكفي — لا عربون على إعلانك.';
  }

  @override
  String olSeriousBody(String level, String amount) {
    return 'لنشر إعلانك: ضمان $level فأعلى، أو عربون جدية $amount جنيه يُحجز من محفظتك ويُردّ عند البيع أو إنهاء الإعلان.';
  }

  @override
  String olSeriousAgree(String amount) {
    return 'أوافق على حجز $amount جنيه من محفظتي حتى ينتهي الإعلان';
  }

  @override
  String olDepositHeld(String amount) {
    return 'عربون الجدية: $amount جنيه محجوز، يُردّ عند البيع أو الإنهاء.';
  }

  @override
  String olDepositReleased(String amount) {
    return 'عربون الجدية: $amount جنيه — تم رده إلى محفظتك.';
  }

  @override
  String get olFilterPlace => 'المحافظة / المدينة';

  @override
  String get olFilterClear => 'إلغاء فلتر المكان';

  @override
  String get olVisTitle => 'من يرى إعلانك؟';

  @override
  String get olVisAll => 'الجميع';

  @override
  String get olVisGovernorate => 'محافظتي فقط';

  @override
  String get olVisCity => 'مدينتي فقط';

  @override
  String get olVisNeedsCity => 'اختر المدينة ليقتصر الإعلان على أهلها.';

  @override
  String get olVisBadgeCity => 'يظهر لأهل المدينة فقط';

  @override
  String get olVisBadgeGovernorate => 'يظهر لأهل المحافظة فقط';

  @override
  String get olRulesWarnTitle => 'تنبيه: مصادرة العربون أو الضمان';

  @override
  String get olRulesWarnBodyDeposit =>
      'إذا خالف إعلانك القواعد وأزاله المشرف سيتم مصادرة عربون الجدية. تتم المصادرة إذا تحقق أي سبب من هذه الأسباب:';

  @override
  String get olRulesWarnBodyGuarantee =>
      'إذا خالف إعلانك القواعد وأزاله المشرف سيتم مصادرة قيمة الضمان المجمّد. تتم المصادرة إذا تحقق أي سبب من هذه الأسباب:';

  @override
  String get olGuaranteeReleased =>
      'ضمانك المجمّد لهذا الإعلان تم الإفراج عنه.';

  @override
  String get modViolationTitle => 'ما القاعدة التي خالفها الإعلان؟';

  @override
  String get modConfiscate => 'مصادرة العربون أو الضمان';

  @override
  String olGuaranteeFrozen(String amount) {
    return 'ضمانك مجمّد ($amount جنيه) طوال مدة الإعلان، ويُفرَج عنه عند البيع أو الإنهاء.';
  }

  @override
  String get modTypeAccount => 'حساب';

  @override
  String get modStateFrozen => 'مجمَّد';

  @override
  String get modOpenChat => 'فتح محادثة';

  @override
  String get modFreeze => 'تجميد 3 أيام';

  @override
  String get modUnfreeze => 'رفع التجميد';

  @override
  String get modFreezeConfirm =>
      'تجميد هذا الحساب ثلاثة أيام؟ لا يُحذف الحساب، ويبقى له التواصل مع المشرفين فقط.';

  @override
  String get frozenTitle => 'الحساب مجمَّد';

  @override
  String get frozenHeadline => 'جُمِّد حسابك مؤقتًا';

  @override
  String get frozenBody =>
      'وصلتنا بلاغات عن حسابك فجمّده المشرف ثلاثة أيام. يمكنك التواصل مع المشرفين ليتأكدوا من السبب.';

  @override
  String get frozenChat => 'محادثة المشرفين';

  @override
  String get frozenChatTitle => 'المشرفون';

  @override
  String get frozenNoChatYet =>
      'سيفتح المشرف محادثة معك لتوضيح السبب، وتظهر هنا.';

  @override
  String get frozenRefresh => 'تحديث';

  @override
  String get frozenLogout => 'تسجيل الخروج';

  @override
  String frozenUntil(String date) {
    return 'يعود حسابك للعمل بعد $date';
  }

  @override
  String get modAccountDeleted => 'حُذف الحساب وصودر رصيده وضمانه.';

  @override
  String frozenWarnTitle(int count, int limit) {
    return 'تنبيه: هذا التجميد رقم $count من $limit';
  }

  @override
  String frozenWarnBody(int limit) {
    return 'إذا تكرر التجميد $limit مرات خلال 12 شهرًا عُرض حذف الحساب ومصادرة رصيده وضمانه على لجنة من المشرفين، ولك حق الاعتراض.';
  }

  @override
  String modFreezeConfirmCount(int count, int limit) {
    return 'تجميد هذا الحساب ثلاثة أيام؟ هذا التجميد رقم $count من $limit، ولا يُحذف الحساب الآن.';
  }

  @override
  String modFreezeConfirmLast(int limit) {
    return 'هذا هو التجميد رقم $limit: سيُحذف الحساب ويُصادَر رصيده وضمانه نهائيًا. هل تتابع؟';
  }

  @override
  String get reportChatAction => 'الإبلاغ عن المحادثة';

  @override
  String get reportChatPick =>
      'اختر الرسائل التي تريد عرضها على المشرف (اختياري)';

  @override
  String reportChatPickHint(int count) {
    return 'المشرف لا يقرأ المحادثة كلها دون موافقة الطرفين أو نصاب من المشرفين. المحدد: $count';
  }

  @override
  String get reportChatContinue => 'متابعة';

  @override
  String reportChatAttached(int count) {
    return 'ستُعرض $count رسالة على المشرف مع البلاغ';
  }

  @override
  String get modTypeConversation => 'محادثة';

  @override
  String get modConversationTitle => 'المحادثة المُبلَّغ عنها';

  @override
  String modConversationParties(String names) {
    return 'الطرفان: $names';
  }

  @override
  String get modSelectedMessages => 'الرسائل التي اختارها المُبلِّغ';

  @override
  String get modNoSelectedMessages => 'لم يختر المُبلِّغ رسائل.';

  @override
  String get modConsentAll => 'وافق الطرفان';

  @override
  String get modConsentDeclined => 'رفض أحد الطرفين';

  @override
  String get modConsentPending => 'بانتظار موافقة الطرفين';

  @override
  String modQuorumStatus(int n, int q) {
    return 'نصاب المشرفين $n/$q';
  }

  @override
  String get modConversationOpen => 'المحادثة مفتوحة';

  @override
  String get modConversationClosed => 'المحادثة مغلقة';

  @override
  String get modAskConsent => 'طلب موافقة الطرفين';

  @override
  String modVouch(int n, int q) {
    return 'تأييد الاطلاع ($n/$q)';
  }

  @override
  String get modReadConversation => 'قراءة المحادثة';

  @override
  String get modFreezeConfirmPlain =>
      'سيُجمَّد هذا الحساب لمدة ثلاثة أيام. هل تتابع؟';

  @override
  String get panelTitle => 'قرارات الحذف';

  @override
  String get panelEmpty => 'لا توجد قرارات حذف بانتظار التصويت.';

  @override
  String get panelFifthFreeze =>
      'التجميد الخامس خلال 12 شهرًا: يُقترح حذف الحساب ومصادرة رصيده وضمانه.';

  @override
  String get panelSecondRound => 'اعترض صاحب الحساب: تُراجَع القضية مرة ثانية.';

  @override
  String get panelFreezes => 'التجميدات السابقة وأسبابها';

  @override
  String get panelObjection => 'اعتراض صاحب الحساب';

  @override
  String panelTally(int a, int an, int r, int rn) {
    return 'موافقات $a/$an · رفض $r/$rn';
  }

  @override
  String get panelApprove => 'موافقة على الحذف';

  @override
  String get panelReject => 'رفض الحذف';

  @override
  String get panelVoted => 'سجّلتَ صوتك. بانتظار بقية المشرفين.';

  @override
  String get deletionReview =>
      'لجنة من المشرفين تراجع حذف حسابك. ستصلك إشعارات بالقرار.';

  @override
  String deletionScheduled(String when) {
    return 'قررت لجنة المشرفين حذف حسابك في $when ومصادرة رصيده وضمانه. يمكنك الاعتراض كتابةً قبل ذلك.';
  }

  @override
  String get deletionObjected =>
      'وصل اعتراضك وهو قيد مراجعة اللجنة. لن يُحذف الحساب قبل قرارهم.';

  @override
  String get objectAction => 'اعتراض على الحذف';

  @override
  String get objectTitle => 'اعتراضك على الحذف';

  @override
  String get objectHint => 'اشرح بوضوح لماذا لا يجب حذف حسابك';

  @override
  String orderPreparingBy(String name) {
    return 'جارٍ تجهيزه من $name';
  }

  @override
  String orderPreparedBy(String name) {
    return 'جهّزه $name';
  }

  @override
  String orderAcceptedBy(String name) {
    return 'قبِله $name';
  }

  @override
  String get providerPickTitle => 'اختر مقدّم الخدمة';

  @override
  String get providerAnyone => 'أي مقدّم متاح';

  @override
  String projectForOperation(int id) {
    return 'مشروع العملية رقم $id';
  }

  @override
  String get projectTemplatePick => 'ابدأ من خطة جاهزة';

  @override
  String projectTemplateSummary(int stages, int days) {
    return '$stages مراحل · نحو $days يومًا';
  }

  @override
  String get taskRequiresApproval => 'يطلب اعتماد العميل عند اكتمالها';

  @override
  String get taskTakePhoto => 'تصوير المرحلة بالكاميرا';

  @override
  String get approvalPendingBusiness => 'بانتظار اعتماد العميل';

  @override
  String get approvalPendingCustomer => 'هذه المرحلة بانتظار اعتمادك';

  @override
  String get approvalApproved => 'اعتمدها العميل';

  @override
  String approvalRejectedWithNote(String note) {
    return 'أعادها العميل للتعديل: $note';
  }

  @override
  String get approvalApprove => 'اعتماد المرحلة';

  @override
  String get approvalReject => 'إعادة للتعديل';

  @override
  String get approvalRejectTitle => 'ملاحظتك على المرحلة';

  @override
  String get approvalRejectHint => 'اكتب ما يجب تعديله';

  @override
  String get myStagesTitle => 'مراحلي';

  @override
  String get myStagesEmpty => 'لا توجد مراحل مسندة إليك الآن.';

  @override
  String get myStagesPhotoSaved => 'حُفظت الصورة';

  @override
  String myStagesDue(String date) {
    return 'تنتهي $date';
  }

  @override
  String get myStagesPlus25 => '+٢٥٪';

  @override
  String projectCardStage(String stage) {
    return 'المرحلة الحالية: $stage';
  }

  @override
  String projectCardStageBy(String stage, String name) {
    return 'المرحلة الحالية: $stage — $name';
  }

  @override
  String projectCardWaiting(int count) {
    return '$count مرحلة بانتظار اعتمادك';
  }

  @override
  String get projectStartForOperation => 'ابدأ مشروعًا لهذه العملية';

  @override
  String get agreementTitle => 'الاتفاق على الخطة';

  @override
  String agreementDue(String date) {
    return 'موعد التسليم: $date';
  }

  @override
  String agreementGrace(String date) {
    return 'نهاية فترة السماح: $date';
  }

  @override
  String agreementVersion(int n) {
    return 'النسخة $n';
  }

  @override
  String get agreementStatusProposed => 'بانتظار موافقة العميل';

  @override
  String get agreementStatusAgreed => 'متفق عليها';

  @override
  String agreementAgreedOn(String date) {
    return 'وافق العميل $date';
  }

  @override
  String get agreementPropose => 'عرض الخطة على العميل';

  @override
  String get agreementProposeDue => 'موعد التسليم';

  @override
  String get agreementProposeGrace => 'أيام السماح بعد التسليم';

  @override
  String get agreementNeedsOperation =>
      'اربط المشروع بطلب أو حجز لعميل لتعرض عليه الخطة.';

  @override
  String get agreementWaitingCustomer => 'بانتظار رد العميل';

  @override
  String get agreementAgree => 'أوافق على الخطة';

  @override
  String get agreementDecline => 'أرفض';

  @override
  String get agreementDeclineHint => 'اكتب السبب';

  @override
  String get extensionRequest => 'طلب تمديد';

  @override
  String get requestExtensionTitle => 'طلب تمديد فترة السماح';

  @override
  String get extensionDays => 'عدد الأيام';

  @override
  String get extensionReason => 'السبب';

  @override
  String get extensionSent => 'أُرسل طلب التمديد إلى العميل';

  @override
  String requestExtensionLine(int days, String date) {
    return 'تمديد فترة السماح $days يومًا حتى $date';
  }

  @override
  String requestScopePlanned(String from, String to) {
    return 'تعديل كمية مخططة من $from إلى $to';
  }

  @override
  String requestScopeAdd(String name, String planned) {
    return 'إضافة كمية: $name = $planned';
  }

  @override
  String requestScopeDelete(String name) {
    return 'حذف كمية: $name';
  }

  @override
  String get requestScopeLine => 'تعديل نطاق العمل';

  @override
  String get requestApproved => 'وافق العميل';

  @override
  String requestRejectedWith(String note) {
    return 'رفض العميل: $note';
  }

  @override
  String get requestApprove => 'موافقة';

  @override
  String get requestReject => 'رفض';

  @override
  String get startRequest => 'طلب بدء المرحلة';

  @override
  String get startRequestSent => 'أُرسل طلب البدء إلى العميل';

  @override
  String get startRequested => 'بانتظار موافقة العميل على البدء';

  @override
  String get startApproved => 'بدأت بموافقة العميل';

  @override
  String startDeclined(String note) {
    return 'رفض العميل البدء: $note';
  }

  @override
  String get startNotRequested => 'لم يُطلب بدؤها بعد';

  @override
  String get startApproveAction => 'أوافق على بدء المرحلة';

  @override
  String get startDeclineAction => 'ليس الآن';

  @override
  String stageWorks(int n) {
    return '$n عملًا';
  }

  @override
  String get itemsTitle => 'الكميات';

  @override
  String get itemsEmpty => 'لم تُسجَّل كميات لهذا العمل بعد.';

  @override
  String get itemAdd => 'إضافة كمية';

  @override
  String get itemName => 'البند (مثل: عدد الأعمدة)';

  @override
  String get itemUnit => 'الوحدة';

  @override
  String get itemPlanned => 'المخطط';

  @override
  String get itemDone => 'المنفَّذ';

  @override
  String get itemReason => 'سبب التعديل (اختياري)';

  @override
  String get itemRequestSent => 'أُرسل الطلب للعميل ولن يُطبَّق قبل موافقته';

  @override
  String get taskDetailsTitle => 'الكميات والتفاصيل';

  @override
  String get taskZone => 'الموقع (مثل: الدور الثالث / شقة 2)';

  @override
  String get taskDetails => 'تفاصيل ومواصفات العمل';

  @override
  String get quantityLogTitle => 'سجل تعديل الكميات';

  @override
  String get quantityLogEmpty => 'لا توجد تعديلات بعد';

  @override
  String get quantityLogViaRequest => 'بموافقة العميل';

  @override
  String get quantityLogCreated => 'إضافة';

  @override
  String get quantityLogDeleted => 'حذف';

  @override
  String get buildingGenerate => 'مبنى سكني بأدواره وشققه';

  @override
  String get buildingFloors => 'عدد الأدوار (بالأرضي)';

  @override
  String get buildingFlats => 'الشقق في كل دور';

  @override
  String get buildingBasement => 'يوجد بدروم';

  @override
  String buildingGenerated(int n) {
    return 'تم توليد $n عملًا';
  }

  @override
  String get agreementProposeStart => 'بدء التنفيذ';

  @override
  String get agreementProposeStartHint =>
      'تاريخ مستقبلي؛ المدة حتى ذلك الموعد للتفاوض';

  @override
  String get agreementRequireGuarantee => 'ضمان العميل المطلوب قبل بدء العمل';

  @override
  String get agreementNoGuarantee => 'بدون شرط';

  @override
  String get guaranteeBronze => 'برونزي فأعلى';

  @override
  String get guaranteeSilver => 'فضي فأعلى';

  @override
  String get guaranteeGold => 'ذهبي فأعلى';

  @override
  String guaranteeRequired(String level) {
    return 'يشترط النشاط ضمانًا $level على الأقل في حساب العميل';
  }

  @override
  String guaranteeRequirementMet(String level) {
    return 'ضمانك يستوفي شرط النشاط: $level فأعلى';
  }

  @override
  String guaranteeRequirementNotMet(String level) {
    return 'يشترط النشاط ضمانًا $level فأعلى في حسابك قبل الاتفاق وبدء العمل';
  }

  @override
  String get shiftPlan => 'ترحيل الخطة';

  @override
  String get shiftStage => 'ترحيل هذه المرحلة';

  @override
  String get shiftPlanTitle => 'ترحيل الخطة';

  @override
  String shiftStageTitle(String stage) {
    return 'ترحيل المرحلة: $stage';
  }

  @override
  String get shiftWeek => 'أسبوع';

  @override
  String get shiftTwoWeeks => 'أسبوعان';

  @override
  String get shiftMonth => 'شهر';

  @override
  String get shiftPickDate => 'اختيار تاريخ بدء';

  @override
  String get shiftApplied => 'تم ترحيل المواعيد';

  @override
  String get shiftRequestSent =>
      'أُرسل طلب الترحيل للطرف الآخر ولن يُطبَّق قبل موافقته';

  @override
  String get shiftAskPostpone => 'طلب تأجيل';

  @override
  String get shiftScopePlan => 'الخطة كلها';

  @override
  String get shiftScopeStage => 'مرحلة';

  @override
  String requestShiftLine(int days, String scope) {
    return 'ترحيل $scope $days يومًا';
  }

  @override
  String agreementStart(String date) {
    return 'بدء التنفيذ: $date';
  }

  @override
  String get buildingElevator => 'يوجد مصعد';

  @override
  String get showcaseVerifiedBadge => 'موثَّق من العميل';

  @override
  String get showcaseAskAction => 'نشر المشروع كمنشور';

  @override
  String get showcaseAskTitle => 'نشر المشروع كمنشور';

  @override
  String get showcaseAskHint =>
      'لا يُنشر شيء قبل موافقة العميل. يظهر النسبة المعتمدة منه فقط، دون اسمه أو عنوانه أو أرقام الوحدات.';

  @override
  String get showcasePublicTitle => 'عنوان المنشور';

  @override
  String get showcaseNote => 'وصف قصير (اختياري)';

  @override
  String get showcaseShowPhotos => 'إظهار صور الأعمال المعتمدة';

  @override
  String get showcaseRequestSent => 'أُرسل طلب النشر إلى العميل';

  @override
  String get showcaseWaiting => 'بانتظار موافقة العميل';

  @override
  String get showcaseLive => 'منشور الآن ويتحدّث بموافقات العميل';

  @override
  String get showcaseTakeDown => 'إيقاف النشر';

  @override
  String get showcaseCancelRequest => 'إلغاء الطلب';

  @override
  String get showcaseWithdrawn => 'أُوقف النشر. يمكنك طلب الموافقة من جديد.';

  @override
  String showcaseDeclined(String note) {
    return 'رفض العميل النشر: $note';
  }

  @override
  String showcaseUpdatedOn(String date) {
    return 'آخر تحديث: $date';
  }

  @override
  String get showcaseConsentTitle => 'النشاط يطلب عرض مشروعك كمنشور';

  @override
  String get showcaseConsentLive => 'مشروعك معروض كمنشور';

  @override
  String get showcaseConsentWithPhotos =>
      'يظهر التقدّم الذي اعتمدته مع صور الأعمال المعتمدة، دون اسمك أو عنوانك.';

  @override
  String get showcaseConsentNoPhotos =>
      'يظهر التقدّم الذي اعتمدته فقط، دون صور ودون اسمك أو عنوانك.';

  @override
  String get showcaseConsentAgree => 'أوافق';

  @override
  String get showcaseConsentDecline => 'لا أوافق';

  @override
  String get showcaseConsentDeclineHint => 'سبب اختياري';

  @override
  String get showcaseKindTraining => 'خطة تدريب';

  @override
  String get showcaseKindNutrition => 'نظام غذائي';

  @override
  String get showcaseKindCombined => 'تدريب وتغذية';

  @override
  String showcaseWeeks(int n) {
    return '$n أسبوعًا';
  }

  @override
  String showcaseConfirmedMonths(int n) {
    return '$n أشهر موثَّقة';
  }

  @override
  String get showcaseNoConfirmedYet => 'بانتظار أول تقرير شهري';

  @override
  String get planShowcaseAskAction => 'نشر نتائج الخطة كمنشور';

  @override
  String get planShowcaseAskHint =>
      'لا يُنشر شيء قبل موافقة العميل، وموافقته واحدة تشمل الخطة كلها: تتحدّث النتائج مع كل تقرير شهري. تظهر التغيّرات فقط، دون اسمه أو وزنه أو أي صورة.';

  @override
  String get planShowcaseConsentTitle => 'المدرب يطلب عرض نتائج خطتك كمنشور';

  @override
  String get planShowcaseConsentLive => 'نتائج خطتك معروضة كمنشور';

  @override
  String get planShowcaseConsentBody =>
      'موافقة واحدة تشمل الخطة كلها: تتحدّث النتائج مع كل تقرير شهري دون أن يُطلب منك شيء كل مرة. تظهر التغيّرات فقط، دون اسمك أو وزنك أو أي صورة، وتستطيع إيقافها في أي وقت.';

  @override
  String get showcaseModeTitle => 'طريقة أخذ الموافقة';

  @override
  String get showcaseModeOnce => 'موافقة عامة مرة واحدة';

  @override
  String get showcaseModeEachProject => 'موافقة على كل مرحلة';

  @override
  String get showcaseModeEachPlan => 'موافقة كل شهر عند التجديد';

  @override
  String get showcaseModeOnceNotice => 'موافقة واحدة تشمل كل المراحل.';

  @override
  String get showcaseModeEachNoticeProject =>
      'تُسأل عن كل مرحلة منتهية قبل نشرها.';

  @override
  String get showcaseModeEachNoticePlan =>
      'تُسأل عن نتائج كل شهر عند تجديد الخطة قبل نشرها.';

  @override
  String get showcaseConsentStageByStage => 'أوافق مرحلةً مرحلة';

  @override
  String get showcaseConsentMonthByMonth => 'أوافق شهرًا بشهر';

  @override
  String get showcaseUnitsTitleProject => 'المراحل المنتهية: هل تُنشر؟';

  @override
  String get showcaseUnitsTitlePlan => 'نتائج الأشهر: هل تُنشر؟';

  @override
  String get showcaseUnitPublish => 'نشر';

  @override
  String get showcaseUnitSkip => 'لا أنشر';

  @override
  String get showcaseUnitApproved => 'منشورة';

  @override
  String get showcaseUnitDeclined => 'غير منشورة';

  @override
  String get promoScreenTitle => 'العروض والخصومات';

  @override
  String get promoAdd => 'عرض جديد';

  @override
  String get promoEdit => 'تعديل العرض';

  @override
  String get promoEmpty =>
      'لا عروض بعد. اضغط «عرض جديد»، اختر منتجاتك ثم نوع الخصم، وسيصل إلى سعر العميل في السلة.';

  @override
  String get promoNoneRunning => 'لا توجد عروض جارية الآن.';

  @override
  String get promoRunning => 'يعمل الآن';

  @override
  String get promoPaused => 'موقوف';

  @override
  String get promoEnded => 'منتهٍ';

  @override
  String get promoPause => 'إيقاف مؤقت';

  @override
  String get promoResume => 'استئناف';

  @override
  String get promoDelete => 'حذف';

  @override
  String get promoDeleteConfirm =>
      'حذف هذا العرض؟ الطلبات التي سُعّرت به تحتفظ بخصمها.';

  @override
  String get promoStepProducts => '٢. اختر المنتجات';

  @override
  String get promoStepType => '١. نوع العرض';

  @override
  String get promoStepDetails => '٣. التفاصيل';

  @override
  String get promoWholeShop => 'كل منتجاتي';

  @override
  String get promoWholeSection => 'القسم كله';

  @override
  String get promoNoSection => 'بدون قسم';

  @override
  String get promoNoProducts => 'لا منتجات لديك بعد.';

  @override
  String get promoPickSomething => 'اختر ما يشمله العرض';

  @override
  String get promoWayPercent => 'نسبة خصم';

  @override
  String get promoWayAmount => 'مبلغ خصم';

  @override
  String get promoWaySpend => 'خصم عند حد أدنى للطلب';

  @override
  String get promoValuePercent => 'نسبة الخصم ٪';

  @override
  String get promoValueAmount => 'مبلغ الخصم (جنيه)';

  @override
  String get promoMinTotal => 'الحد الأدنى للطلب (جنيه)';

  @override
  String get promoTitleOptional => 'عنوان للعرض (اختياري)';

  @override
  String get promoStarts => 'يبدأ';

  @override
  String get promoEnds => 'ينتهي';

  @override
  String get promoMaxUses => 'أو ينتهي بعد عدد طلبات';

  @override
  String get promoNeedsEnd => 'لكل عرض شرط انتهاء: تاريخ أو عدد طلبات';

  @override
  String get promoAudienceNew => 'لأول طلب للعميل فقط';

  @override
  String get promoSave => 'حفظ العرض';

  @override
  String get promoCoversAll => 'يشمل كل المنتجات';

  @override
  String get promoFirstOrder => 'لأول طلب لك';

  @override
  String get businessTabOffers => 'العروض';

  @override
  String get cartOffersSaved => 'وفّرت بالعروض';

  @override
  String promoPercent(String value) {
    return 'خصم $value٪';
  }

  @override
  String promoAmount(String value) {
    return 'خصم $value جنيه';
  }

  @override
  String promoSpend(String min, String value) {
    return 'اشترِ بـ $min جنيه فأكثر واحصل على خصم $value٪';
  }

  @override
  String promoCovers(String names) {
    return 'يشمل: $names';
  }

  @override
  String promoEndsOn(String date) {
    return 'حتى $date';
  }

  @override
  String promoUsesLeft(int n) {
    return 'متبقٍ $n طلب';
  }

  @override
  String promoSelectedCount(int n) {
    return 'اخترتَ $n';
  }

  @override
  String promoItemsCount(int n) {
    return '$n منتجًا';
  }

  @override
  String promoNotYetDiscounted(String names) {
    return 'لم يُخصم بعد لأن سعره ارتفع أخيرًا: $names';
  }

  @override
  String get promoWayBuyGet => 'اشترِ … واحصل على …';

  @override
  String get promoBuyPay => 'اشترِ (تدفع ثمن كم قطعة)';

  @override
  String get promoGetTake => 'واحصل على (كم قطعة تأخذ)';

  @override
  String promoBuyGet(int pay, int take) {
    return 'اشترِ $pay واحصل على $take';
  }

  @override
  String promoBuyGetSentence(int pay, int take, int free) {
    return 'تدفع ثمن $pay وتأخذ $take، والمجاني $free';
  }

  @override
  String get promoBuyGetInvalid =>
      'اكتب الرقم الثاني أكبر من الأول (حتى 20 قطعة).';

  @override
  String get promoSameItemOnly => 'نفس الصنف فقط';

  @override
  String get promoMaxGroups => 'أقصى عدد مرات في الطلب (اختياري)';

  @override
  String get promoRulesTitle => 'قاعدة الخصم الحقيقي';

  @override
  String promoRulesBody(String percent, int days) {
    return 'لا يُخصم صنف ارتفع سعره بأكثر من $percent٪ خلال آخر $days يومًا، حتى لا يكون الخصم وهميًا. يبدأ خصمه تلقائيًا بعد انقضاء المدة، وتُخبَر باليوم عند حفظ العرض.';
  }

  @override
  String get promoSummaryTitle => 'ملخص العرض';

  @override
  String get promoStaySeason =>
      'تسري على إقامة (اختياري): الليالي داخل هذه الفترة فقط';

  @override
  String get promoStayFrom => 'إقامة من';

  @override
  String get promoStayTo => 'إلى';

  @override
  String get promoNightsHint =>
      'في الحجز الأرقام تعني ليالٍ: «اشترِ 2 واحصل على 3» = تدفع ليلتين وتقيم ثلاثًا.';

  @override
  String get bookingOfferLine => 'خصم عرض النشاط';

  @override
  String get promoSummaryFill => 'اكتب أرقام العرض';

  @override
  String get promoWholeKind => 'النوع كله';

  @override
  String get promoMaxBookings => 'أو ينتهي بعد عدد حجوزات';

  @override
  String get promoNeedsEndBooking => 'لكل عرض شرط انتهاء: تاريخ أو عدد حجوزات';

  @override
  String get pshTitle => 'الشراكات والحصص';

  @override
  String get pshEmpty =>
      'لا توجد شراكات بعد. ادعُ نشاطًا لتتعاقدا؛ تفاصيل التعاقد لا يراها غيركما.';

  @override
  String get pshPrivacy => 'تفاصيل هذه الشراكة لا يراها غيركما.';

  @override
  String get pshInvite => 'دعوة شريك';

  @override
  String get pshSearchHint => 'ابحث باسم النشاط';

  @override
  String get pshNoteHint => 'ملاحظة للطرف الآخر (اختياري)';

  @override
  String get pshSend => 'إرسال الدعوة';

  @override
  String get pshInviteSent => 'أُرسلت الدعوة';

  @override
  String get pshKindAgency => 'شركة سياحة';

  @override
  String get pshKindReseller => 'موزّع';

  @override
  String get pshKindSupplier => 'مورّد';

  @override
  String get pshKindCorporate => 'شركة';

  @override
  String get pshKindAllotment => 'حصة فندقية';

  @override
  String get pshStatusActive => 'فعّالة';

  @override
  String get pshStatusPending => 'بانتظار الرد';

  @override
  String get pshStatusPaused => 'موقوفة';

  @override
  String get pshStatusRejected => 'مرفوضة';

  @override
  String get pshStatusEnded => 'منتهية';

  @override
  String get pshRoleOwner => 'أنت المانح';

  @override
  String get pshRolePartner => 'أنت الشريك';

  @override
  String get pshAwaitingYou => 'بانتظار ردك';

  @override
  String get pshAccept => 'قبول';

  @override
  String get pshDecline => 'رفض';

  @override
  String get pshPause => 'إيقاف مؤقت';

  @override
  String get pshResume => 'استئناف';

  @override
  String get pshEnd => 'إنهاء الشراكة';

  @override
  String get pshEndConfirm =>
      'تنتهي الشراكة وتتوقف الحصص التي فيها. لا يمكن التراجع.';

  @override
  String get pshAllocations => 'الحصص';

  @override
  String get pshNoAllocationsOwner =>
      'لم تمنح حصصًا بعد. اضغط «منح حصة» لتعطي شريكك عددًا من غرفك.';

  @override
  String get pshNoAllocationsPartner => 'لم يمنحك الطرف الآخر حصصًا بعد.';

  @override
  String get pshGrant => 'منح حصة';

  @override
  String get pshEdit => 'تعديل';

  @override
  String get pshStop => 'إيقاف الحصة';

  @override
  String get pshActivate => 'تفعيل الحصة';

  @override
  String get pshAllocationStopped => 'موقوفة';

  @override
  String get pshPickRoom => 'اختر الغرفة';

  @override
  String pshUngranted(int n) {
    return 'المتاح للمنح: $n';
  }

  @override
  String get pshQuantity => 'عدد الغرف لكل ليلة';

  @override
  String get pshContractPrice => 'سعر التعاقد لليلة';

  @override
  String get pshMinNights => 'أقل إقامة (ليالٍ)';

  @override
  String get pshMaxNights => 'أقصى إقامة (ليالٍ)';

  @override
  String get pshReleaseDays => 'تُفرج الكمية قبل الموعد بـ (أيام)';

  @override
  String get pshReleaseHelp =>
      'ما لم يُحجز يعود إلى مخزونك قبل الموعد بهذه المدة';

  @override
  String get pshGrantIncomplete => 'اختر الغرفة واكتب الكمية وسعر التعاقد';

  @override
  String pshAvailableOf(int available, int total) {
    return 'المتاح $available من $total غرفة لكل ليلة';
  }

  @override
  String pshContractLine(String price) {
    return 'سعر التعاقد $price';
  }

  @override
  String pshSellLine(String price) {
    return 'سعر بيعك $price';
  }

  @override
  String pshNightsRange(int min, int max) {
    return 'الإقامة من $min إلى $max ليالٍ (0 = بلا حد)';
  }

  @override
  String pshReleaseLine(int days) {
    return 'تُفرج قبل الموعد بـ $days يومًا';
  }

  @override
  String get pshPriceIt => 'سعّر';

  @override
  String get pshPriceTitle => 'سعر البيع للعميل';

  @override
  String get pshMarkupNone => 'بسعر التعاقد';

  @override
  String get pshMarkupFixed => 'مبلغ فوقه';

  @override
  String get pshMarkupPercent => 'نسبة فوقه';

  @override
  String get pshMarkupValue => 'قيمة الزيادة';

  @override
  String pshFinalPrice(String price) {
    return 'يراه العميل: $price';
  }

  @override
  String get pshFloorHint => 'لا يقل سعر بيعك عن سعر التعاقد.';

  @override
  String get pshPartnerRoomsTitle => 'غرف من فنادق شريكة';

  @override
  String pshFromHotel(String name) {
    return 'من $name';
  }

  @override
  String pshRoomsLeft(int n) {
    return 'متبقي $n';
  }

  @override
  String get pshPerNight => 'لليلة';

  @override
  String get tripScreenTitle => 'برامج الرحلات';

  @override
  String get tripProgramsTab => 'البرامج';

  @override
  String get tripEmpty =>
      'لم تكتب برنامجًا بعد. اكتب رحلتك أيامًا وبنودًا، وضع فيها كروت الغرف التي منحها لك فندق.';

  @override
  String get tripNew => 'برنامج جديد';

  @override
  String get tripTitleHint => 'اسم البرنامج';

  @override
  String get tripSummaryHint => 'وصف مختصر (اختياري)';

  @override
  String get tripDraft => 'مسودة';

  @override
  String get tripPublished => 'منشور';

  @override
  String tripDaysCount(int n) {
    return '$n أيام';
  }

  @override
  String tripDayLabel(int n) {
    return 'اليوم $n';
  }

  @override
  String get tripAddDay => 'إضافة يوم';

  @override
  String get tripDayTitleHint => 'عنوان اليوم (اختياري)';

  @override
  String get tripAddText => 'نص';

  @override
  String get tripAddRoom => 'كارت غرفة';

  @override
  String get tripAddPhoto => 'صورة';

  @override
  String get tripPhotoCaption => 'تعليق على الصورة (اختياري)';

  @override
  String get tripPickRoom => 'اختر غرفة من الغرف الممنوحة لشركتك';

  @override
  String get tripNoRooms =>
      'لا توجد غرف ممنوحة لشركتك بعد. تظهر هنا حين يمنحك فندق حصة.';

  @override
  String get tripPublish => 'نشر البرنامج';

  @override
  String get tripUnpublish => 'إلغاء النشر';

  @override
  String get tripDeleteConfirm =>
      'يُحذف البرنامج بأيامه وصوره. لا يمكن التراجع.';

  @override
  String get tripDeleteDayConfirm => 'يُحذف اليوم مع بنوده.';

  @override
  String get tripMoveUp => 'أعلى';

  @override
  String get tripMoveDown => 'أسفل';

  @override
  String get tripBookRoom => 'احجز هذه الغرفة';

  @override
  String get tripSoldOut => 'نفدت';

  @override
  String get tripRoomGone => 'هذا العرض متوقف حاليًا';

  @override
  String get guestScopeLabel => 'لمن تُباع هذه الغرفة؟';

  @override
  String get guestScopeHelp =>
      'لتسعير محلي وآخر سياحي اجعل لكل سعر نوع غرفة. يُطلب إثبات عند الوصول.';

  @override
  String get reserveRoomsLabel => 'غرف احتياطية للضغط';

  @override
  String get reserveRoomsHelp =>
      'عدد من هذا النوع يحجزه الفندق لنزلائه فقط، لا يبيعه الشركاء';

  @override
  String get roomFeaturesAction => 'مواصفات هذه الغرفة';

  @override
  String get roomFeaturesNone => 'لم تُحدَّد بعد';

  @override
  String roomFeaturesTitle(String number) {
    return 'مواصفات الغرفة $number';
  }

  @override
  String get roomFeaturesHint =>
      'الضيف الذي اختار إطلالة أو ميزة عند الحجز يأخذ عند بدء الإقامة رقمًا يحملها';

  @override
  String get childPolicyFirstChild => 'الطفل الأول';

  @override
  String get childPolicyNextChild => 'كل طفل بعده';

  @override
  String get extraBedTitle => 'السرير الإضافي';

  @override
  String get extraBedHint =>
      'نزيل زائد عن سعة الغرفة يُضاف له سرير بسعره بدل رفض الحجز. اتركه فارغًا إن كان الفندق لا يوفّره. الطفل الزائد يدفع نسبته فقط.';

  @override
  String get extraBedPrice => 'سعر السرير الإضافي لليلة';

  @override
  String get extraBedsMax => 'الحد لكل غرفة';

  @override
  String extraBedLine(int n) {
    return 'سرير إضافي × $n';
  }

  @override
  String get mealTimesTitle => 'مواعيد الوجبات';

  @override
  String get mealTimesIntro =>
      'يرى النزيل في حجزه مواعيد الوجبات التي يشملها نظامه: الإفطار للإفطار، ونصف الإقامة للإفطار والعشاء، والإقامة الكاملة والشامل كليًا للثلاث.';

  @override
  String get mealTimesSaved => 'حُفظت مواعيد الوجبات';

  @override
  String get mealTimesYours => 'مواعيد الوجبات';

  @override
  String get mealFrom => 'من';

  @override
  String get mealTo => 'إلى';

  @override
  String settlementConfirmedBy(String name) {
    return 'أكّدها: $name';
  }

  @override
  String settlementForBusiness(String name) {
    return 'نيابةً عن $name';
  }

  @override
  String get settlementIConfirmed => 'أكّدتَ التسوية — بانتظار الطرف الآخر';

  @override
  String get settlementWalletOfferGuest => 'اعرض التسوية من محفظتك';

  @override
  String get settlementWalletAskHotel => 'اطلب التسوية من محفظة العميل';

  @override
  String get settlementWalletSendOffer => 'إرسال العرض';

  @override
  String get settlementWalletSendAsk => 'إرسال الطلب';

  @override
  String settlementWalletMine(String amount) {
    return 'عرضك: $amount ج — بانتظار موافقة الطرف الآخر';
  }

  @override
  String get settlementWalletWithdraw => 'سحب العرض';

  @override
  String settlementWalletHotelAsks(String amount) {
    return 'الفندق يطلب $amount ج من عربونك ليتم التسوية ويعود لك الباقي';
  }

  @override
  String settlementWalletGuestOffers(String amount) {
    return 'العميل يعرض أن تأخذ $amount ج من عربونه ويتم التسوية';
  }

  @override
  String get settlementWalletAccept => 'موافق';

  @override
  String get settlementWalletDecline => 'رفض';

  @override
  String get settlementCollectTitle => 'التسوية من محفظة التطبيق';

  @override
  String settlementCollectNote(String amount) {
    return 'أسرع طريقة لإنهاء التسوية: يعرض العميل أن يأخذ الفندق من عربونه المجمّد ($amount ج) أو جزءًا منه، أو يطلب الفندق ذلك — ولا يُؤخذ شيء إلا بموافقة الطرف الآخر. ثم يعود الباقي لأصحابه وتتم التسوية.';
  }

  @override
  String get settlementCollectButton => 'تحصيل من المحفظة';

  @override
  String settlementCollectAll(String amount) {
    return 'العربون كاملًا ($amount ج)';
  }

  @override
  String get settlementCollectFine => 'غرامة بمبلغ أقل';

  @override
  String settlementCollectAmount(String max) {
    return 'المبلغ (حتى $max ج)';
  }

  @override
  String settlementCollectedNote(String amount) {
    return 'باتفاق الطرفين أُخذ $amount ج من العربون للفندق، وعاد الباقي لأصحابه وتمت التسوية.';
  }

  @override
  String get settlementStayStartedNote =>
      'استلم الفندق المبلغ وبدأت الإقامة، ففُك العربون والتأمين.';

  @override
  String settlementTitle(int id) {
    return 'التسوية · حجز #$id';
  }

  @override
  String get settlementNone => 'لا يوجد ما يُسوّى في هذا الحجز';

  @override
  String get settlementPlease => 'يرجى التسوية لفك العربون';

  @override
  String get settlementOpenButton => 'التسوية والعربون';

  @override
  String get settlementFrozen => 'المجمّد لهذا الحجز';

  @override
  String settlementClientHold(String pct) {
    return 'عربون العميل ($pct%)';
  }

  @override
  String settlementBusinessHold(String pct) {
    return 'تأمين الفندق ($pct%)';
  }

  @override
  String settlementFromGuarantee(String amount) {
    return '$amount من الضمان';
  }

  @override
  String settlementFromWallet(String amount) {
    return '$amount من المحفظة';
  }

  @override
  String get settlementSecuredNote =>
      'مجمّد ما دام الحجز قائمًا، ويُفك فور بدء الإقامة بعد أن يستلم الفندق المبلغ. لا يُخصم من أحد.';

  @override
  String get settlementOpenNote =>
      'أُلغي الحجز. المجمّد لا يُفك تلقائيًا أبدًا — يُفك عندما يؤكد الطرفان «تمت التسوية»، أو يوافق أحدهما على عرض التسوية من محفظة التطبيق، أو يؤكد الفندق استلام دفعة سجّلها العميل، أو يحكم المحكّم.';

  @override
  String get settlementSettledNote => 'تمت التسوية وعاد كل ما جُمّد لصاحبه.';

  @override
  String get settlementArbitrationNote =>
      'الحجز في التحكيم؛ المجمّد ينتظر حكم المحكّم.';

  @override
  String get settlementConfirmTitle => 'تأكيد التسوية';

  @override
  String get settlementHotel => 'الفندق';

  @override
  String get settlementGuest => 'العميل';

  @override
  String get settlementWaiting => 'بانتظار تأكيده';

  @override
  String get settlementDone => 'تمت التسوية';

  @override
  String get settlementWithdraw => 'سحب تأكيدي';

  @override
  String get settlementBothNeeded =>
      'لا يُفك العربون إلا بتأكيد الطرفين. يمكنك سحب تأكيدك حتى يؤكد الطرف الآخر.';

  @override
  String get settlementPaymentsTitle => 'الدفعات خارج التطبيق';

  @override
  String get settlementPaymentsNote =>
      'يسجّلها العميل بإثباتها، ويؤكد الفندق وحده استلامها.';

  @override
  String get settlementRecordPayment => 'تسجيل دفعة خارج التطبيق';

  @override
  String get settlementRecordSend => 'تسجيل الدفعة';

  @override
  String get settlementOwnResponsibility =>
      'الدفع خارج التطبيق على مسؤوليتك الشخصية، ويجب أن يكون لديك إثبات الدفع. التطبيق لا يستلم المبلغ ولا يضمنه؛ يسجّل ما تقوله وإثباتك فقط، والفندق وحده يؤكد الاستلام.';

  @override
  String get settlementAcknowledge =>
      'أقر بأن الدفع خارج التطبيق على مسؤوليتي الشخصية، وأن الإثبات المرفق صحيح ويخص هذا الحجز.';

  @override
  String get settlementAmount => 'المبلغ المدفوع';

  @override
  String get settlementTransfer => 'تحويل';

  @override
  String get settlementCash => 'نقدًا';

  @override
  String get settlementReference => 'رقم العملية أو المرجع (اختياري)';

  @override
  String get settlementProof => 'إثبات الدفع (إيصال أو صورة التحويل)';

  @override
  String get settlementProofCamera => 'كاميرا';

  @override
  String get settlementProofGallery => 'المعرض';

  @override
  String get settlementPaymentMissing =>
      'اكتب المبلغ وأرفق الإثبات ووافق على الإقرار';

  @override
  String get settlementPaymentWaiting => 'بانتظار رد الفندق';

  @override
  String get settlementPaymentReceived => 'أكّد الفندق الاستلام';

  @override
  String get settlementPaymentRefused => 'الفندق يقول إنها لم تصل';

  @override
  String get settlementPaymentConfirmed => 'تم تأكيد الاستلام';

  @override
  String get settlementArrived => 'وصلت';

  @override
  String get settlementNotArrived => 'لم تصل';

  @override
  String get settlementNotArrivedNote => 'ملاحظة للعميل';

  @override
  String get settlementNoAgreement => 'لم تتفقا؟';

  @override
  String get settlementArbitrationHow =>
      'بعد 3 أيام من الإلغاء بلا تسوية، يكفي طرف واحد لطلب تحكيم. المحكّم يحكم من شروط الحجز وإثباتات الدفع والمحادثة، ويحدد التعويض من قيمة الحجز نفسه. الحساب لا يتوقف؛ من لا يدفع ما حُكم عليه يُجمَّد ضمانه بقدره ثم يُحصَّل من محفظته أو ضمانه.';

  @override
  String get settlementArbitrationAsk => 'طلب تحكيم';

  @override
  String get settlementArbitrationTitle => 'طلب تحكيم';

  @override
  String get settlementArbitrationConfirm =>
      'سيُفتح نزاع على هذا الحجز ويُحال لمحكّم. رسم الجلسة يتحمله الطرف الخاسر، ويجب أن يغطيه رصيدك الآن.';

  @override
  String settlementArbitrationFrom(String date) {
    return 'يمكن طلب التحكيم من $date';
  }

  @override
  String get settlementOpenDispute => 'فتح النزاع';

  @override
  String get settlementsTitle => 'تسويات بانتظارك';

  @override
  String get settlementsEmpty => 'لا توجد تسويات مفتوحة';

  @override
  String get settlementTheyConfirmed => 'الطرف الآخر أكّد — بانتظار تأكيدك';

  @override
  String get settlementWaitingBoth => 'بانتظار تأكيد الطرفين';

  @override
  String get ratePlanDeposit => 'نسبة عربون الجدية';

  @override
  String get ratePlanDepositHint =>
      'يُجمَّد من العميل، ومثله تأمين منك، عند قبولك الحجز — من الضمان أولًا ثم المحفظة. لا يُخصم من أحد، ويُفك عندما تتم التسوية.';

  @override
  String ratePlanDepositGuest(String amount) {
    return 'عربون الجدية $amount ج يُجمَّد من ضمانك ثم محفظتك عند قبول الفندق، ومثله من الفندق، ويُفك عند التسوية.';
  }

  @override
  String get stayDetailsTitle => 'تفاصيل الإقامة';

  @override
  String get stayAdults => 'البالغون';

  @override
  String get stayChildren => 'الأطفال';

  @override
  String stayChildLine(int age, String pays) {
    return 'طفل $age سنوات — $pays';
  }

  @override
  String stayChildSingleParent(int age, String pays) {
    return 'طفل $age سنوات مكان البالغ الثاني — $pays';
  }

  @override
  String get stayMealPlan => 'نظام الوجبات';

  @override
  String get stayOccupancy => 'الإشغال';

  @override
  String prepaymentOwed(String amount) {
    return 'المبلغ كاملًا مستحق مقدمًا: $amount ج';
  }

  @override
  String get prepaymentWaiting =>
      'سعر غير قابل للاسترداد — لا يبدأ تسجيل الوصول قبل أن تؤكد استلامه أو تتنازل عنه.';

  @override
  String get prepaymentWaive => 'التنازل عن الدفع المقدم';

  @override
  String get prepaymentReceived => 'تم تأكيد استلام المبلغ المقدم.';

  @override
  String get prepaymentWaived => 'تنازلت عن الدفع المقدم.';

  @override
  String prepaymentCustomerNote(String amount) {
    return 'سعر غير قابل للاسترداد: ادفع المبلغ كاملًا ($amount ج) للفندق مقدمًا كاش أو تحويلًا. لا يبدأ تسجيل الوصول حتى يؤكد الفندق استلامه.';
  }

  @override
  String get nonRefundableCancelTitle => 'إلغاء حجز غير قابل للاسترداد؟';

  @override
  String nonRefundableCancelBody(String amount) {
    return 'حجزت هذه الإقامة بالسعر غير القابل للاسترداد. ما دفعته للفندق مقدمًا ($amount ج) لا يُسترد عند الإلغاء. يرجى التسوية لفك العربون: عربونك المجمّد، ومثله تأمين الفندق، لا يُخصم من أحد ويُفك عندما تؤكدان معًا «تمت التسوية»؛ وإن لم تتفقا خلال 3 أيام يمكن لأي منكما طلب تحكيم.';
  }

  @override
  String get singleOccupancyLabel => 'سعر الإقامة الفردية';

  @override
  String get singleOccupancyHelp =>
      'ما يدفعه بالغ واحد وحده في الغرفة من سعر الليلة (مثلًا 85%). اتركه فارغًا ليدفع سعر الغرفة كاملًا.';

  @override
  String singleOccupancyLine(String pct) {
    return 'إقامة فردية ($pct من الغرفة)';
  }

  @override
  String get thirdAdultLabel => 'تخفيض الشخص الثالث';

  @override
  String get thirdAdultHint =>
      'إن كتبته، يدفع البالغ في السرير الإضافي سعر الفرد ناقص هذه النسبة بدل سعر السرير الثابت.';

  @override
  String get cotTitle => 'سرير أطفال';

  @override
  String get cotsPerRoom => 'عدد أسرّة الأطفال لكل غرفة';

  @override
  String get cotPrice => 'سعر سرير الأطفال لليلة';

  @override
  String get cotPriceHint => 'اتركه فارغًا إن كان مجانيًا';

  @override
  String cotAsk(String price) {
    return 'سرير أطفال ($price)';
  }

  @override
  String cotLine(int n) {
    return 'سرير أطفال × $n';
  }

  @override
  String get ratePlansTitle => 'خطط الأسعار';

  @override
  String get ratePlansIntro =>
      'بجانب السعر المرن يمكنك بيع سعر أرخص غير قابل للاسترداد: يدفع النزيل للفندق المبلغ كاملًا مقدمًا خارج التطبيق، ولا يمكنه تغيير الموعد. التطبيق لا يصادر أي عربون.';

  @override
  String get ratePlansSaved => 'حُفظت خطط الأسعار';

  @override
  String get ratePlanFlexible => 'سعر مرن';

  @override
  String get ratePlanFlexibleHint =>
      'السعر العادي — يمكن للنزيل تغيير الموعد أو الإلغاء.';

  @override
  String get ratePlanFlexibleGuest => 'يمكنك تغيير الموعد أو الإلغاء';

  @override
  String get ratePlanNonRefundable => 'غير قابل للاسترداد';

  @override
  String get ratePlanNonRefundableHint =>
      'أرخص بنسبة تحددها، يُدفع كاملًا مقدمًا ولا يُغيّر موعده.';

  @override
  String get ratePlanNonRefundableGuest =>
      'أرخص — تدفع للفندق كاملًا مقدمًا ولا يمكن تغيير الموعد أو استرداد المبلغ';

  @override
  String get ratePlanNonRefundableBooked =>
      'سعر غير قابل للاسترداد — لا يمكن تغيير الموعد';

  @override
  String get ratePlanDiscount => 'نسبة التخفيض';

  @override
  String get ratePlanDiscountHint => 'من 1% إلى 50%';

  @override
  String get ratePlanChoose => 'خطة السعر';

  @override
  String nonRefundableLine(String pct) {
    return 'خصم غير قابل للاسترداد ($pct)';
  }

  @override
  String get seasonsTitle => 'المواسم';

  @override
  String get seasonsIntro =>
      'لكل موسم سعر للغرف (نسبة أو مبلغ على كل الأنواع، أو سعر ليلة لنوع بعينه)، وسعر لأنظمة الوجبات، وأقل عدد ليالٍ لمن يصل فيه. المواسم لا تتداخل.';

  @override
  String get seasonsEmpty => 'لا توجد مواسم';

  @override
  String get seasonAdd => 'إضافة موسم';

  @override
  String get seasonEdit => 'تعديل الموسم';

  @override
  String get seasonName => 'اسم الموسم';

  @override
  String get seasonNameHint => 'الصيف، عيد الأضحى، رأس السنة…';

  @override
  String get seasonDates => 'من … إلى …';

  @override
  String get seasonMissing => 'اكتب اسم الموسم واختر تواريخه';

  @override
  String get seasonRoomsTitle => 'سعر الغرف في الموسم';

  @override
  String get seasonChangePercent => 'نسبة';

  @override
  String get seasonChangeAmount => 'مبلغ';

  @override
  String get seasonChangeValue => 'الزيادة أو التخفيض';

  @override
  String get seasonChangeHint =>
      'على كل أنواع الغرف — اكتب رقمًا سالبًا للتخفيض';

  @override
  String get seasonRoomPriceHint =>
      'أو سعر ليلة لنوع غرفة بعينه (يغلب على النسبة):';

  @override
  String get seasonMealsTitle => 'سعر الوجبات في الموسم';

  @override
  String seasonMealOwnPrice(String price) {
    return 'سعره العادي $price — اتركه فارغًا ليبقى كما هو';
  }

  @override
  String get seasonMinNights => 'أقل عدد ليالٍ';

  @override
  String get seasonNoMinimum => 'بلا حد';

  @override
  String get seasonMinNightsHint => 'لمن يصل خلال الموسم';

  @override
  String seasonRoomPricesN(int n) {
    return '$n أسعار غرف';
  }

  @override
  String seasonMealPricesN(int n) {
    return '$n أسعار وجبات';
  }

  @override
  String seasonMinNightsN(int n) {
    return 'أقل إقامة $n ليالٍ';
  }

  @override
  String get singleParentTitle => 'بالغ واحد مع طفل';

  @override
  String get singleParentHint =>
      'في غرفة بها بالغ واحد، مكان البالغ الثاني مدفوع في سعر الغرفة؛ الطفل (الأكبر) الذي يشغله يدفع ما تحدده هنا بدل نسبته المعتادة.';

  @override
  String get singleParentChild => 'الطفل مكان البالغ';

  @override
  String bookingChildSingleParentLine(int age, String pays) {
    return 'طفل $age سنوات مكان البالغ الثاني · $pays';
  }

  @override
  String get galaTitle => 'العشاء الإلزامي';

  @override
  String get galaIntro =>
      'ليالي الحفلات (رأس السنة، الكريسماس، الأعياد…): كل إقامة تشمل الليلة تدفع العشاء — كل بالغ بالسعر، والطفل من السن المحدد بنسبته، ومن هو أصغر مجانًا — أيًا كان نظام الوجبات، وعند بيع الشريك لغرفك أيضًا.';

  @override
  String get galaEmpty => 'لا توجد ليالٍ بعشاء إلزامي';

  @override
  String get galaAdd => 'إضافة عشاء إلزامي';

  @override
  String get galaEdit => 'تعديل العشاء الإلزامي';

  @override
  String get galaDate => 'الليلة';

  @override
  String get galaName => 'الاسم';

  @override
  String get galaNameHint => 'عشاء رأس السنة';

  @override
  String get galaAdultPrice => 'سعر البالغ';

  @override
  String get galaChildPercent => 'نسبة الطفل من سعر البالغ';

  @override
  String get galaFreeUnder => 'مجانًا للطفل أقل من (سنة)';

  @override
  String get galaMissing => 'اختر الليلة واكتب الاسم وسعر البالغ';

  @override
  String galaSummary(String price, String percent, int age) {
    return 'البالغ $price · الطفل $percent% · مجانًا تحت $age سنوات';
  }

  @override
  String galaLine(String name, String date) {
    return '$name ($date) — إلزامي';
  }

  @override
  String get childPolicyTitle => 'سياسة الأطفال';

  @override
  String get childPolicyIntro =>
      'حدّد أعمار الأطفال وما يدفعه كل طفل من سعر الليلة. تنطبق على كل غرفك وعلى ما يبيعه شركاؤك من غرفك.';

  @override
  String get childPolicyBands => 'الشرائح';

  @override
  String get childPolicyFrom => 'من عمر';

  @override
  String get childPolicyTo => 'إلى عمر';

  @override
  String get childPolicyPercent => 'نسبة أخرى';

  @override
  String get childPolicyAddBand => 'أضف شريحة';

  @override
  String get childPolicyAdultAge => 'يُعامل كبالغ من عمر';

  @override
  String get childPolicyCountsFrom => 'يُحسب من سعة الغرفة من عمر';

  @override
  String get childPolicyMeals => 'وجبات الطفل بنفس النسبة';

  @override
  String get childPolicySaved => 'حُفظت سياسة الأطفال';

  @override
  String get childFree => 'مجانًا';

  @override
  String get childHalf => 'نصف';

  @override
  String get childThird => 'ثلث';

  @override
  String get bookingChildrenTitle => 'الأطفال';

  @override
  String get bookingAddChild => 'أضف طفلًا';

  @override
  String bookingChildN(int n) {
    return 'الطفل $n';
  }

  @override
  String get bookingChildAge => 'العمر';

  @override
  String bookingChildLine(int age, String pays) {
    return 'طفل $age سنوات · $pays';
  }

  @override
  String bookingGuestsMax(int n) {
    return 'الحد الأقصى $n';
  }

  @override
  String get bookingRoomKindTitle => 'الغرفة';

  @override
  String roomFeaturesPrice(String base, String extra, String total) {
    return 'سعر هذه الغرفة لليلة: $base + $extra = $total';
  }

  @override
  String get unitFeaturesVsRoomsHint =>
      'حدّد هنا ما تحمله كل غرف هذا النوع (سعره داخل سعر النوع). وما تحمله بعض الغرف فقط حدّده على رقم الغرفة من قائمة الأرقام أعلاه.';

  @override
  String bookingRoomRequested(String names) {
    return 'طلب الضيف: $names';
  }

  @override
  String get bookingRoomMatches => 'تحمل ما طلبه الضيف';

  @override
  String get bookingRoomNoMatch => 'لا تحمل كل ما طلبه الضيف';

  @override
  String get pshGuaranteedLabel => 'حصة مضمونة';

  @override
  String get pshGuaranteedHelp =>
      'مغلقة: الغرف محجوزة للشريك وحده. مفتوحة (الافتراضي): يبيع الفندق والشريك من نفس المخزون في وقت واحد';

  @override
  String get guestScopeAll => 'للجميع';

  @override
  String get guestScopeLocals => 'للمصريين والمقيمين فقط';

  @override
  String get guestScopeForeigners => 'للأجانب فقط';

  @override
  String get guestScopeConfirmRequired => 'أكّد الخانة أعلاه للمتابعة';

  @override
  String get guestScopeConfirmLocals =>
      'أقرّ بأنني مصري أو مقيم في مصر وسأقدّم ما يثبت ذلك عند الوصول';

  @override
  String get guestScopeConfirmForeigners =>
      'أقرّ بأنني أجنبي وسأقدّم جواز السفر عند الوصول';

  @override
  String get boardTitle => 'شاشة الغرف';

  @override
  String get boardEmpty =>
      'لا توجد أنواع غرف للإقامة بعد. أضفها من إعدادات الحجز لتظهر هنا.';

  @override
  String get boardFree => 'شاغر';

  @override
  String get boardPartly => 'محجوز جزئيًا';

  @override
  String get boardFull => 'مكتمل';

  @override
  String get boardViaPartner => 'بيع عبر شريك';

  @override
  String boardStock(int n) {
    return '$n غرفة';
  }

  @override
  String boardHeld(int n) {
    return '$n محجوزة لشركاء ولم تُبَع بعد';
  }

  @override
  String boardSoldBy(String name) {
    return 'باعته $name';
  }

  @override
  String get boardDirect => 'حجز مباشر';

  @override
  String boardRoomNumber(String n) {
    return 'غرفة $n';
  }

  @override
  String get boardCheckLocal => 'تحقق من الهوية المصرية أو الإقامة';

  @override
  String get boardCheckForeign => 'تحقق من جواز السفر';

  @override
  String pshNightsFrom(int min) {
    return 'إقامة $min ليالٍ فأكثر';
  }

  @override
  String bookingHoldBanner(String time) {
    return 'الغرفة محجوزة لك مؤقتًا — تنتهي بعد $time';
  }

  @override
  String get bookingUnitHeld => 'تحت التعامل من طرف آخر';

  @override
  String get boardDealing => 'تحت التعامل';

  @override
  String boardDealingNow(int n) {
    return 'تحت التعامل الآن · ينتهي خلال $n د';
  }

  @override
  String boardDealingVia(String name) {
    return 'عبر $name';
  }

  @override
  String get boardDealingHotel => 'من شاشة الفندق';

  @override
  String get guestOriginQuestion => 'أنا…';

  @override
  String get guestOriginLocal => 'مصري أو مقيم';

  @override
  String get guestOriginForeign => 'أجنبي';

  @override
  String get bookingHoldRelease => 'إلغاء الحجز المؤقت';

  @override
  String bookingMyHold(String time) {
    return 'محجوزة لك — تنتهي بعد $time';
  }

  @override
  String get bookingAskRelease => 'اطلب تحريرها من الشريك';

  @override
  String get bookingReleaseWaiting => 'أُرسل طلبك إلى الشريك. بانتظار موافقته…';

  @override
  String get bookingReleaseDeclined => 'اعتذر الشريك عن تحرير الغرفة.';

  @override
  String get bookingReleaseExpired => 'انتهت مهلة الطلب دون رد.';

  @override
  String get pshReleaseTitle => 'طلبات تحرير غرف';

  @override
  String get pshReleaseHint =>
      'ضيف للفندق يطلب غرفة محجوزة لكم. بالموافقة تعود الغرفة إلى الفندق.';

  @override
  String pshReleaseRoom(String room, String from, String to) {
    return '$room · من $from إلى $to';
  }

  @override
  String get pshReleaseApprove => 'موافقة';

  @override
  String get pshReleaseDecline => 'اعتذار';

  @override
  String get pshStayDates => 'تغطي إقامات من ليلة… إلى ليلة…';

  @override
  String get pshStayAny => 'بلا تحديد (كل الأيام)';

  @override
  String pshStanding(int n, int pending) {
    return 'حجوزات قائمة: $n · بانتظار رد الفندق: $pending';
  }

  @override
  String get pshStandingHint =>
      'تبقى سارية بعد انتهاء الحصة أو إيقافها؛ لا يُلغى منها شيء.';

  @override
  String get stkTitle => 'المخزون';

  @override
  String get stkTileSubtitle => 'يكفي مبيعات اليوم؟ واعتماد أوامر الشراء';

  @override
  String get stkNotAvailable => 'المخزون غير متاح لتصنيف نشاطك.';

  @override
  String get stkEnableTitle => 'المخزون والمشتريات';

  @override
  String get stkEnableBody =>
      'تابع المخزون لحظيًا: كل استلام وبيع وهالك حركة مسجلة، والبيع من التطبيق يخصم تلقائيًا بالوصفة. الإدارة الكاملة من تطبيق الكمبيوتر، وتتابعه من هنا.';

  @override
  String stkSubscriptionPrice(String price) {
    return 'الاشتراك الشهري: $price ج من رصيد المحفظة';
  }

  @override
  String get stkSubscriptionFree => 'بدون رسوم اشتراك حاليًا.';

  @override
  String get stkEnableAction => 'تفعيل المخزون';

  @override
  String get stkOwnerEnables => 'يفعّله صاحب النشاط.';

  @override
  String get stkStockValue => 'قيمة المخزون';

  @override
  String get stkCurrency => 'ج';

  @override
  String get stkBelowReorder => 'تحت حد الطلب';

  @override
  String stkPendingApproval(int number) {
    return 'أمر شراء #$number بانتظار اعتمادك';
  }

  @override
  String get stkCoversToday => 'يكفي مبيعات اليوم؟';

  @override
  String get stkNoItems => 'لا أصناف بعد.';

  @override
  String stkCoverageLine(String days, String onHand, String unit) {
    return '$onHand $unit — يكفي ~$days يوم';
  }

  @override
  String get stkVerdictNo => 'لا يكفي';

  @override
  String get stkVerdictTight => 'يكفي بالكاد';

  @override
  String get stkVerdictYes => 'يكفي';

  @override
  String get stkVerdictEmpty => 'نفد';

  @override
  String get stkVerdictUnknown => 'لا مبيعات بعد';

  @override
  String get stkOnHandNow => 'الرصيد الآن';

  @override
  String stkCoverageExplain(
    String avg,
    String rest,
    String today,
    String unit,
  ) {
    return 'بِيع اليوم $today $unit، ومتوسط هذا اليوم في آخر 4 أسابيع $avg، فالمتوقع للباقي ~$rest.';
  }

  @override
  String stkDaysLeft(String days) {
    return 'يكفي ~$days يوم بالمعدل الحالي.';
  }

  @override
  String get stkRecentMoves => 'آخر الحركات';

  @override
  String get stkRecordWaste => 'سجّل هالك';

  @override
  String stkQtyIn(String unit) {
    return 'الكمية ($unit)';
  }

  @override
  String get stkReason => 'السبب';

  @override
  String get stkSaved => 'تم الحفظ.';

  @override
  String get stkReject => 'رفض';

  @override
  String stkPurchaseOrderNo(int number) {
    return 'أمر شراء #$number';
  }

  @override
  String get stkOnBim => 'على BIM';

  @override
  String get stkTotal => 'الإجمالي';

  @override
  String get stkApproveAndSend => 'اعتماد وإرسال';

  @override
  String get stkIncomingTitle => 'أوامر الشراء الواردة';

  @override
  String get stkIncomingEmpty => 'لم يرسل لك أي نشاط أمر شراء بعد.';

  @override
  String get stkConfirmed => 'أكّدت هذا الأمر.';

  @override
  String get stkConfirmOrder => 'تأكيد الأمر';

  @override
  String get stkMoveReceipt => 'استلام';

  @override
  String get stkMoveSale => 'بيع';

  @override
  String get stkMoveSaleReversal => 'إرجاع بيع';

  @override
  String get stkMoveWaste => 'هالك';

  @override
  String get stkMoveTransferOut => 'تحويل خارج';

  @override
  String get stkMoveTransferIn => 'تحويل داخل';

  @override
  String get stkMoveAdjustment => 'تسوية جرد';

  @override
  String get stkMoveSupplierReturn => 'مرتجع لمورد';

  @override
  String get stkMoveOpening => 'رصيد افتتاحي';

  @override
  String get stkMoveReversal => 'عكس حركة';

  @override
  String get stkPoDraft => 'مسودة';

  @override
  String get stkPoPending => 'بانتظار الاعتماد';

  @override
  String get stkPoApproved => 'معتمد ومُرسل';

  @override
  String get stkPoPartial => 'مستلم جزئيًا';

  @override
  String get stkPoReceived => 'مستلم بالكامل';

  @override
  String get stkPoClosed => 'مغلق';

  @override
  String get stkPoRejected => 'مرفوض';

  @override
  String get stkPoCancelled => 'ملغي';

  @override
  String get suiteBrand => 'BIM للأعمال';

  @override
  String get suiteSignInTitle => 'ادخل بحسابك على BIM';

  @override
  String get suiteSignInHint =>
      'نفس الحساب الذي تستخدمه في التطبيق. الموظف يدخل بحسابه هو.';

  @override
  String get suiteLoginField => 'البريد الإلكتروني';

  @override
  String get suiteChooseBusiness => 'اختر النشاط الذي يعمل له هذا الجهاز';

  @override
  String get suiteNoBusiness =>
      'حسابك ليس صاحب نشاط، ولا موظفًا بصلاحية مخزون أو مشتريات أو كاشير.';

  @override
  String get suiteNavDashboard => 'لوحة اليوم';

  @override
  String get suiteNavItems => 'الأصناف والمخزون';

  @override
  String get suiteNavRecipes => 'ربط المنيو والوصفات';

  @override
  String get suiteNavPurchases => 'المشتريات';

  @override
  String get suiteNavReceive => 'الاستلام';

  @override
  String get suiteNavStocktake => 'الجرد';

  @override
  String get suiteNavPos => 'الكاشير';

  @override
  String get suiteNavDevices => 'الأجهزة';

  @override
  String get suiteNavSettings => 'الإعدادات والاشتراك';

  @override
  String get suiteLinkOnline => 'متصل';

  @override
  String get suiteLinkOffice => 'عبر جهاز المدير (بدون نت)';

  @override
  String get suiteLinkOffline => 'بدون اتصال — يُحفظ على الجهاز';

  @override
  String get suiteLinkChecking => 'جارٍ الفحص…';

  @override
  String suitePending(int n) {
    return '$n بانتظار الإرسال';
  }

  @override
  String suiteRejected(int n) {
    return '$n رفضها الخادم';
  }

  @override
  String get suiteSyncNow => 'زامن الآن';

  @override
  String get suiteReadOnlyBanner =>
      'الاشتراك غير مدفوع: للقراءة والتصدير فقط حتى تشحن المحفظة وتجدد. بياناتك محفوظة.';

  @override
  String get suiteGraceBanner =>
      'لم يكفِ الرصيد للتجديد — أيام سماح ثم يصبح للقراءة فقط.';

  @override
  String get suiteRenew => 'جدّد الآن';

  @override
  String get suiteQueued =>
      'حُفظت على هذا الجهاز وتُرسل وحدها عند عودة الاتصال.';

  @override
  String get suiteAtAverageCost => 'بمتوسط التكلفة المرجّح';

  @override
  String get suiteOpenOrders => 'أوامر شراء مفتوحة';

  @override
  String get suiteWasteMonth => 'هالك هذا الشهر';

  @override
  String get suiteNeedsAttention => 'يحتاج انتباهك';

  @override
  String get suiteAllCovered => 'كل الأصناف فوق حد الطلب وتكفي اليوم.';

  @override
  String get suiteItem => 'الصنف';

  @override
  String get suiteOnHand => 'الرصيد';

  @override
  String get suiteDaysLeft => 'يكفي (يوم)';

  @override
  String get suiteNewItem => 'صنف جديد';

  @override
  String get suiteSearchOrScan => 'بحث بالاسم أو امسح الباركود…';

  @override
  String get suiteAll => 'الكل';

  @override
  String get suiteReorderLevel => 'حد إعادة الطلب';

  @override
  String get suiteAvgCost => 'متوسط التكلفة';

  @override
  String get suiteValue => 'القيمة';

  @override
  String get suitePickItem => 'اختر صنفًا لترى دفتر حركاته.';

  @override
  String get suiteBaseUnit => 'أساسية';

  @override
  String get suiteEdit => 'تعديل';

  @override
  String get suiteAddOpening => 'رصيد افتتاحي';

  @override
  String get suiteTransfer => 'تحويل لمخزن';

  @override
  String get suiteLedger => 'دفتر الحركات';

  @override
  String get suiteLedgerHint => 'لا تعديل ولا حذف لحركة — التصحيح بحركة عكسية.';

  @override
  String get suiteWhen => 'الوقت';

  @override
  String get suiteMove => 'الحركة';

  @override
  String get suiteQty => 'الكمية';

  @override
  String get suiteBalanceAfter => 'الرصيد بعدها';

  @override
  String get suiteUnitCost => 'تكلفة الوحدة الأساسية';

  @override
  String get suiteToWarehouse => 'إلى مخزن';

  @override
  String get suiteKindCount => 'عدد';

  @override
  String get suiteKindWeight => 'وزن';

  @override
  String get suiteKindVolume => 'حجم';

  @override
  String get suiteKindLength => 'طول';

  @override
  String get suiteNameAr => 'الاسم بالعربية';

  @override
  String get suiteNameEn => 'الاسم بالإنجليزية (اختياري)';

  @override
  String get suiteGroup => 'المجموعة (مشروبات، خامات مطبخ…)';

  @override
  String get suiteBaseUnitHint => 'الوحدة الأساسية (علبة، جرام، مل، قطعة)';

  @override
  String get suiteUnitKind => 'نوع الوحدة';

  @override
  String get suiteBarcode => 'الباركود';

  @override
  String get suitePurchaseUnits => 'وحدات الشراء (كرتونة، بالتة…)';

  @override
  String get suiteUnitName => 'اسم الوحدة';

  @override
  String suiteUnitFactor(String unit) {
    return '= كم $unit';
  }

  @override
  String get suiteAddUnit => 'أضف وحدة';

  @override
  String get suiteOpeningQty => 'رصيد افتتاحي (بالوحدة الأساسية)';

  @override
  String get suitePickMenuItem =>
      'اختر صنفًا من المنيو أو المتجر لتحدد ما يخصمه من المخزون.';

  @override
  String get suiteLinkRecipe => 'وصفة';

  @override
  String get suiteLinkDirect => 'مباشر';

  @override
  String get suiteLinkNone => 'غير مربوط';

  @override
  String get suiteAddsTo => 'يضيف إلى الوصفة';

  @override
  String suiteRecipeCost(String cost, String percent) {
    return 'التكلفة $cost ج · $percent% من السعر';
  }

  @override
  String get suiteIngredient => 'المكوّن';

  @override
  String get suiteWastePct => 'فاقد %';

  @override
  String get suiteAddIngredient => 'أضف مكوّنًا';

  @override
  String get suiteNewSupplier => 'مورد جديد';

  @override
  String get suiteNewOrder => 'أمر شراء جديد';

  @override
  String get suiteOrders => 'أوامر الشراء';

  @override
  String get suiteSuppliers => 'الموردون';

  @override
  String get suiteSupplierName => 'اسم المورد';

  @override
  String get suitePhone => 'التليفون';

  @override
  String get suiteLinkedBusinessId => 'رقم النشاط على BIM (اختياري)';

  @override
  String get suiteLinkedBusinessHint =>
      'لو المورد نشاط على BIM يصله أمر الشراء في تطبيقه.';

  @override
  String get suitePickOrder => 'اختر أمر شراء.';

  @override
  String get suiteSupplier => 'المورد';

  @override
  String get suiteSupplierConfirmed => 'أكّد المورد الأمر في تطبيقه.';

  @override
  String get suiteLines => 'الأصناف';

  @override
  String get suiteUnit => 'الوحدة';

  @override
  String get suiteOrdered => 'المطلوب';

  @override
  String get suitePrice => 'السعر';

  @override
  String get suiteReceived => 'المستلم';

  @override
  String get suiteBilled => 'المفوتر';

  @override
  String get suiteMatchProblem =>
      'المطابقة الثلاثية: فاتورة المورد لا تطابق المطلوب والمستلم';

  @override
  String get suitePriceDiffers => 'السعر مختلف';

  @override
  String get suiteBilledMore => 'مفوتر أكثر من المستلم';

  @override
  String get suiteSubmit => 'إرسال';

  @override
  String get suiteSaveDraft => 'حفظ كمسودة';

  @override
  String get suiteReceiveNow => 'استلام';

  @override
  String get suiteRecordBill => 'فاتورة المورد';

  @override
  String get suiteRecordPayment => 'سجّل دفعة';

  @override
  String get suiteClose => 'إغلاق';

  @override
  String get suiteBillNumber => 'رقم الفاتورة';

  @override
  String get suitePaymentOutsideHint =>
      'الفلوس تتحرك خارج التطبيق؛ هنا نسجّلها فقط لتعرف حسابك مع المورد.';

  @override
  String get suiteAmount => 'المبلغ';

  @override
  String get suiteCash => 'نقدًا';

  @override
  String get suiteTransferMoney => 'تحويل';

  @override
  String get suiteCheque => 'شيك';

  @override
  String get suiteNote => 'ملاحظة';

  @override
  String get suiteBalance => 'المستحق له';

  @override
  String get suiteUnitPrice => 'سعر الوحدة';

  @override
  String get suiteAddLine => 'أضف سطرًا';

  @override
  String get suiteAgainstOrder => 'على أمر شراء';

  @override
  String get suiteNoOrder => 'بدون أمر شراء';

  @override
  String get suiteScanToReceive =>
      'امسح باركود الصنف أو الكرتونة — كل مسحة تزيد المستلم واحدًا';

  @override
  String suiteUnknownBarcode(String code) {
    return 'باركود غير معروف: $code';
  }

  @override
  String get suiteReceiveEmpty => 'اختر أمر شراء أو امسح باركود صنف.';

  @override
  String get suiteRemaining => 'الباقي';

  @override
  String get suiteReceivedNow => 'المستلم الآن';

  @override
  String get suiteDamaged => 'تالف';

  @override
  String get suiteLot => 'التشغيلة';

  @override
  String get suiteExpiry => 'الصلاحية';

  @override
  String get suiteReceiveNoEdit =>
      'بعد التأكيد لا يُعدَّل الاستلام — الخطأ يُصحَّح بمرتجع أو جرد.';

  @override
  String get suiteConfirmReceipt => 'تأكيد الاستلام';

  @override
  String get suiteStartCount => 'جرد جديد';

  @override
  String get suiteCountTitle => 'عنوان الجرد';

  @override
  String get suiteCountGroup => 'مجموعة فقط (اختياري)';

  @override
  String get suiteBlindCount => 'جرد أعمى (العادّ لا يرى الرقم المحسوب)';

  @override
  String get suiteCounting => 'جارٍ العدّ';

  @override
  String get suiteReview => 'مراجعة الفروق';

  @override
  String get suiteApplied => 'معتمد';

  @override
  String get suiteBack => 'رجوع';

  @override
  String get suiteFinishCount => 'إنهاء العدّ';

  @override
  String get suiteApplyCount => 'اعتماد الجرد وتسجيل الفروق';

  @override
  String get suiteBlindHint =>
      'جرد أعمى: الأرقام المحسوبة تظهر بعد إنهاء العدّ.';

  @override
  String get suiteScanToCount => 'امسح الباركود لزيادة المعدود';

  @override
  String suiteNetDifference(String amount) {
    return 'صافي الفرق: $amount ج';
  }

  @override
  String get suiteExpected => 'المحسوب';

  @override
  String get suiteCounted => 'المعدود';

  @override
  String get suiteDifference => 'الفرق';

  @override
  String get suiteOpenShift => 'فتح وردية';

  @override
  String get suiteCloseShift => 'تقفيل الوردية';

  @override
  String get suiteOpeningCash => 'نقدية البداية في الدرج';

  @override
  String get suiteCountedCash => 'النقدية المعدودة في الدرج';

  @override
  String get suiteShiftClosed => 'تم تقفيل الوردية';

  @override
  String suiteShiftSummary(String counted, String difference, String expected) {
    return 'المتوقع $expected ج، المعدود $counted ج، الفرق $difference ج.';
  }

  @override
  String get suitePaidLess => 'المدفوع أقل من الإجمالي.';

  @override
  String suiteChange(String amount) {
    return 'الباقي للعميل: $amount ج';
  }

  @override
  String get suiteScanToSell => 'امسح الباركود…';

  @override
  String get suiteSearch => 'بحث';

  @override
  String suiteAvailable(int n) {
    return 'متاح ~$n';
  }

  @override
  String get suiteInvoice => 'الفاتورة';

  @override
  String get suitePaidCash => 'المدفوع نقدًا';

  @override
  String get suitePay => 'دفع';

  @override
  String get suiteCashOutsideHint =>
      'الفلوس نقدًا في الدرج — لا شيء من المحفظة.';

  @override
  String get suiteLastSales => 'آخر الفواتير';

  @override
  String get suiteReturned => 'مرتجع';

  @override
  String get suiteReturn => 'مرتجع';

  @override
  String get suiteSize => 'المقاس';

  @override
  String get suiteRegular => 'عادي';

  @override
  String get suiteExtras => 'الإضافات';

  @override
  String get suiteAddToInvoice => 'أضف للفاتورة';

  @override
  String get suiteRoleMain => 'جهاز المدير (الرئيسي)';

  @override
  String get suiteRoleManager => 'مدير';

  @override
  String get suiteRoleWarehouse => 'جهاز المخزن';

  @override
  String get suiteRolePurchases => 'جهاز المشتريات';

  @override
  String get suiteRoleCashier => 'جهاز الكاشير';

  @override
  String get suiteDeviceName => 'اسم الجهاز';

  @override
  String get suitePairTitle => 'ربط بجهاز المدير';

  @override
  String get suitePairCode => 'الكود الظاهر على جهاز المدير';

  @override
  String get suiteRole => 'دور الجهاز';

  @override
  String get suitePair => 'ربط';

  @override
  String get suitePaired => 'تم الربط بجهاز المدير.';

  @override
  String get suitePairFailed =>
      'لم يتم الربط: تأكد من الكود وأن الجهازين على نفس الشبكة.';

  @override
  String get suiteThisComputer => 'هذا الجهاز';

  @override
  String get suiteIsMain =>
      'هذا هو الجهاز الرئيسي: يجمع أجهزة النشاط على الشبكة الداخلية ويزامنها مع السيرفر.';

  @override
  String get suiteNewPairingCode => 'كود ربط جديد';

  @override
  String get suitePairingHint =>
      'الكود صالح 5 دقائق ولمرة واحدة. أدخله على الجهاز الجديد وهو على نفس الشبكة.';

  @override
  String suitePairedWith(String address, String name) {
    return 'مربوط بجهاز المدير «$name» ($address).';
  }

  @override
  String get suiteUnpair => 'فك الربط';

  @override
  String get suiteMakeMain => 'اجعله الجهاز الرئيسي';

  @override
  String get suiteFindMain => 'ابحث عن جهاز المدير على الشبكة';

  @override
  String get suiteNoMainFound => 'لم يُعثر على جهاز رئيسي على هذه الشبكة.';

  @override
  String get suitePairedComputers => 'الأجهزة المربوطة بهذا الجهاز';

  @override
  String get suiteRegister => 'تسجيل';

  @override
  String get suiteForget => 'إزالة';

  @override
  String get suiteRegisteredDevices => 'الأجهزة المسجلة للنشاط';

  @override
  String get suiteNoDevices => 'لا أجهزة مسجلة بعد.';

  @override
  String get suiteRevoke => 'إلغاء التسجيل';

  @override
  String get suiteSubscription => 'الاشتراك الشهري';

  @override
  String suiteSubscriptionStatus(String status) {
    return 'الحالة: $status';
  }

  @override
  String suitePaidUntil(String date) {
    return 'مدفوع حتى $date';
  }

  @override
  String get suiteSubscriptionRules =>
      'تنبيه قبل التجديد بـ3 أيام، ثم 7 أيام سماح، ثم قراءة وتصدير فقط حتى الشحن. لا تُحذف أي بيانات أبدًا، وخصم المبيعات من المخزون مستمر.';

  @override
  String get suiteSubActive => 'ساري';

  @override
  String get suiteSubGrace => 'أيام سماح';

  @override
  String get suiteSubReadOnly => 'قراءة فقط';

  @override
  String get suiteSubNone => 'غير مشترك';

  @override
  String get suiteParts => 'أجزاء المخزون المستخدمة';

  @override
  String get suitePartsHint =>
      'يحددها تصنيف نشاطك من لوحة التحكم؛ الاختيارية تفعّلها أنت.';

  @override
  String get suiteOptional => 'اختياري';

  @override
  String get suiteApprovalLimit => 'حد اعتماد أوامر الشراء';

  @override
  String get suiteApprovalLimitField =>
      'فوق هذا المبلغ يحتاج الأمر اعتمادك (فارغ = بلا حد)';

  @override
  String get suiteRejectedTitle => 'عمليات رفضها الخادم بعد عودة الاتصال';

  @override
  String get suiteClear => 'مسح القائمة';

  @override
  String get suiteReceiptTitle => 'إيصال بيع';

  @override
  String get suiteReceiptFooter => 'شكرًا لزيارتكم — الدفع نقدًا';

  @override
  String get suiteReceiptNumber => 'رقم الفاتورة';

  @override
  String get suiteChangeLabel => 'الباقي';

  @override
  String get suitePrint => 'طباعة';

  @override
  String get suitePrintFailed => 'تعذرت الطباعة. تأكد من الطابعة في الإعدادات.';

  @override
  String get suiteStatus => 'الحالة';

  @override
  String get suiteSignPreparedBy => 'أعدّه';

  @override
  String get suiteSignApprovedBy => 'اعتمده';

  @override
  String get suiteSignSupplier => 'المورد';

  @override
  String get suiteSignReceivedBy => 'المستلم';

  @override
  String suiteReceivingNote(String no) {
    return 'إذن استلام #$no';
  }

  @override
  String get suitePrintReceivingNote => 'طباعة إذن الاستلام';

  @override
  String get suitePrinting => 'الطباعة على هذا الجهاز';

  @override
  String get suitePrintDialog => 'نافذة الطباعة (أختار كل مرة)';

  @override
  String get suiteReceiptPrinter => 'طابعة الإيصالات (رول 80 مم)';

  @override
  String get suiteDocumentPrinter => 'طابعة المستندات (A4)';

  @override
  String get suiteAutoReceipt => 'اطبع الإيصال تلقائيًا بعد كل بيع';

  @override
  String get suiteTestPrint => 'طباعة تجريبية';

  @override
  String get hrAttendanceTitle => 'الحضور';

  @override
  String get hrNavPayroll => 'المرتبات';

  @override
  String get hrBoard => 'لوحة الشهر';

  @override
  String get hrRequests => 'الطلبات';

  @override
  String get hrEmployeesShifts => 'الموظفون والورديات';

  @override
  String get hrRules => 'اللائحة والإجازات الرسمية';

  @override
  String get hrPresent => 'حاضر';

  @override
  String get hrLate => 'متأخر';

  @override
  String get hrAbsent => 'غائب';

  @override
  String get hrOnLeave => 'إجازة';

  @override
  String get hrUnpaidLeave => 'إجازة بدون أجر';

  @override
  String get hrRest => 'راحة';

  @override
  String get hrHoliday => 'إجازة رسمية';

  @override
  String get hrEarly => 'انصراف مبكر';

  @override
  String get hrEmployee => 'الموظف';

  @override
  String get hrEmployees => 'الموظفون';

  @override
  String get hrNoEmployees => 'لا موظفين بعد. أضفهم من «الموظفون» في التطبيق.';

  @override
  String get hrMinutesShort => 'د';

  @override
  String get hrHoursShort => 'س';

  @override
  String get hrNightShort => 'ليلي';

  @override
  String get hrOvertimeSuggested => 'إضافي محسوب';

  @override
  String get hrIn => 'الحضور';

  @override
  String get hrOut => 'الانصراف';

  @override
  String hrDeductionDays(String days) {
    return 'خصم $days يوم';
  }

  @override
  String get hrApproveOvertime => 'اعتماد الإضافي';

  @override
  String get hrNoPending => 'لا طلبات بانتظارك.';

  @override
  String get hrApprove => 'اعتماد';

  @override
  String get hrKindLeave => 'إجازة';

  @override
  String get hrKindCorrection => 'تصحيح بصمة';

  @override
  String get hrKindOvertime => 'إضافي';

  @override
  String get hrLeaveAnnual => 'اعتيادية';

  @override
  String get hrLeaveCasual => 'عارضة';

  @override
  String get hrLeaveSick => 'مرضية';

  @override
  String get hrLeaveUnpaid => 'بدون أجر';

  @override
  String get hrPending => 'بانتظار الاعتماد';

  @override
  String get hrApproved => 'معتمد';

  @override
  String get hrRejected => 'مرفوض';

  @override
  String get hrCancelled => 'ملغي';

  @override
  String get hrShifts => 'الورديات';

  @override
  String get hrNewShift => 'وردية جديدة';

  @override
  String get hrNoShifts => 'لا ورديات بعد.';

  @override
  String get hrNoShift => 'بلا وردية';

  @override
  String get hrShift => 'الوردية';

  @override
  String get hrShiftName => 'اسم الوردية';

  @override
  String get hrStartsAt => 'تبدأ';

  @override
  String get hrEndsAt => 'تنتهي';

  @override
  String hrLeaveBalance(String remaining, String total) {
    return 'رصيد الإجازة $remaining من $total';
  }

  @override
  String get hrHireDate => 'تاريخ التعيين';

  @override
  String get hrInsured => 'مؤمَّن عليه';

  @override
  String get hrAllowanceName => 'البدل';

  @override
  String get hrInsurable => 'تأميني';

  @override
  String get hrAddAllowance => 'أضف بدلًا';

  @override
  String get hrYourRules => 'لائحتك';

  @override
  String get hrGrace => 'دقائق السماح';

  @override
  String get hrTier1Upto => 'تأخير حتى (دقيقة)';

  @override
  String get hrTier1Fraction => 'خصمه (من اليوم)';

  @override
  String get hrTier2Fraction => 'أكثر من ذلك (من اليوم)';

  @override
  String get hrAbsenceFraction => 'خصم الغياب (أيام)';

  @override
  String get hrMonthlyCap => 'سقف الخصم الشهري (أيام)';

  @override
  String get hrOvertimeDayPct => 'الإضافي النهاري %';

  @override
  String get hrOvertimeNightPct => 'الإضافي الليلي %';

  @override
  String get hrNightFrom => 'الليل من';

  @override
  String get hrNightTo => 'إلى';

  @override
  String get hrDaysPerMonth => 'أيام الشهر للحساب';

  @override
  String get hrHoursPerDay => 'ساعات اليوم';

  @override
  String get hrRestDays => 'أيام الراحة الأسبوعية';

  @override
  String get hrSat => 'سبت';

  @override
  String get hrSun => 'أحد';

  @override
  String get hrMon => 'إثنين';

  @override
  String get hrTue => 'ثلاثاء';

  @override
  String get hrWed => 'أربعاء';

  @override
  String get hrThu => 'خميس';

  @override
  String get hrFri => 'جمعة';

  @override
  String hrHolidays(int n) {
    return 'الإجازات الرسمية $n';
  }

  @override
  String get hrHolidayName => 'اسم الإجازة';

  @override
  String get hrAddHoliday => 'أضف';

  @override
  String hrPayrollTitle(String month) {
    return 'مسير المرتبات $month';
  }

  @override
  String get hrNewAdvance => 'سلفة جديدة';

  @override
  String get hrBonusPenalty => 'مكافأة / جزاء';

  @override
  String get hrGenerate => 'احسب المسير';

  @override
  String get hrApproveLock => 'اعتماد وإقفال الشهر';

  @override
  String get hrPrintAll => 'طباعة الكشوف';

  @override
  String get hrNoRunYet => 'لم يُحسب مسير هذا الشهر بعد. اضغط «احسب المسير».';

  @override
  String get hrApprovedLocked => 'معتمد ومقفل';

  @override
  String get hrDraft => 'مسودة';

  @override
  String get hrReviewTax => 'دخل سنوي كبير: راجع الضريبة مع المحاسب';

  @override
  String get hrGross => 'إجمالي المرتبات';

  @override
  String get hrNetToPay => 'صافي يُصرف';

  @override
  String get hrInsuranceBoth => 'تأمينات (موظفون + صاحب العمل)';

  @override
  String get hrTaxToRemit => 'ضرائب تُورَّد';

  @override
  String get hrAllowances => 'البدلات';

  @override
  String get hrLineBasic => 'الأساسي';

  @override
  String get hrLineOvertime => 'الإضافي';

  @override
  String get hrLineBonus => 'مكافأة';

  @override
  String get hrLineAttendance => 'خصم الحضور';

  @override
  String get hrLineAdvance => 'قسط سلفة';

  @override
  String get hrLinePenalty => 'جزاء';

  @override
  String get hrLineInsurance => 'التأمينات';

  @override
  String get hrLineTax => 'الضريبة';

  @override
  String get hrNet => 'الصافي';

  @override
  String get hrPaid => 'صُرف';

  @override
  String get hrNotPaidYet => 'لم يُصرف بعد';

  @override
  String get hrRecordPaid => 'سجّل الصرف';

  @override
  String get hrPaidOutsideHint => 'المرتب يُصرف خارج التطبيق؛ هنا نسجّله فقط.';

  @override
  String get hrInstallments => 'عدد الأقساط';

  @override
  String hrAdvanceFrom(String month) {
    return 'تُخصم من مسير $month';
  }

  @override
  String hrHowCalculated(String name) {
    return 'كيف حُسب $name';
  }

  @override
  String hrEmployerInsurance(String amount) {
    return 'حصة صاحب العمل في التأمينات: $amount';
  }

  @override
  String hrPayslipTitle(String month) {
    return 'كشف مرتب $month';
  }

  @override
  String get hrItem => 'البند';

  @override
  String get hrDetail => 'التفصيل';

  @override
  String get hrDeductions => 'الاستقطاعات';

  @override
  String get hrSignAccountant => 'المحاسب';

  @override
  String get hrSignEmployee => 'توقيع الموظف بالاستلام';

  @override
  String get hrMyWork => 'حضوري ومرتبي';

  @override
  String get hrNewRequest => 'طلب جديد';

  @override
  String get hrRequestSent => 'أُرسل طلبك للمدير.';

  @override
  String get hrDaysPresent => 'يوم حضور';

  @override
  String get hrLateThisMonth => 'تأخير الشهر';

  @override
  String get hrLeaveLeft => 'رصيد إجازة';

  @override
  String get hrMyRequests => 'طلباتي';

  @override
  String get hrMyPayslips => 'كشوف مرتبي';

  @override
  String get hrNoPayslips => 'لا كشوف بعد.';

  @override
  String get hrLeaveType => 'نوع الإجازة';

  @override
  String get hrFrom => 'من';

  @override
  String get hrTo => 'إلى';

  @override
  String get hrOvertimeHours => 'ساعات الإضافي';

  @override
  String get hrStaffToday => 'الموظفون اليوم';

  @override
  String get hrStaffTodaySubtitle => 'الحضور، الطلبات، واعتماد المسير';

  @override
  String get hrAwaitingYou => 'بانتظار اعتمادك';

  @override
  String hrPayrollReady(String month) {
    return 'مسير $month جاهز للاعتماد';
  }

  @override
  String get hrConfirmReceived => 'تأكيد استلام الراتب';

  @override
  String hrConfirmReceivedAsk(String amount, String month) {
    return 'تؤكد أنك استلمت راتب $month وقدره $amount؟ يصل تأكيدك لصاحب العمل.';
  }

  @override
  String get hrReceivedConfirmed => 'أكّدت استلام الراتب';

  @override
  String get hrEmployeeConfirmed => 'أكّد الموظف';

  @override
  String get hrNotConfirmedYet => 'لم يؤكد بعد';

  @override
  String get suiteAppPrefs => 'اللغة والمظهر والبيانات';

  @override
  String get suiteTestRoleTitle => 'نوع هذا الجهاز — للتجربة فقط';

  @override
  String get suiteTestRoleHint =>
      'تبديل سريع بين أنواع الأجهزة أثناء فترة الاختبار، ويُحذف لاحقًا. الشاشات تتغير فورًا.';

  @override
  String importColumnTakenBy(String field) {
    return 'مربوط بـ «$field»';
  }

  @override
  String get crmTitle => 'العملاء';

  @override
  String get crmMyCustomers => 'عملائي';

  @override
  String get crmMyCustomersSubtitle => 'الآجل والدفعات وملفات العملاء';

  @override
  String get crmMyAccounts => 'حسابي عند المحلات';

  @override
  String get crmMyAccountsSubtitle => 'ما عليك عند كل محل ودفعاتك';

  @override
  String get crmNewCustomer => 'عميل جديد';

  @override
  String get crmName => 'الاسم';

  @override
  String get crmPhone => 'الموبايل';

  @override
  String get crmAddress => 'العنوان';

  @override
  String get crmTags => 'الوسوم (افصل بفاصلة)';

  @override
  String get crmNotes => 'ملاحظاتك (لا يراها العميل)';

  @override
  String get crmCreditLimit => 'حد الآجل';

  @override
  String get crmNoLimit => 'بلا حد';

  @override
  String get crmTermsDays => 'مدة السداد بالأيام';

  @override
  String get crmOpeningBalance => 'رصيد سابق عليه';

  @override
  String get crmSearch => 'بحث بالاسم أو الموبايل';

  @override
  String get crmFilterAll => 'الكل';

  @override
  String get crmFilterOwing => 'عليه آجل';

  @override
  String get crmFilterTop => 'الأفضل إنفاقًا';

  @override
  String get crmFilterFrequent => 'الأكثر زيارة';

  @override
  String get crmFilterNew => 'جديد هذا الشهر';

  @override
  String get crmFilterLapsed => 'انقطع';

  @override
  String get crmFilterOverdue => 'متأخر السداد';

  @override
  String get crmOwedTotal => 'إجمالي الآجل المستحق';

  @override
  String get crmPaymentsMonth => 'دفعات هذا الشهر';

  @override
  String get crmNewMonth => 'عملاء جدد هذا الشهر';

  @override
  String get crmPendingPayments => 'دفعات بانتظار تأكيدك';

  @override
  String crmOwes(String amount) {
    return 'عليه $amount';
  }

  @override
  String crmHasCredit(String amount) {
    return 'له $amount';
  }

  @override
  String get crmSettled => 'خالص';

  @override
  String get crmOnApp => 'على التطبيق';

  @override
  String crmVisits(int n) {
    return '$n زيارة';
  }

  @override
  String crmLastVisit(String date) {
    return 'آخر زيارة $date';
  }

  @override
  String get crmRecordPayment => 'تسجيل دفعة';

  @override
  String get crmPrintStatement => 'طباعة كشف حساب';

  @override
  String get crmRemind => 'ذكّره';

  @override
  String get crmEdit => 'تعديل البيانات';

  @override
  String get crmForget => 'حذف بيانات العميل';

  @override
  String get crmForgetConfirm =>
      'تُمحى بياناته وملاحظاتك، وتبقى الفواتير والقيود باسم «عميل محذوف». متابعة؟';

  @override
  String get crmLinkAccount => 'ربط بحسابه على التطبيق';

  @override
  String get crmLinkHint =>
      'اطلب من العميل فتح «حسابي عند المحلات» ثم «كود حسابي» واكتب الكود هنا.';

  @override
  String get crmCode => 'الكود';

  @override
  String get crmBalanceNow => 'عليه الآن';

  @override
  String get crmSpendYear => 'إنفاق هذه السنة';

  @override
  String get crmAvgTicket => 'متوسط الفاتورة';

  @override
  String get crmTabAccount => 'الحساب';

  @override
  String get crmTabPurchases => 'المشتريات';

  @override
  String get crmTabTop => 'أكثر ما يشتريه';

  @override
  String get crmTabData => 'البيانات';

  @override
  String get crmDate => 'التاريخ';

  @override
  String get crmLine => 'البيان';

  @override
  String get crmDebit => 'عليه';

  @override
  String get crmCreditCol => 'دفع';

  @override
  String get crmBalance => 'الرصيد';

  @override
  String get crmAging30 => 'حتى 30 يومًا';

  @override
  String get crmAging60 => '31–60 يومًا';

  @override
  String get crmAging90 => '61–90 يومًا';

  @override
  String get crmAgingOver => 'أكثر من 90';

  @override
  String get crmOverdue => 'متأخر عن مدة السداد';

  @override
  String get crmAmount => 'المبلغ';

  @override
  String get crmMethod => 'طريقة الدفع';

  @override
  String get crmMethodCash => 'نقدًا';

  @override
  String get crmMethodWallet => 'محفظة (خارج التطبيق)';

  @override
  String get crmMethodInstapay => 'إنستاباي';

  @override
  String get crmMethodBank => 'تحويل بنكي';

  @override
  String get crmReference => 'رقم العملية';

  @override
  String get crmReferenceHint =>
      'من تطبيق البنك أو المحفظة عندك — الطرف الآخر يكتبه أيضًا دون أن يرى ما كتبته';

  @override
  String get crmPaymentRecorded => 'سُجّلت الدفعة — بانتظار تأكيد الطرف الآخر';

  @override
  String get crmPaymentConfirmedNow => 'تأكدت الدفعة';

  @override
  String get crmStatusPending => 'بانتظار الطرف الآخر';

  @override
  String get crmStatusAwaitingMe => 'بانتظار تأكيدك';

  @override
  String get crmStatusConfirmed => 'مؤكدة من الطرفين';

  @override
  String get crmStatusBusinessOnly => 'مؤكدة من المحل فقط';

  @override
  String get crmStatusMismatch => 'غير مطابقة';

  @override
  String get crmStatusRejected => 'مرفوضة';

  @override
  String get crmStatusCancelled => 'ملغاة';

  @override
  String get crmConfirm => 'تأكيد';

  @override
  String get crmRejectBusiness => 'لم يصلني';

  @override
  String get crmRejectCustomer => 'لم أدفع هذا';

  @override
  String get crmCancelPayment => 'إلغاء الدفعة';

  @override
  String crmAttemptsLeft(int n) {
    return 'متبقي $n محاولات';
  }

  @override
  String crmReceiptNo(int n) {
    return 'إيصال $n';
  }

  @override
  String get crmKindOpening => 'رصيد سابق';

  @override
  String get crmKindSale => 'بيع على الحساب';

  @override
  String get crmKindOrder => 'طلب تطبيق';

  @override
  String get crmKindPayment => 'دفعة';

  @override
  String get crmKindReturn => 'مرتجع';

  @override
  String get crmKindAdjustment => 'تسوية';

  @override
  String get crmChargeOrder => 'على الحساب';

  @override
  String get crmAdjust => 'تسوية';

  @override
  String get crmAdjustReason => 'السبب';

  @override
  String get crmAdjustHint => 'موجب يزيد ما عليه، وسالب يقلّله';

  @override
  String crmStatementTitle(String name) {
    return 'كشف حساب — $name';
  }

  @override
  String get crmAmountDue => 'المستحق عليه';

  @override
  String get crmSignAccountant => 'المحاسب';

  @override
  String get crmSignCustomer => 'توقيع العميل بالاطلاع';

  @override
  String get crmReminderSent =>
      'وصله تذكير على التطبيق، وهذا النص لو أردت إرساله أيضًا:';

  @override
  String get crmReminderShare => 'انسخ النص وأرسله من موبايلك:';

  @override
  String get crmCopy => 'نسخ';

  @override
  String get crmCopied => 'نُسخ';

  @override
  String get crmPickCustomer => 'اختيار عميل';

  @override
  String get crmCashCustomer => 'عميل نقدي';

  @override
  String get crmOnAccount => 'على الحساب';

  @override
  String get crmAllOnAccount => 'كله على الحساب';

  @override
  String crmOverLimit(String amount) {
    return 'يتجاوز حد الآجل بـ $amount';
  }

  @override
  String get crmAskOverride => 'موافقة المدير على تجاوز الحد';

  @override
  String crmHeadroom(String amount) {
    return 'متاح على الحساب $amount';
  }

  @override
  String crmLimitOf(String limit) {
    return 'من حد $limit';
  }

  @override
  String get crmScanCode => 'كود حسابه على التطبيق';

  @override
  String get crmMyCode => 'كود حسابي';

  @override
  String get crmMyCodeHint =>
      'اعرضه على الكاشير ليربط ملفك عنده بحسابك. صالح 10 دقائق.';

  @override
  String get crmIPaid => 'دفعت';

  @override
  String crmIOwe(String amount) {
    return 'عليّ $amount';
  }

  @override
  String crmOwedToMe(String amount) {
    return 'لي $amount';
  }

  @override
  String get crmNoAccounts => 'لا يوجد محل يسجل عليك حسابًا.';

  @override
  String get crmNoCustomers => 'لا عملاء بعد.';

  @override
  String get crmPickToSee => 'اختر عميلًا لترى ملفه.';

  @override
  String get crmBusinessOnlyHint =>
      'العميل خارج التطبيق: الدفعة تُحسب بتأكيدك، واطبع له إيصالًا يوقّعه.';

  @override
  String crmPurchaseOrder(int number) {
    return 'طلب تطبيق #$number';
  }

  @override
  String crmPurchaseSale(int number) {
    return 'فاتورة كاشير #$number';
  }

  @override
  String get crmTopItemsEmpty => 'لا مشتريات من الكاشير بعد.';

  @override
  String get crmPaymentReceipt => 'إيصال استلام دفعة';

  @override
  String get crmPayments => 'الدفعات';

  @override
  String get crmLinked => 'رُبط الملف بحسابه على التطبيق';
}
