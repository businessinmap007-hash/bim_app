import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/form_save_button.dart';
import '../../../../shared/widgets/horizontal_mouse_wheel_scroll.dart';
import '../../../media/application/media_picker_service.dart';
import '../../application/booking_settings_controller.dart';
import '../../data/models/booking_settings_models.dart';
import '../../data/models/room_models.dart';
import '../widgets/bookable_rooms_section.dart';
import '../widgets/day_use_section.dart';

/// A single room's own screen — description, photo gallery, capacity and its
/// manual available/maintenance status. Mirrors the menu item edit screen's
/// shape (a plain create sheet, then this screen for everything else),
/// since photo upload needs the unit to already exist.
class BookableItemEditScreen extends ConsumerWidget {
  final int itemId;
  const BookableItemEditScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(bookingSettingsControllerProvider);
    final matches = state.items.where((i) => i.id == itemId);
    final row = matches.isEmpty ? null : matches.first;

    if (row == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.bookingSettingsEditUnit)),
        body: Center(child: Text(l10n.commonSomethingWentWrong)),
      );
    }

    return _Editor(row: row);
  }
}

class _ImagesSection extends ConsumerStatefulWidget {
  final BookableItemRow row;
  const _ImagesSection({required this.row});

  @override
  ConsumerState<_ImagesSection> createState() => _ImagesSectionState();
}

class _ImagesSectionState extends ConsumerState<_ImagesSection> {
  final _picker = MediaPickerService();
  bool _uploading = false;

