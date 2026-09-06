import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../network/api_client.dart';
import '../storage/layout_style_storage.dart';
import '../storage/locale_storage.dart';
import '../storage/theme_mode_storage.dart';
import '../storage/token_storage.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage(ref.watch(secureStorageProvider));
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(tokenStorageProvider));
});

final localeStorageProvider = Provider<LocaleStorage>((ref) {
  return LocaleStorage();
});

final themeModeStorageProvider = Provider<ThemeModeStorage>((ref) {
  return ThemeModeStorage();
});

final layoutStyleStorageProvider = Provider<LayoutStyleStorage>((ref) {
  return LayoutStyleStorage();
});
