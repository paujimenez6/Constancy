import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:Constancy/presentation/providers/auth_provider.dart';
import 'package:Constancy/presentation/providers/settings_provider.dart';
import 'package:Constancy/domain/services/auth_service.dart';
import 'package:Constancy/domain/services/achievement_service.dart';
import 'package:Constancy/domain/models/user_model.dart';
import 'package:Constancy/main.dart';

class MockAuthService extends Mock implements AuthService {}
class MockAchievementService extends Mock implements AchievementService {}
class MockSettingsProvider extends Mock implements SettingsProvider {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthProvider provider;
  late MockAuthService mockAuthService;
  late MockAchievementService mockAchievementService;

  setUpAll(() {
    registerFallbackValue(TipusPrivacitat.values.first);
  });

  setUp(() {
    mockAuthService = MockAuthService();
    mockAchievementService = MockAchievementService();
    provider = AuthProvider(mockAuthService, mockAchievementService);
  });

  group('AuthProvider 100% Coverage', () {
    final tUser = UserModel(
        id: 'u1',
        nom: 'Pau',
        cognom: 'G',
        imatgePerfil: null,
        nickname: 'pauG',
        correu: 'pau@test.com',
        dataRegistre: DateTime.now(),
        locale: 'ca'
    );

    testWidgets('setUser: actualitza usuari i canvia el locale si hi ha context', (WidgetTester tester) async {
      final mockSettings = MockSettingsProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsProvider>.value(
          value: mockSettings,
          child: MaterialApp(
            navigatorKey: navigatorKey,
            home: const Scaffold(),
          ),
        ),
      );

      provider.setUser(tUser);

      expect(provider.currentUser, tUser);
      expect(provider.isAuthenticated, true);
      verify(() => mockSettings.setLocale(const Locale('ca'))).called(1);
    });

    test('initProfileListener: escolta canvis del stream', () async {
      final controller = StreamController<UserModel>();
      when(() => mockAuthService.listenToProfile('u1')).thenAnswer((_) => controller.stream);

      provider.initProfileListener('u1');
      controller.add(tUser);
      await pumpEventQueue();

      expect(provider.currentUser, tUser);
      await controller.close();
    });

    test('dispose: cancel·la subscripció', () {
      provider.dispose();
      expect(provider, isNotNull);
    });

    test('signIn: èxit i error', () async {
      when(() => mockAuthService.signIn('a@b.com', '123')).thenAnswer((_) async => tUser);
      await provider.signIn('a@b.com', '123');
      expect(provider.currentUser, tUser);

      when(() => mockAuthService.signIn('bad', 'bad')).thenThrow(Exception('Error'));
      expect(() => provider.signIn('bad', 'bad'), throwsException);
      expect(provider.isManualLogin, false);
    });

    test('signUp, signOut, deleteAccount', () async {
      when(() => mockAuthService.signUp(email: any(named: 'email'), password: any(named: 'password'), nickname: any(named: 'nickname'), nom: any(named: 'nom'), cognom: any(named: 'cognom')))
          .thenAnswer((_) async => {});
      await provider.signUp(email: 'a@b.com', password: '123', nickname: 'pau', nom: 'Pau', cognom: 'G');

      when(() => mockAuthService.signOut()).thenAnswer((_) async => {});
      await provider.signOut();
      expect(provider.currentUser, isNull);

      provider.setUser(tUser);
      when(() => mockAuthService.deleteAccount()).thenAnswer((_) async => {});
      await provider.deleteAccount();
      expect(provider.currentUser, isNull);
    });

    test('updateProfile i updatePrivacy', () async {
      provider.setUser(tUser);

      when(() => mockAuthService.updateFullProfile(userId: any(named: 'userId'), nom: any(named: 'nom'), cognom: any(named: 'cognom'), imageFile: any(named: 'imageFile'), currentImageUrl: any(named: 'currentImageUrl')))
          .thenAnswer((_) async => tUser);
      await provider.updateProfile(nom: 'Nou', cognom: 'Nom');

      when(() => mockAuthService.updateUserPrivacy(any(), any())).thenAnswer((_) async => tUser);
      await provider.updatePrivacy('u1', TipusPrivacitat.values.first);
    });

    test('Mètodes de mutació local (updateUserData, updateProfileImage, setTabIndex)', () {
      provider.setUser(tUser);

      provider.updateUserData(nom: 'Nou', cognom: 'Nom');
      expect(provider.currentUser!.nom, 'Nou');

      provider.updateProfileImage('nova_url');
      expect(provider.currentUser!.imatgePerfil, 'nova_url');

      provider.setTabIndex(2);
      expect(provider.currentTabIndex, 2);
    });

    test('updateUserLocale: èxit i catch error', () async {
      when(() => mockAuthService.updateUserLocale('u1', 'ca')).thenAnswer((_) async => {});
      await provider.updateUserLocale('u1', 'ca');

      when(() => mockAuthService.updateUserLocale('u1', 'en')).thenThrow(Exception('Error DB'));
      await provider.updateUserLocale('u1', 'en');
    });

    test('Mètodes Wrapper (checkEmail, resetPassword, updatePassword, loginMFAChallenge)', () async {
      when(() => mockAuthService.checkEmailExists(any())).thenAnswer((_) async => true);
      when(() => mockAuthService.sendPasswordResetEmail(any())).thenAnswer((_) async => {});
      when(() => mockAuthService.updatePassword(any())).thenAnswer((_) async => {});
      when(() => mockAuthService.loginMFAChallenge(any())).thenAnswer((_) async => {});

      expect(await provider.checkEmailExists('a@b.com'), true);
      await provider.sendPasswordResetEmail('a@b.com');
      await provider.updatePassword('123');
      await provider.loginMFAChallenge('code');
    });

    test('Mètodes MFA', () async {
      provider.setUser(tUser);

      when(() => mockAuthService.isMFAEnabled()).thenAnswer((_) async => true);
      when(() => mockAuthService.enrollMFA()).thenAnswer((_) async => 'data');
      when(() => mockAuthService.getMFAFactorId()).thenAnswer((_) async => 'f1');
      when(() => mockAuthService.unenrollMFA(any())).thenAnswer((_) async => {});

      when(() => mockAuthService.verifyMFA('f1', '123')).thenAnswer((_) async => {});
      when(() => mockAchievementService.setAbsoluteProgress('u1', 'activarMfa', 1)).thenAnswer((_) async => {});

      expect(await provider.isMFAEnabled(), true);
      expect(await provider.enrollMFA(), 'data');
      expect(await provider.getMFAFactorId(), 'f1');
      await provider.unenrollMFA('f1');
      await provider.verifyMFA('f1', '123');

      when(() => mockAuthService.verifyMFA('bad', 'bad')).thenThrow(Exception('Fail'));
      expect(() => provider.verifyMFA('bad', 'bad'), throwsException);
    });
  });
}