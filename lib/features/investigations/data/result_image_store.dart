import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

/// «نسخة على موبايل المريض»: the result photos of an investigation order, kept in the app's own private folder on THIS
/// phone. They are downloaded from the server once; the server then deletes its copies (after the ordering doctor has
/// read them), so this is the patient's copy — shown from here when the server no longer has them.
class ResultImageStore {
  const ResultImageStore();

  Future<Directory> _dir(int userId, int orderId) async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}${Platform.pathSeparator}investigation_results${Platform.pathSeparator}$userId${Platform.pathSeparator}$orderId');
    if (!await dir.exists()) await dir.create(recursive: true);

    return dir;
  }

  /// The photos already kept for this order, in order.
  Future<List<File>> local(int userId, int orderId) async {
    final dir = await _dir(userId, orderId);
    final files = dir.listSync().whereType<File>().toList()..sort((a, b) => a.path.compareTo(b.path));

    return files;
  }

  /// Download every photo (the links are signed — no login needed) into this order's folder. Returns how many are
  /// kept now; throws if any download fails, so nothing is marked «saved» on a half copy.
  Future<int> save(int userId, int orderId, List<String> urls, {List<String> documentUrls = const []}) async {
    final dir = await _dir(userId, orderId);
    final dio = Dio();
    final kept = <File>[];

    for (var i = 0; i < urls.length; i++) {
      final res = await dio.get<List<int>>(urls[i], options: Options(responseType: ResponseType.bytes));
      final bytes = res.data;
      if (bytes == null || bytes.isEmpty) throw StateError('empty download');

      final ext = _extension(urls[i]);
      final file = File('${dir.path}${Platform.pathSeparator}${(i + 1).toString().padLeft(2, '0')}.$ext');
      await file.writeAsBytes(bytes, flush: true);
      kept.add(file);
    }

    // printed reports (PDF) are kept beside the photos, as they are
    for (var i = 0; i < documentUrls.length; i++) {
      final res = await dio.get<List<int>>(documentUrls[i], options: Options(responseType: ResponseType.bytes));
      final bytes = res.data;
      if (bytes == null || bytes.isEmpty) throw StateError('empty download');

      final file = File('${dir.path}${Platform.pathSeparator}doc_${(i + 1).toString().padLeft(2, '0')}.pdf');
      await file.writeAsBytes(bytes, flush: true);
      kept.add(file);
    }

    return kept.length;
  }

  String _extension(String url) {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? '';
    for (final e in const ['jpg', 'jpeg', 'png', 'webp', 'gif']) {
      if (path.endsWith('.$e')) return e;
    }

    return 'jpg';
  }
}
