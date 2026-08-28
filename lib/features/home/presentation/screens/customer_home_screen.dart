import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../auth/application/auth_controller.dart';

/// Placeholder landing screen for a signed-in customer. The real home
/// (categories, discovery, offers) is Phase 2 of the roadmap — this exists
/// so the auth flow has somewhere to land and can be verified end to end.
class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(authControllerProvider);
    final name = state is AuthSignedIn ? state.user.name : '';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeCustomerTitle),
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
