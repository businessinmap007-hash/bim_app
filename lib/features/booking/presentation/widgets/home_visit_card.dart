import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../service_requests/presentation/widgets/request_photos_row.dart';
import '../../data/models/home_visit.dart';

/// «زيارة الفني»: where the technician goes — the address the customer chose when he accepted the quote — and the photos of
/// the problem. Shown on the visit booking to the customer and to the technician he chose; nobody else ever gets it.
class HomeVisitCard extends StatelessWidget {
  final HomeVisit visit;
  const HomeVisitCard({super.key, required this.visit});

  Future<void> _openMap(BuildContext context) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${visit.lat},${visit.lng}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.homeVisitTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (visit.addressLine != null && visit.addressLine!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_outlined, size: 20),
                  const SizedBox(width: 6),
                  Expanded(
                    child: SelectableText(
                      visit.addressLine!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              if (visit.hasPin)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: () => _openMap(context),
                    icon: const Icon(Icons.map_outlined, size: 18),
                    label: Text(l10n.homeVisitOpenMap),
                  ),
                ),
            ],
            if (visit.photos.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                l10n.homeVisitPhotos,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              const SizedBox(height: 6),
              RequestPhotosRow(urls: visit.photos),
            ],
          ],
        ),
      ),
    );
  }
}
