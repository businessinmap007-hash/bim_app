import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/business_menu_providers.dart';
import '../../data/models/shop_addons.dart';

/// «خدمات المحل» — the shop prices its services ONCE («المشوى 50، المقلى 80، الصينية 100»), per unit
/// bought. Every item of the shop carries them; the customer picks one and the invoice lists it.
class ShopAddonsScreen extends ConsumerStatefulWidget {
  const ShopAddonsScreen({super.key});

  @override
  ConsumerState<ShopAddonsScreen> createState() => _ShopAddonsScreenState();
}

class _ShopAddonsScreenState extends ConsumerState<ShopAddonsScreen> {
  /// option id -> its price field, seeded once from the first load.
  Map<int, TextEditingController>? _fields;

  /// The prices as last saved (text per option) — «تم الحفظ» shows while nothing differs from them.
  Map<int, String>? _saved;
  bool _saving = false;

  bool get _isSaved {
    final saved = _saved, fields = _fields;
    if (saved == null || fields == null) return false;
    return fields.entries.every((e) => (saved[e.key] ?? '') == e.value.text.trim());
  }

  @override
  void dispose() {
    for (final c in _fields?.values ?? const <TextEditingController>[]) {
      c.dispose();
    }
    super.dispose();
  }

  Map<int, TextEditingController> _seed(List<ShopAddonGroup> groups) => {
    for (final g in groups)
      for (final o in g.options)
        o.id: TextEditingController(text: o.price == null ? '' : _plain(o.price!)),
  };

  String _plain(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      await ref.read(businessMenuApiProvider).saveShopAddons({
        for (final e in _fields!.entries) e.key: double.tryParse(e.value.text.replaceAll(',', '.').trim()) ?? 0,
      });
      _saved = {for (final e in _fields!.entries) e.key: e.value.text.trim()};
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
    final async = ref.watch(shopAddonsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.shopAddonsTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.commonSomethingWentWrong)),
        data: (groups) {
          if (groups.isEmpty) {
            return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(l10n.shopAddonsEmpty, textAlign: TextAlign.center)));
          }
          _fields ??= _seed(groups);
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(l10n.shopAddonsHint, style: theme.textTheme.bodySmall),
                    const SizedBox(height: 16),
                    for (final group in groups) ...[
                      Text(group.name, style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      for (final option in group.options)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Expanded(child: Text(option.name, style: theme.textTheme.bodyMedium)),
                              SizedBox(
                                width: 130,
                                child: TextField(
                                  controller: _fields![option.id],
                                  onChanged: (_) => setState(() {}),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                                  decoration: InputDecoration(hintText: l10n.shopAddonPriceHint),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
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
