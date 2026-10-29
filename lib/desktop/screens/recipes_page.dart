import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/inventory/application/inventory_providers.dart';
import '../../features/inventory/data/inventory_models.dart';
import '../../features/inventory/presentation/inventory_labels.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/async_value_view.dart';
import 'common.dart';
import 'items_page.dart';

final _linksProvider = FutureProvider.autoDispose((ref) => ref.watch(inventoryApiProvider).links());

final _selectedOwnerProvider = StateProvider.autoDispose<(String, int)?>((ref) => null);

/// «ربط المنيو والوصفات» — what each sale takes out of the stock: a can sold as a can (one line, «مباشر»), or a burger
/// made of bread, meat and cheese (a recipe, with each line's preparation loss). A size or an extra adds its own lines.
class RecipesPage extends ConsumerWidget {
  const RecipesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final links = ref.watch(_linksProvider);
    final selected = ref.watch(_selectedOwnerProvider);

    return SuitePage(
      title: l10n.suiteNavRecipes,
      scroll: false,
      child: AsyncValueView(
        value: links,
        onRetry: () => ref.invalidate(_linksProvider),
        builder: (context, data) {
          final all = [...data.menu, ...data.retail];
          InvLinkOwner? find((String, int)? key) {
            if (key == null) return null;
            for (final o in all) {
              if (o.ownerType == key.$1 && o.ownerId == key.$2) return o;
              for (final c in [...o.variants, ...o.extras]) {
                if (c.ownerType == key.$1 && c.ownerId == key.$2) return c;
              }
            }
            return null;
          }

          final owner = find(selected);
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 340,
                child: Card(
                  child: ListView(
                    children: [
                      for (final o in all)
                        ListTile(
                          selected: selected == (o.ownerType, o.ownerId),
                          title: Text(o.name),
                          subtitle: Text('${InvLabels.money(o.price)} ${l10n.stkCurrency}'),
                          trailing: _LinkBadge(link: o.link),
                          onTap: () => ref.read(_selectedOwnerProvider.notifier).state = (o.ownerType, o.ownerId),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: owner == null
                    ? Center(child: Text(l10n.suitePickMenuItem))
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _RecipeEditor(key: ValueKey('${owner.ownerType}${owner.ownerId}'), owner: owner, onSaved: () => ref.invalidate(_linksProvider)),
                            for (final c in [...owner.variants, ...owner.extras])
                              _RecipeEditor(key: ValueKey('${c.ownerType}${c.ownerId}'), owner: c, child: true, onSaved: () => ref.invalidate(_linksProvider)),
                          ],
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

class _LinkBadge extends StatelessWidget {
  final String link;
  const _LinkBadge({required this.link});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (text, bg, fg) = switch (link) {
      'recipe' => (l10n.suiteLinkRecipe, const Color(0xFFF4EBD6), const Color(0xFF5E440E)),
      'direct' => (l10n.suiteLinkDirect, const Color(0xFFE7F3EC), const Color(0xFF1F7A44)),
      _ => (l10n.suiteLinkNone, const Color(0xFFF9E4DF), const Color(0xFFB93A22)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}

class _RecipeEditor extends ConsumerStatefulWidget {
  final InvLinkOwner owner;
  final bool child;
  final VoidCallback onSaved;

  const _RecipeEditor({super.key, required this.owner, this.child = false, required this.onSaved});

  @override
  ConsumerState<_RecipeEditor> createState() => _RecipeEditorState();
}

class _RecipeEditorState extends ConsumerState<_RecipeEditor> {
  late final List<(int?, TextEditingController, TextEditingController)> _lines = [
    for (final l in widget.owner.lines) (l.itemId, TextEditingController(text: invNum(l.qty)), TextEditingController(text: invNum(l.wastePct))),
  ];

  @override
  void dispose() {
    for (final l in _lines) {
      l.$2.dispose();
      l.$3.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final lines = [
      for (final l in _lines)
        if (l.$1 != null && (parseNum(l.$2.text) ?? 0) > 0) InvRecipeLine(itemId: l.$1!, qty: parseNum(l.$2.text)!, wastePct: parseNum(l.$3.text) ?? 0),
    ];
    final ok = await suiteRun(context, () async {
      await ref.read(inventoryApiProvider).saveRecipe(widget.owner.ownerType, widget.owner.ownerId, lines);
      return true;
    }, queueable: false);
    if (ok == true) widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = ref.watch(suiteItemsProvider).valueOrNull?.items ?? const <InvItem>[];
    final o = widget.owner;

    return SuiteSection(
      title: widget.child ? '${l10n.suiteAddsTo}: ${o.name}' : o.name,
      actions: [
        if (!widget.child)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: Text(
              o.price > 0 ? l10n.suiteRecipeCost(InvLabels.money(o.cost), invNum(o.cost / o.price * 100)) : InvLabels.money(o.cost),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        FilledButton(onPressed: _save, child: Text(l10n.commonSave)),
      ],
      child: Column(
        children: [
          for (var i = 0; i < _lines.length; i++)
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _lines[i].$1,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: l10n.suiteIngredient, isDense: true),
                    items: [for (final it in items) DropdownMenuItem(value: it.id, child: Text('${it.nameAr} (${it.baseUnit})'))],
                    onChanged: (v) => setState(() => _lines[i] = (v, _lines[i].$2, _lines[i].$3)),
                  ),
                ),
                const SizedBox(width: 8),
                NumField(controller: _lines[i].$2, label: l10n.suiteQty),
                const SizedBox(width: 8),
                NumField(controller: _lines[i].$3, label: l10n.suiteWastePct),
                IconButton(
                  tooltip: l10n.commonDelete,
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _lines.removeAt(i)),
                ),
              ],
            ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              icon: const Icon(Icons.add),
              label: Text(l10n.suiteAddIngredient),
              onPressed: () => setState(() => _lines.add((null, TextEditingController(text: '1'), TextEditingController(text: '0')))),
            ),
          ),
        ],
      ),
    );
  }
}
