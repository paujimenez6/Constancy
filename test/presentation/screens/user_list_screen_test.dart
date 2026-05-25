import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:Constancy/presentation/screens/user_list_screen.dart';
import 'package:Constancy/presentation/providers/auth_provider.dart';
import 'package:Constancy/presentation/providers/social_provider.dart';
import 'package:Constancy/domain/models/user_model.dart';
import 'package:Constancy/generated/l10n.dart';

class MockAuthProvider extends Mock implements AuthProvider {}
class MockSocialProvider extends Mock implements SocialProvider {}

void main() {
  Provider.debugCheckInvalidValueType = null;

  late MockAuthProvider mockAuth;
  late MockSocialProvider mockSocial;

  final tUserMe = UserModel(
    id: 'u1', nickname: 'pau', nom: 'Pau', cognom: 'S',
    correu: 'test@test.com', dataRegistre: DateTime.now(),
  );

  final tUserOther = UserModel(
    id: 'u2', nickname: 'altre', nom: 'Altre', cognom: 'User',
    correu: 'altre@test.com', dataRegistre: DateTime.now(),
  );

  setUp(() {
    mockAuth = MockAuthProvider();
    mockSocial = MockSocialProvider();

    when(() => mockAuth.currentUser).thenReturn(tUserMe);

    when(() => mockSocial.removeFollower(any())).thenAnswer((_) async => {});
    when(() => mockSocial.refreshSocialStats(any())).thenAnswer((_) async => {});
  });

  Widget createTestWidget({List<UserModel>? users, bool isFollowers = false}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuth),
        ChangeNotifierProvider<SocialProvider>.value(value: mockSocial),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ca')],
        home: UserListScreen(
          title: 'Títol',
          users: users ?? [tUserMe, tUserOther],
          ownerNickname: 'pau',
          isMyFollowersList: isFollowers,
        ),
      ),
    );
  }

  testWidgets('Renderitza correctament la llista i mostra estat buit', (tester) async {
    await tester.pumpWidget(createTestWidget(users: []));
    await tester.pumpAndSettle();
    expect(find.textContaining('No s\'han trobat usuaris'), findsOneWidget);
  });

  testWidgets('Renderitza llista amb usuaris i etiqueta "ME"', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('pau'), findsOneWidget);
    expect(find.text('altre'), findsOneWidget);
    expect(find.text('TU'), findsOneWidget);
  });

  testWidgets('Acció d\'eliminar seguidor obre el modal i confirma', (tester) async {
    await tester.pumpWidget(createTestWidget(isFollowers: true));
    await tester.pumpAndSettle();

    final removeButton = find.widgetWithText(TextButton, 'Eliminar');
    await tester.tap(removeButton);
    await tester.pumpAndSettle();

    expect(find.text('Eliminar seguidor'), findsOneWidget);
    await tester.tap(find.text('Eliminar').last);
    await tester.pumpAndSettle();

    verify(() => mockSocial.removeFollower('u2')).called(1);
    verify(() => mockSocial.refreshSocialStats('u1')).called(1);
  });

  testWidgets('Cancel·lar l\'eliminació de seguidor', (tester) async {
    await tester.pumpWidget(createTestWidget(isFollowers: true));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Eliminar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel·lar'));
    await tester.pumpAndSettle();

    verifyNever(() => mockSocial.removeFollower(any()));
  });
}