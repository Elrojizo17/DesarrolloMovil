import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnackBar Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para los campos de texto
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Credenciales de prueba
  final String _correctEmail = 'estudiante@univalle.edu.co';
  final String _correctPassword = 'moviles2024';

  // Variable para mostrar/ocultar contraseña
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================
  // MÉTODO 1: SnackBar Básico (Simple)
  // ============================================
  void _showBasicSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================
  // MÉTODO 2: SnackBar de Error (Rojo)
  // ============================================
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // ============================================
  // MÉTODO 3: SnackBar de Éxito (Verde)
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
  // MÉTODO 4: SnackBar con Acción (Undo)
  // ============================================
  void _showSnackBarWithAction() {
    // Primero limpiamos cualquier SnackBar anterior
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('¿Olvidaste tu contraseña?'),
        backgroundColor: Colors.orange[800],
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'RECUPERAR',
          textColor: Colors.white,
          onPressed: () {
            // Mostrar otro SnackBar al presionar la acción
            _showBasicSnackBar('Se envió un correo de recuperación');
          },
        ),
      ),
    );
  }

  // ============================================
  // MÉTODO 5: SnackBar Personalizado (Estilo moderno)
  // ============================================
  void _showCustomSnackBar(String title, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(message),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 6,
      ),
    );
  }

  // ============================================
  // LÓGICA DE LOGIN
  // ============================================
  void _validateAndLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Validar campos vacíos
    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackBar('Por favor completa todos los campos');
      return;
    }

    // Validar formato de email básico
    if (!email.contains('@') || !email.contains('.')) {
      _showCustomSnackBar(
        'Email inválido',
        'Por favor ingresa un correo válido',
        Colors.orange[800]!,
      );
      return;
    }

    // Validar credenciales
    if (email == _correctEmail && password == _correctPassword) {
      _showSuccessSnackBar('¡Bienvenido! Login exitoso');
      
      // Aquí iría la navegación a la siguiente pantalla
      // Navigator.pushReplacement(...);
    } else {
      _showErrorSnackBar('Email o contraseña incorrectos');
    }
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
                  Icons.account_circle,
                  size: 100,
                  color: Colors.deepPurple[700],
                ),
                const SizedBox(height: 16),
                
                // Título
                Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple[900],
                  ),
                ),
                const SizedBox(height: 32),

                // Campo de Email
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    hintText: 'estudiante@univalle.edu.co',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de Contraseña
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
                const SizedBox(height: 8),

                // Link de olvidé contraseña
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showSnackBarWithAction,
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                ),
                const SizedBox(height: 24),

                // Botón de Login
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _validateAndLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple[700],
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
                const SizedBox(height: 32),

                // Divider
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('O prueba otros SnackBar'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),

                // Botones de demostración
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showBasicSnackBar('Mensaje simple'),
                      icon: const Icon(Icons.message),
                      label: const Text('Básico'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showSuccessSnackBar('Operación exitosa'),
                      icon: const Icon(Icons.check),
                      label: const Text('Éxito'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showErrorSnackBar('Ha ocurrido un error'),
                      icon: const Icon(Icons.error),
                      label: const Text('Error'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showCustomSnackBar(
                        'Atención',
                        'Este es un mensaje personalizado con más detalle',
                        Colors.purple,
                      ),
                      icon: const Icon(Icons.style),
                      label: const Text('Personalizado'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}