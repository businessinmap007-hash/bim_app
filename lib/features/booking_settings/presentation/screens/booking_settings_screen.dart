import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/booking_settings_controller.dart';
import '../../data/models/booking_settings_models.dart';
import 'bookable_item_edit_screen.dart';

/// A business's self-service booking configuration — prices (what a room
/// type costs), bookable units (which specific rooms exist) and weekly
/// hours. All three sit behind the same GET /business/{prices,
/// bookable-items,working-hours} endpoints a business already had on the
/// backend with no app screen to reach them from.
class BookingSettingsScreen extends StatelessWidget {
  const BookingSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.bookingSettingsTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.bookingSettingsPricesTab),
              Tab(text: l10n.bookingSettingsUnitsTab),
              Tab(text: l10n.bookingSettingsHoursTab),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_PricesTab(), _UnitsTab(), _HoursTab()],
        ),
      ),
    );
  }
}

class _PricesTab extends ConsumerWidget {
  const _PricesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(bookingSettingsControllerProvider);

    if (state.isLoading) return const Center(child: CircularProgressIndicator());
    if (state.error != null) return Center(child: Text(l10n.commonSomethingWentWrong));

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
        onPressed: () => _showAddPriceSheet(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.bookingSettingsAddPrice),
      ),
      body: state.prices.isEmpty
          ? _EmptyState(icon: Icons.sell_outlined, label: l10n.bookingSettingsPricesEmpty)
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: state.prices.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final row = state.prices[index];
                return _SettingsRowCard(
                  icon: Icons.sell_outlined,
                  title: row.lineOption?.name ?? row.label,
                  subtitle: row.serviceName,
                  trailing: '${row.price.toStringAsFixed(0)} ${row.currency}',
                  onDelete: () async {
                    final confirmed = await _confirmDelete(context);
                    if (confirmed) {
                      await ref.read(bookingSettingsControllerProvider.notifier).deletePrice(row.id);
                    }
                  },
                );
              },
            ),
    );
  }

  Future<void> _showAddPriceSheet(BuildContext context, WidgetRef ref) async {
    final options = ref.read(bookingSettingsControllerProvider).pricesOptions;
    if (options == null || options.services.isEmpty) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: _AddPriceForm(options: options),
      ),
    );
  }
}

class _AddPriceForm extends ConsumerStatefulWidget {
  final PricesOptionsPayload options;
  const _AddPriceForm({required this.options});

  @override
  ConsumerState<_AddPriceForm> createState() => _AddPriceFormState();
}

