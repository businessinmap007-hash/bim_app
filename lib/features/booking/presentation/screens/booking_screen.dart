import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../business/data/models/offering_item.dart';
import '../../application/booking_providers.dart';
import '../../data/models/booking_form.dart';

/// Booking a specific priced offering («غرفة مزدوجة», «كشف عظام») at a
/// business. The form itself is entirely shape-driven — see
/// Api\V2\BookingController::form / BookingShapeResolver — so this widget
/// knows nothing about hotels or clinics either: it renders whichever
/// fields the shape asks for, mapping each known key to the payload
/// BookingShapeResolver::COLUMNS expects (unmapped keys ride in `meta`).
class BookingScreen extends ConsumerStatefulWidget {
  final int businessId;
  final OfferingItem offering;

  const BookingScreen({super.key, required this.businessId, required this.offering});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTime? _startsAt;
  DateTime? _endsAt;
  int _partySize = 1;
  int _quantity = 1;
  int _childrenCount = 0;
  String? _channel;
  String? _visitPlace;
  int? _unitId;
  final Set<int> _modifierOptionIds = {};
  final Map<String, TextEditingController> _textControllers = {};
  final _notesController = TextEditingController();
  bool _submitting = false;

  // Live total — same math as the actual booking (line + selected
  // modifiers per day, × days/quantity), fetched from the server so it
  // never disagrees with what create() ends up charging. Debounced so
  // toggling a few checkboxes in a row doesn't fire a request per tap.
  double? _previewTotal;
  bool _previewLoading = false;
  Timer? _previewDebounce;
  int _previewRequestId = 0;
  // Set when the server refuses to price the current selection (e.g. a
  // required unit hasn't been chosen). Shown next to the total so the
  // customer isn't left staring at a flat single-unit price that silently
  // never accounted for their dates/options, and blocks submitting into the
  // same guaranteed failure.
  String? _previewError;

  TextEditingController _controllerFor(String key) =>
      _textControllers.putIfAbsent(key, () => TextEditingController());

