import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// The save button at the end of a settings form — compact, at the start edge, like the business-settings and price
/// screens. It says «تم الحفظ» (disabled) while nothing is left unsaved and goes back to «حفظ» on the next change, so
/// no snack bar is needed to tell the owner it worked.
class FormSaveButton extends StatelessWidget {
  final bool saving;
  final bool saved;
  final VoidCallback onPressed;
  const FormSaveButton({super.key, required this.saving, required this.saved, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: ElevatedButton(
        onPressed: saving || saved ? null : onPressed,
        child: saving
            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : Text(saved ? l10n.storeTermsSavedDone : l10n.commonSave),
      ),
    );
  }
}
