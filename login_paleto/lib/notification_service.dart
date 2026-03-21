import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

const String periodicNotificationTaskName = 'periodicNotificationTask';
const String periodicNotificationUniqueName = 'paleto-periodic-notification';

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
    static const String _periodicNotificationsPrefKey =
      'periodic_notifications_enabled';

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
    Duration delay = const Duration(minutes: 5),
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

  Future<bool> isPeriodicNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_periodicNotificationsPrefKey) ?? false;
  }

  Future<bool> setPeriodicNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();

    if (!enabled) {
      await _cancelPeriodicTask();
      await prefs.setBool(_periodicNotificationsPrefKey, false);
      return true;
    }

    final permissionGranted = await ensureNotificationPermission();
    if (!permissionGranted) {
      return false;
    }

    await _registerPeriodicTask();
    await prefs.setBool(_periodicNotificationsPrefKey, true);
    return true;
  }

  Future<void> syncPeriodicNotificationsWithPreference() async {
    final enabled = await isPeriodicNotificationsEnabled();
    if (!enabled) {
      return;
    }

    final permissionGranted = await ensureNotificationPermission();
    if (!permissionGranted) {
      await setPeriodicNotificationsEnabled(false);
      return;
    }

    await _registerPeriodicTask();
  }

  Future<void> _registerPeriodicTask() async {
    await Workmanager().registerPeriodicTask(
      periodicNotificationUniqueName,
      periodicNotificationTaskName,
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      constraints: Constraints(
        networkType: NetworkType.not_required,
      ),
    );
  }

  Future<void> _cancelPeriodicTask() async {
    await Workmanager().cancelByUniqueName(periodicNotificationUniqueName);
  }
}
