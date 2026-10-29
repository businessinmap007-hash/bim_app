// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'BIM';

  @override
  String get appTagline => 'Every business, one place';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonRefresh => 'Refresh';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonOk => 'OK';

  @override
  String get commonSubmit => 'Submit';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonClear => 'Clear';

  @override
  String get commonNext => 'Next';

  @override
  String get commonBack => 'Back';

  @override
  String get commonSomethingWentWrong =>
      'Something went wrong, please try again.';

  @override
  String get commonNoInternet => 'No internet connection.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEmpty => 'No notifications yet.';

  @override
  String get notificationsMarkAllRead => 'Mark all read';

  @override
  String get notificationsClearAll => 'Clear all';

  @override
  String get notificationsClearAllConfirm =>
      'Clear all notifications? This can\'t be undone.';

  @override
  String notificationsFrom(String name) {
    return 'From $name';
  }

  @override
  String get authChooseAccountType => 'Choose account type';

  @override
  String get authAccountTypeCustomer => 'Customer';

  @override
  String get authAccountTypeBusiness => 'Business owner';

  @override
  String get authLogin => 'Log in';

  @override
  String get authRegister => 'Create account';

  @override
  String get authWelcomeBack => 'Welcome back';

  @override
  String get authEmailOrPhone => 'Email or phone';

  @override
  String get authPassword => 'Password';

  @override
  String get authConfirmPassword => 'Confirm password';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authForgotPasswordTitle => 'Reset password';

  @override
  String get authForgotPasswordInstructions =>
      'Enter your email and we\'ll send you a verification code to reset your password.';

  @override
  String get authSendCode => 'Send code';

  @override
  String get authResendCode => 'Resend code';

  @override
  String get authVerificationCode => 'Verification code';

  @override
  String get authCodeSentMessage =>
      'A verification code was sent to your email.';

  @override
  String get authNewPassword => 'New password';

  @override
  String get authResetPassword => 'Reset password';

  @override
  String get authBackToLogin => 'Back to login';

  @override
  String get authResetPasswordSuccess =>
      'Your password has been changed. You can now log in.';

  @override
  String get authDontHaveAccount => 'Don\'t have an account?';

  @override
  String get authAlreadyHaveAccount => 'Already have an account?';

  @override
  String get authLogout => 'Log out';

  @override
  String get authChangePassword => 'Change password';

  @override
  String get authCurrentPassword => 'Current password';

  @override
  String get authChangePasswordSuccess =>
      'Password changed. Your other devices were signed out.';

  @override
  String get authLogoutAll => 'Sign out of all devices';

  @override
  String get authLogoutAllBody =>
      'You will be signed out of this device and every other device where you are signed in. Continue?';

  @override
  String get authName => 'Name';

  @override
  String get authInvalidCredentials => 'Invalid login credentials.';

  @override
  String get validationRequired => 'This field is required.';

  @override
  String get validationInvalidEmail => 'Enter a valid email.';

  @override
  String get validationPasswordPolicy =>
      '8-20 characters, with an upper-case letter, a lower-case letter, and a digit.';

  @override
  String get validationPasswordMismatch => 'Passwords do not match.';

  @override
  String get homeCustomerTitle => 'Home';

  @override
  String get homeBusinessTitle => 'Business Dashboard';

  @override
  String get categoriesEmpty => 'No categories available right now.';

  @override
  String get specialtiesEmpty => 'No specialties available in this category.';

  @override
  String get categoriesRecommendedTitle => 'Recommended for you';

  @override
  String get categoriesTopRatedTitle => 'Top rated';

  @override
  String get categoriesRecommendedEmpty => 'No businesses yet.';

  @override
  String get categoriesServiceTypeAll => 'All';

  @override
  String get businessSearchHint => 'Search by business name...';

  @override
  String get businessListEmpty => 'No matching businesses.';

  @override
  String get childOfferingsTitle => 'Items & prices';

  @override
  String get childOfferingsAll => 'All';

  @override
  String get childOfferingsEmpty => 'No matching items.';

  @override
  String get businessFilterByLocation => 'Filter by location';

  @override
  String get businessFilterGovernorate => 'Governorate';

  @override
  String get businessFilterCity => 'City';

  @override
  String get businessFilterAnyCity => 'All cities';

  @override
  String get businessFilterClearLocation => 'Clear location filter';

  @override
  String get businessFilterChooseGovernorate => 'Choose a governorate';

  @override
  String get businessFilterByAttributes => 'Attributes';

  @override
  String businessFilterAttributesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attributes',
      one: '1 attribute',
    );
    return '$_temp0';
  }

  @override
  String get businessFilterAttributesEmpty =>
      'No attributes are available for this specialty yet.';

  @override
  String businessFilterAttributeBusinessCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count businesses',
      one: '1 business',
      zero: 'No businesses',
    );
    return '$_temp0';
  }

  @override
  String get businessFilterAttributesClear => 'Clear all';

  @override
  String get businessFilterAttributesApply => 'Apply';

  @override
  String get businessOpenNow => 'Open now';

  @override
  String get businessClosedNow => 'Closed now';

  @override
  String get businessCallForPrice => 'More details';

  @override
  String get businessFollow => 'Follow';

  @override
  String get businessUnfollow => 'Unfollow';

  @override
  String businessFollowersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count followers',
      one: '1 follower',
      zero: 'No followers',
    );
    return '$_temp0';
  }

  @override
  String businessCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count businesses',
      one: '1 business',
      zero: 'No businesses',
    );
    return '$_temp0';
  }

  @override
  String get settingsAppSettings => 'App settings';

  @override
  String get settingsAccountSubtitle =>
      'Information, business, services, staff, watermark, security';

  @override
  String get settingsAppSubtitle => 'Language, theme, layout, notifications';

  @override
  String get accountInfoTitle => 'Account information';

  @override
  String get accountInfoSubtitle =>
      'Name, e-mail, phone, address, location, social links';

  @override
  String get businessSettingsTitle => 'Business settings';

  @override
  String get businessSettingsSubtitle =>
      'Category, store terms, delivery & pickup, attributes';

  @override
  String get servicesSettingsSubtitle =>
      'Your services, delivery pricing and drivers';

  @override
  String get staffSettingsTitle => 'Staff settings';

  @override
  String get accountSecuritySection => 'Security & account';

  @override
  String get setupRequiredBadge => 'Required';

  @override
  String get setupIncompleteTitle => 'Finish setting up your account';

  @override
  String get setupIncompleteBody =>
      'Your products are not shown to customers until you choose how you deliver and hand over orders (Store terms → Delivery & pickup).';

  @override
  String get settingsMenuDisplay => 'How menus are shown';

  @override
  String get notificationSettingsTitle => 'Notifications';

  @override
  String get notificationSettingsSubtitle =>
      'Which are active and which are silent';

  @override
  String get notificationSettingsHint =>
      'Switch a kind of notification off to make it silent: it still arrives in your inbox, but nothing pops up and there is no sound.';

  @override
  String get notificationActive => 'Active';

  @override
  String get notificationSilent => 'Silent';

  @override
  String get notificationLockedNote =>
      'Money alerts and announcements from the platform are never silenced.';

  @override
  String get notificationOnThisPhone => 'On this phone';

  @override
  String setupChooseAtLeastOne(String group) {
    return 'Choose at least one option in «$group».';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageArabic => 'العربية';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsAppearanceLight => 'Light';

  @override
  String get settingsAppearanceDark => 'Dark';

  @override
  String get settingsAppearanceSystem => 'System default';

  @override
  String get settingsCategoriesLayoutSection => 'Categories layout';

  @override
  String get settingsLayoutIconRow => 'Compact icon row';

  @override
  String get settingsLayoutTabsAndRows => 'Tabs & preview rows';

  @override
  String get settingsLayoutBarAndMenu => 'Bar & dropdown menu';

  @override
  String get accountDataSection => 'Your details';

  @override
  String get settingsAccountSection => 'Account settings';

  @override
  String get settingsServicesSection => 'Service settings';

  @override
  String get settingsNoServicesForCategory =>
      'No platform services are available for your business\'s current category.';

  @override
  String get profileActivitySettingsSection => 'Activity settings';

  @override
  String get settingsComingSoon => 'Coming soon';

  @override
  String get categoryPickerFieldLabel => 'Category';

  @override
  String get categoryPickerChooseHint => 'Choose a category';

  @override
  String get categoryPickerChooseRoot => 'Choose a section';

  @override
  String get mediaCapturedByCamera => 'This photo was captured with the camera';

  @override
  String get mediaFromGallery => 'This photo was uploaded from the gallery';

  @override
  String get mediaAddFromCamera => 'Take photo';

  @override
  String get mediaAddFromGallery => 'Choose from gallery';

  @override
  String get mediaRemove => 'Remove';

  @override
  String get mediaCrop => 'Crop photo';

  @override
  String get mediaWatermarkTitle => 'Watermark';

  @override
  String get mediaWatermarkUseMobile => 'Phone number';

  @override
  String get mediaWatermarkUseBusinessName => 'Business name';

  @override
  String get mediaWatermarkSettingsHint =>
      'Choose what watermark text comes from your profile — it\'s added to every photo you add automatically, no retyping.';

  @override
  String get mediaWatermarkDisabledHint => 'Watermark is currently off.';

  @override
  String get productWatermarkTitle => 'Put my watermark on these photos';

  @override
  String productWatermarkOn(String text) {
    return 'Stamped with: $text — protects the photos from being copied';
  }

  @override
  String get productWatermarkOff => 'The photos are added as they are';

  @override
  String get mediaWatermarkOpenSettings => 'Turn it on in Settings';

  @override
  String get mediaWatermarkRepeatCount => 'Repeat count';

  @override
  String get mediaComposerTitle => 'Photo display & watermark';

  @override
  String get mediaEmpty =>
      'No photos yet — add one from the camera or gallery.';

  @override
  String get cropTitle => 'Crop photo';

  @override
  String get cropAspectOriginal => 'Original';

  @override
  String get cropAspectSquare => 'Square';

  @override
  String get cropAspectPortrait => 'Portrait';

  @override
  String get cropAspectLandscape => 'Landscape';

  @override
  String get cropConfirm => 'Done';

  @override
  String get businessRatingNoReviews => 'No reviews yet';

  @override
  String get businessTabPosts => 'Posts';

  @override
  String get businessTabMenu => 'Menu';

  @override
  String get businessTabBooking => 'Booking';

  @override
  String get businessTabAbout => 'About';

  @override
  String get businessTabServices => 'Services';

  @override
  String get businessPostsEmpty => 'No posts yet';

  @override
  String get businessMenuEmpty => 'No menu items yet';

  @override
  String get businessServicesEmpty => 'No services yet';

  @override
  String get businessActionBook => 'Book';

  @override
  String get businessActionOrder => 'Order';

  @override
  String get businessOutOfStock => 'Currently unavailable';

  @override
  String businessMenuAvailableQuantity(int quantity) {
    return 'Available $quantity';
  }

  @override
  String get menuCardBestseller => 'Bestseller';

  @override
  String menuCardPriceFrom(String price) {
    return 'From $price';
  }

  @override
  String menuCardPricePerUnit(String price, String unit) {
    return '$price EGP / $unit';
  }

  @override
  String get menuCardViewOptions => 'View options';

  @override
  String get menuCardAddShort => 'Add';

  @override
  String get menuCardSpecsTitle => 'Specifications';

  @override
  String get businessNoContentYet => 'Nothing to show yet';

  @override
  String get businessInfoTitle => 'Business info';

  @override
  String get businessInfoPhone => 'Phone number';

  @override
  String get businessInfoAddress => 'Address';

  @override
  String get businessInfoCountry => 'Country';

  @override
  String get businessInfoLocation => 'Location';

  @override
  String get businessInfoOpenInMaps => 'Open in maps';

  @override
  String get businessInfoCheckIn => 'Check-in time';

  @override
  String get businessInfoCheckOut => 'Check-out time';

  @override
  String get businessInfoHours => 'Working hours';

  @override
  String get businessInfoAlbums => 'Photo album';

  @override
  String get businessInfoNoAlbums => 'No photos yet.';

  @override
  String get profileTitle => 'My Profile';

  @override
  String get profileName => 'Name';

  @override
  String get profilePhone => 'Mobile number';

  @override
  String get profileLocation => 'Location';

  @override
  String get profileLocationNotSet => 'Location not set yet';

  @override
  String get profileLocationSet => 'Location set';

  @override
  String get profileUseCurrentLocation => 'Use my current location';

  @override
  String get profileLocationPermissionDenied =>
      'Location access is needed — allow it from your device settings.';

  @override
  String get profileLocationNoMatch =>
      'We couldn\'t determine your governorate and city from your location — please choose them manually.';

  @override
  String get profilePhotoCamera => 'Take a photo';

  @override
  String get profilePhotoGallery => 'Choose from gallery';

  @override
  String get profilePhotoView => 'View photo';

  @override
  String get coverCropTitle => 'Frame the cover';

  @override
  String get coverCropHint =>
      'Drag and zoom so the part you want is inside the frame — this is exactly how the cover will look. The red cross marks the centre.';

  @override
  String get coverCropCentre => 'Centre the photo';

  @override
  String get profileCoverAdjust => 'Adjust the current cover';

  @override
  String get profilePhotoRemove => 'Remove photo';

  @override
  String get profileSaved => 'Changes saved.';

  @override
  String get profilePrivacyNote =>
      'Your phone and location are never shown publicly — a business only sees them once you actually use one of its services, like a booking or an order.';

  @override
  String get profileSave => 'Save';

  @override
  String get navCategories => 'Categories';

  @override
  String get navSearch => 'Search';

  @override
  String get navProfile => 'My account';

  @override
  String get searchEmptyHint => 'Type a business name to search for';

  @override
  String get profileEmail => 'Email';

  @override
  String get profileNameEnglish => 'English name';

  @override
  String get profileAbout => 'About your business';

  @override
  String get profileSocialLinks => 'Social media links';

  @override
  String get profileAccountType => 'Account type';

  @override
  String get profileAccountTypeClient => 'Customer';

  @override
  String get profileAccountTypeBusiness => 'Business';

  @override
  String get profileSpecialty => 'Specialty';

  @override
  String get profileSpecialtyNotSet => 'No specialty chosen yet';

  @override
  String get profileCategory => 'Category';

  @override
  String get profileCategoryNotSet => 'No category chosen yet';

  @override
  String get profileConvertToBusiness => 'Convert account to business';

  @override
  String get profileConvertToBusinessHint =>
      'Choose your business specialty to complete the conversion — this can\'t be undone from here.';

  @override
  String get profileConvertConfirm => 'Confirm conversion';

  @override
  String get profileConvertSuccess => 'Your account is now a business account.';

  @override
  String get profileOptionsTitle => 'Business attributes';

  @override
  String get profileOptionsEmpty =>
      'No attributes available for your current specialty.';

  @override
  String get profileOptionsSave => 'Save attributes';

  @override
  String get profileAdministrativeLocation => 'Administrative area';

  @override
  String get locationFieldLabel => 'Governorate / City';

  @override
  String get locationGovernorateLabel => 'Governorate';

  @override
  String get locationCityLabel => 'City / village / district';

  @override
  String get locationChooseCityHint => 'Choose the city';

  @override
  String get locationChooseHint => 'Choose a governorate and city';

  @override
  String get locationChooseGovernorate => 'Choose a governorate';

  @override
  String get locationEmpty => 'No results';

  @override
  String get locationSearchCity => 'Search for a city';

  @override
  String get profileAlbumsTitle => 'Photo albums';

  @override
  String get profileAlbumsEmpty => 'No albums yet.';

  @override
  String get profileAlbumsAdd => 'New album';

  @override
  String get profileAlbumsNewTitle => 'Album name';

  @override
  String get profileAlbumsCreate => 'Create';

  @override
  String get profileAlbumsAddPhoto => 'Add photo';

  @override
  String get profileAlbumsDelete => 'Delete album';

  @override
  String get profileAlbumsDeleteConfirm =>
      'Delete this album and all its photos?';

  @override
  String get depositAsPaymentRequest =>
      'Ask the business to take my deposit as a payment';

  @override
  String get depositAsPaymentRequested =>
      'Your request was sent. The deposit stays frozen until the business answers.';

  @override
  String get depositAsPaymentAsked =>
      'The customer asks that the frozen deposit be taken as a payment instead of a transfer outside the app.';

  @override
  String get depositAsPaymentAccept => 'Take the deposit as a payment';

  @override
  String get depositAsPaymentDecline => 'Decline';

  @override
  String get depositAsPaymentTaken => 'The deposit was taken as a payment.';

  @override
  String get depositAsPaymentDeclined =>
      'The business declined. Pay the value directly as usual.';

  @override
  String get bookingTermsDepositAsPayment =>
      'Accept the frozen deposit as a payment when the customer asks';

  @override
  String get bookingTermsDepositAsPaymentHint =>
      'Optional. Instead of a transfer outside the app, the customer may ask that the frozen deposit be taken as a payment. You may accept or decline each time.';

  @override
  String get depositNotPartOfPrice =>
      'A deposit is a seriousness measure, not part of the price: it comes back once the customer has paid the whole value directly. Platform fees are charged separately from each wallet.';

  @override
  String get roomsTitle => 'Rooms';

  @override
  String roomsOpenCount(String n) {
    return '$n open';
  }

  @override
  String get roomsHint =>
      'The hotel\'s own list. Customers book a room type and never see these numbers until their stay starts. Type numbers or a range like 101-110.';

  @override
  String get roomsNumbersField => 'Room numbers';

  @override
  String get roomsAdd => 'Add';

  @override
  String get roomMaintenance => 'Close for maintenance';

  @override
  String get roomsReopen => 'Reopen';

  @override
  String get bookingRoom => 'Room';

  @override
  String get bookingRoomOnStart => 'Given when the stay starts';

  @override
  String get bookingRoomAssign => 'Choose';

  @override
  String get bookingRoomChange => 'Change';

  @override
  String get bookingRoomNoFree => 'No free room of this type for these nights.';

  @override
  String get bookingRoomNone => 'This room type has no listed rooms.';

  @override
  String bookingRoomYours(String number) {
    return 'Your room: $number';
  }

  @override
  String get bookingTermsTitle => 'Booking terms';

  @override
  String get bookingTermsIntro =>
      'Choose how your bookings are secured. Every booking waits for your approval before it is confirmed.';

  @override
  String get bookingTermsEnabled => 'Ask for security on a booking';

  @override
  String get bookingTermsEnabledHint =>
      'Without it a booking is made with no deposit.';

  @override
  String get bookingTermsModeTitle => 'How it is secured';

  @override
  String get bookingTermsModeDeposit => 'Freeze a deposit';

  @override
  String get bookingTermsModeDepositHint =>
      'An amount is frozen in the customer\'s wallet and one against it in yours; both are released with the two parties\' agreement.';

  @override
  String get bookingTermsModeGuarantee => 'Freeze the customer\'s guarantee';

  @override
  String get bookingTermsModeGuaranteeHint =>
      'The customer\'s guarantee stands for it instead of cash; if it cannot cover, a deposit is asked.';

  @override
  String get bookingTermsModeExternal => 'Transfer outside the app';

  @override
  String get bookingTermsModeExternalHint =>
      'The customer transfers the amount to you directly; you and the customer both confirm it. The platform carries no responsibility for the transfer.';

  @override
  String get bookingTermsRecommended => 'Preferred';

  @override
  String get bookingTermsPercentTitle => 'Deposit amount';

  @override
  String bookingTermsPercentValue(String percent) {
    return '$percent% of the booking';
  }

  @override
  String get bookingTermsBaseTitle => 'Counted on';

  @override
  String get bookingTermsBaseFirstDay => 'The first day\'s value';

  @override
  String get bookingTermsBaseTotal => 'The whole booking';

  @override
  String get bookingTermsCounterTitle => 'What you freeze against it';

  @override
  String bookingTermsCounterValue(String percent) {
    return '$percent% of the deposit';
  }

  @override
  String get bookingTermsCounterHint =>
      'A share of the customer\'s deposit is frozen from your wallet, so you are bound too.';

  @override
  String get bookingTermsGuaranteeTitle => 'Guarantee asked for';

  @override
  String get bookingTermsGuaranteeSame => 'As much as the deposit';

  @override
  String bookingTermsGuaranteeTimes(String n) {
    return '$n× the day\'s value';
  }

  @override
  String get bookingTermsGuaranteeHint =>
      'It can be several times the value of the day\'s booking.';

  @override
  String get bookingTermsExternalNote =>
      'The customer transfers the deposit directly, and you confirm it reached you before the stay starts.';

  @override
  String get bookingTermsForfeitTitle =>
      'If the customer breaks the booking, the whole deposit is mine';

  @override
  String get bookingTermsForfeitHint =>
      'A declared term the customer sees when booking, and the arbitrator reads in a dispute.';

  @override
  String bookingTermsExampleTitle(String value) {
    return 'Example: one day at $value';
  }

  @override
  String bookingTermsExampleDeposit(String amount) {
    return 'Deposit: $amount';
  }

  @override
  String bookingTermsExampleCustomer(String amount) {
    return 'Frozen from the customer: $amount';
  }

  @override
  String bookingTermsExampleBusiness(String amount) {
    return 'Frozen from you: $amount';
  }

  @override
  String bookingTermsExampleExternal(String amount) {
    return 'Transferred directly by the customer: $amount';
  }

  @override
  String bookingTermsExampleGuarantee(String amount) {
    return 'Customer guarantee asked for: $amount';
  }

  @override
  String get bookingTermsSpecificWarning =>
      'You have terms for specific services, and they take priority over these.';

  @override
  String get bookingTermsApprovalNote =>
      'Every booking waits for your approval before it is confirmed.';

  @override
  String get bookingTermsSaved => 'Booking terms saved';

  @override
  String get bookingSettingsTitle => 'Booking management';

  @override
  String get bookingSettingsPricesTab => 'Prices';

  @override
  String get bookingSettingsUnitsTab => 'Units';

  @override
  String get bookingSettingsHoursTab => 'Working hours';

  @override
  String get bookingSettingsAddPrice => 'Add price';

  @override
  String get bookingSettingsAddUnit => 'Add unit';

  @override
  String get bookingSettingsService => 'Service';

  @override
  String get bookingSettingsItemType => 'Item type';

  @override
  String get bookingSettingsLineOption => 'Type';

  @override
  String get bookingSettingsLineOptionHint => 'e.g. Double room';

  @override
  String get bookingSettingsPrice => 'Price';

  @override
  String get bookingSettingsCode => 'Code / Number';

  @override
  String get bookingSettingsCapacity => 'Capacity';

  @override
  String get bookingSettingsPricesEmpty =>
      'No prices yet — add one for each type you offer.';

  @override
  String get bookingSettingsUnitsEmpty => 'No units yet.';

  @override
  String get bookingSettingsDelete => 'Delete';

  @override
  String get bookingSettingsDeleteConfirm => 'Delete this?';

  @override
  String get bookingSettingsApplyAllLabel => 'All days';

  @override
  String get bookingSettingsApplyToWeek => 'Apply to week';

  @override
  String get bookingSettingsApplyHint =>
      'Fills the list only — adjust any day, then save.';

  @override
  String get bookingSettingsClosed => 'Closed';

  @override
  String get bookingSettingsOpenTime => 'Opening time';

  @override
  String get bookingSettingsCloseTime => 'Closing time';

  @override
  String get bookingSettingsSaveHours => 'Save hours';

  @override
  String get bookingSettingsHoursSaved => 'Hours saved.';

  @override
  String get bookingSettingsOpenNow => 'Open now';

  @override
  String get bookingSettingsClosedNow => 'Closed now';

  @override
  String get bookingSettingsDescription => 'Description';

  @override
  String get bookingSettingsStatus => 'Status';

  @override
  String get bookingSettingsStatusAvailable => 'Available';

  @override
  String get bookingSettingsStatusMaintenance => 'Closed for maintenance';

  @override
  String get bookingSettingsStatusBooked => 'Booked now';

  @override
  String get bookingSettingsGridView => 'Grid view';

  @override
  String get bookingSettingsListView => 'List view';

  @override
  String get bookingSettingsEditUnit => 'Edit unit';

  @override
  String get bookingSettingsCheckInTime => 'Check-in time';

  @override
  String get bookingSettingsCheckOutTime => 'Check-out time';

  @override
  String get bookingSettingsSaveCheckTimes => 'Save check-in/out times';

  @override
  String get bookingSettingsCheckTimesSaved => 'Check-in/out times saved.';

  @override
  String get weekdaySunday => 'Sunday';

  @override
  String get weekdayMonday => 'Monday';

  @override
  String get weekdayTuesday => 'Tuesday';

  @override
  String get weekdayWednesday => 'Wednesday';

  @override
  String get weekdayThursday => 'Thursday';

  @override
  String get weekdayFriday => 'Friday';

  @override
  String get weekdaySaturday => 'Saturday';

  @override
  String get postsMyPostsTitle => 'My Posts';

  @override
  String get postsTabFollowing => 'Following';

  @override
  String get postsTabMine => 'My Posts';

  @override
  String get postsTabJobs => 'My Jobs';

  @override
  String get myFollowsTitle => 'Following';

  @override
  String get myFollowsEmpty => 'You\'re not following any accounts yet.';

  @override
  String get postsFeedEmpty =>
      'No posts yet — follow a business to see its posts here.';

  @override
  String get postsMineEmpty => 'You haven\'t posted anything yet.';

  @override
  String get postsJobsEmpty => 'You haven\'t posted any jobs yet.';

  @override
  String get postsCreateTitle => 'New post';

  @override
  String get postsPublish => 'Publish';

  @override
  String get postsTitleLabel => 'Title';

  @override
  String get postsBodyLabel => 'Text';

  @override
  String postsMaxImagesReached(int max) {
    return 'Up to $max photos per post.';
  }

  @override
  String get postsDeleteConfirmTitle => 'Delete this post?';

  @override
  String get postsDelete => 'Delete';

  @override
  String get postsReadMore => 'More';

  @override
  String get postsShare => 'Share';

  @override
  String get postsEdit => 'Edit';

  @override
  String get postsEditTitle => 'Edit post';

  @override
  String get postsReplacePhotos => 'Replace photos';

  @override
  String get postsKeepCurrentPhotos => 'Keep current photos';

  @override
  String get postsSaveChanges => 'Save';

  @override
  String get postsJobsClosed => 'Closed';

  @override
  String postsJobsApplicantsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count applicants',
      one: '1 applicant',
      zero: 'No applicants',
    );
    return '$_temp0';
  }

  @override
  String get jobsCreateTitle => 'New job';

  @override
  String get postsLinkItem => 'Link to one of your items (optional)';

  @override
  String get postsLinkItemSheetTitle => 'Pick an item to advertise';

  @override
  String get jobsTitleLabel => 'Job title';

  @override
  String get jobsStatsPosted => 'Jobs posted';

  @override
  String get jobsStatsOpen => 'Open now';

  @override
  String get jobsStatsApplicants => 'Applicants';

  @override
  String get jobsStatsApproved => 'Accepted';

  @override
  String jobsPlatformSummary(int open, int hiring) {
    return '$open open jobs from $hiring hiring businesses';
  }

  @override
  String get jobsPickTitleHint => 'Pick the job title';

  @override
  String get jobsTitleOther => 'Other title';

  @override
  String get jobsAllTitles => 'All titles';

  @override
  String get jobsBodyLabel => 'Job description';

  @override
  String get jobsRequirementsLabel => 'Requirements (optional)';

  @override
  String get jobsSalaryLabel => 'Salary (optional)';

  @override
  String get jobsPublishAction => 'Publish job';

  @override
  String get cartTitle => 'Cart';

  @override
  String get cartEmpty => 'Your cart is empty.';

  @override
  String get cartAdd => 'Add to cart';

  @override
  String get cartBuyNow => 'Buy now';

  @override
  String get cartAddedToCart => 'Added to cart.';

  @override
  String get cartQty => 'Quantity';

  @override
  String get cartRemove => 'Remove';

  @override
  String get cartVariantChoose => 'Choose a type';

  @override
  String cartPaymentInstalments(int count, String monthly, String date) {
    return 'Instalments: $count monthly payments of $monthly, the first on $date';
  }

  @override
  String cartPaymentInstalmentsDown(
    int count,
    String first,
    String monthly,
    String date,
  ) {
    return 'Instalments over $count months: first payment $first (down payment included), then $monthly a month, the first on $date';
  }

  @override
  String variantInstallmentNoteDown(int months, String down, String monthly) {
    return '$down down + $months months — $monthly a month';
  }

  @override
  String get techPricingInstallmentDown => 'Down payment (optional)';

  @override
  String get techPricingInstallmentDownInvalid =>
      'The down payment must be less than the price.';

  @override
  String ordersInstallmentsPaidSummary(String paid, String remaining) {
    return 'Paid $paid · Remaining $remaining';
  }

  @override
  String get ordersInstallmentCollect => 'Collect';

  @override
  String get ordersInstallmentUndo => 'Undo collection';

  @override
  String cartOrderPlacedPaidNow(String paid) {
    return 'Paid now: $paid';
  }

  @override
  String get businessReportsTabCash => 'Cash';

  @override
  String get businessReportsTabInstallments => 'Instalments';

  @override
  String get businessReportsInstOrders => 'Instalment orders';

  @override
  String get businessReportsInstContractTotal => 'Total on instalments';

  @override
  String get businessReportsInstCollected => 'Collected';

  @override
  String get businessReportsInstRemaining => 'Left to collect';

  @override
  String get businessReportsInstOverdue => 'Overdue';

  @override
  String get businessReportsInstByMonth => 'Due by month';

  @override
  String get businessReportsInstUpcoming => 'Upcoming payments';

  @override
  String get businessReportsInstNone => 'No payments due.';

  @override
  String businessReportsInstPayments(int count) {
    return '$count payments';
  }

  @override
  String businessReportsInstLine(int seq, int count, int order) {
    return 'Payment $seq of $count · order #$order';
  }

  @override
  String get ordersInstallmentsTitle => 'Payment schedule';

  @override
  String get ordersInstallmentPaid => 'Paid';

  @override
  String get techPricingInstallmentMonths => 'Months';

  @override
  String get techPricingInstallmentMonthsRequired =>
      'Enter the number of months (2 or more).';

  @override
  String variantInstallmentNote(int months, String monthly) {
    return '$months months — $monthly a month';
  }

  @override
  String techPricingPriceBy(String group) {
    return 'Price by $group';
  }

  @override
  String get cartPaymentChoose => 'Choose how to pay';

  @override
  String get techPricingPriceFor => 'Price';

  @override
  String get cartExtrasChoose => 'Extras';

  @override
  String get menuItemDetailTitle => 'Product Details';

  @override
  String cartItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String get cartSubtotal => 'Subtotal';

  @override
  String get cartServiceFee => 'Service fee';

  @override
  String get cartTax => 'Tax';

  @override
  String get cartDeliveryFee => 'Delivery fee';

  @override
  String get cartDiscount => 'Discount';

  @override
  String get cartFinalTotal => 'Total';

  @override
  String get cartCheckout => 'Checkout';

  @override
  String get cartCheckoutTitle => 'Checkout';

  @override
  String get cartStoreNotReady =>
      'This store hasn\'t set how it delivers or hands over orders yet, so you can\'t place an order with it for now.';

  @override
  String get cartFulfillmentType => 'Fulfillment';

  @override
  String get cartFulfillmentDelivery => 'Delivery';

  @override
  String get cartFulfillmentPickup => 'Pickup';

  @override
  String get cartFulfillmentShipping => 'Shipping';

  @override
  String get cartFulfillmentFactoryPickup => 'Factory-gate pickup';

  @override
  String get cartFulfillmentDineIn => 'Dine in';

  @override
  String get businessFulfillmentPrompt =>
      'How would you like to get your order?';

  @override
  String get cartOutOfStockPolicyPrompt =>
      'If something in your order runs out, what would you like us to do?';

  @override
  String get cartOutOfStockSubstitute => 'Substitute (closest match)';

  @override
  String get cartOutOfStockRemove => 'Just remove that item';

  @override
  String get cartOutOfStockCancel => 'Cancel the whole order';

  @override
  String orderLineSubstituted(String note) {
    return 'Substituted: $note';
  }

  @override
  String get orderLineRemoved => 'Unavailable — removed';

  @override
  String get cartAddressLabel => 'Address';

  @override
  String get cartAddressHint => 'Enter the delivery address';

  @override
  String get cartPickupTimeLabel => 'Pickup time';

  @override
  String get cartPickupTimeChoose => 'Choose a pickup time';

  @override
  String get cartPickupTimeRequired => 'Choose when you\'ll pick up the order.';

  @override
  String get cartNotesLabel => 'Notes (optional)';

  @override
  String get cartPaymentMethod => 'Payment method';

  @override
  String get cartPaymentCash => 'Cash on delivery';

  @override
  String get cartPaymentCashInStore => 'Cash at the store';

  @override
  String get cartPlaceOrder => 'Place order';

  @override
  String get cartOrderPlaced => 'Order placed successfully.';

  @override
  String get cartGoToCart => 'Go to cart';

  @override
  String get bookingScreenTitle => 'Booking';

  @override
  String get bookingSubmit => 'Book now';

  @override
  String get bookingChooseUnit => 'Choose a unit';

  @override
  String get bookingUnitEmpty => 'No units available right now.';

  @override
  String get bookingModifiersTitle => 'Extras';

  @override
  String get bookingTotalLabel => 'Total';

  @override
  String get bookingFrom => 'From';

  @override
  String get bookingTo => 'To';

  @override
  String get bookingChoosePlaceholder => 'Choose...';

  @override
  String get bookingChannelInPerson => 'In person';

  @override
  String get bookingChannelOnline => 'Online';

  @override
  String get bookingVisitAtBusiness => 'At the business';

  @override
  String get bookingVisitAtCustomer => 'At your place';

  @override
  String get bookingSuccess => 'Booking request sent successfully.';

  @override
  String get bookingDatetimeLabel => 'Booking time';

  @override
  String get bookingCapacityLabel => 'Capacity';

  @override
  String get maxChildrenLabel => 'Most children in the room';

  @override
  String get maxChildrenHelp =>
      'Besides the adults, from two years old (a baby sleeps in a cot). Empty = not set';

  @override
  String roomOccupancy(int adults, int children) {
    return '$adults adults + $children children';
  }

  @override
  String get bookingUnitRequired => 'Choose a unit first.';

  @override
  String get bookingDateRequired => 'Choose a date first.';

  @override
  String get bookingUnitUnavailable => 'Not available for these dates';

  @override
  String get ordersBookingsTitle => 'My orders & bookings';

  @override
  String get ordersTab => 'Orders';

  @override
  String get bookingsTab => 'Bookings';

  @override
  String get businessOrdersTitle => 'Incoming orders';

  @override
  String get businessReportsTitle => 'Reports';

  @override
  String get businessReportsRange7d => '7 days';

  @override
  String get businessReportsRange30d => '30 days';

  @override
  String get businessReportsRange90d => '90 days';

  @override
  String get businessReportsTotalOrders => 'Total orders';

  @override
  String get businessReportsTotalRevenue => 'Revenue';

  @override
  String get businessReportsCompleted => 'Completed';

  @override
  String get businessReportsCancelled => 'Cancelled';

  @override
  String get businessReportsPending => 'Pending';

  @override
  String get businessReportsAverageOrderValue => 'Avg. order value';

  @override
  String get businessReportsDailyOrdersChartTitle => 'Orders per day';

  @override
  String get businessReportsDailyRevenueChartTitle => 'Revenue per day';

  @override
  String get businessReportsByFulfillmentType => 'By fulfillment type';

  @override
  String get businessReportsEmpty => 'No orders in this range yet.';

  @override
  String get businessOrdersFilterAll => 'All';

  @override
  String get businessOrdersFilterPending => 'Pending';

  @override
  String get businessOrdersFilterCompleted => 'Completed';

  @override
  String get businessOrdersFilterCancelled => 'Cancelled';

  @override
  String get businessOrdersEmpty => 'No orders yet.';

  @override
  String businessOrdersItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String get businessOrdersStatusPending => 'New';

  @override
  String get businessOrdersStatusAccepted => 'Accepted';

  @override
  String get businessOrdersStatusPreparing => 'Preparing';

  @override
  String get businessOrdersStatusReady => 'Ready';

  @override
  String get businessOrdersStatusCompleted => 'Completed';

  @override
  String get businessOrdersStatusCancelled => 'Cancelled';

  @override
  String get businessOrdersItemsSection => 'Items';

  @override
  String get businessOrdersTotal => 'Total';

  @override
  String get businessOrdersNotes => 'Notes';

  @override
  String get businessOrdersDepositCovered => 'Covered by a deposit/guarantee';

  @override
  String get businessOrdersDepositUncovered => 'No deposit or guarantee cover';

  @override
  String get paymentConfirmSectionTitle => 'Payment confirmation';

  @override
  String get shippingRatesTitle => 'Shipping prices';

  @override
  String get shippingDaysHint =>
      'Shipping days for this destination (none = every day)';

  @override
  String get shippingRunsToday => 'Today';

  @override
  String get shippingRunsTomorrow => 'Tomorrow';

  @override
  String get shippingRatesHint =>
      'Your shipping price from your governorate to each one. Leave a field empty if you don\'t ship there.';

  @override
  String get shippingOrdersTitle => 'Shipping orders';

  @override
  String get shippingOrdersEmpty => 'No shipping orders.';

  @override
  String get shippingPickCompany => 'Choose a shipping company';

  @override
  String get shippingChangeCompany => 'Change the shipping company';

  @override
  String get shippingPickerTitle => 'Available shipping companies';

  @override
  String get shippingNoCompanies =>
      'No shipping company serves the customer\'s governorate yet.';

  @override
  String get shippingSetAppointment => 'Set the shipping appointment';

  @override
  String get shippingChangeAppointment => 'Change the appointment';

  @override
  String get shippingMarkShipped => 'Mark shipped';

  @override
  String get shippingMarkDelivered => 'Mark delivered';

  @override
  String get shippingStatusAwaitingCompany =>
      'Waiting for a shipping company to be chosen';

  @override
  String get shippingStatusAwaitingAppointment =>
      'Waiting for the shipping appointment';

  @override
  String get shippingStatusShipped => 'The order has been shipped';

  @override
  String get shippingStatusDelivered => 'The order was delivered';

  @override
  String get shippingAppointmentSuitable => 'The appointment suits me';

  @override
  String get shippingAppointmentConfirmed => 'You accepted the appointment';

  @override
  String get businessMyLocation => 'My city';

  @override
  String get registerAddressLabel => 'Address (street, building...)';

  @override
  String get checkoutNeedAddress => 'Choose a delivery address first.';

  @override
  String get addressSaveAndUse => 'Save address and use it';

  @override
  String get shippingAppointmentNotSuitable =>
      'The appointment doesn\'t suit me - chat with the company';

  @override
  String get shippingCheckoutNote =>
      'Your order goes to another governorate: it is shipped by a company the merchant chooses, and its price is added to your invoice.';

  @override
  String get shippingSaved => 'Saved.';

  @override
  String shippingStatusScheduled(String when) {
    return 'Shipping appointment: $when';
  }

  @override
  String shippingCompanyLine(String name) {
    return 'Shipping company: $name';
  }

  @override
  String shippingFeeLine(String fee) {
    return 'Shipping fee: $fee';
  }

  @override
  String get deliveryQuoteEnterAmountTitle => 'Delivery fee for this order';

  @override
  String get deliveryQuoteAmountLabel => 'Amount';

  @override
  String get deliveryQuoteProposeButton => 'Propose the delivery fee';

  @override
  String get deliveryQuoteSend => 'Send';

  @override
  String get deliveryQuoteFeeLocked =>
      'The delivery fee isn\'t agreed yet - pickup can\'t start.';

  @override
  String get deliveryQuoteAwaitingCourier =>
      'This order is outside the business\'s city - waiting for a courier to set the delivery fee.';

  @override
  String get deliveryQuoteAccept => 'Accept the fee';

  @override
  String get deliveryQuoteDecline => 'Decline';

  @override
  String get deliveryQuoteMerchantSuitable =>
      'The merchant considers this fee suitable';

  @override
  String get deliveryQuoteMerchantNotSuitable =>
      'The merchant considers this fee not suitable';

  @override
  String get deliveryQuoteRecommendSuitable => 'Suitable';

  @override
  String get deliveryQuoteRecommendNotSuitable => 'Not suitable';

  @override
  String get deliveryQuoteNoteLabel => 'Note for the customer (optional)';

  @override
  String get deliveryQuoteCheckoutLater =>
      'Delivery fee: set by the courier after they take your order, and you approve it.';

  @override
  String get deliveryQuoteSaved => 'Your answer was sent.';

  @override
  String deliveryQuoteWaitingCustomer(String amount) {
    return 'Waiting for the customer to answer $amount';
  }

  @override
  String deliveryQuoteProposedTitle(String amount) {
    return 'The driver proposed a delivery fee of $amount';
  }

  @override
  String deliveryQuoteRecommendTitle(String amount) {
    return 'The driver proposed $amount - is it suitable?';
  }

  @override
  String get orderDeliveryFeeRow => 'Delivery fee';

  @override
  String get bookingPaymentBusinessStatusLabel =>
      'Business receipt of the amount';

  @override
  String get bookingPaymentBusinessButton => 'Confirm cash received';

  @override
  String get bookingPaymentBusinessConfirmed => 'Amount confirmed received';

  @override
  String get bookingPaymentDepositHint =>
      'Your confirmation counts as agreeing to release the deposit; it releases once both sides confirm.';

  @override
  String get paymentConfirmCompleteHint =>
      'Confirm you received the order amount to be able to complete the order.';

  @override
  String get paymentConfirmReviewHint =>
      'Reviews open once every party has confirmed the payment.';

  @override
  String get trustSectionTitle => 'Trust';

  @override
  String get trustCustomer => 'I trust the customer';

  @override
  String get trustBusiness => 'I trust the merchant';

  @override
  String get trustDriver => 'I trust the driver';

  @override
  String get trustsYouNote => 'Trusts you';

  @override
  String get businessOrdersDepositReleased =>
      'Deposit released after all parties confirmed';

  @override
  String get paymentConfirmCustomerStatusLabel => 'Customer payment';

  @override
  String get paymentConfirmMerchantStatusLabel =>
      'Merchant receipt of the order amount';

  @override
  String get paymentConfirmDriverStatusLabel =>
      'Driver receipt of the delivery fee';

  @override
  String get paymentConfirmStatusConfirmed => 'Confirmed';

  @override
  String get paymentConfirmStatusPending => 'Not yet confirmed';

  @override
  String get paymentConfirmCustomerButton => 'I confirm I paid in cash';

  @override
  String get paymentConfirmCustomerConfirmed => 'Your payment is confirmed';

  @override
  String get paymentConfirmMerchantButton =>
      'Confirm cash received for the order';

  @override
  String get paymentConfirmMerchantConfirmed =>
      'Order amount confirmed received';

  @override
  String get businessOrdersReject => 'Reject';

  @override
  String get businessOrdersAccept => 'Accept';

  @override
  String get businessOrdersRejectConfirm =>
      'Reject this order? The customer will be notified.';

  @override
  String get businessOrdersNoDepositWarning =>
      'This order has no deposit or guarantee cover. Accept anyway, at your own risk?';

  @override
  String get businessOrdersMarkPreparing => 'Start preparing';

  @override
  String get businessOrdersMarkReady => 'Mark ready';

  @override
  String get businessOrdersItemUnavailable => 'Mark unavailable';

  @override
  String get businessOrdersItemUnavailableTitle => 'This item is unavailable';

  @override
  String get businessOrdersItemUnavailableSubstituteNoteLabel =>
      'What did you substitute it with?';

  @override
  String get businessOrdersItemUnavailableSubstituteNoteHint =>
      'e.g. Pepsi instead of Coke';

  @override
  String get businessOrdersItemUnavailableRemoveConfirm =>
      'This item will be removed from the order and the total updated. The customer will be notified.';

  @override
  String businessOrdersItemUnavailableCancelConfirm(int id) {
    return 'The customer asked to cancel the whole order if an item runs out. This will cancel order #$id entirely.';
  }

  @override
  String get businessOrdersItemUnavailableNoPolicy =>
      'The customer did not state what to do if an item runs out. Contact them directly through the order chat.';

  @override
  String get businessOrdersItemUnavailableDone =>
      'Done — the customer has been notified.';

  @override
  String get ordersEmpty => 'No orders yet.';

  @override
  String get bookingsEmpty => 'No bookings yet.';

  @override
  String get ordersCancel => 'Cancel order';

  @override
  String get bookingMoneyTitle => 'What you need up front for this booking';

  @override
  String get bookingMoneyDeposit => 'Deposit held from your wallet';

  @override
  String get bookingMoneyGuarantee => 'Covered by your guarantee';

  @override
  String get bookingMoneyFee => 'Service fee';

  @override
  String get bookingMoneyTotal => 'Needed from your wallet';

  @override
  String get bookingMoneyBalance => 'Your wallet balance';

  @override
  String get bookingMoneyReady => 'Your balance is enough';

  @override
  String get bookingMoneyShort => 'Your balance is not enough';

  @override
  String get bookingMoneyFeeNonRefundable =>
      'The service fee is not refundable once the booking is in progress.';

  @override
  String get bookingMoneyOtherPending =>
      'The other side has not met its part yet.';

  @override
  String get orderDriverTitle => 'Your delivery driver';

  @override
  String get orderDriverCall => 'Call the driver';

  @override
  String get ordersReorder => 'Order again';

  @override
  String get ordersReordered => 'The items were added to your cart.';

  @override
  String get ordersReorderedWithSkipped =>
      'The available items were added to your cart; some could not be found.';

  @override
  String get ordersCancelled => 'Order cancelled.';

  @override
  String get ordersCancelConfirm => 'Cancel this order?';

  @override
  String get bookingsCancel => 'Cancel booking';

  @override
  String get bookingsCancelled => 'Booking cancelled.';

  @override
  String get bookingsCancelConfirm => 'Cancel this booking?';

  @override
  String get bookingsConfirmReadiness => 'Confirm readiness';

  @override
  String get bookingsConfirmed => 'Confirmation saved.';

  @override
  String get bookingsDepositSettlement => 'Deposit settlement';

  @override
  String get bookingsAgreeRelease => 'Confirm transaction succeeded';

  @override
  String get bookingsAgreeRefund => 'Transaction didn\'t happen';

  @override
  String get bookingsAgreementSaved => 'Your answer was saved.';

  @override
  String get bookingsWaitingOtherPartyRelease =>
      'Waiting for the other party to confirm the deposit can be released.';

  @override
  String get bookingsWaitingOtherPartyRefund =>
      'Waiting for the other party to confirm the deposit should be refunded.';

  @override
  String get bookingsDepositReleased => 'Deposit released.';

  @override
  String get bookingsDepositRefunded => 'Deposit refunded.';

  @override
  String get pendingSettlementTitle => 'Decision needed';

  @override
  String get pendingSettlementSubtitle =>
      'You need to decide before continuing to use the app.';

  @override
  String pendingSettlementQuestion(String name) {
    return 'Did the transaction with $name succeed?';
  }

  @override
  String pendingSettlementRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more decisions after this',
      one: '1 more decision after this',
    );
    return '$_temp0';
  }

  @override
  String get orderStatusPending => 'Pending';

  @override
  String get orderStatusCompleted => 'Completed';

  @override
  String get orderStatusCancelled => 'Cancelled';

  @override
  String get orderTrackerPlaced => 'Order placed';

  @override
  String get orderTrackerAccepted => 'Accepted';

  @override
  String get orderTrackerPreparing => 'Preparing';

  @override
  String get orderTrackerReady => 'Ready';

  @override
  String get orderTrackerCompletedPickup => 'Picked up';

  @override
  String get orderTrackerCompletedDineIn => 'Served';

  @override
  String get orderTrackerDriverAssigned => 'Driver assigned';

  @override
  String get orderTrackerPickedUpByDriver => 'Picked up by driver';

  @override
  String get orderTrackerDelivered => 'Delivered';

  @override
  String get orderTrackerCancelledTitle => 'This order was cancelled';

  @override
  String get bookingStatusPending => 'Pending';

  @override
  String get bookingStatusAccepted => 'Accepted';

  @override
  String get bookingStatusRejected => 'Rejected';

  @override
  String get bookingStatusCancelled => 'Cancelled';

  @override
  String get bookingStatusInProgress => 'In progress';

  @override
  String get bookingStatusCompleted => 'Completed';

  @override
  String get businessBookingsTitle => 'Incoming bookings';

  @override
  String get businessBookingsFilterAll => 'All';

  @override
  String get businessBookingsFilterPending => 'Pending';

  @override
  String get businessBookingsFilterAccepted => 'Accepted';

  @override
  String get businessBookingsFilterInProgress => 'In progress';

  @override
  String get businessBookingsFilterCompleted => 'Completed';

  @override
  String get businessBookingsFilterCancelled => 'Cancelled';

  @override
  String get businessBookingsEmpty => 'No bookings yet.';

  @override
  String get businessBookingsCustomer => 'Customer';

  @override
  String get businessBookingsUnit => 'Unit';

  @override
  String get businessBookingsQuantity => 'Quantity';

  @override
  String get businessBookingsPartySize => 'Guests';

  @override
  String get businessBookingsNotes => 'Notes';

  @override
  String get businessBookingsDateTime => 'Date & time';

  @override
  String get businessBookingsPrice => 'Price';

  @override
  String get businessBookingsAccept => 'Accept';

  @override
  String get businessBookingsReject => 'Reject';

  @override
  String get businessBookingsRejectConfirm =>
      'Reject this booking? The customer will be notified.';

  @override
  String get businessBookingsConfirm => 'Confirm readiness';

  @override
  String get businessBookingsStart => 'Start';

  @override
  String get businessBookingsComplete => 'Complete';

  @override
  String get ratingsReviewsTitle => 'Reviews';

  @override
  String get ratingsEmpty => 'No reviews yet.';

  @override
  String get ratingsLeaveReview => 'Leave a review';

  @override
  String get ratingsSubmit => 'Submit review';

  @override
  String get ratingsCommentHint => 'Write a comment (optional)';

  @override
  String get ratingsSubmitted => 'Your review was submitted.';

  @override
  String get ratingsSelectStarsError => 'Choose a star rating first.';

  @override
  String get financeTitle => 'Financial affairs';

  @override
  String get walletTitle => 'Wallet';

  @override
  String get walletAvailableBalance => 'Available balance';

  @override
  String get walletLockedBalance => 'Locked balance';

  @override
  String get walletTransactionsTitle => 'Transactions';

  @override
  String get walletTabAll => 'All';

  @override
  String get walletTypeDeposit => 'Top-ups';

  @override
  String get walletTypeWithdraw => 'Withdrawals';

  @override
  String get walletTypeTransfer => 'Transfers';

  @override
  String get walletTypeHold => 'Holds';

  @override
  String get walletTypeRelease => 'Releases';

  @override
  String get walletTypeRefund => 'Refunds';

  @override
  String get walletTypePlatformFee => 'Fees';

  @override
  String get walletTypeAdjustment => 'Adjustments';

  @override
  String get walletTransactionsEmpty => 'No transactions yet.';

  @override
  String get walletPinCreateTitle => 'Set your wallet PIN';

  @override
  String walletPinCreateHint(int length) {
    return 'Choose a $length-digit PIN to protect wallet actions like this one.';
  }

  @override
  String get walletPinEnterTitle => 'Enter your wallet PIN';

  @override
  String get walletPinFieldHint => 'PIN';

  @override
  String get walletPinConfirmHint => 'Confirm PIN';

  @override
  String get walletPinMismatch => 'PINs don\'t match.';

  @override
  String get walletPinWrong => 'Incorrect PIN.';

  @override
  String get chatTitle => 'Chat';

  @override
  String get chatOpenChat => 'Chat';

  @override
  String get chatEmpty => 'No messages yet.';

  @override
  String get chatMessageHint => 'Write a message...';

  @override
  String get chatLocked =>
      'This chat has ended; you can no longer send messages.';

  @override
  String get threadAccessConsentPrompt =>
      'May admins read this chat if ever needed (e.g. for a dispute)? Your choice, any time.';

  @override
  String get threadAccessApprove => 'Allow';

  @override
  String get threadAccessDecline => 'Don\'t allow';

  @override
  String get threadAccessStatusApproved =>
      'You allowed admins to view this chat';

  @override
  String get threadAccessStatusDeclined =>
      'You did not allow admins to view this chat';

  @override
  String get threadAccessSheetTitle => 'Chat privacy';

  @override
  String get agendaTitle => 'My agenda';

  @override
  String get agendaEmpty => 'Nothing on this day.';

  @override
  String get agendaAddTask => 'Add task';

  @override
  String get agendaTaskTitle => 'Title';

  @override
  String get agendaTaskNotes => 'Notes (optional)';

  @override
  String get agendaStartTime => 'Start time';

  @override
  String get agendaEndTime => 'End time (optional)';

  @override
  String get agendaToday => 'Today';

  @override
  String get agendaDeleteConfirm => 'Delete this task?';

  @override
  String get agendaTitleRequired => 'Enter a title for the task.';

  @override
  String get agendaWeekView => 'Week view';

  @override
  String get agendaDayView => 'Day view';

  @override
  String get agendaNothing => 'Nothing';

  @override
  String get agendaRepeat => 'Repeat';

  @override
  String get agendaRepeatNone => 'Does not repeat';

  @override
  String get agendaRepeatDaily => 'Daily';

  @override
  String get agendaRepeatWeekly => 'Weekly';

  @override
  String get agendaRepeatWeeks => 'Number of weeks';

  @override
  String get agendaRepeatFromToday => 'Repeating starts from today.';

  @override
  String get agendaRemindMe => 'Remind me';

  @override
  String get agendaWeekdaysRequired => 'Pick at least one day.';

  @override
  String agendaRecurringResult(int created, int skipped) {
    return 'Added $created tasks; skipped $skipped that clashed with other commitments.';
  }

  @override
  String get agendaFeedTitle => 'Sync with your phone calendar';

  @override
  String get agendaFeedHint =>
      'Copy the link and subscribe to it in Google or Apple Calendar so your schedule appears there automatically.';

  @override
  String get agendaFeedCopy => 'Copy link';

  @override
  String get agendaFeedCopied => 'Link copied.';

  @override
  String get agendaFeedRotate => 'Create a new link';

  @override
  String get agendaFeedRotateConfirm =>
      'The old link will stop working in every calendar subscribed to it. Continue?';

  @override
  String get cartShareCart => 'Share cart';

  @override
  String get cartShareInstructions =>
      'Share this code with your friends so they can add their orders:';

  @override
  String get cartShareCopied => 'Code copied.';

  @override
  String get cartJoinSharedCart => 'Join a shared cart';

  @override
  String get cartJoinTokenHint => 'Enter the share code';

  @override
  String get cartJoinAction => 'Join';

  @override
  String get sharedCartTitle => 'Shared cart';

  @override
  String get sharedCartParticipants => 'Participants';

  @override
  String get sharedCartAddItems => 'Add items';

  @override
  String get sharedCartLeave => 'Leave cart';

  @override
  String get sharedCartLeaveConfirm => 'Leave this shared cart?';

  @override
  String get sharedCartCancelCart => 'Cancel cart';

  @override
  String get sharedCartCancelConfirm => 'Cancel this shared cart entirely?';

  @override
  String get sharedCartHostBadge => 'Host';

  @override
  String get sharedCartInviteFriend => 'Invite a friend';

  @override
  String get sharedCartInviteHint => 'Their phone number or email';

  @override
  String get sharedCartInviteAction => 'Invite';

  @override
  String sharedCartInviteSent(String name) {
    return 'Invitation sent to $name.';
  }

  @override
  String get sharedCartShowQr => 'Show QR code';

  @override
  String get sharedCartQrHint =>
      'Have your friend scan this with bim_app, or any camera, to join the cart.';

  @override
  String get sharedCartCopyLink => 'Copy link';

  @override
  String get qrScanTitle => 'Scan QR';

  @override
  String get qrScanHint =>
      'Point the camera at your friend\'s shared-cart QR code';

  @override
  String get qrScanCameraUnavailable =>
      'Camera isn\'t available. Check the app\'s camera permission and try again.';

  @override
  String get deliveryAssignDriverTitle => 'Choose a driver';

  @override
  String get deliveryNoDriversYet =>
      'You haven\'t added any delivery drivers yet.';

  @override
  String get deliveryDriverOnDuty => 'On duty';

  @override
  String get deliveryDriverOffDuty => 'Off duty';

  @override
  String deliveryDriverBusy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'carrying $count orders',
      one: 'carrying 1 order',
    );
    return '$_temp0';
  }

  @override
  String deliveryDriverDistance(String km) {
    return '$km km away';
  }

  @override
  String get deliveryAssign => 'Assign';

  @override
  String get deliveryMyDriversTitle => 'My Drivers';

  @override
  String get deliveryTakeOffDuty => 'Take off duty';

  @override
  String get deliveryTakeOnDuty => 'Reactivate';

  @override
  String get deliveryNearbyFreelancersSection => 'Nearby freelance drivers';

  @override
  String get deliveryNearbyFreelancersHint =>
      'Visibility only — you can\'t assign them directly; they self-accept from the open job board if you leave an order unassigned by your own team.';

  @override
  String get deliveryNoNearbyFreelancers =>
      'No nearby freelance drivers right now.';

  @override
  String get deliveryLocationNeededForFreelancers =>
      'Set your business\'s location in Settings to see nearby freelance drivers.';

  @override
  String get deliveryPickupQrTitle => 'Pickup QR';

  @override
  String deliveryPickupQrHint(String driver) {
    return 'Show this to $driver when they arrive to pick up the order';
  }

  @override
  String get deliveryPickupQrHintGeneric =>
      'Show this code to the driver when they arrive to pick up the order';

  @override
  String get deliveryShowPickupQrAgain => 'Show pickup code';

  @override
  String get deliveryDeliveryQrTitle => 'Delivery QR';

  @override
  String get deliveryDeliveryQrHint =>
      'Show this to the customer so they can confirm they received their order';

  @override
  String get deliveryDashboardTitle => 'Delivery';

  @override
  String get deliveryBecomeDriverTitle => 'Become a delivery driver';

  @override
  String get deliveryBecomeDriverHint =>
      'Register to see and accept delivery jobs, or be linked by a business.';

  @override
  String get deliveryBecomeDriver => 'Register as a driver';

  @override
  String get deliveryOnDutySwitch => 'Available for deliveries';

  @override
  String get deliveryDeliveredCount => 'Orders delivered';

  @override
  String get deliveryFastDeliveryCount => 'Fast deliveries ⚡';

  @override
  String get deliveryMyActiveOrders => 'My active deliveries';

  @override
  String get deliveryNoActiveOrders => 'No active deliveries right now.';

  @override
  String get deliveryScanPickupTitle => 'Scan pickup QR';

  @override
  String get deliveryScanPickupHint =>
      'Point the camera at the restaurant\'s pickup QR code';

  @override
  String get deliveryPickupConfirmed =>
      'Pickup confirmed — you\'re carrying this order now.';

  @override
  String get deliveryShowDeliveryQr => 'Show delivery QR to customer';

  @override
  String get deliveryCompleted => 'This delivery is complete.';

  @override
  String get myWorkDriverRole => 'Delivery driver';

  @override
  String get deliveryResetPickupCode => 'Reset code';

  @override
  String get deliveryResetPickupCodeConfirm =>
      'The current code will stop working and a new one will be created. Continue?';

  @override
  String get deliveryAvailableOrdersTitle => 'Available orders';

  @override
  String get deliveryAvailableOrdersEmpty =>
      'No orders available right now. Pull to refresh.';

  @override
  String get deliveryAcceptOrder => 'Accept delivery';

  @override
  String get deliveryOrderAccepted =>
      'Order accepted — find it under My active deliveries.';

  @override
  String deliveryFeeLine(String fee) {
    return 'Delivery fee: $fee';
  }

  @override
  String deliveryOrderTotalLine(String total) {
    return 'Order total: $total';
  }

  @override
  String get deliveryFeeSettingsTitle => 'Delivery fee';

  @override
  String get deliveryFeeBusinessHint =>
      'A flat amount added automatically to the customer\'s invoice when they choose delivery. Leave empty for free delivery.';

  @override
  String get deliveryFeeDriverHint =>
      'A flat amount you charge as a freelance driver. Only applies when the business never set a delivery fee, and never changes a fee the business already set.';

  @override
  String get deliveryFeeAmountLabel => 'Delivery fee';

  @override
  String get deliveryFeeSaved => 'Delivery fee saved.';

  @override
  String get deliveryFeeInvalid => 'Enter a valid amount.';

  @override
  String get deliveryFeeClear => 'No fee';

  @override
  String get paymentConfirmDriverButton => 'Confirm cash received for delivery';

  @override
  String get paymentConfirmDriverConfirmed => 'Delivery fee confirmed received';

  @override
  String get deliveryCustomerSection => 'Customer';

  @override
  String get deliveryOpenInMaps => 'Open in Maps';

  @override
  String get deliveryCalculateDistance => 'Calculate distance';

  @override
  String deliveryDistanceValue(String km) {
    return 'Distance: $km km';
  }

  @override
  String get deliverySendEtaToCustomer => 'Send ETA to customer';

  @override
  String get deliveryEtaDialogTitle => 'Set the expected delivery time';

  @override
  String get deliveryEtaInMinutes => 'In (minutes)';

  @override
  String get deliveryEtaAtTime => 'Pick a specific time';

  @override
  String get deliveryEtaSent => 'The expected time was sent to the customer.';

  @override
  String get deliveryScanReceiptTitle => 'Scan to confirm receipt';

  @override
  String get deliveryScanReceiptHint =>
      'Point the camera at the driver\'s delivery QR code';

  @override
  String get deliveryReceiptConfirmed => 'Delivery confirmed — thank you!';

  @override
  String get sharedCartInviteGroup => 'Invite a group';

  @override
  String get sharedCartNoGroupsYet =>
      'You don\'t have any contact groups yet. Create one from the drawer first.';

  @override
  String sharedCartGroupInviteSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Invited $count people.',
      one: 'Invited 1 person.',
      zero: 'No one new to invite — they\'re all already in.',
    );
    return '$_temp0';
  }

  @override
  String get sharedCartSelectMembers => 'Choose who to invite';

  @override
  String get sharedCartSelectAll => 'Select all';

  @override
  String get contactGroupsTitle => 'Contact groups';

  @override
  String get contactGroupsEmpty =>
      'No contact groups yet. Create one to invite the same circle of friends to a shared cart at once.';

  @override
  String get contactGroupsCreate => 'New group';

  @override
  String get contactGroupNameHint => 'e.g. Family, Damietta friends';

  @override
  String get commonCreate => 'Create';

  @override
  String contactGroupMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
      zero: 'No members',
    );
    return '$_temp0';
  }

  @override
  String get contactGroupAddMember => 'Add member';

  @override
  String get contactGroupAddAction => 'Add';

  @override
  String get contactGroupRename => 'Rename group';

  @override
  String get contactGroupDeleteConfirm =>
      'Delete this group? This does not affect any cart you\'ve already shared.';

  @override
  String get contactGroupNoMembers =>
      'No members yet. Add someone by their phone number or email.';

  @override
  String get businessGroupsTitle => 'Business groups';

  @override
  String get businessGroupsEmpty =>
      'No business groups yet. Create one to target the same circle of businesses with your offers at once.';

  @override
  String get businessGroupsCreate => 'New group';

  @override
  String get businessGroupNameHint =>
      'e.g. Vegetable shops, Furniture factories';

  @override
  String get businessGroupRename => 'Rename group';

  @override
  String get businessGroupDeleteConfirm =>
      'Delete this group? This does not affect any listing you\'ve already restricted to it.';

  @override
  String get businessGroupNoMembers => 'No businesses yet. Add one by search.';

  @override
  String get businessGroupAddToOffersGroup => 'Add to an offers group';

  @override
  String businessGroupMemberAdded(String business, String group) {
    return 'Added $business to \"$group\".';
  }

  @override
  String get retailListingAddBusinessGroup => 'Add a group';

  @override
  String get retailListingBusinessGroupPickerTitle => 'Choose a business group';

  @override
  String get retailListingBusinessGroupPickerEmpty => 'No business groups yet.';

  @override
  String get staffTeamSettingsTitle => 'Staff settings';

  @override
  String get staffTitle => 'Staff';

  @override
  String get staffEmpty => 'No staff yet.';

  @override
  String get staffAdd => 'Add staff';

  @override
  String get staffEdit => 'Edit staff';

  @override
  String get staffPhone => 'Staff member\'s phone';

  @override
  String get staffJobTitle => 'Job title (optional)';

  @override
  String get staffCapabilities => 'Capabilities';

  @override
  String get staffCapabilitiesRequired => 'Choose at least one capability.';

  @override
  String get staffActive => 'Active';

  @override
  String get staffInactiveBadge => 'Inactive';

  @override
  String get staffPendingBadge => 'Pending';

  @override
  String get staffInvitationsTitle => 'Work invitations';

  @override
  String get staffInvitationsEmpty =>
      'No invitations waiting for your response.';

  @override
  String get staffInvitationAccept => 'Accept';

  @override
  String get staffInvitationDecline => 'Decline';

  @override
  String get staffInvitationAccepted => 'Invitation accepted.';

  @override
  String get staffInvitationDeclined => 'Invitation declined.';

  @override
  String get staffInvitationSentTitle => 'Invitation sent';

  @override
  String get staffInvitationSentPending =>
      'Waiting for the employee to accept.';

  @override
  String get staffRemove => 'Remove';

  @override
  String get staffRemoveConfirm => 'Remove this staff member?';

  @override
  String get staffPhoneRequired => 'Enter the staff member\'s phone number.';

  @override
  String get staffActivityTitle => 'Staff activity log';

  @override
  String get staffActivityEmpty => 'No activity in this period.';

  @override
  String get staffActivityFrom => 'From';

  @override
  String get staffActivityTo => 'To';

  @override
  String get staffActivityToday => 'Today';

  @override
  String get staffActivityFilter => 'Filter';

  @override
  String get staffActivityStaffLabel => 'Staff member';

  @override
  String get staffActivityAllStaff => 'Everyone';

  @override
  String get staffActivityOwnerBadge => 'Owner';

  @override
  String staffActivityOperationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count operations',
      one: '1 operation',
      zero: 'No operations in this period',
    );
    return '$_temp0';
  }

  @override
  String get staffActivityActionAccepted => 'Accepted';

  @override
  String get staffActivityActionRejected => 'Rejected';

  @override
  String get staffActivityActionPreparing => 'Started preparing';

  @override
  String get staffActivityActionReady => 'Marked ready';

  @override
  String get staffActivityActionCompleted => 'Completed';

  @override
  String get staffActivityActionStarted => 'Started';

  @override
  String get staffActivityActionConfirmed => 'Confirmed';

  @override
  String get staffActivityActionItemUnavailable => 'Reported item unavailable';

  @override
  String get staffActivitySubjectOrder => 'Order';

  @override
  String get staffActivitySubjectBooking => 'Booking';

  @override
  String get staffGroupsTitle => 'Work teams';

  @override
  String get staffGroupsEmptyGroup => 'No one in this group yet.';

  @override
  String get staffAssignTask => 'Assign a task';

  @override
  String get staffAttendancePresent => 'Present now';

  @override
  String get staffAttendanceCheckedOut => 'Checked out';

  @override
  String get staffAttendanceNotCheckedIn => 'Hasn\'t checked in today';

  @override
  String staffAttendancePresentSince(String time) {
    return 'Present since $time';
  }

  @override
  String staffAttendanceCheckedOutAt(String time) {
    return 'Checked out at $time';
  }

  @override
  String get myWorkTitle => 'My work';

  @override
  String get myWorkEmpty => 'You don\'t work for any business yet.';

  @override
  String get attendanceCheckIn => 'Check in';

  @override
  String get attendanceCheckOut => 'Check out';

  @override
  String get attendanceVerificationSettingsTitle => 'Attendance verification';

  @override
  String get attendanceVerificationToggleLabel => 'Location + QR verification';

  @override
  String get attendanceVerificationToggleHint =>
      'When on, staff must scan a code from a display at the business and be nearby to check in or out.';

  @override
  String get attendanceOpenDisplayScreen =>
      'Open the attendance display screen';

  @override
  String get attendanceQrDisplayTitle => 'Attendance display';

  @override
  String get attendanceQrDisplayHint =>
      'Have the employee scan this code to check in or out — it refreshes automatically';

  @override
  String get attendanceScanQrTitle => 'Scan the attendance code';

  @override
  String get attendanceScanQrHint =>
      'Point the camera at the attendance code shown at the workplace';

  @override
  String get attendanceLocationRequired =>
      'Attendance verification needs access to your location.';

  @override
  String get finesTitle => 'Fines';

  @override
  String get finesEmpty => 'No fines.';

  @override
  String get finesFrozenAmount => 'Frozen amount';

  @override
  String get finesCollectedAmount => 'Collected amount';

  @override
  String get finesAppealStatementHint => 'Explain why you\'re contesting this';

  @override
  String get finesSubmitAppeal => 'Submit appeal';

  @override
  String get finesAppealSubmitted =>
      'Your appeal was submitted and will be reviewed.';

  @override
  String get finesAppealPending => 'Your appeal is under review.';

  @override
  String get finesAppealStatementRequired =>
      'Explain why you\'re contesting this first.';

  @override
  String get finesStatusFrozen => 'Frozen (appeal window open)';

  @override
  String get finesStatusAppealed => 'Under appeal';

  @override
  String get finesStatusUpheld => 'Upheld (due for collection)';

  @override
  String get finesStatusOverturned => 'Overturned';

  @override
  String get finesStatusCollected => 'Collected';

  @override
  String get finesStatusCancelled => 'Cancelled';

  @override
  String get projectsTitle => 'Projects';

  @override
  String get projectsEmpty => 'No projects yet.';

  @override
  String get projectTasksEmpty => 'No tasks yet.';

  @override
  String get projectsAdd => 'New project';

  @override
  String get projectTitleLabel => 'Project title';

  @override
  String get projectDescription => 'Description (optional)';

  @override
  String get projectReference => 'Reference (optional)';

  @override
  String get projectStartsOn => 'Start date (optional)';

  @override
  String get projectDueOn => 'Due date (optional)';

  @override
  String get projectTitleRequired => 'Enter a project title.';

  @override
  String get projectOverdueBadge => 'Overdue';

  @override
  String get projectTasksTitle => 'Tasks';

  @override
  String get projectAddTask => 'Add task';

  @override
  String get projectDeleteConfirm =>
      'Delete this project? All its tasks will be deleted too.';

  @override
  String get taskTitleLabel => 'Task title';

  @override
  String get taskNotes => 'Notes (optional)';

  @override
  String get taskRequiresPhoto => 'Requires a camera photo to complete';

  @override
  String get taskTitleRequired => 'Enter a task title.';

  @override
  String get taskCriticalBadge => 'Critical';

  @override
  String get taskDeleteConfirm => 'Delete this task?';

  @override
  String get taskProgressLabel => 'Progress';

  @override
  String get taskMarkDone => 'Mark done';

  @override
  String get projectStatusPlanning => 'Planning';

  @override
  String get projectStatusActive => 'Active';

  @override
  String get projectStatusOnHold => 'On hold';

  @override
  String get projectStatusCompleted => 'Completed';

  @override
  String get projectStatusCancelled => 'Cancelled';

  @override
  String get taskStatusPending => 'Pending';

  @override
  String get taskStatusInProgress => 'In progress';

  @override
  String get taskStatusBlocked => 'Blocked';

  @override
  String get taskStatusDone => 'Done';

  @override
  String get projectProgressTitle => 'Project progress';

  @override
  String get projectProgressEmpty => 'No progress plan for this operation yet.';

  @override
  String get projectViewProgress => 'View project progress';

  @override
  String get tripSearchTitle => 'Search trips';

  @override
  String get tripOrigin => 'From';

  @override
  String get tripDestination => 'To';

  @override
  String get tripChooseGovernorate => 'Choose a governorate';

  @override
  String get tripDateOptional => 'Date (optional)';

  @override
  String get tripSearchAction => 'Search';

  @override
  String get tripSearchEmpty => 'No matching trips.';

  @override
  String get tripSearchFieldsRequired =>
      'Choose both an origin and a destination.';

  @override
  String get tripReserve => 'Reserve';

  @override
  String get tripUnits => 'Units';

  @override
  String get tripReservationNotes => 'Notes (optional)';

  @override
  String get tripReserved =>
      'Reservation created, awaiting the carrier\'s confirmation.';

  @override
  String get myReservationsTitle => 'Trip reservations';

  @override
  String get myReservationsEmpty => 'No reservations yet.';

  @override
  String get tripReservationCancel => 'Cancel reservation';

  @override
  String get tripReservationCancelConfirm => 'Cancel this reservation?';

  @override
  String get tripReservationCancelled => 'Reservation cancelled.';

  @override
  String get tripStatusPending => 'Awaiting confirmation';

  @override
  String get tripStatusConfirmed => 'Confirmed';

  @override
  String get tripStatusCompleted => 'Completed';

  @override
  String get tripStatusCancelled => 'Cancelled';

  @override
  String get tripStatusBlocked => 'Manually held';

  @override
  String get tripModeFreight => 'Freight';

  @override
  String get tripModePassenger => 'Passengers';

  @override
  String get tripModeLimousine => 'Limousine';

  @override
  String get tripModeDistribution => 'Distribution';

  @override
  String get clinicBookAppointment => 'Book an appointment';

  @override
  String get billVisitFee => 'Visit fee';

  @override
  String get billServices => 'Services';

  @override
  String get billServicesAfterVisit =>
      'The services\' cost shows once the visit is done, and may be raised or lowered.';

  @override
  String get billTotal => 'Total';

  @override
  String get billPaid => 'Paid';

  @override
  String get billRemaining => 'Remaining';

  @override
  String get billRecordPayment => 'Record a payment';

  @override
  String get billAmount => 'Amount';

  @override
  String get billKindVisitFee => 'Visit fee';

  @override
  String get billKindService => 'Service';

  @override
  String get billNote => 'Note (optional)';

  @override
  String get billFinalPrice => 'Final price';

  @override
  String get billFinalPriceHint => 'Leave empty for the listed price';

  @override
  String get billSave => 'Save';

  @override
  String get billConfirm => 'Confirm';

  @override
  String get billDispute => 'Dispute';

  @override
  String get billDisputeNote => 'What do you object to? (optional)';

  @override
  String get billConfirmed => 'confirmed by the patient';

  @override
  String get billDisputed => 'disputed by the patient';

  @override
  String get billAwaitingYou => 'waiting for your confirmation';

  @override
  String get billAwaitingPatient => 'waiting for the patient';

  @override
  String get billNextInstallment => 'Instalment at the next session';

  @override
  String get billInstallmentHint => 'Leave empty to ask for everything left';

  @override
  String get billCarriedOver => 'Instalment due';

  @override
  String billCarriedOverLine(String amount, String due) {
    return 'The patient still owes $amount from earlier visits — $due is asked with this session.';
  }

  @override
  String get billOwedTitle => 'Due from earlier visits';

  @override
  String billOwedBody(String amount, String due) {
    return 'You still owe this clinic $amount — $due is asked with your next appointment.';
  }

  @override
  String get clinicKindNoSlots => 'No open times for this kind right now';

  @override
  String get clinicPickService => 'Services needed (optional)';

  @override
  String get clinicPickKind => 'Visit type';

  @override
  String get clinicRequestBooking => 'Request the booking';

  @override
  String get clinicPatientLabel => 'Patient';

  @override
  String get clinicForMe => 'Me';

  @override
  String get clinicForOther => 'Someone else';

  @override
  String get clinicAttendeeName => 'Patient\'s name';

  @override
  String get clinicAttendeePhone => 'Phone (optional)';

  @override
  String clinicAttendeeFor(Object name) {
    return 'For $name';
  }

  @override
  String get clinicNoOpenSlots => 'No open slots right now.';

  @override
  String get clinicPickDay => 'Day';

  @override
  String get clinicPickTime => 'Time';

  @override
  String get clinicPickSlotHint => 'Pick a day and a time to book';

  @override
  String get clinicBookSlot => 'Book this slot';

  @override
  String get clinicReasonHint => 'Reason for the visit (optional)';

  @override
  String get clinicAppointmentBooked => 'Appointment booked.';

  @override
  String get myClinicAppointmentsTitle => 'Clinic appointments';

  @override
  String get myClinicAppointmentsEmpty => 'No appointments yet.';

  @override
  String get clinicAppointmentCancel => 'Cancel appointment';

  @override
  String get clinicAppointmentCancelConfirm => 'Cancel this appointment?';

  @override
  String get clinicAppointmentCancelled => 'Appointment cancelled.';

  @override
  String get clinicStatusRequested => 'Awaiting confirmation';

  @override
  String get clinicStatusConfirmed => 'Confirmed';

  @override
  String get clinicStatusCompleted => 'Completed';

  @override
  String get clinicStatusCancelled => 'Cancelled';

  @override
  String get clinicStatusNoShow => 'No-show';

  @override
  String get trainingPlansTitle => 'Training plans';

  @override
  String get trainingPlansEmpty => 'No training plans yet.';

  @override
  String get trainingStatusActive => 'Active';

  @override
  String get trainingStatusPaused => 'Paused';

  @override
  String get trainingStatusCompleted => 'Completed';

  @override
  String get trainingStatusCancelled => 'Cancelled';

  @override
  String get trainingTabExercises => 'Exercises';

  @override
  String get trainingPlanPendingPrompt =>
      'New training plan awaiting your acceptance';

  @override
  String get trainingPlanAccepted => 'Plan accepted.';

  @override
  String get trainingPlanDeclined => 'Plan declined.';

  @override
  String get trainingTabMeals => 'Meals';

  @override
  String get trainingTabProgress => 'Progress';

  @override
  String get trainingTabBodyReports => 'Body reports';

  @override
  String get trainingExercisesEmpty => 'No exercises yet.';

  @override
  String get trainingMealsEmpty => 'No meals yet.';

  @override
  String get trainingSetsLabel => 'Sets';

  @override
  String get trainingRepsLabel => 'Reps';

  @override
  String get trainingRestLabel => 'Rest';

  @override
  String get trainingCompleteRound => 'Complete a round';

  @override
  String get trainingRoundCompleted => 'Round logged.';

  @override
  String get trainingAllRoundsDone => 'All rounds done for today';

  @override
  String get trainingLogProgress => 'Log progress';

  @override
  String get trainingWeightHint => 'Weight (kg)';

  @override
  String get trainingNotesHint => 'Notes (optional)';

  @override
  String get trainingProgressLogged => 'Progress logged.';

  @override
  String get trainingProgressEmpty => 'No check-ins yet.';

  @override
  String get trainingWeeklySummaryTitle => 'This week';

  @override
  String get trainingAdherence => 'Adherence';

  @override
  String get trainingTargetRounds => 'Target rounds';

  @override
  String get trainingCompletedRoundsLabel => 'Completed rounds';

  @override
  String get trainingActiveDays => 'Active days';

  @override
  String get trainingCheckIns => 'Check-ins';

  @override
  String get trainingLatestWeight => 'Latest weight';

  @override
  String get trainingBodyReportsEmpty => 'No readings recorded yet.';

  @override
  String get mealBreakfast => 'Breakfast';

  @override
  String get mealLunch => 'Lunch';

  @override
  String get mealDinner => 'Dinner';

  @override
  String get mealSnack => 'Snack';

  @override
  String get bodyReportWeight => 'Weight';

  @override
  String get bodyReportMuscle => 'Muscle mass';

  @override
  String get bodyReportFat => 'Fat %';

  @override
  String get bodyReportWater => 'Water %';

  @override
  String get bodyReportBone => 'Bone mass';

  @override
  String get bodyReportVisceralFat => 'Visceral fat';

  @override
  String get prescriptionsTitle => 'Prescriptions';

  @override
  String get prescriptionsEmpty => 'No prescriptions yet.';

  @override
  String get prescriptionStatusRequested => 'Awaiting pharmacy reply';

  @override
  String get prescriptionStatusQuoted => 'Quote ready';

  @override
  String get medicineRequestTitle => 'Request medicine (no prescription)';

  @override
  String get medicineRequestDirectLabel => 'Direct medicine request';

  @override
  String get medicineRequestExplainer =>
      'Not sure of the exact drug name? Send a photo of the paper prescription or describe what you need, and the pharmacy will reply with the items and price.';

  @override
  String get medicineRequestPharmacyLabel => 'Pharmacy';

  @override
  String get medicineRequestPickPharmacyTitle => 'Choose a pharmacy';

  @override
  String get medicineRequestNoteLabel =>
      'Note (optional if you attach a photo)';

  @override
  String get medicineRequestNoteHint =>
      'e.g. I need something for a headache and a cough';

  @override
  String get medicineRequestAttachPhoto => 'Attach the prescription photo';

  @override
  String get medicineRequestChangePhoto => 'Change photo';

  @override
  String get medicineRequestTakePhoto => 'Take a photo';

  @override
  String get medicineRequestChooseFromGallery => 'Choose from gallery';

  @override
  String get medicineRequestSubmit => 'Send request';

  @override
  String get medicineRequestNeedsNoteOrPhoto =>
      'Write a note or attach a photo of the prescription.';

  @override
  String get medicineRequestCustomerNoteLabel => 'Customer\'s note';

  @override
  String get medicineRequestQuoteTitle => 'Quote this request';

  @override
  String get medicineRequestQuoteAction => 'Quote this request';

  @override
  String get medicineRequestAddLine => 'Add item';

  @override
  String get medicineRequestNeedsOneLine => 'Add at least one item.';

  @override
  String get medicineRequestQuoted => 'The quote was sent.';

  @override
  String get medicineRequestDeclineTitle => 'Decline request';

  @override
  String get medicineRequestDeclineNoteHint => 'Reason (optional)';

  @override
  String get medicineRequestDeclineAction => 'Decline request';

  @override
  String get medicineRequestDeclined => 'The request was declined.';

  @override
  String get medicineRequestConfirmAction => 'Confirm price and proceed';

  @override
  String get medicineRequestConfirmed =>
      'Request confirmed — now being prepared.';

  @override
  String get prescriptionStatusIssued => 'Issued';

  @override
  String get prescriptionStatusSent => 'Sent to pharmacy';

  @override
  String get prescriptionStatusPreparing => 'Preparing';

  @override
  String get prescriptionStatusReady => 'Ready';

  @override
  String get prescriptionStatusDispensed => 'Dispensed';

  @override
  String get prescriptionStatusCancelled => 'Cancelled';

  @override
  String get prescriptionDiagnosisLabel => 'Diagnosis';

  @override
  String get prescriptionConditionLabel => 'Patient condition';

  @override
  String get prescriptionNotesLabel => 'Notes';

  @override
  String get prescriptionPharmacyLabel => 'Pharmacy';

  @override
  String get prescriptionMedicineTotalLabel => 'Total';

  @override
  String get prescriptionSharedWithTitle => 'Shared with';

  @override
  String get prescriptionItemsTitle => 'Medicines';

  @override
  String get prescriptionDosageLabel => 'Dosage';

  @override
  String get prescriptionQuantityLabel => 'Quantity';

  @override
  String get prescriptionFoodBefore => 'Before food';

  @override
  String get prescriptionFoodWith => 'With food';

  @override
  String get prescriptionFoodAfter => 'After food';

  @override
  String get prescriptionSlotMorning => 'Morning';

  @override
  String get prescriptionSlotEvening => 'Evening';

  @override
  String get prescriptionDurationDays => 'day(s)';

  @override
  String get prescriptionDurationWeeks => 'week(s)';

  @override
  String get prescriptionDurationMonths => 'month(s)';

  @override
  String get prescriptionImagesTitle => 'Photos';

  @override
  String get prescriptionSendToPharmacy => 'Send to pharmacy';

  @override
  String get prescriptionSent => 'Prescription sent to the pharmacy.';

  @override
  String get prescriptionFulfillmentDelivery => 'Delivery';

  @override
  String get prescriptionFulfillmentPickup => 'Pickup';

  @override
  String get prescriptionDeliveryAddressHint => 'Delivery address';

  @override
  String get prescriptionCancel => 'Cancel prescription';

  @override
  String get prescriptionCancelConfirm => 'Cancel this prescription?';

  @override
  String get prescriptionCancelled => 'Prescription cancelled.';

  @override
  String get prescriptionScheduleReminders => 'Schedule reminders';

  @override
  String get prescriptionRemindersLabel => 'reminders scheduled';

  @override
  String get prescriptionShareWithDoctor => 'Share with another doctor';

  @override
  String get prescriptionShared => 'Prescription shared.';

  @override
  String get prescriptionSendPickPharmacyTitle => 'Choose a pharmacy';

  @override
  String get prescriptionSharePickDoctorTitle => 'Choose a doctor';

  @override
  String get prescriptionSupersededLabel => 'Superseded by a revision';

  @override
  String get prescriptionRemovePhotoConfirm => 'Remove this photo?';

  @override
  String get offersTitle => 'Offers';

  @override
  String get offersEmpty => 'No offers right now.';

  @override
  String get offersAllCategories => 'All';

  @override
  String get offersOpenNow => 'Open now';

  @override
  String get offersSearchHint => 'Search offers...';

  @override
  String get offerSortBoosted => 'Featured';

  @override
  String get offerSortLatest => 'Latest';

  @override
  String get offerSortLowestPrice => 'Lowest price';

  @override
  String get offerFollowBusiness => 'Follow this seller';

  @override
  String get offerUnfollowBusiness => 'Unfollow';

  @override
  String get offerFollowed =>
      'You\'ll be notified about this seller\'s offers.';

  @override
  String get offerUnfollowed => 'Unfollowed.';

  @override
  String get myOfferFollowsTitle => 'Followed sellers';

  @override
  String get myOfferFollowsEmpty => 'You\'re not following any sellers yet.';

  @override
  String get offerAvailableQuantityLabel => 'Available';

  @override
  String get offerEndsAtLabel => 'Ends';

  @override
  String get disputesTitle => 'My disputes';

  @override
  String get disputesEmpty => 'No disputes.';

  @override
  String get disputeStatusOpen => 'Open';

  @override
  String get disputeStatusMutualResolution => 'Settlement window';

  @override
  String get disputeStatusUnderReview => 'Under arbitration';

  @override
  String get disputeStatusResolved => 'Resolved';

  @override
  String get disputeStatusClosed => 'Closed';

  @override
  String get disputeStatusCancelled => 'Cancelled';

  @override
  String get disputeStatusExpired => 'Expired';

  @override
  String get disputeRoleOpener => 'You opened this';

  @override
  String get disputeRoleRespondent => 'Opened against you';

  @override
  String get disputeReasonNotDelivered => 'Not delivered';

  @override
  String get disputeReasonNotAsDescribed => 'Not as described';

  @override
  String get disputeReasonQuality => 'Quality issue';

  @override
  String get disputeReasonLate => 'Late';

  @override
  String get disputeReasonCancelledByBusiness => 'Cancelled by the business';

  @override
  String get disputeReasonNoShow => 'No-show';

  @override
  String get disputeReasonOvercharged => 'Overcharged';

  @override
  String get disputeReasonDamage => 'Damage';

  @override
  String get disputeReasonOther => 'Other';

  @override
  String get disputeOpenTitle => 'Report a problem';

  @override
  String get disputeReasonLabel => 'Reason';

  @override
  String get disputeDetailsHint => 'Additional details (optional)';

  @override
  String get disputeOpened => 'Dispute opened.';

  @override
  String get disputeCooperate => 'I\'m engaging with the settlement';

  @override
  String get disputeCooperated => 'Marked as engaging.';

  @override
  String get disputeRequestArbitration => 'Request arbitration';

  @override
  String get disputeArbitrationRequested => 'Arbitration requested.';

  @override
  String get disputeArbitrationFeeLabel => 'Session fee';

  @override
  String get disputeArbitrationBalanceLabel => 'Your balance';

  @override
  String get disputeAgreeSettlement => 'We agreed — end the dispute';

  @override
  String get disputeWithdrawSettlement => 'Withdraw agreement';

  @override
  String get disputeSettlementAgreed => 'Agreement recorded.';

  @override
  String get disputeSettlementWithdrawn => 'Agreement withdrawn.';

  @override
  String get disputeSettlementCompleteLabel =>
      'Both sides agreed — the dispute is settled.';

  @override
  String get disputeSettlementWaitingLabel =>
      'Waiting for the other side to agree.';

  @override
  String get disputeCounterpartyLabel => 'Other party';

  @override
  String get disputeCooperationTitle => 'Cooperation';

  @override
  String get disputeCooperationClientLabel => 'Client';

  @override
  String get disputeCooperationBusinessLabel => 'Business';

  @override
  String get disputeCooperationPending => 'Not yet';

  @override
  String get disputeMyObligationsTitle => 'What I owe on this dispute';

  @override
  String get disputeObligationsTitle => 'Dispute obligations';

  @override
  String get disputeSettleObligations => 'Settle from wallet';

  @override
  String get disputeObligationSettled => 'Settled.';

  @override
  String get disputeObligationsBlockedNotice =>
      'You have unpaid dispute obligations blocking new operations.';

  @override
  String get disputeOwedByMeTitle => 'I owe';

  @override
  String get disputeOwedToMeTitle => 'Owed to me';

  @override
  String get disputeObligationsEmpty => 'Nothing outstanding.';

  @override
  String get disputeClosePurgeAction => 'Delete this conversation';

  @override
  String get disputeClosurePurgeConfirm =>
      'Delete this conversation for good? Only the ruling record stays.';

  @override
  String get disputeClosurePurged => 'Requested.';

  @override
  String get disputeRoomTitle => 'Dispute room';

  @override
  String get disputeConductTitle => 'Room rules';

  @override
  String get disputeConductAccept => 'I agree';

  @override
  String get disputeConductDecline => 'I don\'t agree';

  @override
  String get disputeRoomLocked => 'This room is closed.';

  @override
  String get disputeRoomPurgedNotice => 'This conversation has been deleted.';

  @override
  String get disputeSettlementPaymentsTitle => 'Off-app payment';

  @override
  String get disputeProposePayment => 'Propose a payment';

  @override
  String get disputePayerLabel => 'Who pays';

  @override
  String get disputePayerClient => 'Client';

  @override
  String get disputePayerBusiness => 'Business';

  @override
  String get disputeAmountHint => 'Amount';

  @override
  String get disputeMethodHint => 'Method (optional)';

  @override
  String get disputeNoteHint => 'Note (optional)';

  @override
  String get disputePropose => 'Propose';

  @override
  String get disputeAccept => 'Accept';

  @override
  String get disputeReject => 'Reject';

  @override
  String get disputeConfirmReceived => 'Confirm received';

  @override
  String get disputeWithdraw => 'Withdraw';

  @override
  String get disputeNoSettlementPayments => 'No payment proposals yet.';

  @override
  String get disputeHistoryTitle => 'History';

  @override
  String get addressesTitle => 'My addresses';

  @override
  String get addressesEmpty => 'No saved addresses yet.';

  @override
  String get addressAddTitle => 'Add address';

  @override
  String get addressEditTitle => 'Edit address';

  @override
  String get addressLineHint => 'Street, building, floor...';

  @override
  String get addressZipHint => 'Zip code (optional)';

  @override
  String get addressMakePrimary => 'Make this the primary address';

  @override
  String get addressDeleteConfirm => 'Delete this address?';

  @override
  String get addressPickTitle => 'Choose a delivery address';

  @override
  String get addressUseNewLabel => 'Type a different address';

  @override
  String get commentsTitle => 'Comments';

  @override
  String get commentsEmpty => 'No comments yet.';

  @override
  String get commentComposeHint => 'Add a comment...';

  @override
  String get commentReplyHint => 'Write a reply...';

  @override
  String get commentPrivateToggle => 'Only visible to the post\'s owner';

  @override
  String get commentPrivateBadge => 'Private';

  @override
  String get commentRepliesLabel => 'replies';

  @override
  String get commentViewReplies => 'View replies';

  @override
  String get commentHideReplies => 'Hide replies';

  @override
  String get commentReplyAction => 'Reply';

  @override
  String get commentEditAction => 'Edit';

  @override
  String get commentDeleteAction => 'Delete';

  @override
  String get commentDeleteConfirm => 'Delete this comment?';

  @override
  String get commentSend => 'Post';

  @override
  String get guaranteeTitle => 'My guarantee';

  @override
  String get guaranteeNoneYet => 'You haven\'t activated a guarantee yet.';

  @override
  String get guaranteeLockedAmountLabel => 'Locked';

  @override
  String get guaranteeCoverageLabel => 'Coverage';

  @override
  String get guaranteeAvailableCoverageLabel => 'Available coverage';

  @override
  String get guaranteeUsedCoverageLabel => 'Used';

  @override
  String get guaranteeTrustScoreLabel => 'Trust score';

  @override
  String get guaranteeCompletedOpsLabel => 'Completed operations';

  @override
  String get guaranteeLevelsTitle => 'Coverage levels';

  @override
  String get guaranteeActivate => 'Activate';

  @override
  String get guaranteeUpgrade => 'Upgrade';

  @override
  String get guaranteeCurrentLevelBadge => 'Current';

  @override
  String get guaranteeAutoActivate => 'Activate best available level';

  @override
  String get guaranteeUnlock => 'Unlock guarantee';

  @override
  String get guaranteeUnlockConfirm =>
      'Unlock your guarantee and return the locked amount to your wallet?';

  @override
  String get guaranteeUnlocked => 'Guarantee unlocked.';

  @override
  String get guaranteeActivated => 'Guarantee activated.';

  @override
  String get guaranteeNoChange =>
      'No change — your balance doesn\'t yet cover a higher level.';

  @override
  String get guaranteeTransactionsTitle => 'Transactions';

  @override
  String get guaranteeTransactionsEmpty => 'No transactions yet.';

  @override
  String get guaranteeRequiredLockedLabel => 'Requires';

  @override
  String get jobsTitle => 'Jobs';

  @override
  String get jobsEmpty => 'No open jobs right now.';

  @override
  String get jobsSearchHint => 'Search jobs...';

  @override
  String get jobsAllCategories => 'All fields';

  @override
  String get jobSalaryLabel => 'Salary';

  @override
  String get jobRequirementsLabel => 'Requirements';

  @override
  String get jobInterviewLabel => 'Interview';

  @override
  String get jobApplicantsLabel => 'applicants';

  @override
  String get jobApply => 'Apply';

  @override
  String get jobApplied => 'Application sent.';

  @override
  String get jobFollowsTitle => 'Job alerts';

  @override
  String get jobFollowsEmpty => 'You\'re not following any fields yet.';

  @override
  String get jobFollowAdd => 'Follow a field';

  @override
  String get jobFollowPickTitle => 'Choose a field to follow';

  @override
  String get jobUnfollow => 'Unfollow';

  @override
  String get jobFollowed => 'Following this field.';

  @override
  String get agendaLocalRemindersTitle => 'Reminders on this phone';

  @override
  String get agendaLocalRemindersHint =>
      'This phone shows your task and medicine reminders itself, with the words you wrote — they never leave it.';

  @override
  String agendaReminderBody(String time) {
    return 'At $time';
  }

  @override
  String get agendaSettingsTitle => 'Reminders & meal times';

  @override
  String get agendaSettingsMealTimesSection => 'Meal times';

  @override
  String get agendaSettingsMealTimesHint =>
      'Medication doses tied to meals are scheduled around these.';

  @override
  String get agendaSettingsBreakfast => 'Breakfast';

  @override
  String get agendaSettingsLunch => 'Lunch';

  @override
  String get agendaSettingsDinner => 'Dinner';

  @override
  String get agendaSettingsMealTimesSaved => 'Meal times saved.';

  @override
  String get agendaSettingsRemindersSection => 'Reminders';

  @override
  String get agendaSettingsRemindersHint =>
      'How long before an appointment or an agenda item you want to be notified.';

  @override
  String get agendaSettingsFirstLead => 'First appointment reminder';

  @override
  String get agendaSettingsSecondLead => 'Second appointment reminder';

  @override
  String get agendaSettingsSecondLeadNone => 'Off';

  @override
  String get agendaSettingsAgendaLead => 'Agenda item reminder';

  @override
  String get agendaSettingsAgendaLeadNone => 'At the time';

  @override
  String get agendaSettingsRemindersSaved => 'Reminder preferences saved.';

  @override
  String get agendaSettingsSecondLeadError =>
      'The second reminder must be closer than the first.';

  @override
  String durationMinutes(int count) {
    return '${count}m';
  }

  @override
  String durationHours(int count) {
    return '${count}h';
  }

  @override
  String durationDays(int count) {
    return '${count}d';
  }

  @override
  String get depositsTitle => 'Escrow deposits';

  @override
  String get depositsEmpty => 'No deposits.';

  @override
  String get depositsAllStatuses => 'All';

  @override
  String get depositStatusFrozen => 'Frozen';

  @override
  String get depositStatusInProgress => 'In progress';

  @override
  String get depositStatusReleased => 'Released';

  @override
  String get depositStatusRefunded => 'Refunded';

  @override
  String get depositStatusSplit => 'Split';

  @override
  String get depositRoleClient => 'You paid';

  @override
  String get depositRoleBusiness => 'You\'re holding';

  @override
  String get depositMyAmount => 'My share';

  @override
  String get depositTotalAmount => 'Total amount';

  @override
  String get depositClientShare => 'Client share';

  @override
  String get depositBusinessShare => 'Business share';

  @override
  String get depositCounterparty => 'Counterparty';

  @override
  String get depositCreatedAt => 'Created';

  @override
  String get depositReleasedAt => 'Released';

  @override
  String get depositRefundedAt => 'Refunded';

  @override
  String get depositBookingLabel => 'Booking';

  @override
  String get myRatingTitle => 'My Rating';

  @override
  String get myRatingObjectiveSection => 'Operation record';

  @override
  String get myRatingTotalOperations => 'Total operations';

  @override
  String get myRatingSuccessRate => 'Success rate';

  @override
  String get myRatingCancelRate => 'Cancellation rate';

  @override
  String get myRatingDisputeRate => 'Dispute rate';

  @override
  String get myRatingFaultRate => 'Ruled against you';

  @override
  String get myRatingVindicationRate => 'Ruled in your favor';

  @override
  String get myRatingReviewsSection => 'Reviews';

  @override
  String get myRatingStarsAverage => 'Average rating';

  @override
  String myRatingReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '1 review',
      zero: 'No reviews yet',
    );
    return '$_temp0';
  }

  @override
  String get myRatingConsentSection => 'Service fees';

  @override
  String get myRatingConsentEnabledLabel =>
      'Your rating is open — service fees apply to your own operations.';

  @override
  String get myRatingConsentDisabledLabel =>
      'Your rating is closed — transacting is free, but your rating and reviews stay hidden until you open it.';

  @override
  String get myRatingEnableButton => 'Open my rating';

  @override
  String get myRatingEnableConfirmTitle => 'Open your rating?';

  @override
  String get myRatingEnableConfirmBody =>
      'This makes your operations visible with a rating and reviews, and service fees will start applying to your own operations from now on. You can close it again later.';

  @override
  String get myRatingEnableConfirm => 'Open it';

  @override
  String get myRatingEnabledMessage =>
      'Your rating is now open. Service fees will apply to your operations from now on.';

  @override
  String get myRatingDisableButton => 'Close my rating';

  @override
  String get myRatingDisableConfirmTitle => 'Close your rating?';

  @override
  String get myRatingDisableConfirmBody =>
      'Your operation record and reviews will be hidden again, and service fees will stop applying to your new operations.';

  @override
  String get myRatingDisableConfirm => 'Close it';

  @override
  String get myRatingDisabledMessage => 'Your rating is now closed.';

  @override
  String get myRatingHiddenHint => 'Hidden while your rating is closed.';

  @override
  String get merchantAccountTitle => 'Merchant account';

  @override
  String get merchantAccountHint =>
      'A dedicated Fawry sub-account settles your payments directly to you instead of the platform\'s shared account.';

  @override
  String get merchantAccountStatusActive => 'Active';

  @override
  String get merchantAccountStatusPending => 'Application under review';

  @override
  String get merchantAccountStatusRejected => 'Application rejected';

  @override
  String get merchantAccountStatusNone => 'Not set up yet';

  @override
  String get merchantAccountRoutingDisabledNote =>
      'Direct routing isn\'t live platform-wide yet — applications are still reviewed and queued.';

  @override
  String get merchantAccountNoteHint => 'Note for the review team (optional)';

  @override
  String get merchantAccountApplyButton => 'Apply for a merchant account';

  @override
  String get merchantAccountApplied =>
      'Your application was submitted and will be reviewed.';

  @override
  String get menuManagementTitle => 'My Menu';

  @override
  String get marketCatalogTitle => 'Bulk Pricing';

  @override
  String get marketCatalogNotApplicable =>
      'This screen is for ready-goods merchants (supermarkets, greengrocers, etc.).';

  @override
  String get marketCatalogEmpty =>
      'No sections available for your business category.';

  @override
  String marketCatalogFilledOf(int filled, int total) {
    return '$filled of $total priced';
  }

  @override
  String get marketCatalogSave => 'Save';

  @override
  String marketCatalogSaved(int saved) {
    String _temp0 = intl.Intl.pluralLogic(
      saved,
      locale: localeName,
      other: 'Saved $saved items',
      one: 'Saved 1 item',
      zero: 'Nothing changed',
    );
    return '$_temp0';
  }

  @override
  String marketCatalogCleared(int cleared) {
    return ', and cleared $cleared emptied items';
  }

  @override
  String get marketCatalogQuantity => 'Quantity';

  @override
  String get marketCatalogSupplyPrice => 'Supply price';

  @override
  String get marketCatalogSalePrice => 'Sale price';

  @override
  String get marketCatalogBrand => 'Brand / supplier';

  @override
  String get marketCatalogUnit => 'Unit';

  @override
  String marketCatalogDefaultMargin(String margin) {
    return 'A default margin of $margin% is on — enter only the supply price and the sale price is computed for you.';
  }

  @override
  String get marketCatalogLowStockSettings => 'Low-stock alert';

  @override
  String get marketCatalogLowStockSettingsHint =>
      'When any item\'s quantity reaches this number or lower, you\'ll get an alert to reorder from your supplier. The number applies to every item regardless of its own sale unit (kg, pack...). Leave it blank to alert only once an item is fully out.';

  @override
  String get marketCatalogLowStockThreshold => 'Alert when quantity reaches';

  @override
  String get marketCatalogLowStockNoAlert => 'No early alert — only at zero';

  @override
  String get marketCatalogLowStockSaved => 'Alert setting saved.';

  @override
  String get menuSectionsTitle => 'Menu Sections';

  @override
  String get menuSectionsEmpty => 'No sections yet.';

  @override
  String get menuSectionAdd => 'Add section';

  @override
  String get menuSectionEditTitle => 'Edit section';

  @override
  String get menuSectionAddTitle => 'Add section';

  @override
  String get menuSectionDeleteConfirm =>
      'Delete this section? Items in it keep their data but lose their section.';

  @override
  String get menuItemsTitle => 'Menu Items';

  @override
  String get menuItemsEmpty => 'No items yet.';

  @override
  String get menuItemsSearchHint => 'Search items...';

  @override
  String get menuItemsAllSections => 'All sections';

  @override
  String get menuItemsAddBrandRow => 'Add brand';

  @override
  String get menuItemsUnbranchedSection => 'Other items';

  @override
  String menuItemsQuantityShort(int quantity) {
    return 'Available: $quantity';
  }

  @override
  String get menuItemsDisplayModeLabel => 'Display';

  @override
  String get menuItemsDisplayModeList => 'List';

  @override
  String get menuItemsDisplayModeGrid => 'Grid';

  @override
  String get menuItemsManageTypesAction => 'Manage types';

  @override
  String get menuItemsManageSectionsAction => 'Manage sections';

  @override
  String get menuTypeSelectionSubtitle =>
      'Pick the types your business carries — you can add more from here any time.';

  @override
  String menuTypeSelectionContinue(int count) {
    return 'Continue ($count)';
  }

  @override
  String get menuTypeSelectionSaved => 'Types updated';

  @override
  String get menuItemAdd => 'Add item';

  @override
  String get menuItemsAddPrice => 'Add price';

  @override
  String get menuItemEditTitle => 'Edit item';

  @override
  String get menuItemAddTitle => 'Add item';

  @override
  String get menuItemDeleteConfirm => 'Delete this item?';

  @override
  String get techPricingTitle => 'Pricing & Details';

  @override
  String get techPricingProductLabel => 'Product';

  @override
  String get techPricingPickProduct => 'Pick a real product';

  @override
  String get techPricingSearchHint => 'Search for a model...';

  @override
  String get techPricingNoResults => 'No results';

  @override
  String get techPricingConditionLabel => 'Condition';

  @override
  String get techPricingAddAnother => 'Add another model';

  @override
  String get techPricingAddProduct => 'Add product';

  @override
  String get techPricingUnitDetails => 'This unit\'s details';

  @override
  String get techPricingItemDetails => 'Item details';

  @override
  String get menuSearchTitle => 'Search & compare';

  @override
  String get menuSearchHint => 'Search by name or model…';

  @override
  String get menuSearchFilters => 'Filters';

  @override
  String menuSearchFiltersCount(int n) {
    return 'Filters ($n)';
  }

  @override
  String get menuSearchApply => 'Show results';

  @override
  String get menuSearchReset => 'Clear all';

  @override
  String get menuSearchFrom => 'From';

  @override
  String get menuSearchTo => 'To';

  @override
  String menuSearchRangeHint(String min, String max) {
    return '$min – $max';
  }

  @override
  String menuSearchResults(int n) {
    return '$n results';
  }

  @override
  String get menuSearchEmpty => 'Nothing matches these specs.';

  @override
  String get menuSearchNoKinds => 'No products with specs are on sale yet.';

  @override
  String get menuSearchPickKind => 'Pick a product type to see its filters';

  @override
  String get menuSearchAllKinds => 'All';

  @override
  String get menuSearchSortPriceAsc => 'Cheapest first';

  @override
  String get menuSearchSortPriceDesc => 'Most expensive first';

  @override
  String get menuSearchSortNewest => 'Newest';

  @override
  String get menuSearchCompare => 'Compare prices';

  @override
  String get menuCompareTitle => 'Price comparison';

  @override
  String menuCompareShops(int n) {
    return 'Sold by $n shops';
  }

  @override
  String get menuCompareCheapest => 'Cheapest';

  @override
  String menuCompareMore(String amount) {
    return '+$amount over the cheapest';
  }

  @override
  String get menuCompareOpenShop => 'Open shop';

  @override
  String techPricingFieldNotNumber(String field) {
    return '\"$field\" must be a number';
  }

  @override
  String get techPricingAllBrands => 'All';

  @override
  String get techPricingPending => 'Under review';

  @override
  String get techPricingNotFound => 'Model not listed? Add it yourself';

  @override
  String get techPricingNewModelTitle => 'Add a new model';

  @override
  String get techPricingNewModelNote =>
      'It shows in your store right away, and to other merchants after admin review.';

  @override
  String get techPricingBrandLabel => 'Brand';

  @override
  String get techPricingOtherBrand => 'Other brand';

  @override
  String get techPricingBrandNameHint => 'Brand name';

  @override
  String get techPricingSeriesLabel => 'Series (optional)';

  @override
  String get techPricingModelLabel => 'Model name';

  @override
  String get techPricingProcessorLabel => 'Processor';

  @override
  String get techPricingRamLabel => 'RAM (GB)';

  @override
  String get techPricingStorageLabel => 'Storage';

  @override
  String get techPricingScreenLabel => 'Screen size (inch)';

  @override
  String get techPricingOsLabel => 'Operating system';

  @override
  String get techPricingModelRequired =>
      'Enter the model name and pick a brand';

  @override
  String get techDetailTotal => 'Total';

  @override
  String get techPricingPhotosLabel => 'Product photos';

  @override
  String get techPricingTakePhoto => 'Take a photo';

  @override
  String get techPricingFromGallery => 'From gallery';

  @override
  String get techPricingUsedCameraOnly =>
      'A used item is photographed live with the camera — a real, unedited shot of this very unit.';

  @override
  String get techPricingRearCameraLabel => 'Rear camera (MP)';

  @override
  String get techPricingFrontCameraLabel => 'Front camera (MP)';

  @override
  String get techPricingBatteryLabel => 'Battery (mAh)';

  @override
  String get menuFilterAllBrands => 'All brands';

  @override
  String get menuBundlesTitle => 'Menu Bundles';

  @override
  String get menuBundlesEmpty => 'No bundles yet.';

  @override
  String get menuBundleAdd => 'Add bundle';

  @override
  String get menuBundleEditTitle => 'Edit bundle';

  @override
  String get menuBundleDeleteConfirm => 'Delete this bundle?';

  @override
  String get menuBundleFormError =>
      'Enter a name, a price, and pick at least 2 components.';

  @override
  String get menuBundlePricingMode => 'Pricing';

  @override
  String get menuBundlePricingFixed => 'Flat price';

  @override
  String get menuBundlePricingDiscountPercent => '% off components';

  @override
  String get menuBundlePricingDiscountFixed => 'Amount off components';

  @override
  String get menuBundleFixedPrice => 'Bundle price';

  @override
  String get menuBundleDiscountPercent => 'Discount %';

  @override
  String get menuBundleDiscountFixed => 'Discount amount';

  @override
  String get menuBundleComponents => 'Components';

  @override
  String get menuBundleComponentsHint =>
      'Pick at least 2 menu items — the composition is fixed, the customer can\'t swap them.';

  @override
  String get menuBundleComponentsSubtotal => 'Components total';

  @override
  String get menuBundleFinalPrice => 'Bundle price';

  @override
  String get menuItemNameArHint => 'Name (Arabic)';

  @override
  String get menuItemNameEnHint => 'Name (English, optional)';

  @override
  String get menuItemDescriptionArHint => 'Description (Arabic, optional)';

  @override
  String get menuItemDescriptionEnHint => 'Description (English, optional)';

  @override
  String get menuItemSectionLabel => 'Section';

  @override
  String get menuItemNoSection => 'No section';

  @override
  String get menuItemBranchLabel => 'Type';

  @override
  String get menuItemNoBranch => '— Not set —';

  @override
  String get menuItemNotSpecified => 'Not specified';

  @override
  String get menuItemAvailableQuantityHint => 'Available quantity (optional)';

  @override
  String get menuItemBasePriceHint => 'Price';

  @override
  String get menuItemSaleUnitLabel => 'Sold by';

  @override
  String get menuItemSaleUnitByItem => 'By the item';

  @override
  String get menuItemSupplyPriceHint => 'Cost price (optional)';

  @override
  String get menuItemSupplyPriceHelper =>
      'For your own records only — never shown to the customer';

  @override
  String get menuItemBrandNameHint => 'Brand (optional)';

  @override
  String get menuItemBrandLabel => 'Brand';

  @override
  String get menuItemNoBrand => '— Not set —';

  @override
  String get menuItemSortOrderHint => 'Sort order';

  @override
  String get menuItemActiveLabel => 'Active';

  @override
  String get itemPhotoSetCover => 'Show this photo on the card';

  @override
  String get itemPhotoIsCover => 'This is the card photo';

  @override
  String get itemPhotoCoverBadge => 'Card photo';

  @override
  String get itemPhotoCropAdjust => 'Adjust the part that shows';

  @override
  String get itemPhotoCropTitle => 'The part of the photo that shows';

  @override
  String get itemPhotoCropHint =>
      'Drag the photo to put the product in the middle, and zoom in to leave out the empty part. This is how it will look on the card.';

  @override
  String get itemPhotoCropListPreview => 'In a list';

  @override
  String get itemPhotoCropReset => 'Whole photo';

  @override
  String get menuItemImagesSection => 'Photos';

  @override
  String get menuItemAddImage => 'Add photo';

  @override
  String get menuItemVariantsSection => 'Variants';

  @override
  String get menuItemAddVariant => 'Add variant';

  @override
  String get menuItemEditVariant => 'Edit variant';

  @override
  String get menuItemVariantTypeHint => 'Type (e.g. size)';

  @override
  String get menuItemVariantPriceHint => 'Price (absolute, optional)';

  @override
  String get menuItemVariantPriceDeltaHint => 'Price add-on (optional)';

  @override
  String get menuItemVariantDefaultLabel => 'Default choice';

  @override
  String get menuItemExtraGroupsSection => 'Extra groups';

  @override
  String get menuItemAddExtraGroup => 'Add group';

  @override
  String get menuItemEditExtraGroup => 'Edit group';

  @override
  String get menuItemExtraGroupNameHint => 'Group name (e.g. Sauces)';

  @override
  String get menuItemExtraGroupSelectionLabel => 'Selection type';

  @override
  String get menuItemExtraGroupSelectionSingle =>
      'Single choice (radio button)';

  @override
  String get menuItemExtraGroupSelectionMultiple =>
      'Multiple choice (checkbox)';

  @override
  String get menuItemExtraGroupNone => 'No group';

  @override
  String get menuItemExtrasSection => 'Extras';

  @override
  String get menuItemAddExtra => 'Add extra';

  @override
  String get menuItemEditExtra => 'Edit extra';

  @override
  String get menuItemExtraGroupHint => 'Group (optional)';

  @override
  String get menuItemExtraPriceHint => 'Price';

  @override
  String get menuItemExtraMaxQtyHint => 'Max quantity';

  @override
  String get menuItemDeleteRowConfirm => 'Delete this?';

  @override
  String get menuNameRequired => 'Enter a name.';

  @override
  String get menuPriceRequired => 'Enter a valid price.';

  @override
  String get retailVariantGroupsTitle => 'Product variants';

  @override
  String get retailVariantGroupsEmpty =>
      'No variant groups yet. Group one product\'s colors or sizes instead of listing them separately.';

  @override
  String get retailVariantGroupsDeleteConfirm =>
      'Delete this product? The variants themselves (listings) stay on your shelf, ungrouped.';

  @override
  String get retailVariantGroupsNewTitle => 'New product with variants';

  @override
  String get retailVariantGroupsEditTitle => 'Edit variants';

  @override
  String get retailVariantGroupsNameLabel =>
      'Product name (e.g. Classic Shirt)';

  @override
  String get retailVariantGroupsOptionsTitle => 'Variants';

  @override
  String get retailVariantGroupsLabelHint => 'Variant (e.g. Blue - M)';

  @override
  String get retailVariantGroupsAddOption => 'Add a variant from my products';

  @override
  String get retailVariantGroupsNeedTwo =>
      'Enter a name and pick at least two variants.';

  @override
  String get retailVariantGroupsPickListingTitle =>
      'Choose one of your products';

  @override
  String get retailVariantGroupsSearchHint => 'Search by name';

  @override
  String get retailStorefrontChooseVariantTitle => 'Choose a variant';

  @override
  String get retailListingsTitle => 'My Products';

  @override
  String get retailListingsProductsTab => 'Products';

  @override
  String get retailListingsVisibilityTab => 'Visibility';

  @override
  String get retailListingsEmpty => 'No products listed yet.';

  @override
  String get retailListingsSearchHint => 'Search my products...';

  @override
  String get retailListingAdd => 'Add product';

  @override
  String get retailListingPickTitle => 'Choose a product';

  @override
  String get retailListingLookupHint => 'Search the catalog...';

  @override
  String get retailListingLookupEmpty => 'No matching products.';

  @override
  String get retailListingEditTitle => 'Edit listing';

  @override
  String get retailListingPriceHint => 'Price';

  @override
  String get retailListingStockHint => 'Stock (optional)';

  @override
  String retailListingAvailableQtyBadge(String qty) {
    return 'Available: $qty';
  }

  @override
  String get retailListingMinOrderQtyLabel =>
      'Minimum order quantity (optional)';

  @override
  String get retailListingMinOrderQtyHint =>
      'e.g. 20 — wholesale buyers must order at least this much';

  @override
  String retailListingMinOrderQtyBadge(String qty) {
    return 'Min $qty';
  }

  @override
  String get retailListingMaxOrderQtyLabel =>
      'Maximum order quantity (optional)';

  @override
  String get retailListingMaxOrderQtyHint =>
      'e.g. 100 — a single order can\'t take more than this, so one buyer can\'t clear your whole shelf';

  @override
  String retailListingMaxOrderQtyBadge(String qty) {
    return 'Max $qty';
  }

  @override
  String get retailListingMaxBelowMinError =>
      'The maximum must be greater than or equal to the minimum.';

  @override
  String get retailListingUnitLabel => 'Unit (optional)';

  @override
  String get retailListingUnitHint => 'Type your own unit';

  @override
  String get retailListingUnitOther => 'Other...';

  @override
  String get retailExtrasTitle => 'Product add-ons';

  @override
  String get retailExtrasHint =>
      'e.g. 1-year warranty, 2-year warranty, installation';

  @override
  String get retailExtrasName => 'Add-on name';

  @override
  String get retailExtrasPrice => 'Price';

  @override
  String get retailExtrasGroup => 'Group (optional, e.g. Warranty)';

  @override
  String get retailExtrasSingle => 'Pick only one from the group';

  @override
  String get retailExtrasAdd => 'Add item';

  @override
  String get retailVariantConditionLabel => 'Condition';

  @override
  String get retailVariantPaymentLabel => 'Payment';

  @override
  String get retailVariantNone => 'None';

  @override
  String get retailVariantDescriptionHint =>
      'Description of this price (optional)';

  @override
  String get retailVariantAddAnotherPrice =>
      'Add another price for this product';

  @override
  String get retailVariantFilterTitle => 'Filter prices';

  @override
  String get retailVariantFilterClear => 'Show all';

  @override
  String get retailListingSkuHint => 'SKU (optional)';

  @override
  String get retailListingActiveLabel => 'Active';

  @override
  String get retailListingDeleteConfirm =>
      'Remove this product from your listings?';

  @override
  String get retailPriceRequired => 'Enter a valid price.';

  @override
  String get retailListingGovernoratesLabel => 'Governorates';

  @override
  String get retailListingGovernoratesAllHint =>
      'All governorates — no geographic restriction';

  @override
  String retailListingGovernoratesSelectedHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count governorates selected',
      one: '1 governorate selected',
    );
    return '$_temp0';
  }

  @override
  String get retailListingChooseGovernorates => 'Choose governorates';

  @override
  String get retailListingGovernoratesPickerTitle => 'Choose governorates';

  @override
  String get retailListingGovernoratesSelectAll => 'Select all';

  @override
  String get retailListingGovernoratesClearAll => 'Clear';

  @override
  String get retailListingVisibilityLabel => 'Who can see this';

  @override
  String get retailListingVisibilityPublic => 'Everyone';

  @override
  String get retailListingVisibilityPublicHint =>
      'Shown to every customer, like the rest of your products.';

  @override
  String get retailListingVisibilityRestricted => 'Wholesale sale';

  @override
  String get retailListingVisibilityRestrictedHint =>
      'Wholesale sale: hidden from everyone except the shop types or businesses you pick below — a price only they can even see exists.';

  @override
  String get retailListingRestrictedBadge => 'Wholesale';

  @override
  String get retailListingAudienceShopTypesLabel => 'Shop types';

  @override
  String get retailListingAudienceBusinessesLabel => 'Specific businesses';

  @override
  String get retailListingAddShopType => 'Add a shop type';

  @override
  String get retailListingAddBusiness => 'Add a business';

  @override
  String get retailListingAudienceEmpty => 'None chosen yet.';

  @override
  String get retailListingAudienceRequired =>
      'Choose at least one shop type or business.';

  @override
  String get retailListingBusinessSearchTitle => 'Choose a business';

  @override
  String get retailListingBusinessSearchHint => 'Search by business name...';

  @override
  String get retailListingBusinessSearchEmpty => 'No matching businesses.';

  @override
  String get retailListingsFeedEmpty => 'No products yet.';

  @override
  String retailStorefrontMinQtyLabel(String qty) {
    return 'Min order: $qty';
  }

  @override
  String retailStorefrontMaxQtyLabel(String qty) {
    return 'Max order: $qty';
  }

  @override
  String retailStorefrontQtyBelowMin(String min) {
    return 'Minimum order is $min';
  }

  @override
  String retailStorefrontQtyOutOfRange(String min, String max) {
    return 'Order between $min and $max';
  }

  @override
  String get retailStorefrontQuantityLabel => 'Quantity';

  @override
  String get retailStorefrontEmpty =>
      'This business has no products listed yet.';

  @override
  String get accountDeletionTitle => 'Delete my account';

  @override
  String accountDeletionHint(int days) {
    return 'You\'ll have $days days to change your mind — logging in again during that window restores everything exactly as it was.';
  }

  @override
  String get accountDeletionBlockersTitle =>
      'You can\'t delete your account right now';

  @override
  String get accountDeletionPasswordHint => 'Confirm your password';

  @override
  String get accountDeletionReasonHint => 'Reason (optional)';

  @override
  String get accountDeletionRequestButton => 'Delete my account';

  @override
  String get accountDeletionConfirmTitle => 'Delete your account?';

  @override
  String get accountDeletionConfirmBody =>
      'This signs you out everywhere right away. You can restore your account by logging in again within the grace period — after that it\'s gone for good.';

  @override
  String get accountDeletionConfirmButton => 'Delete it';

  @override
  String get accountDeletionRequested =>
      'Your account is scheduled for deletion. Log back in within the grace period to restore it.';

  @override
  String get restoreAccountTitle => 'Restore your account';

  @override
  String get restoreAccountHint =>
      'Enter the email and password of the account you deleted — this only works during its grace period.';

  @override
  String get restoreAccountButton => 'Restore account';

  @override
  String get restoreAccountLinkFromLogin => 'Deleted your account by mistake?';

  @override
  String get clinicManagementTitle => 'My Clinic';

  @override
  String get clinicQueueTab => 'Appointments';

  @override
  String get clinicSlotsTab => 'Slots';

  @override
  String get clinicQueueEmpty => 'No appointments.';

  @override
  String get clinicQueueAllStatuses => 'All';

  @override
  String get clinicActionConfirm => 'Confirm';

  @override
  String get clinicActionReject => 'Reject';

  @override
  String get clinicActionComplete => 'Complete';

  @override
  String get clinicActionNoShow => 'No-show';

  @override
  String get clinicActionReschedule => 'Reschedule';

  @override
  String get clinicRescheduleTitle => 'Reschedule appointment';

  @override
  String get clinicRescheduleConfirm => 'Save new time';

  @override
  String get clinicSlotsEmpty => 'No open slots.';

  @override
  String get clinicAddSlots => 'Add slots';

  @override
  String get clinicSlotsSpecificTab => 'Specific dates';

  @override
  String get clinicSlotsRecurringTab => 'Recurring weekly';

  @override
  String get clinicSlotAddDate => 'Add a date & time';

  @override
  String clinicSlotPendingCount(int count) {
    return '$count queued';
  }

  @override
  String get clinicPublishButton => 'Publish';

  @override
  String get clinicWeekdaysLabel => 'Days of the week';

  @override
  String get clinicStartTimeHint => 'From';

  @override
  String get clinicEndTimeHint => 'To';

  @override
  String get clinicIntervalHint => 'Interval (minutes)';

  @override
  String get clinicWeeksHint => 'Repeat for (weeks)';

  @override
  String get clinicGenerateButton => 'Generate';

  @override
  String clinicSlotsPublished(int created, int skipped) {
    String _temp0 = intl.Intl.pluralLogic(
      skipped,
      locale: localeName,
      other: ', $skipped skipped',
      zero: '',
    );
    return '$created slots published$_temp0.';
  }

  @override
  String get clinicSlotDeleteConfirm => 'Remove this slot?';

  @override
  String get clinicWeekday0 => 'Sun';

  @override
  String get clinicWeekday1 => 'Mon';

  @override
  String get clinicWeekday2 => 'Tue';

  @override
  String get clinicWeekday3 => 'Wed';

  @override
  String get clinicWeekday4 => 'Thu';

  @override
  String get clinicWeekday5 => 'Fri';

  @override
  String get clinicWeekday6 => 'Sat';

  @override
  String get clinicSelectWeekdaysError => 'Choose at least one day.';

  @override
  String get trainingTemplatesTitle => 'My Templates';

  @override
  String get trainingTemplatesEmpty => 'No templates yet.';

  @override
  String get trainingTemplateAdd => 'Add template';

  @override
  String get trainingTemplateAddTitle => 'Add template';

  @override
  String get trainingTemplateEditTitle => 'Edit template';

  @override
  String get trainingTemplateTitleHint => 'Title';

  @override
  String get trainingTemplateGoalHint => 'Goal (optional)';

  @override
  String get trainingTemplateNotesHint => 'Notes (optional)';

  @override
  String get trainingTemplateDeleteConfirm => 'Delete this template?';

  @override
  String get trainingTemplateExercisesSection => 'Exercises';

  @override
  String get trainingTemplateAddExercise => 'Add exercise';

  @override
  String get trainingTemplateMealsSection => 'Meals';

  @override
  String get trainingTemplateAddMeal => 'Add meal';

  @override
  String get trainingExerciseNameHint => 'Exercise name';

  @override
  String get trainingExerciseDayHint => 'Day (optional)';

  @override
  String get trainingExerciseDayAny => 'Any day';

  @override
  String get trainingExerciseSetsHint => 'Sets (optional)';

  @override
  String get trainingExerciseRepsHint => 'Reps (optional)';

  @override
  String get trainingExerciseRestHint => 'Rest, seconds (optional)';

  @override
  String get trainingMealTypeLabel => 'Meal type';

  @override
  String get trainingMealNameHint => 'Meal name';

  @override
  String get trainingMealCaloriesHint => 'Calories (optional)';

  @override
  String get trainingRemoveRowConfirm => 'Delete this?';

  @override
  String get businessPricesTitle => 'My Prices';

  @override
  String get businessPricesSubtitle => 'Price per type you offer — yours only.';

  @override
  String get businessPricesEmpty => 'No prices yet.';

  @override
  String get businessPricesAdd => 'Add price';

  @override
  String get businessPricesFilterAll => 'All services';

  @override
  String get businessPriceDeleteConfirm => 'Delete this price?';

  @override
  String get businessPriceEditTitle => 'Edit price';

  @override
  String get businessPriceAddTitle => 'Add price';

  @override
  String get priceFieldService => 'Service';

  @override
  String get priceFieldServiceHint => 'Choose a service';

  @override
  String get priceFieldItemType => 'Item type';

  @override
  String get priceFieldItemTypePickServiceFirst => 'Choose the service first';

  @override
  String get priceFieldItemTypeEmpty => 'No allowed types';

  @override
  String get priceFieldItemTypeHint => 'Choose the type';

  @override
  String get priceFieldPrice => 'Price';

  @override
  String get priceFieldCurrency => 'Currency';

  @override
  String get priceFieldActive => 'Active';

  @override
  String get priceChargeModeLabel => 'Charge mode';

  @override
  String get priceChargeModeStandard => 'Standard price';

  @override
  String get priceChargeModeFree => 'Free — food only is charged';

  @override
  String get priceChargeModeReservationFee => 'Fixed reservation fee';

  @override
  String get priceChargeModeMinimum => 'Minimum order amount';

  @override
  String get priceFieldChargeAmount => 'Fee / minimum amount';

  @override
  String get priceFieldDuration => 'Appointment duration (minutes)';

  @override
  String get priceFieldDurationHint => 'Leave blank if no fixed duration';

  @override
  String get priceDiscountEnable => 'Enable discount';

  @override
  String get priceFieldDiscountPercent => 'Discount %';

  @override
  String get priceVocabTitle => 'What are you selling here?';

  @override
  String get priceLineLabel => 'Type';

  @override
  String get priceLineNone => '— Not specified —';

  @override
  String get priceModifiersLabel => 'What sets it apart';

  @override
  String get priceModifierAdjustHint =>
      'Adds to the unit price — leave blank if descriptive only';

  @override
  String get priceNoServicesWarning =>
      'No services available for your business yet.';

  @override
  String get offerCompareButton => 'Compare prices';

  @override
  String get offerCompareTitle => 'Compare prices';

  @override
  String get offerCompareSortLabel => 'Sort by';

  @override
  String get offerCompareSortLowest => 'Lowest price';

  @override
  String get offerCompareSortHighest => 'Highest price';

  @override
  String get offerCompareSortBestValue => 'Best value';

  @override
  String get offerCompareSortRanking => 'Top ranked';

  @override
  String get offerCompareEmpty => 'No offers found for this item yet.';

  @override
  String get offerCompareBestPrice => 'Best price';

  @override
  String get offerCompareRefundable => 'Refundable';

  @override
  String get shopProductsTitle => 'Shop Products';

  @override
  String get shopProductsSearchHint => 'Search products...';

  @override
  String get shopProductsEmpty => 'No products found.';

  @override
  String get shopProductsFilterAllBrands => 'All brands';

  @override
  String get shopProductsSellersLabel => 'sellers';

  @override
  String get productOffersEmpty => 'No sellers currently.';

  @override
  String get productOffersStockLabel => 'Stock';

  @override
  String get clinicWritePrescription => 'Write prescription';

  @override
  String get clinicViewPrescription => 'View prescription';

  @override
  String get prescriptionsIssuedTitle => 'Issued Prescriptions';

  @override
  String get prescriptionsIssuedEmpty => 'No prescriptions issued yet.';

  @override
  String get prescriptionIssueTitle => 'Issue Prescription';

  @override
  String get prescriptionReviseTitle => 'Revise Prescription';

  @override
  String get prescriptionIssueSubmit => 'Issue prescription';

  @override
  String get prescriptionReviseSubmit => 'Save revision';

  @override
  String get prescriptionReviseAction => 'Revise';

  @override
  String get medicineSearchTitle => 'Add medicine';

  @override
  String get medicineSearchHint => 'Search drug name...';

  @override
  String get medicineNoResults => 'No matches. Add it as a new drug below.';

  @override
  String get medicineAddNew => 'Add new medicine';

  @override
  String get medicineAddTitle => 'New medicine';

  @override
  String get medicineNameHint => 'Drug name';

  @override
  String get medicineStrengthHint => 'Strength (optional)';

  @override
  String get medicineInstructionsHint => 'Instructions (optional)';

  @override
  String get medicineFrequencyLabel => 'Times per day';

  @override
  String get medicineFoodTimingLabel => 'Food timing';

  @override
  String get medicineTimeSlotsLabel => 'Time of day';

  @override
  String get medicineDurationLabel => 'Duration';

  @override
  String get medicineAddItem => 'Add medicine';

  @override
  String get medicineAtLeastOneItem => 'Add at least one medicine.';

  @override
  String get pharmacyQueueTitle => 'Pharmacy Queue';

  @override
  String get pharmacyQueueFilterAll => 'All';

  @override
  String get pharmacyQueueEmpty => 'No prescriptions sent to you yet.';

  @override
  String get pharmacyPriceAction => 'Price';

  @override
  String get pharmacyPrepareAction => 'Start preparing';

  @override
  String get pharmacyMarkReadyAction => 'Mark ready';

  @override
  String get pharmacyDispenseAction => 'Dispense';

  @override
  String get pharmacyRejectAction => 'Reject';

  @override
  String get pharmacyRejectConfirm =>
      'Reject this prescription and send it back to the patient?';

  @override
  String get pharmacyPreparingStarted => 'Preparation started.';

  @override
  String get pharmacyMarkedReady => 'Marked ready for the patient.';

  @override
  String get pharmacyDispensed => 'Dispensed.';

  @override
  String get pharmacyRejected => 'Rejected and returned to the patient.';

  @override
  String get pharmacyPriceTitle => 'Price this prescription';

  @override
  String get pharmacyUnitPriceLabel => 'Unit price';

  @override
  String get pharmacyBilledQuantityLabel => 'Quantity';

  @override
  String get pharmacyPriced => 'Prescription priced.';

  @override
  String get pharmacyCurrencyLabel => 'EGP';

  @override
  String get businessOffersTitle => 'My Offers';

  @override
  String get businessOfferAdd => 'Add offer';

  @override
  String get businessOffersEmpty => 'No offers yet.';

  @override
  String get businessOffersFilterAll => 'All';

  @override
  String get businessOfferStatusActive => 'Active';

  @override
  String get businessOfferStatusPaused => 'Paused';

  @override
  String get businessOfferStatusExpired => 'Expired';

  @override
  String get businessOfferStatusCancelled => 'Cancelled';

  @override
  String businessOffersUsage(int active, int max) {
    return '$active of $max active offers used';
  }

  @override
  String get businessOfferPause => 'Pause';

  @override
  String get businessOfferActivate => 'Activate';

  @override
  String get businessOfferDeleteConfirm => 'Delete this offer?';

  @override
  String get businessOfferBoostAction => 'Boost';

  @override
  String get businessOfferBoostTitle => 'Boost this offer';

  @override
  String businessOfferBoostDuration(int days) {
    return '$days days';
  }

  @override
  String get businessOfferBoosted => 'Offer boosted.';

  @override
  String get businessOfferBoostPurchasesTitle => 'My boosts';

  @override
  String get businessOfferBoostPurchasesEmpty => 'No boost purchases yet.';

  @override
  String get businessOfferAddTitle => 'New offer';

  @override
  String get businessOfferEditTitle => 'Edit offer';

  @override
  String get businessOfferTypeLabel => 'What\'s this offer on?';

  @override
  String get businessOfferTypeMenuItem => 'Menu item';

  @override
  String get businessOfferTypeProduct => 'Product';

  @override
  String get businessOfferTypeService => 'Service';

  @override
  String get businessOfferPickItem => 'Choose the item';

  @override
  String get businessOfferPickItemFirst =>
      'Choose the item this offer is on first.';

  @override
  String get businessOfferNoItemsFound => 'No items found.';

  @override
  String businessOfferCurrentPrice(String price, String currency) {
    return 'Current price: $price $currency';
  }

  @override
  String get businessOfferTitleLabel => 'Offer title (optional)';

  @override
  String get businessOfferFinalPriceLabel => 'Offer price';

  @override
  String businessOfferPriceTooHigh(String price, String currency) {
    return 'Offer price must be less than the current price ($price $currency).';
  }

  @override
  String get businessOfferEndConditionLabel => 'This offer ends...';

  @override
  String get businessOfferEndsAtLabel => 'On a date';

  @override
  String get businessOfferPickEndDate => 'Choose an end date for the offer.';

  @override
  String get businessOfferWhileStockLasts => 'While stock lasts';

  @override
  String get businessOfferLimitedQuantity => 'After a limited quantity';

  @override
  String get businessOfferQuantityLabel => 'Quantity';

  @override
  String get businessOfferRefundableLabel => 'Refundable';

  @override
  String get drawerSectionProfile => 'Profile settings';

  @override
  String get drawerSectionJobsPosts => 'Jobs & posts';

  @override
  String get drawerSectionMyServices => 'My services';

  @override
  String get chatsListTitle => 'Chats';

  @override
  String get chatsListEmpty => 'No conversations yet.';

  @override
  String get chatRenameGroup => 'Rename group';

  @override
  String get chatDeleteGroupConfirm => 'Delete this group for everyone?';

  @override
  String get chatLeaveGroupConfirm => 'Leave this group?';

  @override
  String get chatLeaveAction => 'Leave';

  @override
  String get chatDeleteConfirm => 'Delete this chat? This cannot be undone.';

  @override
  String get offerPerformanceTitle => 'Offer Performance';

  @override
  String get offerPerformanceEmpty => 'No activity on your offers yet.';

  @override
  String get offerPerformanceByOffer => 'By offer';

  @override
  String get offerEventView => 'Views';

  @override
  String get offerEventClick => 'Clicks';

  @override
  String get offerEventLead => 'Leads';

  @override
  String get offerEventConversion => 'Conversions';

  @override
  String get offerEventShare => 'Shares';

  @override
  String get offerEventSave => 'Saves';

  @override
  String get tableScanTitle => 'Table order';

  @override
  String get tableScanHint =>
      'Enter the code printed on your table to join its order.';

  @override
  String get tableScanCodeLabel => 'Table code';

  @override
  String get tableScanJoin => 'Join table';

  @override
  String get tableCallStaff => 'Call staff';

  @override
  String get tableCallWaiter => 'Call waiter';

  @override
  String get tableCallBill => 'Ask for the bill';

  @override
  String get tableCallAssistance => 'Ask for assistance';

  @override
  String get tableCallsTitle => 'Table calls';

  @override
  String get tableCallsEmpty => 'No table is calling right now.';

  @override
  String tableCallTable(String label) {
    return 'Table $label';
  }

  @override
  String get tableCallResolve => 'Handled';

  @override
  String get tableCallSent => 'Sent to staff.';

  @override
  String get myTripSchedulesTitle => 'My Trip Schedules';

  @override
  String get incomingReservationsTitle => 'Incoming Reservations';

  @override
  String get tripScheduleAdd => 'Publish route';

  @override
  String get tripScheduleAddTitle => 'New trip schedule';

  @override
  String get tripSchedulesEmpty => 'No trip schedules published yet.';

  @override
  String get tripScheduleDeleteConfirm => 'Delete this trip schedule?';

  @override
  String get tripScheduleModeLabel => 'Trip type';

  @override
  String get tripScheduleVehicleLabel => 'Vehicle type';

  @override
  String get tripScheduleInternational =>
      'International trip (between two countries)';

  @override
  String get tripChooseCountry => 'Choose a country';

  @override
  String get tripSchedulePatternLabel => 'This trip runs...';

  @override
  String get tripSchedulePatternWeekly => 'Weekly, on a fixed day';

  @override
  String get tripSchedulePatternOneOff => 'On a specific date';

  @override
  String get tripSchedulePatternOnDemand => 'On demand';

  @override
  String get tripScheduleDayLabel => 'Day of the week';

  @override
  String get tripScheduleDateLabel => 'Date';

  @override
  String get tripScheduleDatePickRequired => 'Pick a date for this trip.';

  @override
  String get tripScheduleDepartureTimeLabel => 'Departure time';

  @override
  String get tripScheduleReturnTimeLabel => 'Return time';

  @override
  String get tripScheduleNotesLabel => 'Notes';

  @override
  String tripReturnAt(String time) {
    return 'Return $time';
  }

  @override
  String get tripScheduleCapacityLabel => 'Capacity';

  @override
  String get tripSchedulePriceLabel => 'Price per unit';

  @override
  String get tripScheduleDepositLabel => 'Deposit per unit (optional)';

  @override
  String get tripScheduleStopsTitle => 'Stops along the route (optional)';

  @override
  String get tripScheduleStopLabel => 'Stop name';

  @override
  String get tripScheduleStopAddress => 'Address';

  @override
  String get tripScheduleAddStop => '+ Add a stop';

  @override
  String get tripScheduleStopBusinessHint =>
      'You can pick a registered business (a clinic, a shop...) instead of typing an address — its actual GPS location is used when the run is executed.';

  @override
  String get tripScheduleStopPickBusiness => 'Pick a registered business';

  @override
  String get tripScheduleStopClearBusiness => 'Unlink';

  @override
  String get tripScheduleStopUsesGps =>
      'The business\'s GPS location will be used instead of this address';

  @override
  String get tripScheduleStopPickBusinessTitle => 'Pick a business';

  @override
  String get tripScheduleStopSearchHint => 'Type a business name to search';

  @override
  String get tripScheduleStopSearchEmpty => 'No matching results.';

  @override
  String get tripRunStart => 'Start a run';

  @override
  String get tripRunsTitle => 'Live runs';

  @override
  String get tripRunEmpty => 'No runs yet.';

  @override
  String get tripRunStartTitle => 'Start the run';

  @override
  String get tripRunStartRequiresStops =>
      'Add stops to this leg first, before starting a run.';

  @override
  String get tripRunPassengerCountLabel => 'Actual passenger count';

  @override
  String get tripRunPassengerCountRequired =>
      'Enter the actual passenger count.';

  @override
  String tripRunPassengerCountDisplay(int count) {
    return 'Passengers: $count';
  }

  @override
  String get tripRunManifestTitle => 'Cargo manifest';

  @override
  String get tripRunManifestItemLabel => 'Item name';

  @override
  String get tripRunManifestItemUnit => 'Unit (optional)';

  @override
  String get tripRunManifestItemQty => 'Quantity';

  @override
  String get tripRunAddManifestItem => '+ Add an item';

  @override
  String get tripRunManifestRequired => 'Add at least one item.';

  @override
  String get tripRunManifestQtyRequired =>
      'Enter a valid quantity for each item.';

  @override
  String get tripRunStartAction => 'Start the run';

  @override
  String get tripRunStatusInProgress => 'Run in progress';

  @override
  String get tripRunStatusAwaitingReconciliation =>
      'Awaiting cargo reconciliation';

  @override
  String get tripRunStatusCompleted => 'Run completed';

  @override
  String tripRunHeadingTo(String stop) {
    return 'Heading to $stop';
  }

  @override
  String tripRunArrivedAt(String stop) {
    return 'Arrived at $stop';
  }

  @override
  String get tripRunArrivedAction => 'I\'ve arrived';

  @override
  String tripRunAdvanceToNext(String stop) {
    return 'Done — heading to $stop';
  }

  @override
  String get tripRunFinishAction => 'Mark fully complete';

  @override
  String get tripRunCompletedMessage => 'The run is fully completed';

  @override
  String get tripRunNavigate => 'Open in Google Maps';

  @override
  String get tripRunReconcileTitle => 'Cargo reconciliation';

  @override
  String get tripRunReconcileDelivered => 'Delivered';

  @override
  String get tripRunReconcileReturned => 'Returned';

  @override
  String get tripRunReconcileSubmit => 'Submit reconciliation';

  @override
  String get incomingReservationsEmpty => 'No reservations yet.';

  @override
  String get tripReservationStatusAll => 'All';

  @override
  String get tripReservationStatusPending => 'Pending';

  @override
  String get tripReservationStatusConfirmed => 'Confirmed';

  @override
  String get tripReservationStatusCompleted => 'Completed';

  @override
  String get tripReservationStatusCancelled => 'Cancelled';

  @override
  String tripReservationClient(int id) {
    return 'Client #$id';
  }

  @override
  String tripReservationUnitsCount(int count) {
    return '$count units';
  }

  @override
  String get tripReservationConfirmAction => 'Confirm';

  @override
  String get tripReservationCompleteAction => 'Complete';

  @override
  String get tripReservationRejectAction => 'Reject';

  @override
  String get myTrainingClientsTitle => 'My Training Clients';

  @override
  String get trainingClientsEmpty => 'No client plans yet.';

  @override
  String get trainingTemplateApply => 'Apply to a client';

  @override
  String get trainingApplyClientLabel => 'Client phone or e-mail';

  @override
  String get trainingApplyClientHint =>
      'Type the phone or e-mail exactly as registered, then tap Search.';

  @override
  String get trainingApplyFind => 'Search';

  @override
  String get trainingApplyClientNotFound =>
      'No client has exactly this phone or e-mail.';

  @override
  String get trainingApplyStart => 'Start date';

  @override
  String get trainingApplyCreate => 'Create the plan and send it to the client';

  @override
  String get trainingApplyDone =>
      'Plan created and sent to the client to accept.';

  @override
  String get trainingTemplateWeeks => 'Template length (weeks)';

  @override
  String get trainingDayLabelHint => 'Day name (Push / Pull / Legs)';

  @override
  String trainingWeekOf(int w, int t) {
    return 'Week $w of $t';
  }

  @override
  String trainingWeekNumber(int w) {
    return 'Week $w';
  }

  @override
  String trainingWeightsThisWeek(String w) {
    return 'This week: $w kg';
  }

  @override
  String trainingWeightsNextWeek(String w) {
    return 'Next week: $w kg';
  }

  @override
  String get trainingProgramTitle => 'Programme';

  @override
  String get trainingProgramWeeks => 'Number of weeks';

  @override
  String get trainingProgramEvery => 'Add weight every (weeks)';

  @override
  String get trainingProgramIncrement => 'Increase by (kg)';

  @override
  String get trainingProgramApply => 'Apply to every exercise';

  @override
  String get trainingProgramHint =>
      'Each week\'s weights are worked out from the rule and apply to every exercise that has a weight.';

  @override
  String get trainingProgramSaved => 'Programme updated.';

  @override
  String get trainingSetWeightsHint => 'Weights per set (20-25-30)';

  @override
  String trainingLogSetTitle(int n) {
    return 'Log set $n';
  }

  @override
  String get trainingSetReps => 'Reps';

  @override
  String get trainingSetWeight => 'Weight (kg)';

  @override
  String get trainingSetSkipDetails => 'Confirm without details';

  @override
  String get trainingTargetWeight => 'Target weight (kg)';

  @override
  String get trainingWeightLabel => 'Weight';

  @override
  String get trainingKgUnit => 'kg';

  @override
  String get trainingSessionDone =>
      'Well done! You finished today\'s workout and your trainer was told.';

  @override
  String get trainingMonthlySummary => 'Monthly summary';

  @override
  String get trainingMonthSessions => 'Days finished';

  @override
  String get trainingMonthSets => 'Sets';

  @override
  String get trainingMonthReps => 'Reps';

  @override
  String get trainingMonthVolume => 'Volume (kg)';

  @override
  String get trainingMonthExercises => 'Exercises';

  @override
  String trainingMonthSetsDone(int n) {
    return '$n sets';
  }

  @override
  String get trainingMonthMaxWeight => 'Top weight';

  @override
  String get trainingMonthNoData => 'Nothing recorded this month.';

  @override
  String trainingMonthWeight(String from, String to) {
    return 'Weight: $from to $to kg';
  }

  @override
  String get trainingSessionsSection => 'Finished days';

  @override
  String trainingDayLogTitle(String date) {
    return 'Sets on $date';
  }

  @override
  String get trainingPhotoLibrary => 'My photo library';

  @override
  String get trainingPhotoLibraryEmpty =>
      'No photos in your library yet. Add photos to reuse them with several clients.';

  @override
  String get trainingPhotoLibraryDeleteConfirm =>
      'Delete this photo from your library? Copies already attached to clients\' plans are not affected.';

  @override
  String get trainingPhotoFromLibrary => 'From my library';

  @override
  String get trainingPhotoPickTitle => 'Pick photos from your library';

  @override
  String trainingPhotoAttach(int n) {
    return 'Attach ($n)';
  }

  @override
  String get trainingAddPhoto => 'Add photo';

  @override
  String get trainingPhotoPrivateHint =>
      'Photos are visible only to you and your client.';

  @override
  String get trainingPickFromLibrary => 'Pick from the exercise library';

  @override
  String get trainingLibrarySearch => 'Search exercises';

  @override
  String get trainingLibraryAll => 'All';

  @override
  String get trainingLibraryEmpty => 'No matching exercises.';

  @override
  String trainingWeeklyAverage(int percent) {
    return 'Your clients\' average adherence this week: $percent%';
  }

  @override
  String trainingWeeklyRange(String from, String to) {
    return 'Week of $from to $to';
  }

  @override
  String trainingClientWeek(int done, int target, int days, int checkins) {
    return '$done of $target rounds · $days active days · $checkins check-ins';
  }

  @override
  String get trainingClientNoSchedule => 'No exercises scheduled yet';

  @override
  String get trainingPlanStatusActive => 'Active';

  @override
  String get trainingPlanStatusPaused => 'Paused';

  @override
  String get trainingPlanStatusCompleted => 'Completed';

  @override
  String get trainingPlanStatusCancelled => 'Cancelled';

  @override
  String get mealTypeBreakfast => 'Breakfast';

  @override
  String get mealTypeLunch => 'Lunch';

  @override
  String get mealTypeDinner => 'Dinner';

  @override
  String get mealTypeSnack => 'Snack';

  @override
  String get trainingAddExercise => 'Add exercise';

  @override
  String get trainingExerciseName => 'Exercise name';

  @override
  String get trainingAnyDay => 'Any day';

  @override
  String get trainingSets => 'Sets';

  @override
  String get trainingReps => 'Reps';

  @override
  String get trainingAddMeal => 'Add meal';

  @override
  String get trainingMealName => 'Meal name';

  @override
  String get trainingCalories => 'Calories';

  @override
  String get trainingAddBodyReport => 'Add monthly reading';

  @override
  String get trainingBodyReportHint =>
      'One reading per month — sending the same month again updates it.';

  @override
  String get trainingWeightKg => 'Weight (kg)';

  @override
  String get trainingMuscleKg => 'Muscle mass (kg)';

  @override
  String get trainingFatPercent => 'Fat %';

  @override
  String get trainingWaterPercent => 'Water %';

  @override
  String get trainingExercisesSection => 'Exercises';

  @override
  String get trainingMealsSection => 'Meals';

  @override
  String get trainingBodyReportsSection => 'Body composition';

  @override
  String get storeTermsTitle => 'Store terms';

  @override
  String get storeTermsCustomerTitle => 'Store terms';

  @override
  String get storeTermsHint =>
      'Set your store\'s policies once (returns, minimum order, delivery…). Customers see them on your page and at checkout, and every order keeps the terms it was placed under.';

  @override
  String get storeTermsSave => 'Save';

  @override
  String get shopAddonsTitle => 'Shop services';

  @override
  String get shopAddonsEmpty => 'Your business offers no extra services.';

  @override
  String get shopAddonsHint =>
      'Price your shop\'s services once (grilled, fried, baked tray…). The price is per unit sold (per kg, for example); every item carries them, the customer picks one, and the invoice lists it as its own line. Leave a field empty if you do not offer the service.';

  @override
  String get shopAddonPriceHint => 'Price';

  @override
  String get shopAddonsSaved => 'Service prices saved.';

  @override
  String get cartLineBase => 'Item';

  @override
  String get paymentPlanCash => 'Cash';

  @override
  String paymentPlanMonths(int months) {
    return 'Instalments over $months months';
  }

  @override
  String get storeTermsSavedDone => 'Saved';

  @override
  String get techPricingPlansTitle => 'Payment plans (instalments)';

  @override
  String get techPricingPlansHint =>
      'The price above is the cash price. Add an instalment plan: the months, a down payment if any, and what one unit costs on it. The customer picks cash or a plan.';

  @override
  String get techPricingPlanTotal => 'Unit price on the plan';

  @override
  String get techPricingAddPlan => 'Add an instalment plan';

  @override
  String get techPricingPlanBelowCash =>
      'The instalment price cannot be below the cash price.';

  @override
  String get itemAddonsTitle => 'Shop services on this item';

  @override
  String get itemAddonsHint =>
      'Tick what this item offers from the shop services (cooking method, preparation…). Prices are set once in «Shop services».';

  @override
  String weightGramsChip(int grams) {
    return '$grams g';
  }

  @override
  String get weightKilo => 'kg';

  @override
  String get weightChoose => 'Quantity (weight)';

  @override
  String cardInstalment(String monthly, int months) {
    return 'Instalments from $monthly a month over $months months';
  }

  @override
  String get menuInstalmentsOnly => 'On instalments';

  @override
  String get menuSheetMapTitle => 'Match the columns';

  @override
  String get menuSheetMapHint =>
      'Pick, for each of our columns, the number of the matching column in your file. What you leave on «None» is not read — and changes nothing on an existing item.';

  @override
  String get menuSheetMapFileColumns => 'Your file\'s columns';

  @override
  String get menuSheetMapOurColumns => 'Our columns';

  @override
  String get menuSheetMapNone => '— None —';

  @override
  String menuSheetMapColumn(int n) {
    return 'Column $n';
  }

  @override
  String get menuSheetMapPreview => 'Preview with this matching';

  @override
  String get menuSheetMapReset => 'Automatic matching';

  @override
  String menuSheetMapRows(int count) {
    return '$count rows in the file';
  }

  @override
  String get menuSheetTitle => 'Menu import & export';

  @override
  String get menuSheetExportHint =>
      'Download your items as an Excel file, edit or add to them on a computer or phone, then upload it here. Each item keeps its ID: editing it updates the same item.';

  @override
  String get menuSheetExportItems => 'Export my items (Excel)';

  @override
  String get menuSheetExportTemplate => 'Empty template (Excel)';

  @override
  String get menuSheetImport => 'Choose a file to import';

  @override
  String get menuSheetImportHint =>
      'An Excel or CSV file with the template columns. «Type» is one of your trade types; sizes, extras, photos and barcode are optional — how to write them is on the template\'s second sheet. You see a preview before anything changes.';

  @override
  String get menuSheetPreviewTitle => 'Preview — nothing changed yet';

  @override
  String get menuSheetDoneTitle => 'Imported';

  @override
  String menuSheetSummary(int created, int updated, int errors) {
    return 'New: $created — Updated: $updated — Errors: $errors';
  }

  @override
  String get menuSheetConfirm => 'Confirm import';

  @override
  String menuSheetRow(int row) {
    return 'Row $row';
  }

  @override
  String get menuSheetActionCreate => 'New';

  @override
  String get menuSheetActionUpdate => 'Update';

  @override
  String get menuSheetActionSection => 'Section';

  @override
  String get menuSheetActionError => 'Error';

  @override
  String get menuSheetEmpty => 'The file is empty or has no readable rows.';

  @override
  String get menuSheetListsSheet => 'Types and units';

  @override
  String get menuSheetTypes => 'Type';

  @override
  String get menuSheetGroup => 'Group';

  @override
  String get menuSheetUnits => 'Units';

  @override
  String get menuSheetHowTo => 'How to write';

  @override
  String get medicalFileTitle => 'My medical file';

  @override
  String get medicalFileLocalNote =>
      'Kept on this phone only, encrypted — never uploaded. You share it with a doctor or pharmacist by a QR code for a few minutes.';

  @override
  String get medicalBloodType => 'Blood type';

  @override
  String get medicalBloodUnknown => 'Unknown';

  @override
  String get medicalSectionConditions => 'Chronic conditions';

  @override
  String get medicalSectionAllergies => 'Allergies';

  @override
  String get medicalSectionMedications => 'Current medications';

  @override
  String get medicalSectionSurgeries => 'Past surgeries';

  @override
  String get medicalNotes => 'Notes';

  @override
  String get medicalAdd => 'Add';

  @override
  String get medicalEntryTitle => 'Name';

  @override
  String get medicalEntryDetail => 'Details (optional)';

  @override
  String get medicalEmptySection => 'Nothing yet';

  @override
  String get medicalShare => 'Share with a doctor or pharmacist';

  @override
  String get medicalScan => 'Read a patient\'s file';

  @override
  String get medicalShareChoose => 'Choose what to share';

  @override
  String medicalShareMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get medicalShareCreate => 'Create the share code';

  @override
  String get medicalShareShowCode =>
      'Show this code to the doctor or pharmacist to scan in their app.';

  @override
  String medicalShareExpires(String time) {
    return 'Ends $time';
  }

  @override
  String get medicalShareEnd => 'End the share now';

  @override
  String get medicalShareEnded => 'The share has ended.';

  @override
  String get medicalScanHint =>
      'Point the camera at the medical file code on the patient\'s phone';

  @override
  String medicalSharedBy(String name) {
    return '$name\'s medical file';
  }

  @override
  String medicalSharedAt(String time) {
    return 'Shared $time';
  }

  @override
  String get medicalViewNote => 'Shown here only; not saved on this phone.';

  @override
  String get medicalShareInvalid => 'This is not a medical file code.';

  @override
  String get medicalShareUnreadable =>
      'Could not open the file — the share may have ended.';

  @override
  String get medicalShareNothing =>
      'Your file is empty — add what you want to share first.';

  @override
  String get medicalBackupTitle => 'Encrypted backup';

  @override
  String get medicalBackupNone =>
      'No backup yet — if you lose or change your phone, your file is gone.';

  @override
  String medicalBackupLast(String time) {
    return 'Last backup: $time';
  }

  @override
  String get medicalBackupChanged =>
      'The file changed after the last backup — make a new one.';

  @override
  String get medicalBackupNow => 'Back up now';

  @override
  String get medicalBackupRestore => 'Restore from a backup';

  @override
  String get medicalBackupDelete => 'Delete the backup';

  @override
  String get medicalBackupPassphrase => 'Backup passphrase';

  @override
  String get medicalBackupPassphraseAgain => 'Repeat the passphrase';

  @override
  String get medicalBackupWarning =>
      'This passphrase is stored nowhere and cannot be recovered. If you forget it nobody can open the backup — not even us.';

  @override
  String get medicalBackupTooShort =>
      'The passphrase needs at least 8 characters.';

  @override
  String get medicalBackupMismatch => 'The two passphrases do not match.';

  @override
  String get medicalBackupWorking => 'Encrypting… this takes a few seconds.';

  @override
  String get medicalBackupDone => 'Backup made.';

  @override
  String get medicalBackupRestored => 'Restored.';

  @override
  String get medicalBackupNothing => 'This account has no backup.';

  @override
  String get medicalBackupWrong =>
      'Wrong passphrase, or the backup is damaged.';

  @override
  String get medicalBackupReplace =>
      'This phone\'s current file will be replaced by the backup. Continue?';

  @override
  String get medicalBackupDeleted => 'The backup was deleted.';

  @override
  String get medicalBackupDeleteConfirm =>
      'Delete the backup from the server? Your file on this phone is not affected.';

  @override
  String get rxArchiveTitle => 'My prescriptions on this phone';

  @override
  String get rxArchiveNote =>
      'A copy of every prescription a doctor wrote for you is kept here automatically and stays with you even if the server drops it. It is part of the encrypted backup.';

  @override
  String get rxArchiveEmpty =>
      'No prescriptions yet — they appear here after you open \"My prescriptions\".';

  @override
  String get rxArchiveOpen => 'Prescriptions on this phone';

  @override
  String get rxShowPharmacist => 'Show to a pharmacist (QR)';

  @override
  String get rxShowTitle => 'Show the prescription to the pharmacist';

  @override
  String get rxShowHint =>
      'The pharmacist scans the code in the app, sees the prescription and checks it is exactly what the doctor wrote. It reaches them encrypted and ends in minutes.';

  @override
  String get rxShowCreate => 'Create the code';

  @override
  String get rxPurgedNote =>
      'The server no longer keeps the diagnosis and notes of this finished prescription — the copy on this phone is now the only one. Keep an encrypted backup.';

  @override
  String get rxControlledRuleShort => 'handwritten paper, stamped «dispensed»';

  @override
  String get rxControlledPickTitle =>
      'A drug in the controlled-substance schedules';

  @override
  String get rxControlledPickBody =>
      'This drug is written only on a handwritten prescription — photograph it here so the pharmacist can compare it with the paper the patient holds. Set how many times it will be dispensed; after the last time the pharmacist stamps the paper «dispensed».';

  @override
  String get rxControlledPickOk => 'Understood';

  @override
  String get rxDispenseTimes => 'Number of fillings';

  @override
  String get rxDispenseTimesHint =>
      'After the last filling the pharmacist stamps the paper prescription «dispensed».';

  @override
  String rxDispenseTimesValue(Object count) {
    return '$count times';
  }

  @override
  String rxFillingOf(Object limit, Object n) {
    return 'Filling $n of $limit';
  }

  @override
  String get rxFinalFilling =>
      'This is the last filling: after handing over, stamp the paper prescription «dispensed».';

  @override
  String get rxMoreFillings =>
      'The prescription stays open for more fillings: give it back to the patient without the «dispensed» stamp.';

  @override
  String rxFillingRecorded(Object limit, Object n) {
    return 'Filling $n of $limit recorded.';
  }

  @override
  String get rxFinalRecorded =>
      'Dispensed — stamp the paper prescription «dispensed» now.';

  @override
  String get rxControlledBadge => 'Controlled drug';

  @override
  String get rxHandwrittenTitle => 'A controlled drug is on this prescription';

  @override
  String get rxHandwrittenHint =>
      'To prevent fraud, take a photo of the prescription written by your own hand on paper. The pharmacy compares it with the paper the patient holds.';

  @override
  String get rxHandwrittenTake => 'Photograph the handwritten prescription';

  @override
  String get rxHandwrittenRetake => 'Take it again';

  @override
  String get rxHandwrittenRequired =>
      'Add the photo of the handwritten prescription first.';

  @override
  String get rxControlledComparePaper =>
      'Controlled drug — compare this photo with the paper prescription in the patient\'s hand before dispensing.';

  @override
  String get rxControlledNoPaper =>
      'Controlled drug with no handwritten prescription on file — it cannot be dispensed.';

  @override
  String get rxNoCopy =>
      'There is no verifiable copy of this prescription on this phone.';

  @override
  String get rxShownTitle => 'A prescription shown to you';

  @override
  String rxShownBy(String name) {
    return 'Shown by $name';
  }

  @override
  String rxIssuedBy(String name) {
    return 'Doctor: $name';
  }

  @override
  String get rxVerifyWorking => 'Checking the prescription…';

  @override
  String get rxVerified => 'Verified — exactly what the doctor wrote';

  @override
  String get rxNotVerified =>
      'Not verified — it does not match what the doctor wrote. Do not dispense.';

  @override
  String get rxCanDispense => 'Not dispensed yet — it can be dispensed.';

  @override
  String get rxAlreadyDispensed =>
      'Already dispensed — do not dispense it again.';

  @override
  String get rxCancelledOrOther =>
      'It cannot be dispensed: cancelled, or sent to another pharmacy.';

  @override
  String get rxSuperseded =>
      'The doctor replaced it with a newer one — this copy is no longer valid.';

  @override
  String get rxDispenseNow => 'Record this prescription as dispensed';

  @override
  String get rxDispenseConfirm =>
      'You record that your pharmacy handed the medicine over just now. It cannot be undone, and no other pharmacy can dispense it.';

  @override
  String get rxDispensed => 'Recorded as dispensed.';

  @override
  String get rxCheckUnavailable =>
      'Verification is for pharmacy accounts only — this shows what the patient sent, unverified.';

  @override
  String rxItemDosage(String value) {
    return 'Dose: $value';
  }

  @override
  String rxItemQuantity(String value) {
    return 'Quantity: $value';
  }

  @override
  String get rxDiagnosis => 'Diagnosis';

  @override
  String get rxNotes => 'Doctor\'s notes';

  @override
  String get stayReqButtonIssue => 'Report a problem';

  @override
  String get stayReqButtonService => 'Request a service';

  @override
  String get stayReqIssueTitle => 'What is wrong in the room?';

  @override
  String get stayReqServiceTitle => 'What do you need?';

  @override
  String get stayReqNoteHint => 'Note (optional)';

  @override
  String get stayReqNoteHintRequired => 'Describe the problem';

  @override
  String get stayReqSend => 'Send to the hotel';

  @override
  String get stayReqSent => 'Your request reached the hotel';

  @override
  String get stayReqMine => 'Your requests in this stay';

  @override
  String get stayReqWithdraw => 'Withdraw the request';

  @override
  String get stayReqNotNow => 'Requests are available during the stay only';

  @override
  String get stayReqStatusNew => 'Waiting';

  @override
  String get stayReqStatusInProgress => 'In progress';

  @override
  String get stayReqStatusDone => 'Done';

  @override
  String get stayReqStatusCancelled => 'Cancelled';

  @override
  String get stayReqScreenTitle => 'Guest requests';

  @override
  String get stayReqTabOpen => 'Open';

  @override
  String get stayReqTabDone => 'Finished';

  @override
  String get stayReqEmpty => 'No requests right now';

  @override
  String stayReqRoom(String number) {
    return 'Room $number';
  }

  @override
  String get stayReqNoRoom => 'No room number';

  @override
  String get stayReqStart => 'Start working on it';

  @override
  String get stayReqDone => 'Mark done';

  @override
  String get stayReqCannot => 'Can\'t do it';

  @override
  String get stayReqKindIssue => 'Problem';

  @override
  String get stayReqKindService => 'Service';

  @override
  String get stayReqManageServices => 'Services a guest can order';

  @override
  String get stayReqServicesIntro =>
      'What a guest may order during their stay. Add what your hotel offers and switch off what it does not.';

  @override
  String get stayReqServicesStarting =>
      'This is the platform\'s starting list — edit it to make it yours.';

  @override
  String get stayReqAddServiceHint =>
      'A service name, or several separated by commas';

  @override
  String get stayReqAdd => 'Add';

  @override
  String get bookingDayUse => 'Day use';

  @override
  String get bookingStayByNight => 'Overnight stay';

  @override
  String get bookingDayUseDate => 'Day-use date';

  @override
  String bookingDayUseWindow(String from, String to) {
    return 'From $from to $to';
  }

  @override
  String bookingDayUseTag(String from, String to) {
    return 'Day use · $from–$to';
  }

  @override
  String get dayUseSettingsTitle => 'Day use';

  @override
  String get dayUseSettingsHint =>
      'Sell the same room through the day without a night: a time window and a flat price. The guest only picks a date.';

  @override
  String get dayUseEnable => 'Offer Day use for this room type';

  @override
  String get dayUseFrom => 'From';

  @override
  String get dayUseTo => 'To';

  @override
  String get dayUsePrice => 'Day-use price';

  @override
  String get bookingAddOnsTitle => 'Booking add-ons';

  @override
  String get bookingAddOnsIntro =>
      'What a guest adds on top of the room (like the meal plan) and what one particular room has (like the view). Everything is priced once, here.';

  @override
  String get bookingAddOnsGuestChoice => 'What the guest chooses';

  @override
  String get bookingAddOnsRoomFeatures => 'What a room has';

  @override
  String get bookingAddOnsRoomFeaturesHint =>
      'Priced once here; then you tick, on each room, which features it has and its price grows by them.';

  @override
  String get bookingAddOnsEmpty => 'There are no add-ons for this business';

  @override
  String get addOnSelectionSingle => 'One choice';

  @override
  String get addOnSelectionMultiple => 'Several choices';

  @override
  String get addOnPricePerNight => 'Added per night';

  @override
  String get addOnPriceFeature => 'Added to the room price';

  @override
  String get addOnPerPerson => 'Per person';

  @override
  String get unitFeaturesTitle => 'Room features';

  @override
  String get unitFeaturesHint =>
      'Tick what this room has. A feature is priced once in «Booking add-ons» and its price is added to the room\'s price.';

  @override
  String get bookingNoAddOn => 'None';

  @override
  String get bookingDayTitle => 'Day';

  @override
  String get bookingStartTime => 'Start time';

  @override
  String get bookingTimeTitle => 'Time';

  @override
  String bookingDurationLabel(Object value) {
    return 'Duration: $value';
  }

  @override
  String get bookingDurHour => '1 hour';

  @override
  String get bookingDurHourHalf => '1.5 hours';

  @override
  String get bookingDurTwoHours => '2 hours';

  @override
  String bookingDurHours(Object n) {
    return '$n hours';
  }

  @override
  String get bookingBookNow => 'Book now';

  @override
  String get bookingBookTable => 'Book a table';

  @override
  String get bookingHourlyHint =>
      'Pick a day and a time, then the pitch or hall';

  @override
  String get bookingTableHint => 'Pick a day and a time to see the free tables';

  @override
  String get bookingClosedDay => 'Closed on this day';

  @override
  String get bookingNoFreeTime => 'No times available on this day';

  @override
  String get bookingPartySizeLabel => 'Party size';

  @override
  String bookingPartyPeople(Object n) {
    return '$n people';
  }

  @override
  String bookingTablesAt(Object time) {
    return 'Tables free at $time';
  }

  @override
  String bookingSeatsUpTo(Object n) {
    return 'Seats $n';
  }

  @override
  String get bookingHourWord => 'hour';

  @override
  String get bookingNightWord => 'night';

  @override
  String get bookingWhenStay => 'When do you want to stay?';

  @override
  String get bookingArrival => 'Arrival';

  @override
  String get bookingDeparture => 'Departure';

  @override
  String get bookingGuests => 'Guests';

  @override
  String bookingGuestsCount(Object n) {
    return '$n guests';
  }

  @override
  String get bookingAvailableInDates => 'Available on these dates';

  @override
  String bookingUnitsCount(Object n) {
    return '$n units';
  }

  @override
  String get bookingNoUnitsInDates => 'No units available on these dates.';

  @override
  String get bookingPickUnitToContinue => 'Pick a unit to continue';

  @override
  String get bookingContinue => 'Continue';

  @override
  String get bookingServiceTitle => 'Service';

  @override
  String get bookingPickDayTitle => 'Pick a day';

  @override
  String get bookingPickTimeTitle => 'Pick a time';

  @override
  String get bookingConfirmAppointment => 'Confirm the appointment';

  @override
  String bookingMinutes(Object n) {
    return '$n min';
  }

  @override
  String get courseLevelTitle => 'Level';

  @override
  String get courseLevelAll => 'All';

  @override
  String get courseGroupsTitle => 'Available groups';

  @override
  String courseStartsOn(Object date) {
    return 'Starts $date';
  }

  @override
  String courseSeatsLeft(Object n) {
    return '$n seats left';
  }

  @override
  String get courseSeatsFull => 'Full';

  @override
  String get coursePerCourse => 'EGP / course';

  @override
  String get courseEnroll => 'Enrol in the course';

  @override
  String get courseNoGroups => 'No group is open right now.';

  @override
  String get courseHint => 'Pick a group';

  @override
  String get courseManageTitle => 'Course groups';

  @override
  String get courseAddGroup => 'Add a group';

  @override
  String get courseEditGroup => 'Edit the group';

  @override
  String get courseOfCourse => 'Course';

  @override
  String get courseGroupName => 'Group name';

  @override
  String get courseGroupLevel => 'Level';

  @override
  String get courseGroupLevelHint => 'Beginner / Intermediate / Advanced';

  @override
  String get courseGroupSchedule => 'Schedule (e.g. Sun and Tue · 7 pm)';

  @override
  String get courseGroupStarts => 'Starts';

  @override
  String get courseGroupEnds => 'End date (optional)';

  @override
  String get courseGroupEndsShort => 'Ends';

  @override
  String get courseGroupSeats => 'Seats';

  @override
  String get courseGroupOpen => 'Open to join';

  @override
  String get courseGroupClosed => 'Closed';

  @override
  String courseTaken(Object seats, Object taken) {
    return '$taken of $seats seats';
  }

  @override
  String get courseNoCourses =>
      'No courses yet — add one from «My prices» first.';

  @override
  String get courseDeleteGroup => 'Delete the group';

  @override
  String get courseNameRequired => 'Write the group name.';

  @override
  String get arrivalNoticeTitle => 'Arrival notice';

  @override
  String get arrivalNoticeIntro =>
      'The customer reads it when booking and after, and the reminder repeats it.';

  @override
  String get arrivalNoticeMinutes => 'Be there before the appointment by';

  @override
  String get arrivalNoticeNone => 'None';

  @override
  String get arrivalNoticeText => 'An extra sentence (optional)';

  @override
  String get arrivalNoticePreview => 'This is how the customer reads it';

  @override
  String get queueYourTurn => 'Your turn';

  @override
  String queueTurnNumber(Object n) {
    return 'Turn number $n';
  }

  @override
  String queueExpectedAt(Object time) {
    return 'Around $time';
  }

  @override
  String queueAhead(Object n) {
    return '$n ahead of you';
  }

  @override
  String get queueNoneAhead => 'Nobody ahead of you';

  @override
  String get queueFull => 'This day\'s turns are used up';

  @override
  String get queueClosed => 'Closed on this day';

  @override
  String get queueTake => 'Take my turn';

  @override
  String queueTurnTaken(Object n, Object time) {
    return 'Your turn number $n is booked — around $time';
  }

  @override
  String get queueEstimateNote =>
      'The time is approximate and moves with the queue.';

  @override
  String get bookingFlowTitle => 'How bookings are taken';

  @override
  String get bookingFlowIntro =>
      'Choose how your customers book their appointments with you.';

  @override
  String get bookingFlowSlots => 'By appointment';

  @override
  String get bookingFlowSlotsSub =>
      'The customer picks the day and a time from the free ones.';

  @override
  String get bookingFlowQueue => 'By turn';

  @override
  String get bookingFlowQueueSub =>
      'The customer picks only the day and gets the next turn with the approximate time.';

  @override
  String get chairPickTitle => 'Choose the barber';

  @override
  String get chairAnyone => 'Anyone free';

  @override
  String chairWithPerson(Object name) {
    return 'With $name';
  }

  @override
  String get chairsTitle => 'Chairs and barbers';

  @override
  String get chairsIntro =>
      'Each chair has its own line. The customer picks the barber or any free chair.';

  @override
  String get chairAdd => 'Add a chair';

  @override
  String get chairEdit => 'Edit the chair';

  @override
  String get chairName => 'Chair name (e.g. Chair 1)';

  @override
  String get chairPerson => 'Barber name';

  @override
  String get chairPhoto => 'The barber\'s photo';

  @override
  String get chairChoosePhoto => 'Choose a photo';

  @override
  String get chairRemovePhoto => 'Remove the photo';

  @override
  String get chairOpen => 'Open for booking';

  @override
  String get chairDelete => 'Delete the chair';

  @override
  String get chairsEmpty =>
      'No chairs yet. Add a chair with the barber photo for customers to choose.';

  @override
  String get chairNeedsName => 'Write the chair name or the barber name.';

  @override
  String get chairClosed => 'Closed';

  @override
  String get queueConsoleTitle => 'Call the next turn';

  @override
  String get queueNowServing => 'Being served';

  @override
  String get queueCalled => 'Called';

  @override
  String get queueWaiting => 'Waiting';

  @override
  String get queueCallNext => 'Call the next';

  @override
  String get queueCallAgain => 'Call again';

  @override
  String get queueStart => 'Start the service';

  @override
  String get queueFinish => 'Done';

  @override
  String get queueNobody => 'Nobody is waiting';

  @override
  String get queueAddWalkIn => 'Add a customer with no booking';

  @override
  String get queueWalkInTitle => 'A turn for a customer with no booking';

  @override
  String get queueWalkInName => 'Customer name';

  @override
  String get queueWalkInPhone => 'Phone (optional)';

  @override
  String get queueWalkInService => 'Service';

  @override
  String get queueWalkInAdd => 'Add the turn';

  @override
  String queueWalkInAdded(Object n) {
    return 'Turn $n added';
  }

  @override
  String queueTurnShort(Object n) {
    return 'Turn $n';
  }

  @override
  String get queueWalkInTag => 'Walk-in';

  @override
  String get queueNoChair => 'No chair set';

  @override
  String get queueCalledSent => 'The customer was called';

  @override
  String get chairFromStaff => 'From the staff (optional)';

  @override
  String get chairNotStaff => 'None — I write the name and photo myself';

  @override
  String get chairStaffHint =>
      'The name and account photo of the staff member show on the chair; what you write below wins over them.';

  @override
  String get myChairTitle => 'My chair';

  @override
  String get myChairServed => 'Served today';

  @override
  String get myChairNone =>
      'Your account is not seated at a chair of this business yet. Ask the owner to put you on one.';

  @override
  String get bookingPickUnitTitle => 'Choose your room';

  @override
  String bookingUnitsAvailableCount(int count) {
    return '$count available';
  }

  @override
  String get bookingPerNight => '/ night';

  @override
  String get bookingPerHour => '/ hour';

  @override
  String bookingPriceIncludes(String features) {
    return 'includes $features';
  }

  @override
  String get bookingUnitNotPriced => 'Not priced yet';

  @override
  String bookingDayUseCardHint(String from, String to) {
    return 'No overnight — $from to $to';
  }

  @override
  String get bookingDayUseMealsTitle => 'Meals (optional)';

  @override
  String get bookingDayUseMealsHint =>
      'Pick any number — added to the day\'s price';

  @override
  String get bookingNightPrice => 'Price per night';

  @override
  String bookingTimesNights(int count) {
    return '× $count nights';
  }

  @override
  String get bookingBasePriceLine => 'Room';

  @override
  String get trainingFoodTable => 'Nutrition table';

  @override
  String get trainingPickFood => 'Pick from the nutrition table';

  @override
  String get trainingFoodSearch => 'Search a food';

  @override
  String get trainingFoodServings => 'Servings';

  @override
  String trainingFoodKcal(int kcal) {
    return '$kcal kcal';
  }

  @override
  String trainingFoodMacros(String p, String c, String f) {
    return 'Protein $p · Carbs $c · Fat $f';
  }

  @override
  String get trainingAddOwnFood => 'Add my own food';

  @override
  String get trainingFoodName => 'Food name';

  @override
  String get trainingFoodServingLabel => 'Serving (e.g. plate, 200 g)';

  @override
  String get trainingFoodCalories => 'Calories per serving';

  @override
  String get trainingFoodProtein => 'Protein (g)';

  @override
  String get trainingFoodCarbs => 'Carbs (g)';

  @override
  String get trainingFoodFat => 'Fat (g)';

  @override
  String get trainingFoodSection => 'Section';

  @override
  String get trainingFoodEmpty => 'No matching foods';

  @override
  String get trainingFoodApprox =>
      'Values are approximate for the serving named.';

  @override
  String get trainingMine => 'Added by you';

  @override
  String get trainingEditEntry => 'Edit';

  @override
  String get trainingDeleteOwnConfirm =>
      'Delete this entry? Plans that already use it keep their copy.';

  @override
  String get trainingAddOwnExercise => 'Add my own exercise';

  @override
  String get trainingOwnExerciseTitle => 'My exercise';

  @override
  String get trainingExerciseSection => 'Section';

  @override
  String get trainingExerciseInstructions => 'How to do it';

  @override
  String get trainingMealFromTable =>
      'From the table — calories are worked out for you';

  @override
  String get trainingLibraryEquipment => 'Equipment';

  @override
  String get addOnPricePerDay => 'Added to the day\'s price';

  @override
  String get invTitle => 'Investigation orders';

  @override
  String get invOrderTests => 'Order tests';

  @override
  String get invMyOrdersEmpty => 'No investigation orders yet.';

  @override
  String get invStatusIssued => 'Issued';

  @override
  String get invStatusSent => 'Sent to a centre';

  @override
  String get invStatusAccepted => 'Accepted';

  @override
  String get invStatusReady => 'Results ready';

  @override
  String get invStatusDeclined => 'Declined';

  @override
  String get invStatusCancelled => 'Cancelled';

  @override
  String get invStepIssued => 'Issued';

  @override
  String get invStepSent => 'Sent';

  @override
  String get invStepAccepted => 'Received';

  @override
  String get invStepReady => 'Results';

  @override
  String invFromDoctor(String doctor) {
    return 'From $doctor';
  }

  @override
  String get invOwnRequest => 'Own request';

  @override
  String get invKindLab => 'Test';

  @override
  String get invKindRadiology => 'Radiology';

  @override
  String invDoctorNote(String note) {
    return 'Doctor\'s note: $note';
  }

  @override
  String get invShareTitle => 'Share the order with a registered centre';

  @override
  String get invShareHint => 'The price of the whole order at each centre';

  @override
  String get invCoversAll => 'Covers every test';

  @override
  String invCoversSome(int covers, int of) {
    return 'Covers $covers of $of';
  }

  @override
  String get invShareNever =>
      'No centre receives the order until you choose it.';

  @override
  String invShareButton(String center) {
    return 'Share with $center';
  }

  @override
  String get invNoCenters => 'No registered centre does these tests yet.';

  @override
  String get invCancelOrder => 'Cancel the order';

  @override
  String get invCancelConfirm => 'Cancel this order?';

  @override
  String get invSent => 'The order was sent to the centre.';

  @override
  String get invResults => 'Results';

  @override
  String invCenterNote(String note) {
    return 'Centre\'s note: $note';
  }

  @override
  String invAppointment(String when) {
    return 'Appointment: $when';
  }

  @override
  String get invTotal => 'Total';

  @override
  String get invNotPriced => 'Not priced by this centre';

  @override
  String get hospitalTabDepartments => 'Departments & doctors';

  @override
  String get hospitalNoDepartments => 'No departments to show yet.';

  @override
  String get hospitalNoDoctors => 'No doctors in this department yet.';

  @override
  String hospitalDoctorCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count doctors',
      one: '1 doctor',
      zero: 'No doctors',
    );
    return '$_temp0';
  }

  @override
  String get hospitalManageTitle => 'Hospital departments & doctors';

  @override
  String get hospitalManageHint =>
      'Departments are the specialties you enabled in the business settings. Add doctors under each one.';

  @override
  String get hospitalManageNoDepartments =>
      'Enable the medical specialties in the business settings first and they will appear here as departments.';

  @override
  String get hospitalAddDoctor => 'Add a doctor';

  @override
  String get hospitalDoctorWithAccount => 'App account';

  @override
  String get hospitalDoctorNoAccount => 'No account';

  @override
  String get hospitalSearchDoctorHint => 'Search the doctor by name';

  @override
  String get hospitalInviteNote =>
      'The doctor appears in the department once they accept your invitation, and patients can visit their page from under it.';

  @override
  String get hospitalDoctorName => 'Doctor\'s name';

  @override
  String get hospitalDoctorTitle => 'Title (optional)';

  @override
  String get hospitalDoctorPending => 'Waiting for the doctor\'s approval';

  @override
  String get hospitalDoctorRemoveConfirm =>
      'Remove this doctor from the department?';

  @override
  String get hospitalInvitationsTitle => 'Hospital invitations';

  @override
  String get hospitalInvitationsEmpty => 'No invitations.';

  @override
  String get hospitalInvitationPendingSection =>
      'Invitations waiting for your answer';

  @override
  String get hospitalInvitationActiveSection => 'Listed among the doctors of';

  @override
  String get hospitalInvitationAccept => 'Accept';

  @override
  String get hospitalInvitationDecline => 'Decline';

  @override
  String get hospitalInvitationLeave => 'Stop appearing';

  @override
  String get procKindSurgery => 'General surgery';

  @override
  String get procKindOrthopedic => 'Bones and joints';

  @override
  String get procKindObstetrics => 'Obstetrics and gynecology';

  @override
  String get procKindUrology => 'Urology and kidneys';

  @override
  String get procKindEnt => 'Ear, nose and throat';

  @override
  String get procKindOphthalmology => 'Eye surgery';

  @override
  String get procKindCardiac => 'Heart, chest and vascular';

  @override
  String get procKindNeuro => 'Brain, nerves and spine';

  @override
  String get procKindPlastic => 'Plastic surgery and burns';

  @override
  String get procKindPediatric => 'Pediatric surgery';

  @override
  String get procKindOncology => 'Cancer surgery';

  @override
  String get procKindBariatric => 'Bariatric surgery';

  @override
  String get procKindMaxillofacial => 'Face, jaw and dental surgery';

  @override
  String get procKindEndoscopy => 'Endoscopies';

  @override
  String get procKindProcedure => 'Treatment procedures';

  @override
  String get procStatusRequested => 'Waiting for the hospital';

  @override
  String get procStatusAccepted => 'Scheduled';

  @override
  String get procStatusCompleted => 'Done';

  @override
  String get procStatusDeclined => 'Declined';

  @override
  String get procStatusCancelled => 'Cancelled';

  @override
  String get procPriceAfterAssessment => 'Price after assessment';

  @override
  String procScheduledAt(Object when) {
    return 'Scheduled: $when';
  }

  @override
  String procPreferredDate(Object date) {
    return 'Preferred day: $date';
  }

  @override
  String procHospitalNote(Object note) {
    return 'Hospital note: $note';
  }

  @override
  String get specialtyServicesTitle => 'Clinic services';

  @override
  String get specialtyServicesHint =>
      'Tick the services your clinic offers and write each price. Leave the price empty to show «Price after the exam».';

  @override
  String get specialtyPriceAfterExam => 'Price after the exam';

  @override
  String get specialtyAddOwn => 'Add a service';

  @override
  String get specialtyOwnName => 'Service name';

  @override
  String get dentalKindCheckup => 'X-rays and diagnosis';

  @override
  String get dentalKindPreventive => 'Prevention and cleaning';

  @override
  String get dentalKindRestorative => 'Fillings and restoration';

  @override
  String get dentalKindEndodontic => 'Root canal treatment';

  @override
  String get dentalKindPeriodontal => 'Gums';

  @override
  String get dentalKindSurgical => 'Surgery and implants';

  @override
  String get dentalKindProsthetic => 'Crowns, bridges and dentures';

  @override
  String get dentalKindOrthodontic => 'Braces';

  @override
  String get dentalKindCosmetic => 'Cosmetic dentistry';

  @override
  String get dentalKindPediatric => 'Children\'s dentistry';

  @override
  String get skinKindInjectables => 'Cosmetic injections';

  @override
  String get skinKindFaceLifting => 'Non-surgical face lifting';

  @override
  String get skinKindLaser => 'Laser';

  @override
  String get skinKindScars => 'Scars and wounds';

  @override
  String get skinKindPeels => 'Peels and skin care';

  @override
  String get skinKindSkinDisease => 'Skin diseases';

  @override
  String get skinKindHair => 'Hair and scalp';

  @override
  String get skinKindBody => 'Body';

  @override
  String get procTabTitle => 'Procedures';

  @override
  String get procNoneOffered => 'The hospital has not listed procedures yet.';

  @override
  String get procRequestSent => 'Your request was sent to the hospital.';

  @override
  String get procMyRequestsTitle => 'My hospital requests';

  @override
  String get procMyRequestsEmpty => 'No requests yet.';

  @override
  String get procPickPreferredDate => 'Preferred day (optional)';

  @override
  String get procAskButton => 'Request the procedure';

  @override
  String get procAskNote =>
      'The hospital answers with a date, and may ask to assess you before quoting a price.';

  @override
  String get procCancelRequest => 'Cancel the request';

  @override
  String get procManageTitle => 'Hospital medical procedures';

  @override
  String get procManageHint =>
      'Tick what the hospital performs and write its price. Leave the price empty to show «price after assessment».';

  @override
  String get procAddOwn => 'Add a procedure';

  @override
  String get procOwnName => 'Procedure name';

  @override
  String get procRequestsTitle => 'Procedure requests';

  @override
  String get procTabUpcoming => 'Upcoming';

  @override
  String get procRequestsEmpty => 'No requests.';

  @override
  String get procPickSchedule => 'Procedure date';

  @override
  String get procQuoteTitle => 'Price after assessment';

  @override
  String get procSkipQuote => 'No price';

  @override
  String get procAcceptSchedule => 'Accept and schedule';

  @override
  String get procMarkDone => 'Mark as done';

  @override
  String get importHubTitle => 'Import my data';

  @override
  String get importHubIntro =>
      'Bring your old data from an Excel or CSV file instead of starting from zero: choose what to import, then the file, then link its columns to ours.';

  @override
  String get importHubMenu => 'Menu and items';

  @override
  String get importHubMenuSub =>
      'Sections and their items with prices, sizes and extras';

  @override
  String get importHubPatients => 'Patient files';

  @override
  String get importHubPatientsSub =>
      'Patients and their history — kept on this device only';

  @override
  String get importHubUnits => 'Rooms and units';

  @override
  String get importHubUnitsSub =>
      'Rooms, courts or halls with their number, kind and capacity';

  @override
  String get unitsImportIntro =>
      'Pick the service and the unit type once, then the file: each row is a unit (number, name, kind, capacity and count). A unit with the same number already there is left as it is.';

  @override
  String get unitsImportService => 'Service';

  @override
  String get unitsImportType => 'Unit type';

  @override
  String get unitsImportKind => 'Unit kind when the file does not say';

  @override
  String get unitsImportKindHelp =>
      'The file\'s «type» column is matched with your kinds first';

  @override
  String get unitsImportKindNone => 'No kind';

  @override
  String get unitsImportNext => 'Next: choose the file';

  @override
  String get unitsImportNone =>
      'No service with bookable units on this account.';

  @override
  String get clinicStartVisit => 'Start the visit';

  @override
  String get clinicCreateFileShort => 'Create file';

  @override
  String get importHubNothing => 'Nothing to import for this account yet.';

  @override
  String get importPickFile => 'Choose a file';

  @override
  String get importTemplate => 'Ready template';

  @override
  String get importFileEmpty =>
      'The file is empty or has no rows below the header row.';

  @override
  String get importFileUnreadable =>
      'This file could not be read. Try an Excel (xlsx) or CSV file.';

  @override
  String importFileInfo(Object count, Object name) {
    return '$name — $count rows';
  }

  @override
  String get importMapHint =>
      'For each of our columns, pick the matching column of your file. We remember the link for similar files.';

  @override
  String get importNotUsed => '— not used —';

  @override
  String get importUnnamedColumn => 'unnamed';

  @override
  String importRun(Object count) {
    return 'Import $count rows';
  }

  @override
  String get importRequiredMissing => 'Link the required (*) columns first.';

  @override
  String get importDone => 'Import finished';

  @override
  String importCreated(Object count) {
    return 'New files: $count';
  }

  @override
  String importMerged(Object count) {
    return 'Added to existing files: $count';
  }

  @override
  String importSkipped(Object count) {
    return '$count rows skipped:';
  }

  @override
  String importSkippedRow(Object reason, Object row) {
    return 'Row $row: $reason';
  }

  @override
  String get patientFilesTitle => 'Patient files';

  @override
  String get patientFilesDeviceNote =>
      'These files are kept on this device only, encrypted, and are never uploaded to the server.';

  @override
  String get patientFilesSearch => 'Search by name or phone';

  @override
  String get patientFilesEmpty => 'No files on this device yet.';

  @override
  String get patientFilesImport => 'Import patient files';

  @override
  String get patientFilesImportIntro =>
      'From an Excel or CSV file: the patient\'s name is required, the rest is optional. Rows with the same phone are folded into one file with its visits, and nothing already there is duplicated.';

  @override
  String get patientFilesAdd => 'Add a patient';

  @override
  String patientFilesCount(Object count) {
    return '$count files';
  }

  @override
  String patientFileEntryCount(Object count) {
    return '$count entries';
  }

  @override
  String get patientFileName => 'Patient\'s name';

  @override
  String get patientFilePhone => 'Phone';

  @override
  String get patientFileNationalId => 'National ID';

  @override
  String get patientFileBirth => 'Date of birth';

  @override
  String get patientFileGender => 'Gender';

  @override
  String get patientFileChronic => 'Chronic conditions';

  @override
  String get patientFileAllergies => 'Allergies';

  @override
  String get patientFileNotes => 'Notes';

  @override
  String get patientFileEdit => 'Edit details';

  @override
  String get patientFileDelete => 'Delete the file';

  @override
  String get patientFileDeleteConfirm =>
      'Delete this file from the device for good?';

  @override
  String get patientFileAddEntry => 'Add an entry';

  @override
  String get patientFileEntryTitle => 'Title (diagnosis, test, scan, medicine)';

  @override
  String get patientFileEntryDetail => 'Details (optional)';

  @override
  String get patientFileNoEntries =>
      'No entries yet. Add a visit, a test, a scan or a medicine.';

  @override
  String get patientFileSendCopy => 'Send a copy to the patient';

  @override
  String get patientFileOpen => 'Patient file';

  @override
  String get patientFileCreate => 'Create a file for this patient';

  @override
  String get recordKindVisit => 'Visit';

  @override
  String get recordKindTest => 'Test';

  @override
  String get recordKindRadiology => 'Scan';

  @override
  String get recordKindMedicine => 'Medicine';

  @override
  String get recordKindNote => 'Note';

  @override
  String get medicalSectionRecords => 'Visits and tests history';

  @override
  String get medicalSaveToMyFile => 'Save a copy in my medical file';

  @override
  String get medicalSavedToMyFile =>
      'Saved in your medical file on this phone.';

  @override
  String get patientBackupTitle => 'Encrypted backup';

  @override
  String get patientBackupIntro =>
      'The patient files are gzipped and encrypted on this device with a passphrase only you know. Keep the backup as a file wherever you like (Drive, a flash drive, e-mail), or on the server, which can read nothing of it.';

  @override
  String get patientBackupPassphraseWarning =>
      'The passphrase is kept nowhere: if you forget it the backup is lost and cannot be recovered.';

  @override
  String get patientBackupNever => 'No backup has been made yet';

  @override
  String patientBackupLast(Object when) {
    return 'Last backup: $when';
  }

  @override
  String patientBackupChanged(Object changed, Object total) {
    return '$changed of $total files changed since';
  }

  @override
  String get patientBackupToFile => 'Save a backup as a file';

  @override
  String get patientBackupToServer => 'Save an encrypted backup on the server';

  @override
  String get patientBackupRestoreTitle => 'Restore';

  @override
  String get patientBackupFromFile => 'Restore from a file';

  @override
  String get patientBackupFromServer => 'Restore from the server';

  @override
  String get patientBackupMergeNote =>
      'Restoring merges: it adds the files that are missing and replaces a file only with a newer copy of it.';

  @override
  String get patientBackupDeleteServerCopy => 'Delete the server copy';

  @override
  String get patientBackupServerDeleted => 'The server copy was deleted.';

  @override
  String get patientBackupFileMade => 'The backup is ready.';

  @override
  String get patientBackupServerDone => 'The backup was saved on the server.';

  @override
  String get patientBackupNoServerCopy => 'There is no copy on the server.';

  @override
  String get patientBackupWrongPassphrase =>
      'Wrong passphrase, or the file is not a patient-files backup.';

  @override
  String get patientBackupFailed => 'The operation could not be completed.';

  @override
  String patientBackupRestored(Object added, Object updated) {
    return '$added files added, $updated updated.';
  }

  @override
  String get patientBackupChoosePassphrase =>
      'Choose a passphrase for the backup';

  @override
  String get patientBackupEnterPassphrase => 'Enter the backup\'s passphrase';

  @override
  String get patientBackupPassphrase => 'Passphrase';

  @override
  String get patientBackupPassphraseAgain => 'Type the passphrase again';

  @override
  String patientBackupPassphraseShort(Object min) {
    return 'The passphrase needs at least $min characters.';
  }

  @override
  String get patientBackupPassphraseMismatch =>
      'The two passphrases do not match.';

  @override
  String get invWriteResults => 'Write the results';

  @override
  String get invResultsTextHint =>
      'Write each test result here, or paste it as the lab system has it: it is read in the app as text and saves space. Use photos only for what is not text (a film, a signed paper).';

  @override
  String get invResultHint => 'e.g. Hb 13.2 g/dL (12–16)';

  @override
  String get invAddResultPhotos => 'Add photos (for what is not text)';

  @override
  String invResultPhotosCount(Object count) {
    return '$count photos attached';
  }

  @override
  String get invSendResults => 'Send the results';

  @override
  String get invSaveToMyFile => 'Save a copy in my file';

  @override
  String get invSavedToMyFile =>
      'The results were saved in your medical file on this phone.';

  @override
  String get invShareWithDoctor => 'Share the results with the doctor';

  @override
  String get invResultsAsText => 'Results';

  @override
  String get invIssuedTitle => 'Tests I ordered';

  @override
  String invIssuedFor(Object name) {
    return '$name\'s tests';
  }

  @override
  String get invIssuedEmpty => 'No investigation orders.';

  @override
  String get invDoctorOrders => 'Patient\'s tests';

  @override
  String invDoctorOrdersReady(Object count) {
    return 'Results ready ($count)';
  }

  @override
  String get invDoctorHiddenNote =>
      'The doctor\'s name is not shown to the lab or the radiology centre.';

  @override
  String get invKeepPhotosOnPhone => 'Keep the photos on this phone';

  @override
  String get invPhotosKept =>
      'The photos are kept on your phone. The server\'s copy is deleted once the doctor has read them.';

  @override
  String get invPhotosKeptLocal => 'Kept on this phone';

  @override
  String invPhotosExpire(Object date) {
    return 'The result photos will be deleted from the server on $date unless you keep them on your phone.';
  }

  @override
  String get invPhotosPurgedNoCopy =>
      'The result photos were deleted from the server and there is no copy on this phone.';

  @override
  String get invPhotosSaveFailed =>
      'The photos could not be downloaded. Try again.';

  @override
  String get invAddResultDicom => 'Attach DICOM scans';

  @override
  String invResultDicomCount(Object n) {
    return 'DICOM files: $n';
  }

  @override
  String invDicomStudy(Object n) {
    return 'DICOM study $n';
  }

  @override
  String get invDicomHint =>
      'A scan file — opens in a DICOM viewer on your phone';

  @override
  String get invOpenDicom => 'Open / share';

  @override
  String get invDicomOpenFailed =>
      'Could not download the scan file. Try again.';

  @override
  String get invAddResultPdf => 'Attach a PDF report';

  @override
  String invResultPdfCount(Object count) {
    return '$count PDF attached';
  }

  @override
  String invPdfReport(Object n) {
    return 'PDF report $n';
  }

  @override
  String get invOpenPdf => 'Open';

  @override
  String get invPdfOpenFailed => 'The file could not be opened.';

  @override
  String get invCurrency => 'EGP';

  @override
  String get invIssueTitle => 'Order tests';

  @override
  String invIssueForPatient(String name) {
    return 'For patient: $name';
  }

  @override
  String get invTabLab => 'Tests';

  @override
  String get invTabRadiology => 'Radiology';

  @override
  String get invSearchHint => 'Search the list';

  @override
  String get invNotesLabel => 'Notes (optional)';

  @override
  String invSelectedCount(int count) {
    return 'In the order: $count';
  }

  @override
  String get invNothingSelected => 'Nothing chosen yet';

  @override
  String get invSendToPatient => 'Send the order to the patient';

  @override
  String get invIssued => 'The order was sent to the patient.';

  @override
  String get invCenterTitle => 'Investigation orders';

  @override
  String get invTabIncoming => 'Incoming';

  @override
  String get invTabAccepted => 'In progress';

  @override
  String get invTabDone => 'Done';

  @override
  String get invCenterEmpty => 'No orders here.';

  @override
  String get invAccept => 'Accept and set a time';

  @override
  String get invDecline => 'Decline';

  @override
  String get invAttachResults => 'Upload the results';

  @override
  String get invPickAppointment => 'Pick a time';

  @override
  String get invResultsAttached => 'The results were uploaded.';

  @override
  String get invPriceList => 'Test prices';

  @override
  String get invPriceListHint =>
      'Write your price for each test you do, and leave the rest empty.';

  @override
  String get invPriceLabel => 'Price';

  @override
  String get invPricesSaved => 'Prices saved.';

  @override
  String get invPickTests => 'Choose the tests';

  @override
  String get invAttachPaper => 'Photo of the doctor\'s request (optional)';

  @override
  String get invSendRequest => 'Send the request';

  @override
  String get invRequestSent => 'Your request was sent to the centre.';

  @override
  String get invNoTests => 'This centre has not priced its tests yet.';

  @override
  String get invKeepOrder => 'Keep the order';

  @override
  String get workingHoursTitle => 'Working hours';

  @override
  String get workingHoursTileSubtitle =>
      'Days of the week, opening and closing time, or open 24 hours';

  @override
  String get workingHoursOpen24 => 'Open 24 hours';

  @override
  String get bookingSettingsCheckTab => 'Check-in / out';

  @override
  String businessHoursClosesAt(String time) {
    return 'Closes at $time';
  }

  @override
  String businessHoursClosesIn(String left) {
    return '$left left until closing';
  }

  @override
  String businessHoursOpensAt(String time) {
    return 'Opens at $time';
  }

  @override
  String get businessHoursClosedToday => 'Closed today';

  @override
  String get clinicDayClosed => 'Closed';

  @override
  String get clinicDayNoSlots => 'Full';

  @override
  String get staffIsPhysician => 'Treating physician';

  @override
  String get staffIsPhysicianHint =>
      'His name is on his visits, prescriptions and test orders; patients can choose him, he has his own schedule and sees only his patients.';

  @override
  String get staffPhysicianBadge => 'Physician';

  @override
  String get clinicPickPhysician => 'Physician';

  @override
  String get myAppointmentsTitle => 'My appointments';

  @override
  String clinicWithPhysician(Object name) {
    return 'Treating physician: $name';
  }

  @override
  String get clinicSlotsForPhysician => 'Physician\'s times';

  @override
  String get clinicSlotsForHospital =>
      'The hospital itself (no physician named)';

  @override
  String get treatingPhysicianLabel => 'Treating physician';

  @override
  String assigneeLine(String name) {
    return 'Responsible: $name';
  }

  @override
  String get assigneeTitle => 'Responsible';

  @override
  String get assigneeNobody => 'Nobody assigned yet';

  @override
  String get assigneeAssign => 'Assign';

  @override
  String get assigneeChange => 'Change';

  @override
  String get assigneePickTitle => 'Choose who is responsible for this';

  @override
  String get assigneeRelease => 'Unassign';

  @override
  String get staffIsProvider => 'Serves customers directly';

  @override
  String get staffIsProviderHint =>
      'Bookings can be assigned to him, and he sees only the ones assigned to him.';

  @override
  String get staffProviderBadge => 'Service provider';

  @override
  String get staffDepartment => 'Department';

  @override
  String get staffNoDepartment => 'No department';

  @override
  String get procStatusAdvised => 'Physician’s decision — awaiting your answer';

  @override
  String procDecisionBy(String name) {
    return 'Physician’s decision: $name';
  }

  @override
  String get procConfirmDecision => 'Confirm the procedure';

  @override
  String get procDeclineDecision => 'Decline';

  @override
  String get procDecisionAction => 'Procedure decision';

  @override
  String get procDecisionTitle => 'Procedure decision';

  @override
  String get procDecisionNotes => 'Notes for the patient (optional)';

  @override
  String get procDecisionSend => 'Send the decision to the patient';

  @override
  String get procDecisionSent => 'The decision was sent to the patient.';

  @override
  String get procDecisionNone =>
      'The hospital has not listed any procedure yet.';

  @override
  String get staffPhysicianBundle =>
      'Includes: clinic appointments, prescriptions, test and radiology orders, and procedure decisions.';

  @override
  String get invPackage => 'Package';

  @override
  String get invPackagesTitle => 'Packages';

  @override
  String get invPackagesHeading => 'Packages';

  @override
  String invIncludes(String names) {
    return 'Includes: $names';
  }

  @override
  String get invHomeCollection => 'Sample collection at home';

  @override
  String get invPickDay => 'Day';

  @override
  String get invPickTime => 'Time';

  @override
  String get invNoTimes => 'No times on this day.';

  @override
  String get invChooseTime => 'Choose a day and time';

  @override
  String invRequestedAt(String when) {
    return 'Requested time: $when';
  }

  @override
  String get invPackageAdd => 'Add a package';

  @override
  String get invPackageEdit => 'Edit the package';

  @override
  String get invPackageName => 'Package name';

  @override
  String get invPackagePrice => 'Package price';

  @override
  String get invPackageNote => 'Note (optional)';

  @override
  String get invPackageTests => 'Tests it includes';

  @override
  String get invPackageSave => 'Save the package';

  @override
  String get invPackageHidden => 'Hidden from patients';

  @override
  String get invPackageShow => 'Shown to patients';

  @override
  String get invPackagesEmpty =>
      'No packages yet. Add one price for several tests.';

  @override
  String get invPackageNeedTests =>
      'Pick at least one test and write the price.';

  @override
  String get invPackagesHint =>
      'What you price here is shown on your page and paid as it is, not as the sum of its tests.';

  @override
  String get invHomeFeeLabel => 'Fee for taking the sample at home';

  @override
  String get invHomeFeeHint =>
      'Leave it empty if the lab does not take samples at home.';

  @override
  String get invHomeFeeSaved => 'Price saved.';

  @override
  String get invPriceListActionPackages => 'Packages';

  @override
  String externalDepositOwed(String amount) {
    return 'Deposit owed outside the platform: $amount EGP';
  }

  @override
  String get externalDepositWaiting =>
      'The booking does not start until you confirm you received it or accept the booking without it.';

  @override
  String get externalDepositCash => 'Received in cash';

  @override
  String get externalDepositTransfer => 'Received by transfer';

  @override
  String get externalDepositWaive => 'Accept the deposit — no payment outside';

  @override
  String get externalDepositReceived =>
      'The deposit was confirmed as received.';

  @override
  String get externalDepositWaived =>
      'The booking was accepted with no deposit.';

  @override
  String externalDepositCustomerNote(String amount) {
    return 'Pay the deposit ($amount EGP) to the business directly, in cash or by transfer. The booking does not start until the business confirms it.';
  }

  @override
  String get depositAsPaymentOffer =>
      'You may take the frozen deposit as a payment toward the booking instead of a payment outside the platform.';

  @override
  String get bookingsReschedule => 'Change the time';

  @override
  String get bookingsRescheduleTitle => 'Pick the new day';

  @override
  String get bookingsRescheduled =>
      'Time changed. If the booking was accepted, the business answers the new time.';

  @override
  String get visitDepositTitle => 'Seriousness deposit';

  @override
  String visitDepositQuotedWalletPatient(String amount) {
    return 'The business asks for a $amount EGP deposit, frozen in your wallet when the visit is confirmed and returned to you afterwards.';
  }

  @override
  String visitDepositQuotedExternalPatient(String amount) {
    return 'The business asks for a $amount EGP deposit, paid to it directly in cash or by transfer outside the platform.';
  }

  @override
  String visitDepositQuotedWalletBusiness(String amount, String counter) {
    return 'A $amount EGP deposit is frozen from the patient, and you freeze $counter EGP when you confirm.';
  }

  @override
  String visitDepositQuotedExternalBusiness(String amount) {
    return 'The patient pays you the $amount EGP deposit directly; you record that it arrived after confirming.';
  }

  @override
  String visitDepositHeld(String amount, String counter) {
    return 'Deposit frozen: $amount EGP from the patient and $counter EGP from the business. Both go back after the visit is done.';
  }

  @override
  String visitDepositHeldClientOnly(String amount) {
    return 'Deposit frozen: $amount EGP from the patient. It goes back to them after the visit is done.';
  }

  @override
  String visitDepositPendingPatient(String amount) {
    return 'Pay the deposit ($amount EGP) to the business directly, in cash or by transfer outside the platform.';
  }

  @override
  String visitDepositPendingBusiness(String amount) {
    return 'The $amount EGP deposit is owed outside the platform — record that it arrived, or accept without it.';
  }

  @override
  String get visitDepositReceivedCash =>
      'The business received the deposit in cash.';

  @override
  String get visitDepositReceivedTransfer =>
      'The business received the deposit by transfer.';

  @override
  String get visitDepositWaived =>
      'The business accepted the visit without a deposit.';

  @override
  String get visitDepositReleased =>
      'The deposit went back to both after the visit.';

  @override
  String get visitDepositRefunded => 'The deposit went back to both.';

  @override
  String get visitDepositDisputed =>
      'The deposit is under an open dispute until a ruling.';

  @override
  String get visitDepositResolved =>
      'The deposit was settled by an arbitration ruling.';

  @override
  String get visitDepositGiveBack => 'Give the deposit back';

  @override
  String get visitDepositGiveBackDone => 'The deposit went back to both.';

  @override
  String get visitDepositDispute => 'Open a dispute over the deposit';

  @override
  String get visitDepositDisputeOpened => 'The dispute was opened.';

  @override
  String get bookingTermsNeedGuarantee =>
      'To switch on the frozen deposit or the customer’s guarantee your business needs an active guarantee standing behind its share. Activate your guarantee first, or choose «transfer outside the platform».';

  @override
  String visitDepositFromGuarantee(String amount) {
    return '$amount EGP of it stands on the patient’s guarantee instead of the wallet.';
  }

  @override
  String visitDepositBusinessFromGuarantee(String amount) {
    return 'The business’s share ($amount EGP) stands on its guarantee.';
  }

  @override
  String guaranteeBadgeTooltip(String level, String amount) {
    return 'Guarantee level: $level — covers up to $amount EGP';
  }

  @override
  String guaranteeBadgeTitle(String level) {
    return 'Guarantee level: $level';
  }

  @override
  String guaranteeBadgeBody(String amount) {
    return 'This is the account’s guarantee level on the platform; it covers its operations up to $amount EGP, so you know which level you are dealing with.';
  }

  @override
  String orderDepositQuotedCustomer(String amount) {
    return 'This order needs $amount EGP of cover: frozen from your guarantee first, then your wallet, when the business accepts; it goes back after delivery and payment confirmation.';
  }

  @override
  String orderDepositQuotedBusiness(String amount) {
    return 'This order’s cover is $amount EGP: frozen from the customer’s guarantee first, then his wallet, when you accept; it goes back after delivery and payment confirmation.';
  }

  @override
  String orderDepositHeld(String amount) {
    return 'The order’s $amount EGP cover is frozen until delivery and payment confirmation.';
  }

  @override
  String get guarantorInviteButton => 'Ask a friend to stand for you';

  @override
  String get guarantorSheetTitle => 'A friend as guarantor';

  @override
  String guarantorSheetBody(String amount) {
    return 'You are $amount EGP short of the deposit. A friend with an active guarantee freezes a part of it until the operation ends, then it goes back to him in full.';
  }

  @override
  String get guarantorNoNeed =>
      'Your guarantee and wallet cover the deposit now. You may still invite a friend.';

  @override
  String get guarantorFieldHint => 'Friend’s phone or email';

  @override
  String get guarantorSend => 'Send the invitation';

  @override
  String get guarantorSent => 'The invitation was sent.';

  @override
  String get guarantorStatusInvited => 'Waiting for an answer';

  @override
  String guarantorStatusAccepted(String amount) {
    return 'Accepted and froze $amount EGP of his guarantee';
  }

  @override
  String get guarantorStatusDeclined => 'Declined';

  @override
  String get guarantorStatusReleased => 'His guarantee went back to him';

  @override
  String get guarantorStatusCancelled => 'The invitation was cancelled';

  @override
  String get guarantorRequestTitle => 'Guarantee request';

  @override
  String guarantorRequestBody(String name) {
    return '$name asks you to stand for an operation: a part of your guarantee is frozen until it ends, then returned in full — nothing is deducted.';
  }

  @override
  String guarantorAvailable(String amount) {
    return 'Free in your guarantee: $amount EGP';
  }

  @override
  String get guarantorAmountLabel => 'Amount to freeze from your guarantee';

  @override
  String get guarantorAccept => 'I will stand for it';

  @override
  String get guarantorDecline => 'Decline';

  @override
  String get guarantorAccepted =>
      'A part of your guarantee is frozen for this operation.';

  @override
  String get tripReservationNoShowAction => 'No-show';

  @override
  String get tripReservationStatusNoShow => 'No-show';

  @override
  String get tripStatusNoShow => 'You did not show';

  @override
  String get tripReserveWithFriend => 'Reserve with a friend standing for you';

  @override
  String get tripFriendPathHint =>
      'Your friend gets a guarantee request after the reservation, and the carrier confirms once it is covered.';

  @override
  String tripDepositQuotedBusiness(String amount) {
    return 'A $amount EGP deposit is frozen from the passenger when you confirm the reservation.';
  }

  @override
  String tripDepositQuotedCustomer(String amount) {
    return 'The carrier asks for a $amount EGP deposit; it is frozen from your guarantee or wallet when the carrier confirms, and goes back to you after the trip.';
  }

  @override
  String tripDepositHeld(String amount) {
    return 'The $amount EGP deposit is frozen and goes back once the trip is done.';
  }

  @override
  String visitDepositQuotedWalletBusinessNoCounter(String amount) {
    return 'A $amount EGP deposit is frozen from the patient when you confirm.';
  }

  @override
  String get guarantorFromContacts => 'Pick from your friends and family';

  @override
  String get guarantorOrByContact => 'Or invite by phone or email:';

  @override
  String get tripOfflineRatingVisible => 'Shown in ratings (fee paid)';

  @override
  String get tripOfflineNotCounted =>
      'Off-app — not in ratings or counts until the fee is paid';

  @override
  String get tripOfflineShowInRatingAction => 'Show in ratings';

  @override
  String get tripOfflineAddTitle => 'Add a passenger from outside the app';

  @override
  String get tripOfflineNameLabel => 'Passenger name';

  @override
  String get tripOfflinePhoneLabel => 'Phone (optional)';

  @override
  String get tripOfflineUnitsLabel => 'Seats';

  @override
  String get tripOfflineAdded => 'The passenger was added and the seat held.';

  @override
  String get tripAttendanceConfirmAction => 'Confirm attendance';

  @override
  String get tripAttendanceWaitingClient => 'Waiting for the customer';

  @override
  String get tripAttendanceConfirmAsClient => 'I am here — confirm';

  @override
  String get tripAttendanceWaitingCarrier =>
      'You confirmed; waiting for the driver';

  @override
  String get tripAttendanceBothConfirmed => 'Attendance confirmed by both';

  @override
  String get tripReservationStatusBlocked => 'Manual hold';

  @override
  String get tripRunPartialTitle => 'Start the trip short?';

  @override
  String get tripRunPartialBody =>
      'The trip is not full, or not everyone confirmed attendance. Do you accept starting it as it is?';

  @override
  String get tripRunPartialConfirm => 'I accept, start';

  @override
  String get tripFullNotice => 'This trip is full.';

  @override
  String get parcelStatusRequested => 'Waiting for the driver to price it';

  @override
  String get parcelStatusPriced => 'Waiting for you to accept the price';

  @override
  String get parcelStatusAccepted => 'Accepted';

  @override
  String get parcelStatusLoaded => 'On the car';

  @override
  String get parcelStatusDelivered => 'Delivered';

  @override
  String get parcelStatusRejected => 'Rejected';

  @override
  String get parcelStatusCancelled => 'Cancelled';

  @override
  String get parcelRequestTitle => 'Send a parcel with the trip';

  @override
  String get parcelDescriptionLabel => 'Describe the parcel';

  @override
  String get parcelDescriptionHelp =>
      'Size, weight and where it rides (e.g. small box, 20 kg, in the boot)';

  @override
  String get parcelReceiverTitle => 'Receiver';

  @override
  String get parcelReceiverNoAccount => 'Or a receiver with no account:';

  @override
  String get parcelReceiverName => 'Receiver name';

  @override
  String get parcelReceiverPhone => 'Receiver phone';

  @override
  String get parcelReceiverRequired =>
      'Pick the receiver from your groups, or write a name and a phone.';

  @override
  String get parcelSendRequest => 'Send the request';

  @override
  String get parcelRequestSent =>
      'The parcel request was sent. The driver will price it.';

  @override
  String get parcelSendInstead => 'Send a parcel with this trip';

  @override
  String get myParcelsTitle => 'My parcels';

  @override
  String get myParcelsEmpty => 'No parcels yet.';

  @override
  String get parcelAcceptPrice => 'Accept the price';

  @override
  String get parcelRegenerateCode => 'New code';

  @override
  String get parcelCancel => 'Cancel';

  @override
  String get parcelCodeHint =>
      'Give this code to the receiver; they hand it to the driver on receipt.';

  @override
  String parcelTakesSeats(int count) {
    return 'takes $count seat(s)';
  }

  @override
  String get carrierParcelsTitle => 'Parcels';

  @override
  String get carrierParcelsEmpty => 'No parcels on your legs.';

  @override
  String get parcelSender => 'Sender';

  @override
  String get parcelSetPrice => 'Set the price';

  @override
  String get parcelPriceTitle => 'Parcel price';

  @override
  String get parcelPriceLabel => 'Price';

  @override
  String get parcelSeatsLabel => 'Seats it takes';

  @override
  String get parcelSeatsHelp => '0 when it rides in the boot';

  @override
  String get parcelLoadAction => 'Load on the car';

  @override
  String get parcelDeliverAction => 'Hand over';

  @override
  String get parcelDeliverTitle => 'Hand over the parcel';

  @override
  String get parcelDeliverCodeLabel => 'Delivery code';

  @override
  String get parcelDeliverCodeHelp =>
      'Ask the receiver for it — the parcel is not handed over without it';

  @override
  String parcelDeliveredAt(String time) {
    return 'Delivered: $time';
  }

  @override
  String get parcelStatusReturned => 'Not handed over (came back)';

  @override
  String get parcelWhoPaysTitle => 'Who pays the driver (cash)';

  @override
  String get parcelPayerSender => 'The sender, handing it to the driver';

  @override
  String get parcelPayerReceiver => 'The receiver, on receipt';

  @override
  String get parcelPickupCodeHint =>
      'The driver scans this QR (or types its code) to take the parcel from you.';

  @override
  String get parcelPickupTitle => 'Take the parcel from the sender';

  @override
  String get parcelPickupHint => 'Scan the sender QR or type its code';

  @override
  String parcelExpectedArrival(String time) {
    return 'Expected arrival (approximate): $time';
  }

  @override
  String get parcelExpectedArrivalPick => 'Set the approximate arrival';

  @override
  String get parcelCashTitle => 'Collect the amount';

  @override
  String parcelCashBody(String amount, String currency) {
    return 'Did you collect $amount $currency in cash now? (recorded only)';
  }

  @override
  String get parcelCashNotYet => 'Not yet';

  @override
  String get parcelCashCollected => 'Yes, collected';

  @override
  String get handoverScanQr => 'Scan QR';

  @override
  String get handoverOrTypeCode => 'Or type the code:';

  @override
  String get handoverCodeLabel => 'Code';

  @override
  String get handoverConfirmTyped => 'Confirm the typed code';

  @override
  String get clinicOptionsTitle => 'Clinic options';

  @override
  String get clinicArrivalQrTitle => 'Arrival QR';

  @override
  String get clinicArrivalQrHint =>
      'The patient scans it on arrival to be activated in the queue. Optional.';

  @override
  String get clinicArrivalQrRotate => 'New code';

  @override
  String get clinicDayClosureTitle => 'Day is full';

  @override
  String get clinicDayClosureBody =>
      'Closes new bookings for today. Optional — you may add working hours instead.';

  @override
  String clinicDayClosureClosedOn(String date) {
    return 'Closed to new bookings on $date';
  }

  @override
  String get clinicArriveAction => 'I arrived — scan the clinic QR';

  @override
  String get clinicArriveHint =>
      'Scan the code shown at the clinic to confirm you arrived';

  @override
  String get clinicArriveDone =>
      'Your arrival is recorded. You are in the queue now.';

  @override
  String get tripFullBadge => 'Full';

  @override
  String get handoverShowCode => 'Show the code';

  @override
  String get handoverHideCode => 'Hide the code';

  @override
  String get guestBookingTitle => 'Add a guest';

  @override
  String get guestBookingAction => 'Book for the guest';

  @override
  String get guestNameLabel => 'Guest name';

  @override
  String get guestPhoneLabel => 'Guest\'s phone';

  @override
  String get guestPhoneHint => 'If he has an account the booking goes on it';

  @override
  String get guestLookupAction => 'Look up';

  @override
  String guestAccountFound(String name) {
    return 'Has an account: $name';
  }

  @override
  String get guestNoAccount =>
      'No account for this phone — recorded by name only, never counted or rated.';

  @override
  String get guestOfferingLabel => 'Service';

  @override
  String get guestUnitLabel => 'Unit';

  @override
  String get guestStartLabel => 'Start';

  @override
  String get guestEndLabel => 'End (optional)';

  @override
  String get guestPartySizeLabel => 'People';

  @override
  String get guestBookingDone => 'Booked for the guest';

  @override
  String get guestChip => 'Off-app guest';

  @override
  String returningCustomerBadge(int count) {
    return 'Returning customer · $count previous dealings';
  }

  @override
  String get bookingAttendanceCustomerDone =>
      'The customer confirmed attendance';

  @override
  String get bookingAttendanceCustomerWaiting =>
      'Waiting for the customer to confirm attendance';

  @override
  String get bookingAttendanceBusinessDone => 'You confirmed attendance';

  @override
  String get relationshipTitleBusiness => 'This customer’s dealings with you';

  @override
  String get relationshipTitleCustomer => 'Your dealings with this business';

  @override
  String relationshipSummaryLine(int total, int completed, int notCompleted) {
    return '$total dealings · $completed successful · $notCompleted not completed';
  }

  @override
  String get relationshipNoDisputes => 'No disputes, no problems';

  @override
  String relationshipDisputes(int count, int open) {
    return 'Disputes: $count ($open open)';
  }

  @override
  String get rideRequestTitle => 'Request a ride';

  @override
  String get rideRequestIntro =>
      'Say from where to where and for how much; drivers answer with their prices and you pick the best.';

  @override
  String get rideFromLabel => 'From';

  @override
  String get rideToLabel => 'To';

  @override
  String get ridePassengersLabel => 'Passengers';

  @override
  String get rideWhenLabel => 'When';

  @override
  String get rideWhenNow => 'Now';

  @override
  String get rideWhenPick => 'Pick a time';

  @override
  String get rideDistanceLabel => 'Approximate distance (km)';

  @override
  String get rideDistanceNeeded =>
      'The ride stays in one city: write the approximate distance.';

  @override
  String rideDistanceKm(String km) {
    return 'About $km km';
  }

  @override
  String rideSuggestedPrice(String price) {
    return 'Suggested price $price EGP';
  }

  @override
  String get ridePriceLabel => 'The price you offer (EGP)';

  @override
  String get rideDetailsLabel => 'Notes for the driver (optional)';

  @override
  String get rideSubmit => 'Post the request';

  @override
  String get rideFieldsRequired => 'Choose where from and where to.';

  @override
  String get rideAllRequestsTitle => 'My requests';

  @override
  String get rideIncomingTitle => 'Ride requests';

  @override
  String get requestStatusOpen => 'Open';

  @override
  String get requestStatusAccepted => 'Chosen';

  @override
  String get requestStatusCancelled => 'Cancelled';

  @override
  String get requestStatusExpired => 'Expired';

  @override
  String requestOffersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count offers',
      one: '1 offer',
      zero: 'No offers',
    );
    return '$_temp0';
  }

  @override
  String get requestsEmpty => 'No requests yet.';

  @override
  String get requestNoOffers => 'No offers yet. You are told at the first one.';

  @override
  String requestYourPrice(String price) {
    return 'Your price $price EGP';
  }

  @override
  String requestPassengersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count passengers',
      one: '1 passenger',
    );
    return '$_temp0';
  }

  @override
  String get requestOfferAccept => 'Accept this offer';

  @override
  String get requestOfferAcceptsYourPrice => 'Takes your price';

  @override
  String requestOfferEta(int minutes) {
    return 'Reaches you in $minutes min';
  }

  @override
  String get requestChangePrice => 'Change the price';

  @override
  String get requestCancel => 'Cancel the request';

  @override
  String get requestCancelConfirm =>
      'The offers are turned down and the drivers told. Cancel the request?';

  @override
  String get requestCancelled => 'The request is cancelled.';

  @override
  String get requestBookingMade =>
      'The offer is chosen and your booking is made.';

  @override
  String get requestOpenBooking => 'Open the booking';

  @override
  String get requestOfferPriceLabel => 'Your price (EGP)';

  @override
  String requestOfferAcceptBudget(String price) {
    return 'Take the customer\'s price ($price EGP)';
  }

  @override
  String get requestOfferMessageLabel =>
      'A message for the customer (optional)';

  @override
  String get requestOfferEtaLabel => 'I reach him in (minutes)';

  @override
  String get requestOfferSend => 'Send my offer';

  @override
  String get requestOfferWithdraw => 'Withdraw my offer';

  @override
  String get requestOfferSent => 'Your offer was sent.';

  @override
  String get requestOfferWithdrawn => 'Your offer was withdrawn.';

  @override
  String requestMyOffer(String price) {
    return 'Your offer: $price EGP';
  }

  @override
  String requestCustomerPrice(String price) {
    return 'Customer\'s price: $price EGP';
  }

  @override
  String get requestsIncomingEmpty => 'No open requests in your area now.';

  @override
  String requestFrom(String name) {
    return 'From $name';
  }

  @override
  String get techPricingRentPerDay => 'Price per day (EGP)';

  @override
  String get roomsTitleCar => 'Cars';

  @override
  String get roomsTitleUnit => 'Units';

  @override
  String get roomsHintCar =>
      'Your own list. The customer books the kind of car and does not see these numbers until the rental starts. Write the plate numbers.';

  @override
  String get roomsHintUnit =>
      'Your own list. The customer books the kind and does not see these codes before it starts. Write codes or a range like 1-10.';

  @override
  String get roomsNumbersFieldCar => 'Plate numbers';

  @override
  String get roomsNumbersFieldUnit => 'Unit codes';

  @override
  String get stayDiscountTitle => 'Week and month discount';

  @override
  String get stayDiscountHint =>
      'The longer the stay the less it costs: a percentage off the total for 7 days or more, a larger one for 30 days or more.';

  @override
  String get stayDiscountWeekly => 'Week discount %';

  @override
  String get stayDiscountMonthly => 'Month discount %';

  @override
  String get carWantedTitle => 'I want a car';

  @override
  String get carWantedIntro =>
      'Say what you are after; showrooms and owners in your governorate answer with what they have. Pick the best offer and book a viewing.';

  @override
  String get carDealBuy => 'Buy';

  @override
  String get carDealRent => 'Rent';

  @override
  String get carTypeLabel => 'Kind of car';

  @override
  String get carBrandLabel => 'Make';

  @override
  String get carAnyChoice => 'Any';

  @override
  String get carYearMinLabel => 'From year';

  @override
  String get carMaxPriceBuy => 'Highest price (EGP)';

  @override
  String get carMaxPriceRent => 'Highest price per day (EGP)';

  @override
  String get carDaysLabel => 'Number of days';

  @override
  String get carViewingWhen => 'Viewing time (optional)';

  @override
  String get carWantedSubmit => 'Post my request';

  @override
  String get carGovernorateRequired => 'Choose the governorate and city.';

  @override
  String get carWantedAcceptViewing => 'Accept and book the viewing';

  @override
  String carOfferItem(String name) {
    return 'The car: $name';
  }

  @override
  String get carOfferPickItem => 'Point at one of your cars (optional)';

  @override
  String get carOfferNoItem => 'No particular car';

  @override
  String carRentDaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String carYearFrom(String year) {
    return 'From $year';
  }

  @override
  String carMaxPriceIs(String price) {
    return 'Up to $price EGP';
  }

  @override
  String get requestsAnswerTitle => 'Customers\' requests';

  @override
  String get requestKindRide => 'Rides';

  @override
  String get requestKindCar => 'Cars';

  @override
  String get carDetailsLabel => 'Notes (optional)';

  @override
  String get requestNewTitle => 'New request';

  @override
  String get hotelRoomsTitle => 'Book a room';

  @override
  String get hotelRoomsFilter => 'Filter';

  @override
  String hotelRoomsFilterCount(int count) {
    return 'Filter · $count';
  }

  @override
  String get hotelRoomsClear => 'Clear all';

  @override
  String get hotelRoomsApply => 'Show rooms';

  @override
  String get hotelRoomsClassLabel => 'Hotel class';

  @override
  String get hotelRoomsPriceLabel => 'Price per night';

  @override
  String get hotelRoomsPriceFrom => 'From';

  @override
  String get hotelRoomsPriceTo => 'To';

  @override
  String get hotelRoomsCityChip => 'City';

  @override
  String get hotelRoomsEmpty => 'No rooms match your filter.';

  @override
  String hotelRoomsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rooms',
      one: '1 room',
      zero: 'No rooms',
    );
    return '$_temp0';
  }

  @override
  String hotelRoomsPricePerNight(String price, String currency) {
    return '$price $currency per night';
  }

  @override
  String get hotelRoomsOtherPrices => 'Other prices for the same room';

  @override
  String get hotelRoomsCheaperThanHotel => 'Lower than the hotel\'s own price.';

  @override
  String get hotelRoomsSearchEntry => 'Find a room by hotel class';

  @override
  String get hotelRoomsDatesLabel => 'Dates of stay';

  @override
  String get hotelRoomsDatesPick => 'Pick check-in and check-out';

  @override
  String hotelRoomsNights(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nights',
      one: '1 night',
    );
    return '$_temp0';
  }

  @override
  String hotelRoomsTotalFor(String total, String currency, String nights) {
    return 'Total $total $currency for $nights';
  }

  @override
  String get bookingChooseStay => 'Choose the days of your stay';

  @override
  String bookingStayNights(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nights',
      one: '1 night',
    );
    return '$_temp0';
  }

  @override
  String bookingStayCheckInOut(String checkIn, String checkOut) {
    return 'Check-in $checkIn, check-out $checkOut';
  }

  @override
  String get emptyReturnTitle => 'Empty return';

  @override
  String get emptyReturnSectionTitle => 'Drivers going back empty on this line';

  @override
  String get emptyReturnSectionHint =>
      'A cheaper ride: the driver is heading back anyway and sets his own price.';

  @override
  String emptyReturnSaving(String percent) {
    return 'Save $percent%';
  }

  @override
  String emptyReturnPriceEgp(String price) {
    return '$price EGP';
  }

  @override
  String emptyReturnUsualFare(String price) {
    return 'Usual fare $price EGP';
  }

  @override
  String emptyReturnDeparts(String when) {
    return 'Leaves $when';
  }

  @override
  String emptyReturnSeats(String n) {
    return 'Up to $n passengers';
  }

  @override
  String get emptyReturnBook => 'Book this ride';

  @override
  String get emptyReturnBookTitle => 'Book this return ride?';

  @override
  String emptyReturnBookBody(String driver, String when, String price) {
    return '$driver · $when · $price EGP. The booking is confirmed once the driver accepts it.';
  }

  @override
  String get emptyReturnBooked => 'Booked — waiting for the driver to confirm.';

  @override
  String get emptyReturnDriverIntro =>
      'Going back without a passenger? Offer the way home at a lower price and earn on the trip back.';

  @override
  String get emptyReturnPublishTitle => 'Publish a return';

  @override
  String get emptyReturnFrom => 'I am going from';

  @override
  String get emptyReturnTo => 'to';

  @override
  String get emptyReturnWhen => 'Leaving at';

  @override
  String get emptyReturnPriceLabel => 'Your price for the whole car (EGP)';

  @override
  String emptyReturnPriceHelp(String price, String ref) {
    return 'Suggested $price EGP — the usual fare is $ref EGP and you cannot go above it.';
  }

  @override
  String get emptyReturnSeatsLabel => 'Passengers it takes';

  @override
  String get emptyReturnNotesLabel => 'Notes (optional)';

  @override
  String get emptyReturnPublish => 'Publish';

  @override
  String get emptyReturnPublished =>
      'Published — customers on this line can book it.';

  @override
  String get emptyReturnMineTitle => 'My offers';

  @override
  String get emptyReturnNone => 'You have not published any return yet.';

  @override
  String get emptyReturnCancel => 'Take it down';

  @override
  String get emptyReturnCancelled => 'The offer was taken down.';

  @override
  String get emptyReturnStatusLive => 'Shown to customers';

  @override
  String get emptyReturnStatusPassed => 'Time passed';

  @override
  String get emptyReturnStatusCancelled => 'Taken down';

  @override
  String get emptyReturnChooseCities => 'Choose both cities.';

  @override
  String get emptyReturnChooseWhen => 'Choose when you leave.';

  @override
  String tripLegEveryDay(String day) {
    return 'Every $day';
  }

  @override
  String tripLegEveryDayAt(String day, String time) {
    return 'Every $day · $time';
  }

  @override
  String tripReservationWithCarrier(String name) {
    return 'With $name';
  }

  @override
  String get requestsAvailableTitle => 'Taking requests';

  @override
  String get requestsAvailableOn =>
      'Customers\' requests reach you. Switch off when you want a break.';

  @override
  String get requestsAvailableOff =>
      'On a break: no new requests reach you, you cannot answer, and your return offers are hidden.';

  @override
  String get emptyReturnSuggestionsTitle => 'Your rides — offer the way back';

  @override
  String emptyReturnSuggestionAfter(String when) {
    return 'After your ride at $when';
  }

  @override
  String get emptyReturnSuggestionUse => 'Offer the way back';

  @override
  String emptyReturnForRide(String when) {
    return 'The way back of your ride at $when';
  }

  @override
  String get homeServiceTitle => 'I need a technician';

  @override
  String get homeServiceIntro =>
      'Say which trade and what is wrong. The technicians of that trade in your governorate send you their quotes and you pick one.';

  @override
  String get homeServiceTradeLabel => 'Type of technician';

  @override
  String get homeServiceJobLabel => 'What is the problem?';

  @override
  String get homeServiceNoAddress =>
      'Only the city is shared. Your address is shown only to the technician you choose, once you accept his offer.';

  @override
  String get homeServiceWhenLabel => 'When do you want him? (optional)';

  @override
  String get homeServiceAnyTime => 'Any time';

  @override
  String get homeServiceBudgetLabel => 'The most you would pay (optional)';

  @override
  String homeServiceBudgetIs(String price) {
    return 'Up to $price EGP';
  }

  @override
  String get homeServiceSubmit => 'Ask for quotes';

  @override
  String get homeServiceTradeRequired =>
      'Choose the type of technician and your city.';

  @override
  String get homeServicePhotosLabel =>
      'Photos of the problem (optional, up to 4)';

  @override
  String get homeServicePhotosHint =>
      'Only the technicians your request reached see them, and they are deleted when the request or the visit is over.';

  @override
  String get homeVisitAddressTitle => 'Where should the technician come?';

  @override
  String get homeVisitAddressHint =>
      'Only the technician you chose sees this address.';

  @override
  String get homeVisitNoAddress =>
      'You have no saved address. Add your address first.';

  @override
  String get homeVisitAddAddress => 'Add an address';

  @override
  String get homeVisitChoose => 'Choose this offer';

  @override
  String get homeVisitTitle => 'Technician visit';

  @override
  String get homeVisitAddress => 'Address';

  @override
  String get homeVisitOpenMap => 'Open in maps';

  @override
  String get homeVisitPhotos => 'Photos of the problem';

  @override
  String get requestKindHome => 'Technicians';

  @override
  String get workQuoteTitle => 'Ask a workshop or factory for a quote';

  @override
  String get workQuoteIntro =>
      'Say what you want made or mended. The workshops or factories of that trade send you their price and how many days they need, and you pick one.';

  @override
  String get workQuoteTradeLabel => 'Type of workshop or factory';

  @override
  String get workQuoteWhatLabel => 'What do you want? (short)';

  @override
  String get workQuoteDetailsLabel =>
      'Specification: sizes, materials, colours…';

  @override
  String get workQuoteQuantityLabel => 'Quantity';

  @override
  String get workQuoteUnitLabel => 'Unit (piece, metre…)';

  @override
  String get workQuoteDeadlineLabel => 'Needed by (optional)';

  @override
  String get workQuoteNationwide =>
      'Any workshop or factory in Egypt may answer';

  @override
  String get workQuoteNationwideHelp =>
      'Off: only those in your governorate. On: factories elsewhere that deliver may answer too.';

  @override
  String get workQuoteSubmit => 'Ask for quotes';

  @override
  String get workQuoteRequired =>
      'Choose the type, say what you want and give the specification (at least 10 letters), and choose your city.';

  @override
  String workQuoteQuantityIs(String n, String unit) {
    return 'Quantity $n $unit';
  }

  @override
  String workQuoteDeadlineIs(String date) {
    return 'Needed by $date';
  }

  @override
  String get workQuoteNationwideShort => 'Any governorate';

  @override
  String get workQuoteOfferDaysLabel => 'Days I need to finish';

  @override
  String workQuoteOfferDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Ready in $days days',
      one: 'Ready in 1 day',
    );
    return '$_temp0';
  }

  @override
  String get requestKindQuote => 'Quotes';

  @override
  String get olTitle => 'Owner listings';

  @override
  String get olTileSubtitle =>
      'Sell or rent a car, a flat or any used thing — no business account';

  @override
  String get olCarsEntry => 'Cars from their owners — buy, rent, or list yours';

  @override
  String get olPropertyEntry =>
      'Flats from their owners — buy, rent, or list yours';

  @override
  String get olMine => 'My listings';

  @override
  String get olMyChats => 'My conversations';

  @override
  String get olAll => 'All';

  @override
  String get olSearchHint => 'Search listings';

  @override
  String get olEmpty => 'No listings here yet.';

  @override
  String get olMineEmpty => 'You have not posted anything yet.';

  @override
  String get olChatsEmpty => 'No conversations yet.';

  @override
  String get olAdd => 'Add a listing';

  @override
  String get olDealSale => 'For sale';

  @override
  String get olDealRent => 'For rent';

  @override
  String get olDealSwap => 'Swap';

  @override
  String get olPerDay => 'per day';

  @override
  String get olPerWeek => 'per week';

  @override
  String get olPerMonth => 'per month';

  @override
  String get olPriceOpen => 'Price on agreement';

  @override
  String get olCurrency => 'EGP';

  @override
  String get olFormTitleNew => 'New listing';

  @override
  String get olFormTitleEdit => 'Edit listing';

  @override
  String get olCategoryLabel => 'Category';

  @override
  String get olTitleLabel => 'Title (at least 3 letters)';

  @override
  String get olDescriptionLabel => 'Description';

  @override
  String get olPriceLabel => 'Price (EGP)';

  @override
  String get olPriceOptionalLabel => 'Value (optional)';

  @override
  String get olPriceUnitLabel => 'Rent period';

  @override
  String get olPlaceRequired => 'Choose the governorate and the city.';

  @override
  String get olNeedPhoto =>
      'Add at least one photo so people can see your listing.';

  @override
  String get olDetails => 'Details';

  @override
  String get olPhotosTitle => 'Photos (at least one)';

  @override
  String get olAddPhotoCamera => 'Camera';

  @override
  String get olAddPhotoGallery => 'Gallery';

  @override
  String get olSave => 'Publish';

  @override
  String get olSaveEdit => 'Save changes';

  @override
  String olOwnerIs(String name) {
    return 'Listed by $name';
  }

  @override
  String get olNoPhoneNote =>
      'The phone number is hidden. Chat here; when you agree, swap numbers (the platform charges a fee).';

  @override
  String get olContact => 'Message the owner';

  @override
  String get olReport => 'Report this listing';

  @override
  String get olReported => 'We received your report, thank you.';

  @override
  String get olFinish => 'Sold / rented — finish it';

  @override
  String get olFinishHint =>
      'The listing is hidden now and deleted after 3 days.';

  @override
  String get olFinishSold => 'Sold';

  @override
  String get olFinishRented => 'Rented';

  @override
  String get olFinishSwapped => 'Swapped';

  @override
  String get olFinishWithdrawn => 'I withdraw it';

  @override
  String get olRenew => 'Renew for 60 days';

  @override
  String get olDelete => 'Delete now';

  @override
  String get olDeleteConfirm => 'Delete the listing, its photos and its chats?';

  @override
  String get olEdit => 'Edit';

  @override
  String get olStatusActive => 'Live';

  @override
  String get olStatusFlagged => 'Hidden: people reported it';

  @override
  String get olStatusDone => 'Finished';

  @override
  String get olStatusExpired => 'Expired';

  @override
  String get olNoPhotoHidden => 'Not shown yet: add a photo';

  @override
  String olDeletesOn(String date) {
    return 'Deleted on $date';
  }

  @override
  String olExpiresOn(String date) {
    return 'Live until $date';
  }

  @override
  String olInquiriesCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n conversations',
      one: '1 conversation',
    );
    return '$_temp0';
  }

  @override
  String get olIAmBuyer => 'I am the buyer';

  @override
  String get olIAmSeller => 'I am the seller';

  @override
  String get olNumbersSwapped => 'numbers swapped';

  @override
  String get olAsksToSwap => 'asks to swap numbers';

  @override
  String get olWeAgree => 'We agree — swap numbers';

  @override
  String olFeeLine(String fee, String share) {
    return 'Platform fee $fee EGP, your share $share EGP';
  }

  @override
  String olFeeLineOther(String fee) {
    return 'Platform fee $fee EGP (paid by the other side)';
  }

  @override
  String get olRevealWaiting => 'Waiting for the other side to accept.';

  @override
  String olRevealAsked(String name) {
    return '$name asks to swap numbers.';
  }

  @override
  String get olRevealAccept => 'Accept and pay my share';

  @override
  String get olRevealDecline => 'Not yet';

  @override
  String get olRevealWithdraw => 'Withdraw the request';

  @override
  String olPhoneIs(String name, String phone) {
    return '$name\'s number: $phone';
  }

  @override
  String get olCopy => 'Copy';

  @override
  String get olListingEnded => 'This listing has ended.';

  @override
  String get reportTitle => 'Report';

  @override
  String get reportDetailsHint => 'More details (optional)';

  @override
  String get reportSend => 'Send report';

  @override
  String get reportSent => 'We received your report, thank you.';

  @override
  String get reportAction => 'Report';

  @override
  String get modTitle => 'Moderation';

  @override
  String get modOpen => 'Open';

  @override
  String get modHandled => 'Handled';

  @override
  String get modEmpty => 'No reports.';

  @override
  String get modDismiss => 'Dismiss report';

  @override
  String get modRemove => 'Remove';

  @override
  String get modRestore => 'Restore';

  @override
  String get modRemovePostConfirm =>
      'Hide this post? You can restore it later.';

  @override
  String get modRemoveListingConfirm =>
      'Delete this listing with its photos and chats for good?';

  @override
  String get modStateLive => 'Live';

  @override
  String get modStateHidden => 'Hidden';

  @override
  String get modStateGone => 'Deleted';

  @override
  String get modTypePost => 'Post';

  @override
  String get modTypeListing => 'Owner listing';

  @override
  String modByAuthor(String name) {
    return 'By $name';
  }

  @override
  String modReportsCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n reports',
      one: '1 report',
    );
    return '$_temp0';
  }

  @override
  String get trainingPaidExpired =>
      'The month is over — the plan is hidden from the client';

  @override
  String get trainingPaidHint =>
      'The service fee is taken when you share it and at every monthly renewal. Editing the plan after the month renews it.';

  @override
  String get trainingRenew => 'Renew for another month';

  @override
  String get trainingRenewConfirm =>
      'Renew the plan for another month? The service fee will be taken again.';

  @override
  String get trainingRenewed => 'The plan was renewed.';

  @override
  String trainingPaidUntil(String date) {
    return 'Paid month until $date';
  }

  @override
  String get trainingEditDetails => 'Edit plan details';

  @override
  String get bodyCalcTitle => 'Healthy weight calculator';

  @override
  String get bodyCalcMale => 'Male';

  @override
  String get bodyCalcFemale => 'Female';

  @override
  String get bodyCalcAge => 'Age (years)';

  @override
  String get bodyCalcHeight => 'Height (cm)';

  @override
  String get bodyCalcWeight => 'Weight (kg)';

  @override
  String get bodyCalcActivity => 'Activity level';

  @override
  String get bodyCalcActSedentary => 'Little movement (desk job)';

  @override
  String get bodyCalcActLight => 'Light (exercise 1–3 days)';

  @override
  String get bodyCalcActModerate => 'Moderate (exercise 3–5 days)';

  @override
  String get bodyCalcActActive => 'High (exercise 6–7 days)';

  @override
  String get bodyCalcActVery => 'Very high (twice a day or heavy work)';

  @override
  String get bodyCalcEnter =>
      'Enter your age, height and weight to see the result.';

  @override
  String get bodyCalcBmi => 'Body mass index';

  @override
  String get bodyCalcUnderweight => 'Underweight';

  @override
  String get bodyCalcNormal => 'Normal weight';

  @override
  String get bodyCalcOverweight => 'Overweight';

  @override
  String get bodyCalcObese => 'Obese';

  @override
  String get bodyCalcMinor =>
      'Adult tables do not apply under 18. Ask your doctor what weight suits your age.';

  @override
  String get bodyCalcInRange =>
      'Your weight is inside the healthy range for your height.';

  @override
  String get bodyCalcDisclaimer =>
      'A rough estimate; it does not replace your doctor or dietitian.';

  @override
  String bodyCalcHealthyRange(String min, String max) {
    return 'Healthy weight for your height: $min to $max kg';
  }

  @override
  String bodyCalcIdeal(String kg) {
    return 'Approximate ideal weight: $kg kg';
  }

  @override
  String bodyCalcLose(String kg) {
    return 'To reach the healthy range, lose about $kg kg.';
  }

  @override
  String bodyCalcGain(String kg) {
    return 'To reach the healthy range, gain about $kg kg.';
  }

  @override
  String bodyCalcBmr(String kcal) {
    return 'What your body burns at rest: $kcal kcal/day';
  }

  @override
  String bodyCalcMaintain(String kcal) {
    return 'Calories to keep your current weight: $kcal kcal/day';
  }

  @override
  String get modOpenReport => 'Open the report and deal with it';

  @override
  String get modRelease => 'Release the report';

  @override
  String modInHands(String name) {
    return '$name is dealing with this report';
  }

  @override
  String modHandledBy(String name) {
    return 'Closed by $name';
  }

  @override
  String get trainingExpiredShort => 'Month over';

  @override
  String get modTypeComment => 'Comment';

  @override
  String get modRemoveCommentConfirm => 'Hide this comment from everyone?';

  @override
  String get bodyCalcGoal => 'Your goal';

  @override
  String get bodyCalcGoalLose => 'Lose weight';

  @override
  String get bodyCalcGoalMaintain => 'Keep my weight';

  @override
  String get bodyCalcGoalGain => 'Gain weight';

  @override
  String get bodyCalcTape => 'More measurements (optional)';

  @override
  String get bodyCalcTapeHint =>
      'Waist and neck (and hips for women) to estimate body fat';

  @override
  String get bodyCalcWaist => 'Waist (cm)';

  @override
  String get bodyCalcNeck => 'Neck (cm)';

  @override
  String get bodyCalcHip => 'Hips (cm)';

  @override
  String get bodyCalcComposition => 'Body composition';

  @override
  String get bodyCalcFatEssential => 'Essential';

  @override
  String get bodyCalcFatAthletic => 'Athletic';

  @override
  String get bodyCalcFatFitness => 'Fit';

  @override
  String get bodyCalcFatAverage => 'Average';

  @override
  String get bodyCalcFatHigh => 'High';

  @override
  String get bodyCalcFatFromTape =>
      'Estimated from the tape measures (US Navy method)';

  @override
  String get bodyCalcFatFromReport =>
      'From the last report your trainer measured';

  @override
  String get bodyCalcWhtOk => 'within the usual range';

  @override
  String get bodyCalcWhtHigh => 'high';

  @override
  String get bodyCalcNeeds => 'Your daily needs';

  @override
  String get bodyCalcSave => 'Save this measurement on my phone';

  @override
  String get bodyCalcSaved => 'The measurement was saved on your phone.';

  @override
  String get bodyCalcHistory => 'My saved measurements';

  @override
  String get bodyCalcHistoryHint =>
      'Kept on this phone only and never sent anywhere.';

  @override
  String get bodyCalcSinceBefore => 'since the one before';

  @override
  String bodyCalcFat(String p) {
    return 'Body fat: $p%';
  }

  @override
  String bodyCalcLean(String kg) {
    return 'Lean mass: $kg kg';
  }

  @override
  String bodyCalcMuscle(String kg) {
    return 'Recorded muscle mass: $kg kg';
  }

  @override
  String bodyCalcWht(String r, String verdict) {
    return 'Waist ÷ height: $r — $verdict (usually under 0.5)';
  }

  @override
  String bodyCalcWhr(String r, String verdict) {
    return 'Waist ÷ hip: $r — $verdict';
  }

  @override
  String bodyCalcTarget(String goal, String kcal) {
    return 'Calories for your goal ($goal): $kcal kcal/day';
  }

  @override
  String bodyCalcProtein(String min, String max) {
    return 'Protein: $min to $max g/day';
  }

  @override
  String bodyCalcWater(String l) {
    return 'Water: about $l L/day';
  }

  @override
  String bodyCalcKgUnit(String kg) {
    return '$kg kg';
  }

  @override
  String bodyCalcRecorded(String kg, String date) {
    return 'Last weight recorded on your account: $kg kg ($date)';
  }

  @override
  String get olSeriousTitle => 'Seriousness of the listing';

  @override
  String get olDepositAgreeFirst =>
      'Agree to the seriousness deposit to publish your listing.';

  @override
  String get olDepositNoBalance =>
      'Your balance is not enough for the seriousness deposit. Top up your wallet first.';

  @override
  String olSeriousGuaranteeOk(String level) {
    return 'Your $level+ guarantee is enough — no deposit on your listing.';
  }

  @override
  String olSeriousBody(String level, String amount) {
    return 'To publish you need a $level guarantee or higher, or a seriousness deposit of $amount EGP held from your wallet and handed back when you sell or end the listing.';
  }

  @override
  String olSeriousAgree(String amount) {
    return 'I agree to hold $amount EGP from my wallet until the listing ends';
  }

  @override
  String olDepositHeld(String amount) {
    return 'Seriousness deposit: $amount EGP held, handed back when you sell or end it.';
  }

  @override
  String olDepositReleased(String amount) {
    return 'Seriousness deposit: $amount EGP — handed back to your wallet.';
  }

  @override
  String get olFilterPlace => 'Governorate / city';

  @override
  String get olFilterClear => 'Clear the place filter';

  @override
  String get olVisTitle => 'Who sees your listing?';

  @override
  String get olVisAll => 'Everyone';

  @override
  String get olVisGovernorate => 'My governorate';

  @override
  String get olVisCity => 'My city';

  @override
  String get olVisNeedsCity =>
      'Choose the city to limit the listing to its people.';

  @override
  String get olVisBadgeCity => 'Shown to the people of its city only';

  @override
  String get olVisBadgeGovernorate =>
      'Shown to the people of its governorate only';

  @override
  String get olRulesWarnTitle =>
      'Warning: the deposit or guarantee can be confiscated';

  @override
  String get olRulesWarnBodyDeposit =>
      'If your listing breaks the rules and a moderator removes it, your seriousness deposit is confiscated. It is confiscated if any of these reasons applies:';

  @override
  String get olRulesWarnBodyGuarantee =>
      'If your listing breaks the rules and a moderator removes it, the frozen guarantee is confiscated. It is confiscated if any of these reasons applies:';

  @override
  String get olGuaranteeReleased =>
      'The guarantee frozen for this listing was released.';

  @override
  String get modViolationTitle => 'Which rule did the listing break?';

  @override
  String get modConfiscate => 'Confiscate the deposit or guarantee';

  @override
  String olGuaranteeFrozen(String amount) {
    return 'Your guarantee is frozen ($amount EGP) for the life of the listing and released when you sell or end it.';
  }

  @override
  String get modTypeAccount => 'Account';

  @override
  String get modStateFrozen => 'Frozen';

  @override
  String get modOpenChat => 'Open a chat';

  @override
  String get modFreeze => 'Freeze 3 days';

  @override
  String get modUnfreeze => 'Lift the freeze';

  @override
  String get modFreezeConfirm =>
      'Freeze this account for three days? It is not deleted, and it can only talk to the moderators.';

  @override
  String get frozenTitle => 'Account frozen';

  @override
  String get frozenHeadline => 'Your account is temporarily frozen';

  @override
  String get frozenBody =>
      'We received reports about your account and a moderator froze it for three days. You can talk to the moderators so they can check what happened.';

  @override
  String get frozenChat => 'Chat with the moderators';

  @override
  String get frozenChatTitle => 'Moderators';

  @override
  String get frozenNoChatYet =>
      'A moderator will open a chat with you to clarify the reason; it will appear here.';

  @override
  String get frozenRefresh => 'Refresh';

  @override
  String get frozenLogout => 'Log out';

  @override
  String frozenUntil(String date) {
    return 'Your account works again after $date';
  }

  @override
  String get modAccountDeleted =>
      'The account was deleted and its balance and guarantee were confiscated.';

  @override
  String frozenWarnTitle(int count, int limit) {
    return 'Warning: this is freeze $count of $limit';
  }

  @override
  String frozenWarnBody(int limit) {
    return 'If it is frozen $limit times within 12 months, deleting the account and confiscating its balance and guarantee goes to a panel of moderators, and you may object.';
  }

  @override
  String modFreezeConfirmCount(int count, int limit) {
    return 'Freeze this account for three days? This is freeze $count of $limit; the account is not deleted now.';
  }

  @override
  String modFreezeConfirmLast(int limit) {
    return 'This is freeze $limit: the account will be deleted and its balance and guarantee confiscated for good. Continue?';
  }

  @override
  String get reportChatAction => 'Report this conversation';

  @override
  String get reportChatPick =>
      'Pick the messages you want to show the moderator (optional)';

  @override
  String reportChatPickHint(int count) {
    return 'The moderator cannot read the whole chat without both parties\' consent or a quorum of moderators. Selected: $count';
  }

  @override
  String get reportChatContinue => 'Continue';

  @override
  String reportChatAttached(int count) {
    return '$count messages will be shown to the moderator with the report';
  }

  @override
  String get modTypeConversation => 'Conversation';

  @override
  String get modConversationTitle => 'Reported conversation';

  @override
  String modConversationParties(String names) {
    return 'Between: $names';
  }

  @override
  String get modSelectedMessages => 'Messages the reporter chose';

  @override
  String get modNoSelectedMessages => 'The reporter chose no messages.';

  @override
  String get modConsentAll => 'Both parties agreed';

  @override
  String get modConsentDeclined => 'One party declined';

  @override
  String get modConsentPending => 'Waiting for both parties';

  @override
  String modQuorumStatus(int n, int q) {
    return 'Moderator quorum $n/$q';
  }

  @override
  String get modConversationOpen => 'Conversation is open';

  @override
  String get modConversationClosed => 'Conversation is closed';

  @override
  String get modAskConsent => 'Ask both parties\' consent';

  @override
  String modVouch(int n, int q) {
    return 'Vouch to read ($n/$q)';
  }

  @override
  String get modReadConversation => 'Read the conversation';

  @override
  String get modFreezeConfirmPlain =>
      'This account will be frozen for three days. Continue?';

  @override
  String get panelTitle => 'Deletion decisions';

  @override
  String get panelEmpty => 'No deletion decisions are waiting for a vote.';

  @override
  String get panelFifthFreeze =>
      'Fifth freeze within 12 months: deleting the account and confiscating its balance and guarantee is proposed.';

  @override
  String get panelSecondRound =>
      'The account owner objected: the case is reviewed a second time.';

  @override
  String get panelFreezes => 'Earlier freezes and their reasons';

  @override
  String get panelObjection => 'The account owner\'s objection';

  @override
  String panelTally(int a, int an, int r, int rn) {
    return 'Approvals $a/$an · Rejections $r/$rn';
  }

  @override
  String get panelApprove => 'Approve deletion';

  @override
  String get panelReject => 'Reject deletion';

  @override
  String get panelVoted =>
      'Your vote is recorded. Waiting for the other moderators.';

  @override
  String get deletionReview =>
      'A panel of moderators is reviewing the deletion of your account. You will be notified of the decision.';

  @override
  String deletionScheduled(String when) {
    return 'The moderators\' panel decided to delete your account on $when and confiscate its balance and guarantee. You can object in writing before then.';
  }

  @override
  String get deletionObjected =>
      'Your objection was received and is under review. The account is not deleted before they decide.';

  @override
  String get objectAction => 'Object to the deletion';

  @override
  String get objectTitle => 'Your objection';

  @override
  String get objectHint =>
      'Explain clearly why your account should not be deleted';

  @override
  String orderPreparingBy(String name) {
    return 'Being prepared by $name';
  }

  @override
  String orderPreparedBy(String name) {
    return 'Prepared by $name';
  }

  @override
  String orderAcceptedBy(String name) {
    return 'Accepted by $name';
  }

  @override
  String get providerPickTitle => 'Choose who serves you';

  @override
  String get providerAnyone => 'Anyone available';

  @override
  String projectForOperation(int id) {
    return 'Project for operation $id';
  }

  @override
  String get projectTemplatePick => 'Start from a ready plan';

  @override
  String projectTemplateSummary(int stages, int days) {
    return '$stages stages · about $days days';
  }

  @override
  String get taskRequiresApproval =>
      'Asks for the customer\'s approval when done';

  @override
  String get taskTakePhoto => 'Take a photo of the stage';

  @override
  String get approvalPendingBusiness => 'Waiting for the customer\'s approval';

  @override
  String get approvalPendingCustomer =>
      'This stage is waiting for your approval';

  @override
  String get approvalApproved => 'Approved by the customer';

  @override
  String approvalRejectedWithNote(String note) {
    return 'Sent back by the customer: $note';
  }

  @override
  String get approvalApprove => 'Approve the stage';

  @override
  String get approvalReject => 'Send back';

  @override
  String get approvalRejectTitle => 'Your note on the stage';

  @override
  String get approvalRejectHint => 'Say what has to change';

  @override
  String get myStagesTitle => 'My stages';

  @override
  String get myStagesEmpty => 'No stages are assigned to you right now.';

  @override
  String get myStagesPhotoSaved => 'Photo saved';

  @override
  String myStagesDue(String date) {
    return 'Due $date';
  }

  @override
  String get myStagesPlus25 => '+25%';

  @override
  String projectCardStage(String stage) {
    return 'Current stage: $stage';
  }

  @override
  String projectCardStageBy(String stage, String name) {
    return 'Current stage: $stage — $name';
  }

  @override
  String projectCardWaiting(int count) {
    return '$count stage(s) waiting for your approval';
  }

  @override
  String get projectStartForOperation => 'Start a project for this operation';

  @override
  String get agreementTitle => 'Agreement on the plan';

  @override
  String agreementDue(String date) {
    return 'Delivery date: $date';
  }

  @override
  String agreementGrace(String date) {
    return 'Grace ends: $date';
  }

  @override
  String agreementVersion(int n) {
    return 'Version $n';
  }

  @override
  String get agreementStatusProposed => 'Waiting for the customer';

  @override
  String get agreementStatusAgreed => 'Agreed';

  @override
  String agreementAgreedOn(String date) {
    return 'Customer agreed $date';
  }

  @override
  String get agreementPropose => 'Offer the plan to the customer';

  @override
  String get agreementProposeDue => 'Delivery date';

  @override
  String get agreementProposeGrace => 'Grace days after delivery';

  @override
  String get agreementNeedsOperation =>
      'Link the project to a customer\'s order or booking to offer him the plan.';

  @override
  String get agreementWaitingCustomer => 'Waiting for the customer';

  @override
  String get agreementAgree => 'I agree to the plan';

  @override
  String get agreementDecline => 'Decline';

  @override
  String get agreementDeclineHint => 'Write the reason';

  @override
  String get extensionRequest => 'Ask for more time';

  @override
  String get requestExtensionTitle => 'Ask to extend the grace';

  @override
  String get extensionDays => 'Number of days';

  @override
  String get extensionReason => 'Reason';

  @override
  String get extensionSent => 'The request was sent to the customer';

  @override
  String requestExtensionLine(int days, String date) {
    return 'Extend the grace by $days days, to $date';
  }

  @override
  String requestScopePlanned(String from, String to) {
    return 'Change a planned quantity from $from to $to';
  }

  @override
  String requestScopeAdd(String name, String planned) {
    return 'Add a quantity: $name = $planned';
  }

  @override
  String requestScopeDelete(String name) {
    return 'Remove a quantity: $name';
  }

  @override
  String get requestScopeLine => 'Change of scope';

  @override
  String get requestApproved => 'The customer approved';

  @override
  String requestRejectedWith(String note) {
    return 'The customer declined: $note';
  }

  @override
  String get requestApprove => 'Approve';

  @override
  String get requestReject => 'Decline';

  @override
  String get startRequest => 'Ask to start the stage';

  @override
  String get startRequestSent => 'The start request was sent to the customer';

  @override
  String get startRequested => 'Waiting for the customer to approve the start';

  @override
  String get startApproved => 'Started with the customer\'s approval';

  @override
  String startDeclined(String note) {
    return 'The customer declined the start: $note';
  }

  @override
  String get startNotRequested => 'Start not requested yet';

  @override
  String get startApproveAction => 'I approve starting the stage';

  @override
  String get startDeclineAction => 'Not now';

  @override
  String stageWorks(int n) {
    return '$n works';
  }

  @override
  String get itemsTitle => 'Quantities';

  @override
  String get itemsEmpty => 'No quantities recorded for this work yet.';

  @override
  String get itemAdd => 'Add a quantity';

  @override
  String get itemName => 'Item (e.g. number of columns)';

  @override
  String get itemUnit => 'Unit';

  @override
  String get itemPlanned => 'Planned';

  @override
  String get itemDone => 'Done';

  @override
  String get itemReason => 'Reason for the change (optional)';

  @override
  String get itemRequestSent =>
      'The request was sent to the customer and nothing changes before he approves';

  @override
  String get taskDetailsTitle => 'Quantities and details';

  @override
  String get taskZone => 'Place (e.g. third floor / flat 2)';

  @override
  String get taskDetails => 'Details and specifications';

  @override
  String get quantityLogTitle => 'Quantity change log';

  @override
  String get quantityLogEmpty => 'No changes yet';

  @override
  String get quantityLogViaRequest => 'with the customer\'s approval';

  @override
  String get quantityLogCreated => 'Added';

  @override
  String get quantityLogDeleted => 'Removed';

  @override
  String get buildingGenerate => 'Residential building with floors and flats';

  @override
  String get buildingFloors => 'Number of floors (including ground)';

  @override
  String get buildingFlats => 'Flats per floor';

  @override
  String get buildingBasement => 'Has a basement';

  @override
  String buildingGenerated(int n) {
    return '$n works were generated';
  }

  @override
  String get agreementProposeStart => 'Execution starts';

  @override
  String get agreementProposeStartHint =>
      'A future date; the time until then is the negotiation';

  @override
  String get agreementRequireGuarantee =>
      'Guarantee required of the customer before work begins';

  @override
  String get agreementNoGuarantee => 'No condition';

  @override
  String get guaranteeBronze => 'Bronze or higher';

  @override
  String get guaranteeSilver => 'Silver or higher';

  @override
  String get guaranteeGold => 'Gold or higher';

  @override
  String guaranteeRequired(String level) {
    return 'The business requires a $level guarantee at least on the customer\'s account';
  }

  @override
  String guaranteeRequirementMet(String level) {
    return 'Your guarantee meets the business\'s condition: $level or higher';
  }

  @override
  String guaranteeRequirementNotMet(String level) {
    return 'The business requires a $level guarantee or higher on your account before agreeing and starting work';
  }

  @override
  String get shiftPlan => 'Postpone the plan';

  @override
  String get shiftStage => 'Postpone this stage';

  @override
  String get shiftPlanTitle => 'Postpone the plan';

  @override
  String shiftStageTitle(String stage) {
    return 'Postpone the stage: $stage';
  }

  @override
  String get shiftWeek => 'A week';

  @override
  String get shiftTwoWeeks => 'Two weeks';

  @override
  String get shiftMonth => 'A month';

  @override
  String get shiftPickDate => 'Pick a start date';

  @override
  String get shiftApplied => 'The dates were postponed';

  @override
  String get shiftRequestSent =>
      'The request was sent to the other side and nothing changes before they approve';

  @override
  String get shiftAskPostpone => 'Ask to postpone';

  @override
  String get shiftScopePlan => 'the whole plan';

  @override
  String get shiftScopeStage => 'a stage';

  @override
  String requestShiftLine(int days, String scope) {
    return 'Postpone $scope by $days days';
  }

  @override
  String agreementStart(String date) {
    return 'Execution starts: $date';
  }

  @override
  String get buildingElevator => 'The building has a lift';

  @override
  String get showcaseVerifiedBadge => 'Verified by the customer';

  @override
  String get showcaseAskAction => 'Show the project as a post';

  @override
  String get showcaseAskTitle => 'Show the project as a post';

  @override
  String get showcaseAskHint =>
      'Nothing is published before the customer agrees. Only the progress he confirmed shows — no name, address or unit numbers.';

  @override
  String get showcasePublicTitle => 'Post title';

  @override
  String get showcaseNote => 'A short description (optional)';

  @override
  String get showcaseShowPhotos => 'Show the photos of approved works';

  @override
  String get showcaseRequestSent => 'The request was sent to the customer';

  @override
  String get showcaseWaiting => 'Waiting for the customer\'s agreement';

  @override
  String get showcaseLive =>
      'Live now and growing with the customer\'s approvals';

  @override
  String get showcaseTakeDown => 'Take it down';

  @override
  String get showcaseCancelRequest => 'Cancel the request';

  @override
  String get showcaseWithdrawn =>
      'It was taken down. You can ask for agreement again.';

  @override
  String showcaseDeclined(String note) {
    return 'The customer declined: $note';
  }

  @override
  String showcaseUpdatedOn(String date) {
    return 'Last updated: $date';
  }

  @override
  String get showcaseConsentTitle =>
      'The business asks to show your project as a post';

  @override
  String get showcaseConsentLive => 'Your project is shown as a post';

  @override
  String get showcaseConsentWithPhotos =>
      'The progress you approved shows with the photos of the works you approved — without your name or address.';

  @override
  String get showcaseConsentNoPhotos =>
      'Only the progress you approved shows — no photos, and no name or address.';

  @override
  String get showcaseConsentAgree => 'I agree';

  @override
  String get showcaseConsentDecline => 'I do not agree';

  @override
  String get showcaseConsentDeclineHint => 'An optional reason';

  @override
  String get showcaseKindTraining => 'Training plan';

  @override
  String get showcaseKindNutrition => 'Nutrition plan';

  @override
  String get showcaseKindCombined => 'Training and nutrition';

  @override
  String showcaseWeeks(int n) {
    return '$n weeks';
  }

  @override
  String showcaseConfirmedMonths(int n) {
    return '$n documented months';
  }

  @override
  String get showcaseNoConfirmedYet => 'Waiting for the first monthly report';

  @override
  String get planShowcaseAskAction => 'Show the plan\'s results as a post';

  @override
  String get planShowcaseAskHint =>
      'Nothing is published before the client agrees, and his one approval covers the whole plan: the results update with every monthly report. Only the changes show — no name, no weight, no photo.';

  @override
  String get planShowcaseConsentTitle =>
      'The trainer asks to show your plan\'s results as a post';

  @override
  String get planShowcaseConsentLive =>
      'Your plan\'s results are shown as a post';

  @override
  String get planShowcaseConsentBody =>
      'One approval covers the whole plan: the results update with every monthly report and you are not asked each time. Only the changes show — no name, no weight, no photo — and you can stop it any time.';

  @override
  String get showcaseModeTitle => 'How consent is asked';

  @override
  String get showcaseModeOnce => 'One general approval';

  @override
  String get showcaseModeEachProject => 'Approval at every stage';

  @override
  String get showcaseModeEachPlan => 'Approval every month, at renewal';

  @override
  String get showcaseModeOnceNotice => 'One approval covers every stage.';

  @override
  String get showcaseModeEachNoticeProject =>
      'You are asked about each finished stage before it is shown.';

  @override
  String get showcaseModeEachNoticePlan =>
      'You are asked about each month\'s results at the plan\'s renewal before they are shown.';

  @override
  String get showcaseConsentStageByStage => 'I agree stage by stage';

  @override
  String get showcaseConsentMonthByMonth => 'I agree month by month';

  @override
  String get showcaseUnitsTitleProject => 'Finished stages: show them?';

  @override
  String get showcaseUnitsTitlePlan => 'Monthly results: show them?';

  @override
  String get showcaseUnitPublish => 'Show';

  @override
  String get showcaseUnitSkip => 'Don\'t show';

  @override
  String get showcaseUnitApproved => 'Shown';

  @override
  String get showcaseUnitDeclined => 'Not shown';

  @override
  String get promoScreenTitle => 'Offers and discounts';

  @override
  String get promoAdd => 'New offer';

  @override
  String get promoEdit => 'Edit the offer';

  @override
  String get promoEmpty =>
      'No offers yet. Tap «New offer», pick your products then the kind of discount, and it reaches the customer\'s price in the cart.';

  @override
  String get promoNoneRunning => 'No offers running right now.';

  @override
  String get promoRunning => 'Running';

  @override
  String get promoPaused => 'Paused';

  @override
  String get promoEnded => 'Ended';

  @override
  String get promoPause => 'Pause';

  @override
  String get promoResume => 'Resume';

  @override
  String get promoDelete => 'Delete';

  @override
  String get promoDeleteConfirm =>
      'Delete this offer? Orders it already priced keep their discount.';

  @override
  String get promoStepProducts => '2. Choose the products';

  @override
  String get promoStepType => '1. Kind of offer';

  @override
  String get promoStepDetails => '3. Details';

  @override
  String get promoWholeShop => 'All my products';

  @override
  String get promoWholeSection => 'The whole section';

  @override
  String get promoNoSection => 'No section';

  @override
  String get promoNoProducts => 'You have no products yet.';

  @override
  String get promoPickSomething => 'Choose what the offer covers';

  @override
  String get promoWayPercent => 'Percentage off';

  @override
  String get promoWayAmount => 'Amount off';

  @override
  String get promoWaySpend => 'Discount above a minimum order';

  @override
  String get promoValuePercent => 'Discount %';

  @override
  String get promoValueAmount => 'Discount amount (EGP)';

  @override
  String get promoMinTotal => 'Minimum order (EGP)';

  @override
  String get promoTitleOptional => 'A title for the offer (optional)';

  @override
  String get promoStarts => 'Starts';

  @override
  String get promoEnds => 'Ends';

  @override
  String get promoMaxUses => 'Or ends after a number of orders';

  @override
  String get promoNeedsEnd =>
      'Every offer needs an end: a date or a number of orders';

  @override
  String get promoAudienceNew => 'For the customer\'s first order only';

  @override
  String get promoSave => 'Save the offer';

  @override
  String get promoCoversAll => 'Covers all products';

  @override
  String get promoFirstOrder => 'For your first order';

  @override
  String get businessTabOffers => 'Offers';

  @override
  String get cartOffersSaved => 'Saved with offers';

  @override
  String promoPercent(String value) {
    return '$value% off';
  }

  @override
  String promoAmount(String value) {
    return '$value EGP off';
  }

  @override
  String promoSpend(String min, String value) {
    return 'Spend $min EGP or more, get $value% off';
  }

  @override
  String promoCovers(String names) {
    return 'Covers: $names';
  }

  @override
  String promoEndsOn(String date) {
    return 'Until $date';
  }

  @override
  String promoUsesLeft(int n) {
    return '$n orders left';
  }

  @override
  String promoSelectedCount(int n) {
    return '$n chosen';
  }

  @override
  String promoItemsCount(int n) {
    return '$n products';
  }

  @override
  String promoNotYetDiscounted(String names) {
    return 'Not discounted yet because its price rose recently: $names';
  }

  @override
  String get promoWayBuyGet => 'Buy … get …';

  @override
  String get promoBuyPay => 'Buy (pieces paid for)';

  @override
  String get promoGetTake => 'Get (pieces taken)';

  @override
  String promoBuyGet(int pay, int take) {
    return 'Buy $pay, get $take';
  }

  @override
  String promoBuyGetSentence(int pay, int take, int free) {
    return 'You pay for $pay and take $take; $free are free';
  }

  @override
  String get promoBuyGetInvalid =>
      'The second number must be larger than the first (up to 20 pieces).';

  @override
  String get promoSameItemOnly => 'The same item only';

  @override
  String get promoMaxGroups => 'Most times in one order (optional)';

  @override
  String get promoRulesTitle => 'The real-discount rule';

  @override
  String promoRulesBody(String percent, int days) {
    return 'An item whose price rose by more than $percent% within the last $days days is not discounted, so the discount is never fake. Its discount starts by itself when the period passes, and you are told the day when you save the offer.';
  }

  @override
  String get promoSummaryTitle => 'Offer summary';

  @override
  String get promoStaySeason =>
      'Applies to stays (optional): only the nights inside this period';

  @override
  String get promoStayFrom => 'Stay from';

  @override
  String get promoStayTo => 'To';

  @override
  String get promoNightsHint =>
      'In a booking the numbers mean nights: «Buy 2, get 3» = pay for two nights and stay three.';

  @override
  String get bookingOfferLine => 'Business offer discount';

  @override
  String get promoSummaryFill => 'Fill in the offer\'s numbers';

  @override
  String get promoWholeKind => 'The whole kind';

  @override
  String get promoMaxBookings => 'Or ends after a number of bookings';

  @override
  String get promoNeedsEndBooking =>
      'Every offer needs an end: a date or a number of bookings';

  @override
  String get pshTitle => 'Partnerships & allocations';

  @override
  String get pshEmpty =>
      'No partnerships yet. Invite a business to contract with; nobody but the two of you sees its details.';

  @override
  String get pshPrivacy =>
      'Nobody but the two of you sees the details of this partnership.';

  @override
  String get pshInvite => 'Invite a partner';

  @override
  String get pshSearchHint => 'Search by business name';

  @override
  String get pshNoteHint => 'A note for the other side (optional)';

  @override
  String get pshSend => 'Send the invitation';

  @override
  String get pshInviteSent => 'The invitation was sent';

  @override
  String get pshKindAgency => 'Tour company';

  @override
  String get pshKindReseller => 'Reseller';

  @override
  String get pshKindSupplier => 'Supplier';

  @override
  String get pshKindCorporate => 'Company';

  @override
  String get pshKindAllotment => 'Hotel allotment';

  @override
  String get pshStatusActive => 'Active';

  @override
  String get pshStatusPending => 'Waiting for an answer';

  @override
  String get pshStatusPaused => 'Paused';

  @override
  String get pshStatusRejected => 'Declined';

  @override
  String get pshStatusEnded => 'Ended';

  @override
  String get pshRoleOwner => 'You give';

  @override
  String get pshRolePartner => 'You sell';

  @override
  String get pshAwaitingYou => 'Awaiting you';

  @override
  String get pshAccept => 'Accept';

  @override
  String get pshDecline => 'Decline';

  @override
  String get pshPause => 'Pause';

  @override
  String get pshResume => 'Resume';

  @override
  String get pshEnd => 'End the partnership';

  @override
  String get pshEndConfirm =>
      'The partnership ends and its allocations stop. This cannot be undone.';

  @override
  String get pshAllocations => 'Allocations';

  @override
  String get pshNoAllocationsOwner =>
      'You have not granted anything yet. Tap «Grant an allocation» to give your partner some of your rooms.';

  @override
  String get pshNoAllocationsPartner =>
      'The other side has not granted you anything yet.';

  @override
  String get pshGrant => 'Grant an allocation';

  @override
  String get pshEdit => 'Edit';

  @override
  String get pshStop => 'Stop';

  @override
  String get pshActivate => 'Activate';

  @override
  String get pshAllocationStopped => 'Stopped';

  @override
  String get pshPickRoom => 'Pick the room';

  @override
  String pshUngranted(int n) {
    return 'Left to grant: $n';
  }

  @override
  String get pshQuantity => 'Rooms per night';

  @override
  String get pshContractPrice => 'Contract price per night';

  @override
  String get pshMinNights => 'Shortest stay (nights)';

  @override
  String get pshMaxNights => 'Longest stay (nights)';

  @override
  String get pshReleaseDays => 'Release the rooms before the date by (days)';

  @override
  String get pshReleaseHelp =>
      'Rooms not booked go back to your stock this many days before';

  @override
  String get pshGrantIncomplete =>
      'Pick the room and write the quantity and the contract price';

  @override
  String pshAvailableOf(int available, int total) {
    return '$available of $total rooms free per night';
  }

  @override
  String pshContractLine(String price) {
    return 'Contract price $price';
  }

  @override
  String pshSellLine(String price) {
    return 'Your selling price $price';
  }

  @override
  String pshNightsRange(int min, int max) {
    return 'Stay $min to $max nights (0 = no limit)';
  }

  @override
  String pshReleaseLine(int days) {
    return 'Released $days days before';
  }

  @override
  String get pshPriceIt => 'Set price';

  @override
  String get pshPriceTitle => 'Selling price for the customer';

  @override
  String get pshMarkupNone => 'At the contract price';

  @override
  String get pshMarkupFixed => 'An amount on top';

  @override
  String get pshMarkupPercent => 'A percentage on top';

  @override
  String get pshMarkupValue => 'The markup';

  @override
  String pshFinalPrice(String price) {
    return 'The customer sees: $price';
  }

  @override
  String get pshFloorHint =>
      'Your selling price is never below the contract price.';

  @override
  String get pshPartnerRoomsTitle => 'Rooms from partner hotels';

  @override
  String pshFromHotel(String name) {
    return 'From $name';
  }

  @override
  String pshRoomsLeft(int n) {
    return '$n left';
  }

  @override
  String get pshPerNight => 'per night';

  @override
  String get tripScreenTitle => 'Trip programmes';

  @override
  String get tripProgramsTab => 'Programmes';

  @override
  String get tripEmpty =>
      'No programme yet. Write your trip as days and items and drop in the room cards a hotel gave you.';

  @override
  String get tripNew => 'New programme';

  @override
  String get tripTitleHint => 'Programme name';

  @override
  String get tripSummaryHint => 'A short description (optional)';

  @override
  String get tripDraft => 'Draft';

  @override
  String get tripPublished => 'Published';

  @override
  String tripDaysCount(int n) {
    return '$n days';
  }

  @override
  String tripDayLabel(int n) {
    return 'Day $n';
  }

  @override
  String get tripAddDay => 'Add a day';

  @override
  String get tripDayTitleHint => 'Day title (optional)';

  @override
  String get tripAddText => 'Text';

  @override
  String get tripAddRoom => 'Room card';

  @override
  String get tripAddPhoto => 'Photo';

  @override
  String get tripPhotoCaption => 'A caption for the photo (optional)';

  @override
  String get tripPickRoom => 'Pick one of the rooms given to your company';

  @override
  String get tripNoRooms =>
      'No rooms given to your company yet. They appear here once a hotel grants you an allocation.';

  @override
  String get tripPublish => 'Publish the programme';

  @override
  String get tripUnpublish => 'Unpublish';

  @override
  String get tripDeleteConfirm =>
      'The programme is deleted with its days and photos. This cannot be undone.';

  @override
  String get tripDeleteDayConfirm => 'The day is deleted with its items.';

  @override
  String get tripMoveUp => 'Move up';

  @override
  String get tripMoveDown => 'Move down';

  @override
  String get tripBookRoom => 'Book this room';

  @override
  String get tripSoldOut => 'Sold out';

  @override
  String get tripRoomGone => 'This offer is currently stopped';

  @override
  String get guestScopeLabel => 'Who is this room sold to?';

  @override
  String get guestScopeHelp =>
      'For a local and a tourist rate make a room type for each. Proof is asked on arrival.';

  @override
  String get reserveRoomsLabel => 'Rooms kept for peak';

  @override
  String get reserveRoomsHelp =>
      'How many of this type only the hotel\'s own guests can take; partners cannot sell them';

  @override
  String get roomFeaturesAction => 'Features of this room';

  @override
  String get roomFeaturesNone => 'None set yet';

  @override
  String roomFeaturesTitle(String number) {
    return 'Features of room $number';
  }

  @override
  String get roomFeaturesHint =>
      'A guest who ticked a view or feature at booking is given, when the stay starts, a number that carries it';

  @override
  String get childPolicyFirstChild => 'First child';

  @override
  String get childPolicyNextChild => 'Each further';

  @override
  String get extraBedTitle => 'Extra bed';

  @override
  String get extraBedHint =>
      'A guest over the room\'s capacity gets an extra bed at its price instead of a refusal. Leave it empty if the hotel has none. A child over it pays only its share.';

  @override
  String get extraBedPrice => 'Extra bed price a night';

  @override
  String get extraBedsMax => 'Per room';

  @override
  String extraBedLine(int n) {
    return 'Extra bed × $n';
  }

  @override
  String get mealTimesTitle => 'Meal times';

  @override
  String get mealTimesIntro =>
      'Guests see on their booking the times of the meals their plan gives: breakfast for BB, breakfast and dinner for half board, all three for full board and all inclusive.';

  @override
  String get mealTimesSaved => 'Meal times saved';

  @override
  String get mealTimesYours => 'Meal times';

  @override
  String get mealFrom => 'From';

  @override
  String get mealTo => 'To';

  @override
  String settlementConfirmedBy(String name) {
    return 'Confirmed by $name';
  }

  @override
  String settlementForBusiness(String name) {
    return 'On behalf of $name';
  }

  @override
  String get settlementIConfirmed =>
      'You confirmed — waiting for the other side';

  @override
  String get settlementWalletOfferGuest => 'Offer to settle from your wallet';

  @override
  String get settlementWalletAskHotel =>
      'Ask to settle from the guest\'s wallet';

  @override
  String get settlementWalletSendOffer => 'Send the offer';

  @override
  String get settlementWalletSendAsk => 'Send the request';

  @override
  String settlementWalletMine(String amount) {
    return 'Your proposal: $amount EGP — waiting for the other side';
  }

  @override
  String get settlementWalletWithdraw => 'Withdraw the proposal';

  @override
  String settlementWalletHotelAsks(String amount) {
    return 'The hotel asks $amount EGP of your deposit to settle; the rest comes back to you';
  }

  @override
  String settlementWalletGuestOffers(String amount) {
    return 'The guest offers $amount EGP of the deposit to settle';
  }

  @override
  String get settlementWalletAccept => 'Accept';

  @override
  String get settlementWalletDecline => 'Decline';

  @override
  String get settlementCollectTitle => 'Settle from the app wallet';

  @override
  String settlementCollectNote(String amount) {
    return 'The fastest way to settle: the guest offers the hotel his held deposit ($amount EGP) or part of it, or the hotel asks for it — nothing is taken without the other side\'s yes. The rest then goes back and it is settled.';
  }

  @override
  String get settlementCollectButton => 'Collect from the wallet';

  @override
  String settlementCollectAll(String amount) {
    return 'The whole deposit ($amount EGP)';
  }

  @override
  String get settlementCollectFine => 'A smaller fine';

  @override
  String settlementCollectAmount(String max) {
    return 'Amount (up to $max EGP)';
  }

  @override
  String settlementCollectedNote(String amount) {
    return 'By both sides\' agreement $amount EGP of the deposit went to the hotel; the rest went back and it is settled.';
  }

  @override
  String get settlementStayStartedNote =>
      'The hotel received the amount and the stay began, so the deposits were released.';

  @override
  String settlementTitle(int id) {
    return 'Settlement · booking #$id';
  }

  @override
  String get settlementNone => 'Nothing to settle on this booking';

  @override
  String get settlementPlease => 'Please settle to release the deposit';

  @override
  String get settlementOpenButton => 'Settlement and deposit';

  @override
  String get settlementFrozen => 'Held for this booking';

  @override
  String settlementClientHold(String pct) {
    return 'Guest\'s deposit ($pct%)';
  }

  @override
  String settlementBusinessHold(String pct) {
    return 'Hotel\'s counter deposit ($pct%)';
  }

  @override
  String settlementFromGuarantee(String amount) {
    return '$amount from the guarantee';
  }

  @override
  String settlementFromWallet(String amount) {
    return '$amount from the wallet';
  }

  @override
  String get settlementSecuredNote =>
      'Held while the booking stands, and released as soon as the stay begins after the hotel received the amount. Nothing is deducted from anyone.';

  @override
  String get settlementOpenNote =>
      'The booking was cancelled. Nothing is ever released by itself — only when both sides confirm it is settled, when one side accepts the other\'s wallet settlement, when the hotel confirms a payment the guest recorded, or by an arbitrator\'s ruling.';

  @override
  String get settlementSettledNote =>
      'Settled — everything held went back to whoever posted it.';

  @override
  String get settlementArbitrationNote =>
      'The booking is in arbitration; what is held waits for the ruling.';

  @override
  String get settlementConfirmTitle => 'Confirm the settlement';

  @override
  String get settlementHotel => 'Hotel';

  @override
  String get settlementGuest => 'Guest';

  @override
  String get settlementWaiting => 'Waiting';

  @override
  String get settlementDone => 'Settled';

  @override
  String get settlementWithdraw => 'Withdraw my confirmation';

  @override
  String get settlementBothNeeded =>
      'The deposit is released only when both sides confirm. You can withdraw yours until the other side confirms.';

  @override
  String get settlementPaymentsTitle => 'Payments outside the app';

  @override
  String get settlementPaymentsNote =>
      'The guest records them with their proof; only the hotel confirms them.';

  @override
  String get settlementRecordPayment => 'Record a payment made outside the app';

  @override
  String get settlementRecordSend => 'Record the payment';

  @override
  String get settlementOwnResponsibility =>
      'Paying outside the app is at your own responsibility, and you must keep proof of payment. The app does not receive or guarantee the money; it only records what you say and your proof, and only the hotel confirms it arrived.';

  @override
  String get settlementAcknowledge =>
      'I acknowledge that paying outside the app is at my own responsibility, and that the attached proof is genuine and belongs to this booking.';

  @override
  String get settlementAmount => 'Amount paid';

  @override
  String get settlementTransfer => 'Transfer';

  @override
  String get settlementCash => 'Cash';

  @override
  String get settlementReference =>
      'Transaction number or reference (optional)';

  @override
  String get settlementProof =>
      'Proof of payment (receipt or transfer screenshot)';

  @override
  String get settlementProofCamera => 'Camera';

  @override
  String get settlementProofGallery => 'Gallery';

  @override
  String get settlementPaymentMissing =>
      'Write the amount, attach the proof and accept the acknowledgement';

  @override
  String get settlementPaymentWaiting => 'Waiting for the hotel';

  @override
  String get settlementPaymentReceived => 'The hotel confirmed it';

  @override
  String get settlementPaymentRefused => 'The hotel says it did not arrive';

  @override
  String get settlementPaymentConfirmed => 'Receipt confirmed';

  @override
  String get settlementArrived => 'Arrived';

  @override
  String get settlementNotArrived => 'Did not arrive';

  @override
  String get settlementNotArrivedNote => 'A note for the guest';

  @override
  String get settlementNoAgreement => 'No agreement?';

  @override
  String get settlementArbitrationHow =>
      'Three days after the cancellation with no settlement, one side may ask for arbitration. The arbitrator rules from the booking\'s terms, the payment proofs and the chat, and sets any compensation from the booking\'s own value. No account is stopped; whoever does not pay a ruling has their guarantee frozen for it, then it is taken from their wallet or guarantee.';

  @override
  String get settlementArbitrationAsk => 'Ask for arbitration';

  @override
  String get settlementArbitrationTitle => 'Ask for arbitration';

  @override
  String get settlementArbitrationConfirm =>
      'A dispute will be opened on this booking and sent to an arbitrator. The session fee falls on the losing side, and your balance must cover it now.';

  @override
  String settlementArbitrationFrom(String date) {
    return 'Arbitration can be asked from $date';
  }

  @override
  String get settlementOpenDispute => 'Open the dispute';

  @override
  String get settlementsTitle => 'Settlements waiting for you';

  @override
  String get settlementsEmpty => 'No open settlements';

  @override
  String get settlementTheyConfirmed =>
      'The other side confirmed — waiting for you';

  @override
  String get settlementWaitingBoth => 'Waiting for both sides';

  @override
  String get ratePlanDeposit => 'Commitment deposit';

  @override
  String get ratePlanDepositHint =>
      'Held from the guest, and as much from you, when you accept — guarantee first, then the wallet. Nothing is deducted; it is released when the booking is settled.';

  @override
  String ratePlanDepositGuest(String amount) {
    return 'A commitment deposit of $amount EGP is held from your guarantee, then your wallet, when the hotel accepts — and as much from the hotel — released on settlement.';
  }

  @override
  String get stayDetailsTitle => 'Stay details';

  @override
  String get stayAdults => 'Adults';

  @override
  String get stayChildren => 'Children';

  @override
  String stayChildLine(int age, String pays) {
    return 'Child of $age — $pays';
  }

  @override
  String stayChildSingleParent(int age, String pays) {
    return 'Child of $age in the second adult\'s place — $pays';
  }

  @override
  String get stayMealPlan => 'Meal plan';

  @override
  String get stayOccupancy => 'Occupancy';

  @override
  String prepaymentOwed(String amount) {
    return 'The full amount is due in advance: $amount EGP';
  }

  @override
  String get prepaymentWaiting =>
      'Non-refundable rate — the guest is not checked in before you confirm it arrived or waive it.';

  @override
  String get prepaymentWaive => 'Waive the prepayment';

  @override
  String get prepaymentReceived => 'The prepayment was confirmed.';

  @override
  String get prepaymentWaived => 'You waived the prepayment.';

  @override
  String prepaymentCustomerNote(String amount) {
    return 'Non-refundable rate: pay the full amount ($amount EGP) to the hotel in advance, in cash or by transfer. Check-in waits until the hotel confirms it.';
  }

  @override
  String get nonRefundableCancelTitle => 'Cancel a non-refundable booking?';

  @override
  String nonRefundableCancelBody(String amount) {
    return 'You booked this stay at the non-refundable rate. What you paid the hotel in advance ($amount EGP) is not refunded on cancelling. Please settle to release the deposit: your held deposit, and the hotel\'s as much, are deducted from no one and released when you both confirm it is settled; with no agreement after 3 days either of you may ask for arbitration.';
  }

  @override
  String get singleOccupancyLabel => 'Single occupancy rate';

  @override
  String get singleOccupancyHelp =>
      'What one adult alone in the room pays of the night (e.g. 85%). Leave it empty and he pays the whole room.';

  @override
  String singleOccupancyLine(String pct) {
    return 'Single occupancy ($pct of the room)';
  }

  @override
  String get thirdAdultLabel => 'Third person reduction';

  @override
  String get thirdAdultHint =>
      'When set, the adult in an extra bed pays one person\'s night less this %, instead of the fixed bed price.';

  @override
  String get cotTitle => 'Baby cot';

  @override
  String get cotsPerRoom => 'Baby cots per room';

  @override
  String get cotPrice => 'Baby cot price a night';

  @override
  String get cotPriceHint => 'Leave empty when it is free';

  @override
  String cotAsk(String price) {
    return 'Baby cot ($price)';
  }

  @override
  String cotLine(int n) {
    return 'Baby cot × $n';
  }

  @override
  String get ratePlansTitle => 'Rate plans';

  @override
  String get ratePlansIntro =>
      'Beside the flexible rate you can sell a cheaper non-refundable one: the guest pays the hotel in full in advance outside the app and cannot change the dates. The app confiscates no deposit.';

  @override
  String get ratePlansSaved => 'Rate plans saved';

  @override
  String get ratePlanFlexible => 'Flexible rate';

  @override
  String get ratePlanFlexibleHint =>
      'The usual rate — the guest may change the dates or cancel.';

  @override
  String get ratePlanFlexibleGuest => 'You can change the dates or cancel';

  @override
  String get ratePlanNonRefundable => 'Non-refundable';

  @override
  String get ratePlanNonRefundableHint =>
      'Cheaper by the % you set, paid in full in advance, dates fixed.';

  @override
  String get ratePlanNonRefundableGuest =>
      'Cheaper — paid to the hotel in full in advance; the dates cannot change and nothing is refunded';

  @override
  String get ratePlanNonRefundableBooked =>
      'Non-refundable rate — the dates cannot change';

  @override
  String get ratePlanDiscount => 'Discount';

  @override
  String get ratePlanDiscountHint => 'From 1% to 50%';

  @override
  String get ratePlanChoose => 'Rate';

  @override
  String nonRefundableLine(String pct) {
    return 'Non-refundable discount ($pct)';
  }

  @override
  String get seasonsTitle => 'Seasons';

  @override
  String get seasonsIntro =>
      'Each season has the rooms\' price (a % or an amount on every type, or a night price for one type), the meal plans\' price, and the shortest stay for an arrival in it. Seasons do not overlap.';

  @override
  String get seasonsEmpty => 'No seasons';

  @override
  String get seasonAdd => 'Add a season';

  @override
  String get seasonEdit => 'Edit season';

  @override
  String get seasonName => 'Season name';

  @override
  String get seasonNameHint => 'Summer, Eid, New Year…';

  @override
  String get seasonDates => 'From … to …';

  @override
  String get seasonMissing => 'Write the season\'s name and pick its dates';

  @override
  String get seasonRoomsTitle => 'Room prices in the season';

  @override
  String get seasonChangePercent => 'Percent';

  @override
  String get seasonChangeAmount => 'Amount';

  @override
  String get seasonChangeValue => 'Increase or reduction';

  @override
  String get seasonChangeHint =>
      'On every room type — a negative number reduces';

  @override
  String get seasonRoomPriceHint =>
      'Or a night price for one room type (it wins over the change):';

  @override
  String get seasonMealsTitle => 'Meal prices in the season';

  @override
  String seasonMealOwnPrice(String price) {
    return 'Its usual price $price — leave empty to keep it';
  }

  @override
  String get seasonMinNights => 'Minimum nights';

  @override
  String get seasonNoMinimum => 'None';

  @override
  String get seasonMinNightsHint => 'For an arrival in the season';

  @override
  String seasonRoomPricesN(int n) {
    return '$n room prices';
  }

  @override
  String seasonMealPricesN(int n) {
    return '$n meal prices';
  }

  @override
  String seasonMinNightsN(int n) {
    return 'min $n nights';
  }

  @override
  String get singleParentTitle => 'One adult with a child';

  @override
  String get singleParentHint =>
      'In a room with one adult, the second adult\'s place is paid for in the room\'s price; the (oldest) child in it pays what you set here instead of its usual share.';

  @override
  String get singleParentChild => 'Child in adult\'s place';

  @override
  String bookingChildSingleParentLine(int age, String pays) {
    return 'Child of $age in the second adult\'s place · $pays';
  }

  @override
  String get galaTitle => 'Gala dinners';

  @override
  String get galaIntro =>
      'Gala nights (New Year\'s Eve, Christmas, Eid…): every stay over the night pays the dinner — each adult the price, a child from the age you set its percentage, a younger child free — whatever the meal plan, also when a partner sells your rooms.';

  @override
  String get galaEmpty => 'No gala nights';

  @override
  String get galaAdd => 'Add a gala dinner';

  @override
  String get galaEdit => 'Edit gala dinner';

  @override
  String get galaDate => 'Night';

  @override
  String get galaName => 'Name';

  @override
  String get galaNameHint => 'New Year\'s Eve gala';

  @override
  String get galaAdultPrice => 'Adult price';

  @override
  String get galaChildPercent => 'Child\'s % of the adult price';

  @override
  String get galaFreeUnder => 'Free for a child under (years)';

  @override
  String get galaMissing =>
      'Pick the night and write the name and the adult price';

  @override
  String galaSummary(String price, String percent, int age) {
    return 'Adult $price · child $percent% · free under $age';
  }

  @override
  String galaLine(String name, String date) {
    return '$name ($date) — compulsory';
  }

  @override
  String get childPolicyTitle => 'Children policy';

  @override
  String get childPolicyIntro =>
      'Set the children\'s ages and what each pays of the night\'s price. It applies to all your rooms and to the rooms your partners sell.';

  @override
  String get childPolicyBands => 'Age bands';

  @override
  String get childPolicyFrom => 'From age';

  @override
  String get childPolicyTo => 'to age';

  @override
  String get childPolicyPercent => 'Other share';

  @override
  String get childPolicyAddBand => 'Add a band';

  @override
  String get childPolicyAdultAge => 'Adult from age';

  @override
  String get childPolicyCountsFrom => 'Takes a place in the room from age';

  @override
  String get childPolicyMeals => 'A child\'s meals at the same share';

  @override
  String get childPolicySaved => 'Children policy saved';

  @override
  String get childFree => 'Free';

  @override
  String get childHalf => 'Half';

  @override
  String get childThird => 'A third';

  @override
  String get bookingChildrenTitle => 'Children';

  @override
  String get bookingAddChild => 'Add a child';

  @override
  String bookingChildN(int n) {
    return 'Child $n';
  }

  @override
  String get bookingChildAge => 'Age';

  @override
  String bookingChildLine(int age, String pays) {
    return 'Child of $age · $pays';
  }

  @override
  String bookingGuestsMax(int n) {
    return 'up to $n';
  }

  @override
  String get bookingRoomKindTitle => 'Room';

  @override
  String roomFeaturesPrice(String base, String extra, String total) {
    return 'This room a night: $base + $extra = $total';
  }

  @override
  String get unitFeaturesVsRoomsHint =>
      'Tick here what EVERY room of this type has (its price is inside the type\'s price). What only some rooms have, tick on the room number in the list above.';

  @override
  String bookingRoomRequested(String names) {
    return 'The guest asked for: $names';
  }

  @override
  String get bookingRoomMatches => 'Has what the guest asked for';

  @override
  String get bookingRoomNoMatch => 'Lacks part of what the guest asked for';

  @override
  String get pshGuaranteedLabel => 'Guaranteed allotment';

  @override
  String get pshGuaranteedHelp =>
      'On: the rooms are held for the partner alone. Off (default): the hotel and the partner sell the same stock at the same time';

  @override
  String get guestScopeAll => 'Everyone';

  @override
  String get guestScopeLocals => 'Egyptians and residents only';

  @override
  String get guestScopeForeigners => 'Foreigners only';

  @override
  String get guestScopeConfirmRequired => 'Tick the box above to continue';

  @override
  String get guestScopeConfirmLocals =>
      'I confirm I am an Egyptian or a resident of Egypt and will show proof on arrival';

  @override
  String get guestScopeConfirmForeigners =>
      'I confirm I am a foreigner and will show my passport on arrival';

  @override
  String get boardTitle => 'Rooms board';

  @override
  String get boardEmpty =>
      'No room types yet. Add them in the booking settings and they appear here.';

  @override
  String get boardFree => 'Free';

  @override
  String get boardPartly => 'Partly taken';

  @override
  String get boardFull => 'Full';

  @override
  String get boardViaPartner => 'Sold through a partner';

  @override
  String boardStock(int n) {
    return '$n rooms';
  }

  @override
  String boardHeld(int n) {
    return '$n held for partners and not sold yet';
  }

  @override
  String boardSoldBy(String name) {
    return 'Sold by $name';
  }

  @override
  String get boardDirect => 'Direct booking';

  @override
  String boardRoomNumber(String n) {
    return 'Room $n';
  }

  @override
  String get boardCheckLocal => 'Check the Egyptian ID or residence';

  @override
  String get boardCheckForeign => 'Check the passport';

  @override
  String pshNightsFrom(int min) {
    return 'Stay $min nights or more';
  }

  @override
  String bookingHoldBanner(String time) {
    return 'Held for you — expires in $time';
  }

  @override
  String get bookingUnitHeld => 'Being booked by someone else';

  @override
  String get boardDealing => 'Being booked';

  @override
  String boardDealingNow(int n) {
    return 'Being booked now · ends in $n min';
  }

  @override
  String boardDealingVia(String name) {
    return 'through $name';
  }

  @override
  String get boardDealingHotel => 'from the hotel\'s own screen';

  @override
  String get guestOriginQuestion => 'I am…';

  @override
  String get guestOriginLocal => 'Egyptian or resident';

  @override
  String get guestOriginForeign => 'Foreigner';

  @override
  String get bookingHoldRelease => 'Release the hold';

  @override
  String bookingMyHold(String time) {
    return 'Held for you — ends in $time';
  }

  @override
  String get bookingAskRelease => 'Ask the partner to release it';

  @override
  String get bookingReleaseWaiting =>
      'Your request was sent to the partner. Waiting for its answer…';

  @override
  String get bookingReleaseDeclined =>
      'The partner could not release the room.';

  @override
  String get bookingReleaseExpired =>
      'The request ran out of time without an answer.';

  @override
  String get pshReleaseTitle => 'Requests to release rooms';

  @override
  String get pshReleaseHint =>
      'A guest of the hotel asks for a room held for you. If you agree it goes back to the hotel.';

  @override
  String pshReleaseRoom(String room, String from, String to) {
    return '$room · $from to $to';
  }

  @override
  String get pshReleaseApprove => 'Agree';

  @override
  String get pshReleaseDecline => 'Decline';

  @override
  String get pshStayDates => 'Covers stays from night… to night…';

  @override
  String get pshStayAny => 'Not limited (any date)';

  @override
  String pshStanding(int n, int pending) {
    return 'Bookings standing: $n · waiting for the hotel: $pending';
  }

  @override
  String get pshStandingHint =>
      'They stay valid after the allocation ends or stops; nothing is cancelled.';

  @override
  String get stkTitle => 'Stock';

  @override
  String get stkTileSubtitle =>
      'Does it cover today? and approving purchase orders';

  @override
  String get stkNotAvailable =>
      'Inventory is not available for your business category.';

  @override
  String get stkEnableTitle => 'Inventory & purchases';

  @override
  String get stkEnableBody =>
      'Follow your stock live: every receipt, sale and waste is a recorded move, and app sales deduct by recipe automatically. Full management is on the desktop app; follow it from here.';

  @override
  String stkSubscriptionPrice(String price) {
    return 'Monthly subscription: $price EGP from your wallet';
  }

  @override
  String get stkSubscriptionFree => 'No subscription fee for now.';

  @override
  String get stkEnableAction => 'Switch inventory on';

  @override
  String get stkOwnerEnables => 'The business owner switches it on.';

  @override
  String get stkStockValue => 'Stock value';

  @override
  String get stkCurrency => 'EGP';

  @override
  String get stkBelowReorder => 'Below reorder level';

  @override
  String stkPendingApproval(int number) {
    return 'Purchase order #$number awaits your approval';
  }

  @override
  String get stkCoversToday => 'Covers today\'s sales?';

  @override
  String get stkNoItems => 'No items yet.';

  @override
  String stkCoverageLine(String days, String onHand, String unit) {
    return '$onHand $unit — about $days days';
  }

  @override
  String get stkVerdictNo => 'Not enough';

  @override
  String get stkVerdictTight => 'Barely';

  @override
  String get stkVerdictYes => 'Enough';

  @override
  String get stkVerdictEmpty => 'Out';

  @override
  String get stkVerdictUnknown => 'No sales yet';

  @override
  String get stkOnHandNow => 'On hand now';

  @override
  String stkCoverageExplain(
    String avg,
    String rest,
    String today,
    String unit,
  ) {
    return 'Sold today $today $unit; this weekday\'s average over 4 weeks is $avg, so ~$rest is expected for the rest of the day.';
  }

  @override
  String stkDaysLeft(String days) {
    return 'Lasts ~$days days at the current rate.';
  }

  @override
  String get stkRecentMoves => 'Recent moves';

  @override
  String get stkRecordWaste => 'Record waste';

  @override
  String stkQtyIn(String unit) {
    return 'Quantity ($unit)';
  }

  @override
  String get stkReason => 'Reason';

  @override
  String get stkSaved => 'Saved.';

  @override
  String get stkReject => 'Reject';

  @override
  String stkPurchaseOrderNo(int number) {
    return 'Purchase order #$number';
  }

  @override
  String get stkOnBim => 'On BIM';

  @override
  String get stkTotal => 'Total';

  @override
  String get stkApproveAndSend => 'Approve and send';

  @override
  String get stkIncomingTitle => 'Incoming purchase orders';

  @override
  String get stkIncomingEmpty =>
      'No business has sent you a purchase order yet.';

  @override
  String get stkConfirmed => 'You confirmed this order.';

  @override
  String get stkConfirmOrder => 'Confirm the order';

  @override
  String get stkMoveReceipt => 'Receipt';

  @override
  String get stkMoveSale => 'Sale';

  @override
  String get stkMoveSaleReversal => 'Sale returned';

  @override
  String get stkMoveWaste => 'Waste';

  @override
  String get stkMoveTransferOut => 'Transfer out';

  @override
  String get stkMoveTransferIn => 'Transfer in';

  @override
  String get stkMoveAdjustment => 'Stocktake adjustment';

  @override
  String get stkMoveSupplierReturn => 'Return to supplier';

  @override
  String get stkMoveOpening => 'Opening balance';

  @override
  String get stkMoveReversal => 'Reversal';

  @override
  String get stkPoDraft => 'Draft';

  @override
  String get stkPoPending => 'Awaiting approval';

  @override
  String get stkPoApproved => 'Approved and sent';

  @override
  String get stkPoPartial => 'Partially received';

  @override
  String get stkPoReceived => 'Received';

  @override
  String get stkPoClosed => 'Closed';

  @override
  String get stkPoRejected => 'Rejected';

  @override
  String get stkPoCancelled => 'Cancelled';

  @override
  String get suiteBrand => 'BIM Business';

  @override
  String get suiteSignInTitle => 'Sign in with your BIM account';

  @override
  String get suiteSignInHint =>
      'The same account as the app. A staff member signs in with their own.';

  @override
  String get suiteLoginField => 'Email';

  @override
  String get suiteChooseBusiness =>
      'Choose the business this computer works for';

  @override
  String get suiteNoBusiness =>
      'Your account is not a business, nor staff with inventory, purchases or cashier access.';

  @override
  String get suiteNavDashboard => 'Today';

  @override
  String get suiteNavItems => 'Items & stock';

  @override
  String get suiteNavRecipes => 'Menu links & recipes';

  @override
  String get suiteNavPurchases => 'Purchases';

  @override
  String get suiteNavReceive => 'Receiving';

  @override
  String get suiteNavStocktake => 'Stocktake';

  @override
  String get suiteNavPos => 'Cashier';

  @override
  String get suiteNavDevices => 'Devices';

  @override
  String get suiteNavSettings => 'Settings & subscription';

  @override
  String get suiteLinkOnline => 'Online';

  @override
  String get suiteLinkOffice => 'Via the main computer (offline)';

  @override
  String get suiteLinkOffline => 'Offline — saved on this computer';

  @override
  String get suiteLinkChecking => 'Checking…';

  @override
  String suitePending(int n) {
    return '$n waiting to send';
  }

  @override
  String suiteRejected(int n) {
    return '$n refused by the server';
  }

  @override
  String get suiteSyncNow => 'Sync now';

  @override
  String get suiteReadOnlyBanner =>
      'Subscription unpaid: read and export only until you top up and renew. Your data is kept.';

  @override
  String get suiteGraceBanner =>
      'The wallet did not cover the renewal — grace days, then read-only.';

  @override
  String get suiteRenew => 'Renew now';

  @override
  String get suiteQueued =>
      'Saved on this computer; it is sent by itself when the connection is back.';

  @override
  String get suiteAtAverageCost => 'At weighted average cost';

  @override
  String get suiteOpenOrders => 'Open purchase orders';

  @override
  String get suiteWasteMonth => 'Waste this month';

  @override
  String get suiteNeedsAttention => 'Needs your attention';

  @override
  String get suiteAllCovered =>
      'Every item is above its reorder level and covers today.';

  @override
  String get suiteItem => 'Item';

  @override
  String get suiteOnHand => 'On hand';

  @override
  String get suiteDaysLeft => 'Days left';

  @override
  String get suiteNewItem => 'New item';

  @override
  String get suiteSearchOrScan => 'Search by name or scan a barcode…';

  @override
  String get suiteAll => 'All';

  @override
  String get suiteReorderLevel => 'Reorder level';

  @override
  String get suiteAvgCost => 'Average cost';

  @override
  String get suiteValue => 'Value';

  @override
  String get suitePickItem => 'Pick an item to see its ledger.';

  @override
  String get suiteBaseUnit => 'base';

  @override
  String get suiteEdit => 'Edit';

  @override
  String get suiteAddOpening => 'Opening balance';

  @override
  String get suiteTransfer => 'Transfer to a warehouse';

  @override
  String get suiteLedger => 'Ledger';

  @override
  String get suiteLedgerHint =>
      'No move is edited or deleted — a mistake is answered by a reversing move.';

  @override
  String get suiteWhen => 'When';

  @override
  String get suiteMove => 'Move';

  @override
  String get suiteQty => 'Qty';

  @override
  String get suiteBalanceAfter => 'Balance after';

  @override
  String get suiteUnitCost => 'Cost per base unit';

  @override
  String get suiteToWarehouse => 'To warehouse';

  @override
  String get suiteKindCount => 'Count';

  @override
  String get suiteKindWeight => 'Weight';

  @override
  String get suiteKindVolume => 'Volume';

  @override
  String get suiteKindLength => 'Length';

  @override
  String get suiteNameAr => 'Name in Arabic';

  @override
  String get suiteNameEn => 'Name in English (optional)';

  @override
  String get suiteGroup => 'Group (drinks, kitchen supplies…)';

  @override
  String get suiteBaseUnitHint => 'Base unit (can, gram, ml, piece)';

  @override
  String get suiteUnitKind => 'Unit kind';

  @override
  String get suiteBarcode => 'Barcode';

  @override
  String get suitePurchaseUnits => 'Purchase units (carton, pallet…)';

  @override
  String get suiteUnitName => 'Unit name';

  @override
  String suiteUnitFactor(String unit) {
    return '= how many $unit';
  }

  @override
  String get suiteAddUnit => 'Add a unit';

  @override
  String get suiteOpeningQty => 'Opening quantity (base unit)';

  @override
  String get suitePickMenuItem =>
      'Pick a menu or store item to set what it takes from the stock.';

  @override
  String get suiteLinkRecipe => 'Recipe';

  @override
  String get suiteLinkDirect => 'Direct';

  @override
  String get suiteLinkNone => 'Not linked';

  @override
  String get suiteAddsTo => 'Adds to the recipe';

  @override
  String suiteRecipeCost(String cost, String percent) {
    return 'Cost $cost EGP · $percent% of the price';
  }

  @override
  String get suiteIngredient => 'Ingredient';

  @override
  String get suiteWastePct => 'Loss %';

  @override
  String get suiteAddIngredient => 'Add an ingredient';

  @override
  String get suiteNewSupplier => 'New supplier';

  @override
  String get suiteNewOrder => 'New purchase order';

  @override
  String get suiteOrders => 'Purchase orders';

  @override
  String get suiteSuppliers => 'Suppliers';

  @override
  String get suiteSupplierName => 'Supplier name';

  @override
  String get suitePhone => 'Phone';

  @override
  String get suiteLinkedBusinessId => 'Business id on BIM (optional)';

  @override
  String get suiteLinkedBusinessHint =>
      'If the supplier is a business on BIM, it receives the order in its app.';

  @override
  String get suitePickOrder => 'Pick a purchase order.';

  @override
  String get suiteSupplier => 'Supplier';

  @override
  String get suiteSupplierConfirmed => 'The supplier confirmed it in its app.';

  @override
  String get suiteLines => 'Lines';

  @override
  String get suiteUnit => 'Unit';

  @override
  String get suiteOrdered => 'Ordered';

  @override
  String get suitePrice => 'Price';

  @override
  String get suiteReceived => 'Received';

  @override
  String get suiteBilled => 'Billed';

  @override
  String get suiteMatchProblem =>
      'Three-way match: the supplier\'s bill does not match what was ordered and received';

  @override
  String get suitePriceDiffers => 'price differs';

  @override
  String get suiteBilledMore => 'billed more than received';

  @override
  String get suiteSubmit => 'Send';

  @override
  String get suiteSaveDraft => 'Save as draft';

  @override
  String get suiteReceiveNow => 'Receive';

  @override
  String get suiteRecordBill => 'Supplier\'s bill';

  @override
  String get suiteRecordPayment => 'Record a payment';

  @override
  String get suiteClose => 'Close';

  @override
  String get suiteBillNumber => 'Bill number';

  @override
  String get suitePaymentOutsideHint =>
      'Money moves outside the app; this only records it so you know where you stand with the supplier.';

  @override
  String get suiteAmount => 'Amount';

  @override
  String get suiteCash => 'Cash';

  @override
  String get suiteTransferMoney => 'Transfer';

  @override
  String get suiteCheque => 'Cheque';

  @override
  String get suiteNote => 'Note';

  @override
  String get suiteBalance => 'Owed to him';

  @override
  String get suiteUnitPrice => 'Unit price';

  @override
  String get suiteAddLine => 'Add a line';

  @override
  String get suiteAgainstOrder => 'Against purchase order';

  @override
  String get suiteNoOrder => 'Without a purchase order';

  @override
  String get suiteScanToReceive =>
      'Scan the item or carton barcode — each scan adds one';

  @override
  String suiteUnknownBarcode(String code) {
    return 'Unknown barcode: $code';
  }

  @override
  String get suiteReceiveEmpty => 'Pick a purchase order or scan an item.';

  @override
  String get suiteRemaining => 'Remaining';

  @override
  String get suiteReceivedNow => 'Received now';

  @override
  String get suiteDamaged => 'Damaged';

  @override
  String get suiteLot => 'Lot';

  @override
  String get suiteExpiry => 'Expiry';

  @override
  String get suiteReceiveNoEdit =>
      'A confirmed receipt is not edited — a mistake goes back as a return or a stocktake.';

  @override
  String get suiteConfirmReceipt => 'Confirm receipt';

  @override
  String get suiteStartCount => 'New count';

  @override
  String get suiteCountTitle => 'Count title';

  @override
  String get suiteCountGroup => 'One group only (optional)';

  @override
  String get suiteBlindCount =>
      'Blind count (the counter does not see the computed figure)';

  @override
  String get suiteCounting => 'Counting';

  @override
  String get suiteReview => 'Reviewing differences';

  @override
  String get suiteApplied => 'Applied';

  @override
  String get suiteBack => 'Back';

  @override
  String get suiteFinishCount => 'Finish counting';

  @override
  String get suiteApplyCount => 'Apply and book the differences';

  @override
  String get suiteBlindHint =>
      'Blind count: computed figures show after counting ends.';

  @override
  String get suiteScanToCount => 'Scan to add to the count';

  @override
  String suiteNetDifference(String amount) {
    return 'Net difference: $amount EGP';
  }

  @override
  String get suiteExpected => 'Expected';

  @override
  String get suiteCounted => 'Counted';

  @override
  String get suiteDifference => 'Difference';

  @override
  String get suiteOpenShift => 'Open a shift';

  @override
  String get suiteCloseShift => 'Close the shift';

  @override
  String get suiteOpeningCash => 'Opening cash in the drawer';

  @override
  String get suiteCountedCash => 'Cash counted in the drawer';

  @override
  String get suiteShiftClosed => 'Shift closed';

  @override
  String suiteShiftSummary(String counted, String difference, String expected) {
    return 'Expected $expected EGP, counted $counted EGP, difference $difference EGP.';
  }

  @override
  String get suitePaidLess => 'The amount paid is less than the total.';

  @override
  String suiteChange(String amount) {
    return 'Change: $amount EGP';
  }

  @override
  String get suiteScanToSell => 'Scan a barcode…';

  @override
  String get suiteSearch => 'Search';

  @override
  String suiteAvailable(int n) {
    return '~$n available';
  }

  @override
  String get suiteInvoice => 'Invoice';

  @override
  String get suitePaidCash => 'Paid in cash';

  @override
  String get suitePay => 'Pay';

  @override
  String get suiteCashOutsideHint =>
      'Cash in the drawer — nothing from the wallet.';

  @override
  String get suiteLastSales => 'Last sales';

  @override
  String get suiteReturned => 'returned';

  @override
  String get suiteReturn => 'Return';

  @override
  String get suiteSize => 'Size';

  @override
  String get suiteRegular => 'Regular';

  @override
  String get suiteExtras => 'Extras';

  @override
  String get suiteAddToInvoice => 'Add to invoice';

  @override
  String get suiteRoleMain => 'Main computer';

  @override
  String get suiteRoleManager => 'Manager';

  @override
  String get suiteRoleWarehouse => 'Warehouse';

  @override
  String get suiteRolePurchases => 'Purchasing';

  @override
  String get suiteRoleCashier => 'Cashier';

  @override
  String get suiteDeviceName => 'Computer name';

  @override
  String get suitePairTitle => 'Pair with the main computer';

  @override
  String get suitePairCode => 'The code shown on the main computer';

  @override
  String get suiteRole => 'Role';

  @override
  String get suitePair => 'Pair';

  @override
  String get suitePaired => 'Paired with the main computer.';

  @override
  String get suitePairFailed =>
      'Pairing failed: check the code and that both computers are on the same network.';

  @override
  String get suiteThisComputer => 'This computer';

  @override
  String get suiteIsMain =>
      'This is the main computer: it gathers the business\'s computers on the office network and syncs them with the server.';

  @override
  String get suiteNewPairingCode => 'New pairing code';

  @override
  String get suitePairingHint =>
      'The code is valid for 5 minutes, once. Enter it on the new computer while on the same network.';

  @override
  String suitePairedWith(String address, String name) {
    return 'Paired with the main computer «$name» ($address).';
  }

  @override
  String get suiteUnpair => 'Unpair';

  @override
  String get suiteMakeMain => 'Make it the main computer';

  @override
  String get suiteFindMain => 'Find the main computer on the network';

  @override
  String get suiteNoMainFound => 'No main computer found on this network.';

  @override
  String get suitePairedComputers => 'Computers paired with this one';

  @override
  String get suiteRegister => 'Register';

  @override
  String get suiteForget => 'Remove';

  @override
  String get suiteRegisteredDevices => 'The business\'s registered computers';

  @override
  String get suiteNoDevices => 'No computers registered yet.';

  @override
  String get suiteRevoke => 'Revoke';

  @override
  String get suiteSubscription => 'Monthly subscription';

  @override
  String suiteSubscriptionStatus(String status) {
    return 'Status: $status';
  }

  @override
  String suitePaidUntil(String date) {
    return 'Paid until $date';
  }

  @override
  String get suiteSubscriptionRules =>
      'A reminder 3 days before renewal, then 7 grace days, then read and export only until you top up. No data is ever deleted, and sales keep updating the stock.';

  @override
  String get suiteSubActive => 'Active';

  @override
  String get suiteSubGrace => 'Grace days';

  @override
  String get suiteSubReadOnly => 'Read-only';

  @override
  String get suiteSubNone => 'Not subscribed';

  @override
  String get suiteParts => 'Parts in use';

  @override
  String get suitePartsHint =>
      'Your category sets them from the control panel; you switch the optional ones.';

  @override
  String get suiteOptional => 'Optional';

  @override
  String get suiteApprovalLimit => 'Purchase order approval limit';

  @override
  String get suiteApprovalLimitField =>
      'Above this amount an order needs your approval (empty = no limit)';

  @override
  String get suiteRejectedTitle =>
      'Operations the server refused after reconnecting';

  @override
  String get suiteClear => 'Clear the list';
}
