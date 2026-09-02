import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../discovery/application/discovery_providers.dart';
import '../../../discovery/data/models/business_summary.dart';

/// A name-search picker for a business, used to choose a pharmacy to send a
/// prescription to, or a second doctor to share one with. Reuses the same
/// cross-category name search the Search tab uses — the backend is the one
/// that validates the picked account is actually a pharmacy/doctor (the
/// picker can't know that client-side), so a wrong pick just surfaces the
/// server's rejection message rather than being blocked here.
Future<BusinessSummary?> showBusinessPickerSheet(BuildContext context, {required String title}) {
  return showModalBottomSheet<BusinessSummary>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _BusinessPickerSheet(title: title),
  );
}

class _BusinessPickerSheet extends ConsumerStatefulWidget {
  final String title;
  const _BusinessPickerSheet({required this.title});

  @override
  ConsumerState<_BusinessPickerSheet> createState() => _BusinessPickerSheetState();
}

class _BusinessPickerSheetState extends ConsumerState<_BusinessPickerSheet> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<BusinessSummary> _results = const [];
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(q));
  }

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) {
      setState(() => _results = const []);
      return;
    }
    setState(() => _loading = true);
    try {
      final results = await ref.read(searchApiProvider).businesses(q);
      if (mounted) setState(() => _results = results);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.businessSearchHint,
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: _onChanged,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 320,
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _results.isEmpty
                    ? Center(child: Text(l10n.businessListEmpty))
                    : ListView.builder(
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final b = _results[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: b.logoUrl != null ? NetworkImage(b.logoUrl!) : null,
                              child: b.logoUrl == null ? const Icon(Icons.storefront_outlined) : null,
                            ),
                            title: Text(b.name),
                            onTap: () => Navigator.of(context).pop(b),
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
