import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bim_app/core/deposit/guarantor.dart';
import 'package:bim_app/core/deposit/visit_deposit.dart';
import 'package:bim_app/core/deposit/visit_deposit_api.dart';
import 'package:bim_app/core/deposit/visit_deposit_providers.dart';
import 'package:bim_app/core/deposit/widgets/invite_guarantor_sheet.dart';
import 'package:bim_app/core/network/api_client.dart';
import 'package:bim_app/features/contact_groups/application/contact_groups_providers.dart';
import 'package:bim_app/features/contact_groups/data/contact_groups_api.dart';
import 'package:bim_app/features/contact_groups/data/models/contact_group.dart';
import 'package:bim_app/l10n/app_localizations.dart';

class _NoClient implements ApiClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeDeposit extends VisitDepositApi {
  final invitedUsers = <int>[];
  _FakeDeposit() : super(_NoClient());

  @override
  Future<GuarantorList> guarantors(VisitKind kind, int id) async => GuarantorList(
    items: [Guarantor(id: 9, status: Guarantor.invited, guarantorId: 3, guarantorName: 'Mona')],
    need: const GuarantorNeed(deposit: 100, combinedCoverage: 20, needed: 80),
  );

  @override
  Future<Guarantor> inviteGuarantor(VisitKind kind, int id, {String? phone, String? email, int? userId}) async {
    invitedUsers.add(userId ?? -1);

    return Guarantor(id: 10, status: Guarantor.invited, guarantorId: userId, guarantorName: 'x');
  }
}

class _FakeGroups extends ContactGroupsApi {
  _FakeGroups() : super(_NoClient());

  @override
  Future<List<ContactGroup>> list() async => const [
    ContactGroup(
      id: 1,
      name: 'العائلة',
      membersCount: 2,
      members: [
        ContactGroupMember(id: 1, userId: 3, name: 'Mona'),
        ContactGroupMember(id: 2, userId: 4, name: 'Karim'),
      ],
    ),
  ];
}

void main() {
  testWidgets('a person of the friends-and-family groups is invited with one tap; one already invited is left out', (tester) async {
    final deposit = _FakeDeposit();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          visitDepositApiProvider.overrideWithValue(deposit),
          contactGroupsApiProvider.overrideWithValue(_FakeGroups()),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showInviteGuarantorSheet(context, kind: VisitKind.tripReservation, subjectId: 5),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Karim is a choice; Mona (user 3) is already invited and appears only as the invited row, never as a chip
    expect(find.widgetWithText(ActionChip, 'Karim'), findsOneWidget);
    expect(find.widgetWithText(ActionChip, 'Mona'), findsNothing);

    await tester.tap(find.widgetWithText(ActionChip, 'Karim'));
    await tester.pumpAndSettle();

    expect(deposit.invitedUsers, [4]);
  });
}
