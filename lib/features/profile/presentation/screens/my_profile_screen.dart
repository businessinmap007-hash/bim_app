import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../auth/data/models/auth_user.dart';
import '../../../categories/application/categories_providers.dart';
import '../../../categories/data/models/category_root.dart';
import '../../../categories/data/models/specialty.dart';
import '../../../categories/presentation/widgets/category_picker_field.dart';
import '../../../albums/presentation/screens/albums_screen.dart';
import '../../../location/application/location_providers.dart';
import '../../../location/data/models/location_models.dart';
import '../../../location/presentation/widgets/location_picker_field.dart';
import '../../../settings/presentation/screens/services_settings_screen.dart';
import '../../application/profile_controller.dart';
import '../../application/profile_options_controller.dart';
import '../widgets/profile_avatar_picker.dart';
import '../widgets/profile_cover_picker.dart';

/// The signed-in user's OWN account — private by design. There is no route
/// anywhere in this app (or endpoint on the backend) that opens someone
/// ELSE's profile; a business only ever sees a party's name/phone/location/
/// photo inside a booking or order it is actually fulfilling for them (see
/// Api\V2\BookingController::relations() and OrderController on the
/// backend) — never by browsing an account directly.
///
/// What's editable depends on the account's real type (read from
/// AuthUser.type, never guessed from which login button was tapped to get
/// here): a business gets its English name and about text too, on top of
/// what a customer edits. A customer additionally gets a one-way "convert to
/// business" action — see ProfileController::update on the backend for why
/// that direction only.
class MyProfileScreen extends ConsumerStatefulWidget {
  const MyProfileScreen({super.key});

  @override
  ConsumerState<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends ConsumerState<MyProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _nameEnController;
  late final TextEditingController _phoneController;
  late final TextEditingController _aboutController;
  late final TextEditingController _facebookController;
  late final TextEditingController _instagramController;
  late final TextEditingController _twitterController;
  late final TextEditingController _youtubeController;
  late final TextEditingController _linkedinController;
  double? _latitude;
  double? _longitude;
  LocationSelection? _locationSelection;
  bool _saving = false;
  bool _locating = false;
  String? _error;

  // Only used while converting a client account to business.
  CategorySelection? _newSpecialty;
  bool _showConvertPanel = false;
  bool _converting = false;

  AuthUser? _userAt(AuthState state) => state is AuthSignedIn ? state.user : null;

