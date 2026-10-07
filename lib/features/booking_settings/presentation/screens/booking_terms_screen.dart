import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/form_save_button.dart';
import '../../../../shared/widgets/scrolling_chip_row.dart';
import '../../application/booking_settings_controller.dart';
import '../../application/booking_terms_provider.dart';
import '../../data/models/booking_terms.dart';

/// «شروط الحجز» — how this business secures its bookings, in its own words (Api\V2\BusinessBookingTermsController):
/// a deposit frozen in both wallets (the preferred way), the customer's guarantee, or a transfer outside the app that
/// both parties confirm. Every booking still waits for the business's approval; that is shown, not switched.
class BookingTermsScreen extends ConsumerStatefulWidget {
  const BookingTermsScreen({super.key});

  @override
  ConsumerState<BookingTermsScreen> createState() => _BookingTermsScreenState();
}

class _BookingTermsScreenState extends ConsumerState<BookingTermsScreen> {
  static const _exampleValue = 800.0;
  static const _percents = [10.0, 20.0, 25.0, 30.0, 40.0, 50.0];
  static const _counters = [0.0, 25.0, 50.0, 100.0];
  static const _multiples = [0.0, 1.0, 2.0, 3.0, 5.0, 10.0];

  BookingTerms? _terms;
  bool _saving = false;
  String? _error;
  // what the server last had — the button says «تم الحفظ» exactly while the form equals it
  String? _savedSignature;

  String _signatureOf(BookingTerms t) => jsonEncode(t.toJson());

