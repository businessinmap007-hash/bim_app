import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../business/application/business_page_providers.dart';
import '../../application/layout_style_controller.dart';
import '../../application/locale_controller.dart';
import '../../application/theme_mode_controller.dart';
import '../widgets/settings_widgets.dart';
import 'notification_settings_screen.dart';

/// «اعدادات التطبيق» — المالك، 2026-10-06: everything about how the APP looks and speaks on THIS phone: the language,
/// the theme, the layout of the categories screen, how menus are shown, and the notifications.
class AppSettingsScreen extends ConsumerWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeControllerProvider);
    final themeMode = ref.watch(themeModeControllerProvider);
    final layoutStyle = ref.watch(layoutStyleControllerProvider);
    final menuMode = ref.watch(customerMenuDisplayModeControllerProvider) ?? 'grid';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsAppSettings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsSectionHeader(l10n.settingsLanguage),
          const SizedBox(height: 8),
          SettingsCard(
            children: [
              SettingsOptionRow(
                label: l10n.settingsLanguageArabic,
                selected: locale.languageCode == 'ar',
                onTap: () => ref.read(localeControllerProvider.notifier).setLocale(const Locale('ar')),
              ),
              const Divider(height: 1),
              SettingsOptionRow(
                label: l10n.settingsLanguageEnglish,
                selected: locale.languageCode == 'en',
                onTap: () => ref.read(localeControllerProvider.notifier).setLocale(const Locale('en')),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SettingsSectionHeader(l10n.settingsAppearance),
          const SizedBox(height: 8),
          SettingsCard(
            children: [
              SettingsOptionRow(
                label: l10n.settingsAppearanceLight,
                selected: themeMode == ThemeMode.light,
                onTap: () => ref.read(themeModeControllerProvider.notifier).setThemeMode(ThemeMode.light),
              ),
              const Divider(height: 1),
              SettingsOptionRow(
                label: l10n.settingsAppearanceDark,
                selected: themeMode == ThemeMode.dark,
                onTap: () => ref.read(themeModeControllerProvider.notifier).setThemeMode(ThemeMode.dark),
              ),
              const Divider(height: 1),
              SettingsOptionRow(
                label: l10n.settingsAppearanceSystem,
                selected: themeMode == ThemeMode.system,
                onTap: () => ref.read(themeModeControllerProvider.notifier).setThemeMode(ThemeMode.system),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SettingsSectionHeader(l10n.settingsCategoriesLayoutSection),
          const SizedBox(height: 8),
          SettingsCard(
            children: [
              SettingsOptionRow(
                label: l10n.settingsLayoutIconRow,
                selected: layoutStyle == CategoriesLayoutStyle.iconRow,
                onTap: () => ref.read(layoutStyleControllerProvider.notifier).setStyle(CategoriesLayoutStyle.iconRow),
              ),
              const Divider(height: 1),
              SettingsOptionRow(
                label: l10n.settingsLayoutTabsAndRows,
                selected: layoutStyle == CategoriesLayoutStyle.tabsAndRows,
                onTap: () => ref.read(layoutStyleControllerProvider.notifier).setStyle(CategoriesLayoutStyle.tabsAndRows),
              ),
              const Divider(height: 1),
              SettingsOptionRow(
                label: l10n.settingsLayoutBarAndMenu,
                selected: layoutStyle == CategoriesLayoutStyle.barAndMenu,
                onTap: () => ref.read(layoutStyleControllerProvider.notifier).setStyle(CategoriesLayoutStyle.barAndMenu),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SettingsSectionHeader(l10n.settingsMenuDisplay),
          const SizedBox(height: 8),
          SettingsCard(
            children: [
              SettingsOptionRow(
                label: l10n.menuItemsDisplayModeGrid,
                selected: menuMode != 'list',
                onTap: () => ref.read(customerMenuDisplayModeControllerProvider.notifier).setMode('grid'),
              ),
              const Divider(height: 1),
              SettingsOptionRow(
                label: l10n.menuItemsDisplayModeList,
                selected: menuMode == 'list',
                onTap: () => ref.read(customerMenuDisplayModeControllerProvider.notifier).setMode('list'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SettingsCard(
            children: [
              SettingsNavTile(
                icon: Icons.notifications_outlined,
                title: l10n.notificationSettingsTitle,
                subtitle: l10n.notificationSettingsSubtitle,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationSettingsScreen())),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
