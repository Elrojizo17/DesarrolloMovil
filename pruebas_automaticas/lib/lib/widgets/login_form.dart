import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  final Function(String, String) onLogin;

  const LoginForm({Key? key, required this.onLogin}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Correo electrónico'),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Contraseña'),
            obscureText: true,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              widget.onLogin(_emailController.text, _passwordController.text);
            },
            child: Text('Ingresar'),
          ),
        ],
      ),
    );
  }
}
