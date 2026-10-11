import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/full_screen_gallery.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../medical_file/application/medical_file_providers.dart';
import '../../../medical_file/data/medical_file.dart';
import '../../../medical_file/presentation/screens/medical_share_screen.dart';
import '../../application/investigations_providers.dart';
import '../../data/models/investigation.dart';
import '../../data/result_image_store.dart';
import '../widgets/investigation_widgets.dart';

/// One investigation order, from the patient's side: its items and steps, the registered centres with what each charges
/// for the WHOLE order (to share it with one), and the results when they are in. The doctor opens the same screen to
/// follow the order; only the patient sees the share section.
class InvestigationOrderDetailScreen extends ConsumerStatefulWidget {
  final int orderId;
  const InvestigationOrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<InvestigationOrderDetailScreen> createState() => _InvestigationOrderDetailScreenState();
}

class _InvestigationOrderDetailScreenState extends ConsumerState<InvestigationOrderDetailScreen> {
  int? _centerId;
  bool _busy = false;
  List<File> _local = const [];
  bool _localLoaded = false;

  Future<void> _loadLocal(int userId) async {
    if (_localLoaded) return;
    _localLoaded = true;
    try {
      final files = await const ResultImageStore().local(userId, widget.orderId);
      if (mounted) setState(() => _local = files);
    } catch (_) {
      // no local copy readable: the server's photos (if any) are still shown
    }
  }

  List<File> get _localImages => _local.where((f) => !f.path.toLowerCase().endsWith('.pdf')).toList();
  List<File> get _localDocs => _local.where((f) => f.path.toLowerCase().endsWith('.pdf')).toList();

