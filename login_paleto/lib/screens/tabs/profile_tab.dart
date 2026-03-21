import 'package:flutter/material.dart';

import '../../notification_service.dart';

class ProfileTab extends StatefulWidget {
  final bool isGuestMode;
  final VoidCallback onLogout;

  const ProfileTab({
    super.key,
    required this.isGuestMode,
    required this.onLogout,
  });

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _periodicNotificationsEnabled = false;
  bool _loading = true;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationState();
  }

  Future<void> _loadNotificationState() async {
    final enabled =
        await NotificationService.instance.isPeriodicNotificationsEnabled();
    if (!mounted) {
      return;
    }

    setState(() {
      _periodicNotificationsEnabled = enabled;
      _loading = false;
    });
  }

  Future<void> _onTogglePeriodicNotifications(bool enabled) async {
    setState(() {
      _updating = true;
    });

    final success = await NotificationService.instance
        .setPeriodicNotificationsEnabled(enabled);

    if (!mounted) {
      return;
    }

    if (!success && enabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No se pudo activar: permiso denegado.'),
          backgroundColor: Colors.red[700],
        ),
      );
      setState(() {
        _updating = false;
      });
      return;
    }

    setState(() {
      _periodicNotificationsEnabled = enabled;
      _updating = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          enabled
              ? 'Notificaciones periodicas activadas (cada 15 min).'
              : 'Notificaciones periodicas desactivadas.',
        ),
        backgroundColor: enabled ? Colors.green[700] : Colors.blueGrey[700],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 84, color: Colors.deepOrange[700]),
            const SizedBox(height: 16),
            Text(
              'Perfil',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.isGuestMode
                  ? 'Jugando en modo visitante. El progreso no se conserva.'
                  : 'Sesion iniciada. Tu progreso se guarda localmente.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Card(
              child: _loading
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                          SizedBox(width: 12),
                          Text('Cargando configuracion...'),
                        ],
                      ),
                    )
                  : SwitchListTile.adaptive(
                      value: _periodicNotificationsEnabled,
                      onChanged: _updating
                          ? null
                          : (value) => _onTogglePeriodicNotifications(value),
                      title: const Text('Notificaciones periodicas'),
                      subtitle: Text(
                        _periodicNotificationsEnabled
                            ? 'Activas: recibiras avisos cada 15 minutos.'
                            : 'Inactivas: no se enviaran avisos periodicos.',
                      ),
                      secondary: _updating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2.2),
                            )
                          : const Icon(Icons.notifications_active_outlined),
                    ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: widget.onLogout,
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar Sesion'),
            ),
          ],
        ),
      ),
    );
  }
}
