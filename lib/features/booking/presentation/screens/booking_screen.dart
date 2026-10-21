import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/arrival_notice_banner.dart';
import '../../../../core/assignment/assignee.dart';
import '../../../chairs/data/models/service_chair.dart';
import '../../../chairs/presentation/widgets/chair_picker.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../business/data/models/offering_item.dart';
import '../../application/booking_providers.dart';
import '../../data/models/unit_discovery.dart';
import '../../data/models/booking_form.dart';
import '../../../../core/time/egypt_time.dart';
import '../../../../core/time/clock_format.dart';
import '../../../../core/time/local_format.dart';
import '../../../course/data/models/course.dart';
import '../widgets/booking_unit_icon.dart';
import '../widgets/relationship_card.dart';

/// Booking a specific priced offering («غرفة مزدوجة», «كشف عظام») at a
/// business. The form itself is entirely shape-driven — see
/// Api\V2\BookingController::form / BookingShapeResolver — so this widget
/// knows nothing about hotels or clinics either: it renders whichever
/// fields the shape asks for, mapping each known key to the payload
/// BookingShapeResolver::COLUMNS expects (unmapped keys ride in `meta`).
class BookingScreen extends ConsumerStatefulWidget {
  final int businessId;
  final OfferingItem offering;

  /// How this business's booking page is drawn («أشكال الحجز») — null draws the form as it always was.
  final UnitShape? shape;

  /// The room the guest tapped on the business page — chosen already, so the picker is not shown again.
  final DiscoveredUnit? initialUnit;

  /// Opened from the Day use card: starts on the Day use side of the room type.
  final bool startInDayUse;

  /// The day and time (or the dates) already chosen on the page's own board — the form opens with them filled.
  final DateTime? initialStartsAt;
  final DateTime? initialEndsAt;
  final int? initialPartySize;

  /// «كورس»: the group chosen on the board — the dates and the group are its own, so the form does not ask them.
  final int? courseGroupId;

  /// …and what that group is, so the form can say it: its name, level, when it meets and when it starts.
  final CourseGroup? courseGroup;

  /// «بالدور»: the day named on the board — the business gives the turn and the time, so no time is asked.
  final DateTime? queueDate;

  /// «كرسي وعليه الحلاق»: the person chosen on the board — none means whoever is free.
  final ServiceChair? chair;

  /// «اختر مقدّم الخدمة»: the staff member the customer chose on the board — none means the business decides.
  final Assignee? provider;

  const BookingScreen({
    super.key,
    required this.businessId,
    required this.offering,
    this.shape,
    this.initialUnit,
    this.startInDayUse = false,
    this.initialStartsAt,
    this.initialEndsAt,
    this.initialPartySize,
    this.courseGroupId,
    this.courseGroup,
    this.queueDate,
    this.chair,
    this.provider,
  });

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
  // the length of the time chosen on the page's own board; a form that asks only for a start still sends the end
  Duration? _boardLength;
  // «Day use»: the guest picks only a date; the room type names the window and the flat price
  bool _dayUse = false;
  // what the chosen room type offers — kept from the moment it was picked, because the discovery request it came from
  // is keyed by the dates and is replaced as soon as a date is chosen
  DayUseOffer? _dayUseOffer;
  final Set<int> _modifierOptionIds = {};
  final Map<String, TextEditingController> _textControllers = {};
  final _notesController = TextEditingController();
  bool _submitting = false;

  /// The guest ticked that they are who a scoped room type is sold to («مصري أو مقيم» / «أجنبي»).
  bool _originConfirmed = false;

  String get _scope => widget.initialUnit?.guestScope ?? 'all';

  // Live total — same math as the actual booking (line + selected
  // modifiers per day, × days/quantity), fetched from the server so it
  // never disagrees with what create() ends up charging. Debounced so
  // toggling a few checkboxes in a row doesn't fire a request per tap.
  BookingPreview? _preview;
  double? get _previewTotal => _preview?.total;
  bool _previewLoading = false;
  BookingFormPayload? _form;
  Timer? _previewDebounce;
  int _previewRequestId = 0;
  // Set when the server refuses to price the current selection (e.g. a
  // required unit hasn't been chosen). Shown next to the total so the
  // customer isn't left staring at a flat single-unit price that silently
  // never accounted for their dates/options, and blocks submitting into the
  // same guaranteed failure.
  String? _previewError;

