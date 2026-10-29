import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/env/env.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/providers/core_providers.dart';
import '../../core/storage/token_storage.dart';
import '../../features/inventory/data/inventory_api.dart';
import '../lan/lan_link.dart';
import 'suite_store.dart';

/// How this computer reaches the data right now.
enum SuiteLink { checking, online, office, offline }

class SuiteSyncState {
  final SuiteLink link;
  final int pending;
  final int rejected;
  final bool isHub;
  final DateTime? lastSync;

  const SuiteSyncState({this.link = SuiteLink.checking, this.pending = 0, this.rejected = 0, this.isHub = false, this.lastSync});

  SuiteSyncState copyWith({SuiteLink? link, int? pending, int? rejected, bool? isHub, DateTime? lastSync}) => SuiteSyncState(
        link: link ?? this.link,
        pending: pending ?? this.pending,
        rejected: rejected ?? this.rejected,
        isHub: isHub ?? this.isHub,
        lastSync: lastSync ?? this.lastSync,
      );
}

/// The heart of «يعمل بدون نت»: every few seconds it checks the server, sends the queued writes IN ORDER (each with the
/// token of the person who made it — the server checks that person's permissions and records him), and, on the main
/// computer, keeps the copy the other computers read from fresh. A write the server refuses is kept in a list the
/// user can read; nothing is dropped silently.
class SuiteSync extends StateNotifier<SuiteSyncState> {
  final SuiteStore store;
  final ApiClient client;
  final TokenStorage tokens;
  final LanClient lan;
  LanHub? hub;
  int? businessId;
  Timer? _timer;
  bool _busy = false;

  final Dio _replay = Dio(BaseOptions(
    baseUrl: Env.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
    headers: {'Accept': 'application/json'},
  ));

  /// What the main computer keeps fresh for the others to read when the internet is down.
  static const warmPaths = [
    '/business/inventory/settings',
    '/business/inventory/dashboard',
    '/business/inventory/coverage',
    '/business/inventory/items',
    '/business/inventory/warehouses',
    '/business/inventory/suppliers',
    '/business/inventory/purchase-orders',
    '/business/inventory/stocktakes',
    '/business/inventory/pos/catalog',
  ];

