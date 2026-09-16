import 'package:flutter/material.dart';

/// A person's account, at a glance — avatar, name, phone. The shared shape
/// for "here's who this is" moments across the app: confirming who was just
/// added as staff or to a training plan, and the notification card the
/// other side sees when that invitation arrives (see PersonCard.forBusiness
/// for the inviting business's own version of the same card).
class PersonCard extends StatelessWidget {
  final String name;
  final String? phone;
  final String? photoUrl;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const PersonCard({
    super.key,
    required this.name,
    this.phone,
    this.photoUrl,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  /// Same card, populated from a business account instead of a person —
  /// what an invited employee sees: who is inviting them, not their own
  /// (already-known) details.
  factory PersonCard.forBusiness({
    required String name,
    String? phone,
    String? logoUrl,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) => PersonCard(
    name: name,
    phone: phone,
    photoUrl: logoUrl,
    subtitle: subtitle,
    trailing: trailing,
    onTap: onTap,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
          child: photoUrl == null ? const Icon(Icons.person_outline) : null,
        ),
        title: Text(name, style: theme.textTheme.titleMedium),
        subtitle: Text(
          subtitle?.isNotEmpty == true ? subtitle! : (phone ?? ''),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: trailing,
      ),
    );
  }
}
