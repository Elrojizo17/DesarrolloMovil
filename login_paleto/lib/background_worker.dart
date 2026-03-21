import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

import 'notification_service.dart';

final FlutterLocalNotificationsPlugin _backgroundNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _initBackgroundNotifications() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const settings = InitializationSettings(android: androidSettings);
  await _backgroundNotificationsPlugin.initialize(settings);

  const androidChannel = AndroidNotificationChannel(
    'life_channel',
    'Vida disponible',
    description: 'Avisos cuando puedes volver a jugar',
    importance: Importance.high,
  );

  await _backgroundNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(androidChannel);
}

Future<void> _showPeriodicNotification() async {
  const androidDetails = AndroidNotificationDetails(
    'life_channel',
    'Vida disponible',
    channelDescription: 'Avisos cuando puedes volver a jugar',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  await _backgroundNotificationsPlugin.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    'Recordatorio de Paleto Knive',
    'Vuelve al juego y sigue subiendo de nivel.',
    const NotificationDetails(android: androidDetails),
  );
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == periodicNotificationTaskName) {
      await _initBackgroundNotifications();
      await _showPeriodicNotification();
    }
    return Future.value(true);
  });
}
