import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/business_menu_providers.dart';
import '../../data/models/store_terms.dart';

/// «شروط المتجر» — the merchant answers the store's policies ONCE (returns, minimum order, delivery,
/// trade scope); they show on the menu page, at checkout, and are frozen on each order.
class StoreTermsScreen extends ConsumerStatefulWidget {
  const StoreTermsScreen({super.key});

  @override
  ConsumerState<StoreTermsScreen> createState() => _StoreTermsScreenState();
}

class _StoreTermsScreenState extends ConsumerState<StoreTermsScreen> {
  /// group id -> chosen option ids; null until the first load seeds it.
  Map<int, Set<int>>? _chosen;

  /// What was last saved — «تم الحفظ» shows while nothing differs from it.
  Map<int, Set<int>>? _saved;
  bool _saving = false;

  Map<int, Set<int>> _copy(Map<int, Set<int>> m) => {for (final e in m.entries) e.key: {...e.value}};

  /// False until the first save of this visit — an untouched screen offers «حفظ», not «تم الحفظ».
  bool get _isSaved {
    final saved = _saved, chosen = _chosen;
    if (saved == null || chosen == null) return false;
    for (final e in chosen.entries) {
      final was = saved[e.key] ?? const <int>{};
      if (was.length != e.value.length || !was.containsAll(e.value)) return false;
    }
    return true;
  }

  Map<int, Set<int>> _seed(List<StoreTermGroup> groups) => {
    for (final g in groups) g.groupId: {for (final o in g.options.where((o) => o.selected)) o.id},
  };

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      await ref.read(businessMenuApiProvider).saveStoreTerms({
        for (final e in _chosen!.entries) e.key: e.value.toList(),
      });
      _saved = _copy(_chosen!);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final termsAsync = ref.watch(storeTermsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.storeTermsTitle)),
      body: termsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.commonSomethingWentWrong)),
        data: (groups) {
          if (groups.isEmpty) {
            return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(l10n.storeTermsEmpty, textAlign: TextAlign.center)));
          }
          _chosen ??= _seed(groups);
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(l10n.storeTermsHint, style: theme.textTheme.bodySmall),
                    const SizedBox(height: 16),
                    for (final group in groups) ...[
                      Text(group.name, style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final option in group.options)
                            FilterChip(
                              label: Text(option.name),
                              selected: _chosen![group.groupId]!.contains(option.id),
                              onSelected: (on) => setState(() {
                                final set = _chosen![group.groupId]!;
                                on ? set.add(option.id) : set.remove(option.id);
                              }),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      // «تم الحفظ» while nothing differs from what was saved; «حفظ» again on any change.
                      onPressed: _saving || _isSaved ? null : _save,
                      child: Text(_isSaved ? l10n.storeTermsSavedDone : l10n.storeTermsSave),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
