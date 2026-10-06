import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/scrolling_chip_row.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../categories/application/categories_providers.dart';
import '../../../categories/data/models/category_root.dart';
import '../../../categories/data/models/specialty.dart';
import '../../application/profile_options_controller.dart';
import '../../data/models/profile_options.dart';

/// «اعدادات البزنس» — المالك، 2026-10-06: what the business IS — its category and specialty, and its choices:
/// «شروط المتجر» (returns, delivery & pickup, minimum order…) and the attributes that describe it. One save.
///
/// The account is not COMPLETE until it has said how it delivers and hands over orders: until then its products are
/// not shown to customers (the server enforces it) and this page says so, on top.
class BusinessSettingsScreen extends ConsumerStatefulWidget {
  const BusinessSettingsScreen({super.key});

  @override
  ConsumerState<BusinessSettingsScreen> createState() => _BusinessSettingsScreenState();
}

class _BusinessSettingsScreenState extends ConsumerState<BusinessSettingsScreen> {
  bool _saving = false;
  String? _error;

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final state = ref.read(profileOptionsControllerProvider);

    // A group the account cannot be complete without needs at least one tick.
    for (final group in state.terms) {
      if (group.required && !group.options.any((o) => state.selectedIds.contains(o.id))) {
        setState(() => _error = l10n.setupChooseAtLeastOne(group.name));
        return;
      }
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    final ok = await ref.read(profileOptionsControllerProvider.notifier).save();
    if (ok) {
      // The server says whether the account is complete now; the rest of the app (the banner, the settings badge) follows.
      await ref.read(authControllerProvider.notifier).refreshUser();
      messenger.showSnackBar(SnackBar(content: Text(l10n.profileSaved)));
    } else if (ref.read(profileOptionsControllerProvider).loaded) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final auth = ref.watch(authControllerProvider);
    final user = auth is AuthSignedIn ? auth.user : null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.businessSettingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (user != null && !user.setupComplete) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.error),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: theme.colorScheme.error),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.setupIncompleteTitle, style: theme.textTheme.titleSmall),
                        const SizedBox(height: 4),
                        Text(l10n.setupIncompleteBody, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          _FieldLabel(l10n.profileCategory),
          const SizedBox(height: 6),
          _RootCategoryLabel(categoryId: user?.categoryId),
          const SizedBox(height: 16),
          _FieldLabel(l10n.profileSpecialty),
          const SizedBox(height: 6),
          _SpecialtyLabel(categoryId: user?.categoryId, categoryChildId: user?.categoryChildId),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.w600)),
          ],
          if (user?.categoryChildId != null) ...[
            const SizedBox(height: 16),
            _OptionsSection(onSave: _save, saving: _saving),
          ],
        ],
      ),
    );
  }
}

/// Resolves a specialty id to its display name for the profile's read-only
/// summary — there's no "look up one specialty by id" endpoint, so this
/// re-reads the root's already-cached specialty list (the same data the
/// category picker itself uses) and finds the match locally.
class _SpecialtyLabel extends ConsumerWidget {
  final int? categoryId;
  final int? categoryChildId;

  const _SpecialtyLabel({
    required this.categoryId,
    required this.categoryChildId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final style = Theme.of(context).textTheme.bodyMedium;

    if (categoryChildId == null) {
      return Text(l10n.profileSpecialtyNotSet, style: style);
    }
    if (categoryId == null) {
      return Text('#$categoryChildId', style: style);
    }

    final specialtiesAsync = ref.watch(specialtiesProvider(categoryId!));
    return specialtiesAsync.when(
      data: (specialties) {
        final languageCode = Localizations.localeOf(context).languageCode;
        Specialty? match;
        for (final specialty in specialties) {
          if (specialty.id == categoryChildId) {
            match = specialty;
            break;
          }
        }
        return Text(
          match?.localizedName(languageCode) ?? '#$categoryChildId',
          style: style,
        );
      },
      loading: () => const SizedBox(
        height: 16,
        width: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (error, stack) => Text('#$categoryChildId', style: style),
    );
  }
}

/// The root category name («عقارات و أراضي») above the specialty — there's
/// no "one root by id" endpoint either, so this matches against the same
/// cached root list the home grid and category picker already use.
class _RootCategoryLabel extends ConsumerWidget {
  final int? categoryId;
  const _RootCategoryLabel({required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final style = Theme.of(context).textTheme.bodyMedium;

    if (categoryId == null) {
      return Text(l10n.profileCategoryNotSet, style: style);
    }

    final rootsAsync = ref.watch(categoryRootsProvider);
    return rootsAsync.when(
      data: (roots) {
        final languageCode = Localizations.localeOf(context).languageCode;
        CategoryRoot? match;
        for (final root in roots) {
          if (root.id == categoryId) {
            match = root;
            break;
          }
        }
        return Text(
          match?.localizedName(languageCode) ?? '#$categoryId',
          style: style,
        );
      },
      loading: () => const SizedBox(
        height: 16,
        width: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (error, stack) => Text('#$categoryId', style: style),
    );
  }
}

/// A business's self-service attribute picks — every option for its
/// specialty, grouped, as checkboxes. Saved on its own ("حفظ الخصائص"),
/// separate from the main profile Save, since it's a different backend
/// endpoint (PATCH /profile/options replaces the whole set, not a diff).
class _OptionsSection extends ConsumerWidget {
  const _OptionsSection({required this.onSave, required this.saving});

  final Future<void> Function() onSave;
  final bool saving;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(profileOptionsControllerProvider);
    final notifier = ref.read(profileOptionsControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // with store terms above, the groups below carry their own «خصائص النشاط» heading — one heading, not two
        if (state.terms.isEmpty) ...[
          _FieldLabel(l10n.profileOptionsTitle),
          const SizedBox(height: 8),
        ],
        if (state.error != null) ...[
          Text(
            state.error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 8),
        ],
        if (state.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (state.groups.isEmpty && state.terms.isEmpty)
          Text(
            l10n.profileOptionsEmpty,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
          )
        else ...[
          // «شروط المتجر» — set once, here: what is ticked is what customers read on the store page and at checkout.
          if (state.terms.isNotEmpty) ...[
            Text(
              l10n.storeTermsTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.storeTermsHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            for (final group in state.terms)
              _OptionGroupChips(group: group, state: state, notifier: notifier),
            const SizedBox(height: 8),
            if (state.groups.isNotEmpty)
              Text(
                l10n.profileOptionsTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            if (state.groups.isNotEmpty) const SizedBox(height: 12),
          ],
          for (final group in state.groups)
            _OptionGroupChips(group: group, state: state, notifier: notifier),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: ElevatedButton(
              onPressed: state.isSaving || saving ? null : onSave,
              child: state.isSaving || saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l10n.profileSave),
            ),
          ),
        ],
      ],
    );
  }
}

/// One group of options as chips — a store term or a business attribute, ticked the same way.
class _OptionGroupChips extends StatelessWidget {
  final ProfileOptionGroup group;
  final ProfileOptionsState state;
  final ProfileOptionsController notifier;
  const _OptionGroupChips({
    required this.group,
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(group.name, style: Theme.of(context).textTheme.titleSmall),
        ScrollingChipRow(
          spacing: 4,
          children: [
            for (final option in group.options)
              FilterChip(
                label: Text(option.name),
                selected: state.selectedIds.contains(option.id),
                onSelected: (value) => notifier.toggle(option.id, value),
                selectedColor: AppColors.accentGold.withValues(alpha: 0.3),
              ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}


class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(label, style: Theme.of(context).textTheme.titleSmall);
  }
}
