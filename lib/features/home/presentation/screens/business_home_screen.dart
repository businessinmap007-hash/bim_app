import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
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
    final name = state is AuthSignedIn ? (state.user.nameEn ?? state.user.name) : '';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeBusinessTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.authLogout,
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: Center(child: Text('${l10n.authWelcomeBack}, $name')),
    );
  }
}
