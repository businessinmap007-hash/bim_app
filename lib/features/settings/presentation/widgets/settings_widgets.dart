import 'package:flutter/material.dart';

/// The small building blocks every settings screen shares (they used to be private to one screen).
class SettingsSectionHeader extends StatelessWidget {
  final String label;
  const SettingsSectionHeader(this.label, {super.key});

  @override
  Widget build(BuildContext context) => Text(label, style: Theme.of(context).textTheme.titleSmall);
}

class SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const SettingsCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) => Card(margin: EdgeInsets.zero, clipBehavior: Clip.antiAlias, child: Column(children: children));
}

/// A plain tappable row with a radio mark (a Radio widget was avoided on purpose — see the old settings screen's note).
class SettingsOptionRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const SettingsOptionRow({super.key, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge)),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
            ),
          ],
        ),
      ),
    );
  }
}

/// A navigation row of a settings hub: icon, title, an optional «required» chip, and the chevron.
class SettingsNavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? badge;
  final VoidCallback onTap;
  final Color? color;

  const SettingsNavTile({super.key, required this.icon, required this.title, this.subtitle, this.badge, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: color == null ? null : TextStyle(color: color)),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: theme.colorScheme.error, borderRadius: BorderRadius.circular(10)),
              child: Text(badge!, style: TextStyle(color: theme.colorScheme.onError, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onTap,
    );
  }
}
