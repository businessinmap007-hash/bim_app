import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/profile_cover_header.dart';
import '../../../auth/application/auth_controller.dart';

/// Placeholder for the business owner's panel. Real content (orders,
/// bookings, catalog, financial statement) lands module by module per the
/// roadmap's priority order — this is the auth-flow landing spot for now.
class BusinessHomeScreen extends ConsumerWidget {
  const BusinessHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(authControllerProvider);
    final name = state is AuthSignedIn
        ? (state.user.nameEn ?? state.user.name)
        : '';

    final business = state is AuthSignedIn ? state.user : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeBusinessTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settingsTitle,
            onPressed: () => context.push('/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.authLogout,
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ProfileCoverHeader(
            coverImageUrl: business?.coverUrl,
            avatarImageUrl: business?.logoUrl,
            title: name,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${l10n.authWelcomeBack}, $name',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}
