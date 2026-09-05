import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';

/// Turn-by-turn navigation to a stop, delegated entirely to the phone's own
/// Google Maps app — no map SDK, no routing API, no ongoing cost to the
/// platform. Google's directions deep link accepts a plain text destination
/// (an address or even just a place name), not only lat/lng, which is why a
/// TripStop only ever carries a label + free-text address. Same
/// `launchUrl(..., mode: LaunchMode.externalApplication)` call already used
/// for "open in maps" in business_info_screen.dart — `dir` (directions)
/// rather than `search` (a pin), since this is "take me there."
class MapsLauncher {
  const MapsLauncher._();

  static Future<void> navigateTo(BuildContext context, String destination) async {
    final l10n = AppLocalizations.of(context)!;
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(destination)}');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
    }
  }
}
