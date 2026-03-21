import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'background_service.dart';

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _abrirPantallaSegunPayload(String? payload) async {
  if (payload == detalleSyncPayload) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => const DetalleNotificacionPage()),
    );
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {}

Future<void> _initNotifications() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  await notificationsPlugin.initialize(
    const InitializationSettings(android: androidSettings),
    onDidReceiveNotificationResponse: (response) async {
      await _abrirPantallaSegunPayload(response.payload);
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );
  await notificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  await _initNotifications();
  runApp(const MyApp());
}

// ── MyApp ──────────────────────────────────────────────
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    navigatorKey: navigatorKey,
    debugShowCheckedModeBanner: false,
    title: 'Background Tasks Demo',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      scaffoldBackgroundColor: const Color(0xFFF6F8FC),
      useMaterial3: true,
    ),
    home: const HomePage(),
  );
}

// ── HomePage ───────────────────────────────────────────
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _syncActivo = false;
  final List<String> _logs = [];

  void _log(String msg) =>
    setState(() => _logs.insert(0, '[${TimeOfDay.now().format(context)}] $msg'));

  Future<void> _toggleSync() async {
    if (_syncActivo) {
      await Workmanager().cancelAll();
      _log('⏹ Sync periódico CANCELADO');
    } else {
      await registrarTareaPeriodica();
      _log('✅ Sync periódico ACTIVADO (cada 15 min)');
    }
    setState(() => _syncActivo = !_syncActivo);
  }

  Future<void> _ejecutarAhora() async {
    await ejecutarAhora();
    _log('🚀 Tarea enviada (revisa notificación)');
  }

  Future<void> _programarNotif(int segundos) async {
    await Future.delayed(Duration(seconds: segundos));
    await notificationsPlugin.show(
      0, '🔔 Recordatorio',
      'Esto apareció después de $segundos segundos',
      const NotificationDetails(android: AndroidNotificationDetails(
        'canal_recordatorios', 'Recordatorios',
        channelDescription: 'Notificaciones simples',
        importance: Importance.max, priority: Priority.high,
        playSound: true, enableVibration: true,
        icon: '@mipmap/ic_launcher',
      )),
      payload: detalleSyncPayload,
    );
    _log('🔔 Notificación enviada después de $segundos s');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(scrolledUnderElevation: 0, elevation: 0,
      backgroundColor: const Color(0xFFF6F8FC), centerTitle: true,
      title: const Text('Background Tasks Demo',
        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700))),
    body: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      child: Column(children: [
        _buildHeader(),
        const SizedBox(height: 18),
        _buildStatusCard(),
        const SizedBox(height: 18),
        _buildCard(title: 'Tareas Periódicas',
          subtitle: 'Controla procesos automáticos en segundo plano.',
          icon: Icons.sync_rounded, color: Colors.green,
          child: Column(children: [
            _button(_syncActivo ? 'Detener Sync' : 'Activar Sync Periódico',
              _syncActivo ? Icons.stop_rounded : Icons.sync_rounded,
              _syncActivo ? Colors.red.shade400 : Colors.green.shade500, _toggleSync),
            const SizedBox(height: 12),
            _buttonOutline('Ejecutar Ahora (prueba)',
              Icons.play_arrow_rounded, _ejecutarAhora),
          ])),
        const SizedBox(height: 18),
        _buildCard(title: 'Notificaciones',
          subtitle: 'Envía recordatorios y abre la app al tocarlos.',
          icon: Icons.notifications_active_rounded, color: Colors.deepPurple,
          child: Column(children: [
            _button('Notificar en 10 segundos', Icons.notifications_rounded,
              Colors.deepPurple.shade500, () => _programarNotif(10)),
            const SizedBox(height: 12),
            _buttonOutline('Notificar en 1 minuto', Icons.alarm_rounded,
              () => _programarNotif(60)),
          ])),
        const SizedBox(height: 18),
        _buildCard(title: 'Log de actividad',
          subtitle: 'Aquí verás lo que hace la aplicación.',
          icon: Icons.receipt_long_rounded, color: Colors.orange,
          child: SizedBox(height: 240,
            child: _logs.isEmpty
              ? Center(child: Text('Presiona un botón y aquí verás la actividad',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.4)))
              : ListView.separated(itemCount: _logs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFD),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200)),
                    child: Text(_logs[i],
                      style: const TextStyle(fontSize: 13,
                        fontFamily: 'monospace', color: Colors.black87))))),
          ),
      ]),
    ),
  );

  Widget _buildHeader() => Container(
    width: double.infinity, padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(26),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 18, offset: const Offset(0,6))]),
    child: Row(children: [
      Container(width: 68, height: 68,
        decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(20)),
        child: Icon(Icons.phone_android_rounded, color: Colors.indigo.shade400, size: 36)),
      const SizedBox(width: 14),
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('App con tareas automáticas',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: Colors.black87)),
        SizedBox(height: 6),
        Text('Notificaciones, procesos automáticos y pruebas en segundo plano.',
          style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.35)),
      ])),
    ]),
  );

  Widget _buildStatusCard() => Container(
    width: double.infinity, padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [Colors.indigo.shade400, Colors.blue.shade300]),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.22), blurRadius: 16, offset: const Offset(0,6))]),
    child: Row(children: [
      const CircleAvatar(radius: 24, backgroundColor: Colors.white24,
        child: Icon(Icons.rocket_launch_rounded, color: Colors.white)),
      const SizedBox(width: 12),
      Expanded(child: Text(
        _syncActivo ? 'Estado: sincronización automática activada.'
                    : 'Estado: lista para ejecutar tareas y notificaciones.',
        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4, fontWeight: FontWeight.w500))),
    ]),
  );

  Widget _buildCard({required String title, required String subtitle,
      required IconData icon, required Color color, required Widget child}) =>
    Container(
      width: double.infinity, padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 18, offset: const Offset(0,6))],
        border: Border.all(color: Colors.grey.shade200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 44, height: 44,
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87)),
            Text(subtitle, style: const TextStyle(fontSize: 12.5, color: Colors.grey)),
          ])),
        ]),
        const SizedBox(height: 16),
        child,
      ]),
    );

  Widget _button(String text, IconData icon, Color color, VoidCallback onTap) =>
    SizedBox(width: double.infinity, height: 56,
      child: ElevatedButton.icon(onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
        style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)))));

  Widget _buttonOutline(String text, IconData icon, VoidCallback onTap) =>
    SizedBox(width: double.infinity, height: 56,
      child: OutlinedButton.icon(onPressed: onTap,
        icon: Icon(icon, color: Colors.grey.shade800),
        label: Text(text, style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w600, fontSize: 15)),
        style: OutlinedButton.styleFrom(backgroundColor: Colors.white,
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)))));
}

// ── DetalleNotificacionPage ────────────────────────────
class DetalleNotificacionPage extends StatelessWidget {
  const DetalleNotificacionPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF6F8FC),
    appBar: AppBar(scrolledUnderElevation: 0, elevation: 0,
      backgroundColor: const Color(0xFFF6F8FC), centerTitle: true,
      title: const Text('Detalle',
        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700))),
    body: Center(child: Padding(padding: const EdgeInsets.all(22),
      child: Container(width: double.infinity, padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(26),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 18, offset: const Offset(0,6))]),
        child: const Column(mainAxisSize: MainAxisSize.min, children: [
          CircleAvatar(radius: 34, backgroundColor: Color(0x1A4CAF50),
            child: Icon(Icons.check_circle_rounded, color: Colors.green, size: 40)),
          SizedBox(height: 16),
          Text('Abriste la app desde la notificación', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87)),
          SizedBox(height: 10),
          Text('Aquí puedes mostrar mensajes importantes, datos sincronizados o información del sistema.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.4)),
        ]),
      ))),
  );
}