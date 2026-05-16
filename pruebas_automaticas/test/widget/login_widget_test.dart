import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pruebas_automaticas/lib/widgets/login_form.dart';

void main() {
  group('Pruebas del LoginForm', () {
    testWidgets('El widget debe mostrar los campos y el botón', (tester) async {
      // Construir el widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: LoginForm(onLogin: (email, pass) {})),
        ),
      );

      // Verificar que los elementos existen
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Ingresar'), findsOneWidget);
    });

    testWidgets('Al presionar botón se llama a onLogin', (tester) async {
      bool llamadaRealizada = false;
      String emailCapturado = '';
      String passCapturado = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoginForm(
              onLogin: (email, pass) {
                llamadaRealizada = true;
                emailCapturado = email;
                passCapturado = pass;
              },
            ),
          ),
        ),
      );

      // Escribir en el campo de email
      await tester.enterText(find.byType(TextField).first, 'test@mail.com');

      // Escribir en el campo de contraseña
      await tester.enterText(find.byType(TextField).last, 'secreto123');

      // Presionar el botón
      await tester.tap(find.text('Ingresar'));

      // Esperar a que termine la animación
      await tester.pump();

      // Verificar
      expect(llamadaRealizada, true);
      expect(emailCapturado, 'test@mail.com');
      expect(passCapturado, 'secreto123');
    });
  });
}
