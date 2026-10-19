import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../location/presentation/widgets/location_picker_field.dart';
import '../../../media/application/media_picker_service.dart';
import '../../../media/data/picked_media.dart';
import '../../application/owner_listings_providers.dart';
import '../../data/owner_listings_api.dart';
import '../widgets/owner_listing_card.dart';
import '../widgets/owner_listing_photo.dart';

/// Post one item (or change the one already posted): the category, sale / rent / swap, the price, the place, what the
/// category asks about the item, and the photos. One live listing per category per account — the server says so when a
/// second one is tried.
class OwnerListingFormScreen extends ConsumerStatefulWidget {
  /// Opens on this category (the cars root offers «سيارة»).
  final String? initialCategory;

  /// Editing: the listing as the server gave it (with its images and raw attributes).
  final OwnerListing? listing;

  const OwnerListingFormScreen({super.key, this.initialCategory, this.listing});

  @override
  ConsumerState<OwnerListingFormScreen> createState() =>
      _OwnerListingFormScreenState();
}

class _OwnerListingFormScreenState
    extends ConsumerState<OwnerListingFormScreen> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _picker = MediaPickerService();
  final Map<String, TextEditingController> _text = {};
  final Map<String, String?> _select = {};
  final List<PickedMedia> _photos = [];
  late List<OwnerImage> _existing = [...?widget.listing?.images];

  bool _agreeDeposit = false;
  String? _categoryKey;
  String _deal = 'sale';
  String _unit = 'month';
  LocationSelection? _where;
  bool _busy = false;
  String? _error;

  bool get _editing => widget.listing != null;

  @override
  void initState() {
    super.initState();
    final l = widget.listing;
    _categoryKey = l?.categoryKey ?? widget.initialCategory;

    if (l != null) {
      _deal = l.deal;
      _title.text = l.title;
      _description.text = l.description ?? '';
      _price.text = l.price == null ? '' : l.price!.toStringAsFixed(0);
      _unit = l.priceUnit ?? 'month';
      if (l.governorateId > 0) {
        _where = LocationSelection(
          countryId: l.countryId,
          governorateId: l.governorateId,
          cityId: l.cityId ?? 0,
          label: [
            l.governorate ?? '',
            l.city ?? '',
          ].where((s) => s.isNotEmpty).join(' — '),
        );
      }
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _price.dispose();
    for (final c in _text.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(String key) =>
      _text.putIfAbsent(key, () {
        final raw = widget.listing?.rawAttributes[key];
        return TextEditingController(text: raw == null ? '' : '$raw');
      });

  String? _selected(String key) => _select.containsKey(key)
      ? _select[key]
      : (widget.listing?.rawAttributes[key] == null
            ? null
            : '${widget.listing!.rawAttributes[key]}');

  Future<void> _addFromCamera() async {
    final media = await _picker.pickFromCamera();
    if (media != null) setState(() => _photos.add(media));
  }

  Future<void> _addFromGallery() async {
    final media = await _picker.pickFromGallery();
    if (media.isNotEmpty) setState(() => _photos.addAll(media));
  }

  Future<void> _removeExisting(OwnerImage image) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref
          .read(ownerListingsApiProvider)
          .deleteImage(widget.listing!.id, image.id);
      setState(
        () => _existing = _existing.where((i) => i.id != image.id).toList(),
      );
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = e is ApiException
              ? e.message
              : l10n.commonSomethingWentWrong,
        );
      }
    }
  }

  Map<String, dynamic> _attributes(OwnerCategory category) {
    final out = <String, dynamic>{};
    for (final f in category.fields.where((f) => f.appliesTo(_deal))) {
      if (f.type == 'select') {
        final v = _selected(f.key);
        if (v != null && v.isNotEmpty) out[f.key] = v;
      } else {
        final v = _controllerFor(f.key).text.trim();
        if (v.isEmpty) continue;
        out[f.key] = f.type == 'int' ? (int.tryParse(v) ?? v) : v;
      }
    }
    return out;
  }

  Future<void> _save(OwnerCategory category) async {
    final l10n = AppLocalizations.of(context)!;
    final where = _where;

    if (_title.text.trim().length < 3) {
      setState(() => _error = l10n.olTitleLabel);
      return;
    }
    if (where == null) {
      setState(() => _error = l10n.olPlaceRequired);
      return;
    }
    if (!_editing && _photos.isEmpty) {
      setState(() => _error = l10n.olNeedPhoto);
      return;
    }

    final requirement = ref.read(ownerRequirementProvider).valueOrNull;
    if (!_editing && requirement != null && requirement.needsDeposit) {
      if (!_agreeDeposit) {
        setState(() => _error = l10n.olDepositAgreeFirst);
        return;
      }
      if (!requirement.enoughBalance) {
        setState(() => _error = l10n.olDepositNoBalance);
        return;
      }
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final api = ref.read(ownerListingsApiProvider);
      final price = double.tryParse(_price.text.trim().replaceAll(',', ''));
      final cityId = where.cityId > 0 ? where.cityId : null;

      final int id;
      if (_editing) {
        id = widget.listing!.id;
        await api.update(
          id,
          deal: _deal,
          title: _title.text,
          description: _description.text,
          price: price,
          priceUnit: _unit,
          governorateId: where.governorateId,
          cityId: cityId,
          attributes: _attributes(category),
        );
      } else {
        final created = await api.create(
          category: category.key,
          deal: _deal,
          title: _title.text,
          description: _description.text,
          price: price,
          priceUnit: _unit,
          governorateId: where.governorateId,
          cityId: cityId,
          attributes: _attributes(category),
          holdDeposit: _agreeDeposit,
        );
        id = created.id;
      }

      await api.uploadImages(id, _photos);
      ref.invalidate(myOwnerListingsProvider);
      ref.invalidate(ownerListingProvider(id));
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e is ApiException ? e.message : l10n.commonSomethingWentWrong;
      });
    }
  }

  /// «جدية الإعلان»: a bronze+ guarantee stands behind the listing, or a deposit is held until it ends.
  List<Widget> _seriousness(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final r = ref.watch(ownerRequirementProvider).valueOrNull;
    if (r == null || !r.required) return const [];

    final amount = r.depositAmount.toStringAsFixed(
      r.depositAmount == r.depositAmount.roundToDouble() ? 0 : 2,
    );

    return [
      const SizedBox(height: 16),
      Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: r.guaranteeOk
              ? Row(
                  children: [
                    const Icon(Icons.verified_outlined, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(l10n.olSeriousGuaranteeOk(r.minLevelName)),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.olSeriousTitle,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(l10n.olSeriousBody(r.minLevelName, amount)),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _agreeDeposit,
                      onChanged: (v) =>
                          setState(() => _agreeDeposit = v ?? false),
                      title: Text(l10n.olSeriousAgree(amount)),
                    ),
                    if (!r.enoughBalance)
                      Text(
                        l10n.olDepositNoBalance,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                  ],
                ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final categories =
        ref.watch(ownerCategoriesProvider).valueOrNull ??
        const <OwnerCategory>[];
    final category = categories.where((c) => c.key == _categoryKey).firstOrNull;

    if (category != null && !category.deals.contains(_deal)) {
      // the deal the form had does not exist in this category (a phone is not let)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _deal = category.deals.first);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? l10n.olFormTitleEdit : l10n.olFormTitleNew),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            initialValue: categories.any((c) => c.key == _categoryKey)
                ? _categoryKey
                : null,
            isExpanded: true,
            decoration: InputDecoration(labelText: l10n.olCategoryLabel),
            items: [
              for (final c in categories)
                DropdownMenuItem(value: c.key, child: Text(c.name)),
            ],
            // a listing's category is fixed once posted
            onChanged: _editing
                ? null
                : (v) => setState(() => _categoryKey = v),
          ),
          if (category != null) ...[
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: [
                for (final d in category.deals)
                  ButtonSegment(value: d, label: Text(ownerDealLabel(l10n, d))),
              ],
              selected: {
                category.deals.contains(_deal) ? _deal : category.deals.first,
              },
              onSelectionChanged: (s) => setState(() => _deal = s.first),
            ),
            const SizedBox(height: 16),
            Text(l10n.olPhotosTitle, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            SizedBox(
              height: 88,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final image in _existing)
                    _thumb(
                      OwnerListingPhoto(
                        path: image.image,
                        width: 88,
                        height: 88,
                      ),
                      () => _removeExisting(image),
                    ),
                  for (var i = 0; i < _photos.length; i++)
                    _thumb(
                      FutureBuilder<Uint8List>(
                        future: _photos[i].file.readAsBytes(),
                        builder: (_, snap) => snap.hasData
                            ? Image.memory(
                                snap.data!,
                                width: 88,
                                height: 88,
                                fit: BoxFit.cover,
                              )
                            : const SizedBox(width: 88, height: 88),
                      ),
                      () => setState(() => _photos.removeAt(i)),
                    ),
                  _addButton(
                    Icons.photo_camera_outlined,
                    l10n.olAddPhotoCamera,
                    _addFromCamera,
                  ),
                  _addButton(
                    Icons.photo_library_outlined,
                    l10n.olAddPhotoGallery,
                    _addFromGallery,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _title,
              maxLength: 120,
              decoration: InputDecoration(labelText: l10n.olTitleLabel),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _price,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: _deal == 'swap'
                          ? l10n.olPriceOptionalLabel
                          : l10n.olPriceLabel,
                    ),
                  ),
                ),
                if (_deal == 'rent') ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _unit,
                      decoration: InputDecoration(
                        labelText: l10n.olPriceUnitLabel,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'day',
                          child: Text(l10n.olPerDay),
                        ),
                        DropdownMenuItem(
                          value: 'week',
                          child: Text(l10n.olPerWeek),
                        ),
                        DropdownMenuItem(
                          value: 'month',
                          child: Text(l10n.olPerMonth),
                        ),
                      ],
                      onChanged: (v) => setState(() => _unit = v ?? 'month'),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            LocationPickerField(
              value: _where,
              onChanged: (v) => setState(() => _where = v),
            ),
            const SizedBox(height: 16),
            Text(l10n.olDetails, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            for (final f in category.fields.where(
              (f) => f.appliesTo(_deal),
            )) ...[_fieldFor(f), const SizedBox(height: 12)],
            TextField(
              controller: _description,
              maxLines: 4,
              maxLength: 2000,
              decoration: InputDecoration(labelText: l10n.olDescriptionLabel),
            ),
            if (!_editing) ..._seriousness(context),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : () => _save(category),
              child: _busy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_editing ? l10n.olSaveEdit : l10n.olSave),
            ),
          ],
        ],
      ),
    );
  }

  Widget _fieldFor(OwnerField f) {
    final label = f.required ? '${f.label} *' : f.label;

    if (f.type == 'select') {
      final current = _selected(f.key);
      return DropdownButtonFormField<String>(
        initialValue: f.options.any((o) => o.value == current) ? current : null,
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
        items: [
          for (final o in f.options)
            DropdownMenuItem(value: o.value, child: Text(o.label)),
        ],
        onChanged: (v) => setState(() => _select[f.key] = v),
      );
    }

    return TextField(
      controller: _controllerFor(f.key),
      keyboardType: f.type == 'int' ? TextInputType.number : TextInputType.text,
      maxLength: f.type == 'text' ? 80 : null,
      decoration: InputDecoration(labelText: label, counterText: ''),
    );
  }

  Widget _thumb(Widget image, VoidCallback onRemove) => Padding(
    padding: const EdgeInsetsDirectional.only(end: 8),
    child: Stack(
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(8), child: image),
        PositionedDirectional(
          top: 0,
          end: 0,
          child: InkWell(
            onTap: onRemove,
            child: const CircleAvatar(
              radius: 11,
              backgroundColor: Colors.black54,
              child: Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _addButton(IconData icon, String label, VoidCallback onTap) => Padding(
    padding: const EdgeInsetsDirectional.only(end: 8),
    child: OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(88, 88),
        padding: const EdgeInsets.all(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    ),
  );
}
