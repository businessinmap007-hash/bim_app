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
  String get commonSubmit => 'Submit';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

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
  String get businessInfoTitle => 'Business info';

  @override
  String get businessInfoPhone => 'Phone number';

  @override
  String get businessInfoLocation => 'Location';

  @override
  String get businessInfoOpenInMaps => 'Open in maps';

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
  String get jobsTitleLabel => 'Job title';

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
  String get ordersEmpty => 'No orders yet.';

  @override
  String get bookingsEmpty => 'No bookings yet.';

  @override
  String get ordersCancel => 'Cancel order';

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
  String get orderStatusPending => 'Pending';

  @override
  String get orderStatusCompleted => 'Completed';

  @override
  String get orderStatusCancelled => 'Cancelled';

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
  String get walletTitle => 'Wallet';

  @override
  String get walletAvailableBalance => 'Available balance';

  @override
  String get walletLockedBalance => 'Locked balance';

  @override
  String get walletTransactionsTitle => 'Transactions';

  @override
  String get walletTransactionsEmpty => 'No transactions yet.';

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
  String get staffRemove => 'Remove';

  @override
  String get staffRemoveConfirm => 'Remove this staff member?';

  @override
  String get staffPhoneRequired => 'Enter the staff member\'s phone number.';

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
  String get clinicNoOpenSlots => 'No open slots right now.';

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
  String get menuItemAdd => 'Add item';

  @override
  String get menuItemEditTitle => 'Edit item';

  @override
  String get menuItemAddTitle => 'Add item';

  @override
  String get menuItemDeleteConfirm => 'Delete this item?';

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
  String get menuItemBasePriceHint => 'Price';

  @override
  String get menuItemSupplyPriceHint => 'Cost price (optional)';

  @override
  String get menuItemBrandNameHint => 'Brand (optional)';

  @override
  String get menuItemSortOrderHint => 'Sort order';

  @override
  String get menuItemActiveLabel => 'Active';

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
  String get retailListingsTitle => 'My Products';

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
  String get retailListingSkuHint => 'SKU (optional)';

  @override
  String get retailListingActiveLabel => 'Active';

  @override
  String get retailListingDeleteConfirm =>
      'Remove this product from your listings?';

  @override
  String get retailPriceRequired => 'Enter a valid price.';

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
  String get tripScheduleCapacityLabel => 'Capacity';

  @override
  String get tripSchedulePriceLabel => 'Price per unit';

  @override
  String get tripScheduleDepositLabel => 'Deposit per unit (optional)';

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
}
