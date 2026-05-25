import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:Constancy/domain/services/auth_service.dart';
import 'package:Constancy/persistence/repositories/auth_repository.dart';
import 'package:Constancy/domain/models/user_model.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockFile extends Mock implements File {}

void main() {
  setUpAll(() {
    registerFallbackValue(TipusPrivacitat.public);
  });

  late AuthService service;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    service = AuthService(mockRepository);
  });

  group('AuthService Test - 100% Coverage', () {
    final tUser = UserModel(
        id: '1',
        nickname: 'Pau',
        nom: 'Pau',
        cognom: 'J',
        correu: 'a@a.com',
        dataRegistre: DateTime.now()
    );

    test('Tots els mètodes de l\'AuthService funcionen correctament', () async {
      when(() => mockRepository.signIn(any(), any())).thenAnswer((_) async => tUser);
      when(() => mockRepository.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          nickname: any(named: 'nickname'),
          nom: any(named: 'nom'),
          cognom: any(named: 'cognom')
      )).thenAnswer((_) async {});
      when(() => mockRepository.signOut()).thenAnswer((_) async {});
      when(() => mockRepository.listenToProfile(any())).thenAnswer((_) => Stream.value(tUser));
      when(() => mockRepository.updateProfile(
          userId: any(named: 'userId'),
          nom: any(named: 'nom'),
          cognom: any(named: 'cognom'),
          imageFile: any(named: 'imageFile'),
          currentImageUrl: any(named: 'currentImageUrl')
      )).thenAnswer((_) async {return null;});
      when(() => mockRepository.getUserProfile(any())).thenAnswer((_) async => tUser);
      when(() => mockRepository.updatePrivacy(any(), any())).thenAnswer((_) async {});
      when(() => mockRepository.updateUserDeviceToken(any(), any())).thenAnswer((_) async {});
      when(() => mockRepository.updateUserLocale(any(), any())).thenAnswer((_) async {});
      when(() => mockRepository.checkEmailExists(any())).thenAnswer((_) async => true);
      when(() => mockRepository.sendPasswordResetEmail(any())).thenAnswer((_) async {});
      when(() => mockRepository.updatePassword(any())).thenAnswer((_) async {});
      when(() => mockRepository.isMFAEnabled()).thenAnswer((_) async => true);
      when(() => mockRepository.enrollMFA()).thenAnswer((_) async => {});
      when(() => mockRepository.verifyMFA(any(), any())).thenAnswer((_) async {});
      when(() => mockRepository.getMFAFactorId()).thenAnswer((_) async => 'factor1');
      when(() => mockRepository.unenrollMFA(any())).thenAnswer((_) async {});
      when(() => mockRepository.loginMFAChallenge(any())).thenAnswer((_) async {});
      when(() => mockRepository.deleteAccount()).thenAnswer((_) async {});

      await service.signIn('a@a.com', '123456');
      await service.signUp(email: 'a@a.com', password: '123', nickname: 'n', nom: 'n', cognom: 'c');
      await service.signOut();
      service.listenToProfile('1');
      await service.updateFullProfile(userId: '1', nom: 'n', cognom: 'c');
      await service.updateUserPrivacy('1', TipusPrivacitat.public);
      await service.updateDeviceToken('1', 'tok');
      await service.updateUserLocale('1', 'ca');
      await service.checkEmailExists('a@a.com');
      await service.sendPasswordResetEmail('a@a.com');
      await service.updatePassword('new');
      await service.isMFAEnabled();
      await service.enrollMFA();
      await service.verifyMFA('f1', '123');
      await service.getMFAFactorId();
      await service.unenrollMFA('f1');
      await service.loginMFAChallenge('123');
      await service.deleteAccount();

      verify(() => mockRepository.signIn('a@a.com', '123456')).called(1);
      verify(() => mockRepository.signUp(email: 'a@a.com', password: '123', nickname: 'n', nom: 'n', cognom: 'c')).called(1);
      verify(() => mockRepository.signOut()).called(1);
      verify(() => mockRepository.listenToProfile('1')).called(1);
      verify(() => mockRepository.updateProfile(userId: '1', nom: 'n', cognom: 'c')).called(1);
      verify(() => mockRepository.updatePrivacy('1', TipusPrivacitat.public)).called(1);
      verify(() => mockRepository.updateUserDeviceToken('1', 'tok')).called(1);
      verify(() => mockRepository.updateUserLocale('1', 'ca')).called(1);
      verify(() => mockRepository.checkEmailExists('a@a.com')).called(1);
      verify(() => mockRepository.sendPasswordResetEmail('a@a.com')).called(1);
      verify(() => mockRepository.updatePassword('new')).called(1);
      verify(() => mockRepository.isMFAEnabled()).called(1);
      verify(() => mockRepository.enrollMFA()).called(1);
      verify(() => mockRepository.verifyMFA('f1', '123')).called(1);
      verify(() => mockRepository.getMFAFactorId()).called(1);
      verify(() => mockRepository.unenrollMFA('f1')).called(1);
      verify(() => mockRepository.loginMFAChallenge('123')).called(1);
      verify(() => mockRepository.deleteAccount()).called(1);
    });
  });
}