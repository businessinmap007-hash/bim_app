import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/auth_controller.dart';

/// Two-step /auth/password/{forgot,resend,verify,reset} flow: step 1 sends
/// a code to the given email, step 2 takes that code plus a new password.
/// Kept as one screen (not two routes) since the only state that moves
/// between the steps — the email — has nowhere else to live in between.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailFormKey = GlobalKey<FormBuilderState>();
  final _resetFormKey = GlobalKey<FormBuilderState>();

  bool _codeSent = false;
  bool _submitting = false;
  String? _error;
  String _email = '';

  Future<void> _sendCode() async {
    if (_emailFormKey.currentState?.saveAndValidate() != true) return;
    final email = _emailFormKey.currentState!.value['email'] as String;

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(authApiProvider).forgotPassword(email);
      if (mounted) {
        setState(() {
          _email = email;
          _codeSent = true;
        });
      }
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _resendCode() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(authApiProvider).resendResetCode(_email);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_resetFormKey.currentState?.saveAndValidate() != true) return;
    final values = _resetFormKey.currentState!.value;

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref
          .read(authApiProvider)
          .resetPassword(
            email: _email,
            code: values['code'] as String,
            password: values['password'] as String,
            passwordConfirmation: values['password_confirmation'] as String,
          );
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.authResetPasswordSuccess)),
        );
        context.go('/login');
      }
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
      appBar: AppBar(title: Text(l10n.authForgotPasswordTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_error != null) ...[
                    _ErrorBanner(message: _error!),
                    const SizedBox(height: 16),
                  ],
                  if (!_codeSent) _buildEmailStep(l10n) else _buildResetStep(l10n),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailStep(AppLocalizations l10n) {
    return FormBuilder(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.authForgotPasswordInstructions,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          FormBuilderTextField(
            name: 'email',
            decoration: InputDecoration(labelText: l10n.authEmailOrPhone),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _sendCode(),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(
                errorText: l10n.validationRequired,
              ),
              FormBuilderValidators.email(
                errorText: l10n.validationInvalidEmail,
              ),
            ]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submitting ? null : _sendCode,
            child: _submitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(l10n.authSendCode),
          ),
        ],
      ),
    );
  }

  Widget _buildResetStep(AppLocalizations l10n) {
    return FormBuilder(
      key: _resetFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.authCodeSentMessage,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          FormBuilderTextField(
            name: 'code',
            decoration: InputDecoration(labelText: l10n.authVerificationCode),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            validator: FormBuilderValidators.required(
              errorText: l10n.validationRequired,
            ),
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'password',
            decoration: InputDecoration(
              labelText: l10n.authNewPassword,
              helperText: l10n.validationPasswordPolicy,
            ),
            obscureText: true,
            textInputAction: TextInputAction.next,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(
                errorText: l10n.validationRequired,
              ),
              FormBuilderValidators.minLength(8),
            ]),
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'password_confirmation',
            decoration: InputDecoration(labelText: l10n.authConfirmPassword),
            obscureText: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _resetPassword(),
            validator: (value) {
              final password =
                  _resetFormKey.currentState?.fields['password']?.value;
              if (value != password) return l10n.validationPasswordMismatch;
              return null;
            },
          ),
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: _submitting ? null : _resendCode,
              child: Text(l10n.authResendCode),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submitting ? null : _resetPassword,
            child: _submitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(l10n.authResetPassword),
          ),
        ],
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
      child: Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}
