import 'package:flutter/material.dart';

import '../models/game_save.dart';
import '../notification_service.dart';
import '../services/game_session_service.dart';
import 'game_screen.dart';

// ============================================
// PANTALLA DE INICIO (Zona Pública)
// ============================================

class HomePublicScreen extends StatefulWidget {
  const HomePublicScreen({super.key});

  @override
  State<HomePublicScreen> createState() => _HomePublicScreenState();
}

class _HomePublicScreenState extends State<HomePublicScreen> {
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange[800],
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _nuevaPartida() {
    _showSuccessSnackBar('Crea o inicia sesion para comenzar una nueva partida');
    Navigator.pushNamed(context, '/login');
  }

  Future<void> _continuarPartida() async {
    final email = await GameSessionService.getLoggedUser();
    if (email == null || email.isEmpty) {
      if (!mounted) return;
      _showWarningSnackBar('No hay sesion activa para continuar una partida.');
      return;
    }

    final save = await GameSessionService.loadSavedGameForUser(email);
    if (save == null) {
      if (!mounted) return;
      _showWarningSnackBar('No se encontro una partida guardada para $email.');
      return;
    }

    if (!mounted) return;
    _showSuccessSnackBar('Partida restaurada correctamente');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(
          initialSave: save,
          userEmail: email,
        ),
      ),
    );
  }

  Future<void> _modoVisitante() async {
    _showWarningSnackBar('Modo Visitante: Puedes jugar hasta Nivel 5');
    final guestSave = GameSave.newGame();
    await GameSessionService.clearLoggedUser();
    await GameSessionService.saveGuestGame(guestSave);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(
          initialSave: guestSave,
          isGuestMode: true,
        ),
      ),
    );
  }

  Future<void> _probarNotificacion() async {
    final ok = await NotificationService.instance.sendTestNotificationNow();
    if (!ok) {
      if (!mounted) return;
      _showSnackBar(
        'Permiso de notificaciones denegado.',
        Colors.red[700]!,
      );
      return;
    }

    await NotificationService.instance.cancelLifeAvailableNotification();
    await NotificationService.instance.scheduleLifeAvailableNotification(
      delay: const Duration(seconds: 5),
    );
    _showSnackBar(
      'Notificacion enviada (se repite en 5s).',
      Colors.blue[700]!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.restaurant, size: 100, color: Colors.deepOrange[700]),
                const SizedBox(height: 16),
                Text(
                  'Paleto Knive',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange[900],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Zona Pública (Sin sesión)',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _nuevaPartida,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline),
                        SizedBox(width: 8),
                        Text(
                          'Nueva Partida',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _continuarPartida,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_circle_outline),
                        SizedBox(width: 8),
                        Text(
                          'Continuar Partida',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _modoVisitante,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_outline),
                        SizedBox(width: 8),
                        Text(
                          'Modo Visitante',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login),
                        SizedBox(width: 8),
                        Text(
                          'Iniciar Sesión',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _probarNotificacion,
                    icon: const Icon(Icons.notifications_active_outlined),
                    label: const Text(
                      'Probar Notificacion (5s)',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.deepOrange[800],
                      side: BorderSide(color: Colors.deepOrange[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