  @override
  void initState() {
    super.initState();
    final unit = widget.initialUnit;
    if (unit != null) {
      _unitId = unit.id;
      _dayUseOffer = unit.dayUse;
      _dayUse = widget.startInDayUse && unit.dayUse != null;
    }
    _startsAt = widget.initialStartsAt;
    _endsAt = widget.initialEndsAt;
    if (widget.initialStartsAt != null && widget.initialEndsAt != null) {
      _boardLength = widget.initialEndsAt!.difference(widget.initialStartsAt!);
    }
    if (widget.initialPartySize != null && widget.initialPartySize! > 0) _partySize = widget.initialPartySize!;
    // the total of what was chosen on the board, before anything else is touched
    if (_startsAt != null || _unitId != null) WidgetsBinding.instance.addPostFrameCallback((_) => _schedulePreview());
  }

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

  UnitDiscoveryParams get _discoveryParams => (
    businessId: widget.businessId,
    serviceId: widget.offering.serviceId,
    itemType: widget.offering.itemType,
    startsAt: _startsAt,
    endsAt: _endsAt,
  );

  /// What the chosen room type offers as Day use, if it does.
  DayUseOffer? _dayUseOfferOfSelected() => _unitId == null ? null : _dayUseOffer;

  bool get _dayUseActive => _dayUse && _dayUseOfferOfSelected() != null;

  void _schedulePreview() {
    _previewDebounce?.cancel();
    _previewDebounce = Timer(const Duration(milliseconds: 350), _fetchPreview);
  }

  Future<void> _fetchPreview() async {
    final requestId = ++_previewRequestId;
    setState(() => _previewLoading = true);
    try {
      final dayUse = _dayUseActive && _startsAt != null;
      final preview = await ref.read(bookingApiProvider).preview(
        businessId: widget.businessId,
        serviceId: widget.offering.serviceId ?? 0,
        bookableId: _unitId,
        offeringId: widget.offering.id,
        offeringType: 'service_price',
        startsAt: dayUse ? null : _startsAt,
        endsAt: dayUse ? null : _endsAt,
        dayUseDate: dayUse ? _startsAt : null,
        quantity: _quantity,
        partySize: _partySize,
        optionIds: _modifierOptionIds.toList(),
      );
      // A slower earlier request landing after a newer one must not
      // overwrite it with a stale total.
      if (mounted && requestId == _previewRequestId) {
        setState(() {
          _preview = preview;
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
      // 0 is «بدون»: the group is cleared and nothing is added
      if (optionId != 0) _modifierOptionIds.add(optionId);
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
    final now = EgyptTime.now();
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

  /// One screen for the whole stay: tap the first day and then the last, and every day between is selected. Replaces the two
  /// separate «من» and «إلى» pickers of a period booking.
  Future<void> _pickDateRange() async {
    final now = EgyptTime.today();
    final start = _startsAt;
    final end = _endsAt;
    final range = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 730)),
      initialDateRange: start != null && end != null && !end.isBefore(start) && !start.isBefore(now)
          ? DateTimeRange(start: DateTime(start.year, start.month, start.day), end: DateTime(end.year, end.month, end.day))
          : null,
    );
    if (range == null) return;
    setState(() {
      _startsAt = range.start;
      _endsAt = range.end;
    });
    _schedulePreview();
  }

  Future<void> _pickDateTime({required bool isEnd}) async {
    final now = EgyptTime.now();
    final initial = (isEnd ? _endsAt : _startsAt) ?? now;
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 730)),
      initialDate: initial.isBefore(now) ? now : initial,
    );
    if (date == null || !mounted) return;
    final time = await ClockFormat.pick(context, initial: TimeOfDay.fromDateTime(initial));
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
    final dayUse = _dayUseActive;

