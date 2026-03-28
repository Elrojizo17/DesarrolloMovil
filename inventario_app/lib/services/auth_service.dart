import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _auth = Supabase.instance.client.auth;

  Future<void> registrar(String email, String password) async {
    await _auth.signUp(email: email, password: password);
  }

  Future<void> login(String email, String password) async {
    await _auth.signInWithPassword(email: email, password: password);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get usuarioActual => _auth.currentUser;

  Stream<AuthState> get sesionStream => _auth.onAuthStateChange;
}