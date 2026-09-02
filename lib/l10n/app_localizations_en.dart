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
  String get commonCancel => 'Cancel';

  @override
  String get commonSubmit => 'Submit';

  @override
  String get commonSave => 'Save';

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
  String get businessSearchHint => 'Search by business name...';

  @override
  String get businessListEmpty => 'No matching businesses.';

  @override
  String get businessOpenNow => 'Open now';

  @override
  String get businessClosedNow => 'Closed now';

  @override
  String get businessCallForPrice => 'Call for price';

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
  String get settingsAccountSection => 'Account settings';

  @override
  String get settingsServicesSection => 'Service settings';

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
  String get businessNoContentYet => 'Nothing to show yet';

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
  String get profilePhotoCamera => 'Take a photo';

  @override
  String get profilePhotoGallery => 'Choose from gallery';

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
  String get locationFieldLabel => 'Country / Governorate / City';

  @override
  String get locationChooseHint => 'Choose country, governorate and city';

  @override
  String get locationChooseCountry => 'Choose a country';

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
  String get postsFeedEmpty =>
      'No posts yet — follow a business to see its posts here.';

  @override
  String get postsMineEmpty => 'You haven\'t posted anything yet.';

  @override
  String get postsJobsEmpty => 'You haven\'t posted any jobs yet.';

  @override
  String get postsCreateChoicePost => 'New post';

  @override
  String get postsCreateChoiceJob => 'New job';

  @override
  String get postsCreateTitle => 'New post';

  @override
  String get postsPublish => 'Publish';

  @override
  String get postsTitleLabel => 'Title (optional)';

  @override
  String get postsBodyLabel => 'Text';

  @override
  String get postsDeleteConfirmTitle => 'Delete this post?';

  @override
  String get postsDelete => 'Delete';

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
  String get jobsTitleLabel => 'Job title';

  @override
  String get jobsBodyLabel => 'Job description';

  @override
  String get jobsRequirementsLabel => 'Requirements (optional)';

  @override
  String get jobsSalaryLabel => 'Salary (optional)';

  @override
  String get cartTitle => 'Cart';

  @override
  String get cartEmpty => 'Your cart is empty.';

  @override
  String get cartAdd => 'Add to cart';

  @override
  String get cartAddedToCart => 'Added to cart.';

  @override
  String get cartQty => 'Quantity';

  @override
  String get cartRemove => 'Remove';

  @override
  String get cartVariantChoose => 'Choose a type';

  @override
  String get cartExtrasChoose => 'Extras';

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
  String get cartFulfillmentType => 'Fulfillment';

  @override
  String get cartFulfillmentDelivery => 'Delivery';

  @override
  String get cartFulfillmentPickup => 'Pickup';

  @override
  String get cartFulfillmentDineIn => 'Dine in';

  @override
  String get cartAddressLabel => 'Address';

  @override
  String get cartAddressHint => 'Enter the delivery address';

  @override
  String get cartNotesLabel => 'Notes (optional)';

  @override
  String get cartPaymentMethod => 'Payment method';

  @override
  String get cartPaymentCash => 'Cash on delivery';

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
  String get bookingUnitRequired => 'Choose a unit first.';

  @override
  String get bookingDateRequired => 'Choose a date first.';
}
