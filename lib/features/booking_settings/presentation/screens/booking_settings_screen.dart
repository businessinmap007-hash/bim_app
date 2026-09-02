import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/booking_settings_controller.dart';
import '../../data/models/booking_settings_models.dart';

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
        onPressed: () => _showAddPriceSheet(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.bookingSettingsAddPrice),
      ),
      body: state.prices.isEmpty
          ? Center(child: Text(l10n.bookingSettingsPricesEmpty))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: state.prices.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final row = state.prices[index];
                return Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    title: Text(row.lineOption?.name ?? row.label),
                    subtitle: Text(row.serviceName),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${row.price.toStringAsFixed(0)} ${row.currency}',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            final confirmed = await _confirmDelete(context);
                            if (confirmed) {
                              await ref.read(bookingSettingsControllerProvider.notifier).deletePrice(row.id);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
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

class _UnitsTab extends ConsumerWidget {
  const _UnitsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(bookingSettingsControllerProvider);

    if (state.isLoading) return const Center(child: CircularProgressIndicator());
    if (state.error != null) return Center(child: Text(l10n.commonSomethingWentWrong));

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddUnitSheet(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.bookingSettingsAddUnit),
      ),
      body: state.items.isEmpty
          ? Center(child: Text(l10n.bookingSettingsUnitsEmpty))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: state.items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final row = state.items[index];
                return Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    title: Text(row.label),
                    subtitle: row.capacity != null ? Text('${l10n.bookingSettingsCapacity}: ${row.capacity}') : null,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        final confirmed = await _confirmDelete(context);
                        if (confirmed) {
                          await ref.read(bookingSettingsControllerProvider.notifier).deleteBookableItem(row.id);
                        }
                      },
                    ),
                  ),
                );
              },
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(bookingSettingsControllerProvider);

    if (state.isLoading) return const Center(child: CircularProgressIndicator());
    if (state.hours == null) return Center(child: Text(l10n.commonSomethingWentWrong));

    _days ??= [for (final day in _dayOrder) state.hours!.days.firstWhere((d) => d.day == day, orElse: () => WorkingDay(day: day))];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Icon(Icons.circle, size: 10, color: state.hours!.isOpenNow ? AppColors.success : AppColors.error),
            const SizedBox(width: 8),
            Text(state.hours!.isOpenNow ? l10n.bookingSettingsOpenNow : l10n.bookingSettingsClosedNow),
          ],
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < _days!.length; i++)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  Expanded(child: Text(_dayName(l10n, _days![i].day))),
                  if (_days![i].isClosed == true)
                    Text(l10n.bookingSettingsClosed, style: TextStyle(color: Theme.of(context).hintColor))
                  else ...[
                    TextButton(
                      onPressed: () => _pickTime(i, isOpen: true),
                      child: Text(_days![i].open ?? l10n.bookingSettingsOpenTime),
                    ),
                    Text(' — '),
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
          ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(l10n.bookingSettingsSaveHours),
        ),
      ],
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
