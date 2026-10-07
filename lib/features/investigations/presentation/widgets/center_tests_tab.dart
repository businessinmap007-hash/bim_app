import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/investigations_providers.dart';
import '../screens/investigation_order_detail_screen.dart';
import 'investigation_widgets.dart';

/// The «الحجز» tab of a lab's or a radiology centre's page: the tests it does and what it charges, several at once, an
/// optional photo of the doctor's paper request, and one button — the order goes to this centre at once and the centre
/// accepts it with a time.
class CenterTestsTab extends ConsumerStatefulWidget {
  final int centerId;
  const CenterTestsTab({super.key, required this.centerId});

  @override
  ConsumerState<CenterTestsTab> createState() => _CenterTestsTabState();
}

class _CenterTestsTabState extends ConsumerState<CenterTestsTab> {
  final Set<int> _picked = {};
  final _notes = TextEditingController();
  File? _photo;
  bool _sending = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null && mounted) setState(() => _photo = File(picked.path));
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _sending = true);
    try {
      final order = await ref.read(investigationsApiProvider).requestFromCenter(
        centerId: widget.centerId,
        optionIds: _picked.toList(),
        notes: _notes.text.trim(),
        photoPath: _photo?.path,
      );
      ref.invalidate(myInvestigationOrdersProvider);
      if (!mounted) return;
      setState(() {
        _picked.clear();
        _photo = null;
        _notes.clear();
        _sending = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.invRequestSent)));
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => InvestigationOrderDetailScreen(orderId: order.id)));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)));
        setState(() => _sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final async = ref.watch(centerTestsProvider(widget.centerId));

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(child: Text(l10n.commonSomethingWentWrong)),
      data: (tests) {
        if (tests.isEmpty) return Center(child: Text(l10n.invNoTests));

        final total = tests.where((t) => _picked.contains(t.optionId)).fold<double>(0, (a, t) => a + (t.price ?? 0));

        Widget section(String kind) {
          final rows = tests.where((t) => t.kind == kind).toList();
          if (rows.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 6),
                child: Text(investigationKindLabel(l10n, kind), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              ),
              for (final t in rows)
                Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: CheckboxListTile(
                    value: _picked.contains(t.optionId),
                    onChanged: (on) => setState(() => on == true ? _picked.add(t.optionId) : _picked.remove(t.optionId)),
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(t.name),
                    secondary: Text(
                      '${formatInvestigationMoney(t.price ?? 0)} ${l10n.invCurrency}',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
            ],
          );
        }

        return Builder(
          builder: (context) => CustomScrollView(
            key: const PageStorageKey('center_tests'),
            slivers: [
              SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(l10n.invPickTests, style: theme.textTheme.titleLarge),
                    section('lab'),
                    section('radiology'),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _pickPhoto,
                      icon: Icon(_photo == null ? Icons.upload_outlined : Icons.check_circle_outline),
                      label: Text(l10n.invAttachPaper),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notes,
                      minLines: 2,
                      maxLines: 4,
                      decoration: InputDecoration(labelText: l10n.invNotesLabel, alignLabelWithHint: true),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: Text(_picked.isEmpty ? l10n.invNothingSelected : l10n.invSelectedCount(_picked.length), style: theme.textTheme.bodySmall)),
                        Text('${formatInvestigationMoney(total)} ${l10n.invCurrency}', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _picked.isEmpty || _sending ? null : _send,
                        child: _sending
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text(l10n.invSendRequest),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
