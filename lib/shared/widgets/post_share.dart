import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/env/env.dart';
import '../../features/business/data/models/business_post.dart';
import '../../features/posts/application/posts_controller.dart';

/// The link shared for a post — a plain https:// URL (not a custom scheme:
/// WhatsApp/Facebook only auto-link http(s), so a `bimapp://` link would
/// just sit there as inert text in the share sheet's target app). The
/// backend serves a public preview page at this path (Open Graph tags for
/// a rich WhatsApp/Facebook card) that hands off into the app.
///
/// Only works as a real deep link — landing straight in the app rather than
/// a browser tab — once Android App Links / iOS Universal Links are set up
/// against the production domain (asset links / apple-app-site-association
/// files + native project config); that's a one-time platform setup this
/// doesn't attempt, since it needs the real domain to verify against, not
/// the dev API_BASE_URL a local run points at.
String postShareUrl(int postId) => '${Env.assetBaseUrl}/posts/$postId';

Future<void> sharePost(WidgetRef ref, BusinessPost post) async {
  final caption = [
    post.title,
    post.body,
  ].where((s) => s.isNotEmpty).join('\n');

  final text = [
    if (caption.isNotEmpty) caption,
    postShareUrl(post.id),
  ].join('\n\n');

  await SharePlus.instance.share(ShareParams(text: text));
  // Best-effort: the share sheet already did its job for the user even if
  // this count bump fails.
  unawaited(ref.read(postsApiProvider).incrementShareCount(post.id).catchError((_) {}));
}
