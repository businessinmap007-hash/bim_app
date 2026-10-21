import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/trip_programs_providers.dart';
import 'trip_program_editor_screen.dart';

/// «برامج الرحلات»: the trips a tour company wrote, drafts and published, and a button to start a new one.
class TripProgramsScreen extends ConsumerWidget {
  const TripProgramsScreen({super.key});

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final title = TextEditingController();
    final summary = TextEditingController();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.tripNew),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: title, decoration: InputDecoration(labelText: l10n.tripTitleHint), autofocus: true),
          const SizedBox(height: 8),
          TextField(controller: summary, maxLines: 2, decoration: InputDecoration(labelText: l10n.tripSummaryHint)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(l10n.commonSave)),
        ],
      ),
    );
    final name = title.text.trim();
    final text = summary.text.trim();
    title.dispose();
    summary.dispose();
    if (ok != true || name.isEmpty) return;

    try {
      final program = await ref.read(tripProgramsApiProvider).create(name, text);
      ref.invalidate(myTripProgramsProvider);
      await navigator.push(MaterialPageRoute(builder: (_) => TripProgramEditorScreen(programId: program.id)));
      ref.invalidate(myTripProgramsProvider);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(myTripProgramsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tripScreenTitle)),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _create(context, ref), icon: const Icon(Icons.add), label: Text(l10n.tripNew)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: OutlinedButton(onPressed: () => ref.invalidate(myTripProgramsProvider), child: Text(l10n.commonRetry))),
        data: (list) => list.isEmpty
            ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(l10n.tripEmpty, textAlign: TextAlign.center)))
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final p = list[i];

                  return Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.route_outlined)),
                      title: Text(p.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(l10n.tripDaysCount(p.daysCount)),
                      trailing: Text(p.isPublished ? l10n.tripPublished : l10n.tripDraft, style: TextStyle(color: p.isPublished ? AppColors.success : AppColors.warning, fontWeight: FontWeight.w700, fontSize: 12)),
                      onTap: () async {
                        await Navigator.of(context).push(MaterialPageRoute(builder: (_) => TripProgramEditorScreen(programId: p.id)));
                        ref.invalidate(myTripProgramsProvider);
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
