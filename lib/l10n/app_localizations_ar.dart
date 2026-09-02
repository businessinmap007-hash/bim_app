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
  String get commonDelete => 'حذف';

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

  @override
  String get ordersBookingsTitle => 'طلباتي وحجوزاتي';

  @override
  String get ordersTab => 'الطلبات';

  @override
  String get bookingsTab => 'الحجوزات';

  @override
  String get ordersEmpty => 'لا توجد طلبات بعد.';

  @override
  String get bookingsEmpty => 'لا توجد حجوزات بعد.';

  @override
  String get ordersCancel => 'إلغاء الطلب';

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
  String get orderStatusPending => 'قيد الانتظار';

  @override
  String get orderStatusCompleted => 'مكتمل';

  @override
  String get orderStatusCancelled => 'ملغي';

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
  String get walletTitle => 'المحفظة';

  @override
  String get walletAvailableBalance => 'الرصيد المتاح';

  @override
  String get walletLockedBalance => 'رصيد محجوز';

  @override
  String get walletTransactionsTitle => 'الحركات';

  @override
  String get walletTransactionsEmpty => 'لا توجد حركات بعد.';

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
  String get staffRemove => 'إزالة';

  @override
  String get staffRemoveConfirm => 'هل تريد إزالة هذا الموظف؟';

  @override
  String get staffPhoneRequired => 'أدخل رقم هاتف الموظف.';

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
  String get clinicNoOpenSlots => 'لا توجد فترات متاحة حاليًا.';

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
  String get trainingBodyReportsEmpty => 'لا توجد تقارير جسم بعد.';

  @override
  String get mealBreakfast => 'فطار';

  @override
  String get mealLunch => 'غداء';

  @override
  String get mealDinner => 'عشاء';

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
      'هذا يجعل عملياتك ظاهرة بتقييم ومراجعات، وستبدأ رسوم الخدمة في التطبيق على عملياتك الخاصة من الآن. لا يمكن التراجع عن هذا من داخل التطبيق.';

  @override
  String get myRatingEnableConfirm => 'فتحه';

  @override
  String get myRatingEnabledMessage =>
      'تم فتح تقييمك. ستُطبَّق رسوم الخدمة على عملياتك من الآن.';

  @override
  String get merchantAccountTitle => 'حساب Merchant';

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
  String get menuItemAdd => 'إضافة صنف';

  @override
  String get menuItemEditTitle => 'تعديل الصنف';

  @override
  String get menuItemAddTitle => 'إضافة صنف';

  @override
  String get menuItemDeleteConfirm => 'حذف هذا الصنف؟';

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
  String get menuItemBasePriceHint => 'السعر';

  @override
  String get menuItemSupplyPriceHint => 'سعر التكلفة (اختياري)';

  @override
  String get menuItemBrandNameHint => 'الماركة (اختياري)';

  @override
  String get menuItemSortOrderHint => 'ترتيب العرض';

  @override
  String get menuItemActiveLabel => 'نشط';

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
  String get retailListingsTitle => 'منتجاتي';

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
  String get retailListingSkuHint => 'رمز المنتج SKU (اختياري)';

  @override
  String get retailListingActiveLabel => 'نشط';

  @override
  String get retailListingDeleteConfirm => 'إزالة هذا المنتج من منتجاتك؟';

  @override
  String get retailPriceRequired => 'أدخل سعرًا صحيحًا.';
}
