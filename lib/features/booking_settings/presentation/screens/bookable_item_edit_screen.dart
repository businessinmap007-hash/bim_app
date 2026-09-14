import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/horizontal_mouse_wheel_scroll.dart';
import '../../../media/application/media_picker_service.dart';
import '../../application/booking_settings_controller.dart';
import '../../data/models/booking_settings_models.dart';

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

    return Scaffold(
      appBar: AppBar(title: Text(row.label)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ImagesSection(row: row),
          const SizedBox(height: 20),
          _DetailsForm(row: row),
        ],
      ),
    );
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

class _DetailsForm extends ConsumerStatefulWidget {
  final BookableItemRow row;
  const _DetailsForm({required this.row});

  @override
  ConsumerState<_DetailsForm> createState() => _DetailsFormState();
}

class _DetailsFormState extends ConsumerState<_DetailsForm> {
  late final TextEditingController _description;
  late final TextEditingController _capacity;
  late final TextEditingController _quantity;
  late String _status;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _description = TextEditingController(text: widget.row.description ?? '');
    _capacity = TextEditingController(text: widget.row.capacity?.toString() ?? '');
    _quantity = TextEditingController(text: widget.row.quantity.toString());
    _status = widget.row.status;
  }

  @override
  void dispose() {
    _description.dispose();
    _capacity.dispose();
    _quantity.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.commonSave)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(l10n.commonSave),
        ),
      ],
    );
  }
}
