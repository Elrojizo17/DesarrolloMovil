class AuthService {
  // Método síncrono: login
  bool login(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      return false;
    }
    return email == 'user@escuela.edu' && password == '123456';
  }

  // Método asíncrono: obtener rol
  Future<String> getRolUsuario(String email) async {
    await Future.delayed(Duration(milliseconds: 100));
    if (email == 'admin@escuela.edu') return 'administrador';
    if (email == 'user@escuela.edu') return 'estudiante';
    return 'invitado';
  }
}
