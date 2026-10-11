import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../business_menu/presentation/screens/menu_import_screen.dart';
import 'units_import_screen.dart';
import '../../../patient_records/presentation/screens/patient_files_screen.dart';

/// «استيراد بياناتي» — one door for bringing a business's OLD data in: pick what to bring (the menu or goods, the
/// clinic's patient files), then the file, then link its columns to ours. Each business sees only what it has.
class DataImportHubScreen extends StatelessWidget {
  final bool hasMenu;
  final bool hasClinic;
  final bool hasUnits;

  const DataImportHubScreen({super.key, this.hasMenu = false, this.hasClinic = false, this.hasUnits = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    Widget tile(IconData icon, String title, String sub, Widget screen) => Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(sub),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen)),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.importHubTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.importHubIntro, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 14),
          if (hasMenu) tile(Icons.restaurant_menu_outlined, l10n.importHubMenu, l10n.importHubMenuSub, const MenuImportScreen()),
          if (hasClinic) tile(Icons.folder_shared_outlined, l10n.importHubPatients, l10n.importHubPatientsSub, const PatientFilesScreen()),
          if (hasUnits) tile(Icons.meeting_room_outlined, l10n.importHubUnits, l10n.importHubUnitsSub, const UnitsImportScreen()),
          if (!hasMenu && !hasClinic && !hasUnits) Center(child: Text(l10n.importHubNothing)),
        ],
      ),
    );
  }
}
