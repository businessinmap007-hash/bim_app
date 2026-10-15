import 'dart:async';

import 'guarantee_badge_info.dart';

/// `ApiClient.get`, as a function — so the loader can be tested without a network.
typedef BadgeFetch = Future<dynamic> Function(String path, {Map<String, dynamic>? query});

/// Fetches the badges of the accounts a screen shows — one batched call for everything asked within a few
/// milliseconds, kept for a while so a list scrolling back does not ask again.
class GuaranteeBadgeLoader {
  final BadgeFetch _fetch;
  final Duration _window;
  final Duration _ttl;

  GuaranteeBadgeLoader(this._fetch, {Duration window = const Duration(milliseconds: 40), Duration ttl = const Duration(minutes: 10)})
    : _window = window,
      _ttl = ttl;

  final Map<int, ({GuaranteeBadgeInfo? info, DateTime at})> _cache = {};
  final Map<int, List<Completer<GuaranteeBadgeInfo?>>> _waiting = {};
  Timer? _timer;

  Future<GuaranteeBadgeInfo?> load(int userId) {
    final hit = _cache[userId];
    if (hit != null && DateTime.now().difference(hit.at) < _ttl) return Future.value(hit.info);

    final completer = Completer<GuaranteeBadgeInfo?>();
    _waiting.putIfAbsent(userId, () => []).add(completer);
    _timer ??= Timer(_window, _flush);

    return completer.future;
  }

  Future<void> _flush() async {
    _timer = null;
    final batch = Map<int, List<Completer<GuaranteeBadgeInfo?>>>.of(_waiting);
    _waiting.clear();
    if (batch.isEmpty) return;

    final ids = batch.keys.toList();

    try {
      for (var i = 0; i < ids.length; i += 100) {
        final chunk = ids.sublist(i, i + 100 > ids.length ? ids.length : i + 100);
        final data = await _fetch('/guarantee-badges', query: {'ids': chunk.join(',')}) as Map<String, dynamic>;
        final raw = data['badges'];
        final map = raw is Map<String, dynamic> ? raw : const <String, dynamic>{};

        for (final id in chunk) {
          final info = GuaranteeBadgeInfo.fromJsonOrNull(map['$id']);
          _cache[id] = (info: info, at: DateTime.now());
          for (final c in batch[id]!) {
            c.complete(info);
          }
        }
      }
    } catch (_) {
      // a badge is decoration: on any failure the account simply shows no badge this time
      for (final waiters in batch.values) {
        for (final c in waiters) {
          if (!c.isCompleted) c.complete(null);
        }
      }
    }
  }
}
