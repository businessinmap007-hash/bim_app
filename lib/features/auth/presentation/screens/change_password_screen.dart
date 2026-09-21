import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/auth_controller.dart';

/// Change the signed-in account's password (POST /profile/password). The
/// backend also revokes every OTHER device's session, which is what the
/// success message says — this device stays signed in.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _submitting = false;
  String? _error;

  Future<void> _submit() async {
    if (_formKey.currentState?.saveAndValidate() != true) return;
    final values = _formKey.currentState!.value;

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref
          .read(authApiProvider)
          .changePassword(
            currentPassword: values['current_password'] as String,
            password: values['password'] as String,
            passwordConfirmation: values['password_confirmation'] as String,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.authChangePasswordSuccess)),
      );
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      // The wrong-current-password message arrives as a field error; show
      // whichever the server sent first rather than a generic 422 line.
      final field = e.fieldErrors.values.expand((m) => m).cast<String?>().firstWhere((_) => true, orElse: () => null);
      setState(() => _error = field ?? e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.authChangePassword)),
      body: FormBuilder(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_error != null) ...[
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              const SizedBox(height: 12),
            ],
            FormBuilderTextField(
              name: 'current_password',
              decoration: InputDecoration(labelText: l10n.authCurrentPassword),
              obscureText: true,
              textInputAction: TextInputAction.next,
              validator: FormBuilderValidators.required(errorText: l10n.validationRequired),
            ),
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: 'password',
              decoration: InputDecoration(
                labelText: l10n.authNewPassword,
                helperText: l10n.validationPasswordPolicy,
                helperMaxLines: 2,
              ),
              obscureText: true,
              textInputAction: TextInputAction.next,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: l10n.validationRequired),
                FormBuilderValidators.minLength(8),
              ]),
            ),
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: 'password_confirmation',
              decoration: InputDecoration(labelText: l10n.authConfirmPassword),
              obscureText: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              validator: (value) {
                final password = _formKey.currentState?.fields['password']?.value;
                if (value != password) return l10n.validationPasswordMismatch;
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l10n.commonSave),
            ),
          ],
        ),
      ),
    );
  }
}
