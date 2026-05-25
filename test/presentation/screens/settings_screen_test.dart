import 'package:Constancy/domain/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:Constancy/generated/l10n.dart';
import 'package:Constancy/presentation/providers/auth_provider.dart';
import 'package:Constancy/presentation/providers/settings_provider.dart';
import 'package:Constancy/presentation/screens/settings_screen.dart';

class MockAuthProvider extends Mock implements AuthProvider {}

class FakeUser extends Fake implements UserModel {}

class MockTotp extends Mock {
  String get secret => 'ABC123';
}

class MockEnrollData extends Mock {
  String get id => 'factor-id';
  MockTotp get totp => MockTotp();
}

void main() {
  late MockAuthProvider authProvider;
  late SettingsProvider settingsProvider;

  final user = UserModel(
    id: '1',
    nickname: 'nick',
    nom: 'Nom',
    cognom: 'Cog',
    correu: 'mail@test.com',
    dataRegistre: DateTime.now(),
  );

  setUpAll(() {
    registerFallbackValue(FakeUser());

    registerFallbackValue(
      TipusPrivacitat.public,
    );
  });

  setUp(() {
    authProvider = MockAuthProvider();
    settingsProvider = SettingsProvider();

    when(() => authProvider.currentUser)
        .thenReturn(user);

    when(() => authProvider.isMFAEnabled())
        .thenAnswer((_) async => false);

    when(
          () => authProvider.updateUserLocale(
        any<String>(),
        any<String>(),
      ),
    ).thenAnswer((_) async {});

    when(
          () => authProvider.updatePrivacy(
        any<String>(),
        any<TipusPrivacitat>(),
      ),
    ).thenAnswer((_) async {});

    when(() => authProvider.deleteAccount())
        .thenAnswer((_) async {});

    when(() => authProvider.getMFAFactorId())
        .thenAnswer((_) async => 'factor-id');

    when(
          () => authProvider.unenrollMFA(
        any<String>(),
      ),
    ).thenAnswer((_) async {});

    when(
          () => authProvider.verifyMFA(
        any<String>(),
        any<String>(),
      ),
    ).thenAnswer((_) async {});

    when(() => authProvider.enrollMFA())
        .thenAnswer(
          (_) async => MockEnrollData(),
    );
  });

  Widget buildWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
        ),
        ChangeNotifierProvider<SettingsProvider>.value(
          value: settingsProvider,
        ),
      ],
      child: MaterialApp(
        navigatorKey: GlobalKey<NavigatorState>(),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ca'),
        ],
        home: const SettingsScreen(),
      ),
    );
  }

  testWidgets(
    'renders settings screen',
        (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);

      expect(
        find.byIcon(Icons.delete_outlined),
        findsOneWidget,
      );

      expect(
        find.byType(SwitchListTile),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'changes theme mode',
        (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(
        find.byType(
          DropdownButton<ThemeMode>,
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Fosc').last);

      await tester.pumpAndSettle();

      expect(
        settingsProvider.themeMode,
        ThemeMode.dark,
      );
    },
  );

  testWidgets(
    'changes language',
        (tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.pumpAndSettle();

      await tester.tap(
        find.byType(
          DropdownButton<String>,
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(
        find.text('Espanyol').last,
      );

      await tester.pumpAndSettle();

      verify(
            () => authProvider.updateUserLocale(
          '1',
          'es',
        ),
      ).called(1);
    },
  );

  testWidgets(
    'opens MFA enrollment dialog',
        (tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));

      await tester.pumpAndSettle();

      expect(find.text('ABC123'), findsOneWidget);
    },
  );

  testWidgets(
    'verifies MFA successfully',
        (tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));

      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        '123456',
      );

      await tester.tap(
        find.textContaining('Confirm'),
      );

      await tester.pumpAndSettle();

      verify(
            () => authProvider.verifyMFA(
          'factor-id',
          '123456',
        ),
      ).called(1);
    },
  );

  testWidgets(
    'handles MFA verify error',
        (tester) async {
      when(
            () => authProvider.verifyMFA(
          any<String>(),
          any<String>(),
        ),
      ).thenThrow(Exception());

      await tester.pumpWidget(buildWidget());

      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));

      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        '123456',
      );

      await tester.tap(
        find.textContaining('Confirm'),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    },
  );

  testWidgets(
    'disables MFA',
        (tester) async {
      when(() => authProvider.isMFAEnabled())
          .thenAnswer((_) async => true);

      await tester.pumpWidget(buildWidget());

      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));

      await tester.pumpAndSettle();

      await tester.tap(
        find.textContaining('Confirm'),
      );

      await tester.pumpAndSettle();

      verify(
            () => authProvider.unenrollMFA(
          'factor-id',
        ),
      ).called(1);
    },
  );

  testWidgets(
    'opens delete account dialog',
        (tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.pumpAndSettle();

      await tester.tap(
        find.byIcon(Icons.delete_outlined),
      );

      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsOneWidget);
    },
  );

  testWidgets(
    'deletes account',
        (tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.pumpAndSettle();

      await tester.tap(
        find.byIcon(Icons.delete_outlined),
      );

      await tester.pumpAndSettle();

      await tester.tap(
        find.textContaining('Confirm'),
      );

      await tester.pumpAndSettle();

      verify(
            () => authProvider.deleteAccount(),
      ).called(1);
    },
  );

  testWidgets(
    'shows loading if user is null',
        (tester) async {
      when(() => authProvider.currentUser)
          .thenReturn(null);

      await tester.pumpWidget(buildWidget());

      expect(
        find.byType(CircularProgressIndicator),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'handles enroll MFA exception',
        (tester) async {
      when(() => authProvider.enrollMFA())
          .thenThrow(Exception());

      await tester.pumpWidget(buildWidget());

      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));

      await tester.pumpAndSettle();

      verify(
            () => authProvider.enrollMFA(),
      ).called(1);
    },
  );

  testWidgets(
    'cancel button closes MFA dialog',
        (tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));

      await tester.pumpAndSettle();

      await tester.tap(
        find.textContaining('Cancel'),
      );

      await tester.pumpAndSettle();

      expect(
        find.byType(TextField),
        findsNothing,
      );
    },
  );
}