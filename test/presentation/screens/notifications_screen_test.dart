import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:Constancy/presentation/screens/notifications_screen.dart';
import 'package:Constancy/presentation/providers/auth_provider.dart';
import 'package:Constancy/presentation/providers/social_provider.dart';
import 'package:Constancy/domain/models/user_model.dart';
import 'package:Constancy/generated/l10n.dart';

class MockAuthProvider extends Mock implements AuthProvider {}
class MockSocialProvider extends Mock implements SocialProvider {}

void main() {
  late MockAuthProvider mockAuthProvider;
  late MockSocialProvider mockSocialProvider;

  setUpAll(() {
    registerFallbackValue('u1');
    registerFallbackValue({'id': 'u2'});
  });

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockSocialProvider = MockSocialProvider();

    final user = UserModel(
      id: 'u1', nickname: 'pau', nom: 'Pau', cognom: 'S',
      correu: 'test@test.com', dataRegistre: DateTime.now(),
    );

    when(() => mockAuthProvider.currentUser).thenReturn(user);
    when(() => mockSocialProvider.getPendingRequests()).thenAnswer((_) async => []);
    when(() => mockSocialProvider.getFollowNotifications()).thenAnswer((_) async => []);
    when(() => mockSocialProvider.markNotificationsAsRead()).thenAnswer((_) async => {});
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
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
        home: NotificationsScreen(),
      ),
    );
  }

  testWidgets('Renderitza sol·licituds i notificacions', (tester) async {
    final mockProfile = {'id': 'u2', 'nickname': 'TestUser', 'imatge_perfil': null};

    when(() => mockSocialProvider.getPendingRequests()).thenAnswer((_) async => [
      {'id': 'req1', 'sender_id': 'u2', 'profiles': mockProfile}
    ]);
    when(() => mockSocialProvider.getFollowNotifications()).thenAnswer((_) async => [
      {'type': 'new_follower', 'created_at': DateTime.now().toIso8601String(), 'profiles': mockProfile}
    ]);
    when(() => mockSocialProvider.getFollowStatus(any())).thenAnswer((_) async => {'isFollowing': false, 'isPending': false});

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsWidgets);
    expect(find.text('TestUser'), findsWidgets);
    expect(find.widgetWithText(ElevatedButton, 'Acceptar'), findsOneWidget);
  });
}