  @override
  void dispose() {
    _notesController.dispose();
    _previewDebounce?.cancel();
    for (final c in _textControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _schedulePreview() {
    _previewDebounce?.cancel();
    _previewDebounce = Timer(const Duration(milliseconds: 350), _fetchPreview);
  }

  Future<void> _fetchPreview() async {
    final requestId = ++_previewRequestId;
    setState(() => _previewLoading = true);
    try {
      final total = await ref.read(bookingApiProvider).preview(
        businessId: widget.businessId,
        serviceId: widget.offering.serviceId ?? 0,
        bookableId: _unitId,
        offeringId: widget.offering.id,
        offeringType: 'service_price',
        startsAt: _startsAt,
        endsAt: _endsAt,
        quantity: _quantity,
        partySize: _partySize,
        optionIds: _modifierOptionIds.toList(),
      );
      // A slower earlier request landing after a newer one must not
      // overwrite it with a stale total.
      if (mounted && requestId == _previewRequestId) {
        setState(() {
          _previewTotal = total;
          _previewError = null;
          _previewLoading = false;
        });
      }
    } catch (e) {
      if (mounted && requestId == _previewRequestId) {
        setState(() {
          _previewError = e is ApiException && e.message.isNotEmpty ? e.message : null;
          _previewLoading = false;
        });
      }
    }
  }

  /// The one selected modifier in a single-select group, if any — read
  /// straight off [_modifierOptionIds] rather than kept as separate state,
  /// mirroring the same pattern used for a menu item's extra groups.
  int? _singleModifierGroupValue(List<BookingModifier> groupModifiers) {
    for (final m in groupModifiers) {
      if (_modifierOptionIds.contains(m.optionId)) return m.optionId;
    }
    return null;
  }

  void _pickSingleModifier(List<BookingModifier> groupModifiers, int optionId) {
    setState(() {
      for (final m in groupModifiers) {
        _modifierOptionIds.remove(m.optionId);
      }
      _modifierOptionIds.add(optionId);
    });
    _schedulePreview();
  }

  /// Folds a flat modifier list into its taxonomy groups, in first-seen
  /// order. An ungrouped modifier becomes its own single-item "group" (no
  /// name, never single-select) so it keeps rendering as a plain checkbox.
  List<({String? name, bool isSingle, List<BookingModifier> modifiers})> _modifierGroupsIn(
    List<BookingModifier> modifiers,
  ) {
    final result = <({String? name, bool isSingle, List<BookingModifier> modifiers})>[];
    final seenGroupIds = <int>{};

    for (final m in modifiers) {
      final groupId = m.groupId;
      if (groupId == null) {
        result.add((name: null, isSingle: false, modifiers: [m]));
        continue;
      }
      if (!seenGroupIds.add(groupId)) continue;

      result.add((
        name: m.groupName,
        isSingle: m.isSingleSelect,
        modifiers: modifiers.where((x) => x.groupId == groupId).toList(),
      ));
    }

    return result;
  }

  List<BookingFormField> _fallbackFields(AppLocalizations l10n) => [
    BookingFormField(key: 'datetime', label: l10n.bookingDatetimeLabel, required: true),
    BookingFormField(key: 'notes', label: l10n.cartNotesLabel, required: false),
  ];

  Future<void> _pickDate({required bool isEnd}) async {
    final now = DateTime.now();
    final initial = (isEnd ? _endsAt : _startsAt) ?? now;
    final picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 730)),
      initialDate: initial.isBefore(now) ? now : initial,
    );
    if (picked == null) return;
    setState(() {
      if (isEnd) {
        _endsAt = picked;
      } else {
        _startsAt = picked;
      }
    });
    _schedulePreview();
  }

  Future<void> _pickDateTime({required bool isEnd}) async {
    final now = DateTime.now();
    final initial = (isEnd ? _endsAt : _startsAt) ?? now;
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 730)),
      initialDate: initial.isBefore(now) ? now : initial,
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(initial));
    if (time == null) return;
    final combined = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isEnd) {
        _endsAt = combined;
      } else {
        _startsAt = combined;
      }
    });
    _schedulePreview();
  }

  /// Everything the shape asked for that has no dedicated column —
  /// BookingShapeResolver::COLUMNS is the source of truth for what DOES.
  Map<String, dynamic> _buildMeta(List<BookingFormField> fields) {
    const known = {'datetime', 'date_range', 'duration', 'guest_count', 'party_size', 'quantity', 'notes'};
    final meta = <String, dynamic>{};
    for (final f in fields) {
      if (known.contains(f.key)) continue;
      switch (f.key) {
        case 'channel':
          if (_channel != null) meta['channel'] = _channel;
        case 'visit_place':
          if (_visitPlace != null) meta['visit_place'] = _visitPlace;
        case 'children_count':
          // 0 is a real answer ("no children"), not an unanswered field —
          // always send it once the field is on the form at all.
          meta['children_count'] = _childrenCount;
        default:
          final text = _textControllers[f.key]?.text.trim();
          if (text != null && text.isNotEmpty) meta[f.key] = text;
      }
    }
    return meta;
  }

  Future<void> _submit(BookingFormPayload form, List<BookableUnitOption> units) async {
    final l10n = AppLocalizations.of(context)!;
    final fields = form.shape?.fields ?? _fallbackFields(l10n);
    final hasDateRange = fields.any((f) => f.key == 'date_range' || f.key == 'duration');
    final hasDatetime = fields.any((f) => f.key == 'datetime');
    final needsUnit = form.shape?.needsUnit ?? false;

    if ((hasDateRange || hasDatetime) && _startsAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.bookingDateRequired)));
      return;
    }
    if (needsUnit && units.isNotEmpty && _unitId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.bookingUnitRequired)));
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref.read(bookingApiProvider).create(
        businessId: widget.businessId,
        serviceId: widget.offering.serviceId ?? 0,
        bookableId: _unitId,
        offeringId: widget.offering.id,
        offeringType: 'service_price',
        startsAt: _startsAt,
        endsAt: hasDateRange ? _endsAt : null,
        allDay: fields.any((f) => f.key == 'date_range'),
        partySize: fields.any((f) => f.key == 'guest_count' || f.key == 'party_size') ? _partySize : null,
        quantity: fields.any((f) => f.key == 'quantity') ? _quantity : null,
        notes: _notesController.text.trim(),
        meta: _buildMeta(fields),
        optionIds: _modifierOptionIds.toList(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.bookingSuccess)));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        // A 422/403 carries a specific, already-localized reason (e.g. "this
        // business books a specific unit — choose one first") — surfacing it
        // beats a generic "something went wrong" the customer can't act on.
        final message = e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final formAsync = ref.watch(bookingFormProvider(widget.businessId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookingScreenTitle)),
      body: AsyncValueView(
        value: formAsync,
        onRetry: () => ref.invalidate(bookingFormProvider(widget.businessId)),
        builder: (context, form) {
          final l10n = AppLocalizations.of(context)!;
          if (_previewTotal == null && !_previewLoading && _previewRequestId == 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _fetchPreview());
          }
          final rawFields = form.shape?.fields ?? _fallbackFields(l10n);
          // DURATION asks for both 'datetime' (a start point) and 'duration'
          // (start + how long) — the 'duration' picker's own "from" already
          // captures the start, so a plain 'datetime' field alongside it
          // would just be the same picker shown twice.
          final hasDurationField = rawFields.any((f) => f.key == 'duration');
          final fields = rawFields.where((f) => !(f.key == 'datetime' && hasDurationField)).toList();
          final needsUnit = form.shape?.needsUnit ?? false;
          final units = widget.offering.units.isNotEmpty ? widget.offering.units : form.units;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(widget.offering.label, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                '${widget.offering.price.toStringAsFixed(0)} ${widget.offering.currency}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              if (needsUnit) ...[
                Text(l10n.bookingChooseUnit, style: Theme.of(context).textTheme.titleSmall),
                _unitPickerSection(context, l10n, units),
                const SizedBox(height: 12),
              ],
              ...fields.map((field) => _fieldWidget(context, l10n, field, form.shape)),
              if (form.modifiers.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(l10n.bookingModifiersTitle, style: Theme.of(context).textTheme.titleSmall),
                // Grouped modifiers first — a single-select group (e.g.
                // «نظام الوجبات» set to radio by its owner) renders as
                // RadioListTile with enforced exclusivity; multiple-select
                // and ungrouped modifiers keep the plain checkbox list.
                for (final group in _modifierGroupsIn(form.modifiers)) ...[
                  if (group.name != null) Text(group.name!, style: Theme.of(context).textTheme.bodyMedium),
                  if (group.isSingle)
                    ...group.modifiers.map(
                      (m) => RadioListTile<int>(
                        contentPadding: EdgeInsets.zero,
                        value: m.optionId,
                        groupValue: _singleModifierGroupValue(group.modifiers),
                        onChanged: (value) => _pickSingleModifier(group.modifiers, m.optionId),
                        title: Text(m.name),
                        secondary: Text(
                          m.adjustType == 'percent'
                              ? '+${m.adjustValue.toStringAsFixed(0)}%'
                              : '+${m.adjustValue.toStringAsFixed(0)}',
                        ),
                      ),
                    )
                  else
                    ...group.modifiers.map(
                      (m) => CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _modifierOptionIds.contains(m.optionId),
                        onChanged: (checked) {
                          setState(() {
                            if (checked ?? false) {
                              _modifierOptionIds.add(m.optionId);
                            } else {
                              _modifierOptionIds.remove(m.optionId);
                            }
                          });
                          _schedulePreview();
                        },
                        title: Text(m.name),
                        secondary: Text(
                          m.adjustType == 'percent'
                              ? '+${m.adjustValue.toStringAsFixed(0)}%'
                              : '+${m.adjustValue.toStringAsFixed(0)}',
                        ),
                      ),
                    ),
                ],
              ],
              const SizedBox(height: 20),
              Card(
                margin: EdgeInsets.zero,
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.35),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n.bookingTotalLabel, style: Theme.of(context).textTheme.titleSmall),
                          _previewLoading && _previewTotal == null
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : Text(
                                  _previewTotal != null
                                      ? '${_previewTotal!.toStringAsFixed(0)} ${widget.offering.currency}'
                                      : '${widget.offering.price.toStringAsFixed(0)} ${widget.offering.currency}',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                                ),
                        ],
                      ),
                      // The number above may still be showing the flat
                      // single-unit price (never mind selected dates/options)
                      // when the server couldn't price the current
                      // selection — say so instead of letting it pass as
                      // the real total.
                      if (_previewError != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          _previewError!,
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _submitting || _previewError != null ? null : () => _submit(form, units),
                child: _submitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.bookingSubmit),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Real named units (rooms/tables/pitches), grouped by kind, with an
  /// image and — once dates are picked — live availability for those
  /// exact dates. See Api\V2\UnitDiscoveryController. Falls back to the
  /// plain unscoped list (no price/image/availability) while loading or on
  /// error, so a slow/failed request never blocks booking outright.
  Widget _unitPickerSection(BuildContext context, AppLocalizations l10n, List<BookableUnitOption> fallbackUnits) {
    final params = (
      businessId: widget.businessId,
      serviceId: widget.offering.serviceId,
      itemType: widget.offering.itemType,
      startsAt: _startsAt,
      endsAt: _endsAt,
    );
    final discoveryAsync = ref.watch(unitDiscoveryProvider(params));

    return discoveryAsync.when(
      data: (groups) {
        final entries = groups.expand((g) => g.units.map((u) => (group: g, unit: u))).toList();
        if (entries.isEmpty) return _fallbackUnitList(context, l10n, fallbackUnits);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final entry in entries)
              RadioListTile<int>(
                contentPadding: EdgeInsets.zero,
                value: entry.unit.id,
                groupValue: _unitId,
                onChanged: entry.unit.available == false
                    ? null
                    : (v) {
                        setState(() => _unitId = v);
                        _schedulePreview();
                      },
                title: Row(
                  children: [
                    if (entry.unit.images.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          entry.unit.images.first,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const SizedBox(width: 40, height: 40),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(child: Text(entry.unit.displayTitle)),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (entry.unit.capacity != null)
                      Text('${l10n.bookingCapacityLabel}: ${entry.unit.capacity}'),
                    if (entry.unit.price != null)
                      Text('${entry.unit.price!.toStringAsFixed(0)} ${entry.group.currency ?? ''}'),
                    if (entry.unit.available == false)
                      Text(
                        l10n.bookingUnitUnavailable,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => _fallbackUnitList(context, l10n, fallbackUnits),
    );
  }

  Widget _fallbackUnitList(BuildContext context, AppLocalizations l10n, List<BookableUnitOption> units) {
    if (units.isEmpty) {
      return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(l10n.bookingUnitEmpty));
    }
    return Column(
      children: units
          .map(
            (u) => RadioListTile<int>(
              contentPadding: EdgeInsets.zero,
              value: u.id,
              groupValue: _unitId,
              onChanged: (v) {
                setState(() => _unitId = v);
                _schedulePreview();
              },
              title: Text(u.title.isNotEmpty ? u.title : (u.code ?? '#${u.id}')),
              subtitle: u.capacity != null ? Text('${l10n.bookingCapacityLabel}: ${u.capacity}') : null,
            ),
          )
          .toList(),
    );
  }

  Widget _fieldWidget(BuildContext context, AppLocalizations l10n, BookingFormField field, BookingShape? shape) {
    final theme = Theme.of(context);
    final labelText = field.required ? '${field.label} *' : field.label;

    switch (field.key) {
      case 'date_range':
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(labelText, style: theme.textTheme.titleSmall),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.bookingFrom),
                      subtitle: Text(_startsAt != null ? DateFormat.yMd().format(_startsAt!) : l10n.bookingChoosePlaceholder),
                      onTap: () => _pickDate(isEnd: false),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.bookingTo),
                      subtitle: Text(_endsAt != null ? DateFormat.yMd().format(_endsAt!) : l10n.bookingChoosePlaceholder),
                      onTap: () => _pickDate(isEnd: true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      case 'duration':
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(labelText, style: theme.textTheme.titleSmall),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.bookingFrom),
                      subtitle: Text(
                        _startsAt != null ? DateFormat.yMd().add_Hm().format(_startsAt!) : l10n.bookingChoosePlaceholder,
                      ),
                      onTap: () => _pickDateTime(isEnd: false),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.bookingTo),
                      subtitle: Text(
                        _endsAt != null ? DateFormat.yMd().add_Hm().format(_endsAt!) : l10n.bookingChoosePlaceholder,
                      ),
                      onTap: () => _pickDateTime(isEnd: true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      case 'datetime':
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(labelText),
          subtitle: Text(
            _startsAt != null ? DateFormat.yMd().add_Hm().format(_startsAt!) : l10n.bookingChoosePlaceholder,
          ),
          trailing: const Icon(Icons.calendar_month_outlined),
          onTap: () => _pickDateTime(isEnd: false),
        );
      case 'guest_count':
      case 'party_size':
        return _stepperRow(context, labelText, _partySize, (v) {
          setState(() => _partySize = v);
          _schedulePreview();
        });
      case 'quantity':
        return _stepperRow(context, labelText, _quantity, (v) {
          setState(() => _quantity = v);
          _schedulePreview();
        });
      case 'children_count':
        return _stepperRow(context, labelText, _childrenCount, (v) => setState(() => _childrenCount = v), min: 0);
      case 'channel':
        return _choiceRow(
          context,
          labelText,
          shape?.channels ?? const [],
          _channel,
          (v) => setState(() => _channel = v),
          (v) => v == 'online' ? l10n.bookingChannelOnline : l10n.bookingChannelInPerson,
        );
      case 'visit_place':
        return _choiceRow(
          context,
          labelText,
          const ['at_business', 'at_customer'],
          _visitPlace,
          (v) => setState(() => _visitPlace = v),
          (v) => v == 'at_customer' ? l10n.bookingVisitAtCustomer : l10n.bookingVisitAtBusiness,
        );
      case 'notes':
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextField(
            controller: _notesController,
            decoration: InputDecoration(labelText: labelText),
            maxLines: 3,
          ),
        );
      default:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextField(
            controller: _controllerFor(field.key),
            decoration: InputDecoration(labelText: labelText),
          ),
        );
    }
  }

  Widget _stepperRow(BuildContext context, String label, int value, ValueChanged<int> onChanged, {int min = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          IconButton(
            onPressed: value > min ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          SizedBox(width: 32, child: Text('$value', textAlign: TextAlign.center)),
          IconButton(
            onPressed: () => onChanged(value + 1),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }

  Widget _choiceRow(
    BuildContext context,
    String label,
    List<String> options,
    String? selected,
    ValueChanged<String> onChanged,
    String Function(String) labelFor,
  ) {
    if (options.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: options
                .map((o) => ChoiceChip(label: Text(labelFor(o)), selected: selected == o, onSelected: (_) => onChanged(o)))
                .toList(),
          ),
        ],
      ),
    );
  }
}
