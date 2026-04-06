import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> signUp({
    required String email,
    required String password,
    required String nickname,
    required String nom,
    required String cognom,
  }) async {
    try {

      final existingNickname = await _supabase
          .from('profiles')
          .select('nickname')
          .eq('nickname', nickname)
          .maybeSingle();

      if (existingNickname != null) throw 'NICKNAME_TAKEN';

      await _supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'io.supabase.constancy://login-callback',
        data: {
          'nickname': nickname,
          'nom': nom,
          'cognom': cognom,
        },
      );

    } on AuthException catch (e) {
      if (e.code == 'user_already_exists') throw 'EMAIL_EXISTS';
      throw e.message;
    } catch (e) {
      if (e == 'NICKNAME_TAKEN') rethrow;
      debugPrint("Error: $e");
      throw 'UNKNOWN';
    }
  }

  Future<UserModel> signIn(String email, String password) async {
    try {
      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user == null) throw Exception('Usuari no trobat');

      final Map<String, dynamic> data = await _supabase
          .from('profiles')
          .select()
          .eq('id', res.user!.id)
          .single();

      data['token'] = res.session?.accessToken;

      return UserModel.fromJson(data);
    } catch (e) {
      throw Exception('Error en l\'inici de sessió: $e');
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}

