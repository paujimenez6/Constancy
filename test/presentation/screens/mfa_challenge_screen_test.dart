import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:Constancy/presentation/screens/mfa_challenge_screen.dart';
import 'package:Constancy/presentation/providers/auth_provider.dart';
import 'package:Constancy/generated/l10n.dart';

class MockAuthProvider extends Mock implements AuthProvider {}

void main() {
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    registerFallbackValue('123456');
  });

  Widget createTestWidget() {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: mockAuthProvider,
      child: const MaterialApp(
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('ca')],
        home: MfaChallengeScreen(),
      ),
    );
  }

  group('MfaChallengeScreen Tests', () {
    testWidgets('UI renderitza correctament', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.vpn_key_rounded), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('No crida authProvider si el codi té menys de 6 caràcters', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextField), '123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      verifyNever(() => mockAuthProvider.loginMFAChallenge(any()));
    });

    testWidgets('Mostra error si el login falla', (tester) async {
      when(() => mockAuthProvider.loginMFAChallenge(any()))
          .thenThrow(Exception('Error'));

      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextField), '123456');
      await tester.tap(find.byType(ElevatedButton));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();

      expect(find.text('Codi incorrecte o caducat'), findsOneWidget);
    });

    testWidgets('Cancel·lar tanca sessió', (tester) async {
      when(() => mockAuthProvider.signOut()).thenAnswer((_) async => {});

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Cancel·lar'));
      await tester.pumpAndSettle();

      verify(() => mockAuthProvider.signOut()).called(1);
    });
  });
}