import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../training/application/showcase_providers.dart';
import '../../../projects/data/models/project_showcase.dart';

/// «موافقة النشر العامة»: allow once that a business may show the results of my projects / training plans / nutrition plans as a
/// post — anonymous, only what I confirmed — instead of being asked every time. What I take down myself is never put back.
class ShowcaseConsentScreen extends ConsumerWidget {
  const ShowcaseConsentScreen({super.key});

  Future<void> _set(BuildContext context, WidgetRef ref, Map<String, bool> change) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    try {
      await ref.read(showcaseApiProvider).updateConsent(change);
      ref.invalidate(showcaseConsentProvider);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(showcaseConsentProvider);

    Widget body(ShowcaseConsent c) => ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.showcaseGeneralIntro, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              SwitchListTile(title: Text(l10n.showcaseGeneralProjects), value: c.projects, onChanged: (v) => _set(context, ref, {'projects': v})),
              SwitchListTile(
                title: Text(l10n.showcaseGeneralProjectPhotos),
                subtitle: Text(l10n.showcaseGeneralProjectPhotosHint),
                value: c.projectPhotos,
                onChanged: c.projects ? (v) => _set(context, ref, {'project_photos': v}) : null,
              ),
              SwitchListTile(title: Text(l10n.showcaseGeneralTraining), value: c.training, onChanged: (v) => _set(context, ref, {'training': v})),
              SwitchListTile(title: Text(l10n.showcaseGeneralNutrition), value: c.nutrition, onChanged: (v) => _set(context, ref, {'nutrition': v})),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(l10n.showcaseGeneralFootnote, style: Theme.of(context).textTheme.bodySmall),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.showcaseGeneralTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: OutlinedButton(onPressed: () => ref.invalidate(showcaseConsentProvider), child: Text(l10n.commonRetry))),
        data: body,
      ),
    );
  }
}
