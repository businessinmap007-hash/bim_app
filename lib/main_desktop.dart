import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/providers/core_providers.dart';
import 'desktop/desktop_app.dart';
import 'desktop/sync/desktop_sync.dart';
import 'desktop/sync/suite_store.dart';
import 'features/inventory/application/inventory_providers.dart';

/// «تطبيق الكمبيوتر» (Windows / macOS) — the business's back office: inventory, purchases, the cashier.
///
///   flutter run -d windows -t lib/main_desktop.dart
///   flutter build windows -t lib/main_desktop.dart
///
/// Same codebase as the phone app (API client, sign-in, translations, theme); its own entry point and shell. Every
/// inventory call goes through [DesktopInventoryTransport], which keeps working with no internet.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await SuiteStore.open(const FlutterSecureStorage());

  runApp(ProviderScope(
    overrides: [
      suiteStoreProvider.overrideWithValue(store),
      inventoryTransportProvider.overrideWith(
        (ref) => DesktopInventoryTransport(client: ref.watch(apiClientProvider), store: store, sync: ref.watch(suiteSyncProvider.notifier)),
      ),
    ],
    child: const DesktopApp(),
  ));
}

