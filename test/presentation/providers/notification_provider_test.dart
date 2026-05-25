import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:Constancy/presentation/providers/notification_provider.dart';
import 'package:Constancy/presentation/providers/auth_provider.dart';
import 'package:Constancy/domain/services/notification_service.dart';
import 'package:Constancy/domain/services/auth_service.dart';
import 'package:Constancy/main.dart';

class MockNotificationService extends Mock implements NotificationService {}
class MockAuthService extends Mock implements AuthService {}
class MockAuthProvider extends Mock implements AuthProvider {}

void main() {
  late NotificationProvider provider;
  late MockNotificationService mockNotificationService;
  late MockAuthService mockAuthService;
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockNotificationService = MockNotificationService();
    mockAuthService = MockAuthService();
    mockAuthProvider = MockAuthProvider();
    provider = NotificationProvider(mockNotificationService, mockAuthService);
  });

  group('NotificationProvider 100% Coverage', () {

    test('initializeNotifications: test de tots els camins de permisos', () async {
      when(() => mockNotificationService.requestPermissions()).thenAnswer((_) async => true);
      when(() => mockNotificationService.getToken()).thenAnswer((_) async => 'token123');
      when(() => mockAuthService.updateDeviceToken('u1', 'token123')).thenAnswer((_) async => {});

      await provider.initializeNotifications('u1');
      verify(() => mockAuthService.updateDeviceToken('u1', 'token123')).called(1);

      when(() => mockNotificationService.getToken()).thenAnswer((_) async => null);
      await provider.initializeNotifications('u1');

      when(() => mockNotificationService.requestPermissions()).thenAnswer((_) async => false);
      await provider.initializeNotifications('u1');
    });

    testWidgets('setupListeners, navegació i InAppBanner logic', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
          ],
          child: MaterialApp(
            navigatorKey: navigatorKey,
            home: const Scaffold(body: Text('Home')),
            routes: {
              '/search': (_) => const Scaffold(body: Text('Search')),
              '/notifications': (_) => const Scaffold(body: Text('Notis')),
            },
          ),
        ),
      );

      when(() => mockNotificationService.initializeNotificationListeners(
        onMessageReceived: any(named: 'onMessageReceived'),
        onNotificationOpened: any(named: 'onNotificationOpened'),
      )).thenAnswer((_) {});

      provider.setupListeners();

      final captured = verify(() => mockNotificationService.initializeNotificationListeners(
        onMessageReceived: captureAny(named: 'onMessageReceived'),
        onNotificationOpened: captureAny(named: 'onNotificationOpened'),
      )).captured;

      final onMessageReceived = captured[0] as void Function(RemoteMessage);
      final onNotificationOpened = captured[1] as void Function(RemoteMessage);

      onNotificationOpened(const RemoteMessage(data: {'type': 'new_follower'}));

      onNotificationOpened(const RemoteMessage(data: {'type': 'league_end'}));

      when(() => mockAuthProvider.setTabIndex(0)).thenReturn(null);
      onNotificationOpened(const RemoteMessage(data: {'type': 'end_of_day'}));
      verify(() => mockAuthProvider.setTabIndex(0)).called(1);

      onNotificationOpened(const RemoteMessage(data: {'type': 'dummy'}));

      const msg = RemoteMessage(
        notification: RemoteNotification(title: 'TestTitle', body: 'TestBody'),
        data: {'type': 'dummy'},
      );

      onMessageReceived(msg);

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('TestTitle'), findsOneWidget);

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(find.text('TestTitle'), findsNothing);

      onMessageReceived(msg);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('TestTitle'));
      await tester.pumpAndSettle();

      expect(find.text('TestTitle'), findsNothing);
    });
  });
}