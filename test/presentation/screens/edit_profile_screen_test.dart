import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:Constancy/presentation/screens/edit_profile_screen.dart';
import 'package:Constancy/presentation/providers/auth_provider.dart';
import 'package:Constancy/domain/models/user_model.dart';
import 'package:Constancy/generated/l10n.dart';

class MockAuthProvider extends Mock implements AuthProvider {}

void main() {
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();

    final user = UserModel(
      id: 'u1',
      nickname: 'pau',
      nom: 'Pau',
      cognom: 'S',
      correu: 'test@test.com',
      dataRegistre: DateTime.now(),
    );
    when(() => mockAuthProvider.currentUser).thenReturn(user);

    registerFallbackValue(File('dummy.png'));
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
        home: EditProfileScreen(),
      ),
    );
  }

  group('EditProfileScreen UI Tests', () {
    testWidgets('Validació: omplir camps i guardar', (tester) async {
      when(() => mockAuthProvider.updateProfile(
          nom: any(named: 'nom'),
          cognom: any(named: 'cognom'),
          imageFile: any(named: 'imageFile')
      )).thenAnswer((_) async => {});

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(1), 'NouNom');
      await tester.enterText(find.byType(TextFormField).at(2), 'NouCognom');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      verify(() => mockAuthProvider.updateProfile(nom: 'NouNom', cognom: 'NouCognom', imageFile: null)).called(1);
    });

    testWidgets('Error en desar mostra SnackBar vermell', (tester) async {
      when(() => mockAuthProvider.updateProfile(
          nom: any(named: 'nom'),
          cognom: any(named: 'cognom'),
          imageFile: any(named: 'imageFile')
      )).thenThrow(Exception('Error DB'));

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, Colors.red);
    });

    testWidgets('Camps buits no envien dades', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(1), '');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      verifyNever(() => mockAuthProvider.updateProfile(nom: any(named: 'nom'), cognom: any(named: 'cognom'), imageFile: any(named: 'imageFile')));
    });
  });
}