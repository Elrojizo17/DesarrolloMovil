import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'life_channel';
  static const String _channelName = 'Vida disponible';
  static const String _channelDescription =
      'Avisos cuando puedes volver a jugar';
  static const int _lifeNotificationId = 1001;
  static const int _testNotificationId = 1002;

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings);

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
      ),
    );

    await ensureNotificationPermission();
  }

  Future<bool> ensureNotificationPermission() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin == null) {
      return true;
    }

    final areEnabled = await androidPlugin.areNotificationsEnabled();
    if (areEnabled ?? false) {
      return true;
    }

    final requested = await androidPlugin.requestNotificationsPermission();
    return requested ?? false;
  }

  Future<void> scheduleLifeAvailableNotification({
    Duration delay = const Duration(minutes: 1),
  }) async {
    final permissionGranted = await ensureNotificationPermission();
    if (!permissionGranted) {
      return;
    }

    final scheduledDate = tz.TZDateTime.now(tz.local).add(delay);

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      _lifeNotificationId,
      'Tu vida esta disponible',
      'Ya puedes volver a jugar en Paleto Knive',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<bool> sendTestNotificationNow() async {
    final permissionGranted = await ensureNotificationPermission();
    if (!permissionGranted) {
      return false;
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      _testNotificationId,
      'Prueba de notificacion',
      'Si ves este mensaje, las notificaciones funcionan.',
      details,
    );

    return true;
  }

  Future<void> cancelLifeAvailableNotification() async {
    await _plugin.cancel(_lifeNotificationId);
  }
}
