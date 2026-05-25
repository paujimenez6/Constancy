import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:Constancy/presentation/screens/update_password_screen.dart';
import 'package:Constancy/presentation/providers/auth_provider.dart';
import 'package:Constancy/domain/models/user_model.dart';
import 'package:Constancy/generated/l10n.dart';

class MockAuthProvider extends Mock implements AuthProvider {}

void main() {
  Provider.debugCheckInvalidValueType = null;

  late MockAuthProvider mockAuth;

  final tUser = UserModel(
    id: 'u1', nickname: 'pau', nom: 'Pau', cognom: 'S',
    correu: 'test@test.com', dataRegistre: DateTime.now(),
  );

  setUp(() {
    mockAuth = MockAuthProvider();
    when(() => mockAuth.currentUser).thenReturn(tUser);
  });

  Widget createTestWidget() {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: mockAuth,
      child: const MaterialApp(
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('ca')],
        home: UpdatePasswordScreen(),
      ),
    );
  }

  testWidgets('Renderitza correctament amb el correu de l\'usuari', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.textContaining('test@test.com'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
  });

  testWidgets('Toggle de visibilitat de contrasenya', (tester) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();

    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
  });

  testWidgets('Validació: contrasenya massa curta', (tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.enterText(find.byType(TextFormField), '123');
    await tester.tap(find.text('Desar nova contrasenya'));
    await tester.pumpAndSettle();

    expect(find.text('Mínim 6 caràcters'), findsOneWidget);
  });

  testWidgets('Èxit: actualització de contrasenya', (tester) async {
    when(() => mockAuth.updatePassword(any())).thenAnswer((_) async => {});

    await tester.pumpWidget(createTestWidget());

    await tester.enterText(find.byType(TextFormField), '123456');
    await tester.tap(find.text('Desar nova contrasenya'));
    await tester.pumpAndSettle();

    verify(() => mockAuth.updatePassword('123456')).called(1);
    expect(find.text('Contrasenya actualitzada correctament!'), findsOneWidget);
  });

  testWidgets('Error: mateixa contrasenya', (tester) async {
    when(() => mockAuth.updatePassword(any())).thenThrow('same_password');

    await tester.pumpWidget(createTestWidget());

    await tester.enterText(find.byType(TextFormField), '123456');
    await tester.tap(find.text('Desar nova contrasenya'));
    await tester.pumpAndSettle();

    expect(find.text('La nova contrasenya ha de ser diferent a l\'actual'), findsOneWidget);
  });

  testWidgets('Error: genèric', (tester) async {
    when(() => mockAuth.updatePassword(any())).thenThrow('Error inesperat');

    await tester.pumpWidget(createTestWidget());

    await tester.enterText(find.byType(TextFormField), '123456');
    await tester.tap(find.text('Desar nova contrasenya'));
    await tester.pumpAndSettle();

    expect(find.text('S\'ha produït un error inesperat. Torna-ho a provar.'), findsOneWidget);
  });
}