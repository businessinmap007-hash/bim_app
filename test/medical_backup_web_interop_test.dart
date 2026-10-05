import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/features/medical_file/data/medical_backup_crypto.dart';
import 'package:bim_app/features/medical_file/data/medical_file.dart';

/// «نسخة الطبيب على الكمبيوتر» — the doctor's web panel seals its prescriptions copy with the same envelope the
/// phone's backup uses. This blob was made by the PAGE'S OWN JavaScript (Node WebCrypto: PBKDF2-SHA256 310k rounds,
/// AES-256-GCM, nonce || ciphertext || tag) and must open with the phone's code — so a file downloaded on the
/// computer can be restored on the phone and the other way round.
const _sealedByTheWebPanel = '''{"v":1,"kdf":"pbkdf2-sha256","iterations":310000,"salt":"f7Y/EvRIpIScIrzWN7iYcg==","data":"rXy8YKH5U2YOyrih9qFhnPXUNlD+aBzvjs/+nlXK7uwVlXQ1mTCaVAgwx6T4xjMqPaB9Kxls1lA5EZr3ym07YNqE/W3hu4/0sZ6ZyGTcxzUjclYbDlzj2Kx8EGoqtCkymLZ/tmSMRwvq4riu8Kw/I86Expbbm8tJH6U5jc3y1Ma56TppNuYLcqjEuRthTxengKvCzyM4gR2FiHdIcJpcXeFcA/LMrQUqFNoSdBfjCn54tycrRXZO"}''';

void main() {
  test('a copy sealed by the web panel opens on the phone', () async {
    final back = await MedicalBackupCrypto.open(_sealedByTheWebPanel, 'a long passphrase');

    expect(back.prescriptions.single['id'], 7);
    expect(back.prescriptions.single['diagnosis'], 'Flu');
    expect((back.prescriptions.single['items'] as List).single['name'], 'Paracetamol');
  });

  test('the wrong passphrase does not open it', () async {
    await expectLater(MedicalBackupCrypto.open(_sealedByTheWebPanel, 'not the passphrase'), throwsA(anything));
  });

  test('a copy sealed on the phone is what the web panel reads (written for the node check)', () async {
    final out = Platform.environment['BIM_WRITE_PHONE_BLOB'];
    if (out == null) return; // only when asked: the check is run from the web side
    final blob = await MedicalBackupCrypto.seal(
      const MedicalFile(bloodType: 'A+'),
      'a long passphrase',
      prescriptions: [
        {'id': 9, 'status': 'issued', 'diagnosis': 'Cough', 'items': <dynamic>[]},
      ],
    );
    File(out).writeAsStringSync(blob);
  });
}
