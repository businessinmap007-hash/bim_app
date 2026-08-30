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
}
