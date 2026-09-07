import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/env/env.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../contact_groups/application/contact_groups_providers.dart';
import '../../../contact_groups/data/models/contact_group.dart';
import '../../application/shared_cart_providers.dart';
import '../screens/shared_cart_screen.dart';
import 'group_member_picker_sheet.dart';

/// Every way to bring someone into a shared cart, in one popup — QR to show,
/// invite one friend, or invite a whole contact group — reached right where
/// the customer picks delivery/pickup, before they've added anything, rather
/// than only after they've built up a cart (see FulfillmentSelectorBar's
/// caller in BusinessDetailScreen). Talks to SharedCartApi directly instead
/// of the per-screen SharedCartController, since this isn't tied to viewing
/// the cart itself.
Future<void> showShareCartSheet(
  BuildContext context, {
  required int orderId,
  required String shareToken,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _ShareCartSheet(orderId: orderId, shareToken: shareToken),
  );
}

class _ShareCartSheet extends ConsumerWidget {
  final int orderId;
  final String shareToken;
  const _ShareCartSheet({required this.orderId, required this.shareToken});

  Future<void> _inviteFriend(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final identifier = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.sharedCartInviteFriend),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.sharedCartInviteHint),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(l10n.sharedCartInviteAction),
          ),
        ],
      ),
    );
    if (identifier == null || identifier.isEmpty || !context.mounted) return;

    try {
      final name = await ref.read(sharedCartApiProvider).invite(orderId, identifier);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.sharedCartInviteSent(name))));
      }
    } catch (e) {
      if (context.mounted) {
        final message = e is ApiException ? (e.firstErrorFor('identifier') ?? e.message) : l10n.commonSomethingWentWrong;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  Future<void> _inviteGroup(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final groupsNotifier = ref.read(contactGroupsControllerProvider.notifier);
    var groups = ref.read(contactGroupsControllerProvider).groups;
    if (groups.isEmpty) {
      await groupsNotifier.load();
      groups = ref.read(contactGroupsControllerProvider).groups;
    }
    if (!context.mounted) return;

    if (groups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.sharedCartNoGroupsYet)));
      return;
    }

    final group = await showModalBottomSheet<ContactGroup>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(l10n.sharedCartInviteGroup, style: Theme.of(context).textTheme.titleMedium),
            ),
            for (final g in groups)
              ListTile(
                leading: const Icon(Icons.groups_outlined),
                title: Text(g.name),
                subtitle: Text(l10n.contactGroupMembersCount(g.membersCount)),
                onTap: () => Navigator.pop(sheetContext, g),
              ),
          ],
        ),
      ),
    );
    if (group == null || !context.mounted) return;

    if (group.members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.contactGroupNoMembers)));
      return;
    }

    final memberIds = await showModalBottomSheet<List<int>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => GroupMemberPickerSheet(members: group.members),
    );
    if (memberIds == null || memberIds.isEmpty || !context.mounted) return;

    try {
      final names = await ref.read(sharedCartApiProvider).inviteGroup(orderId, group.id, memberIds: memberIds);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.sharedCartGroupInviteSent(names.length))));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // Same join URL the web host-share page's QR (SharedCartWebController::qr)
    // and SharedCartScreen's own QR sheet encode — generated on-device so
    // this doesn't need CORS opened up on a non-API path just for an image.
    final joinUrl = '${Env.assetBaseUrl}/cart/join/$shareToken';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.cartShareCart, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(
              l10n.sharedCartQrHint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: QrImageView(data: joinUrl, size: 180, backgroundColor: Colors.white),
              ),
            ),
            Center(
              child: TextButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: joinUrl));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.cartShareCopied)));
                  }
                },
                icon: const Icon(Icons.copy_outlined, size: 18),
                label: Text(l10n.sharedCartCopyLink),
              ),
            ),
            const Divider(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person_add_alt_outlined),
              title: Text(l10n.sharedCartInviteFriend),
              onTap: () => _inviteFriend(context, ref),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.groups_outlined),
              title: Text(l10n.sharedCartInviteGroup),
              onTap: () => _inviteGroup(context, ref),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.arrow_forward_outlined),
              title: Text(l10n.sharedCartTitle),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => SharedCartScreen(orderId: orderId)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
