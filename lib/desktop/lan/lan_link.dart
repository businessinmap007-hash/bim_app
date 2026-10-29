import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

import '../sync/suite_store.dart';

/// The office network between the business's computers (owner, 2026-10-29: «نسخه فى المخازن ونسخة على جهاز المشتريات
/// ونسخة للبيع مربوطين بالشبكة الداخلية تلقائيا»).
///
/// The MAIN computer runs [LanHub]: it answers a discovery broadcast, pairs a new computer with a one-time 6-digit code
/// shown on its screen, keeps every paired computer's writes in its own queue (sent to the server with the token of the
/// person who made them) and serves its copy of the data when the internet is down. Every message after pairing is
/// AES-256-GCM with a key that only the two computers hold.
class LanLink {
  const LanLink._();

  static const httpPort = 47820;
  static const discoveryPort = 47821;
  static const _probe = 'BIM_SUITE_DISCOVER_1';

  static final _aes = AesGcm.with256bits();

  static Future<String> seal(List<int> key, Map<String, dynamic> message) async {
    final box = await _aes.encrypt(utf8.encode(jsonEncode(message)), secretKey: SecretKey(key));
    return base64Encode(box.concatenation());
  }

  static Future<Map<String, dynamic>> open(List<int> key, String sealed) async {
    final box = SecretBox.fromConcatenation(base64Decode(sealed), nonceLength: 12, macLength: 16);
    final clear = await _aes.decrypt(box, secretKey: SecretKey(key));
    return jsonDecode(utf8.decode(clear)) as Map<String, dynamic>;
  }

  /// The pairing key both sides derive from the code on the screen and the new computer's id — never sent.
  static Future<List<int>> pairingKey(String code, String deviceUuid) async =>
      (await Sha256().hash(utf8.encode('bim-suite-pair|$code|$deviceUuid'))).bytes;

  static Future<String> proof(String code, String deviceUuid) async {
    final mac = await Hmac.sha256().calculateMac(utf8.encode(deviceUuid), secretKey: SecretKey(utf8.encode(code)));
    return base64Encode(mac.bytes);
  }

  static List<int> randomKey() {
    final r = Random.secure();
    return List<int>.generate(32, (_) => r.nextInt(256));
  }
}

/// A computer that paired with the main one.
class LanPeer {
  final String uuid;
  final String name;
  final String role;
  final DateTime pairedAt;
  DateTime? lastSeen;

  LanPeer({required this.uuid, required this.name, required this.role, required this.pairedAt, this.lastSeen});

  Map<String, dynamic> toJson() => {'uuid': uuid, 'name': name, 'role': role, 'paired_at': pairedAt.toIso8601String()};

  factory LanPeer.fromJson(Map<String, dynamic> j) =>
      LanPeer(uuid: j['uuid'] as String, name: j['name'] as String, role: j['role'] as String, pairedAt: DateTime.parse(j['paired_at'] as String));
}

/// Runs on the main computer.
class LanHub {
  final SuiteStore store;
  final int businessId;
  final String businessName;

  /// Called when a paired computer sends a write: the hub queues it with that person's token.
  final Future<void> Function(OutboxEntry entry) onRelay;

  HttpServer? _http;
  RawDatagramSocket? _udp;
  String? _code;
  DateTime? _codeUntil;

  LanHub({required this.store, required this.businessId, required this.businessName, required this.onRelay});

  bool get running => _http != null;

  /// A fresh one-time code, valid for five minutes.
  String newPairingCode() {
    _code = (Random.secure().nextInt(900000) + 100000).toString();
    _codeUntil = DateTime.now().add(const Duration(minutes: 5));
    return _code!;
  }

  String? get activeCode => (_code != null && _codeUntil != null && _codeUntil!.isAfter(DateTime.now())) ? _code : null;

