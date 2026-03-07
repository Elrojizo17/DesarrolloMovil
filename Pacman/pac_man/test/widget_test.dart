import 'package:flutter_test/flutter_test.dart';

import 'package:pacman_game/main.dart';  // importa tu main.dart

void main() {
  testWidgets('Smoke test: la app se carga sin errores', (WidgetTester tester) async {
    // Construye la app completa
    await tester.pumpWidget(const PacmanApp());

    // Verifica que elementos clave de tu juego aparezcan
    expect(find.text('Score: 0'), findsOneWidget);           // El score inicial
    expect(find.text('Usa las flechas del teclado para mover a Pac-Man'), findsOneWidget);
    expect(find.text('🎮 Jugando...'), findsOneWidget);     // Estado inicial

    // Opcional: verifica que no haya texto del contador viejo
    expect(find.text('0'), findsNothing);  // ya no debería haber un '0' suelto
  });
}