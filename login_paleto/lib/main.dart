import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

import 'background_worker.dart';
import 'models/game_save.dart';
import 'notification_service.dart';
import 'screens/game_screen.dart';
import 'screens/home_public_screen.dart';
import 'services/game_session_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  await NotificationService.instance.initialize();
  await NotificationService.instance.syncPeriodicNotificationsWithPreference();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paleto Knive',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class AppAuth {
  AppAuth._();

  static const String defaultEmail = 'usuario@palet.knive';
  static const String defaultPassword = 'paleto123';

  static String? _registeredName;
  static String? _registeredEmail;
  static String? _registeredPassword;

  static void registerAccount({
    required String name,
    required String email,
    required String password,
  }) {
    _registeredName = name;
    _registeredEmail = email;
    _registeredPassword = password;
  }

  static bool login(String email, String password) {
    final isDefaultAccount =
        email == defaultEmail && password == defaultPassword;
    final isRegisteredAccount =
        _registeredEmail != null &&
        _registeredPassword != null &&
        email == _registeredEmail &&
        password == _registeredPassword;

    return isDefaultAccount || isRegisteredAccount;
  }

  static String get loginSuccessMessage {
    if (_registeredName != null && _registeredName!.trim().isNotEmpty) {
      return 'Bienvenido, $_registeredName';
    }
    return 'Bienvenido';
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

    // Navegar a la zona publica despues de 4 segundos
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePublicScreen(),
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
              'Paleto Knive',
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
// FORMULARIO DE INICIO DE SESIÓN
// ============================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _validateAndLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Por favor completa todos los campos', Colors.red[700]!);
      return;
    }

    if (AppAuth.login(email, password)) {
      await GameSessionService.setLoggedUser(email);
      var save = await GameSessionService.loadSavedGameForUser(email);
      save ??= GameSave.newGame();
      await GameSessionService.saveGameForUser(email, save);

      _showSnackBar(
        '${AppAuth.loginSuccessMessage}! Login exitoso',
        Colors.green[700]!,
      );

      if (!mounted) {
        return;
      }

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => GameScreen(
                initialSave: save!,
                userEmail: email,
              ),
            ),
          );
        }
      });
    } else {
      _showSnackBar('Email o contraseña incorrectos', Colors.red[700]!);
    }
  }

  Future<void> _goToCreateAccount() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegisterScreen(),
      ),
    );
  }

  void _goToRecoverAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RecoverAccountScreen(),
      ),
    );
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
                Icon(
                  Icons.restaurant,
                  size: 100,
                  color: Colors.deepOrange[700],
                ),
                const SizedBox(height: 16),
                Text(
                  'Paleto Knive',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange[900],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Inicia sesión para continuar',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                // Email
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    hintText: 'usuario@palet.knive',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                // Contraseña
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword 
                            ? Icons.visibility_off 
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                // Botón Login
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _validateAndLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'INGRESAR',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _goToRecoverAccount,
                  icon: const Icon(Icons.help_outline),
                  label: const Text('¿Olvidaste tu cuenta? Recuperar'),
                ),
                TextButton.icon(
                  onPressed: _goToCreateAccount,
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Crear cuenta nueva'),
                ),
                // Botón Volver
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Volver'),
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
// REGISTRO DE CUENTA
// ============================================
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool get _hasMinLength => _passwordController.text.length >= 8;
  bool get _hasUppercase => RegExp(r'[A-Z]').hasMatch(_passwordController.text);
  bool get _hasLowercase => RegExp(r'[a-z]').hasMatch(_passwordController.text);
  bool get _hasNumber => RegExp(r'[0-9]').hasMatch(_passwordController.text);
  bool get _hasSpecialChar => RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(_passwordController.text);

  bool get _passwordRecommendationMet =>
      _hasMinLength && _hasUppercase && _hasLowercase && _hasNumber && _hasSpecialChar;

  int get _passwordChecksCompleted {
    int completed = 0;
    if (_hasMinLength) completed++;
    if (_hasUppercase) completed++;
    if (_hasLowercase) completed++;
    if (_hasNumber) completed++;
    if (_hasSpecialChar) completed++;
    return completed;
  }

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_refresh);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_refresh);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {});
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _passwordRuleTile(String text, bool isValid) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isValid ? Colors.green[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isValid ? Colors.green[200]! : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: isValid ? Colors.green[700] : Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isValid ? Colors.green[900] : Colors.grey[700],
                fontSize: 13,
                fontWeight: isValid ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          if (isValid)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.green[700],
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Listo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _createAccount() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar('Completa todos los campos para crear la cuenta.', Colors.red[700]!);
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar('Las contraseñas no coinciden.', Colors.red[700]!);
      return;
    }

    if (!_passwordRecommendationMet) {
      _showSnackBar(
        'Contraseña débil: sigue las recomendaciones mínimas sugeridas.',
        Colors.orange[800]!,
      );
      return;
    }

    AppAuth.registerAccount(
      name: name,
      email: email,
      password: password,
    );

    await GameSessionService.setLoggedUser(email);
    final save = GameSave.newGame();
    await GameSessionService.saveGameForUser(email, save);

    if (!mounted) {
      return;
    }

    _showSnackBar('Cuenta creada e inicio de sesion exitoso.', Colors.green[700]!);
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) {
        return;
      }
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => GameScreen(
            initialSave: save,
            userEmail: email,
          ),
        ),
        (route) => route.isFirst,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.deepOrange[700],
        title: const Text('Crear Cuenta'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre de usuario',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  hintText: 'nuevo@palet.knive',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                onChanged: (_) => setState(() {}),
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Crear contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                onChanged: (_) => setState(() {}),
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirmar contraseña',
                  prefixIcon: const Icon(Icons.lock_reset),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.deepOrange[100]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recomendación mínima sugerida de contraseña:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.deepOrange[900],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          _passwordRecommendationMet
                              ? Icons.verified
                              : Icons.rule,
                          size: 18,
                          color: _passwordRecommendationMet
                              ? Colors.green[700]
                              : Colors.orange[800],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Cumplimiento: $_passwordChecksCompleted/5 requisitos',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _passwordRecommendationMet
                                  ? Colors.green[800]
                                  : Colors.orange[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _passwordRuleTile('Al menos 8 caracteres', _hasMinLength),
                    const SizedBox(height: 6),
                    _passwordRuleTile('Una letra mayúscula', _hasUppercase),
                    const SizedBox(height: 6),
                    _passwordRuleTile('Una letra minúscula', _hasLowercase),
                    const SizedBox(height: 6),
                    _passwordRuleTile('Un número', _hasNumber),
                    const SizedBox(height: 6),
                    _passwordRuleTile('Un carácter especial', _hasSpecialChar),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          _confirmPasswordController.text.isNotEmpty &&
                                  _confirmPasswordController.text == _passwordController.text
                              ? Icons.check_circle
                              : Icons.info_outline,
                          size: 18,
                          color: _confirmPasswordController.text.isNotEmpty &&
                                  _confirmPasswordController.text == _passwordController.text
                              ? Colors.green[700]
                              : Colors.blueGrey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _confirmPasswordController.text.isEmpty
                                ? 'Confirma tu contraseña para validar coincidencia.'
                                : _confirmPasswordController.text == _passwordController.text
                                    ? 'Confirmación correcta: contraseñas coinciden.'
                                    : 'Las contraseñas aún no coinciden.',
                            style: TextStyle(
                              fontSize: 12,
                              color: _confirmPasswordController.text.isEmpty
                                  ? Colors.blueGrey[700]
                                  : _confirmPasswordController.text == _passwordController.text
                                      ? Colors.green[800]
                                      : Colors.red[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _createAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'CREAR CUENTA',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// RECUPERAR CUENTA
// ============================================
class RecoverAccountScreen extends StatefulWidget {
  const RecoverAccountScreen({super.key});

  @override
  State<RecoverAccountScreen> createState() => _RecoverAccountScreenState();
}

class _RecoverAccountScreenState extends State<RecoverAccountScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _recoverAccount() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnackBar('Ingresa tu correo para recuperar tu cuenta.', Colors.red[700]!);
      return;
    }

    _showSnackBar(
      'Si el correo existe, te enviamos instrucciones para recuperar tu cuenta.',
      Colors.blue[700]!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.deepOrange[700],
        title: const Text('Recuperar Cuenta'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text(
                'Ingresa tu correo y te enviaremos los pasos de recuperación.',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  hintText: 'usuario@palet.knive',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _recoverAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'RECUPERAR CUENTA',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// DASHBOARD (Después del login)
// ============================================
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.deepOrange[700],
        title: const Text('Dashboard'),
        centerTitle: true,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePublicScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.dashboard,
              size: 100,
              color: Colors.deepOrange[700],
            ),
            const SizedBox(height: 24),
            const Text(
              'Bienvenido al Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Has iniciado sesión correctamente',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameScreen(
                      initialSave: GameSave.newGame(),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Ir al Juego'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// PANTALLA DEL JUEGO
// ============================================
class LegacyGameScreen extends StatefulWidget {
  final String title;

  const LegacyGameScreen({
    super.key,
    required this.title,
  });

  @override
  State<LegacyGameScreen> createState() => _LegacyGameScreenState();
}

class _LegacyGameScreenState extends State<LegacyGameScreen> {
  int _currentLevel = 1;
  static const int maxLevelForNormal = 10;
  static const int maxLevelForVisitor = 5;
  bool _lifeNotificationScheduled = false;

  bool get _isVisitorMode => widget.title == 'Modo Visitante';
  int get _levelLimit => _isVisitorMode ? maxLevelForVisitor : maxLevelForNormal;

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

  void _showLimitPopUp() {
    final modeLabel = _isVisitorMode ? 'Modo Visitante' : 'Modo Normal';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          icon: Icon(
            Icons.lock_outline,
            color: Colors.orange[800],
            size: 50,
          ),
          title: const Text('Límite Alcanzado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$modeLabel: Solo puedes jugar hasta el Nivel $_levelLimit',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                _isVisitorMode
                    ? 'Para desbloquear más niveles, inicia sesión en tu cuenta.'
                    : 'Has alcanzado el máximo de niveles permitidos para este modo.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Entendido'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (_isVisitorMode) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange[700],
              ),
              child: Text(_isVisitorMode ? 'Iniciar Sesión' : 'Aceptar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _scheduleLifeNotificationIfNeeded() async {
    if (_lifeNotificationScheduled) {
      return;
    }

    await NotificationService.instance.scheduleLifeAvailableNotification();
    if (!mounted) {
      return;
    }

    setState(() {
      _lifeNotificationScheduled = true;
    });

    _showGameSnackBar(
      'Te avisaremos por notificacion cuando tu vida este disponible (1 min).',
      Colors.blue[700]!,
    );
  }

  void _nextLevel() {
    if (_currentLevel >= _levelLimit) {
      _scheduleLifeNotificationIfNeeded();
      _showLimitPopUp();
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