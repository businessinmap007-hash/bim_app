import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../settings/application/locale_controller.dart';

/// First screen an unauthenticated visitor sees. Only picks customer vs.
/// business today — per [[bim-project-roadmap]] other account kinds
/// (arbitrator, driver, pharmacy, doctor...) are provisioned by an admin or a
/// dedicated flow, never from this generic picker.
class AccountTypeScreen extends ConsumerWidget {
  const AccountTypeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Unconstrained on web/desktop this stretched full-bleed buttons
            // across a 1500px browser window — a form reads as a form up to
            // a point, then it's just a stretched mobile layout on a big
            // screen.
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.push_pin_rounded,
                        size: 64,
                        color: AppColors.accentGold,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.appName,
                        textAlign: TextAlign.center,
                        // No color override here: headlineMedium already
                        // carries the theme's own text color (white in dark
                        // mode, navy in light) via AppTextStyles.themed() —
                        // hardcoding navy made this text invisible against
                        // the dark background.
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
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
                        onPressed: () =>
                            context.push('/login', extra: 'client'),
                        child: Text(l10n.authAccountTypeCustomer),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () =>
                            context.push('/login', extra: 'business'),
                        child: Text(l10n.authAccountTypeBusiness),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Device locale drives the default (LocaleController), but a
            // first-time visitor must still be able to override it before
            // ever reaching Settings — there's no other screen yet where an
            // unauthenticated user can change language.
            PositionedDirectional(
              top: 8,
              end: 8,
              child: TextButton.icon(
                onPressed: () => ref
                    .read(localeControllerProvider.notifier)
                    .setLocale(Locale(locale.languageCode == 'ar' ? 'en' : 'ar')),
                icon: const Icon(Icons.language, size: 18),
                label: Text(locale.languageCode == 'ar' ? 'English' : 'العربية'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
