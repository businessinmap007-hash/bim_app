import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/promotions_providers.dart';
import '../../data/models/promotion.dart';
import '../widgets/offer_widgets.dart';
import 'promotion_form_screen.dart';

/// «العروض والخصومات» of the business: its promotions, each running / paused / ended, with a button to write a new one. Open to
/// every business — a clothes shop's products, a restaurant's menu, a salon's services.
class PromotionsScreen extends ConsumerWidget {
  const PromotionsScreen({super.key});

  Future<void> _open(BuildContext context, [Promotion? editing]) =>
      Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => PromotionFormScreen(editing: editing)));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(myPromotionsProvider);
    final api = ref.read(promotionsApiProvider);

    Future<void> run(Future<void> Function() action) async {
      await action();
      ref.invalidate(myPromotionsProvider);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.promoScreenTitle)),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _open(context), icon: const Icon(Icons.add), label: Text(l10n.promoAdd)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: OutlinedButton(onPressed: () => ref.invalidate(myPromotionsProvider), child: Text(l10n.commonRetry))),
        data: (list) => list.isEmpty
            ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(l10n.promoEmpty, textAlign: TextAlign.center)))
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final p = list[i];
                  final (label, color) = p.isRunning
                      ? (l10n.promoRunning, AppColors.success)
                      : (!p.isActive ? (l10n.promoPaused, AppColors.warning) : (l10n.promoEnded, AppColors.error));

                  return PromotionCard(
                    promotion: p,
                    onTap: () => _open(context, p),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
                        PopupMenuButton<String>(
                          onSelected: (v) async {
                            if (v == 'edit') await _open(context, p);
                            if (v == 'toggle') await run(() => api.toggle(p.id));
                            if (v == 'delete') {
                              if (!context.mounted) return;
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  content: Text(l10n.promoDeleteConfirm),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.commonCancel)),
                                    FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(l10n.promoDelete)),
                                  ],
                                ),
                              );
                              if (ok == true) await run(() => api.delete(p.id));
                            }
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(value: 'edit', child: Text(l10n.promoEdit)),
                            PopupMenuItem(value: 'toggle', child: Text(p.isActive ? l10n.promoPause : l10n.promoResume)),
                            PopupMenuItem(value: 'delete', child: Text(l10n.promoDelete)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
