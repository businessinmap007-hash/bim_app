import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';

/// Standard loading/error/data rendering for a Riverpod [AsyncValue], so
/// every list screen shows the same retry affordance instead of each one
/// reinventing it.
class AsyncValueView<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(BuildContext context, T data) builder;
  final VoidCallback? onRetry;

  const AsyncValueView({super.key, required this.value, required this.builder, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (data) => builder(context, data),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) {
        final l10n = AppLocalizations.of(context)!;
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 40, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 12),
                Text(l10n.commonSomethingWentWrong, textAlign: TextAlign.center),
                if (onRetry != null) ...[
                  const SizedBox(height: 12),
                  OutlinedButton(onPressed: onRetry, child: Text(l10n.commonRetry)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
