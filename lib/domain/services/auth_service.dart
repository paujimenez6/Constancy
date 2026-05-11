import 'dart:io';
import '../../domain/models/user_model.dart';
import '../../persistence/repositories/auth_repository.dart';

class AuthService {
  final AuthRepository _authRepository;

  AuthService(this._authRepository);

  Future<UserModel> signIn(String email, String password) async {
    return await _authRepository.signIn(email, password);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String nickname,
    required String nom,
    required String cognom,
  }) async {
    await _authRepository.signUp(
      email: email,
      password: password,
      nickname: nickname,
      nom: nom,
      cognom: cognom,
    );
  }

  Future<void> signOut() => _authRepository.signOut();

  Stream<UserModel> listenToProfile(String userId) {
    return _authRepository.listenToProfile(userId);
  }

  Future<UserModel> updateFullProfile({
    required String userId,
    required String nom,
    required String cognom,
    File? imageFile,
    String? currentImageUrl,
  }) async {
    await _authRepository.updateProfile(
      userId: userId,
      nom: nom,
      cognom: cognom,
      imageFile: imageFile,
      currentImageUrl: currentImageUrl,
    );

    return await _authRepository.getUserProfile(userId);
  }

  Future<UserModel> updateUserPrivacy(String userId, TipusPrivacitat privacy) async {
    await _authRepository.updatePrivacy(userId, privacy);
    return await _authRepository.getUserProfile(userId);
  }

  Future<bool> checkEmailExists(String email) => _authRepository.checkEmailExists(email);

  Future<void> sendPasswordResetEmail(String email) => _authRepository.sendPasswordResetEmail(email);

  Future<void> updatePassword(String newPassword) => _authRepository.updatePassword(newPassword);

  Future<bool> isMFAEnabled() => _authRepository.isMFAEnabled();

  Future<dynamic> enrollMFA() => _authRepository.enrollMFA();

  Future<void> verifyMFA(String factorId, String code) => _authRepository.verifyMFA(factorId, code);

  Future<String?> getMFAFactorId() => _authRepository.getMFAFactorId();

  Future<void> unenrollMFA(String factorId) => _authRepository.unenrollMFA(factorId);

  Future<void> loginMFAChallenge(String code) => _authRepository.loginMFAChallenge(code);

  Future<void> deleteAccount() => _authRepository.deleteAccount();
}