  void _change(BookingTerms Function(BookingTerms) edit) => setState(() => _terms = edit(_terms!));

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final saved = await ref.read(bookingSettingsApiProvider).saveBookingTerms(_terms!);
      ref.invalidate(bookingTermsProvider);
      if (!mounted) return;
      setState(() {
        _terms = saved;
        _savedSignature = _signatureOf(saved);
      });
    } catch (e) {
      if (mounted) setState(() => _error = e is ApiException ? e.message : l10n.commonSomethingWentWrong);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(bookingTermsProvider);
    if (_terms == null && async.hasValue) {
      _terms = async.value;
      _savedSignature = _signatureOf(_terms!);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookingTermsTitle)),
      body: _terms == null
          ? Center(
              child: async.hasError
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.commonSomethingWentWrong),
                        const SizedBox(height: 8),
                        OutlinedButton(onPressed: () => ref.invalidate(bookingTermsProvider), child: Text(l10n.commonRetry)),
                      ],
                    )
                  : const CircularProgressIndicator(),
            )
          : _form(context, l10n, _terms!),
    );
  }

  Widget _form(BuildContext context, AppLocalizations l10n, BookingTerms terms) {
    final theme = Theme.of(context);
    final external = terms.mode == BookingSecurityMode.externalTransfer;
    final guarantee = terms.mode == BookingSecurityMode.guaranteeFreeze;

    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text(text, style: theme.textTheme.titleSmall),
    );

    Widget chip({required String label, required bool selected, required VoidCallback onTap}) => ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );

    String number(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Text(l10n.bookingTermsIntro, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.bookingTermsEnabled),
          subtitle: Text(l10n.bookingTermsEnabledHint),
          value: terms.enabled,
          onChanged: (v) => _change((t) => t.copyWith(enabled: v)),
        ),
        if (terms.hasSpecificPolicies)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.accentGold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(l10n.bookingTermsSpecificWarning, style: theme.textTheme.bodySmall)),
              ],
            ),
          ),
        if (terms.enabled) ...[
          heading(l10n.bookingTermsModeTitle),
          _ModeCard(
            title: l10n.bookingTermsModeDeposit,
            hint: l10n.bookingTermsModeDepositHint,
            badge: l10n.bookingTermsRecommended,
            selected: terms.mode == BookingSecurityMode.depositFreeze,
            onTap: () => _change((t) => t.copyWith(mode: BookingSecurityMode.depositFreeze)),
          ),
          _ModeCard(
            title: l10n.bookingTermsModeGuarantee,
            hint: l10n.bookingTermsModeGuaranteeHint,
            selected: guarantee,
            onTap: () => _change((t) => t.copyWith(mode: BookingSecurityMode.guaranteeFreeze)),
          ),
          _ModeCard(
            title: l10n.bookingTermsModeExternal,
            hint: l10n.bookingTermsModeExternalHint,
            selected: external,
            onTap: () => _change((t) => t.copyWith(mode: BookingSecurityMode.externalTransfer)),
          ),
          heading(l10n.bookingTermsPercentTitle),
          ScrollingChipRow(
            children: [
              for (final p in _percents)
                chip(
                  label: l10n.bookingTermsPercentValue(number(p)),
                  selected: terms.depositPercent == p,
                  onTap: () => _change((t) => t.copyWith(depositPercent: p)),
                ),
            ],
          ),
          heading(l10n.bookingTermsBaseTitle),
          ScrollingChipRow(
            children: [
              chip(
                label: l10n.bookingTermsBaseFirstDay,
                selected: terms.depositBase == 'first_day',
                onTap: () => _change((t) => t.copyWith(depositBase: 'first_day')),
              ),
              chip(
                label: l10n.bookingTermsBaseTotal,
                selected: terms.depositBase == 'total',
                onTap: () => _change((t) => t.copyWith(depositBase: 'total')),
              ),
            ],
          ),
          if (external)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(l10n.bookingTermsExternalNote, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
            )
          else ...[
            heading(l10n.bookingTermsCounterTitle),
            ScrollingChipRow(
              children: [
                for (final c in _counters)
                  chip(
                    label: l10n.bookingTermsCounterValue(number(c)),
                    selected: terms.businessCounterPercent == c,
                    onTap: () => _change((t) => t.copyWith(businessCounterPercent: c)),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(l10n.bookingTermsCounterHint, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
          ],
          if (guarantee) ...[
            heading(l10n.bookingTermsGuaranteeTitle),
            ScrollingChipRow(
              children: [
                for (final m in _multiples)
                  chip(
                    label: m == 0 ? l10n.bookingTermsGuaranteeSame : l10n.bookingTermsGuaranteeTimes(number(m)),
                    selected: terms.guaranteeMultiple == m,
                    onTap: () => _change((t) => t.copyWith(guaranteeMultiple: m)),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(l10n.bookingTermsGuaranteeHint, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
          ],
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.bookingTermsForfeitTitle),
            subtitle: Text(l10n.bookingTermsForfeitHint),
            value: terms.forfeitToBusiness,
            onChanged: (v) => _change((t) => t.copyWith(forfeitToBusiness: v)),
          ),
          if (terms.mode == BookingSecurityMode.depositFreeze)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.bookingTermsDepositAsPayment),
              subtitle: Text(l10n.bookingTermsDepositAsPaymentHint),
              value: terms.acceptDepositAsPayment,
              onChanged: (v) => _change((t) => t.copyWith(acceptDepositAsPayment: v)),
            ),
          const SizedBox(height: 8),
          Text(l10n.depositNotPartOfPrice, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 12),
          _Example(example: terms.previewFor(_exampleValue), mode: terms.mode, number: number),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.verified_outlined, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(l10n.bookingTermsApprovalNote, style: theme.textTheme.bodySmall)),
          ],
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
        ],
        const SizedBox(height: 20),
        FormSaveButton(saving: _saving, saved: _savedSignature == _signatureOf(terms), onPressed: _save),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String hint;
  final String? badge;
  final bool selected;
  final VoidCallback onTap;
  const _ModeCard({required this.title, required this.hint, this.badge, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: selected ? AppColors.accentGold : theme.dividerColor, width: selected ? 2 : 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: selected ? AppColors.accentGold : theme.hintColor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(child: Text(title, style: theme.textTheme.titleSmall)),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.accentGold, borderRadius: BorderRadius.circular(8)),
                            child: Text(badge!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primaryNavy)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(hint, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Example extends StatelessWidget {
  final BookingTermsExample example;
  final BookingSecurityMode mode;
  final String Function(double) number;
  const _Example({required this.example, required this.mode, required this.number});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final lines = <String>[
      l10n.bookingTermsExampleDeposit(number(example.deposit)),
      if (mode == BookingSecurityMode.externalTransfer)
        l10n.bookingTermsExampleExternal(number(example.externalAmount))
      else ...[
        l10n.bookingTermsExampleCustomer(number(example.customerHold)),
        if (example.businessHold > 0) l10n.bookingTermsExampleBusiness(number(example.businessHold)),
      ],
      if (mode == BookingSecurityMode.guaranteeFreeze) l10n.bookingTermsExampleGuarantee(number(example.guaranteeRequired)),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.accentGold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.bookingTermsExampleTitle(number(example.bookingValue)), style: theme.textTheme.titleSmall),
          const SizedBox(height: 6),
          for (final line in lines) Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Text(line)),
        ],
      ),
    );
  }
}
