import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:Constancy/presentation/screens/habit_detail_screen.dart';
import 'package:Constancy/presentation/providers/habit_provider.dart';
import 'package:Constancy/presentation/providers/auth_provider.dart';
import 'package:Constancy/presentation/providers/social_provider.dart';
import 'package:Constancy/domain/models/habit_model.dart';
import 'package:Constancy/domain/models/user_model.dart';
import 'package:Constancy/domain/models/habit_group_member_model.dart';
import 'package:Constancy/generated/l10n.dart';

class MockHabitProvider extends Mock implements HabitProvider {}
class MockAuthProvider extends Mock implements AuthProvider {}
class MockSocialProvider extends Mock implements SocialProvider {}

void main() {
  late MockHabitProvider mockHabitProvider;
  late MockAuthProvider mockAuthProvider;
  late MockSocialProvider mockSocialProvider;

  final tHabit = HabitModel(
    id: 'h1', userId: 'u1', titol: 'Hàbit Test', icona: 'star', color: '#000000',
    dataInici: DateTime.now(), createdAt: DateTime.now(), isGroup: true,
    valorObjectiu: 10.0, unitatMesura: UnitatMesura.vegades,
  );

  setUp(() {
    mockHabitProvider = MockHabitProvider();
    mockAuthProvider = MockAuthProvider();
    mockSocialProvider = MockSocialProvider();

    when(() => mockHabitProvider.habits).thenReturn([tHabit]);
    when(() => mockHabitProvider.dailyRecords).thenReturn({});
    when(() => mockHabitProvider.currentGroupMembers).thenReturn([
      HabitGroupMember(userId: 'u1', nickname: 'Pau', progresAcumulat: 5, progresAvui: 1, esAdministrador: true)
    ]);
    when(() => mockHabitProvider.selectedDate).thenReturn(DateTime.now());
    when(() => mockHabitProvider.currentGroupTotalProgress).thenReturn(0.0);
    when(() => mockHabitProvider.isLoading).thenReturn(false);
    when(() => mockHabitProvider.currentInviteCode).thenReturn('ABC123');

    when(() => mockHabitProvider.loadGroupDetails('h1')).thenAnswer((_) async => {});
    when(() => mockHabitProvider.listenToGroupChanges('h1')).thenAnswer((_) {});
    when(() => mockHabitProvider.stopListeningToGroupChanges()).thenAnswer((_) {});

    final user = UserModel(id: 'u1', nickname: 'pau', nom: 'Pau', cognom: 'S', correu: 'a@a.com', dataRegistre: DateTime.now());
    when(() => mockAuthProvider.currentUser).thenReturn(user);

    registerFallbackValue(tHabit);
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<HabitProvider>.value(value: mockHabitProvider),
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
        ChangeNotifierProvider<SocialProvider>.value(value: mockSocialProvider),
      ],
      child: const MaterialApp(
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('ca')],
        home: HabitDetailScreen(habitId: 'h1'),
      ),
    );
  }

  group('HabitDetailScreen 100% Coverage', () {

    testWidgets('Renderitza UI i grup', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.text('Hàbit Test'), findsOneWidget);
    });

    testWidgets('Menu accions: Eliminar Admin', (tester) async {
      when(() => mockHabitProvider.deleteHabit('h1')).thenAnswer((_) async => {});

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('Eliminar').last);
      await tester.pumpAndSettle();
      verify(() => mockHabitProvider.deleteHabit('h1')).called(1);
    });

    testWidgets('Modals de comentari i progrés', (tester) async {
      when(() => mockHabitProvider.updateComment(habitId: 'h1', comentari: 'Bon test')).thenAnswer((_) async => {});

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit_note_rounded));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Bon test');

      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();
      verify(() => mockHabitProvider.updateComment(habitId: 'h1', comentari: 'Bon test')).called(1);
    });
  });
}