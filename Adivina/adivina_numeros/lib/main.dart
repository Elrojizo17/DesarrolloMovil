import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _modoOscuro = true;

  void _cambiarTema(bool value) {
    setState(() {
      _modoOscuro = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Adivina el Número PRO',
      themeMode: _modoOscuro ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: MyHomePage(
        modoOscuro: _modoOscuro,
        onTemaChanged: _cambiarTema,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final bool modoOscuro;
  final Function(bool) onTemaChanged;

  const MyHomePage({
    super.key,
    required this.modoOscuro,
    required this.onTemaChanged,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {

  late int _numeroSecreto;

  int _intentos = 0;
  int _intentosRestantes = 7;
  int _maxIntentos = 7;
  int _rangoMaximo = 50;

  bool _modoDificil = false;
  bool _juegoTerminado = false;
  bool _juegoPerdido = false;

  int _record = 999;

  String _mensaje = '';
  final TextEditingController _controller = TextEditingController();
  final List<int> _historial = [];

  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  final List<String> _mensajesIniciales = [
    '🎲 ¿Listo para el reto?',
    '🔥 Hoy puede ser tu día de suerte',
    '🧠 Usa tu intuición',
    '🎯 ¡Vamos campeón!'
  ];

  @override
  void initState() {
    super.initState();
    _cargarRecord();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _bounceAnimation =
        Tween<double>(begin: 1, end: 1.4).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _iniciarJuego();
  }

  Future<void> _cargarRecord() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _record = prefs.getInt('record') ?? 999;
    });
  }

  Future<void> _guardarRecord() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('record', _record);
  }

  void _iniciarJuego() {
    setState(() {
      _numeroSecreto = Random().nextInt(_rangoMaximo) + 1;
      _intentos = 0;
      _intentosRestantes = _maxIntentos;
      _mensaje =
          _mensajesIniciales[Random().nextInt(_mensajesIniciales.length)];
      _juegoTerminado = false;
      _juegoPerdido = false;
      _historial.clear();
      _controller.clear();
    });
  }

  void _verificar() {
    if (_juegoTerminado || _juegoPerdido) return;

    final numero = int.tryParse(_controller.text);
    if (numero == null) return;

    setState(() {
      _historial.add(numero);
      _intentos++;
      _intentosRestantes--;
      _controller.clear();

      if (numero == _numeroSecreto) {
        _mensaje = '🏆 ¡INCREÍBLE! Lo lograste en $_intentos intentos';
        _juegoTerminado = true;

        if (_intentos < _record) {
          _record = _intentos;
          _guardarRecord();
        }

        _bounceController.forward(from: 0);
      } else if (_intentosRestantes == 0) {
        _mensaje = '💀 Game Over... era $_numeroSecreto';
        _juegoPerdido = true;
      } else if (numero < _numeroSecreto) {
        _mensaje = '📈 Más alto';
      } else {
        _mensaje = '📉 Más bajo';
      }
    });
  }

  double _progreso() => _intentosRestantes / _maxIntentos;

  Color _colorProgreso() {
    if (_progreso() > 0.6) return Colors.greenAccent;
    if (_progreso() > 0.3) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  void _cambiarDificultad(bool value) {
    setState(() {
      _modoDificil = value;

      if (_modoDificil) {
        _rangoMaximo = 200;
        _maxIntentos = 4;
      } else {
        _rangoMaximo = 50;
        _maxIntentos = 7;
      }
    });

    _iniciarJuego();
  }

  @override
  void dispose() {
    _controller.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final gradient = widget.modoOscuro
        ? const LinearGradient(
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [
              Color(0xFFE3F2FD),
              Color(0xFFFFFFFF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );

    final textColor =
        widget.modoOscuro ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [

                const SizedBox(height: 10),

                Text(
                  "🎯 Adivina el Número",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "🏆 Récord: ${_record == 999 ? "-" : _record} intentos",
                  style: TextStyle(color: textColor.withValues(alpha: 0.7)),
                ),

                const SizedBox(height: 10),

                // SWITCH TEMA
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.light_mode,
                      color: textColor.withValues(alpha: 0.7)),
                    Switch(
                      value: widget.modoOscuro,
                      onChanged: widget.onTemaChanged,
                    ),
                    Icon(Icons.dark_mode,
                      color: textColor.withValues(alpha: 0.7)),
                  ],
                ),

                // SWITCH DIFICULTAD
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Fácil",
                        style: TextStyle(color: textColor)),
                    Switch(
                      value: _modoDificil,
                      onChanged: _cambiarDificultad,
                    ),
                    Text("Difícil",
                        style: TextStyle(color: textColor)),
                  ],
                ),

                const SizedBox(height: 15),

                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: _progreso(),
                    minHeight: 12,
                    backgroundColor: Colors.white12,
                    valueColor:
                        AlwaysStoppedAnimation(_colorProgreso()),
                  ),
                ),

                const SizedBox(height: 20),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: widget.modoOscuro
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _mensaje,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 20, color: textColor),
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: "Ingresa tu número",
                    hintStyle:
                      TextStyle(color: textColor.withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: widget.modoOscuro
                        ? Colors.white10
                        : Colors.black12,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _verificar(),
                ),

                const SizedBox(height: 20),

                Wrap(
                  spacing: 8,
                  children: _historial.map((intento) {
                    Color color;
                    if (intento < _numeroSecreto) {
                      color = Colors.blueAccent;
                    } else if (intento > _numeroSecreto) {
                      color = Colors.redAccent;
                    } else {
                      color = Colors.greenAccent;
                    }

                    return Chip(
                      label: Text(intento.toString()),
                      backgroundColor:
                          color.withValues(alpha: 0.2),
                      labelStyle:
                          TextStyle(color: color),
                    );
                  }).toList(),
                ),

                const Spacer(),

                ScaleTransition(
                  scale: _bounceAnimation,
                  child: const Icon(Icons.emoji_events,
                      size: 50,
                      color: Colors.amber),
                ),

                if (_juegoTerminado || _juegoPerdido)
                  ElevatedButton(
                    onPressed: _iniciarJuego,
                    child: const Text("Jugar de nuevo"),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}