  List<LanPeer> peers() {
    final raw = store.meta.get('lan_peers');
    if (raw == null) return [];
    return (jsonDecode(raw) as List<dynamic>).map((e) => LanPeer.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> _savePeers(List<LanPeer> peers) => store.meta.put('lan_peers', jsonEncode(peers.map((p) => p.toJson()).toList()));

  Future<void> forget(String uuid) async {
    await _savePeers(peers()..removeWhere((p) => p.uuid == uuid));
    await store.meta.delete('lan_key_$uuid');
  }

  Future<void> start() async {
    if (running) return;
    _http = await HttpServer.bind(InternetAddress.anyIPv4, LanLink.httpPort, shared: true);
    _http!.listen(_handle, onError: (_) {});

    _udp = await RawDatagramSocket.bind(InternetAddress.anyIPv4, LanLink.discoveryPort, reuseAddress: true);
    _udp!.listen((event) {
      if (event != RawSocketEvent.read) return;
      final packet = _udp!.receive();
      if (packet == null || utf8.decode(packet.data, allowMalformed: true) != LanLink._probe) return;
      final reply = utf8.encode(jsonEncode({'hub': true, 'business_id': businessId, 'name': businessName, 'port': LanLink.httpPort}));
      _udp!.send(reply, packet.address, packet.port);
    });
  }

  Future<void> stop() async {
    await _http?.close(force: true);
    _udp?.close();
    _http = null;
    _udp = null;
  }

  Future<void> _handle(HttpRequest request) async {
    try {
      final body = jsonDecode(await utf8.decoder.bind(request).join()) as Map<String, dynamic>;
      final path = request.uri.path;

      if (path == '/pair') {
        await _pair(request, body);
        return;
      }

      final deviceUuid = request.headers.value('x-device') ?? '';
      final keyRaw = store.meta.get('lan_key_$deviceUuid');
      if (keyRaw == null) {
        return _reply(request, 403, {'error': 'not_paired'});
      }
      final key = base64Decode(keyRaw);
      final message = await LanLink.open(key, body['payload'] as String);
      final peer = peers().where((p) => p.uuid == deviceUuid).firstOrNull;
      peer?.lastSeen = DateTime.now();

      if (path == '/relay') {
        await onRelay(OutboxEntry(
          id: message['id'] as String? ?? OutboxEntry.nextId(deviceUuid),
          method: message['method'] as String,
          path: message['path'] as String,
          body: (message['body'] as Map?)?.cast<String, dynamic>(),
          token: message['token'] as String?,
          businessId: message['business_id'] as int?,
          origin: deviceUuid,
        ));
        return _reply(request, 200, {'payload': await LanLink.seal(key, {'queued': true})});
      }

      if (path == '/cache') {
        final cacheKey = SuiteStore.cacheKey(message['business_id'] as int?, message['path'] as String, (message['query'] as Map?)?.cast<String, dynamic>());
        final data = store.readCache(cacheKey);
        return _reply(request, data == null ? 404 : 200, {'payload': await LanLink.seal(key, {'data': data})});
      }

      return _reply(request, 404, {'error': 'unknown'});
    } catch (_) {
      return _reply(request, 400, {'error': 'bad_request'});
    }
  }

  Future<void> _pair(HttpRequest request, Map<String, dynamic> body) async {
    final code = activeCode;
    final deviceUuid = body['device_uuid'] as String? ?? '';

    if (code == null || deviceUuid.isEmpty || body['proof'] != await LanLink.proof(code, deviceUuid)) {
      return _reply(request, 403, {'error': 'bad_code'});
    }

    final deviceKey = LanLink.randomKey();
    await store.meta.put('lan_key_$deviceUuid', base64Encode(deviceKey));
    final list = peers()..removeWhere((p) => p.uuid == deviceUuid);
    list.add(LanPeer(uuid: deviceUuid, name: body['name'] as String? ?? '', role: body['role'] as String? ?? 'warehouse', pairedAt: DateTime.now()));
    await _savePeers(list);
    _code = null; // one use

    final sealed = await LanLink.seal(await LanLink.pairingKey(code, deviceUuid), {'key': base64Encode(deviceKey), 'business_id': businessId, 'name': businessName});
    return _reply(request, 200, {'payload': sealed});
  }

  Future<void> _reply(HttpRequest request, int status, Map<String, dynamic> body) async {
    request.response
      ..statusCode = status
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(body));
    await request.response.close();
  }
}

/// Runs on every other computer: finds the main one, pairs once, then relays writes and reads its copy offline.
class LanClient {
  final SuiteStore store;

