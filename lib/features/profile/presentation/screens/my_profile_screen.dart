import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/application/auth_controller.dart';
import '../../application/profile_controller.dart';
import '../widgets/profile_avatar_picker.dart';

/// The customer's OWN profile — private by design. There is no route
/// anywhere in this app (or endpoint on the backend) that opens someone
/// ELSE's profile; a business only ever sees a party's name/phone/location/
/// photo inside a booking or order it is actually fulfilling for them (see
/// Api\V2\BookingController::relations() and OrderController on the
/// backend) — never by browsing an account directly.
class MyProfileScreen extends ConsumerStatefulWidget {
  const MyProfileScreen({super.key});

  @override
  ConsumerState<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends ConsumerState<MyProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  double? _latitude;
  double? _longitude;
  bool _saving = false;
  bool _locating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final state = ref.read(authControllerProvider);
    final user = state is AuthSignedIn ? state.user : null;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _latitude = user?.latitude;
    _longitude = user?.longitude;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _locating = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.profileLocationPermissionDenied)));
        }
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(profileControllerProvider)
          .update(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            latitude: _latitude,
            longitude: _longitude,
          );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.profileSaved)));
      }
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    try {
      await ref.read(profileControllerProvider).uploadImage(picked.path);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _removeImage() async {
    try {
      await ref.read(profileControllerProvider).removeImage();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authControllerProvider);
    final user = authState is AuthSignedIn ? authState.user : null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: ProfileAvatarPicker(
              imageUrl: user?.imageUrl,
              onCamera: () => _pickImage(ImageSource.camera),
              onGallery: () => _pickImage(ImageSource.gallery),
              onRemove: user?.imageUrl != null ? _removeImage : null,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accentGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.shield_outlined, color: AppColors.accentGold, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l10n.profilePrivacyNote, style: Theme.of(context).textTheme.bodySmall),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (_error != null) ...[
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 12),
          ],
          Text(l10n.profileName, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          TextField(controller: _nameController),
          const SizedBox(height: 16),
          Text(l10n.profilePhone, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          TextField(controller: _phoneController, keyboardType: TextInputType.phone),
          const SizedBox(height: 16),
          Text(l10n.profileLocation, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  _latitude != null && _longitude != null
                      ? l10n.profileLocationSet
                      : l10n.profileLocationNotSet,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              OutlinedButton.icon(
                onPressed: _locating ? null : _useCurrentLocation,
                icon: _locating
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.my_location, size: 18),
                label: Text(l10n.profileUseCurrentLocation),
              ),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(l10n.profileSave),
          ),
        ],
      ),
    );
  }
}
