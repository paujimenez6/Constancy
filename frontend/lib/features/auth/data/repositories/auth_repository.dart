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
      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final String? userId = res.user?.id;

      if (userId != null) {
        await _supabase.from('profiles').insert({
          'id': userId,
          'nickname': nickname,
          'nom': nom,
          'cognom': cognom,
          'correu': email,
          'punts_xp': 0,
          'nivell_xp': 1,
          'monedes': 0,
          'data_registre': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      throw Exception('Error en el registre: $e');
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

