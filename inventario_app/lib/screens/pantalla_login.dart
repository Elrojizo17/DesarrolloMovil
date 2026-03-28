import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});
  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthService();
  bool _cargando = false;
  bool _esRegistro = false;

  Future<void> _submit() async {
    if (_email.text.isEmpty || _password.text.isEmpty) return;
    setState(() => _cargando = true);
    try {
      if (_esRegistro) {
        await _auth.registrar(_email.text.trim(), _password.text);
      } else {
        await _auth.login(_email.text.trim(), _password.text);
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Icon(Icons.inventory_2_rounded,
                  size: 72, color: Colors.indigo),
              const SizedBox(height: 8),
              const Text('Inventario App',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(
                _esRegistro ? 'Crea tu cuenta' : 'Inicia sesión',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _cargando ? null : _submit,
                  child: _cargando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_esRegistro ? 'Crear cuenta' : 'Iniciar sesión'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    setState(() => _esRegistro = !_esRegistro),
                child: Text(_esRegistro
                    ? '¿Ya tienes cuenta? Inicia sesión'
                    : '¿No tienes cuenta? Regístrate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}