  Future<void> _addImage() async {
    final picked = await _picker.pickFromGallery(allowMultiple: false);
    if (picked.isEmpty) return;
    setState(() => _uploading = true);
    try {
      await ref
          .read(bookingSettingsControllerProvider.notifier)
          .addBookableItemImage(widget.row.id, picked.first.file.path);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _deleteImage(int imageId) async {
    await ref.read(bookingSettingsControllerProvider.notifier).deleteBookableItemImage(widget.row.id, imageId);
  }

  static const _tileSize = 92.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final images = widget.row.images;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.menuItemImagesSection, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 10),
        SizedBox(
          height: _tileSize,
          child: MouseWheelHorizontalScroll(
            builder: (context, controller) => ListView.separated(
              controller: controller,
              scrollDirection: Axis.horizontal,
              itemCount: images.length + 1,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                if (index == images.length) {
                  return _AddImageTile(uploading: _uploading, onTap: _uploading ? null : _addImage);
                }
                final image = images[index];
                return SizedBox(
                  width: _tileSize,
                  height: _tileSize,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(image.url, width: _tileSize, height: _tileSize, fit: BoxFit.cover),
                      ),
                      PositionedDirectional(
                        top: 6,
                        start: 6,
                        child: InkWell(
                          onTap: () => _deleteImage(image.id),
                          borderRadius: BorderRadius.circular(11),
                          child: const CircleAvatar(
                            radius: 11,
                            backgroundColor: Colors.black54,
                            child: Icon(Icons.close, size: 13, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _AddImageTile extends StatelessWidget {
  final bool uploading;
  final VoidCallback? onTap;
  const _AddImageTile({required this.uploading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: _ImagesSectionState._tileSize,
        height: _ImagesSectionState._tileSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.55), width: 1.5),
        ),
        child: uploading
            ? const Center(child: SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)))
            : const Icon(Icons.add_a_photo_outlined, color: AppColors.accentGold),
      ),
    );
  }
}

/// The whole room type in one form with one save bar — details, and for a hotel its Day use — like every other edit
/// screen in the app: the bar turns to «تم الحفظ» once nothing is left unsaved.
class _Editor extends ConsumerStatefulWidget {
  final BookableItemRow row;
  const _Editor({required this.row});

  @override
  ConsumerState<_Editor> createState() => _EditorState();
}

class _EditorState extends ConsumerState<_Editor> {
  late final TextEditingController _description;
  late final TextEditingController _capacity;
  late final TextEditingController _quantity;
  final _dayUsePrice = TextEditingController();
  late String _status;
  DayUseSettings _dayUse = const DayUseSettings();
  bool _dayUseLoaded = false;
  bool _saving = false;
  String? _error;
  String? _savedSignature;

  bool get _isStay => widget.row.itemType == 'booking_stay';

  /// Everything the form can change — the bar is «saved» exactly while this equals what was last saved.
  String get _signature => [
    _description.text.trim(),
    _capacity.text.trim(),
    _quantity.text.trim(),
    _status,
    _dayUse.enabled,
    _dayUse.from,
    _dayUse.to,
    _dayUsePrice.text.trim(),
  ].join('|');

  bool get _isSaved => (!_isStay || _dayUseLoaded) && _savedSignature == _signature;

  @override
  void initState() {
    super.initState();
    _description = TextEditingController(text: widget.row.description ?? '');
    _capacity = TextEditingController(text: widget.row.capacity?.toString() ?? '');
    _quantity = TextEditingController(text: widget.row.quantity.toString());
    _status = widget.row.status;
    for (final c in [_description, _capacity, _quantity, _dayUsePrice]) {
      c.addListener(_refresh);
    }
    if (_isStay) {
      _loadDayUse();
    } else {
      _savedSignature = _signature;
    }
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _description.dispose();
    _capacity.dispose();
    _quantity.dispose();
    _dayUsePrice.dispose();
    super.dispose();
  }

  Future<void> _loadDayUse() async {
    try {
      final settings = await ref.read(bookingSettingsApiProvider).dayUse(widget.row.id);
      if (!mounted) return;
      setState(() {
        _dayUse = settings;
        _dayUsePrice.text = settings.price == null ? '' : settings.price!.toStringAsFixed(settings.price! % 1 == 0 ? 0 : 2);
        _dayUseLoaded = true;
        _savedSignature = _signature;
      });
    } catch (_) {
      // the rest of the form still works without it
      if (mounted) setState(() => _savedSignature = _signature);
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(bookingSettingsControllerProvider.notifier)
          .updateBookableItem(
            widget.row.id,
            serviceId: widget.row.serviceId,
            itemType: widget.row.itemType,
            code: widget.row.code,
            lineOptionId: widget.row.lineOption?.id,
            description: _description.text.trim(),
            capacity: int.tryParse(_capacity.text.trim()),
            quantity: int.tryParse(_quantity.text.trim()),
            status: _status,
          );
      if (_isStay && _dayUseLoaded) {
        final saved = await ref.read(bookingSettingsApiProvider).saveDayUse(
          widget.row.id,
          DayUseSettings(
            enabled: _dayUse.enabled,
            from: _dayUse.from,
            to: _dayUse.to,
            price: double.tryParse(_dayUsePrice.text.trim().replaceAll(',', '.')),
          ),
        );
        _dayUse = saved;
      }
      if (mounted) setState(() => _savedSignature = _signature);
    } catch (e) {
      if (mounted) setState(() => _error = e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final row = widget.row;

    return Scaffold(
      appBar: AppBar(title: Text(row.label)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ImagesSection(row: row),
          if (_isStay) ...[
            const SizedBox(height: 20),
            BookableRoomsSection(itemId: row.id),
            if (_dayUseLoaded) ...[
              const SizedBox(height: 20),
              DayUseFields(value: _dayUse, price: _dayUsePrice, onChanged: (v) => setState(() => _dayUse = v)),
            ],
          ],
          const SizedBox(height: 20),
          TextField(
            controller: _description,
            maxLines: 3,
            decoration: InputDecoration(labelText: l10n.bookingSettingsDescription),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _capacity,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.bookingSettingsCapacity),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _quantity,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.cartQty),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _status,
            decoration: InputDecoration(labelText: l10n.bookingSettingsStatus),
            items: [
              DropdownMenuItem(value: 'available', child: Text(l10n.bookingSettingsStatusAvailable)),
              DropdownMenuItem(value: 'maintenance', child: Text(l10n.bookingSettingsStatusMaintenance)),
            ],
            onChanged: (value) => setState(() => _status = value ?? _status),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 20),
          FormSaveButton(saving: _saving, saved: _isSaved, onPressed: _save),
        ],
      ),
    );
  }
}
