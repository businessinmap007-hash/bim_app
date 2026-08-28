import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  /// 'client' | 'business' — decides which extra fields this form shows.
  final String accountType;

  const RegisterScreen({super.key, required this.accountType});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _submitting = false;
  String? _error;

  bool get _isBusiness => widget.accountType == 'business';

  Future<void> _submit() async {
    if (_formKey.currentState?.saveAndValidate() != true) return;
    final v = _formKey.currentState!.value;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await ref.read(authControllerProvider.notifier).register(
            name: v['name'] as String,
            nameEn: v['name_en'] as String?,
            email: v['email'] as String,
            phone: v['phone'] as String,
            password: v['password'] as String,
            passwordConfirmation: v['password_confirmation'] as String,
            type: widget.accountType,
            categoryChildId: _isBusiness ? int.tryParse(v['category_child_id'] as String? ?? '') : null,
          );
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.authRegister)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null) ...[
                  _ErrorBanner(message: _error!),
                  const SizedBox(height: 16),
                ],
                FormBuilderTextField(
                  name: 'name',
                  decoration: InputDecoration(labelText: l10n.authName),
                  validator: FormBuilderValidators.required(errorText: l10n.validationRequired),
                ),
                if (_isBusiness) ...[
                  const SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'name_en',
                    decoration: const InputDecoration(labelText: 'Business name (English)'),
                    validator: FormBuilderValidators.required(errorText: l10n.validationRequired),
                  ),
                ],
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'email',
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: l10n.validationRequired),
                    FormBuilderValidators.email(errorText: l10n.validationInvalidEmail),
                  ]),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'phone',
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                  validator: FormBuilderValidators.required(errorText: l10n.validationRequired),
                ),
                if (_isBusiness) ...[
                  const SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'category_child_id',
                    decoration: const InputDecoration(
                      labelText: 'Category (child id)',
                      helperText: 'TEMP: numeric id until the category picker (Categories module) ships',
                    ),
                    keyboardType: TextInputType.number,
                    validator: FormBuilderValidators.required(errorText: l10n.validationRequired),
                  ),
                ],
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'password',
                  decoration: InputDecoration(
                    labelText: l10n.authPassword,
                    helperText: l10n.validationPasswordPolicy,
                  ),
                  obscureText: true,
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
                  validator: (value) {
                    final password = _formKey.currentState?.fields['password']?.value;
                    if (value != password) return l10n.validationPasswordMismatch;
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(l10n.authRegister),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(message, style: TextStyle(color: Theme.of(context).colorScheme.error)),
    );
  }
}
