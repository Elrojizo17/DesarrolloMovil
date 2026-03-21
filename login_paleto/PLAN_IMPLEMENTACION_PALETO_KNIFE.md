# Plan de Implementación — Paleto Knife (Idle/Clicker RPG)

> **Proyecto base:** `login_paleto` — Flutter ^3.11.0  
> **Estado actual:** Autenticación funcional, SplashScreen animada, sistema de notificaciones inicializado.  
> **Objetivo:** Transformar la app en un juego idle/clicker RPG completo con chef maestro, sous-chefs, equipamiento, técnicas y sistema de reinicio (prestige).

---

## Índice

1. [Arquitectura General](#1-arquitectura-general)
2. [Fase 0 — Preparación del Proyecto](#2-fase-0--preparación-del-proyecto)
3. [Fase 1 — Zona Pública (Sin Sesión)](#3-fase-1--zona-pública-sin-sesión)
4. [Fase 2 — Estructura de Navegación Principal](#4-fase-2--estructura-de-navegación-principal)
5. [Fase 3 — Tab 1: Combate](#5-fase-3--tab-1-combate)
6. [Fase 4 — Tab 2: Cocina (Sous-chefs)](#6-fase-4--tab-2-cocina-sous-chefs)
7. [Fase 5 — Tab 3: Técnicas](#7-fase-5--tab-3-técnicas)
8. [Fase 6 — Tab 4: Equipo (Arsenal)](#8-fase-6--tab-4-equipo-arsenal)
9. [Fase 7 — Tab 5: Perfil y Configuración](#9-fase-7--tab-5-perfil-y-configuración)
10. [Fase 8 — Sistema de Notificaciones Idle](#10-fase-8--sistema-de-notificaciones-idle)
11. [Fase 9 — Persistencia de Datos](#11-fase-9--persistencia-de-datos)
12. [Fase 10 — Pulido Final](#12-fase-10--pulido-final)
13. [Dependencias Nuevas Requeridas](#13-dependencias-nuevas-requeridas)
14. [Estructura de Archivos Final](#14-estructura-de-archivos-final)

---

## 1. Arquitectura General

### Patrón de estado recomendado: **Provider + ChangeNotifier**

Dado que el proyecto ya usa Flutter puro sin gestión de estado avanzada, se adoptará **Provider** por su sencillez y compatibilidad con Flutter 3.x.

```
lib/
├── models/          # Estructuras de datos puras
├── providers/       # Estado reactivo (ChangeNotifier)
├── screens/         # Pantallas principales
├── widgets/         # Componentes reutilizables
├── services/        # Lógica de negocio (guardado, notificaciones)
└── constants/       # Colores, textos, configuración de juego
```

### Flujo de datos

```
GameProvider (estado central)
    ↕
Services (persistencia, notificaciones)
    ↕
Screens → Widgets (UI reactiva con Consumer<GameProvider>)
```

---

## 2. Fase 0 — Preparación del Proyecto

### Paso 0.1 — Actualizar `pubspec.yaml`

Agregar las nuevas dependencias al archivo existente:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_local_notifications: ^17.2.4
  timezone: ^0.9.4

  # NUEVAS
  provider: ^6.1.2           # Gestión de estado reactivo
  shared_preferences: ^2.3.2  # Persistencia local (guardado de partida)
  google_fonts: ^6.2.1        # Tipografía personalizada (opcional)
  audioplayers: ^6.1.0        # Sonido y música
  flutter_animate: ^4.5.0     # Animaciones de combate y UI
```

Ejecutar: `flutter pub get`

### Paso 0.2 — Crear constantes globales

Crear `lib/constants/game_constants.dart`:

```dart
class GameConstants {
  // Credenciales por defecto (ya existentes en main.dart)
  static const String defaultEmail = 'usuario@palet.knive';
  static const String defaultPassword = 'paleto123';

  // Colores temáticos
  static const int primaryOrange = 0xFFE65100;
  static const int accentGold = 0xFFFFD700;
  static const int darkBackground = 0xFF1A1A2E;

  // Configuración de niveles
  static const int maxLevelBeforeElite = 25;
  static const int maxLevelBeforeMinorChef = 50;
  static const int maxLevelBeforeWorldBoss = 100;

  // Multiplicadores de recompensa
  static const double eliteGoldMultiplier = 2.0;
  static const double minorChefGoldMultiplier = 5.0;
  static const double worldBossGoldMultiplier = 10.0;

  // Slots de sous-chefs activos
  static const int maxActiveSousChefs = 5;

  // Slots de joyas
  static const int maxJewelSlots = 2;

  // Bonificaciones por reinicio
  static const double restartDamageBonus = 0.05;
  static const double restartGoldBonus = 0.03;
  static const double restartSpeedBonus = 0.02;
}
```

### Paso 0.3 — Crear modelos de datos base

Crear `lib/models/` con los siguientes archivos:

**`lib/models/chef_stats.dart`** — Estadísticas del chef principal:
```dart
class ChefStats {
  double baseDamage;
  double criticalMultiplier;
  double criticalChance;
  double precision;
  double goldBonus;
  double attackSpeed;

  ChefStats({
    this.baseDamage = 10.0,
    this.criticalMultiplier = 1.5,
    this.criticalChance = 0.05,
    this.precision = 0.90,
    this.goldBonus = 1.0,
    this.attackSpeed = 1.0,
  });

  Map<String, dynamic> toJson() => { /* serialización */ };
  factory ChefStats.fromJson(Map<String, dynamic> json) => /* deserialización */;
}
```

**`lib/models/sous_chef.dart`** — Modelo de cada sous-chef:
```dart
enum ElementType { neutral, water, fire, earth, advanced }

class SousChef {
  final String id;
  final String name;
  final ElementType element;
  final int unlockWorld;
  bool isActive;
  double damageBonus;
  double speedBonus;

  // Reliquias asignadas
  List<String> assignedRelics;
}
```

**`lib/models/knife.dart`** — Cuchillo equipable:
```dart
enum KnifeRarity { common, rare, epic, legendary, mythic }

class Knife {
  final String id;
  final String name;
  final KnifeRarity rarity;
  final double damageBonus;
  final String skill; // habilidad especial
}
```

**`lib/models/amalgam.dart`** — Enemigo actual:
```dart
class Amalgam {
  final String name;
  double maxHealth;
  double currentHealth;
  final int level;
  final bool isElite;
  final bool isBoss;
  final String elementalType;
}
```

**`lib/models/game_save.dart`** — Estado completo guardable:
```dart
class GameSave {
  int currentLevel;
  int currentWorld;
  double gold;
  double knifeFragments;
  int restartTokens;
  ChefStats chefStats;
  List<SousChef> sousChefs;
  Knife? equippedKnife;
  List<String> ownedKnives;
  Map<String, int> techniqueLevels;
  int totalRestarts;
  Map<String, double> permanentBonuses;

  Map<String, dynamic> toJson() => { /* serialización completa */ };
  factory GameSave.fromJson(Map<String, dynamic> json) => /* deserialización */;
}
```

### Paso 0.4 — Configurar el Provider principal

Crear `lib/providers/game_provider.dart`:

```dart
class GameProvider extends ChangeNotifier {
  GameSave _save = GameSave();
  Amalgam? _currentAmalgam;
  Timer? _autoAttackTimer;
  Timer? _sousChefTimer;

  // Getters públicos
  GameSave get save => _save;
  Amalgam? get currentAmalgam => _currentAmalgam;

  // Inicializar (cargar partida guardada)
  Future<void> initialize() async { /* cargar desde SharedPreferences */ }

  // Acciones de combate
  void tapAttack() { /* lógica de ataque manual */ notifyListeners(); }
  void startAutoAttack() { /* timer de sous-chefs */ }
  void _processAttack({required bool isSousChef}) { /* calcular daño */ }
  void _spawnNextAmalgam() { /* generar nuevo enemigo */ }

  // Persistencia
  Future<void> saveGame() async { /* guardar en SharedPreferences */ }

  @override
  void dispose() { _autoAttackTimer?.cancel(); super.dispose(); }
}
```

Registrar el provider en `main.dart` envolviendo el `MaterialApp` con `MultiProvider`.

---

## 3. Fase 1 — Zona Pública (Sin Sesión)

> **Estado actual:** Ya existe SplashScreen y sistema de login básico.

### Paso 1.1 — Actualizar SplashScreen existente

Modificar `lib/main.dart` (o extraer a `lib/screens/splash_screen.dart`):

- Mantener la animación de logo con cuchillo del Chef
- Al finalizar los 4 segundos, navegar a `HomePublicScreen` en lugar de directamente al login
- La `HomePublicScreen` es el menú principal sin sesión

### Paso 1.2 — Crear `lib/screens/home_public_screen.dart`

Esta pantalla muestra cuatro opciones de menú en estilo RPG:

```
┌─────────────────────────────┐
│   🍴 PALETO KNIFE           │
│   [Logo animado del Chef]   │
│                             │
│   [ Nueva Partida ]         │
│   [ Continuar Partida ]     │
│   [ Modo Visitante ]        │
│                             │
│   v1.0.0                    │
└─────────────────────────────┘
```

**Lógica de cada botón:**

- **Nueva Partida:** Navega a `LoginScreen` (ya existente). Tras autenticación exitosa, crea un `GameSave` vacío y entra al juego.
- **Continuar Partida:** Verifica si existe una sesión guardada en `SharedPreferences`. Si existe, carga el `GameSave` y entra al juego directamente. Si no, muestra un `SnackBar` indicando que no hay partida guardada.
- **Modo Visitante:** Crea un `GameSave` temporal (sin persistencia), navega al juego. Al cerrar sesión se descarta el progreso. Solo permite avanzar hasta nivel 5.

### Paso 1.3 — Actualizar flujo de autenticación existente

En el `LoginScreen` actual (dentro de `main.dart`):

- Al login exitoso, verificar si hay una partida guardada asociada al usuario.
- Si hay partida guardada → cargar y navegar a `GameScreen`.
- Si no hay partida → crear nueva y navegar a `GameScreen`.
- En el `RegisterScreen`, crear nueva cuenta y automáticamente iniciar sesión.

### Paso 1.4 — Guardar sesión en `SharedPreferences`

```dart
// Al hacer login exitoso:
final prefs = await SharedPreferences.getInstance();
await prefs.setString('logged_user', email);
await prefs.setString('game_save_$email', jsonEncode(gameSave.toJson()));
```

---

## 4. Fase 2 — Estructura de Navegación Principal

### Paso 2.1 — Crear `lib/screens/game_screen.dart`

Esta es la pantalla contenedor del juego con `BottomNavigationBar` de 5 tabs:

```dart
class GameScreen extends StatefulWidget { /* ... */ }

class _GameScreenState extends State<GameScreen> {
  int _currentTab = 0;

  final List<Widget> _tabs = [
    CombatTab(),
    KitchenTab(),
    TechniquesTab(),
    ArsenalTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentTab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(GameConstants.darkBackground),
        selectedItemColor: Color(GameConstants.primaryOrange),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.sports_kabaddi), label: 'Combate'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Cocina'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_graph), label: 'Técnicas'),
          BottomNavigationBarItem(icon: Icon(Icons.backpack), label: 'Equipo'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        onTap: (index) => setState(() => _currentTab = index),
      ),
    );
  }
}
```

### Paso 2.2 — Panel de recursos (AppBar superior)

Crear `lib/widgets/resource_bar.dart` — barra superior persistente en todos los tabs:

```
┌─ 🪙 1,234 oro  ──  🔪 45 fragmentos  ──  🎟️ 3 tokens ─┐
```

Este widget escucha `GameProvider` con `Consumer<GameProvider>` y se actualiza en tiempo real.

---

## 5. Fase 3 — Tab 1: Combate

Crear `lib/screens/tabs/combat_tab.dart`

### Paso 3.1 — Arena de combate (zona central)

**Componentes a crear:**

**`lib/widgets/combat/amalgam_display.dart`:**
- Muestra el sprite/icono del enemigo actual (nivel, nombre, tipo elemental)
- Barra de vida animada con `AnimatedContainer` o `TweenAnimationBuilder`
- Al recibir daño, mostrar texto flotante con el valor (`FloatingDamageText`)
- Animación de shake al recibir golpe crítico

**`lib/widgets/combat/floating_damage_text.dart`:**
```dart
// Widget que aparece y desaparece con animación al hacer daño
// Colores: blanco=normal, amarillo=crítico, gris=miss, verde=combo
class FloatingDamageText extends StatefulWidget { /* ... */ }
```

**Lógica de ataque tap:**
```dart
void tapAttack() {
  final roll = Random().nextDouble();
  final isMiss = roll > save.chefStats.precision;
  if (isMiss) { /* mostrar MISS */ return; }

  final isCrit = Random().nextDouble() < save.chefStats.criticalChance;
  double damage = save.chefStats.baseDamage;
  if (isCrit) damage *= save.chefStats.criticalMultiplier;

  _currentAmalgam!.currentHealth -= damage;
  _showDamageEffect(damage, isCrit: isCrit);

  if (_currentAmalgam!.currentHealth <= 0) _onAmalgamDefeated();
  notifyListeners();
}
```

### Paso 3.2 — Indicadores de nivel y progreso

**`lib/widgets/combat/level_indicator.dart`:**
- Nivel actual del jugador
- Barra de progreso (amalgamas derrotadas / necesarias para siguiente nivel)
- Al llegar a niveles clave (25, 50, 100), mostrar `AlertDialog` de jefe especial

**Lógica de niveles especiales:**
```dart
void _onAmalgamDefeated() {
  save.currentLevel++;

  if (save.currentLevel == 25) _spawnEliteAmalgam();
  else if (save.currentLevel == 50) _spawnMinorChef();
  else if (save.currentLevel == 100) _spawnWorldBoss();
  else _spawnNextAmalgam();

  _distributeRewards();
  saveGame();
}
```

**Recompensas especiales:**
```dart
void _distributeRewards() {
  double goldEarned = baseGold;
  if (currentAmalgam.isElite) goldEarned *= GameConstants.eliteGoldMultiplier;
  if (currentAmalgam.isBoss) {
    goldEarned *= GameConstants.worldBossGoldMultiplier;
    _openRewardChest(); // cofres, joyas, reliquias
  }
  save.gold += goldEarned;
}
```

### Paso 3.3 — Panel de recursos (arriba izquierda)

Reutilizar `ResourceBar` widget (creado en Fase 2, Paso 2.2):
- Oro acumulado
- Fragmentos de Cuchillo
- Tokens de Reinicio

### Paso 3.4 — Panel de combate (arriba derecha)

**`lib/widgets/combat/combat_stats_panel.dart`:**
- DPS total (Daño Por Segundo = daño tap + daño auto de sous-chefs)
- Número de sous-chefs activos actualmente

### Paso 3.5 — Estadísticas del chef (abajo)

**`lib/widgets/combat/chef_stats_display.dart`:**
Mostrar en una fila horizontal con iconos:
```
⚔️ 120 dmg  |  💥 1.5x crit  |  🎯 90% prec  |  🪙 +10% gold  |  ⚡ 1.2/s
```

### Paso 3.6 — Auto-ataque de sous-chefs

En `GameProvider`, iniciar un `Timer.periodic` al cargar la partida:
```dart
void startAutoAttack() {
  _sousChefTimer = Timer.periodic(
    Duration(milliseconds: (1000 / save.chefStats.attackSpeed).round()),
    (_) {
      final activeSousChefs = save.sousChefs.where((s) => s.isActive).toList();
      for (final chef in activeSousChefs) {
        _processAttack(isSousChef: true, sourceChef: chef);
      }
    },
  );
}
```

---

## 6. Fase 4 — Tab 2: Cocina (Sous-chefs)

Crear `lib/screens/tabs/kitchen_tab.dart`

### Paso 4.1 — Lista de sous-chefs

**`lib/widgets/kitchen/sous_chef_card.dart`:**

Crear una tarjeta por cada sous-chef con:
- Nombre y tipo elemental (ícono de color por elemento)
- Estado: bloqueado / desbloqueado / activo
- Botón de activar/desactivar (limitado a 5 simultáneos)
- Reliquias asignadas (hasta 2 ranuras de reliquias)
- Bonus de daño y velocidad que aporta

**Sous-chefs disponibles (datos hardcodeados en `lib/constants/sous_chefs_data.dart`):**

| ID | Nombre | Elemento | Mundo desbloqueo |
|----|--------|----------|-----------------|
| `apprentice` | Chef Aprendiz | Neutral | 1 (desde inicio) |
| `sushiman` | Chef Sushiman | Agua | 2 |
| `griller` | Chef Parrillero | Fuego | 3 |
| `baker` | Chef Panadero | Tierra | 4 |
| `executive` | Chef Ejecutivo | Maestro | 5+ |

### Paso 4.2 — Gestión de slots activos

**Lógica en `GameProvider`:**
```dart
void toggleSousChef(String chefId) {
  final chef = save.sousChefs.firstWhere((c) => c.id == chefId);
  final activeCount = save.sousChefs.where((c) => c.isActive).length;

  if (chef.isActive) {
    chef.isActive = false;
  } else if (activeCount < GameConstants.maxActiveSousChefs) {
    chef.isActive = true;
  } else {
    // Mostrar mensaje: "Máximo 5 sous-chefs activos"
  }
  notifyListeners();
  saveGame();
}
```

### Paso 4.3 — Asignación de reliquias a sous-chefs

En la tarjeta de cada sous-chef, mostrar 2 ranuras de reliquias.
Al tocar una ranura vacía, abrir un `BottomSheet` con las reliquias disponibles del inventario del jugador.

---

## 7. Fase 5 — Tab 3: Técnicas

Crear `lib/screens/tabs/techniques_tab.dart`

### Paso 5.1 — Lista de técnicas mejorables

**Técnicas disponibles (definir en `lib/constants/techniques_data.dart`):**

| ID | Nombre | Efecto por nivel | Costo (oro) |
|----|--------|-----------------|-------------|
| `sharpening` | Afilado de Cuchillos | +1 daño base | Escala exponencial |
| `manual_dexterity` | Destreza Manual | +5% velocidad de ataque | Escala exponencial |
| `golden_bacon` | Golden Bacon | +10% oro ganado | Escala exponencial |
| `precision_cut` | Corte de Precisión | +2% prob. crítico | Escala exponencial |
| `lethal_technique` | Técnica Letal | +25% daño crítico | Escala exponencial |
| `culinary_precision` | Precisión Culinaria | +5% precisión, -misses | Escala exponencial |

**Fórmula de costo por nivel:**
```dart
double getTechniqueCost(String techniqueId, int currentLevel) {
  const baseCosts = { 'sharpening': 100.0, 'golden_bacon': 200.0, /* ... */ };
  return baseCosts[techniqueId]! * pow(1.15, currentLevel);
}
```

### Paso 5.2 — Widget de técnica individual

**`lib/widgets/techniques/technique_card.dart`:**
- Nombre e ícono de la técnica
- Nivel actual (ej: "Nivel 7")
- Descripción del efecto actual y siguiente nivel
- Botón "Mejorar" con costo de oro visible
- Botón deshabilitado (gris) si no hay oro suficiente

### Paso 5.3 — Aplicar efectos al comprar técnica

```dart
void upgradeTechnique(String techniqueId) {
  final cost = getTechniqueCost(techniqueId, save.techniqueLevels[techniqueId] ?? 0);
  if (save.gold < cost) return;

  save.gold -= cost;
  save.techniqueLevels[techniqueId] = (save.techniqueLevels[techniqueId] ?? 0) + 1;
  _recalculateChefStats(); // Recalcular todos los stats del chef
  notifyListeners();
  saveGame();
}

void _recalculateChefStats() {
  save.chefStats.baseDamage = 10.0 + (save.techniqueLevels['sharpening'] ?? 0);
  save.chefStats.attackSpeed = 1.0 + (save.techniqueLevels['manual_dexterity'] ?? 0) * 0.05;
  // etc.
}
```

---

## 8. Fase 6 — Tab 4: Equipo (Arsenal)

Crear `lib/screens/tabs/arsenal_tab.dart`

### Paso 6.1 — Sistema de cuchillos especiales

**`lib/widgets/arsenal/knife_inventory.dart`:**

- Mostrar todos los cuchillos obtenidos (rejilla o lista)
- Badge de rareza con color distintivo:
  - Común: gris  |  Raro: azul  |  Épico: morado  |  Legendario: naranja  |  Mítico: rojo/dorado
- Botón "Equipar" en el cuchillo seleccionado
- Al equipar: aplicar su bonus de daño y activar su habilidad especial

**Abrir cofre:**
```dart
void openKnifeChest() {
  const cost = 50; // fragmentos de cuchillo
  if (save.knifeFragments < cost) return;

  save.knifeFragments -= cost;
  final knife = _rollRandomKnife(); // sistema de probabilidades por rareza
  save.ownedKnives.add(knife.id);
  notifyListeners();
  saveGame();
}

Knife _rollRandomKnife() {
  final roll = Random().nextDouble();
  // Común: 60% | Raro: 25% | Épico: 10% | Legendario: 4% | Mítico: 1%
  if (roll < 0.60) return _getRandomByRarity(KnifeRarity.common);
  if (roll < 0.85) return _getRandomByRarity(KnifeRarity.rare);
  // ...
}
```

### Paso 6.2 — Sistema de joyas (2 slots)

**`lib/widgets/arsenal/jewel_slots.dart`:**

- 2 slots visuales (ranuras con borde dorado)
- Al tocar ranura vacía: `BottomSheet` con joyas disponibles
- Tipos de joyas:
  - **Collar:** mejora daño o crítico
  - **Anillo:** mejora oro o velocidad
- Las joyas se obtienen al derrotar jefes especiales

```dart
void equipJewel(String jewelId, int slot) {
  assert(slot == 0 || slot == 1);
  save.equippedJewels[slot] = jewelId;
  _recalculateChefStats();
  notifyListeners();
  saveGame();
}
```

### Paso 6.3 — Sistema de reliquias

**`lib/widgets/arsenal/relics_display.dart`:**

- Lista de reliquias obtenidas (al derrotar jefes)
- Cada reliquia potencia a un sous-chef específico
- Mostrar qué sous-chef tiene asignada cada reliquia
- Botón para reasignar a otro sous-chef

### Paso 6.4 — Ídolos Culinarios (solo 1 activo)

**`lib/widgets/arsenal/culinary_idols.dart`:**

Los ídolos dan un gran bonus pero también una penalización:

| Ídolo | Bonus | Penalización |
|-------|-------|--------------|
| Cuchillo Carnicero | +50% daño | -20% defensa (más daño recibido) |
| Cuchara de Oro | +40% oro | -15% daño |
| Batidor Relámpago | +35% velocidad | -10% crítico |
| Estrella Michelin | +40% daño | -20% velocidad |

- Radio buttons para seleccionar solo 1 ídolo activo
- El efecto se aplica inmediatamente al seleccionarlo

---

## 9. Fase 7 — Tab 5: Perfil y Configuración

Crear `lib/screens/tabs/profile_tab.dart`

### Paso 7.1 — Sección "Ver mis datos"

**`lib/widgets/profile/player_stats_card.dart`:**
```
👨‍🍳 usuario@palet.knive
📊 Nivel actual: 47 | Mundo: 3
🏆 Mejor marca personal: Nivel 89
🔄 Total de reinicios realizados: 2
```

### Paso 7.2 — Bonificaciones permanentes acumuladas

Mostrar los bonos que se han desbloqueado con reinicios anteriores:
```
✅ Daño permanente: +10% (2 reinicios × 5%)
✅ Oro permanente: +6% (2 reinicios × 3%)
✅ Velocidad permanente: +4% (2 reinicios × 2%)
```

### Paso 7.3 — Sistema de Reinicio (Prestige)

> **Disponible desde nivel 100.**

**`lib/widgets/profile/restart_section.dart`:**

**Pantalla de confirmación del reinicio:**
1. Mostrar tokens a ganar según nivel actual
2. Mostrar qué se conserva y qué se reinicia
3. Botón "Confirmar Reinicio" con `AlertDialog` de doble confirmación

```dart
int calculateRestartTokens(int currentLevel) {
  return (currentLevel / 10).floor(); // 10 tokens por cada 100 niveles
}

void performRestart() {
  final tokensGained = calculateRestartTokens(save.currentLevel);

  // Lo que se CONSERVA:
  final keptKnives = save.ownedKnives;
  final keptPermanentBonuses = save.permanentBonuses;
  final keptStats = save.chefStats; // estadísticas base
  final totalRestarts = save.totalRestarts + 1;

  // Aplicar nuevas bonificaciones permanentes:
  final newBonuses = {
    'damage': (keptPermanentBonuses['damage'] ?? 0) + GameConstants.restartDamageBonus,
    'gold': (keptPermanentBonuses['gold'] ?? 0) + GameConstants.restartGoldBonus,
    'speed': (keptPermanentBonuses['speed'] ?? 0) + GameConstants.restartSpeedBonus,
  };

  // Reiniciar a un GameSave nuevo, conservando lo indicado:
  save = GameSave(
    ownedKnives: keptKnives,
    permanentBonuses: newBonuses,
    totalRestarts: totalRestarts,
    restartTokens: save.restartTokens + tokensGained,
  );

  // Los sous-chefs, técnicas y nivel vuelven a 0
  _recalculateChefStats();
  notifyListeners();
  saveGame();
}
```

**Pantalla de vista previa de tokens:**
```
Nivel actual: 147
Tokens a ganar: 14 🎟️
Ver tokens necesarios para mejoras futuras → [botón]
```

### Paso 7.4 — Configuración

**`lib/widgets/profile/settings_section.dart`:**

```dart
class SettingsSection extends StatelessWidget {
  // Switches con SharedPreferences para persistir preferencias:
  // - Sonido y música ON/OFF
  // - Notificaciones idle ON/OFF
  // - Idioma (Español / English)
  // - Apariencia (Modo oscuro / claro)
  // - Botón "Cerrar sesión"
  // - Botón "Borrar partida" (con doble confirmación)
}
```

**Al cerrar sesión:** limpiar la clave `logged_user` de SharedPreferences y navegar a `HomePublicScreen`.

---

## 10. Fase 8 — Sistema de Notificaciones Idle

> El `notification_service.dart` ya existe. Extender su funcionalidad.

### Paso 8.1 — Notificación "Oro lleno"

La notificación se envía cuando el oro acumulado offline alcanza un límite máximo (el juego no puede guardar más oro sin que el jugador entre).

```dart
// En notification_service.dart, agregar:
Future<void> scheduleGoldFullNotification(Duration timeUntilFull) async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
    1, // notification ID
    '🪙 ¡Tu oro está lleno!',
    'Entra al juego para no perder tus ganancias, Chef.',
    tz.TZDateTime.now(tz.local).add(timeUntilFull),
    const NotificationDetails(/* ... */),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
}
```

### Paso 8.2 — Calcular progreso offline

Al abrir el juego (en `GameProvider.initialize()`):

```dart
Future<void> _processOfflineProgress() async {
  final prefs = await SharedPreferences.getInstance();
  final lastSaveTime = prefs.getInt('last_save_timestamp') ?? 0;
  final now = DateTime.now().millisecondsSinceEpoch;
  final offlineSeconds = (now - lastSaveTime) / 1000;

  if (offlineSeconds > 60) {
    final activeSousChefs = save.sousChefs.where((s) => s.isActive).toList();
    final dpsPerSecond = activeSousChefs.fold(0.0, (sum, chef) => sum + chef.damageBonus);
    // Acumular oro proporcional al tiempo offline (máximo 8 horas)
    final cappedSeconds = offlineSeconds.clamp(0, 28800); // 8h máx
    save.gold += dpsPerSecond * cappedSeconds * goldConversionRate;
  }
}
```

---

## 11. Fase 9 — Persistencia de Datos

### Paso 9.1 — Implementar `GameSaveService`

Crear `lib/services/game_save_service.dart`:

```dart
class GameSaveService {
  static const String _saveKey = 'game_save';
  static const String _timestampKey = 'last_save_timestamp';

  Future<GameSave?> loadSave(String userEmail) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('${_saveKey}_$userEmail');
    if (jsonStr == null) return null;
    return GameSave.fromJson(jsonDecode(jsonStr));
  }

  Future<void> saveSave(String userEmail, GameSave save) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_saveKey}_$userEmail', jsonEncode(save.toJson()));
    await prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> deleteSave(String userEmail) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_saveKey}_$userEmail');
  }
}
```

### Paso 9.2 — Auto-guardado

En `GameProvider`, implementar un timer de auto-guardado cada 30 segundos:

```dart
Timer.periodic(const Duration(seconds: 30), (_) => saveGame());
```

También guardar en estos eventos críticos:
- Al derrotar una amalgama
- Al comprar una técnica
- Al activar/desactivar un sous-chef
- Al equipar un cuchillo o joya
- Al realizar un reinicio

---

## 12. Fase 10 — Pulido Final

### Paso 10.1 — Animaciones con `flutter_animate`

Aplicar animaciones de entrada/salida en:
- Aparición de nueva amalgama: `fadeIn + scale`
- Muerte de amalgama: `shake + fadeOut`
- Compra de técnica exitosa: `bounceIn` en el card
- Apertura de cofre: secuencia `scale + rotate + glow`

```dart
// Ejemplo de uso con flutter_animate:
AmalgamDisplay()
  .animate(key: ValueKey(currentAmalgam.id))
  .fadeIn(duration: 300.ms)
  .scale(begin: Offset(0.8, 0.8), end: Offset(1.0, 1.0))
```

### Paso 10.2 — Sonidos con `audioplayers`

Crear `lib/services/audio_service.dart`:

```dart
class AudioService {
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  Future<void> playAttack() => _sfxPlayer.play(AssetSource('sfx/knife_throw.mp3'));
  Future<void> playCritical() => _sfxPlayer.play(AssetSource('sfx/critical_hit.mp3'));
  Future<void> playEnemyDeath() => _sfxPlayer.play(AssetSource('sfx/enemy_defeated.mp3'));
  Future<void> playChestOpen() => _sfxPlayer.play(AssetSource('sfx/chest_open.mp3'));
  Future<void> playBgMusic() => _musicPlayer.play(AssetSource('music/kitchen_battle.mp3'));
}
```

Agregar archivos de audio en `assets/sfx/` y `assets/music/` y registrar en `pubspec.yaml`.

### Paso 10.3 — Soporte de modo oscuro/claro

Actualizar `MaterialApp` en `main.dart`:

```dart
MaterialApp(
  theme: ThemeData(
    colorSchemeSeed: Color(GameConstants.primaryOrange),
    useMaterial3: true,
    brightness: Brightness.light,
  ),
  darkTheme: ThemeData(
    colorSchemeSeed: Color(GameConstants.primaryOrange),
    useMaterial3: true,
    brightness: Brightness.dark,
  ),
  themeMode: context.watch<SettingsProvider>().isDarkMode
      ? ThemeMode.dark
      : ThemeMode.light,
)
```

### Paso 10.4 — Soporte de idiomas (i18n básico)

Crear `lib/constants/strings_es.dart` y `lib/constants/strings_en.dart` con todos los textos de la UI. Usar un `SettingsProvider` para conmutar entre idiomas.

### Paso 10.5 — Modo Visitante — restricción a nivel 5

En `GameProvider`:

```dart
bool get isGuestMode => save.isGuest;

void _onLevelUp() {
  if (isGuestMode && save.currentLevel >= 5) {
    // Mostrar diálogo: "Regístrate para continuar"
    _showRegisterPrompt();
    return;
  }
  // Continuar normalmente
}
```

---

## 13. Dependencias Nuevas Requeridas

Agregar al bloque `dependencies` en `pubspec.yaml`:

```yaml
provider: ^6.1.2
shared_preferences: ^2.3.2
audioplayers: ^6.1.0
flutter_animate: ^4.5.0
google_fonts: ^6.2.1     # opcional, para tipografía RPG
```

> **Nota:** `flutter_local_notifications` y `timezone` ya están incluidos en el proyecto.

---

## 14. Estructura de Archivos Final

```
lib/
├── main.dart                          # Punto de entrada (ya existe, modificar)
├── notification_service.dart          # Servicio de notificaciones (ya existe, extender)
│
├── constants/
│   ├── game_constants.dart            # Números mágicos del juego
│   ├── sous_chefs_data.dart           # Datos de sous-chefs
│   ├── techniques_data.dart           # Datos de técnicas
│   ├── knives_data.dart               # Datos de cuchillos
│   ├── strings_es.dart                # Textos en español
│   └── strings_en.dart                # Textos en inglés
│
├── models/
│   ├── game_save.dart                 # Estado completo serializable
│   ├── chef_stats.dart                # Estadísticas del chef
│   ├── sous_chef.dart                 # Modelo de sous-chef
│   ├── knife.dart                     # Modelo de cuchillo
│   ├── amalgam.dart                   # Modelo de enemigo
│   ├── jewel.dart                     # Modelo de joya
│   └── relic.dart                     # Modelo de reliquia
│
├── providers/
│   ├── game_provider.dart             # Estado central del juego
│   └── settings_provider.dart         # Preferencias del usuario
│
├── services/
│   ├── game_save_service.dart         # Carga/guardado de partidas
│   └── audio_service.dart             # Sonidos y música
│
├── screens/
│   ├── splash_screen.dart             # (extraer de main.dart)
│   ├── home_public_screen.dart        # Menú principal sin sesión
│   ├── login_screen.dart              # (extraer de main.dart)
│   ├── register_screen.dart           # (extraer de main.dart)
│   ├── game_screen.dart               # Contenedor con BottomNav
│   └── tabs/
│       ├── combat_tab.dart            # Tab 1 — Arena de combate
│       ├── kitchen_tab.dart           # Tab 2 — Sous-chefs
│       ├── techniques_tab.dart        # Tab 3 — Mejoras del chef
│       ├── arsenal_tab.dart           # Tab 4 — Cuchillos, joyas, reliquias
│       └── profile_tab.dart           # Tab 5 — Perfil y configuración
│
└── widgets/
    ├── resource_bar.dart              # Barra de recursos superior
    ├── combat/
    │   ├── amalgam_display.dart       # Enemigo actual con barra de vida
    │   ├── floating_damage_text.dart  # Texto flotante de daño
    │   ├── level_indicator.dart       # Indicador de nivel y progreso
    │   ├── combat_stats_panel.dart    # DPS total, sous-chefs activos
    │   └── chef_stats_display.dart    # Stats del chef (abajo)
    ├── kitchen/
    │   └── sous_chef_card.dart        # Tarjeta de sous-chef
    ├── techniques/
    │   └── technique_card.dart        # Tarjeta de técnica mejorable
    ├── arsenal/
    │   ├── knife_inventory.dart       # Inventario de cuchillos
    │   ├── jewel_slots.dart           # Slots de joyas
    │   ├── relics_display.dart        # Lista de reliquias
    │   └── culinary_idols.dart        # Selección de ídolo activo
    └── profile/
        ├── player_stats_card.dart     # Datos del jugador
        ├── restart_section.dart       # Sistema de reinicio/prestige
        └── settings_section.dart      # Configuración de la app

assets/
├── sfx/                               # Efectos de sonido
│   ├── knife_throw.mp3
│   ├── critical_hit.mp3
│   ├── enemy_defeated.mp3
│   └── chest_open.mp3
└── music/
    └── kitchen_battle.mp3             # Música de fondo
```

---

## Orden de Implementación Sugerido

| Prioridad | Fase | Descripción | Tiempo estimado |
|-----------|------|-------------|-----------------|
| 1 | Fase 0 | Preparación, modelos y Provider | 2-3 días |
| 2 | Fase 1 | Zona pública y flujo de login | 1-2 días |
| 3 | Fase 2 | Navegación principal con BottomNav | 1 día |
| 4 | Fase 3 | Tab Combate (funcionalidad core) | 3-4 días |
| 5 | Fase 9 | Persistencia de datos | 1-2 días |
| 6 | Fase 4 | Tab Cocina (sous-chefs) | 2 días |
| 7 | Fase 5 | Tab Técnicas | 1-2 días |
| 8 | Fase 6 | Tab Arsenal | 2-3 días |
| 9 | Fase 7 | Tab Perfil + Reinicio | 2 días |
| 10 | Fase 8 | Notificaciones idle | 1 día |
| 11 | Fase 10 | Pulido (animaciones, sonido, i18n) | 3-5 días |

> **Total estimado:** 19-29 días de desarrollo individual.

---

*Documento generado para el proyecto `login_paleto` — Paleto Knife v2.0*  
*Última actualización: Marzo 2026*