  Future<void> _openUrl(String url) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!ok && mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.invPdfOpenFailed)));
  }

  /// A report kept on this phone is handed to whatever PDF viewer the person picks.
  Future<void> _openLocal(File file) async {
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path, mimeType: 'application/pdf')]));
  }

  Widget _pdfTiles(AppLocalizations l10n, {List<String> urls = const [], List<File> files = const []}) {
    return Column(
      children: [
        for (var i = 0; i < urls.length; i++)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.picture_as_pdf_outlined),
            title: Text(l10n.invPdfReport('${i + 1}')),
            trailing: TextButton(onPressed: () => _openUrl(urls[i]), child: Text(l10n.invOpenPdf)),
          ),
        for (var i = 0; i < files.length; i++)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.picture_as_pdf_outlined),
            title: Text(l10n.invPdfReport('${i + 1}')),
            trailing: TextButton(onPressed: () => _openLocal(files[i]), child: Text(l10n.invOpenPdf)),
          ),
      ],
    );
  }

  /// «نسخة على موبايل المريض»: download the photos, keep them in the app's private folder, then tell the server — it
  /// deletes its own once the ordering doctor has read them.
  Future<void> _keepPhotos(InvestigationOrder order, int userId) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      await const ResultImageStore().save(userId, order.id, order.resultFiles, documentUrls: order.resultDocuments);
      await ref.read(investigationsApiProvider).markSaved(order.id);
      final files = await const ResultImageStore().local(userId, order.id);
      ref.invalidate(investigationOrderProvider(widget.orderId));
      if (mounted) {
        setState(() => _local = files);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.invPhotosKept)));
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.invPhotosSaveFailed)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(investigationOrderProvider(widget.orderId));
      ref.invalidate(investigationCentersProvider(widget.orderId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e is ApiException && e.message.isNotEmpty ? e.message : l10n.commonSomethingWentWrong)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _send(InvestigationCenter center) async {
    final l10n = AppLocalizations.of(context)!;
    await _run(() async {
      await ref.read(investigationsApiProvider).send(widget.orderId, center.id);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.invSent)));
    });
  }

  Future<void> _cancel() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.invCancelConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.invKeepOrder)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.invCancelOrder)),
        ],
      ),
    );
    if (ok == true) await _run(() => ref.read(investigationsApiProvider).cancel(widget.orderId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(investigationOrderProvider(widget.orderId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.invTitle)),
      body: AsyncValueView(
        value: async,
        onRetry: () => ref.invalidate(investigationOrderProvider(widget.orderId)),
        builder: (context, order) => _body(context, l10n, order),
      ),
    );
  }

  /// The results as lines of the patient's medical file: «date · test: …» with the result under it.
  MedicalFile _resultsFile(AppLocalizations l10n, InvestigationOrder order) {
    final day = (order.issuedAt ?? DateTime.now()).toIso8601String().substring(0, 10);

    return MedicalFile(
      sections: {
        MedicalSection.records: [
          for (final i in order.items)
            if (i.hasResult) MedicalEntry(title: '$day · ${investigationKindLabel(l10n, i.kind)}: ${i.name}', detail: i.result!),
        ],
      },
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _keepCopy(AppLocalizations l10n, InvestigationOrder order) async {
    final controller = ref.read(medicalFileControllerProvider.notifier);
    final mine = ref.read(medicalFileControllerProvider).valueOrNull ?? const MedicalFile();
    await controller.save(mine.mergedWith(_resultsFile(l10n, order)));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.invSavedToMyFile)));
  }

  Widget _body(BuildContext context, AppLocalizations l10n, InvestigationOrder order) {
    final theme = Theme.of(context);
    final auth = ref.watch(authControllerProvider);
    final userId = auth is AuthSignedIn ? auth.user.id : null;
    final isPatient = userId != null && order.patient?.id == userId;
    if (isPatient) _loadLocal(userId);
    final locale = Localizations.localeOf(context).toString();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.doctor != null ? l10n.invFromDoctor(order.doctor!.name) : l10n.invOwnRequest,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    InvestigationStatusPill(status: order.status),
                  ],
                ),
                if (order.issuedAt != null)
                  Text(formatInvestigationDate(context, order.issuedAt!), style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                if (order.step > 0) ...[const SizedBox(height: 14), InvestigationSteps(step: order.step)],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InvestigationItemRows(items: order.items, centerChosen: order.center != null),
                if (order.total != null) ...[
                  const Divider(height: 20),
                  Row(
                    children: [
                      Text(l10n.invTotal, style: theme.textTheme.titleSmall),
                      const Spacer(),
                      Text(
                        '${formatInvestigationMoney(order.total!)} ${l10n.invCurrency}',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ],
                if ((order.notes ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(l10n.invDoctorNote(order.notes!), style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                ],
              ],
            ),
          ),
        ),
        if (order.center != null && order.status != InvestigationOrder.issued) ...[
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.local_hospital_outlined),
              title: Text(order.center!.name),
              subtitle: Text(
                [
                  if (order.appointmentAt != null) l10n.invAppointment(formatInvestigationDate(context, order.appointmentAt!)),
                  if ((order.centerNote ?? '').isNotEmpty) l10n.invCenterNote(order.centerNote!),
                ].join('\n'),
              ),
            ),
          ),
        ],
        if (order.requestFiles.isNotEmpty) ...[
          const SizedBox(height: 12),
          _thumbs(context, order.requestFiles),
        ],
        if (order.hasTextResults && isPatient) ...[
          const SizedBox(height: 12),
          // «نسخة التحليل تصل للمريض ويرسلها هو أو يشاركها مع الطبيب … ويمكنه تحميل نسخة منها في ملف المريض»
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: () => _keepCopy(l10n, order),
                icon: const Icon(Icons.save_alt_outlined),
                label: Text(l10n.invSaveToMyFile),
              ),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => MedicalShareScreen(file: _resultsFile(l10n, order))),
                ),
                icon: const Icon(Icons.qr_code_2_outlined),
                label: Text(l10n.invShareWithDoctor),
              ),
            ],
          ),
        ],
        if (order.resultFiles.isNotEmpty || order.resultDocuments.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(l10n.invResults, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (order.resultFiles.isNotEmpty) _thumbs(context, order.resultFiles),
          if (order.resultDocuments.isNotEmpty) _pdfTiles(l10n, urls: order.resultDocuments),
          if (isPatient) ...[
            const SizedBox(height: 8),
            // the photos stay on the server only until they are safe on the patient's phone
            if (order.filesExpireAt != null && !order.patientSaved)
              Text(
                l10n.invPhotosExpire(DateFormat.yMMMd(locale).format(order.filesExpireAt!)),
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
              ),
            if (!order.patientSaved || _local.isEmpty)
              OutlinedButton.icon(
                onPressed: _busy ? null : () => _keepPhotos(order, userId),
                icon: const Icon(Icons.download_for_offline_outlined),
                label: Text(l10n.invKeepPhotosOnPhone),
              ),
          ],
        ],
        // what the patient kept on this phone — and the only copy once the server has deleted its own
        if (isPatient && _local.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.phone_android_outlined, size: 18),
              const SizedBox(width: 6),
              Text(l10n.invPhotosKeptLocal, style: theme.textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < _localImages.length; i++)
                InkWell(
                  onTap: () => FullScreenGallery.show(context, urls: [for (final f in _localImages) f.uri.toString()], initialIndex: i),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(_localImages[i], width: 96, height: 96, fit: BoxFit.cover),
                  ),
                ),
            ],
          ),
          if (_localDocs.isNotEmpty) _pdfTiles(l10n, files: _localDocs),
        ] else if (isPatient && order.filesPurged && order.resultFiles.isEmpty && order.resultDocuments.isEmpty) ...[
          const SizedBox(height: 12),
          Text(l10n.invPhotosPurgedNoCopy, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
        ],
        if (order.canSend && isPatient) ..._shareSection(context, l10n),
        if (order.canCancel) ...[
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(onPressed: _busy ? null : _cancel, child: Text(l10n.invCancelOrder)),
          ),
        ],
      ],
    );
  }

  Widget _thumbs(BuildContext context, List<String> urls) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < urls.length; i++)
          InkWell(
            onTap: () => FullScreenGallery.show(context, urls: urls, initialIndex: i),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                urls[i],
                width: 96,
                height: 96,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox(width: 96, height: 96, child: Icon(Icons.broken_image_outlined)),
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _shareSection(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final centers = ref.watch(investigationCentersProvider(widget.orderId));

    return [
      const SizedBox(height: 20),
      Text(l10n.invShareTitle, style: theme.textTheme.titleMedium),
      Text(l10n.invShareHint, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
      const SizedBox(height: 8),
      centers.when(
        loading: () => const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
        error: (_, _) => Text(l10n.commonSomethingWentWrong),
        data: (list) {
          if (list.isEmpty) return Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(l10n.invNoCenters));
          final selected = list.where((c) => c.id == _centerId).firstOrNull ?? list.first;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final c in list)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: c.id == selected.id ? theme.colorScheme.primary : Colors.transparent, width: 2),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => setState(() => _centerId = c.id),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                                  Text(
                                    c.coversAll ? l10n.invCoversAll : l10n.invCoversSome(c.covers, c.of),
                                    style: theme.textTheme.bodySmall?.copyWith(color: c.coversAll ? null : theme.hintColor),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${formatInvestigationMoney(c.total)} ${l10n.invCurrency}',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              Text(l10n.invShareNever, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _busy ? null : () => _send(selected),
                  child: _busy
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(l10n.invShareButton(selected.name)),
                ),
              ),
            ],
          );
        },
      ),
    ];
  }
}
