import 'package:flutter_test/flutter_test.dart';
import 'package:bim_app/features/medical_file/data/medical_file.dart';
import 'package:bim_app/features/medical_file/data/medical_backup_crypto.dart';
import 'package:bim_app/features/medical_file/data/medical_share_crypto.dart';

/// «الملف الطبي على الموبايل» — what is shared is only what was chosen, and only the code's key opens it.
void main() {
  const file = MedicalFile(
    bloodType: 'O+',
    sections: {
      MedicalSection.conditions: [MedicalEntry(title: 'سكر', detail: 'النوع الثاني')],
      MedicalSection.allergies: [MedicalEntry(title: 'بنسلين')],
      MedicalSection.medications: [MedicalEntry(title: 'ميتفورمين', detail: '500 مجم مرتين')],
    },
    notes: 'ملاحظة خاصة',
  );

  test('the file survives its own JSON', () {
    final again = MedicalFile.fromJson(file.toJson());
    expect(again.bloodType, 'O+');
    expect(again.entries(MedicalSection.conditions).single.detail, 'النوع الثاني');
    expect(again.entries(MedicalSection.allergies).single.title, 'بنسلين');
    expect(again.notes, 'ملاحظة خاصة');
  });

  test('a share carries only the chosen parts', () {
    final shown = file.only(sections: {MedicalSection.allergies}, bloodType: true, notes: false);
    expect(shown.entries(MedicalSection.allergies), hasLength(1));
    expect(shown.entries(MedicalSection.conditions), isEmpty);
    expect(shown.notes, isEmpty, reason: 'notes were not ticked');
    expect(shown.bloodType, 'O+');
  });

  test('the sealed file opens with its key only, and the server copy says nothing', () async {
    final sealed = await MedicalShareCrypto.seal(file.toJson());

    expect(sealed.ciphertext.contains('بنسلين'), isFalse);
    final opened = MedicalFile.fromJson(await MedicalShareCrypto.open(sealed.ciphertext, sealed.key));
    expect(opened.entries(MedicalSection.medications).single.title, 'ميتفورمين');

    final other = await MedicalShareCrypto.seal({'x': 1});
    await expectLater(MedicalShareCrypto.open(sealed.ciphertext, other.key), throwsA(anything), reason: 'another key cannot open it');
  });

  test('the QR code holds the share id and the key, and nothing else reads as one', () {
    final qr = MedicalShareCrypto.qrPayload('6f1c2c9e-1111-2222-3333-444455556666', 'abcDEF_-123');
    expect(MedicalShareCrypto.parseQr(qr), (id: '6f1c2c9e-1111-2222-3333-444455556666', key: 'abcDEF_-123'));
    expect(MedicalShareCrypto.parseQr('https://bim/cart/join/abc'), isNull);
  });

  test('a backup opens with its passphrase only, and the blob says nothing', () async {
    final blob = await MedicalBackupCrypto.seal(file, 'correct horse battery');

    expect(blob.contains('بنسلين'), isFalse);
    expect(blob.contains('correct horse'), isFalse, reason: 'the passphrase is not in it');
    final restored = (await MedicalBackupCrypto.open(blob, 'correct horse battery')).file;
    expect(restored.bloodType, 'O+');
    expect(restored.entries(MedicalSection.allergies).single.title, 'بنسلين');
    expect(restored.notes, 'ملاحظة خاصة');

    await expectLater(MedicalBackupCrypto.open(blob, 'wrong passphrase!'), throwsA(anything));
  });

  test('every backup has its own salt, and a changed blob is refused', () async {
    final a = await MedicalBackupCrypto.seal(file, 'same passphrase 1');
    final b = await MedicalBackupCrypto.seal(file, 'same passphrase 1');
    expect(a == b, isFalse, reason: 'random salt and nonce: the same file never looks the same twice');

    final tampered = a.replaceFirst('"data":"', '"data":"AAAA');
    await expectLater(MedicalBackupCrypto.open(tampered, 'same passphrase 1'), throwsA(anything));
  });
}
