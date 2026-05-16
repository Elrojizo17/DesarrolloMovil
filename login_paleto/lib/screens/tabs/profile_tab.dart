import 'package:flutter/material.dart';

import '../../models/profile_preferences.dart';
import '../../notification_service.dart';
import '../../services/game_session_service.dart';

class ProfileTab extends StatefulWidget {
  final bool isGuestMode;
  final String userEmail;
  final VoidCallback onLogout;

  const ProfileTab({
    super.key,
    required this.isGuestMode,
    required this.userEmail,
    required this.onLogout,
  });

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  static const Map<String, IconData> _avatarIcons = {
    'chef': Icons.restaurant,
    'warrior': Icons.shield,
    'alchemist': Icons.science,
    'hunter': Icons.sports_martial_arts,
  };

  static const Map<String, String> _avatarLabels = {
    'chef': 'Chef',
    'warrior': 'Guerrero',
    'alchemist': 'Alquimista',
    'hunter': 'Cazador',
  };

  static const Map<String, Color> _accentColors = {
    'orange': Color(0xFFE65100),
    'teal': Color(0xFF00695C),
    'indigo': Color(0xFF283593),
    'red': Color(0xFFC62828),
  };

  static const Map<String, String> _accentLabels = {
    'orange': 'Naranja',
    'teal': 'Verde',
    'indigo': 'Indigo',
    'red': 'Rojo',
  };

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mottoController = TextEditingController();

  bool _periodicNotificationsEnabled = false;
  bool _loading = true;
  bool _updatingNotifications = false;
  bool _savingPreferences = false;
  ProfilePreferences _preferences = ProfilePreferences.defaults();

  @override
  void initState() {
    super.initState();
    _loadProfileState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mottoController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileState() async {
    final enabled = await NotificationService.instance
        .isPeriodicNotificationsEnabled();

    final storedPreferences = widget.isGuestMode
        ? await GameSessionService.loadGuestProfile()
        : await GameSessionService.loadProfileForUser(widget.userEmail);

    final preferences = storedPreferences ?? ProfilePreferences.defaults();

    if (!mounted) {
      return;
    }

    setState(() {
      _periodicNotificationsEnabled = enabled;
      _preferences = preferences;
      _nameController.text = preferences.displayName;
      _mottoController.text = preferences.motto;
      _loading = false;
    });
  }

  Future<void> _onTogglePeriodicNotifications(bool enabled) async {
    setState(() {
      _updatingNotifications = true;
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
        _updatingNotifications = false;
      });
      return;
    }

    setState(() {
      _periodicNotificationsEnabled = enabled;
      _updatingNotifications = false;
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

  Future<void> _savePreferences({bool showFeedback = false}) async {
    if (_loading) {
      return;
    }

    final normalizedName = _nameController.text.trim();
    final normalizedMotto = _mottoController.text.trim();

    final nextPreferences = _preferences.copyWith(
      displayName: normalizedName.isEmpty ? 'Chef Paleto' : normalizedName,
      motto: normalizedMotto.isEmpty
          ? 'Cocinar, luchar, mejorar.'
          : normalizedMotto,
    );

    setState(() {
      _preferences = nextPreferences;
      _savingPreferences = true;
    });

    if (widget.isGuestMode) {
      await GameSessionService.saveGuestProfile(nextPreferences);
    } else {
      await GameSessionService.saveProfileForUser(
        widget.userEmail,
        nextPreferences,
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _savingPreferences = false;
    });

    if (showFeedback) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Personalizacion guardada.'),
          backgroundColor: Colors.green[700],
        ),
      );
    }
  }

  Future<void> _updateAvatar(String key) async {
    setState(() {
      _preferences = _preferences.copyWith(avatarKey: key);
    });
    await _savePreferences();
  }

  Future<void> _updateColor(String key) async {
    setState(() {
      _preferences = _preferences.copyWith(accentColorKey: key);
    });
    await _savePreferences();
  }

  Future<void> _toggleShowEmail(bool show) async {
    setState(() {
      _preferences = _preferences.copyWith(showEmailInProfile: show);
    });
    await _savePreferences();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor =
        _accentColors[_preferences.accentColorKey] ?? _accentColors['orange']!;
    final avatarIcon =
        _avatarIcons[_preferences.avatarKey] ?? _avatarIcons['chef']!;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Perfil',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              widget.isGuestMode
                  ? 'Modo visitante: el progreso puede reiniciarse al salir.'
                  : 'Sesion iniciada: personaliza tu perfil y guarda cambios.',
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: accentColor.withValues(alpha: 0.18),
                      child: Icon(avatarIcon, size: 42, color: accentColor),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _preferences.displayName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _preferences.motto,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (!widget.isGuestMode && _preferences.showEmailInProfile)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          widget.userEmail,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.blueGrey[700]),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
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
                  : Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _nameController,
                            maxLength: 22,
                            decoration: const InputDecoration(
                              labelText: 'Nombre visible',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _mottoController,
                            maxLength: 48,
                            decoration: const InputDecoration(
                              labelText: 'Lema personal',
                              prefixIcon: Icon(Icons.format_quote),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Avatar',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _avatarIcons.keys
                                .map(
                                  (key) => ChoiceChip(
                                    label: Text(_avatarLabels[key]!),
                                    avatar: Icon(_avatarIcons[key], size: 18),
                                    selected: _preferences.avatarKey == key,
                                    onSelected: _savingPreferences
                                        ? null
                                        : (_) => _updateAvatar(key),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Color del perfil',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _accentColors.keys
                                .map(
                                  (key) => ChoiceChip(
                                    label: Text(_accentLabels[key]!),
                                    selected:
                                        _preferences.accentColorKey == key,
                                    selectedColor: _accentColors[key]!
                                        .withValues(alpha: 0.25),
                                    onSelected: _savingPreferences
                                        ? null
                                        : (_) => _updateColor(key),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 12),
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            value: _preferences.showEmailInProfile,
                            onChanged: widget.isGuestMode || _savingPreferences
                                ? null
                                : (value) => _toggleShowEmail(value),
                            title: const Text('Mostrar email en perfil'),
                            subtitle: Text(
                              widget.isGuestMode
                                  ? 'Disponible solo para cuenta con sesion.'
                                  : 'Controla si el correo aparece en tu vista.',
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _savingPreferences
                                  ? null
                                  : () => _savePreferences(showFeedback: true),
                              icon: _savingPreferences
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.save_outlined),
                              label: const Text('Guardar personalizacion'),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            Card(
              child: SwitchListTile.adaptive(
                value: _periodicNotificationsEnabled,
                onChanged: _loading || _updatingNotifications
                    ? null
                    : (value) => _onTogglePeriodicNotifications(value),
                title: const Text('Notificaciones periodicas'),
                subtitle: Text(
                  _periodicNotificationsEnabled
                      ? 'Activas: recibiras avisos cada 15 minutos.'
                      : 'Inactivas: no se enviaran avisos periodicos.',
                ),
                secondary: _updatingNotifications
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.2),
                      )
                    : const Icon(Icons.notifications_active_outlined),
              ),
            ),
            const SizedBox(height: 16),
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
