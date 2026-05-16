import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pruebas_automaticas/services/auth_service.dart';
import '../mocks/mock_definitions.mocks.dart';

void main() {
  group('Pruebas con Mockito', () {
    late MockAuthService mockAuth;

    setUp(() {
      mockAuth = MockAuthService();
    });

    test('Simular login exitoso', () {
      when(mockAuth.login('admin@mail.com', '123')).thenReturn(true);
      final resultado = mockAuth.login('admin@mail.com', '123');
      expect(resultado, true);
      verify(mockAuth.login('admin@mail.com', '123')).called(1);
    });

    test('Simular login fallido', () {
      when(mockAuth.login(any, any)).thenReturn(false);
      final resultado = mockAuth.login('cualquier', 'cosa');
      expect(resultado, false);
    });
  });
}
