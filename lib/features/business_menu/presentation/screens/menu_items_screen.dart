import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/localized_name.dart';
import '../../../../shared/utils/produce_emoji.dart';
import '../../../../shared/widgets/horizontal_mouse_wheel_scroll.dart';
import '../../../../shared/widgets/view_mode_toggle.dart';
import '../../../media/application/media_picker_service.dart';
import '../../application/business_menu_providers.dart';
import '../../data/business_menu_api.dart' show SaleUnitOption;
import '../../data/models/menu_item.dart';
import '../../data/models/menu_vocabulary.dart';
import 'menu_item_edit_screen.dart';
import 'menu_sections_screen.dart';
import 'menu_type_selection_screen.dart';
import 'tech_pricing_screen.dart';

/// An item's own name is the best key for its emoji — "بطاطس" IS a potato
/// regardless of which vocabulary group it happens to sell under — falling
/// back to its line option's name for the (usual) case where the item was
/// created directly from that vocabulary branch and never got its own
/// English name typed in.
String _itemEmoji(BusinessMenuItem item) {
  // A catalog-linked device is named by its model («Oppo Reno 12F»),
  // which no emoji matches — its branch («Mobile») does.
  if (item.catalogProductId != null) return produceEmoji(item.lineOption?.nameEn);
  // A hand-named piece («غرفة نوم ماستر»): its own name first, else what it is.
  final own = produceEmoji(item.nameEn ?? item.nameAr);
  return own != '🧺' ? own : produceEmoji(item.lineOption?.nameEn ?? item.lineOption?.nameAr);
}

/// The merchant's own first photo, else the catalog model's photo.
String? _itemImage(BusinessMenuItem item) =>
    item.images.isNotEmpty ? item.images.first.url : item.catalogProduct?.image;

class _PriceDialogResult {
  final double price;
  final double? supplyPrice;
  final int? quantity;
  final String? unit;
  const _PriceDialogResult({required this.price, this.supplyPrice, this.quantity, this.unit});
}

class MenuItemsScreen extends ConsumerStatefulWidget {
  const MenuItemsScreen({super.key});

  @override
  ConsumerState<MenuItemsScreen> createState() => _MenuItemsScreenState();
}

