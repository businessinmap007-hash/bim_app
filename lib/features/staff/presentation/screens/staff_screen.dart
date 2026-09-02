import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/staff_providers.dart';
import '../../data/models/staff_member.dart';

/// The business owner's delegated-staff roster: who can act on the page's
/// behalf, and for which capabilities. Owner-only (the backend rejects a
/// staff caller here regardless).
class StaffScreen extends ConsumerWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(staffControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.staffTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showStaffMemberSheet(context, ref),
        child: const Icon(Icons.person_add_alt_1_outlined),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.commonSomethingWentWrong),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => ref.read(staffControllerProvider.notifier).loadAll(),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            )
          : state.staff.isEmpty
          ? Center(child: Text(l10n.staffEmpty))
          : RefreshIndicator(
              onRefresh: () => ref.read(staffControllerProvider.notifier).loadAll(),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.staff.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final member = state.staff[index];
                  return _StaffTile(
                    member: member,
                    capabilities: state.capabilities,
                    onTap: () => showStaffMemberSheet(context, ref, existing: member),
                  );
                },
              ),
            ),
    );
  }
}

class _StaffTile extends StatelessWidget {
  final StaffMember member;
  final List<CapabilityOption> capabilities;
  final VoidCallback onTap;
  const _StaffTile({required this.member, required this.capabilities, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    final names = member.capabilities
        .map((key) {
          final match = capabilities.where((c) => c.key == key);
          return match.isNotEmpty ? match.first.name(languageCode) : key;
        })
        .join(' · ');

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundImage: member.logoUrl != null ? NetworkImage(member.logoUrl!) : null,
          child: member.logoUrl == null ? const Icon(Icons.person_outline) : null,
        ),
        title: Text(member.title?.isNotEmpty == true ? '${member.name} — ${member.title}' : member.name),
        subtitle: Text(names.isEmpty ? (member.phone ?? '') : names),
        trailing: !member.isActive
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.staffInactiveBadge,
                  style: const TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              )
            : null,
      ),
    );
  }
}

Future<void> showStaffMemberSheet(BuildContext context, WidgetRef ref, {StaffMember? existing}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _StaffMemberSheet(existing: existing),
  );
}

class _StaffMemberSheet extends ConsumerStatefulWidget {
  final StaffMember? existing;
  const _StaffMemberSheet({this.existing});

  @override
  ConsumerState<_StaffMemberSheet> createState() => _StaffMemberSheetState();
}

class _StaffMemberSheetState extends ConsumerState<_StaffMemberSheet> {
  final _phoneController = TextEditingController();
  final _titleController = TextEditingController();
  final Set<String> _selectedCapabilities = {};
  bool _isActive = true;
  bool _submitting = false;
  String? _error;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _phoneController.text = existing.phone ?? '';
      _titleController.text = existing.title ?? '';
      _selectedCapabilities.addAll(existing.capabilities);
      _isActive = existing.isActive;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_isEdit && _phoneController.text.trim().isEmpty) {
      setState(() => _error = l10n.staffPhoneRequired);
      return;
    }
    if (_selectedCapabilities.isEmpty) {
      setState(() => _error = l10n.staffCapabilitiesRequired);
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final notifier = ref.read(staffControllerProvider.notifier);
      if (_isEdit) {
        await notifier.update(
          widget.existing!.userId,
          title: _titleController.text.trim(),
          capabilities: _selectedCapabilities.toList(),
          isActive: _isActive,
        );
      } else {
        await notifier.add(
          phone: _phoneController.text.trim(),
          title: _titleController.text.trim(),
          capabilities: _selectedCapabilities.toList(),
          isActive: _isActive,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _error = l10n.commonSomethingWentWrong);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _remove() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.staffRemoveConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.staffRemove)),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _submitting = true);
    try {
      await ref.read(staffControllerProvider.notifier).remove(widget.existing!.userId);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _error = AppLocalizations.of(context)!.commonSomethingWentWrong;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    final capabilities = ref.watch(staffControllerProvider).capabilities;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_isEdit ? l10n.staffEdit : l10n.staffAdd, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              if (!_isEdit) ...[
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: l10n.staffPhone),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: l10n.staffJobTitle),
              ),
              const SizedBox(height: 12),
              Text(l10n.staffCapabilities, style: Theme.of(context).textTheme.titleSmall),
              for (final cap in capabilities)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _selectedCapabilities.contains(cap.key),
                  onChanged: (checked) => setState(() {
                    if (checked ?? false) {
                      _selectedCapabilities.add(cap.key);
                    } else {
                      _selectedCapabilities.remove(cap.key);
                    }
                  }),
                  title: Text(cap.name(languageCode)),
                ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
                title: Text(l10n.staffActive),
              ),
              if (_error != null) ...[
                const SizedBox(height: 4),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.commonSave),
              ),
              if (_isEdit) ...[
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _submitting ? null : _remove,
                  style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                  child: Text(l10n.staffRemove),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
