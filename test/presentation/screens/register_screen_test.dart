import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:Constancy/generated/l10n.dart';
import 'package:Constancy/presentation/providers/auth_provider.dart';
import 'package:Constancy/presentation/screens/register_screen.dart';

class MockAuthProvider extends Mock implements AuthProvider {}

void main() {
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();

    when(() => mockAuthProvider.addListener(any())).thenReturn(null);
    when(() => mockAuthProvider.removeListener(any())).thenReturn(null);
  });

  Widget createWidget() {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: mockAuthProvider,
      child: const MaterialApp(
        locale: Locale('ca'),
        supportedLocales: [Locale('ca')],
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: RegisterScreen(),
      ),
    );
  }

  Future<void> fillValidForm(WidgetTester tester) async {
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Pau',
    );

    await tester.enterText(
      find.byType(TextFormField).at(1),
      'S',
    );

    await tester.enterText(
      find.byType(TextFormField).at(2),
      'pau_s',
    );

    await tester.enterText(
      find.byType(TextFormField).at(3),
      'test@test.com',
    );

    await tester.enterText(
      find.byType(TextFormField).at(4),
      '123456',
    );

    await tester.enterText(
      find.byType(TextFormField).at(5),
      '123456',
    );
  }

  group('RegisterScreen 100% Coverage', () {
    testWidgets('renderitza tots els widgets principals', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Crea el teu compte'), findsOneWidget);
      expect(find.text('Registrar-se'), findsOneWidget);

      expect(find.byType(TextFormField), findsNWidgets(6));
    });

    testWidgets('toggle visibilitat password', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byIcon(Icons.visibility_off_outlined), findsNWidgets(2));

      await tester.tap(
        find.byIcon(Icons.visibility_off_outlined).first,
      );

      await tester.pump();

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('validacions formulari', (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.tap(find.text('Registrar-se'));
      await tester.pump();

      expect(find.text('Aquest camp és obligatori'), findsWidgets);
    });

    testWidgets('email invàlid', (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.enterText(
        find.byType(TextFormField).at(3),
        'emaildolent',
      );

      await tester.tap(find.text('Registrar-se'));
      await tester.pump();

      expect(find.text('Correu electrònic no vàlid'), findsOneWidget);
    });

    testWidgets('password curta', (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.enterText(
        find.byType(TextFormField).at(4),
        '123',
      );

      await tester.tap(find.text('Registrar-se'));
      await tester.pump();

      expect(find.text('Mínim 6 caràcters'), findsOneWidget);
    });

    testWidgets('passwords diferents', (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.enterText(
        find.byType(TextFormField).at(4),
        '123456',
      );

      await tester.enterText(
        find.byType(TextFormField).at(5),
        '654321',
      );

      await tester.tap(find.text('Registrar-se'));
      await tester.pump();

      expect(find.text('Les contrasenyes no coincideixen'), findsOneWidget);
    });

    testWidgets('cancel·lar consentiment no registra', (tester) async {
      await tester.pumpWidget(createWidget());

      await fillValidForm(tester);

      await tester.tap(find.text('Registrar-se'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Denegar'));
      await tester.pumpAndSettle();

      verifyNever(() => mockAuthProvider.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
        nickname: any(named: 'nickname'),
        nom: any(named: 'nom'),
        cognom: any(named: 'cognom'),
      ));
    });

    testWidgets('Registre complet amb èxit', (tester) async {
      when(() => mockAuthProvider.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
        nickname: any(named: 'nickname'),
        nom: any(named: 'nom'),
        cognom: any(named: 'cognom'),
      )).thenAnswer((_) async {});

      await tester.pumpWidget(createWidget());

      await fillValidForm(tester);

      await tester.tap(find.text('Registrar-se'));
      await tester.pumpAndSettle();

      expect(find.text('Consentiment de dades'), findsOneWidget);

      await tester.tap(find.text('Acceptar'));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      verify(() => mockAuthProvider.signUp(
        email: 'test@test.com',
        password: '123456',
        nickname: 'paus',
        nom: 'Pau',
        cognom: 'S',
      )).called(1);
    });

    testWidgets('Error EMAIL_EXISTS', (tester) async {
      when(() => mockAuthProvider.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
        nickname: any(named: 'nickname'),
        nom: any(named: 'nom'),
        cognom: any(named: 'cognom'),
      )).thenAnswer((_) async {
        throw 'EMAIL_EXISTS';
      });

      await tester.pumpWidget(createWidget());

      await fillValidForm(tester);

      await tester.tap(find.text('Registrar-se'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Acceptar'));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      verify(() => mockAuthProvider.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
        nickname: any(named: 'nickname'),
        nom: any(named: 'nom'),
        cognom: any(named: 'cognom'),
      )).called(1);

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('Error NICKNAME_TAKEN', (tester) async {
      when(() => mockAuthProvider.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
        nickname: any(named: 'nickname'),
        nom: any(named: 'nom'),
        cognom: any(named: 'cognom'),
      )).thenAnswer((_) async {
        throw 'NICKNAME_TAKEN';
      });

      await tester.pumpWidget(createWidget());

      await fillValidForm(tester);

      await tester.tap(find.text('Registrar-se'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Acceptar'));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('Error UNKNOWN', (tester) async {
      when(() => mockAuthProvider.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
        nickname: any(named: 'nickname'),
        nom: any(named: 'nom'),
        cognom: any(named: 'cognom'),
      )).thenAnswer((_) async {
        throw 'UNKNOWN';
      });

      await tester.pumpWidget(createWidget());

      await fillValidForm(tester);

      await tester.tap(find.text('Registrar-se'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Acceptar'));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('Error genèric', (tester) async {
      when(() => mockAuthProvider.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
        nickname: any(named: 'nickname'),
        nom: any(named: 'nom'),
        cognom: any(named: 'cognom'),
      )).thenAnswer((_) async {
        throw Exception('DB FAIL');
      });

      await tester.pumpWidget(createWidget());

      await fillValidForm(tester);

      await tester.tap(find.text('Registrar-se'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Acceptar'));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('dispose coverage', (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('dispose'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('dispose'), findsOneWidget);
    });
  });
}