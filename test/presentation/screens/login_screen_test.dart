import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:Constancy/presentation/screens/login_screen.dart';
import 'package:Constancy/presentation/providers/auth_provider.dart';
import 'package:Constancy/generated/l10n.dart';

class MockAuthProvider extends Mock implements AuthProvider {}

void main() {
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
      ],
      child: const MaterialApp(
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('ca')],
        home: LoginScreen(),
      ),
    );
  }

  void setGiantScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('LoginScreen 100% Coverage', () {

    testWidgets('Validació: camps obligatoris', (tester) async {
      setGiantScreen(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      expect(find.text('Aquest camp és obligatori'), findsWidgets);
    });

    testWidgets('Toggle visibilitat contrasenya canvia icona', (tester) async {
      setGiantScreen(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('Login èxit', (tester) async {
      when(() => mockAuthProvider.signIn(any(), any())).thenAnswer((_) async => {});

      setGiantScreen(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('email_field')), 'test@test.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      verify(() => mockAuthProvider.signIn('test@test.com', 'password123')).called(1);
    });

    testWidgets('Login error mostra SnackBar', (tester) async {
      when(() => mockAuthProvider.signIn(any(), any())).thenThrow(Exception('Fail'));

      setGiantScreen(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('email_field')), 'test@test.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('Forgot Password: Èxit', (tester) async {
      when(() => mockAuthProvider.checkEmailExists('test@test.com')).thenAnswer((_) async => true);
      when(() => mockAuthProvider.sendPasswordResetEmail('test@test.com')).thenAnswer((_) async => {});

      setGiantScreen(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Heu oblidat la contrasenya?'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).last, 'test@test.com');
      await tester.tap(find.text('Enviar enllaç de recuperació'));
      await tester.pumpAndSettle();

      verify(() => mockAuthProvider.sendPasswordResetEmail('test@test.com')).called(1);
    });
  });
}