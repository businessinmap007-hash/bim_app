import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../contact_groups/data/models/contact_group.dart';

/// Lets the host pick specific members of a contact group to invite, instead
/// of always notifying everyone in it. Defaults to everyone selected (the
/// old all-or-nothing behaviour) — unchecking is the opt-out, not the other
/// way around. Pops the list of chosen user ids, or nothing if dismissed.
class GroupMemberPickerSheet extends StatefulWidget {
  final List<ContactGroupMember> members;
  const GroupMemberPickerSheet({super.key, required this.members});

  @override
  State<GroupMemberPickerSheet> createState() => _GroupMemberPickerSheetState();
}

class _GroupMemberPickerSheetState extends State<GroupMemberPickerSheet> {
  late final Set<int> _selected = widget.members.map((m) => m.userId).toSet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final allSelected = _selected.length == widget.members.length;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.sharedCartSelectMembers, style: Theme.of(context).textTheme.titleMedium),
            const Divider(height: 24),
            CheckboxListTile(
              value: allSelected,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.sharedCartSelectAll, style: const TextStyle(fontWeight: FontWeight.w600)),
              onChanged: (checked) => setState(() {
                _selected
                  ..clear()
                  ..addAll(checked == true ? widget.members.map((m) => m.userId) : const <int>[]);
              }),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final m in widget.members)
                    CheckboxListTile(
                      value: _selected.contains(m.userId),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      title: Text(m.name),
                      onChanged: (checked) => setState(() {
                        if (checked == true) {
                          _selected.add(m.userId);
                        } else {
                          _selected.remove(m.userId);
                        }
                      }),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _selected.isEmpty ? null : () => Navigator.pop(context, _selected.toList()),
              child: Text(l10n.sharedCartInviteAction),
            ),
          ],
        ),
      ),
    );
  }
}