  @override
  void initState() {
    super.initState();
    final user = _userAt(ref.read(authControllerProvider));
    _nameController = TextEditingController(text: user?.name ?? '');
    _nameEnController = TextEditingController(text: user?.nameEn ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _aboutController = TextEditingController(text: user?.about ?? '');
    _facebookController = TextEditingController(text: user?.social?.facebook ?? '');
    _instagramController = TextEditingController(text: user?.social?.instagram ?? '');
    _twitterController = TextEditingController(text: user?.social?.twitter ?? '');
    _youtubeController = TextEditingController(text: user?.social?.youtube ?? '');
    _linkedinController = TextEditingController(text: user?.social?.linkedin ?? '');
    _latitude = user?.latitude;
    _longitude = user?.longitude;
    _resolveSavedLocation(user);
  }

  /// Only ids are stored (see AuthUser.countryId/governorateId/cityId) —
  /// there's no "one location by id" endpoint, so the saved location's
  /// display label is built the same way _SpecialtyLabel resolves a
  /// specialty: read the already-cached lists and match locally.
  Future<void> _resolveSavedLocation(AuthUser? user) async {
    final countryId = user?.countryId;
    final governorateId = user?.governorateId;
    final cityId = user?.cityId;
    if (countryId == null || governorateId == null || cityId == null) return;

    try {
      final languageCode = Localizations.localeOf(context).languageCode;
      final countries = await ref.read(locationApiProvider).countries();
      final governorates = await ref.read(locationApiProvider).governorates(countryId);
      final cities = await ref.read(locationApiProvider).cities(governorateId);

      LocationCountry? country;
      for (final c in countries) {
        if (c.id == countryId) {
          country = c;
          break;
        }
      }
      LocationGovernorate? governorate;
      for (final g in governorates) {
        if (g.id == governorateId) {
          governorate = g;
          break;
        }
      }
      LocationCity? city;
      for (final c in cities) {
        if (c.id == cityId) {
          city = c;
          break;
        }
      }
      if (country == null || governorate == null || city == null || !mounted) return;
      // Local non-nullable copies: a mutable local's null-check doesn't
      // stay promoted once captured by the setState closure below.
      final resolvedCountry = country;
      final resolvedGovernorate = governorate;
      final resolvedCity = city;

      setState(() {
        _locationSelection = LocationSelection(
          countryId: countryId,
          governorateId: governorateId,
          cityId: cityId,
          label:
              '${resolvedCountry.localizedName(languageCode)} — '
              '${resolvedGovernorate.localizedName(languageCode)} — '
              '${resolvedCity.localizedName(languageCode)}',
        );
      });
    } catch (_) {
      // Best-effort label resolution — the picker still works to set a new
      // value even if the initial one couldn't be resolved (offline, etc.).
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameEnController.dispose();
    _phoneController.dispose();
    _aboutController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    _youtubeController.dispose();
    _linkedinController.dispose();
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

      // Best-effort: also resolve the administrative division from the same
      // GPS point, still overridable via the manual picker below. A miss
      // (no confident match) just leaves the picker as it was.
      final match = await ref.read(locationApiProvider).nearest(latitude: position.latitude, longitude: position.longitude);
      if (match != null && mounted) {
        final languageCode = Localizations.localeOf(context).languageCode;
        setState(() {
          _locationSelection = LocationSelection(
            countryId: match.countryId,
            governorateId: match.governorateId,
            cityId: match.cityId,
            label:
                '${match.governorateNameEn != null && languageCode == 'en' ? match.governorateNameEn! : match.governorateNameAr} — '
                '${match.cityNameEn != null && languageCode == 'en' ? match.cityNameEn! : match.cityNameAr}',
          );
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _save() async {
    final isBusiness = _userAt(ref.read(authControllerProvider))?.isBusiness ?? false;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(profileControllerProvider)
          .update(
            name: _nameController.text.trim(),
            nameEn: isBusiness ? _nameEnController.text.trim() : null,
            phone: _phoneController.text.trim(),
            about: isBusiness ? _aboutController.text.trim() : null,
            latitude: _latitude,
            longitude: _longitude,
            countryId: _locationSelection?.countryId,
            governorateId: _locationSelection?.governorateId,
            cityId: _locationSelection?.cityId,
            facebook: isBusiness ? _facebookController.text.trim() : null,
            instagram: isBusiness ? _instagramController.text.trim() : null,
            twitter: isBusiness ? _twitterController.text.trim() : null,
            youtube: isBusiness ? _youtubeController.text.trim() : null,
            linkedin: isBusiness ? _linkedinController.text.trim() : null,
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

  Future<void> _confirmConvertToBusiness() async {
    final specialty = _newSpecialty;
    if (specialty == null) return;

    setState(() {
      _converting = true;
      _error = null;
    });
    try {
      await ref
          .read(profileControllerProvider)
          .update(type: 'business', categoryChildId: specialty.childId);
      if (!mounted) return;
      setState(() => _showConvertPanel = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.profileConvertSuccess)));
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _converting = false);
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

  Future<void> _pickCover(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    try {
      await ref.read(profileControllerProvider).uploadCover(picked.path);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _removeCover() async {
    try {
      await ref.read(profileControllerProvider).removeCover();
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
    final user = _userAt(authState);
    final isBusiness = user?.isBusiness ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(l10n.profileSave, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ProfileCoverPicker(
            imageUrl: user?.coverUrl,
            onCamera: () => _pickCover(ImageSource.camera),
            onGallery: () => _pickCover(ImageSource.gallery),
            onRemove: user?.coverUrl != null ? _removeCover : null,
          ),
          const SizedBox(height: 16),
          Center(
            child: ProfileAvatarPicker(
              // A business's photo IS its logo (see ProfileController::
              // updateImage on the backend, which writes there for a
              // business) — fall back to it the same way the drawer/home
              // shell already do, so a business with a logo but no separate
              // `image` still sees its real photo here, not a blank picker.
              imageUrl: user?.logoUrl ?? user?.imageUrl,
              onCamera: () => _pickImage(ImageSource.camera),
              onGallery: () => _pickImage(ImageSource.gallery),
              onRemove: (user?.logoUrl ?? user?.imageUrl) != null ? _removeImage : null,
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(l10n.settingsAccountSection),
          const SizedBox(height: 8),
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
          _FieldLabel(l10n.profileAccountType),
          const SizedBox(height: 6),
          _AccountTypeBadge(isBusiness: isBusiness),
          const SizedBox(height: 16),
          _FieldLabel(l10n.profileName),
          const SizedBox(height: 6),
          TextField(controller: _nameController),
          if (isBusiness) ...[
            const SizedBox(height: 16),
            _FieldLabel(l10n.profileNameEnglish),
            const SizedBox(height: 6),
            TextField(controller: _nameEnController),
          ],
          const SizedBox(height: 16),
          _FieldLabel(l10n.profileEmail),
          const SizedBox(height: 6),
          Text(user?.email ?? '', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          _FieldLabel(l10n.profilePhone),
          const SizedBox(height: 6),
          TextField(controller: _phoneController, keyboardType: TextInputType.phone),
          if (isBusiness) ...[
            const SizedBox(height: 16),
            _FieldLabel(l10n.profileAbout),
            const SizedBox(height: 6),
            TextField(controller: _aboutController, maxLines: 3),
          ],
          const SizedBox(height: 16),
          _FieldLabel(l10n.profileLocation),
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
          const SizedBox(height: 16),
          _FieldLabel(l10n.profileAdministrativeLocation),
          const SizedBox(height: 6),
          LocationPickerField(
            value: _locationSelection,
            onChanged: (selection) => setState(() => _locationSelection = selection),
          ),
          if (isBusiness) ...[
            const SizedBox(height: 24),
            _FieldLabel(l10n.profileSocialLinks),
            const SizedBox(height: 6),
            TextField(
              controller: _facebookController,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.facebook), hintText: 'facebook.com/...'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _instagramController,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.camera_alt_outlined), hintText: 'instagram.com/...'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _twitterController,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.alternate_email), hintText: 'x.com/...'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _youtubeController,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.play_circle_outline), hintText: 'youtube.com/...'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _linkedinController,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.business_center_outlined), hintText: 'linkedin.com/...'),
            ),
          ],
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: const Icon(Icons.photo_album_outlined),
              title: Text(l10n.profileAlbumsTitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AlbumsScreen()),
              ),
            ),
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
          if (isBusiness) ...[
            const SizedBox(height: 32),
            _SectionHeader(l10n.profileActivitySettingsSection),
            const SizedBox(height: 8),
            _FieldLabel(l10n.profileCategory),
            const SizedBox(height: 6),
            _RootCategoryLabel(categoryId: user?.categoryId),
            const SizedBox(height: 16),
            _FieldLabel(l10n.profileSpecialty),
            const SizedBox(height: 6),
            _SpecialtyLabel(categoryId: user?.categoryId, categoryChildId: user?.categoryChildId),
            if (user?.categoryChildId != null) ...[
              const SizedBox(height: 16),
              const _OptionsSection(),
            ],
            const SizedBox(height: 32),
            _SectionHeader(l10n.settingsServicesSection),
            const SizedBox(height: 8),
            Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                leading: const Icon(Icons.storefront_outlined),
                title: Text(l10n.settingsServicesSection),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ServicesSettingsScreen()),
                ),
              ),
            ),
          ],
          if (!isBusiness) ...[
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            if (!_showConvertPanel)
              OutlinedButton.icon(
                onPressed: () => setState(() => _showConvertPanel = true),
                icon: const Icon(Icons.storefront_outlined),
                label: Text(l10n.profileConvertToBusiness),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.profileConvertToBusinessHint, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 12),
                  CategoryPickerField(
                    value: _newSpecialty,
                    onChanged: (selection) => setState(() => _newSpecialty = selection),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _converting ? null : () => setState(() => _showConvertPanel = false),
                          child: Text(l10n.commonCancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: (_converting || _newSpecialty == null) ? null : _confirmConvertToBusiness,
                          child: _converting
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Text(l10n.profileConvertConfirm),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }
}

/// Resolves a specialty id to its display name for the profile's read-only
/// summary — there's no "look up one specialty by id" endpoint, so this
/// re-reads the root's already-cached specialty list (the same data the
/// category picker itself uses) and finds the match locally.
class _SpecialtyLabel extends ConsumerWidget {
  final int? categoryId;
  final int? categoryChildId;

  const _SpecialtyLabel({required this.categoryId, required this.categoryChildId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final style = Theme.of(context).textTheme.bodyMedium;

    if (categoryChildId == null) {
      return Text(l10n.profileSpecialtyNotSet, style: style);
    }
    if (categoryId == null) {
      return Text('#$categoryChildId', style: style);
    }

    final specialtiesAsync = ref.watch(specialtiesProvider(categoryId!));
    return specialtiesAsync.when(
      data: (specialties) {
        final languageCode = Localizations.localeOf(context).languageCode;
        Specialty? match;
        for (final specialty in specialties) {
          if (specialty.id == categoryChildId) {
            match = specialty;
            break;
          }
        }
        return Text(match?.localizedName(languageCode) ?? '#$categoryChildId', style: style);
      },
      loading: () => const SizedBox(
        height: 16,
        width: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (error, stack) => Text('#$categoryChildId', style: style),
    );
  }
}

/// The root category name («عقارات و أراضي») above the specialty — there's
/// no "one root by id" endpoint either, so this matches against the same
/// cached root list the home grid and category picker already use.
class _RootCategoryLabel extends ConsumerWidget {
  final int? categoryId;
  const _RootCategoryLabel({required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final style = Theme.of(context).textTheme.bodyMedium;

    if (categoryId == null) {
      return Text(l10n.profileCategoryNotSet, style: style);
    }

    final rootsAsync = ref.watch(categoryRootsProvider);
    return rootsAsync.when(
      data: (roots) {
        final languageCode = Localizations.localeOf(context).languageCode;
        CategoryRoot? match;
        for (final root in roots) {
          if (root.id == categoryId) {
            match = root;
            break;
          }
        }
        return Text(match?.localizedName(languageCode) ?? '#$categoryId', style: style);
      },
      loading: () => const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)),
      error: (error, stack) => Text('#$categoryId', style: style),
    );
  }
}

/// A business's self-service attribute picks — every option for its
/// specialty, grouped, as checkboxes. Saved on its own ("حفظ الخصائص"),
/// separate from the main profile Save, since it's a different backend
/// endpoint (PATCH /profile/options replaces the whole set, not a diff).
class _OptionsSection extends ConsumerWidget {
  const _OptionsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(profileOptionsControllerProvider);
    final notifier = ref.read(profileOptionsControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(l10n.profileOptionsTitle),
        const SizedBox(height: 8),
        if (state.error != null) ...[
          Text(state.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          const SizedBox(height: 8),
        ],
        if (state.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (state.groups.isEmpty)
          Text(
            l10n.profileOptionsEmpty,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
          )
        else ...[
          for (final group in state.groups) ...[
            Text(group.name, style: Theme.of(context).textTheme.titleSmall),
            Wrap(
              spacing: 4,
              children: [
                for (final option in group.options)
                  FilterChip(
                    label: Text(option.name),
                    selected: state.selectedIds.contains(option.id),
                    onSelected: (value) => notifier.toggle(option.id, value),
                    selectedColor: AppColors.accentGold.withValues(alpha: 0.3),
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: ElevatedButton(
              onPressed: state.isSaving ? null : notifier.save,
              child: state.isSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(l10n.profileOptionsSave),
            ),
          ),
        ],
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(label, style: Theme.of(context).textTheme.titleSmall);
  }
}

/// Divides the page into "اعدادات الحساب / اعدادات النشاط / اعدادات
/// الخدمات" — the account's own data, what it does (business only), and
/// where it manages what it offers (business only, a link out rather than
/// embedded — ServicesSettingsScreen is its own large screen).
class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700),
    );
  }
}

class _AccountTypeBadge extends StatelessWidget {
  final bool isBusiness;
  const _AccountTypeBadge({required this.isBusiness});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = isBusiness ? AppColors.primaryNavy : AppColors.accentGold;

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
        child: Text(
          isBusiness ? l10n.profileAccountTypeBusiness : l10n.profileAccountTypeClient,
          style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
        ),
      ),
    );
  }
}
