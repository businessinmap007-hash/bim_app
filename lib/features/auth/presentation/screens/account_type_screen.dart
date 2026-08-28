import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// First screen an unauthenticated visitor sees. Only picks customer vs.
/// business today — per [[bim-project-roadmap]] other account kinds
/// (arbitrator, driver, pharmacy, doctor...) are provisioned by an admin or a
/// dedicated flow, never from this generic picker.
class AccountTypeScreen extends StatelessWidget {
  const AccountTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.push_pin_rounded, size: 64, color: AppColors.accentGold),
              const SizedBox(height: 16),
              Text(
                l10n.appName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryNavy,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.appTagline,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 48),
              Text(
                l10n.authChooseAccountType,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.push('/login', extra: 'client'),
                child: Text(l10n.authAccountTypeCustomer),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.push('/login', extra: 'business'),
                child: Text(l10n.authAccountTypeBusiness),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
