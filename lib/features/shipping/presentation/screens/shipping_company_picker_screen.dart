import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/shipping_providers.dart';
import '../../data/shipping_api.dart';

/// The merchant picks the shipping company for an order going to another
/// governorate; each company's fixed price is shown and lands on the invoice.
/// Pops with true once a company was chosen.
class ShippingCompanyPickerScreen extends ConsumerStatefulWidget {
  final int orderId;
  final int? businessId;
  const ShippingCompanyPickerScreen({super.key, required this.orderId, this.businessId});

  @override
  ConsumerState<ShippingCompanyPickerScreen> createState() => _ShippingCompanyPickerScreenState();
}

class _ShippingCompanyPickerScreenState extends ConsumerState<ShippingCompanyPickerScreen> {
  late final Future<List<ShippingCompany>> _companies =
      ref.read(shippingApiProvider).companiesFor(widget.orderId, businessId: widget.businessId);
  int? _choosing;

  Future<void> _choose(ShippingCompany company) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _choosing = company.id);
    try {
      await ref.read(shippingApiProvider).assignCompany(widget.orderId, company.id, businessId: widget.businessId);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is ApiException ? e.message : l10n.commonSomethingWentWrong)),
        );
        setState(() => _choosing = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.shippingPickerTitle)),
      body: FutureBuilder<List<ShippingCompany>>(
        future: _companies,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text(l10n.commonSomethingWentWrong));
          final companies = snapshot.data ?? const [];
          if (companies.isEmpty) return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(l10n.shippingNoCompanies)));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: companies.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final c = companies[index];
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: const Icon(Icons.local_shipping_outlined),
                  title: Text(c.name),
                  subtitle: Text(l10n.shippingFeeLine(c.price.toStringAsFixed(0))),
                  trailing: _choosing == c.id
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.chevron_right),
                  onTap: _choosing != null ? null : () => _choose(c),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
