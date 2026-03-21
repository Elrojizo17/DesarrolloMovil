import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

const String syncTaskName = 'syncTask';
const String detalleSyncPayload = 'detalle_sync';

final FlutterLocalNotificationsPlugin backgroundNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _initBackgroundNotifications() async {
  const androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const settings = InitializationSettings(android: androidSettings);
  await backgroundNotificationsPlugin.initialize(settings);

  const androidChannel = AndroidNotificationChannel(
    'canal_background',
    'Tareas en segundo plano',
    description: 'Notificaciones generadas por tareas en background',
    importance: Importance.max,
  );
  await backgroundNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(androidChannel);
}

/// Convierte DateTime a formato 12h — ej: "3:45 PM"
String horaFormateada(DateTime fecha) {
  int hora = fecha.hour;
  final periodo = hora >= 12 ? 'PM' : 'AM';
  hora = hora % 12;
  if (hora == 0) hora = 12;
  final minutos = fecha.minute.toString().padLeft(2, '0');
  return '$hora:$minutos $periodo';
}

Future<void> _mostrarNotificacionBackground({
  required String titulo,
  required String cuerpo,
}) async {
  const androidDetails = AndroidNotificationDetails(
    'canal_background', 'Tareas en segundo plano',
    channelDescription: 'Notificaciones generadas por tareas en background',
    importance: Importance.max, priority: Priority.high,
    playSound: true, enableVibration: true,
    icon: '@mipmap/ic_launcher',
  );
  await backgroundNotificationsPlugin.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    titulo, cuerpo,
    const NotificationDetails(android: androidDetails),
    payload: detalleSyncPayload,
  );
}

// ⚠️ Función de nivel superior — @pragma obligatorio para Release mode
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    await _initBackgroundNotifications();
    switch (taskName) {
      case syncTaskName:
        await Future.delayed(const Duration(seconds: 2));
        final horaBonita = horaFormateada(DateTime.now());
        await _mostrarNotificacionBackground(
          titulo: '📡 Datos actualizados',
          cuerpo: 'Datos actualizados correctamente a las $horaBonita',
        );
        break;
    }
    return Future.value(true);
  });
}

/// Registra una tarea periódica (mínimo 15 min en Android)
Future<void> registrarTareaPeriodica() async {
  await Workmanager().registerPeriodicTask(
    'sync-periodico', syncTaskName,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(
      networkType: NetworkType.connected,
      requiresBatteryNotLow: true,
    ),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
  );
}

/// Ejecuta la tarea de sync inmediatamente (para pruebas)
Future<void> ejecutarAhora() async {
  await Workmanager().registerOneOffTask(
    'sync-inmediato-${DateTime.now().millisecondsSinceEpoch}',
    syncTaskName,
  );
}
