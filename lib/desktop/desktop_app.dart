import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/theme/app_colors.dart';
import '../app/theme/app_theme.dart';
import '../core/network/api_exception.dart';
import '../core/providers/core_providers.dart';
import '../features/auth/application/auth_controller.dart';
import '../features/auth/data/models/auth_user.dart';
import '../features/settings/application/locale_controller.dart';
import '../features/staff/application/staff_providers.dart';
import '../l10n/app_localizations.dart';
import 'shell/desktop_shell.dart';
import 'sync/desktop_sync.dart';

/// The capabilities that open the desktop suite to a staff member.
const suiteCapabilities = {'inventory', 'purchases', 'purchase_approval', 'pos'};

class DesktopApp extends ConsumerWidget {
  const DesktopApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'BIM للأعمال',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      locale: ref.watch(localeControllerProvider),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const _Gate(),
    );
  }
}

/// The business this computer works for: the owner's own, or the employer a staff member chose.
class SuiteBusiness {
  final int id;
  final String name;
  final bool isOwnerAccount;

  const SuiteBusiness({required this.id, required this.name, required this.isOwnerAccount});
}

final suiteBusinessProvider = StateProvider<SuiteBusiness?>((ref) => null);

class _Gate extends ConsumerWidget {
  const _Gate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final business = ref.watch(suiteBusinessProvider);

    return switch (auth) {
      AuthUnknown() => const Scaffold(body: Center(child: CircularProgressIndicator())),
      AuthSignedOut() => const DesktopLoginScreen(),
      AuthSignedIn(:final user) => business == null ? _BusinessPicker(user: user) : const DesktopShell(),
    };
  }
}

/// «ادخل بحسابك على BIM» — the same account as the phone app.
class DesktopLoginScreen extends ConsumerStatefulWidget {
  const DesktopLoginScreen({super.key});

  @override
  ConsumerState<DesktopLoginScreen> createState() => _DesktopLoginScreenState();
}

class _DesktopLoginScreenState extends ConsumerState<DesktopLoginScreen> {
  final _login = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _login.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).login(email: _login.text.trim(), password: _password.text);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.primaryNavy,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: AutofillGroup(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.suiteBrand, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.accentGold)),
                    const SizedBox(height: 8),
                    Text(l10n.suiteSignInTitle, style: Theme.of(context).textTheme.titleLarge),
                    Text(l10n.suiteSignInHint, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _login,
                      autofillHints: const [AutofillHints.username],
                      decoration: InputDecoration(labelText: l10n.suiteLoginField),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _password,
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(labelText: l10n.authPassword),
                      onSubmitted: (_) => _submit(),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ],
                    const SizedBox(height: 20),
                    FilledButton(onPressed: _busy ? null : _submit, child: Text(l10n.authLogin)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// An owner works for his own business; a staff member picks which employer this computer serves.
class _BusinessPicker extends ConsumerStatefulWidget {
  final AuthUser user;
  const _BusinessPicker({required this.user});

  @override
  ConsumerState<_BusinessPicker> createState() => _BusinessPickerState();
}

class _BusinessPickerState extends ConsumerState<_BusinessPicker> {
  @override
  void initState() {
    super.initState();
    if (widget.user.type == 'business') {
      WidgetsBinding.instance.addPostFrameCallback((_) => _choose(widget.user.id, widget.user.name, owner: true));
    }
  }

  void _choose(int id, String name, {required bool owner}) {
    ref.read(apiClientProvider).actingBusinessId = owner ? null : id;
    final sync = ref.read(suiteSyncProvider.notifier);
    sync.businessId = owner ? null : id;
    ref.read(suiteBusinessProvider.notifier).state = SuiteBusiness(id: id, name: name, isOwnerAccount: owner);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (widget.user.type == 'business') {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.suiteChooseBusiness),
        actions: [TextButton(onPressed: () => ref.read(authControllerProvider.notifier).logout(), child: Text(l10n.authLogout))],
      ),
      body: FutureBuilder(
        future: ref.read(staffApiProvider).memberships(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return snap.hasError ? Center(child: Text(l10n.commonSomethingWentWrong)) : const Center(child: CircularProgressIndicator());
          }
          final rows = snap.data!.where((m) => m.capabilities.any(suiteCapabilities.contains)).toList();
          if (rows.isEmpty) return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(l10n.suiteNoBusiness)));
          if (rows.length == 1) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _choose(rows.first.businessId, rows.first.businessName, owner: false));
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  for (final m in rows)
                    Card(
                      child: ListTile(
                        title: Text(m.businessName),
                        subtitle: Text(m.capabilities.where(suiteCapabilities.contains).join('، ')),
                        onTap: () => _choose(m.businessId, m.businessName, owner: false),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