    if ((hasDateRange || hasDatetime || dayUse) && _startsAt == null && widget.queueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.bookingDateRequired)));
      return;
    }
    if (needsUnit && units.isNotEmpty && _unitId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.bookingUnitRequired)));
      return;
    }
    if (_scope != 'all' && !_originConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.guestScopeConfirmRequired)));
      return;
    }

    setState(() => _submitting = true);
    try {
      if (widget.queueDate != null) {
        final booked = await ref.read(bookingApiProvider).createQueued(
          businessId: widget.businessId,
          serviceId: widget.offering.serviceId ?? 0,
          offeringId: widget.offering.id,
          date: widget.queueDate!,
          notes: _notesController.text.trim(),
          meta: _buildMeta(fields),
          chairId: widget.chair?.id,
        );
        if (mounted) {
          final when = booked.queue?.expectedAt ?? booked.startsAt;
          final time = when == null ? '' : ClockFormat.time(context, when);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.queueTurnTaken(booked.queueTurn ?? 0, time))));
          Navigator.of(context).pop(true);
        }
        return;
      }

      await ref.read(bookingApiProvider).create(
        businessId: widget.businessId,
        serviceId: widget.offering.serviceId ?? 0,
        bookableId: _unitId,
        offeringId: widget.offering.id,
        offeringType: 'service_price',
        startsAt: dayUse ? null : _startsAt,
        endsAt: dayUse
            ? null
            : hasDateRange
            ? _endsAt
            : (_boardLength != null && _startsAt != null ? _startsAt!.add(_boardLength!) : null),
        dayUseDate: dayUse ? _startsAt : null,
        allDay: !dayUse && fields.any((f) => f.key == 'date_range'),
        partySize: fields.any((f) => f.key == 'guest_count' || f.key == 'party_size') ? _partySize : null,
        quantity: fields.any((f) => f.key == 'quantity') ? _quantity : null,
        notes: _notesController.text.trim(),
        meta: _buildMeta(fields),
        optionIds: _modifierOptionIds.toList(),
        courseGroupId: widget.courseGroupId,
        chairId: widget.chair?.id,
        providerId: widget.provider?.id,
        guestOrigin: _scope == 'locals' ? 'local' : (_scope == 'foreigners' ? 'foreign' : null),
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
          _form = form;
          final rawFields = form.shape?.fields ?? _fallbackFields(l10n);
          final pageShape = widget.shape;
          // DURATION asks for both 'datetime' (a start point) and 'duration'
          // (start + how long) — the 'duration' picker's own "from" already
          // captures the start, so a plain 'datetime' field alongside it
          // would just be the same picker shown twice.
          final hasDurationField = rawFields.any((f) => f.key == 'duration');
          final dayUseOffer = _dayUseOfferOfSelected();
          final dayUseOn = _dayUse && dayUseOffer != null;
          final fields = rawFields
              .where((f) => !(f.key == 'datetime' && hasDurationField))
              // a Day use asks for a date only — its own picker replaces the night/time fields
              .where((f) => !(dayUseOn && (f.key == 'date_range' || f.key == 'datetime' || f.key == 'duration')))
              // what the page's shape does not ask the guest
              .where((f) => !(pageShape != null && !pageShape.askGuestCounts && (f.key == 'guest_count' || f.key == 'party_size')))
              .where((f) => !(pageShape != null && !pageShape.askChildren && f.key == 'children_count'))
              // a group chosen on the board brings its own dates, group and level
              .where((f) => !(widget.courseGroupId != null && (f.key == 'date_range' || f.key == 'datetime' || f.key == 'group' || f.key == 'level')))
              .where((f) => !(widget.queueDate != null && f.key == 'datetime'))
              .toList();
          final needsUnit = form.shape?.needsUnit ?? false;
          final units = widget.offering.units.isNotEmpty ? widget.offering.units : form.units;
          final unitFirst = pageShape?.unitFirst ?? false;
          final modifiersBlock = _modifiersBlock(context, l10n, form, dayUseOn);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // what he and this business have been through together — before he books
              RelationshipCard(summary: form.relationship),
              if (widget.initialUnit != null) ...[
                _selectedUnitCard(context, widget.initialUnit!),
                // the hotel's add-ons (the meal plan) for a room sold through a partner: they come with the room, not with this business's form
                if (widget.initialUnit!.choices.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(l10n.bookingAddOnsTitle, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  for (final c in widget.initialUnit!.choices)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _modifierOptionIds.contains(c.optionId),
                      onChanged: (v) {
                        setState(() => (v ?? false) ? _modifierOptionIds.add(c.optionId) : _modifierOptionIds.remove(c.optionId));
                        _schedulePreview();
                      },
                      title: Text(c.name ?? ''),
                      secondary: Text(c.adjustType == 'percent' ? '+${c.adjustValue.toStringAsFixed(0)}%' : '+${c.amount.toStringAsFixed(0)}'),
                    ),
                ],
                // «أسعار للمصريين والمقيمين فقط»: the room is sold to one of the two; the guest says which they are, the hotel checks on arrival
                if (_scope != 'all')
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: _originConfirmed,
                    onChanged: (v) => setState(() => _originConfirmed = v ?? false),
                    title: Text(_scope == 'locals' ? l10n.guestScopeConfirmLocals : l10n.guestScopeConfirmForeigners),
                  ),
              ]
              else ...[
                Text(widget.offering.label, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  '${widget.offering.price.toStringAsFixed(0)} ${widget.offering.currency}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
              if (widget.courseGroup != null) ...[
                const SizedBox(height: 12),
                _courseGroupCard(context, l10n, widget.courseGroup!),
              ],
              if (widget.chair != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    ChairAvatar(chair: widget.chair, size: 40),
                    const SizedBox(width: 10),
                    Expanded(child: Text(AppLocalizations.of(context)!.chairWithPerson(widget.chair!.title), style: Theme.of(context).textTheme.titleSmall)),
                  ],
                ),
              ],
              if (widget.provider != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.person_outline),
                    const SizedBox(width: 10),
                    Expanded(child: Text(l10n.chairWithPerson(widget.provider!.line), style: Theme.of(context).textTheme.titleSmall)),
                  ],
                ),
              ],
              if ((form.arrivalNotice ?? '').isNotEmpty) ...[
                const SizedBox(height: 12),
                ArrivalNoticeBanner(message: form.arrivalNotice),
              ],
              const SizedBox(height: 20),
              if (needsUnit && widget.initialUnit == null) ...[
                Text(l10n.bookingChooseUnit, style: Theme.of(context).textTheme.titleSmall),
                _unitPickerSection(context, l10n, units),
                const SizedBox(height: 12),
              ],
              if (dayUseOffer != null) _dayUseSection(context, l10n, dayUseOffer),
              // the hotel's order: the room, then what is added to it (the meal plan), then the dates and the total
              if (unitFirst) ...modifiersBlock,
              ...fields.map((field) => _fieldWidget(context, l10n, field, form.shape)),
              if (!unitFirst) ...modifiersBlock,
              const SizedBox(height: 20),
              _summaryCard(context, l10n, dayUseOn),
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

  /// «مجموعة الصباح · مبتدئ · السبت والاثنين 10:00 ص · يبدأ 21 أكتوبر 2026» — the group the person is enrolling in.
  Widget _courseGroupCard(BuildContext context, AppLocalizations l10n, CourseGroup group) {
    final theme = Theme.of(context);
    final details = <String>[
      if (group.level != null) '${l10n.courseGroupLevel}: ${group.level}',
      if ((group.scheduleText ?? '').trim().isNotEmpty) group.scheduleText!.trim(),
      if (group.startsOn != null) l10n.courseStartsOn(LocalFormat.date(context).format(group.startsOn!)),
    ];

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.groups_outlined, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  for (final line in details)
                    Text(line, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The room the guest tapped on the business page, kept at the top of the form.
  Widget _selectedUnitCard(BuildContext context, DiscoveredUnit unit) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 84,
                height: 70,
                child: unit.images.isEmpty
                    ? ColoredBox(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(bookingUnitIcon(shapeCode: widget.shape?.code, itemType: widget.offering.itemType), color: theme.hintColor),
                      )
                    : Image.network(
                        unit.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(unit.displayTitle, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  if (unit.features.isNotEmpty)
                    Text(unit.features.join(' · '), style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                  if (unit.price != null || _dayUseActive)
                    // «عروض الحجز»: once the preview carries an offer, the night shows what it costs on average after it
                    (_preview != null && _preview!.offerDiscount > 0 && !_dayUseActive && _preview!.periods > 0)
                        ? Row(
                            children: [
                              Text('${(_preview!.total / _preview!.periods).toStringAsFixed(0)} ${widget.offering.currency}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                              const SizedBox(width: 8),
                              Text(unit.price!.toStringAsFixed(0), style: theme.textTheme.bodyMedium?.copyWith(decoration: TextDecoration.lineThrough, color: theme.hintColor)),
                            ],
                          )
                        : Text(
                            '${(_dayUseActive ? _dayUseOffer!.price : unit.price!).toStringAsFixed(0)} ${widget.offering.currency}',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                          ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// What the guest may add: the meal plan of a stay (one choice, with «بدون»), or — on the Day use side — the meals
  /// of the day (any number). Each side shows only its own groups.
  List<Widget> _modifiersBlock(BuildContext context, AppLocalizations l10n, BookingFormPayload form, bool dayUseOn) {
    final modifiers = form.modifiers.where((m) => m.isDayUse == dayUseOn).toList();
    if (modifiers.isEmpty) return const [];

    final theme = Theme.of(context);

    return [
      const SizedBox(height: 8),
      Text(dayUseOn ? l10n.bookingDayUseMealsTitle : l10n.bookingModifiersTitle, style: theme.textTheme.titleSmall),
      if (dayUseOn) Text(l10n.bookingDayUseMealsHint, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
      // Grouped modifiers first — a single-select group (e.g.
      // «نظام الوجبات» set to radio by its owner) renders as
      // RadioListTile with enforced exclusivity; multiple-select
      // and ungrouped modifiers keep the plain checkbox list.
      for (final group in _modifierGroupsIn(modifiers)) ...[
        if (group.name != null && !dayUseOn) Text(group.name!, style: theme.textTheme.bodyMedium),
        if (group.isSingle)
          // one choice → radio buttons, and always «بدون»: the guest may take none of the add-ons
          RadioGroup<int>(
            groupValue: _singleModifierGroupValue(group.modifiers) ?? 0,
            onChanged: (value) => _pickSingleModifier(group.modifiers, value ?? 0),
            child: Column(
              children: [
                RadioListTile<int>(contentPadding: EdgeInsets.zero, value: 0, title: Text(l10n.bookingNoAddOn)),
                ...group.modifiers.map(
                  (m) => RadioListTile<int>(
                    contentPadding: EdgeInsets.zero,
                    value: m.optionId,
                    title: Text(m.name),
                    secondary: Text(
                      m.adjustType == 'percent' ? '+${m.adjustValue.toStringAsFixed(0)}%' : '+${m.adjustValue.toStringAsFixed(0)}',
                    ),
                  ),
                ),
              ],
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
                m.adjustType == 'percent' ? '+${m.adjustValue.toStringAsFixed(0)}%' : '+${m.adjustValue.toStringAsFixed(0)}',
              ),
            ),
          ),
      ],
    ];
  }

  /// The total, with what it is made of: «الغرفة 800 · إطلالة 150 · نصف إقامة 250 = 1200 × 2 ليلة».
  Widget _summaryCard(BuildContext context, AppLocalizations l10n, bool dayUseOn) {
    final theme = Theme.of(context);
    final preview = _preview;
    final currency = widget.offering.currency;
    final lines = preview?.lines ?? const <({String name, double amount})>[];
    final showBreakdown = preview != null && lines.isNotEmpty && preview.unitPrice != null;
    final nights = preview?.periods ?? 1;

    String money(double v) => '${v.toStringAsFixed(0)} $currency';

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showBreakdown) ...[
              _summaryRow(theme, l10n.bookingBasePriceLine, money(preview.baseUnitPrice ?? 0)),
              for (final line in lines) _summaryRow(theme, line.name, '+${line.amount.toStringAsFixed(0)}'),
              if (!dayUseOn) ...[
                const Divider(height: 16),
                _summaryRow(theme, l10n.bookingNightPrice, money(preview.unitPrice!), bold: true),
                if (nights > 1) _summaryRow(theme, l10n.bookingTimesNights(nights), ''),
              ],
              const SizedBox(height: 8),
            ],
            if (preview != null && preview.offerDiscount > 0) ...[
              _summaryRow(theme, l10n.bookingOfferLine, '−${preview.offerDiscount.toStringAsFixed(0)} $currency', bold: true),
              const SizedBox(height: 4),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.bookingTotalLabel, style: theme.textTheme.titleSmall),
                _previewLoading && _previewTotal == null
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(
                        // before a total is known: the day's flat price when Day use is chosen, not the night's
                        (_previewTotal != null && !(_dayUseActive && _startsAt == null))
                            ? money(_previewTotal!)
                            : '${(_dayUseActive ? _dayUseOffer!.price : widget.offering.price).toStringAsFixed(0)} $currency',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
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
              Text(_previewError!, style: TextStyle(color: theme.colorScheme.error)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(ThemeData theme, String label, String value, {bool bold = false}) {
    final style = theme.textTheme.bodyMedium?.copyWith(fontWeight: bold ? FontWeight.w700 : null);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }

  /// «Day use»: the chosen room type is also sold through the day — the guest picks the date, the room type
  /// names the window and the price.
  Widget _dayUseSection(BuildContext context, AppLocalizations l10n, DayUseOffer offer) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: false, label: Text(l10n.bookingStayByNight)),
                ButtonSegment(value: true, label: Text(l10n.bookingDayUse)),
              ],
              selected: {_dayUse},
              onSelectionChanged: (s) {
                setState(() {
                  _dayUse = s.first;
                  // the nights meal plan and the days meals are different groups - leaving one drops its ticks
                  final other = (_form?.modifiers ?? const <BookingModifier>[]).where((m) => m.isDayUse != _dayUse);
                  for (final m in other) {
                    _modifierOptionIds.remove(m.optionId);
                  }
                });
                _schedulePreview();
              },
            ),
          ),
          if (_dayUse) ...[
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.bookingDayUseDate),
              subtitle: Text(_startsAt != null ? LocalFormat.numeric(context).format(_startsAt!) : l10n.bookingChoosePlaceholder),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: () => _pickDate(isEnd: false),
            ),
            Text(
              '${l10n.bookingDayUseWindow(ClockFormat.hhmm(context, offer.from), ClockFormat.hhmm(context, offer.to))} · ${offer.price.toStringAsFixed(0)}',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }

  /// Real named units (rooms/tables/pitches), grouped by kind, with an
  /// image and — once dates are picked — live availability for those
  /// exact dates. See Api\V2\UnitDiscoveryController. Falls back to the
  /// plain unscoped list (no price/image/availability) while loading or on
  /// error, so a slow/failed request never blocks booking outright.
  Widget _unitPickerSection(BuildContext context, AppLocalizations l10n, List<BookableUnitOption> fallbackUnits) {
    final discoveryAsync = ref.watch(unitDiscoveryProvider(_discoveryParams));

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
                        setState(() {
                          _unitId = v;
                          _dayUseOffer = entry.unit.dayUse;
                          if (_dayUseOffer == null) _dayUse = false;
                        });
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
              // one control for the whole stay: from the first night to the day he leaves
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _startsAt != null && _endsAt != null
                      ? '${LocalFormat.numeric(context).format(_startsAt!)}  →  ${LocalFormat.numeric(context).format(_endsAt!)}'
                      : l10n.bookingChooseStay,
                ),
                // «الحضور يوم 20 أكتوبر والمغادرة يوم 25 أكتوبر · 5 ليالٍ»
                subtitle: _startsAt != null && _endsAt != null
                    ? Text(
                        '${l10n.bookingStayCheckInOut(LocalFormat.weekdayMonthDay(context).format(_startsAt!), LocalFormat.weekdayMonthDay(context).format(_endsAt!))}'
                        ' · ${l10n.bookingStayNights(_endsAt!.difference(_startsAt!).inDays.clamp(1, 100000))}',
                      )
                    : null,
                trailing: const Icon(Icons.date_range_outlined),
                onTap: _pickDateRange,
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
                        _startsAt != null ? LocalFormat.numeric(context).addClock().format(_startsAt!) : l10n.bookingChoosePlaceholder,
                      ),
                      onTap: () => _pickDateTime(isEnd: false),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.bookingTo),
                      subtitle: Text(
                        _endsAt != null ? LocalFormat.numeric(context).addClock().format(_endsAt!) : l10n.bookingChoosePlaceholder,
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
            _startsAt != null ? LocalFormat.numeric(context).addClock().format(_startsAt!) : l10n.bookingChoosePlaceholder,
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
