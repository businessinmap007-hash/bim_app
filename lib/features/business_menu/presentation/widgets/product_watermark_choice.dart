import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../settings/application/watermark_settings_controller.dart';
import '../../../settings/presentation/screens/watermark_settings_screen.dart';

/// «إمكانية إضافة العلامة المائية كاختيار عند رفع صور المنتجات لحمايتها من السرقة» — المالك، 2026-10-06.
/// A switch beside the product photos: stamp this account's watermark (its mobile / business name, as set in
/// Settings → العلامة المائية) on the photos being added. The choice is remembered on the device. When no watermark
/// text is set up yet, it says so and opens the settings instead of pretending.
class ProductWatermarkChoice extends ConsumerWidget {
  /// Called after the switch changes, so the screen can re-stamp the photos it already holds.
  final VoidCallback? onChanged;
  const ProductWatermarkChoice({super.key, this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final text = ref.watch(watermarkTextProvider);
    final on = ref.watch(watermarkSettingsControllerProvider.select((s) => s.onProducts));

    if (text == null) {
      // nothing to stamp yet — the way to set it up is one tap away
      return ListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        leading: const Icon(Icons.shield_outlined),
        title: Text(l10n.productWatermarkTitle),
        subtitle: Text(l10n.mediaWatermarkDisabledHint),
        trailing: TextButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const WatermarkSettingsScreen())),
          child: Text(l10n.mediaWatermarkOpenSettings),
        ),
      );
    }

    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      secondary: const Icon(Icons.shield_outlined),
      activeThumbColor: AppColors.accentGold,
      value: on,
      title: Text(l10n.productWatermarkTitle),
      subtitle: Text(on ? l10n.productWatermarkOn(text) : l10n.productWatermarkOff),
      onChanged: (value) {
        ref.read(watermarkSettingsControllerProvider.notifier).setOnProducts(value);
        onChanged?.call();
      },
    );
  }
}
