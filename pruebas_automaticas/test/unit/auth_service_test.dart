import 'package:flutter_test/flutter_test.dart';
import 'package:pruebas_automaticas/services/auth_service.dart';

void main() {
  // Grupo de pruebas (opcional, pero ordena mejor)
  group('Pruebas de AuthService', () {
    test('Login correcto debe retornar true', () {
      final auth = AuthService();
      final resultado = auth.login('user@escuela.edu', '123456');
      expect(resultado, true);
    });

    test('Login con email vacío debe retornar false', () {
      final auth = AuthService();
      final resultado = auth.login('', '123456');
      expect(resultado, false);
    });

    test('Login con contraseña vacía debe retornar false', () {
      final auth = AuthService();
      final resultado = auth.login('user@escuela.edu', '');
      expect(resultado, false);
    });

    test('Login con credenciales incorrectas debe retornar false', () {
      final auth = AuthService();
      final resultado = auth.login('mal@escuela.edu', 'xxxx');
      expect(resultado, false);
    });
  });
}
