import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chef Game Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

// ============================================
// SPLASH SCREEN CON LOGO ANIMADO
// ============================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );

    _animationController.forward();

    // Navegar a HomeScreen después de 4 segundos
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange[700],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animado: Chef con cuchillo
            ScaleTransition(
              scale: _scaleAnimation,
              child: RotationTransition(
                turns: _rotationAnimation,
                child: Icon(
                  Icons.restaurant,
                  size: 120,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Chef Game',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cargando...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// PANTALLA DE INICIO
// ============================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ============================================
  // MÉTODO: SnackBar Básico
  // ============================================
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

  // ============================================
  // MÉTODO: SnackBar de Éxito (Verde)
  // ============================================
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

  // ============================================
  // MÉTODO: SnackBar de Advertencia (Naranja)
  // ============================================
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

  // ============================================
  // ACCIONES DE BOTONES
  // ============================================
  void _nuevaPartida() {
    _showSuccessSnackBar('¡Nueva partida iniciada! Bienvenido al Chef Game');
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const GameScreen(title: 'Nueva Partida'),
          ),
        );
      }
    });
  }

  void _continuarPartida() {
    _showSnackBar(
      'Cargando última partida guardada...',
      Colors.blue[700]!,
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _showSuccessSnackBar('Partida restaurada correctamente');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const GameScreen(title: 'Continuar Partida'),
          ),
        );
      }
    });
  }

  void _modoVisitante() {
    _showWarningSnackBar(
      'Modo Visitante: Puedes jugar hasta el Nivel 5 sin guardar progreso',
    );
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const GameScreen(title: 'Modo Visitante'),
          ),
        );
      }
    });
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
                // Logo o Icono
                Icon(
                  Icons.restaurant,
                  size: 100,
                  color: Colors.deepOrange[700],
                ),
                const SizedBox(height: 16),

                // Título
                Text(
                  'Chef Game',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange[900],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Zona Pública (Sin sesión)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),

                // Botón: Nueva Partida
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
                      elevation: 4,
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

                // Botón: Continuar Partida
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
                      elevation: 4,
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

                // Botón: Modo Visitante
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
                      elevation: 4,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================
// PANTALLA DEL JUEGO
// ============================================
class GameScreen extends StatefulWidget {
  final String title;

  const GameScreen({
    super.key,
    required this.title,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _currentLevel = 1;
  static const int maxLevelForVisitor = 5;

  void _showGameSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _nextLevel() {
    if (widget.title == 'Modo Visitante' && _currentLevel >= maxLevelForVisitor) {
      _showGameSnackBar(
        'Límite alcanzado: Modo Visitante solo permite hasta Nivel $maxLevelForVisitor',
        Colors.orange[800]!,
      );
      return;
    }

    setState(() {
      _currentLevel++;
    });

    _showGameSnackBar(
      'Avanzaste al Nivel $_currentLevel',
      Colors.green[700]!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.deepOrange[700],
        title: Text(widget.title),
        centerTitle: true,
        elevation: 4,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.gamepad,
              size: 100,
              color: Colors.deepOrange[700],
            ),
            const SizedBox(height: 24),
            Text(
              'Nivel $_currentLevel',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange[900],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Juego en progreso...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _nextLevel,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Siguiente Nivel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}