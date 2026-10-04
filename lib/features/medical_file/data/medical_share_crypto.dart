import 'dart:convert';

import 'package:cryptography/cryptography.dart';

/// The encryption of a shared medical file. A fresh AES-256-GCM key for every share: the phone sends the
/// server only `nonce + ciphertext + tag`, and the key travels in the QR code from the patient's screen to
/// the doctor's camera — never over the network. Whoever has the server's copy alone reads nothing.
class MedicalShareCrypto {
  static final _algorithm = AesGcm.with256bits();

  /// The prefix of a medical-share QR code, so a scanner knows it is not a cart or a table code.
  static const qrPrefix = 'BIMMED1';

  /// Encrypt [payload]; returns the base64 ciphertext for the server and the base64url key for the QR.
  static Future<({String ciphertext, String key})> seal(Map<String, dynamic> payload) async {
    final key = await _algorithm.newSecretKey();
    final box = await _algorithm.encrypt(utf8.encode(jsonEncode(payload)), secretKey: key);
    final keyBytes = await key.extractBytes();
    return (ciphertext: base64Encode(box.concatenation()), key: base64UrlEncode(keyBytes).replaceAll('=', ''));
  }

  /// Decrypt what [seal] made. Throws when the key is wrong or the ciphertext was changed (GCM's tag).
  static Future<Map<String, dynamic>> open(String ciphertext, String key) async {
    final box = SecretBox.fromConcatenation(base64Decode(ciphertext), nonceLength: 12, macLength: 16);
    final keyBytes = base64Url.decode(base64Url.normalize(key));
    final clear = await _algorithm.decrypt(box, secretKey: SecretKey(keyBytes));
    return Map<String, dynamic>.from(jsonDecode(utf8.decode(clear)) as Map);
  }

  /// `BIMMED1:{share id}:{key}` — what the patient's QR code holds.
  static String qrPayload(String id, String key) => '$qrPrefix:$id:$key';

  /// The share id and key out of a scanned code, or null when it is not a medical-share code.
  static ({String id, String key})? parseQr(String raw) {
    final parts = raw.trim().split(':');
    if (parts.length != 3 || parts[0] != qrPrefix || parts[1].isEmpty || parts[2].isEmpty) return null;
    return (id: parts[1], key: parts[2]);
  }
}
