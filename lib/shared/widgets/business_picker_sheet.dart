import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/discovery/application/discovery_providers.dart';
import '../../features/discovery/data/models/business_summary.dart';
import '../../l10n/app_localizations.dart';

/// Picks one business by name — a plain search over the platform's own
/// cross-category business search (the same one Categories' search box
/// uses). Pops the picked [BusinessSummary], or null if dismissed. Shared
/// between a restricted retail listing's audience picker and a business
/// group's "add a business" flow — both are just "search, then pick one".
class BusinessPickerSheet extends ConsumerStatefulWidget {
  const BusinessPickerSheet({super.key});

  @override
  ConsumerState<BusinessPickerSheet> createState() => _BusinessPickerSheetState();
}

class _BusinessPickerSheetState extends ConsumerState<BusinessPickerSheet> {
  final _controller = TextEditingController();
  List<BusinessSummary> _results = const [];
  bool _loading = false;
  bool _searched = false;

  Future<void> _search(String q) async {
    setState(() {
      _loading = true;
      _searched = true;
    });
    try {
      final results = await ref.read(searchApiProvider).businesses(q);
      if (mounted) setState(() => _results = results);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.retailListingBusinessSearchTitle, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: l10n.retailListingBusinessSearchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () => _search(_controller.text),
                  ),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: _search,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : !_searched
                    ? const SizedBox.shrink()
                    : _results.isEmpty
                    ? Center(child: Text(l10n.retailListingBusinessSearchEmpty))
                    : ListView.separated(
                        itemCount: _results.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final business = _results[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: business.logoUrl != null ? NetworkImage(business.logoUrl!) : null,
                              child: business.logoUrl == null ? const Icon(Icons.storefront_outlined) : null,
                            ),
                            title: Text(business.name),
                            onTap: () => Navigator.of(context).pop(business),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
