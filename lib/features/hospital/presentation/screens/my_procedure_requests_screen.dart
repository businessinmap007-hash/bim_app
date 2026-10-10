import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../application/hospital_providers.dart';
import '../widgets/procedure_widgets.dart';

/// The patient's own requests for medical procedures at hospitals, with what each hospital answered.
class MyProcedureRequestsScreen extends ConsumerWidget {
  const MyProcedureRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(myProcedureRequestsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.procMyRequestsTitle)),
      body: AsyncValueView(
        value: async,
        onRetry: () => ref.invalidate(myProcedureRequestsProvider),
        builder: (context, rows) {
          if (rows.isEmpty) return Center(child: Text(l10n.procMyRequestsEmpty));

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myProcedureRequestsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: rows.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final r = rows[i];

                return ProcedureRequestCard(
                  request: r,
                  actions: [
                    if (r.canCancel)
                      OutlinedButton(
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          try {
                            await ref.read(hospitalApiProvider).cancelProcedureRequest(r.id);
                            ref.invalidate(myProcedureRequestsProvider);
                          } catch (e) {
                            messenger.showSnackBar(
                              SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)),
                            );
                          }
                        },
                        child: Text(l10n.procCancelRequest),
                      ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