class _MenuItemsScreenState extends ConsumerState<MenuItemsScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  // Anchors for the sticky branch nav — rebuilt each time the vocabulary's
  // shape changes, reused across scroll-driven rebuilds so a key already
  // handed to a mounted widget doesn't change identity under it.
  final Map<int, GlobalKey> _branchKeys = {};
  // null = "All" — every group renders. Picking one group FILTERS the list
  // down to just it instead of merely scrolling there, so a long catalog
  // (several groups, dozens of branches each) doesn't leave every other
  // group's items still sitting in the way below the one you asked for.
  int? _activeGroupId;

  GlobalKey _branchKey(int branchId) => _branchKeys.putIfAbsent(branchId, () => GlobalKey());

  void _jumpTo(GlobalKey key) {
    final target = key.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(target, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(menuItemsControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// «زر اضافة صنف العائم يجب ان يتم معالجته بان الصنف لابد ان يكون تابع
  /// لقسم من الاقسام اسم عربى واسم انجليزى … وياخذ نفس الموصفات كيلو -
  /// جرام - رابطة طالما تحت خضار وفاكهه سعر التوريد والبيع والكمية
  /// والصورة» — المالك، 2026-09-29. A business WITH a vocabulary picks a
  /// section here through [_NewItemScreen] instead of the full
  /// [MenuItemEditScreen] — a hand-typed business with none keeps the full
  /// editor, since it has no sections to require a pick from.
  Future<void> _openCreate() async {
    final vocab = ref.read(menuVocabularyProvider).asData?.value;
    final groups = vocab?.lines.where((g) => g.options.isNotEmpty).toList() ?? const <VocabularyGroup>[];

    // A trade whose groups DESCRIBE the item («غرفة نوم» — مودرن — زان) needs
    // the full form: what it is, its description, those choices, its photos.
    // The quick name-and-price page below has none of them. A trade with a
    // DETAILED group does not come here: its branches go on to «التسعير
    // والتفاصيل», which draws the describing choices itself.
    final describes = vocab?.modifiers.any((g) => g.descriptive && g.options.isNotEmpty) ?? false;
    final hasDetailed = groups.any((g) => g.detailed);

    if (groups.isEmpty || (describes && !hasDetailed)) {
      await Navigator.of(context).push<int>(
        MaterialPageRoute(builder: (_) => const MenuItemEditScreen()),
      );
      ref.read(menuItemsControllerProvider.notifier).load();
      return;
    }

    // «فتح شاشة اضافة صنف بدلا من البوب اب ويكون فيها اختيار القسم ايضا»
    // — المالك، 2026-10-01: a full page, not a dialog.
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => _NewItemScreen(groups: groups)),
    );
    if (created == true) {
      ref.read(menuItemsControllerProvider.notifier).load();
    }
  }

  /// «بدل اضافة صنف يكون الكارت بالصورة او الايموجى ومكان السعر يكون اضافة
  /// لسعر … وعند الضغط على اضافة سعر يظهر كارت اضافة سعر التوريد والبيع
  /// والكمية المتاحة» — المالك، 2026-09-29. Shared by [_quickAddPrice] (a
  /// branch with nothing priced yet) and [_quickEditPrice] (re-pricing an
  /// already-priced item — «بعد اضافة سعر لمنتج او الضغط على المنتج يفتح
  /// صفحة تسعير اخرى قم بحذفها», same owner, same day: tapping a priced
  /// item no longer opens the full [MenuItemEditScreen], it reopens this
  /// same minimal dialog, pre-filled). Returns null if the merchant
  /// cancelled or left the price blank.
  ///
  /// Price fields allow a decimal point OR comma — «سعر التوريد ممكن يكون
  /// 9.5 والبيع 12 ولا استطيع كتابة الرقم العشرى»: some Arabic-locale
  /// keyboards only offer the Eastern Arabic decimal separator «٫», which a
  /// plain `.`-only formatter would silently reject. Both parse the same way.
  Future<_PriceDialogResult?> _priceDialog({
    required String title,
    required List<String>? saleUnitCodes,
    double? initialSupplyPrice,
    double? initialPrice,
    int? initialQuantity,
    String? initialUnit,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final supplyController = TextEditingController(text: initialSupplyPrice?.toString() ?? '');
    final priceController = TextEditingController(text: initialPrice?.toString() ?? '');
    final quantityController = TextEditingController(text: initialQuantity?.toString() ?? '');
    String? selectedUnit = initialUnit;

    // Only a group the backend actually narrows (produce: bunch/kg/g — see
    // SaleUnits::producePackagingGroupNames()) gets a unit field here at
    // all; every other branch keeps this dialog to exactly what the owner
    // first asked for (supply/sale price, quantity).
    List<SaleUnitOption> units = const [];
    if (saleUnitCodes != null) {
      final all = await ref.read(saleUnitOptionsProvider.future);
      units = all.where((u) => saleUnitCodes.contains(u.code)).toList();
      if (selectedUnit == null && units.isNotEmpty) selectedUnit = units.first.code;
    }
    if (!mounted) return null;

    final decimalFormatters = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,٫]'))];

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: supplyController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: decimalFormatters,
                decoration: InputDecoration(labelText: l10n.marketCatalogSupplyPrice, isDense: true, border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: decimalFormatters,
                decoration: InputDecoration(labelText: l10n.marketCatalogSalePrice, isDense: true, border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: l10n.marketCatalogQuantity, isDense: true, border: const OutlineInputBorder()),
              ),
              if (units.isNotEmpty) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedUnit,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l10n.marketCatalogUnit, isDense: true, border: const OutlineInputBorder()),
                  items: units.map((u) => DropdownMenuItem(value: u.code, child: Text(u.label))).toList(),
                  onChanged: (value) => setDialogState(() => selectedUnit = value),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(l10n.commonCancel)),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(l10n.marketCatalogSave)),
          ],
        ),
      ),
    );

    if (saved != true) return null;
    final price = double.tryParse(priceController.text.trim().replaceAll(',', '.').replaceAll('٫', '.'));
    if (price == null) return null;

    return _PriceDialogResult(
      price: price,
      supplyPrice: double.tryParse(supplyController.text.trim().replaceAll(',', '.').replaceAll('٫', '.')),
      quantity: int.tryParse(quantityController.text.trim()),
      unit: selectedUnit,
    );
  }

  Future<void> _quickAddPrice(VocabularyOptionRef branch, List<String>? saleUnitCodes) async {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final result = await _priceDialog(
      title: localizedName(branch.nameAr, branch.nameEn, isEnglish),
      saleUnitCodes: saleUnitCodes,
    );
    if (result == null) return;

    try {
      await ref.read(businessMenuApiProvider).createItem(
        nameAr: branch.nameAr,
        nameEn: branch.nameEn,
        basePrice: result.price,
        supplyPrice: result.supplyPrice,
        saleUnit: result.unit,
        availableQuantity: result.quantity,
        lineOptionId: branch.id,
      );
      ref.read(menuItemsControllerProvider.notifier).load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.commonSomethingWentWrong)));
      }
    }
  }

  /// Re-price an already-priced item through the SAME minimal dialog instead
  /// of the full [MenuItemEditScreen] — everything else about the item
  /// (name, images, description, brand…) is left exactly as it was.
  Future<void> _quickEditPrice(BusinessMenuItem item, List<String>? saleUnitCodes) async {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final result = await _priceDialog(
      title: localizedName(item.nameAr, item.nameEn, isEnglish),
      saleUnitCodes: saleUnitCodes,
      initialSupplyPrice: item.supplyPrice,
      initialPrice: item.basePrice,
      initialQuantity: item.availableQuantity,
      initialUnit: item.saleUnit,
    );
    if (result == null) return;

    try {
      await ref.read(businessMenuApiProvider).updateItem(
        item.id,
        nameAr: item.nameAr,
        nameEn: item.nameEn,
        menuSectionId: item.menuSectionId,
        descriptionAr: item.descriptionAr,
        descriptionEn: item.descriptionEn,
        basePrice: result.price,
        supplyPrice: result.supplyPrice,
        saleUnit: result.unit,
        brandName: item.brandName,
        availableQuantity: result.quantity,
        lineOptionId: item.lineOption?.id,
        modifierOptionIds: item.modifierOptions.map((o) => o.id).toList(),
        sortOrder: item.sortOrder,
        isActive: item.isActive,
      );
      ref.read(menuItemsControllerProvider.notifier).load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.commonSomethingWentWrong)));
      }
    }
  }

  /// A `detailed` branch (see [VocabularyGroup.detailed]) opens «التسعير
  /// والتفاصيل» — the catalog-linked product picker — instead of the plain
  /// quantity/price dialog [_quickAddPrice]/[_quickEditPrice] open for an
  /// ordinary branch. Unlike those, this can be reopened for the SAME
  /// branch any number of times — a branch may carry several real models.
  Future<void> _openTechPricing(VocabularyOptionRef branch, {BusinessMenuItem? existingItem}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => TechPricingScreen(lineOption: branch, existingItem: existingItem)),
    );
    if (saved == true) {
      ref.read(menuItemsControllerProvider.notifier).load();
    }
  }

  /// "أنواع الأجهزة الكهربائية" as a SECTION: tapping its heading opens the
  /// full checklist of every type in that section (not just the narrow set
  /// already ticked), so a merchant isn't stuck with whatever a handful of
  /// ticks looked like when the account was seeded.
  Future<void> _openTypeSelection(int groupId, String groupTitle) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => MenuTypeSelectionScreen(groupId: groupId, groupTitle: groupTitle)),
    );
    if (changed == true) {
      ref.read(menuItemsControllerProvider.notifier).load();
    }
  }

  /// Grouping-by-branch is only worth it once this business has a real
  /// catalog vocabulary, and only on the unfiltered "all sections" view — a
  /// merchant who filtered to one hand-typed section is asking for a plain
  /// list of exactly that section's items, not a re-grouping of them.
  MenuVocabulary? _vocabularyForGrouping(MenuItemsState state) {
    if (state.sectionId != null) return null;
    return ref.watch(menuVocabularyProvider).maybeWhen(data: (v) => v.hasLines ? v : null, orElse: () => null);
  }

  bool _hasEmptyBranchesToShow(MenuItemsState state) {
    final vocabulary = _vocabularyForGrouping(state);
    return vocabulary != null && vocabulary.lines.any((g) => g.options.isNotEmpty);
  }

  /// Priced branches first (A→Z among themselves), then unpriced ones
  /// (A→Z among themselves) — see the call site's doc comment.
  List<VocabularyOptionRef> _sortedBranches(
    List<VocabularyOptionRef> branches,
    Map<int, List<BusinessMenuItem>> itemsByBranch,
    bool isEnglish,
  ) {
    final sorted = [...branches];
    sorted.sort((a, b) {
      final aFilled = itemsByBranch[a.id]?.isNotEmpty ?? false;
      final bFilled = itemsByBranch[b.id]?.isNotEmpty ?? false;
      if (aFilled != bFilled) return aFilled ? -1 : 1;
      return localizedName(a.nameAr, a.nameEn, isEnglish).compareTo(localizedName(b.nameAr, b.nameEn, isEnglish));
    });
    return sorted;
  }

  List<BusinessMenuItem> _sortedItems(List<BusinessMenuItem> items, bool isEnglish) {
    final sorted = [...items];
    sorted.sort(
      (a, b) => localizedName(a.nameAr, a.nameEn, isEnglish).compareTo(localizedName(b.nameAr, b.nameEn, isEnglish)),
    );
    return sorted;
  }

  /// A [_ItemTile] column, or — once the merchant picked "Grid" for
  /// customer display — the SAME items as [_ItemGridTile] cards, so this
  /// screen actually shows what that toggle does instead of only ever
  /// looking like a plain list regardless of which mode is selected.
  ///
  /// Tapping a card re-prices it through [_quickEditPrice] — the same
  /// minimal dialog [_EmptyBranchCard] opens, not the full
  /// [MenuItemEditScreen] (see [_priceDialog]'s doc for why).
  Widget _itemsFor(
    List<BusinessMenuItem> items,
    String displayMode,
    List<String>? saleUnitCodes, {
    bool detailed = false,
    VocabularyOptionRef? branch,
  }) {
    VoidCallback tapFor(BusinessMenuItem item) => detailed
        ? () => _openTechPricing(branch!, existingItem: item)
        : () => _quickEditPrice(item, saleUnitCodes);

    if (displayMode == 'grid') {
      // «اجعل كل كارتين فى سطر واذا كانت الشاشة اكبر يكون 3 فى سطر» —
      // المالك، 2026-09-29. Mobile stays 2 per row; a wider screen (tablet/
      // desktop, same tiers as Breakpoints.gridColumnsFor's own category
      // grid) gets 3.
      final columns = Breakpoints.sizeFor(MediaQuery.of(context).size.width) == ScreenSize.mobile ? 2 : 3;
      return GridView.count(
        crossAxisCount: columns,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.62,
        children: [
          for (final item in items)
            _ItemGridTile(
              item: item,
              onTap: tapFor(item),
            ),
          // A detailed branch may carry several real models — unlike an
          // ordinary branch, "add" stays available even once it has items.
          if (detailed && branch != null)
            _EmptyBranchGridTile(
              branch: branch,
              onAddPrice: () => _openTechPricing(branch),
              label: '${AppLocalizations.of(context)!.techPricingAddAnother} · ${localizedName(branch.nameAr, branch.nameEn, Localizations.localeOf(context).languageCode == 'en')}',
            ),
        ],
      );
    }

    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ItemTile(
              item: item,
              onTap: tapFor(item),
            ),
          ),
        if (detailed && branch != null)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: () => _openTechPricing(branch),
              icon: const Icon(Icons.add, size: 16),
              label: Text(
                '${AppLocalizations.of(context)!.techPricingAddAnother} · ${localizedName(branch.nameAr, branch.nameEn, Localizations.localeOf(context).languageCode == 'en')}',
              ),
            ),
          ),
      ],
    );
  }

  /// «شبكة بيكون كل كارت فى سطر منفردا اجعل كل كارتين فى سطر واذا كانت
  /// الشاشة اكبر يكون 3 فى سطر» — المالك، 2026-09-29. [_itemsFor] used to
  /// be called separately PER BRANCH, and most branches carry exactly one
  /// priced item — a grid of one child renders that one card alone, blank
  /// space beside it, no matter the column count. This builds ONE shared
  /// grid for the whole GROUP instead, so cards actually flow across
  /// branch boundaries. List mode is untouched — its own per-branch blocks
  /// are what "jump to this branch" scrolls to; here the first tile
  /// standing in for a branch carries that same [_branchKey].
  Widget _groupGrid(
    List<VocabularyOptionRef> branches,
    Map<int, List<BusinessMenuItem>> itemsByBranch,
    List<String>? saleUnitCodes, {
    bool detailed = false,
  }) {
    final columns = Breakpoints.sizeFor(MediaQuery.of(context).size.width) == ScreenSize.mobile ? 2 : 3;
    final tiles = <Widget>[];

    for (final branch in branches) {
      final items = itemsByBranch[branch.id];
      if (items != null && items.isNotEmpty) {
        for (var i = 0; i < items.length; i++) {
          final item = items[i];
          final isFirst = i == 0;
          tiles.add(_ItemGridTile(
            key: isFirst ? _branchKey(branch.id) : null,
            item: item,
            onTap: detailed
                ? () => _openTechPricing(branch, existingItem: item)
                : () => _quickEditPrice(item, saleUnitCodes),
          ));
        }
        // A detailed branch may carry several real models — unlike an
        // ordinary branch, "add" stays available even once it has items.
        if (detailed) {
          tiles.add(_EmptyBranchGridTile(
            branch: branch,
            onAddPrice: () => _openTechPricing(branch),
            label: AppLocalizations.of(context)!.techPricingAddAnother,
          ));
        }
      } else {
        tiles.add(_EmptyBranchGridTile(
          key: _branchKey(branch.id),
          branch: branch,
          onAddPrice: detailed ? () => _openTechPricing(branch) : () => _quickAddPrice(branch, saleUnitCodes),
          label: detailed ? AppLocalizations.of(context)!.techPricingAddProduct : null,
        ));
      }
    }

    return GridView.count(
      crossAxisCount: columns,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 0.62,
      children: tiles,
    );
  }

  Widget _buildList(BuildContext context, MenuItemsState state) {
    final vocabulary = _vocabularyForGrouping(state);
    final displayMode = ref.watch(menuDisplayModeControllerProvider).maybeWhen(data: (m) => m, orElse: () => 'list');
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    if (vocabulary == null) {
      return ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index >= state.items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final item = state.items[index];
          return _ItemTile(
            item: item,
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => MenuItemEditScreen(itemId: item.id)),
              );
              ref.read(menuItemsControllerProvider.notifier).load();
            },
          );
        },
      );
    }

    // Every branch the vocabulary knows about, in order — even one with no
    // items yet, so "+ إضافة علامة تجارية" is always there to start it.
    final itemsByBranch = <int, List<BusinessMenuItem>>{};
    for (final item in state.items) {
      final id = item.lineOption?.id;
      if (id != null) (itemsByBranch[id] ??= []).add(item);
    }
    // Items with no line option at all (a hand-typed extra) still need a home.
    final unbranched = state.items.where((i) => i.lineOption == null).toList();

    final groups = vocabulary.lines
        .where((g) => g.options.isNotEmpty && (_activeGroupId == null || g.groupId == _activeGroupId))
        .toList();
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      // A `ListView`'s `children:` list still builds through the Sliver
      // protocol — passing every child up front does NOT mount them all;
      // anything past the default ~250px cache extent stays unmounted with
      // a null `GlobalKey.currentContext` until scrolled near. That silently
      // broke jumping to a branch far down a long catalog while "All" is
      // selected (e.g. "الفواكه" sitting after "الخضروات"'s 45 branches):
      // the chip's own state updated, but `Scrollable.ensureVisible` had no
      // context to jump to and `_jumpTo`'s null-guard quietly did nothing. A
      // generous fixed extent keeps a business's whole catalog mounted —
      // this screen is a merchant's own low-traffic management view, not an
      // infinite feed.
      cacheExtent: 10000,
      children: [
        for (final group in groups) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(group.groupName, style: Theme.of(context).textTheme.titleSmall),
              // A plain TextButton read as just more label text next to the
              // heading — easy to miss even though it's the one control that
              // grows this group's whole catalog. A tonal pill makes it look
              // like the distinct action it is.
              FilledButton.tonalIcon(
                onPressed: () => _openTypeSelection(group.groupId, group.groupName),
                icon: const Icon(Icons.tune, size: 16),
                label: Text(AppLocalizations.of(context)!.menuItemsManageTypesAction),
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // «تنسيق المنتجات يجب ان يكون ابجديا والمنتجات المسعرة تكون فى
          // اعلى القائمة وليست بين المنتجات المسعرة وغير المسعرة» —
          // المالك، 2026-09-29: priced branches first (A→Z among
          // themselves), then unpriced ones (A→Z among themselves) — never
          // interleaved by vocabulary order the way they used to be.
          if (displayMode == 'grid')
            _groupGrid(
              _sortedBranches(group.options, itemsByBranch, isEnglish),
              itemsByBranch,
              group.saleUnitCodes,
              detailed: group.detailed,
            )
          else
            for (final branch in _sortedBranches(group.options, itemsByBranch, isEnglish)) ...[
              Padding(
                key: _branchKey(branch.id),
                padding: const EdgeInsets.only(bottom: 8),
                // A branch already carrying at least one priced item shows
                // exactly those cards — no separate heading, no more "add"
                // next to something already priced (the merchant's own
                // complaint: that button sat beside كزبرة خضراء even though
                // it already had a price). A branch with nothing yet shows
                // ONE placeholder card instead, matching a priced card's own
                // look (image/emoji, name) with "إضافة سعر" where the price
                // would be — tapping it is the only way in now; the old
                // always-there per-branch button is gone. A `detailed`
                // branch (see [VocabularyGroup.detailed]) is the one
                // exception: it may carry several real models, so "add"
                // stays available beside its own priced cards too.
                child: (itemsByBranch[branch.id]?.isNotEmpty ?? false)
                    ? _itemsFor(
                        itemsByBranch[branch.id]!,
                        displayMode,
                        group.saleUnitCodes,
                        detailed: group.detailed,
                        branch: branch,
                      )
                    : _EmptyBranchCard(
                        branch: branch,
                        onAddPrice: group.detailed
                            ? () => _openTechPricing(branch)
                            : () => _quickAddPrice(branch, group.saleUnitCodes),
                        label: group.detailed ? AppLocalizations.of(context)!.techPricingAddProduct : null,
                      ),
              ),
            ],
        ],
        if (unbranched.isNotEmpty) ...[
          Text(AppLocalizations.of(context)!.menuItemsUnbranchedSection, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          _itemsFor(_sortedItems(unbranched, isEnglish), displayMode, null),
        ],
        if (state.isLoadingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final state = ref.watch(menuItemsControllerProvider);
    final sectionsState = ref.watch(menuSectionsControllerProvider);
    // Once this business has a vocabulary, its "sections" ARE the
    // vocabulary's own line groups — shown right below by _GroupBranchNav,
    // always in sync with what's ticked. The hand-picked `menu_sections`
    // filter row below is for a business with NO vocabulary at all (a
    // hand-typed restaurant menu); showing BOTH for a vocabulary business
    // was two different, sometimes-disagreeing answers to "what are my
    // sections" (the real menu_sections table lags until an item is
    // actually priced under a group, per MenuSectionFromOptionGroup) —
    // and filtering into it silently dropped grid mode, since that path
    // never learned about displayMode at all.
    final hasLines = ref.watch(menuVocabularyProvider).maybeWhen(data: (v) => v.hasLines, orElse: () => false);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.menuItemsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: l10n.menuSectionsTitle,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MenuSectionsScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        icon: const Icon(Icons.add),
        label: Text(l10n.menuItemAdd),
      ),
      body: Column(
        children: [
          const _DisplayModeToggle(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.menuItemsSearchHint,
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => ref.read(menuItemsControllerProvider.notifier).setQuery(_searchController.text),
                ),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (q) => ref.read(menuItemsControllerProvider.notifier).setQuery(q),
            ),
          ),
          if (!hasLines)
            SizedBox(
              height: 44,
              child: MouseWheelHorizontalScroll(
                builder: (context, controller) => ListView(
                  controller: controller,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(l10n.menuItemsAllSections),
                        selected: state.sectionId == null,
                        onSelected: (_) => ref.read(menuItemsControllerProvider.notifier).filterBySection(null),
                      ),
                    ),
                    for (final section in sectionsState.items)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(localizedName(section.nameAr, section.nameEn, isEnglish)),
                          selected: state.sectionId == section.id,
                          onSelected: (_) => ref.read(menuItemsControllerProvider.notifier).filterBySection(section.id),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          _GroupBranchNav(
            vocabulary: _vocabularyForGrouping(state),
            selectedGroupId: _activeGroupId,
            onGroupTap: (groupId) => setState(() => _activeGroupId = groupId),
            onBranchTap: (branchId) => _jumpTo(_branchKey(branchId)),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.commonSomethingWentWrong),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () => ref.read(menuItemsControllerProvider.notifier).load(),
                          child: Text(l10n.commonRetry),
                        ),
                      ],
                    ),
                  )
                : state.items.isEmpty && !_hasEmptyBranchesToShow(state)
                ? Center(child: Text(l10n.menuItemsEmpty))
                : RefreshIndicator(
                    onRefresh: () => ref.read(menuItemsControllerProvider.notifier).load(),
                    child: _buildList(context, state),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Two chip rows — an "All" chip plus one per vocabulary group, then (once
/// one group is picked) that group's branches — that FILTER the list down
/// to the picked group instead of merely scrolling there. A long catalog
/// (several groups, dozens of branches) otherwise leaves every other
/// group's items still sitting below the one you actually asked to see;
/// the manual "All sections" filter chips above this stay untouched for
/// hand-typed sections, which this grouping doesn't apply to in the first
/// place.
class _GroupBranchNav extends StatelessWidget {
  final MenuVocabulary? vocabulary;
  final int? selectedGroupId;
  final ValueChanged<int?> onGroupTap;
  final ValueChanged<int> onBranchTap;

  const _GroupBranchNav({
    required this.vocabulary,
    required this.selectedGroupId,
    required this.onGroupTap,
    required this.onBranchTap,
  });

  @override
  Widget build(BuildContext context) {
    final groups = vocabulary?.lines.where((g) => g.options.isNotEmpty).toList() ?? const [];
    if (groups.isEmpty) return const SizedBox.shrink();
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final l10n = AppLocalizations.of(context)!;

    final active = groups.where((g) => g.groupId == selectedGroupId).firstOrNull;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (groups.length > 1)
          SizedBox(
            height: 40,
            child: MouseWheelHorizontalScroll(
              builder: (context, controller) => ListView.separated(
                controller: controller,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: groups.length + 1,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ChoiceChip(
                      label: Text(l10n.menuItemsAllSections),
                      selected: selectedGroupId == null,
                      onSelected: (_) => onGroupTap(null),
                    );
                  }
                  final group = groups[index - 1];
                  return ChoiceChip(
                    label: Text(group.groupName),
                    selected: group.groupId == selectedGroupId,
                    onSelected: (_) => onGroupTap(group.groupId),
                  );
                },
              ),
            ),
          ),
        if (groups.length > 1 && active != null) const SizedBox(height: 6),
        if (active != null)
          SizedBox(
            height: 36,
            child: MouseWheelHorizontalScroll(
              builder: (context, controller) => ListView.separated(
                controller: controller,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: active.options.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final branch = active.options[index];
                  return ActionChip(
                    label: Text(localizedName(branch.nameAr, branch.nameEn, isEnglish)),
                    onPressed: () => onBranchTap(branch.id),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

/// "طريقة العرض للعميل: قائمة/شبكة" — only worth showing once this business
/// has a catalog vocabulary; a hand-typed restaurant menu has no grid mode
/// to offer.
class _DisplayModeToggle extends ConsumerWidget {
  const _DisplayModeToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasLines = ref.watch(menuVocabularyProvider).maybeWhen(data: (v) => v.hasLines, orElse: () => false);
    if (!hasLines) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final modeAsync = ref.watch(menuDisplayModeControllerProvider);

    return modeAsync.maybeWhen(
      data: (mode) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.menuItemsDisplayModeLabel, style: Theme.of(context).textTheme.labelMedium),
            ViewModeToggle(
              isGrid: mode == 'grid',
              listLabel: l10n.menuItemsDisplayModeList,
              gridLabel: l10n.menuItemsDisplayModeGrid,
              onChanged: (grid) => ref.read(menuDisplayModeControllerProvider.notifier).setMode(grid ? 'grid' : 'list'),
            ),
          ],
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

/// A branch with nothing priced yet — same card shape as [_ItemTile] (an
/// emoji stand-in for the photo no item exists to carry, the branch's own
/// name), with "إضافة سعر" where a price would sit. The one way onto this
/// branch now that its old always-there header button is gone. A
/// `detailed` branch (see [VocabularyGroup.detailed]) shows "إضافة منتج"
/// instead — «على تابلت بدون سعر المفروض يكون اضافة منتج بدل من اضافة
/// سعر» — المالك، 2026-09-30: this button already opened «التسعير
/// والتفاصيل» correctly for a detailed branch, but its LABEL stayed the
/// plain quick-price wording regardless, which read as if the wrong
/// screen was about to open.
class _EmptyBranchCard extends StatelessWidget {
  final VocabularyOptionRef branch;
  final VoidCallback onAddPrice;
  final String? label;
  const _EmptyBranchCard({required this.branch, required this.onAddPrice, this.label});

  @override
  Widget build(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onAddPrice,
        leading: CircleAvatar(
          child: Text(produceEmoji(branch.nameEn), style: const TextStyle(fontSize: 18)),
        ),
        title: Text(localizedName(branch.nameAr, branch.nameEn, isEnglish)),
        trailing: TextButton.icon(
          onPressed: onAddPrice,
          icon: const Icon(Icons.add, size: 16),
          label: Text(label ?? AppLocalizations.of(context)!.menuItemsAddPrice),
        ),
      ),
    );
  }
}

/// [_EmptyBranchCard]'s counterpart for grid mode — same emoji placeholder,
/// name and "إضافة سعر" action, shaped to sit in [_ItemGridTile]'s own
/// GridView instead of falling back to a full-width ListTile there. See
/// [_EmptyBranchCard]'s own doc for why [label] exists — this same widget
/// also doubles as the "add another" tile after a detailed branch, so the
/// caller always states its own wording rather than this tile guessing.
class _EmptyBranchGridTile extends StatelessWidget {
  final VocabularyOptionRef branch;
  final VoidCallback onAddPrice;
  final String? label;
  const _EmptyBranchGridTile({super.key, required this.branch, required this.onAddPrice, this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onAddPrice,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                alignment: Alignment.center,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                child: Text(produceEmoji(branch.nameEn), style: const TextStyle(fontSize: 36)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizedName(branch.nameAr, branch.nameEn, isEnglish),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 6),
                  TextButton.icon(
                    onPressed: onAddPrice,
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(label ?? AppLocalizations.of(context)!.menuItemsAddPrice),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemTile extends ConsumerWidget {
  final BusinessMenuItem item;
  final VoidCallback onTap;
  const _ItemTile({required this.item, required this.onTap});

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.menuItemDeleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(menuItemsControllerProvider.notifier).delete(item.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final title = localizedName(item.nameAr, item.nameEn, isEnglish);
    // The OTHER language, as a secondary hint — same role this subtitle
    // always had, just no longer hardcoded to "always English" now that
    // the title itself follows the screen's language.
    final secondary = isEnglish ? item.nameAr : item.nameEn;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundImage: _itemImage(item) != null ? NetworkImage(_itemImage(item)!) : null,
          child: _itemImage(item) == null ? Text(_itemEmoji(item), style: const TextStyle(fontSize: 18)) : null,
        ),
        title: Text(title, style: TextStyle(color: item.isActive ? null : Theme.of(context).hintColor)),
        subtitle: item.availableQuantity != null
            ? Text(AppLocalizations.of(context)!.menuItemsQuantityShort(item.availableQuantity!))
            : (secondary != null && secondary.isNotEmpty && secondary != title ? Text(secondary) : null),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(item.basePrice.toStringAsFixed(2)),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _delete(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}

/// [_ItemTile]'s counterpart for the "Grid" customer-display mode — a photo
/// card, two per row, same tap-to-edit and delete actions. Merchants kept
/// seeing a plain list here no matter which mode they picked, since this
/// screen never actually rendered the mode it was letting them choose.
class _ItemGridTile extends ConsumerWidget {
  final BusinessMenuItem item;
  final VoidCallback onTap;
  const _ItemGridTile({super.key, required this.item, required this.onTap});

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.menuItemDeleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(menuItemsControllerProvider.notifier).delete(item.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    return Opacity(
      opacity: item.isActive ? 1 : 0.5,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: _itemImage(item) != null
                    ? Image.network(
                        _itemImage(item)!,
                        // a catalog shot is shown whole, the merchant's own filled
                        fit: item.images.isNotEmpty ? BoxFit.cover : BoxFit.contain,
                      )
                    : Container(
                        alignment: Alignment.center,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                        child: Text(_itemEmoji(item), style: const TextStyle(fontSize: 36)),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizedName(item.nameAr, item.nameEn, isEnglish),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    if (item.availableQuantity != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          l10n.menuItemsQuantityShort(item.availableQuantity!),
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                        ),
                      ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item.basePrice.toStringAsFixed(2), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                        InkWell(
                          onTap: () => _delete(context, ref),
                          child: Icon(Icons.delete_outline, size: 18, color: theme.hintColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One choice in [_NewItemScreen]'s section picker — EITHER an
/// existing `menu_sections` row (hand-typed by the owner, or already grown
/// from a vocabulary group earlier) or a vocabulary group that has not
/// grown a section yet. Exactly one of [sectionId]/[groupId] is set; which
/// one decides whether `createItem` is called with `menuSectionId` or
/// `optionGroupId`.
class _SectionChoice {
  final String key;
  final String label;
  final int? sectionId;
  final int? groupId;
  final List<String>? saleUnitCodes;
  /// Set for a branch of a DETAILED group («موبايل», «تابلت»…): picking it
  /// hands over to «التسعير والتفاصيل», which prices a real catalog model
  /// rather than a hand-typed name.
  final VocabularyOptionRef? branch;
  const _SectionChoice({
    required this.key,
    required this.label,
    this.sectionId,
    this.groupId,
    this.saleUnitCodes,
    this.branch,
  });
}

/// The FAB's "اضافة صنف" flow for a business WITH a vocabulary — a NEW
/// item name (not one of the fixed line options) that still has to belong
/// to one of the merchant's own sections, with the same required shape as
/// every other product there: bilingual name, the section's own sale-unit
/// restriction if it has one, price/supply/quantity, and a photo. See
/// [MenuItemsScreenState._openCreate]'s doc for the owner quote this answers.
///
/// «قمت باضافة قسم جديد وعند اضافة صنف جديد لم يظهر القسم الجديد فى
/// الاختيارات» — المالك، 2026-09-29: the picker used to list ONLY
/// vocabulary groups, so a section the owner typed by hand (no backing
/// group) never appeared. It now merges every EXISTING section (hand-typed
/// or already grown) with whichever vocabulary groups have not grown one
/// yet — see [_buildChoices].
class _NewItemScreen extends ConsumerStatefulWidget {
  final List<VocabularyGroup> groups;
  const _NewItemScreen({required this.groups});

  @override
  ConsumerState<_NewItemScreen> createState() => _NewItemScreenState();
}

class _NewItemScreenState extends ConsumerState<_NewItemScreen> {
  final _nameArController = TextEditingController();
  final _nameEnController = TextEditingController();
  final _supplyController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _picker = MediaPickerService();

  String? _choiceKey;
  String? _selectedUnit;
  String? _imagePath;
  bool _saving = false;

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    _supplyController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  List<_SectionChoice> _buildChoices(bool isEnglish) {
    final sections = ref.watch(menuSectionsControllerProvider).items;
    final groupSaleUnits = {for (final g in widget.groups) g.groupId: g.saleUnitCodes};
    final grownGroupIds = sections.map((s) => s.optionGroupId).whereType<int>().toSet();
    final detailed = widget.groups.where((g) => g.detailed).toList();
    final detailedIds = detailed.map((g) => g.groupId).toSet();
    final sellable = widget.groups.map((g) => g.groupId).toSet();

    return [
      // A detailed group is offered by BRANCH — its sections are grown per
      // branch from the catalog flow, never typed in by hand here.
      for (final g in detailed)
        for (final o in g.options)
          _SectionChoice(
            key: 'b:${o.id}',
            label: '${g.groupName} — ${localizedName(o.nameAr, o.nameEn, isEnglish)}',
            branch: o,
          ),
      // Only sections that still belong to a group this trade sells: a section
      // grown earlier from a group that now DESCRIBES («أنواع الأخشاب») or from
      // another trade's group is not an answer to «what is it».
      for (final s in sections.where((s) => !detailedIds.contains(s.optionGroupId) && (s.optionGroupId == null || sellable.contains(s.optionGroupId))))
        _SectionChoice(
          key: 's:${s.id}',
          label: localizedName(s.nameAr, s.nameEn, isEnglish),
          sectionId: s.id,
          saleUnitCodes: s.optionGroupId != null ? groupSaleUnits[s.optionGroupId] : null,
        ),
      for (final g in widget.groups)
        if (!g.detailed && !grownGroupIds.contains(g.groupId))
          _SectionChoice(key: 'g:${g.groupId}', label: g.groupName, groupId: g.groupId, saleUnitCodes: g.saleUnitCodes),
    ];
  }

  bool get _canSave =>
      !_saving &&
      _choiceKey != null &&
      _nameArController.text.trim().isNotEmpty &&
      _nameEnController.text.trim().isNotEmpty &&
      double.tryParse(_priceController.text.trim().replaceAll(',', '.').replaceAll('٫', '.')) != null;

  /// A detailed branch is priced through the catalog — this screen steps
  /// aside and reports whatever «التسعير والتفاصيل» saved.
  Future<void> _openTechPricing(VocabularyOptionRef branch) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => TechPricingScreen(lineOption: branch)),
    );
    if (mounted) Navigator.pop(context, saved == true);
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickFromGallery(allowMultiple: false);
    if (picked.isEmpty) return;
    setState(() => _imagePath = picked.first.file.path);
  }

  Future<void> _save() async {
    final price = double.tryParse(_priceController.text.trim().replaceAll(',', '.').replaceAll('٫', '.'));
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final choice = _buildChoices(isEnglish).where((c) => c.key == _choiceKey).firstOrNull;
    if (choice == null || price == null) return;

    setState(() => _saving = true);
    try {
      final item = await ref.read(businessMenuApiProvider).createItem(
        nameAr: _nameArController.text.trim(),
        nameEn: _nameEnController.text.trim(),
        basePrice: price,
        supplyPrice: double.tryParse(_supplyController.text.trim().replaceAll(',', '.').replaceAll('٫', '.')),
        saleUnit: _selectedUnit,
        availableQuantity: int.tryParse(_quantityController.text.trim()),
        menuSectionId: choice.sectionId,
        optionGroupId: choice.groupId,
      );
      final path = _imagePath;
      if (path != null) {
        await ref.read(businessMenuApiProvider).addImage(item.id, path);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.commonSomethingWentWrong)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final decimalFormatters = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,٫]'))];
    final choices = _buildChoices(isEnglish);
    final selected = choices.where((c) => c.key == _choiceKey).firstOrNull;
    final saleUnitCodes = selected?.saleUnitCodes;
    final unitsAsync = ref.watch(saleUnitOptionsProvider);
    final units = saleUnitCodes == null
        ? const <SaleUnitOption>[]
        : unitsAsync.maybeWhen(
            data: (all) => all.where((u) => saleUnitCodes.contains(u.code)).toList(),
            orElse: () => const <SaleUnitOption>[],
          );
    if (units.isNotEmpty && _selectedUnit == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedUnit = units.first.code);
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.menuItemAdd)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _choiceKey,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.menuItemSectionLabel, isDense: true, border: const OutlineInputBorder()),
              items: choices.map((c) => DropdownMenuItem(value: c.key, child: Text(c.label))).toList(),
              onChanged: (value) {
                final branch = choices.where((c) => c.key == value).firstOrNull?.branch;
                if (branch != null) {
                  _openTechPricing(branch);
                  return;
                }
                setState(() {
                  _choiceKey = value;
                  _selectedUnit = null;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameArController,
              decoration: InputDecoration(labelText: l10n.menuItemNameArHint, isDense: true, border: const OutlineInputBorder()),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameEnController,
              decoration: InputDecoration(labelText: l10n.menuItemNameEnHint, isDense: true, border: const OutlineInputBorder()),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _supplyController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: decimalFormatters,
              decoration: InputDecoration(labelText: l10n.marketCatalogSupplyPrice, isDense: true, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: decimalFormatters,
              decoration: InputDecoration(labelText: l10n.marketCatalogSalePrice, isDense: true, border: const OutlineInputBorder()),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(labelText: l10n.marketCatalogQuantity, isDense: true, border: const OutlineInputBorder()),
            ),
            if (units.isNotEmpty) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedUnit,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.marketCatalogUnit, isDense: true, border: const OutlineInputBorder()),
                items: units.map((u) => DropdownMenuItem(value: u.code, child: Text(u.label))).toList(),
                onChanged: (value) => setState(() => _selectedUnit = value),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Text(l10n.menuItemImagesSection, style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(width: 12),
                InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Theme.of(context).dividerColor),
                      image: _imagePath != null
                          ? DecorationImage(image: FileImage(File(_imagePath!)), fit: BoxFit.cover)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: _imagePath == null ? const Icon(Icons.add_a_photo_outlined) : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _canSave ? _save : null,
            child: _saving
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(l10n.marketCatalogSave),
          ),
        ),
      ),
    );
  }
}
