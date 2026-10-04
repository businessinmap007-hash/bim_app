import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

import 'medical_file.dart';

/// The encrypted backup of the medical file. The key comes from a passphrase only the patient knows
/// (PBKDF2-HMAC-SHA256, 310,000 rounds, a random salt per backup) and the file is sealed with AES-256-GCM.
/// The passphrase is kept nowhere: without it the blob is noise — to the server, to us, to anyone — and
/// there is no way to recover it. A wrong passphrase and a tampered blob look the same: the tag fails.
class MedicalBackupCrypto {
  static const iterations = 310000;
  static const minPassphraseLength = 8;

  static final _aes = AesGcm.with256bits();

  static Pbkdf2 _kdf(int rounds) => Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: rounds, bits: 256);

  /// The blob to upload: JSON `{v, kdf, iterations, salt, data}`, every value base64.
  static Future<String> seal(MedicalFile file, String passphrase) async {
    final salt = List<int>.generate(16, (_) => Random.secure().nextInt(256));
    final key = await _derive(passphrase, salt, iterations);
    final box = await _aes.encrypt(utf8.encode(jsonEncode(file.toJson())), secretKey: key);
    return jsonEncode({
      'v': 1,
      'kdf': 'pbkdf2-sha256',
      'iterations': iterations,
      'salt': base64Encode(salt),
      'data': base64Encode(box.concatenation()),
    });
  }

  /// Throws when the passphrase is wrong or the blob was changed.
  static Future<MedicalFile> open(String blob, String passphrase) async {
    final json = jsonDecode(blob) as Map<String, dynamic>;
    final rounds = (json['iterations'] as num).toInt();
    final key = await _derive(passphrase, base64Decode('${json['salt']}'), rounds);
    final box = SecretBox.fromConcatenation(base64Decode('${json['data']}'), nonceLength: 12, macLength: 16);
    final clear = await _aes.decrypt(box, secretKey: key);
    return MedicalFile.fromJson(Map<String, dynamic>.from(jsonDecode(utf8.decode(clear)) as Map));
  }

  /// The slow part, off the UI isolate: it takes seconds on a phone and the screen must not freeze.
  static Future<SecretKey> _derive(String passphrase, List<int> salt, int rounds) async {
    final bytes = await compute(_deriveBytes, (passphrase: passphrase, salt: salt, rounds: rounds));
    return SecretKey(bytes);
  }
}

Future<List<int>> _deriveBytes(({String passphrase, List<int> salt, int rounds}) a) async {
  final key = await MedicalBackupCrypto._kdf(a.rounds).deriveKeyFromPassword(password: a.passphrase, nonce: a.salt);
  return key.extractBytes();
}