  LanClient(this.store);

  String? get hubAddress => store.meta.get('lan_hub_address');

  bool get paired => hubAddress != null && store.meta.get('lan_hub_key') != null;

  /// Broadcasts on the office network and returns the main computers that answered (address → their reply).
  static Future<Map<String, Map<String, dynamic>>> discover({Duration wait = const Duration(seconds: 2)}) async {
    final found = <String, Map<String, dynamic>>{};
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    socket.broadcastEnabled = true;
    final sub = socket.listen((event) {
      if (event != RawSocketEvent.read) return;
      final packet = socket.receive();
      if (packet == null) return;
      try {
        found[packet.address.address] = jsonDecode(utf8.decode(packet.data)) as Map<String, dynamic>;
      } catch (_) {}
    });
    socket.send(utf8.encode(LanLink._probe), InternetAddress('255.255.255.255'), LanLink.discoveryPort);
    await Future<void>.delayed(wait);
    await sub.cancel();
    socket.close();
    return found;
  }

  /// Pairs with the main computer at [address] using the code shown on its screen.
  Future<bool> pair({required String address, required String code, required String name, required String role}) async {
    final uuid = store.deviceUuid;
    final response = await _post(address, '/pair', {'device_uuid': uuid, 'name': name, 'role': role, 'proof': await LanLink.proof(code, uuid)});
    if (response == null || response.$1 != 200) return false;

    final message = await LanLink.open(await LanLink.pairingKey(code, uuid), response.$2['payload'] as String);
    await store.meta.put('lan_hub_address', address);
    await store.meta.put('lan_hub_key', message['key'] as String);
    await store.meta.put('lan_hub_name', message['name'] as String? ?? '');
    return true;
  }

  Future<void> unpair() async {
    await store.meta.delete('lan_hub_address');
    await store.meta.delete('lan_hub_key');
  }

  Future<bool> relay(OutboxEntry entry) async {
    final r = await _sealed('/relay', entry.toJson());
    return r != null && r.$1 == 200;
  }

  Future<dynamic> cached(String path, Map<String, dynamic>? query, int? businessId) async {
    final r = await _sealed('/cache', {'path': path, 'query': query, 'business_id': businessId});
    if (r == null || r.$1 != 200) return null;
    return r.$2['data'];
  }

  Future<(int, Map<String, dynamic>)?> _sealed(String path, Map<String, dynamic> message) async {
    final address = hubAddress;
    final keyRaw = store.meta.get('lan_hub_key');
    if (address == null || keyRaw == null) return null;
    final key = base64Decode(keyRaw);

    final r = await _post(address, path, {'payload': await LanLink.seal(key, message)}, device: store.deviceUuid);
    if (r == null) return null;
    final payload = r.$2['payload'];
    return (r.$1, payload is String ? await LanLink.open(key, payload) : <String, dynamic>{});
  }

  static Future<(int, Map<String, dynamic>)?> _post(String address, String path, Map<String, dynamic> body, {String? device}) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 3);
    try {
      final request = await client.post(address, LanLink.httpPort, path);
      request.headers.contentType = ContentType.json;
      if (device != null) request.headers.set('x-device', device);
      request.write(jsonEncode(body));
      final response = await request.close().timeout(const Duration(seconds: 6));
      final text = await utf8.decoder.bind(response).join();
      return (response.statusCode, text.isEmpty ? <String, dynamic>{} : jsonDecode(text) as Map<String, dynamic>);
    } catch (_) {
      return null;
    } finally {
      client.close(force: true);
    }
  }
}
