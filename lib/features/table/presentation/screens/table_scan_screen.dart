import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../cart/presentation/screens/shared_cart_screen.dart';
import '../../application/table_providers.dart';

/// Api\V2\TableController::scan — a dine-in table's permanent code, typed in
/// rather than camera-scanned (the code is printed on the table; no scanner
/// package exists in this app and the backend never requires one). Joins
/// the table's shared cart — first to enter becomes host, later entries
/// join the same open order — then hands off to the existing shared-cart
/// screen, passing the table token along so it can offer "call waiter".
class TableScanScreen extends ConsumerStatefulWidget {
  const TableScanScreen({super.key});

  @override
  ConsumerState<TableScanScreen> createState() => _TableScanScreenState();
}

class _TableScanScreenState extends ConsumerState<TableScanScreen> {
  final _tokenController = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final l10n = AppLocalizations.of(context)!;
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      setState(() => _error = l10n.validationRequired);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await ref.read(tableApiProvider).scan(token);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => SharedCartScreen(orderId: result.orderId, tableToken: token),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _busy = false;
        _error = e is ApiException ? e.message : l10n.commonSomethingWentWrong;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tableScanTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.tableScanHint, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            TextField(
              controller: _tokenController,
              autofocus: true,
              decoration: InputDecoration(labelText: l10n.tableScanCodeLabel),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _join(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _busy ? null : _join,
              child: _busy
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l10n.tableScanJoin),
            ),
          ],
        ),
      ),
    );
  }
}