  SuiteSync({required this.store, required this.client, required this.tokens, required this.lan}) : super(const SuiteSyncState()) {
    _count();
  }

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 12), (_) => tick());
    unawaited(tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    unawaited(hub?.stop());
    super.dispose();
  }

  void _count() {
    if (!mounted) return;
    state = state.copyWith(pending: store.outbox.length, rejected: store.rejected().length, isHub: hub?.running ?? false);
  }

  /// Queue a write on this computer (or hand it to the main computer when this one cannot reach the server).
  Future<void> enqueue(String method, String path, Map<String, dynamic>? body) async {
    final entry = OutboxEntry(
      id: OutboxEntry.nextId(store.deviceUuid),
      method: method,
      path: path,
      body: body,
      token: await tokens.read(),
      businessId: businessId,
      origin: store.deviceUuid,
    );

    if (hub?.running != true && lan.paired && state.link != SuiteLink.online && await lan.relay(entry)) {
      _count();
      return;
    }
    await store.enqueue(entry);
    _count();
  }

  Future<void> tick() async {
    if (_busy) return;
    _busy = true;
    try {
      final online = await _reachable();
      if (online) {
        await _flush();
        if (hub?.running == true) await _warm();
        state = state.copyWith(link: SuiteLink.online, lastSync: DateTime.now());
        unawaited(_seen());
      } else {
        // a queue built up on this computer while the main one was reachable goes to it
        if (lan.paired && hub?.running != true) {
          for (final entry in store.pending()) {
            if (!await lan.relay(entry)) break;
            await store.remove(entry.id);
          }
        }
        state = state.copyWith(link: lan.paired ? SuiteLink.office : SuiteLink.offline);
      }
    } finally {
      _busy = false;
      _count();
    }
  }

  Future<bool> _reachable() async {
    try {
      await client.get('/business/inventory/settings');
      return true;
    } on ApiException catch (e) {
      return !e.isNetworkError;
    } catch (_) {
      return false;
    }
  }

  Future<void> _flush() async {
    final current = await tokens.read();

    for (final entry in store.pending()) {
      try {
        await _replay.request<dynamic>(
          entry.path,
          data: entry.body,
          options: Options(method: entry.method, headers: {
            'Authorization': 'Bearer ${entry.token ?? current}',
            'X-Business-Id': ?entry.businessId,
            'Accept-Language': client.languageCode,
          }),
        );
        await store.remove(entry.id);
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        if (status == null || status == 402 || status == 401 || status >= 500) {
          break; // no connection, read-only, or the server is down: keep the order and try later
        }
        final data = e.response?.data;
        final message = data is Map && data['message'] is String ? data['message'] as String : 'HTTP $status';
        await store.addRejected(entry, message);
        await store.remove(entry.id);
      }
      _count();
    }
  }

  Future<void> _warm() async {
    for (final path in warmPaths) {
      try {
        store.putCache(SuiteStore.cacheKey(businessId, path, null), await client.get(path));
      } catch (_) {}
    }
  }

  Future<void> _seen() async {
    try {
      await client.post('/business/inventory/devices/${store.deviceUuid}/seen');
    } catch (_) {
      // an unregistered computer is fine: it works by its user's own permissions
    }
  }

  /// Turns this computer into the main one (owner's choice on the devices screen).
  Future<void> startHub({required int businessId, required String businessName}) async {
    hub ??= LanHub(
      store: store,
      businessId: businessId,
      businessName: businessName,
      onRelay: (entry) async {
        await store.enqueue(entry);
        _count();
      },
    );
    await hub!.start();
    await store.meta.put('lan_is_hub', '1');
    _count();
  }

  Future<void> stopHub() async {
    await hub?.stop();
    await store.meta.delete('lan_is_hub');
    _count();
  }

  bool get wantsHub => store.meta.get('lan_is_hub') == '1';
}

/// The desktop's [InventoryTransport]: the server when it answers; otherwise this computer's copy (or the main
/// computer's, over the office network), and writes queued — each carries a uuid, so the server books it once.
class DesktopInventoryTransport implements InventoryTransport {
  final ApiClient client;
  final SuiteStore store;
  final SuiteSync sync;

  DesktopInventoryTransport({required this.client, required this.store, required this.sync});

  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    final key = SuiteStore.cacheKey(sync.businessId, path, query);
    try {
      final data = await client.get(path, query: query);
      store.putCache(key, data);
      return data;
    } on ApiException catch (e) {
      if (!e.isNetworkError) rethrow;
      if (sync.lan.paired && sync.hub?.running != true) {
        final fromHub = await sync.lan.cached(path, query, sync.businessId);
        if (fromHub != null) return fromHub;
      }
      final local = store.readCache(key);
      if (local != null) return local;
      rethrow;
    }
  }

  @override
  Future<dynamic> send(String method, String path, {Map<String, dynamic>? body, bool queueable = false}) async {
    // a queue that is not empty keeps its order: a new write waits behind it
    if (queueable && store.outbox.isNotEmpty && sync.state.link != SuiteLink.online) {
      await sync.enqueue(method, path, body);
      return null;
    }

    try {
      return await DirectInventoryTransport(client).send(method, path, body: body);
    } on ApiException catch (e) {
      if (!e.isNetworkError || !queueable) rethrow;
      await sync.enqueue(method, path, body);
      return null;
    }
  }
}

final suiteStoreProvider = Provider<SuiteStore>((ref) => throw UnimplementedError('opened in main_desktop.dart'));

final suiteSyncProvider = StateNotifierProvider<SuiteSync, SuiteSyncState>((ref) {
  final store = ref.watch(suiteStoreProvider);
  return SuiteSync(store: store, client: ref.watch(apiClientProvider), tokens: ref.watch(tokenStorageProvider), lan: LanClient(store));
});
