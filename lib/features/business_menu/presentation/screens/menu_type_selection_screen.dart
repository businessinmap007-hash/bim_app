import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/business_menu_providers.dart';
import '../../data/models/menu_available_types.dart';

/// "اختيار الأصناف" — a multi-select checklist of every `line` option in ONE
/// section (e.g. all 45 vegetable kinds under "الخضروات"), so a merchant can
/// grow a narrow starting selection instead of being stuck with whatever a
/// handful of ticks looked like when the account was created. Saving
/// replaces exactly this section's ticks — every other section, and every
/// non-`line` attribute on "بيانات النشاط", is untouched (see
/// BusinessMenuItemController::updateAvailableTypes()).
class MenuTypeSelectionScreen extends ConsumerStatefulWidget {
  final int groupId;
  final String groupTitle;
  const MenuTypeSelectionScreen({super.key, required this.groupId, required this.groupTitle});

  @override
  ConsumerState<MenuTypeSelectionScreen> createState() => _MenuTypeSelectionScreenState();
}

class _MenuTypeSelectionScreenState extends ConsumerState<MenuTypeSelectionScreen> {
  Set<int> _selectedIds = {};
  bool _initialized = false;
  bool _saving = false;

  void _seedFrom(AvailableTypeGroup group) {
    if (_initialized) return;
    _initialized = true;
    _selectedIds = group.options.where((o) => o.selected).map((o) => o.id).toSet();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _saving = true);
    try {
      await ref.read(businessMenuApiProvider).updateAvailableTypes(
        groupId: widget.groupId,
        optionIds: _selectedIds.toList(),
      );
      // The narrowed vocabulary (item form's "Type" dropdown, this list's
      // own grouping) depends on the ticks this just changed.
      ref.invalidate(menuVocabularyProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.menuTypeSelectionSaved)));
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(menuAvailableTypesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.groupTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.commonSomethingWentWrong),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => ref.invalidate(menuAvailableTypesProvider),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
        data: (groups) {
          final group = groups.firstWhere(
            (g) => g.groupId == widget.groupId,
            orElse: () => AvailableTypeGroup(groupId: widget.groupId, groupName: widget.groupTitle, options: const []),
          );
          _seedFrom(group);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  l10n.menuTypeSelectionSubtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                  itemCount: group.options.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final option = group.options[index];
                    final selected = _selectedIds.contains(option.id);
                    return _TypeRow(
                      emoji: produceEmoji(option.nameEn),
                      label: option.nameAr,
                      selected: selected,
                      onTap: () => setState(() {
                        selected ? _selectedIds.remove(option.id) : _selectedIds.add(option.id);
                      }),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: async.maybeWhen(
        data: (_) => SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l10n.menuTypeSelectionContinue(_selectedIds.length)),
            ),
          ),
        ),
        orElse: () => null,
      ),
    );
  }
}

/// One selectable row — gold-highlighted with a filled check circle when
/// picked, plain otherwise, matching the design canvas mockup this screen
/// implements.
class _TypeRow extends StatelessWidget {
  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TypeRow({required this.emoji, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentGold.withValues(alpha: 0.12) : theme.inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.accentGold : theme.dividerColor, width: selected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.accentGold : Colors.transparent,
                border: Border.all(
                  color: selected ? AppColors.accentGold : theme.dividerColor.withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
              child: selected ? const Icon(Icons.check, size: 14, color: Color(0xFF0B1F3A)) : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// A best-effort emoji for a produce name — a lightweight, offline stand-in
/// for a real photo per item (downloading and licensing photos for ~120
/// generic vegetables/fruits isn't something to do sight-unseen). Matched by
/// substring on the English name so e.g. "Baladi Orange"/"Navel Orange"/
/// "Blood Orange" all land on 🍊. Falls back to a neutral basket for the long
/// tail (okra, molokhia, taro...) that has no fitting emoji.
String produceEmoji(String? nameEn) {
  final name = (nameEn ?? '').toLowerCase();
  if (name.isEmpty) return '🧺';

  const byMostSpecificFirst = <String, String>{
    'sweet potato': '🍠',
    'watermelon': '🍉',
    'cantaloupe': '🍈',
    'melon': '🍈',
    'papaya': '🍈',
    'mango': '🥭',
    'strawberry': '🍓',
    'grapes': '🍇',
    'vine leaves': '🍇',
    'orange': '🍊',
    'mandarin': '🍊',
    'grapefruit': '🍊',
    'lemon': '🍋',
    'lime': '🍋',
    'banana': '🍌',
    'apple': '🍎',
    'pear': '🍐',
    'peach': '🍑',
    'apricot': '🍑',
    'nectarine': '🍑',
    'plum': '🍑',
    'cherry tomato': '🍅',
    'cherries': '🍒',
    'pineapple': '🍍',
    'avocado': '🥑',
    'kiwi': '🥝',
    'coconut': '🥥',
    'mulberry': '🫐',
    'date': '🌴',
    'tomato': '🍅',
    'potato': '🥔',
    'onion': '🧅',
    'garlic': '🧄',
    'cucumber': '🥒',
    'courgette': '🥒',
    'zucchini': '🥒',
    'chilli': '🌶️',
    'pepper': '🫑',
    'aubergine': '🍆',
    'eggplant': '🍆',
    'carrot': '🥕',
    'bean': '🫘',
    'pea': '🫛',
    'spinach': '🥬',
    'lettuce': '🥬',
    'cabbage': '🥬',
    'chard': '🥬',
    'broccoli': '🥦',
    'cauliflower': '🥦',
    'pumpkin': '🎃',
    'corn': '🌽',
    'mushroom': '🍄',
    'ginger': '🫚',
    'herb': '🌿',
    'parsley': '🌿',
    'coriander': '🌿',
    'dill': '🌿',
    'mint': '🌿',
    'basil': '🌿',
    'rocket': '🌿',
    'celery': '🌿',
    'leek': '🌿',
    'radish': '🌿',
  };

  for (final entry in byMostSpecificFirst.entries) {
    if (name.contains(entry.key)) return entry.value;
  }

  return '🧺';
}
