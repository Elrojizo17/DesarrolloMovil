import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/game_constants.dart';
import '../models/game_save.dart';
import '../providers/game_provider.dart';
import '../services/game_session_service.dart';
import '../widgets/resource_bar.dart';
import 'tabs/arsenal_tab.dart';
import 'tabs/combat_tab.dart';
import 'tabs/kitchen_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/techniques_tab.dart';

class GameScreen extends StatefulWidget {
  final GameSave initialSave;
  final bool isGuestMode;
  final String userEmail;

  const GameScreen({
    super.key,
    required this.initialSave,
    this.isGuestMode = false,
    this.userEmail = '',
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameProvider(
        initialSave: widget.initialSave,
        userEmail: widget.userEmail,
        isGuestMode: widget.isGuestMode,
      ),
      child: Consumer<GameProvider>(
        builder: (context, gameProvider, _) {
          final tabs = <Widget>[
            const CombatTab(),
            const KitchenTab(),
            const TechniquesTab(),
            const ArsenalTab(),
            ProfileTab(
              isGuestMode: widget.isGuestMode,
              onLogout: _onLogout,
            ),
          ];

          return Scaffold(
            body: Column(
              children: [
                Consumer<GameProvider>(
                  builder: (context, provider, _) =>
                      ResourceBar(gameSave: provider.gameSave),
                ),
                Expanded(child: tabs[_currentTab]),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentTab,
              type: BottomNavigationBarType.fixed,
              backgroundColor: const Color(GameConstants.darkBackground),
              selectedItemColor: const Color(GameConstants.primaryOrange),
              unselectedItemColor: Colors.grey[400],
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.sports_kabaddi),
                  label: 'Combate',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.restaurant),
                  label: 'Cocina',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.auto_graph),
                  label: 'Tecnicas',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.backpack),
                  label: 'Equipo',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Perfil',
                ),
              ],
              onTap: (index) => setState(() => _currentTab = index),
            ),
          );
        },
      ),
    );
  }

  Future<void> _onLogout() async {
    if (widget.isGuestMode) {
      await GameSessionService.clearGuestGame();
    }
    await GameSessionService.clearLoggedUser();

    if (!mounted) {
      return;
    }

    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