class _AddPriceFormState extends ConsumerState<_AddPriceForm> {
  BusinessServiceOption? _service;
  ServiceItemType? _itemType;
  NamedOption? _lineOption;
  final _priceController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.options.services.isNotEmpty) {
      _service = widget.options.services.first;
      if (_service!.itemTypes.isNotEmpty) _itemType = _service!.itemTypes.first;
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final service = _service;
    final itemType = _itemType;
    final price = double.tryParse(_priceController.text.trim());
    if (service == null || itemType == null || price == null) return;

    setState(() => _saving = true);
    try {
      await ref
          .read(bookingSettingsControllerProvider.notifier)
          .createPrice(
            serviceId: service.id,
            bookableItemType: itemType.key,
            price: price,
            lineOptionId: _lineOption?.id,
          );
      if (mounted) Navigator.of(context).pop();
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
    final allLineOptions = widget.options.lines.expand((g) => g.options).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.bookingSettingsAddPrice, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          DropdownButtonFormField<BusinessServiceOption>(
            initialValue: _service,
            decoration: InputDecoration(labelText: l10n.bookingSettingsService),
            items: widget.options.services
                .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                .toList(),
            onChanged: (value) => setState(() {
              _service = value;
              _itemType = value?.itemTypes.isNotEmpty == true ? value!.itemTypes.first : null;
            }),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<ServiceItemType>(
            initialValue: _itemType,
            decoration: InputDecoration(labelText: l10n.bookingSettingsItemType),
            items: (_service?.itemTypes ?? [])
                .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                .toList(),
            onChanged: (value) => setState(() => _itemType = value),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<NamedOption>(
            initialValue: _lineOption,
            decoration: InputDecoration(labelText: l10n.bookingSettingsLineOption, hintText: l10n.bookingSettingsLineOptionHint),
            items: allLineOptions.map((o) => DropdownMenuItem(value: o, child: Text(o.name))).toList(),
            onChanged: (value) => setState(() => _lineOption = value),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l10n.bookingSettingsPrice),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(l10n.commonSave),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Rooms grouped by their item type ("section", the same shape a menu groups
/// items under a section) with a grid/list toggle — the merchant's own
/// vocabulary for the type (from itemsOptions) names each section.
class _UnitsTab extends ConsumerStatefulWidget {
  const _UnitsTab();

  @override
  ConsumerState<_UnitsTab> createState() => _UnitsTabState();
}

class _UnitsTabState extends ConsumerState<_UnitsTab> {
  bool _gridView = false;

  String _sectionLabel(BookableItemsOptionsPayload? options, String itemType) {
    for (final service in options?.services ?? const <BusinessServiceOption>[]) {
      for (final type in service.itemTypes) {
        if (type.key == itemType) return type.label;
      }
    }
    return itemType;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(bookingSettingsControllerProvider);

    if (state.isLoading) return const Center(child: CircularProgressIndicator());
    if (state.error != null) return Center(child: Text(l10n.commonSomethingWentWrong));

    final sections = <String, List<BookableItemRow>>{};
    for (final row in state.items) {
      sections.putIfAbsent(row.itemType, () => []).add(row);
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
        onPressed: () => _showAddUnitSheet(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.bookingSettingsAddUnit),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: l10n.bookingSettingsListView,
                  icon: Icon(Icons.view_list_outlined, color: _gridView ? Theme.of(context).hintColor : AppColors.primaryNavy),
                  onPressed: () => setState(() => _gridView = false),
                ),
                IconButton(
                  tooltip: l10n.bookingSettingsGridView,
                  icon: Icon(Icons.grid_view_outlined, color: _gridView ? AppColors.primaryNavy : Theme.of(context).hintColor),
                  onPressed: () => setState(() => _gridView = true),
                ),
              ],
            ),
          ),
          Expanded(
            child: state.items.isEmpty
                ? _EmptyState(icon: Icons.meeting_room_outlined, label: l10n.bookingSettingsUnitsEmpty)
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                    children: [
                      for (final entry in sections.entries) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            _sectionLabel(state.itemsOptions, entry.key),
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (_gridView)
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 0.82,
                            ),
                            itemCount: entry.value.length,
                            itemBuilder: (context, index) => _UnitCard(row: entry.value[index], grid: true),
                          )
                        else
                          for (final row in entry.value) ...[
                            _UnitCard(row: row, grid: false),
                            const SizedBox(height: 10),
                          ],
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddUnitSheet(BuildContext context, WidgetRef ref) async {
    final options = ref.read(bookingSettingsControllerProvider).itemsOptions;
    if (options == null || options.services.isEmpty) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: _AddUnitForm(options: options),
      ),
    );
  }
}

/// One room's card — a thumbnail, its label, and a status chip. Tapping opens
/// the full edit screen (description, photos, status); the leading delete
/// affordance stays here since it needs no form of its own.
class _UnitCard extends ConsumerWidget {
  final BookableItemRow row;
  final bool grid;
  const _UnitCard({required this.row, required this.grid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final (statusLabel, statusColor) = switch (row) {
      _ when row.isUnderMaintenance => (l10n.bookingSettingsStatusMaintenance, AppColors.error),
      _ when row.isCurrentlyBooked => (l10n.bookingSettingsStatusBooked, AppColors.accentGold),
      _ => (l10n.bookingSettingsStatusAvailable, AppColors.success),
    };

    void openEdit() {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => BookableItemEditScreen(itemId: row.id)));
    }

    final thumbnail = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: row.images.isNotEmpty
          ? Image.network(row.images.first.url, fit: BoxFit.cover)
          : Container(
              color: AppColors.accentGold.withValues(alpha: 0.14),
              child: const Icon(Icons.meeting_room_outlined, color: AppColors.accentGold),
            ),
    );

    final statusChip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(999)),
      child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
    );

    if (grid) {
      return InkWell(
        onTap: openEdit,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.softShadow(),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Padding(padding: const EdgeInsets.all(8), child: thumbnail)),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(row.label, style: Theme.of(context).textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    statusChip,
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: openEdit,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.softShadow(),
        ),
        child: Row(
          children: [
            SizedBox(width: 56, height: 56, child: thumbnail),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(row.label, style: Theme.of(context).textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (row.capacity != null)
                    Text(
                      '${l10n.bookingSettingsCapacity}: ${row.capacity}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
                    ),
                  const SizedBox(height: 4),
                  statusChip,
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error, size: 20),
              onPressed: () async {
                final confirmed = await _confirmDelete(context);
                if (confirmed) {
                  await ref.read(bookingSettingsControllerProvider.notifier).deleteBookableItem(row.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AddUnitForm extends ConsumerStatefulWidget {
  final BookableItemsOptionsPayload options;
  const _AddUnitForm({required this.options});

  @override
  ConsumerState<_AddUnitForm> createState() => _AddUnitFormState();
}

class _AddUnitFormState extends ConsumerState<_AddUnitForm> {
  BusinessServiceOption? _service;
  ServiceItemType? _itemType;
  NamedOption? _lineOption;
  final _codeController = TextEditingController();
  final _capacityController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.options.services.isNotEmpty) {
      _service = widget.options.services.first;
      if (_service!.itemTypes.isNotEmpty) _itemType = _service!.itemTypes.first;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final service = _service;
    final itemType = _itemType;
    final code = _codeController.text.trim();
    if (service == null || itemType == null || code.isEmpty) return;

    setState(() => _saving = true);
    try {
      await ref
          .read(bookingSettingsControllerProvider.notifier)
          .createBookableItem(
            serviceId: service.id,
            itemType: itemType.key,
            code: code,
            lineOptionId: _lineOption?.id,
            capacity: int.tryParse(_capacityController.text.trim()),
          );
      if (mounted) Navigator.of(context).pop();
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
    final allLineOptions = widget.options.lineOptions.expand((g) => g.options).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.bookingSettingsAddUnit, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          DropdownButtonFormField<BusinessServiceOption>(
            initialValue: _service,
            decoration: InputDecoration(labelText: l10n.bookingSettingsService),
            items: widget.options.services
                .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                .toList(),
            onChanged: (value) => setState(() {
              _service = value;
              _itemType = value?.itemTypes.isNotEmpty == true ? value!.itemTypes.first : null;
            }),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<ServiceItemType>(
            initialValue: _itemType,
            decoration: InputDecoration(labelText: l10n.bookingSettingsItemType),
            items: (_service?.itemTypes ?? [])
                .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                .toList(),
            onChanged: (value) => setState(() => _itemType = value),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<NamedOption>(
            initialValue: _lineOption,
            decoration: InputDecoration(labelText: l10n.bookingSettingsLineOption, hintText: l10n.bookingSettingsLineOptionHint),
            items: allLineOptions.map((o) => DropdownMenuItem(value: o, child: Text(o.name))).toList(),
            onChanged: (value) => setState(() => _lineOption = value),
          ),
          const SizedBox(height: 12),
          TextField(controller: _codeController, decoration: InputDecoration(labelText: l10n.bookingSettingsCode)),
          const SizedBox(height: 12),
          TextField(
            controller: _capacityController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.bookingSettingsCapacity),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(l10n.commonSave),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _HoursTab extends ConsumerStatefulWidget {
  const _HoursTab();

  @override
  ConsumerState<_HoursTab> createState() => _HoursTabState();
}

class _HoursTabState extends ConsumerState<_HoursTab> {
  List<WorkingDay>? _days;
  bool _saving = false;

  String? _checkIn;
  String? _checkOut;
  bool _checkTimesSaving = false;

  static const _dayOrder = [0, 1, 2, 3, 4, 5, 6];

  String _dayName(AppLocalizations l10n, int day) {
    switch (day) {
      case 0:
        return l10n.weekdaySunday;
      case 1:
        return l10n.weekdayMonday;
      case 2:
        return l10n.weekdayTuesday;
      case 3:
        return l10n.weekdayWednesday;
      case 4:
        return l10n.weekdayThursday;
      case 5:
        return l10n.weekdayFriday;
      default:
        return l10n.weekdaySaturday;
    }
  }

  Future<void> _pickTime(int index, {required bool isOpen}) async {
    final current = _days![index];
    final initial = TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    setState(() {
      _days![index] = isOpen ? current.copyWith(open: formatted) : current.copyWith(close: formatted);
    });
  }

  Future<void> _save() async {
    final days = _days;
    if (days == null) return;
    setState(() => _saving = true);
    try {
      await ref.read(bookingSettingsControllerProvider.notifier).saveHours(days);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.bookingSettingsHoursSaved)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickCheckTime({required bool isCheckIn}) async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked == null) return;
    final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    setState(() {
      if (isCheckIn) {
        _checkIn = formatted;
      } else {
        _checkOut = formatted;
      }
    });
  }

  Future<void> _saveCheckTimes() async {
    setState(() => _checkTimesSaving = true);
    try {
      await ref
          .read(bookingSettingsControllerProvider.notifier)
          .saveCheckTimes(checkInTime: _checkIn, checkOutTime: _checkOut);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.bookingSettingsCheckTimesSaved)));
      }
    } finally {
      if (mounted) setState(() => _checkTimesSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(bookingSettingsControllerProvider);

    if (state.isLoading) return const Center(child: CircularProgressIndicator());
    if (state.hours == null) return Center(child: Text(l10n.commonSomethingWentWrong));

    _days ??= [for (final day in _dayOrder) state.hours!.days.firstWhere((d) => d.day == day, orElse: () => WorkingDay(day: day))];
    if (state.checkTimes != null) {
      _checkIn ??= state.checkTimes!.checkInTime;
      _checkOut ??= state.checkTimes!.checkOutTime;
    }

    final openNow = state.hours!.isOpenNow;
    final statusColor = openNow ? AppColors.success : AppColors.error;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: 8, color: statusColor),
              const SizedBox(width: 8),
              Text(
                openNow ? l10n.bookingSettingsOpenNow : l10n.bookingSettingsClosedNow,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: statusColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.softShadow(),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < _days!.length; i++) ...[
                if (i > 0) Divider(height: 1, color: Theme.of(context).dividerColor.withValues(alpha: 0.4)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(_dayName(l10n, _days![i].day), style: Theme.of(context).textTheme.titleSmall),
                      ),
                      if (_days![i].isClosed == true)
                        Text(l10n.bookingSettingsClosed, style: TextStyle(color: Theme.of(context).hintColor))
                      else ...[
                        TextButton(
                          onPressed: () => _pickTime(i, isOpen: true),
                          child: Text(_days![i].open ?? l10n.bookingSettingsOpenTime),
                        ),
                        Text(' — ', style: TextStyle(color: Theme.of(context).hintColor)),
                        TextButton(
                          onPressed: () => _pickTime(i, isOpen: false),
                          child: Text(_days![i].close ?? l10n.bookingSettingsCloseTime),
                        ),
                      ],
                      Switch(
                        value: _days![i].isClosed != true,
                        onChanged: (value) => setState(() {
                          _days![i] = value ? _days![i].copyWith(isClosed: false) : _days![i].copyWith(isClosed: true, clearTimes: true);
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(l10n.bookingSettingsSaveHours),
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.softShadow(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.bookingSettingsCheckInTime, style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 4),
                        TextButton(
                          onPressed: () => _pickCheckTime(isCheckIn: true),
                          child: Text(_checkIn ?? l10n.bookingSettingsOpenTime),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.bookingSettingsCheckOutTime, style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 4),
                        TextButton(
                          onPressed: () => _pickCheckTime(isCheckIn: false),
                          child: Text(_checkOut ?? l10n.bookingSettingsCloseTime),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _checkTimesSaving ? null : _saveCheckTimes,
                child: _checkTimesSaving
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.bookingSettingsSaveCheckTimes),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Icon-avatar row card — the shared visual shape behind every settings
/// list in this screen (prices, units), matching the Booking flow's own
/// card language (soft navy shadow, 16px radius, gold-tinted icon chip)
/// instead of a bare `Card(ListTile(...))`.
class _SettingsRowCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailing;
  final VoidCallback onDelete;

  const _SettingsRowCard({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.softShadow(),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accentGold.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.accentGold, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                if (subtitle != null)
                  Text(subtitle!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor)),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            Text(trailing!, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          ],
          IconButton(
            icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error, size: 20),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String label;
  const _EmptyState({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).hintColor),
            const SizedBox(height: 12),
            Text(label, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).hintColor)),
          ],
        ),
      ),
    );
  }
}

Future<bool> _confirmDelete(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      content: Text(l10n.bookingSettingsDeleteConfirm),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.bookingSettingsDelete, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
