import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../retail_listings/application/retail_listings_providers.dart';
import '../../../retail_listings/data/models/retail_listing.dart';
import '../../application/retail_variant_groups_providers.dart';
import '../../data/models/retail_variant_group.dart';
import '../../data/retail_variant_groups_api.dart';

/// «تنويعات المنتج» — group several of the business's own retail listings
/// (a color/size family) into one card the customer picks a variant from,
/// instead of unrelated separate listings. Mirrors the "Menu Bundles" screen's
/// shape: a plain list, a full-replace create/edit sheet, no partial editing.
class RetailVariantGroupsScreen extends ConsumerWidget {
  const RetailVariantGroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(retailVariantGroupsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.retailVariantGroupsTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context, ref),
        child: const Icon(Icons.add),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.commonSomethingWentWrong),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => ref.read(retailVariantGroupsControllerProvider.notifier).load(),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            )
          : state.items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.retailVariantGroupsEmpty, textAlign: TextAlign.center),
              ),
            )
          : RefreshIndicator(
              onRefresh: () => ref.read(retailVariantGroupsControllerProvider.notifier).load(),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                itemCount: state.items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final group = state.items[index];
                  return _GroupCard(
                    group: group,
                    onTap: () => _openForm(context, ref, existing: group),
                    onDelete: () => _delete(context, ref, group),
                  );
                },
              ),
            ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, RetailVariantGroup group) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.retailVariantGroupsDeleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(retailVariantGroupsApiProvider).delete(group.id);
      ref.read(retailVariantGroupsControllerProvider.notifier).load();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is ApiException ? e.message : l10n.commonSomethingWentWrong)),
        );
      }
    }
  }

  Future<void> _openForm(BuildContext context, WidgetRef ref, {RetailVariantGroup? existing}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _GroupFormSheet(existing: existing),
    );
    if (saved == true) ref.read(retailVariantGroupsControllerProvider.notifier).load();
  }
}

class _GroupCard extends StatelessWidget {
  final RetailVariantGroup group;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _GroupCard({required this.group, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(group.nameAr, style: Theme.of(context).textTheme.titleSmall)),
                  if (!group.isActive)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: Text(l10n.staffInactiveBadge, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 11)),
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: onDelete,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final o in group.options)
                    Chip(
                      label: Text('${o.label} · ${o.price?.toStringAsFixed(0) ?? '-'}'),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: o.isActive ? null : Theme.of(context).colorScheme.errorContainer,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DraftOption {
  final RetailListing listing;
  final TextEditingController labelController;
  _DraftOption(this.listing, String initialLabel) : labelController = TextEditingController(text: initialLabel);
}

class _GroupFormSheet extends ConsumerStatefulWidget {
  final RetailVariantGroup? existing;
  const _GroupFormSheet({this.existing});

  @override
  ConsumerState<_GroupFormSheet> createState() => _GroupFormSheetState();
}

class _GroupFormSheetState extends ConsumerState<_GroupFormSheet> {
  late final _nameArController = TextEditingController(text: widget.existing?.nameAr ?? '');
  late final _nameEnController = TextEditingController(text: widget.existing?.nameEn ?? '');
  final List<_DraftOption> _options = [];
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Existing options only carry {listing_id, label} — a placeholder
    // RetailListing is enough since the form only ever displays/edits the
    // label, never the underlying listing's own price/stock fields.
    for (final o in widget.existing?.options ?? const []) {
      _options.add(
        _DraftOption(
          RetailListing(
            id: o.listingId,
            price: o.price ?? 0,
            currency: 'EGP',
            isActive: o.isActive,
            visibility: 'public',
            productId: 0,
            productName: o.productName,
          ),
          o.labelAr,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    for (final o in _options) {
      o.labelController.dispose();
    }
    super.dispose();
  }

  Future<void> _pickListing() async {
    final l10n = AppLocalizations.of(context)!;
    final used = _options.map((o) => o.listing.id).toSet();
    final searchController = TextEditingController();
    List<RetailListing> results = [];
    bool loading = true;

    Future<void> runSearch(void Function(void Function()) setSheetState, String q) async {
      setSheetState(() => loading = true);
      try {
        final page = await ref.read(retailListingsApiProvider).list(q: q);
        setSheetState(() {
          results = page.items.where((l) => !used.contains(l.id)).toList();
          loading = false;
        });
      } catch (_) {
        setSheetState(() => loading = false);
      }
    }

    final picked = await showModalBottomSheet<RetailListing>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          if (loading && results.isEmpty) {
            // Kick off the initial load once.
            Future.microtask(() => runSearch(setSheetState, ''));
          }
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(sheetContext).viewInsets.bottom),
            child: SafeArea(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(sheetContext).size.height * 0.7),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.retailVariantGroupsPickListingTitle, style: Theme.of(sheetContext).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    TextField(
                      controller: searchController,
                      autofocus: true,
                      decoration: InputDecoration(hintText: l10n.retailVariantGroupsSearchHint, prefixIcon: const Icon(Icons.search)),
                      onChanged: (q) => runSearch(setSheetState, q),
                    ),
                    const SizedBox(height: 8),
                    if (loading) const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
                    if (!loading)
                      Flexible(
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            for (final l in results)
                              ListTile(
                                title: Text(l.productName ?? '#${l.productId}'),
                                subtitle: Text('${l.price.toStringAsFixed(0)} ${l.currency}'),
                                onTap: () => Navigator.of(sheetContext).pop(l),
                              ),
                            if (results.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Text(l10n.medicineNoResults),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
    if (picked != null && mounted) {
      setState(() => _options.add(_DraftOption(picked, picked.productName ?? '')));
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (_nameArController.text.trim().isEmpty || _options.length < 2) {
      setState(() => _error = l10n.retailVariantGroupsNeedTwo);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    final inputs = _options
        .map((o) => VariantOptionInput(listingId: o.listing.id, labelAr: o.labelController.text.trim()))
        .toList();
    try {
      final api = ref.read(retailVariantGroupsApiProvider);
      if (widget.existing != null) {
        await api.update(widget.existing!.id, nameAr: _nameArController.text.trim(), nameEn: _nameEnController.text.trim(), options: inputs);
      } else {
        await api.create(nameAr: _nameArController.text.trim(), nameEn: _nameEnController.text.trim(), options: inputs);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _saving = false;
        _error = e is ApiException ? e.message : l10n.commonSomethingWentWrong;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.existing == null ? l10n.retailVariantGroupsNewTitle : l10n.retailVariantGroupsEditTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameArController,
                  decoration: InputDecoration(labelText: l10n.retailVariantGroupsNameLabel),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _nameEnController,
                  decoration: const InputDecoration(labelText: 'Name (English)'),
                ),
                const SizedBox(height: 20),
                Text(l10n.retailVariantGroupsOptionsTitle, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                for (final o in _options) ...[
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(o.listing.productName ?? '#${o.listing.id}', overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: o.labelController,
                          decoration: InputDecoration(labelText: l10n.retailVariantGroupsLabelHint, isDense: true),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() => _options.remove(o)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                OutlinedButton.icon(
                  onPressed: _pickListing,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.retailVariantGroupsAddOption),
                ),
                const SizedBox(height: 12),
                if (_error != null) ...[
                  Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  const SizedBox(height: 8),
                ],
                FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(backgroundColor: AppColors.accentGold),
                  child: _saving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(l10n.commonSave),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
