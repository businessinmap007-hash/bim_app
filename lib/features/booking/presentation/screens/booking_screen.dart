import '../../application/guest_origin.dart';
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
import '../../data/models/child_policy.dart';
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

  /// Every kind of room behind the type the guest tapped («بدون إطلالة»، «إطلالة مسبح»، «إطلالة بحر»), each at its all-in price: shown as ONE
  /// choice (radio) on the form, so the guest can change their mind without leaving it. Empty for a type that does not differ by room.
  final List<DiscoveredUnit> variants;

  /// The hotel's «سياسة الأطفال»: when given, a stay asks each child's age instead of a count.
  final ChildPolicy? childPolicy;

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
    this.variants = const [],
    this.childPolicy,
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

  /// each child's age, when the hotel has a «سياسة الأطفال»
  final List<int> _childAges = [];

  bool get _asksAges => widget.childPolicy != null && widget.offering.itemType == 'booking_stay';

  /// the children who take a place in the room, by the hotel's own age
  int get _countedChildren => _asksAges ? _childAges.where(widget.childPolicy!.counts).length : 0;
  String? _channel;
  String? _visitPlace;
  int? _unitId;

  /// the kind of room chosen among [BookingScreen.variants] (starts as the card the guest tapped)
  DiscoveredUnit? _unitCard;

  /// «Number of guests»: a stay takes the guests the room's capacity says (one in a single, two in a double) times the rooms booked.
  /// Null when nothing limits the party.
  int? get _guestCap {
    if (widget.offering.itemType != 'booking_stay') return null;
    final unit = _unitCard?.capacity ??
        (widget.offering.units.isNotEmpty ? widget.offering.units : (_form?.units ?? const <BookableUnitOption>[]))
            .where((u) => u.id == _unitId)
            .map((u) => u.capacity)
            .firstOrNull;
    if (unit == null || unit <= 0) return null;
    // children from the hotel's age take places too: the adults may fill only what they leave — and the extra beds the hotel sells
    final beds = widget.childPolicy?.extraBedsAllowed(_quantity) ?? 0;
    return (unit * _quantity + beds - _countedChildren).clamp(1, 1000);
  }

  /// the party as it is sent: never above what the room takes, even if the guest changed room type or the number of rooms after setting it
  int get _partyToSend {
    final cap = _guestCap;
    return cap == null ? _partySize : _partySize.clamp(1, cap);
  }
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

  // «تحت التعامل»: the room is held for this guest while they fill the booking in
  int? _holdId;
  DateTime? _holdUntil;
  Timer? _holdTicker;

  // «طلب تحرير غرفة»: a room promised to a partner of the hotel, asked back
  bool _canAskRelease = false;
  int? _releaseId;
  String? _releaseStatus;
  Timer? _releasePoll;

  /// The guest ticked that they are who a scoped room type is sold to («مصري أو مقيم» / «أجنبي»).
  bool _originConfirmed = false;

  String get _scope => widget.initialUnit?.guestScope ?? 'all';

  /// What the guest declares for this room: `local` for a room sold to Egyptians and residents, `foreign` for one sold to foreigners.
  String? get _origin => _scope == 'locals' ? 'local' : (_scope == 'foreigners' ? 'foreign' : null);

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
    // the guest has already said who they are: the declaration is ticked when it fits this room
    final said = ref.read(guestOriginProvider);
    if (said != null && said == _origin) _originConfirmed = true;
    if (unit != null) {
      _unitId = unit.id;
      _unitCard = unit;
      // a card of a room type that differs by its rooms («إطلالة بحر») is booked with what it was priced with
      _modifierOptionIds.addAll(unit.variantOptionIds);
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
    _holdTicker?.cancel();
    _releasePoll?.cancel();
    // the hold is NOT released here: leaving the screen keeps the room held until its minutes end, and the guest finds it «محجوزة لك»
    // when they come back (or lets go of it with the button on the banner)
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

  /// Holds the chosen room for the dates picked, so nobody else is offered it meanwhile. Refused (the reason is shown where the price
  /// error is) when it is booked, or being booked by someone else.
  Future<void> _holdRoom(int requestId) async {
    final unit = _unitId;
    final from = _startsAt;
    final to = _endsAt;
    if (unit == null || from == null || to == null || _dayUseActive) return;
    // a room sold to one kind of guest is held only once the guest has said they are that kind
    if (_scope != 'all' && !_originConfirmed) return;

    try {
      final hold = await ref.read(bookingApiProvider).placeHold(businessId: widget.businessId, bookableId: unit, startsAt: from, endsAt: to, quantity: _quantity, guestOrigin: _origin);
      if (!mounted || requestId != _previewRequestId) return;
      setState(() {
        _canAskRelease = false;
        _holdId = hold.id;
        _holdUntil = DateTime.now().add(Duration(seconds: hold.secondsLeft));
      });
      _holdTicker ??= Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        final until = _holdUntil;
        if (until != null && !until.isAfter(DateTime.now())) {
          // time is up: try to hold it again; someone else may have taken it meanwhile
          setState(() => _holdUntil = null);
          _schedulePreview();
        } else {
          setState(() {});
        }
      });
    } catch (e) {
      if (!mounted || requestId != _previewRequestId) return;
      setState(() {
        _holdId = null;
        _holdUntil = null;
        // 409: only a partner's promise stands in the way, and the guest may ask for it to be given back
        _canAskRelease = e is ApiException && e.isConflict;
        _previewError = e is ApiException && e.message.isNotEmpty ? e.message : null;
      });
    }
  }

  Future<void> _askRelease() async {
    final unit = _unitId;
    final from = _startsAt;
    final to = _endsAt;
    if (unit == null || from == null || to == null) return;
    final api = ref.read(bookingApiProvider);

    try {
      final id = await api.requestRelease(bookableId: unit, startsAt: from, endsAt: to, quantity: _quantity);
      if (!mounted) return;
      setState(() {
        _releaseId = id;
        _releaseStatus = 'pending';
      });
      _releasePoll?.cancel();
      _releasePoll = Timer.periodic(const Duration(seconds: 6), (t) async {
        try {
          final status = await api.releaseStatus(id);
          if (!mounted) return t.cancel();
          if (status != 'pending') {
            t.cancel();
            setState(() => _releaseStatus = status);
            // approved: the room is held for this guest on the server; take it up again like any other hold
            if (status == 'approved') {
              setState(() {
                _previewError = null;
                _canAskRelease = false;
              });
              _schedulePreview();
            }
          }
        } catch (_) {
          // a missed poll is not an answer: try again in six seconds
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _previewError = e is ApiException && e.message.isNotEmpty ? e.message : null);
    }
  }

  Future<void> _releaseHold() async {
    final id = _holdId;
    if (id == null) return;
    setState(() {
      _holdId = null;
      _holdUntil = null;
    });
    try {
      await ref.read(bookingApiProvider).releaseHold(id);
    } catch (_) {
      // it expires by itself anyway
    }
  }

  String _holdLeft() {
    final left = _holdUntil?.difference(DateTime.now()) ?? Duration.zero;
    final s = left.inSeconds.clamp(0, 99999);

    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
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
        partySize: _partyToSend,
        optionIds: _modifierOptionIds.toList(),
        childrenAges: _asksAges ? List<int>.of(_childAges) : const [],
      );
      // A slower earlier request landing after a newer one must not
      // overwrite it with a stale total.
      if (mounted && requestId == _previewRequestId) {
        setState(() {
          _preview = preview;
          _previewError = null;
          _previewLoading = false;
        });
        await _holdRoom(requestId);
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
          meta['children_count'] = _asksAges ? _childAges.length : _childrenCount;
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
        partySize: fields.any((f) => f.key == 'guest_count' || f.key == 'party_size') ? _partyToSend : null,
        // each child's age, priced and counted by the hotel's «سياسة الأطفال»
        childrenAges: _asksAges ? List<int>.of(_childAges) : const [],
        quantity: fields.any((f) => f.key == 'quantity') ? _quantity : null,
        notes: _notesController.text.trim(),
        meta: _buildMeta(fields),
        optionIds: _modifierOptionIds.toList(),
        courseGroupId: widget.courseGroupId,
        chairId: widget.chair?.id,
        providerId: widget.provider?.id,
        guestOrigin: _scope == 'locals' ? 'local' : (_scope == 'foreigners' ? 'foreign' : null),
      );
      // the hold became the booking on the server
      _holdId = null;
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
                _selectedUnitCard(context, _unitCard ?? widget.initialUnit!),
                // one choice among the kinds of room, each at its all-in night price — no «+150» beside a view
                if (widget.variants.length > 1) _variantChoice(context, l10n),
                // «تحت التعامل»: the room is held for this guest while they fill the booking in
                if (_holdUntil != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(10)),
                      child: Row(children: [
                        Icon(Icons.timer_outlined, size: 18, color: Theme.of(context).colorScheme.onPrimaryContainer),
                        const SizedBox(width: 8),
                        // the banner is drawn on the theme's dark container: its words take the colour made for it
                        Expanded(child: Text(l10n.bookingHoldBanner(_holdLeft()), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer))),
                        TextButton(onPressed: _releaseHold, style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer), child: Text(l10n.bookingHoldRelease)),
                      ]),
                    ),
                  ),
                // the hotel's add-ons (the meal plan) for a room sold through a partner: they come with the room, not with this business's form
                if (widget.initialUnit!.choices.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(l10n.bookingAddOnsTitle, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  // one choice for a group the hotel sells as one («نظام الوجبات»: none, half board, full board) — a radio with «بدون»
                  for (final group in _choiceGroups(widget.initialUnit!.choices)) ...[
                    if (group.first.group != null && group.first.group!.isNotEmpty)
                      Text(group.first.group!, style: Theme.of(context).textTheme.bodyMedium),
                    if (group.first.single)
                      RadioGroup<int>(
                        groupValue: group.map((c) => c.optionId).where(_modifierOptionIds.contains).firstOrNull ?? 0,
                        onChanged: (picked) {
                          setState(() {
                            _modifierOptionIds.removeAll(group.map((c) => c.optionId));
                            if ((picked ?? 0) != 0) _modifierOptionIds.add(picked!);
                          });
                          _schedulePreview();
                        },
                        child: Column(children: [
                          RadioListTile<int>(contentPadding: EdgeInsets.zero, value: 0, title: Text(l10n.bookingNoAddOn)),
                          for (final c in group)
                            RadioListTile<int>(
                              contentPadding: EdgeInsets.zero,
                              value: c.optionId,
                              title: Text(c.name ?? ''),
                              secondary: Text(c.adjustType == 'percent' ? '+${c.adjustValue.toStringAsFixed(0)}%' : '+${c.amount.toStringAsFixed(0)}'),
                            ),
                        ]),
                      )
                    else
                      for (final c in group)
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
                ],
                // «أسعار للمصريين والمقيمين فقط»: the room is sold to one of the two; the guest says which they are, the hotel checks on arrival
                if (_scope != 'all')
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: _originConfirmed,
                    onChanged: (v) {
                      setState(() => _originConfirmed = v ?? false);
                      // the hold waits for this declaration on a room sold to one kind of guest
                      if (_originConfirmed) _schedulePreview();
                    },
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

  /// «الأطفال»: one line per child with its age; beside it what the hotel's policy says it pays (free, or a share of the night).
  Widget _childAgesBlock(BuildContext context, AppLocalizations l10n) {
    final policy = widget.childPolicy!;
    final theme = Theme.of(context);
    final maxAge = (policy.adultFromAge - 1).clamp(0, 17);

    // what the server priced each child at (a room's first child may be free and a second pay half); before it answers, the first-child rate
    final priced = _preview?.children ?? const [];
    String pays(int i) {
      final p = i < priced.length ? priced[i].percent : policy.percentFor(_childAges[i], first: i == 0);
      return p <= 0 ? l10n.childFree : '${p % 1 == 0 ? p.toStringAsFixed(0) : p.toStringAsFixed(2)}%';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text(l10n.bookingChildrenTitle, style: theme.textTheme.bodyMedium)),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: Text(l10n.bookingAddChild),
              onPressed: _childAges.length >= 10
                  ? null
                  : () {
                      setState(() => _childAges.add(maxAge < 5 ? maxAge : 5));
                      _schedulePreview();
                    },
            ),
          ]),
          for (var i = 0; i < _childAges.length; i++)
            Row(children: [
              Text(l10n.bookingChildN(i + 1)),
              const SizedBox(width: 12),
              Text(l10n.bookingChildAge, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
              const SizedBox(width: 6),
              DropdownButton<int>(
                value: _childAges[i].clamp(0, maxAge),
                items: [for (var a = 0; a <= maxAge; a++) DropdownMenuItem(value: a, child: Text('$a'))],
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _childAges[i] = v);
                  _schedulePreview();
                },
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(pays(i), style: theme.textTheme.bodySmall)),
              IconButton(
                tooltip: l10n.commonDelete,
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() => _childAges.removeAt(i));
                  _schedulePreview();
                },
              ),
            ]),
        ],
      ),
    );
  }

  /// The add-ons of a room grouped as the hotel groups them, in the order they came.
  List<List<UnitChoice>> _choiceGroups(List<UnitChoice> choices) {
    final groups = <int, List<UnitChoice>>{};
    var loose = -1;
    for (final c in choices) {
      groups.putIfAbsent(c.groupId ?? loose--, () => []).add(c);
    }
    return groups.values.toList();
  }

  void _pickVariant(DiscoveredUnit next) {
    setState(() {
      if (_unitCard != null) _modifierOptionIds.removeAll(_unitCard!.variantOptionIds);
      _modifierOptionIds.addAll(next.variantOptionIds);
      _unitCard = next;
    });
    _schedulePreview();
  }

  Widget _variantChoice(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final current = (_unitCard ?? widget.initialUnit)!;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.bookingRoomKindTitle, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          RadioGroup<String>(
            groupValue: current.selectionKey,
            onChanged: (key) {
              final next = widget.variants.where((v) => v.selectionKey == key).firstOrNull;
              if (next != null && next.available != false) _pickVariant(next);
            },
            child: Column(
              children: [
                for (final v in widget.variants)
                  RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    value: v.selectionKey,
                    enabled: v.available != false,
                    title: Text(v.displayTitle),
                    subtitle: v.available == false && (v.reason ?? '').isNotEmpty ? Text(v.reason!) : null,
                    secondary: v.price == null ? null : Text('${v.price!.toStringAsFixed(0)} ${widget.offering.currency}', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                  ),
              ],
            ),
          ),
        ],
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

  String _galaDate(BuildContext context, String date) {
    final d = DateTime.tryParse(date);
    return d == null ? date : LocalFormat.date(context).format(d);
  }

  /// The total, with what it is made of: «الغرفة 800 · إطلالة 150 · نصف إقامة 250 = 1200 × 2 ليلة».
  Widget _summaryCard(BuildContext context, AppLocalizations l10n, bool dayUseOn) {
    final theme = Theme.of(context);
    final preview = _preview;
    final currency = widget.offering.currency;
    final lines = preview?.lines ?? const <({String name, double amount})>[];
    final showBreakdown = preview != null && (lines.isNotEmpty || preview.children.isNotEmpty || preview.extraBeds != null || preview.galaDinners.isNotEmpty) && preview.unitPrice != null;
    final nights = preview?.periods ?? 1;

    String money(double v) => '${v.toStringAsFixed(0)} $currency';

    // the view is part of WHAT the room is: «غرفة فردية · إطلالة بحرية 1300», not «غرفة 1000 + إطلالة 300»
    final card = _unitCard;
    final viewNames = (card != null && card.variantOptionIds.isNotEmpty) ? card.features.toSet() : <String>{};
    final viewExtra = lines.where((l) => viewNames.contains(l.name)).fold<double>(0, (sum, l) => sum + l.amount);
    final otherLines = lines.where((l) => !viewNames.contains(l.name)).toList();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showBreakdown) ...[
              _summaryRow(theme, viewNames.isEmpty ? l10n.bookingBasePriceLine : card!.displayTitle, money((preview.baseUnitPrice ?? 0) + viewExtra)),
              for (final line in otherLines) _summaryRow(theme, line.name, '+${line.amount.toStringAsFixed(0)}'),
              if (preview.extraBeds != null && preview.extraBeds!.count > 0)
                _summaryRow(theme, l10n.extraBedLine(preview.extraBeds!.count), '+${preview.extraBeds!.perNight.toStringAsFixed(0)}'),
              for (final c in preview.children.where((c) => c.perNight > 0))
                _summaryRow(
                  theme,
                  c.singleParent
                      ? l10n.bookingChildSingleParentLine(c.age, '${c.percent % 1 == 0 ? c.percent.toStringAsFixed(0) : c.percent.toStringAsFixed(2)}%')
                      : l10n.bookingChildLine(c.age, '${c.percent % 1 == 0 ? c.percent.toStringAsFixed(0) : c.percent.toStringAsFixed(2)}%'),
                  '+${c.perNight.toStringAsFixed(0)}',
                ),
              if (!dayUseOn) ...[
                const Divider(height: 16),
                _summaryRow(theme, l10n.bookingNightPrice, money(preview.unitPrice! + preview.children.fold<double>(0, (s, c) => s + c.perNight) + (preview.extraBeds?.perNight ?? 0)), bold: true),
                if (nights > 1) _summaryRow(theme, l10n.bookingTimesNights(nights), ''),
              ],
              // «العشاء الإلزامي»: once for its night, on top of the nights
              for (final g in preview.galaDinners)
                _summaryRow(theme, l10n.galaLine(g.name, _galaDate(context, g.date)), '+${g.total.toStringAsFixed(0)}'),
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
              if (_canAskRelease && _releaseId == null)
                Padding(padding: const EdgeInsets.only(top: 6), child: OutlinedButton(onPressed: _askRelease, child: Text(l10n.bookingAskRelease))),
            ],
            if (_releaseId != null && _releaseStatus == 'pending')
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(children: [
                  const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(l10n.bookingReleaseWaiting, style: theme.textTheme.bodyMedium)),
                ]),
              ),
            if (_releaseStatus == 'declined' || _releaseStatus == 'expired')
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_releaseStatus == 'declined' ? l10n.bookingReleaseDeclined : l10n.bookingReleaseExpired, style: TextStyle(color: theme.colorScheme.error)),
              ),
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
                        entry.unit.held ? l10n.bookingUnitHeld : l10n.bookingUnitUnavailable,
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
        final cap = _guestCap;
        return _stepperRow(context, cap == null ? labelText : '$labelText · ${l10n.bookingGuestsMax(cap)}', _partyToSend, (v) {
          setState(() => _partySize = v);
          _schedulePreview();
        }, max: cap);
      case 'quantity':
        return _stepperRow(context, labelText, _quantity, (v) {
          setState(() => _quantity = v);
          _schedulePreview();
        });
      case 'children_count':
        if (_asksAges) return _childAgesBlock(context, l10n);
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

  Widget _stepperRow(BuildContext context, String label, int value, ValueChanged<int> onChanged, {int min = 1, int? max}) {
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
            onPressed: (max == null || value < max) ? () => onChanged(value + 1) : null,
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
