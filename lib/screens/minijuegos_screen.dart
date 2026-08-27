import 'dart:math';

import 'package:flutter/material.dart';

class MemoramaScreen extends StatefulWidget {
  const MemoramaScreen({super.key});

  @override
  State<MemoramaScreen> createState() => _MemoramaScreenState();
}

class _MemoramaScreenState extends State<MemoramaScreen> {
  final List<List<IconData>> _niveles = [
    [Icons.eco, Icons.water_drop, Icons.recycling, Icons.wb_sunny, Icons.forest, Icons.pets],
    [Icons.eco, Icons.water_drop, Icons.recycling, Icons.wb_sunny, Icons.forest, Icons.pets, Icons.energy_savings_leaf, Icons.compost],
    [Icons.eco, Icons.water_drop, Icons.recycling, Icons.wb_sunny, Icons.forest, Icons.pets, Icons.energy_savings_leaf, Icons.compost, Icons.air, Icons.public],
  ];
  late List<IconData> _iconos;
  final Random _random = Random();
  late List<int> _baraja;
  final List<int> _descubiertas = [];
  final Set<int> _parejas = {};
  bool _bloqueado = false;
  int _movimientos = 0;
  int _nivel = 1;

  @override
  void initState() {
    super.initState();
    _reiniciar();
  }

  void _reiniciar() {
    _iconos = [..._niveles[_nivel - 1], ..._niveles[_nivel - 1]];
    _baraja = List<int>.generate(_iconos.length, (index) => index);
    _baraja.shuffle(_random);
    _descubiertas.clear();
    _parejas.clear();
    _bloqueado = false;
    _movimientos = 0;
  }

  Future<void> _tocarCarta(int posicion) async {
    if (_bloqueado ||
        _parejas.contains(posicion) ||
        _descubiertas.contains(posicion)) {
      return;
    }
    setState(() => _descubiertas.add(posicion));
    if (_descubiertas.length < 2) return;

    _movimientos++;
    _bloqueado = true;
    final primera = _baraja[_descubiertas[0]];
    final segunda = _baraja[_descubiertas[1]];
    final coinciden = _iconos[primera] == _iconos[segunda];
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() {
      if (coinciden) _parejas.addAll(_descubiertas);
      _descubiertas.clear();
      _bloqueado = false;
    });
    if (_parejas.length == _baraja.length && mounted) {
      if (_nivel < _niveles.length) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('¡Nivel $_nivel completado!')));
        setState(() => _nivel++);
        _reiniciar();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Completaste todos los niveles!')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memorama Ambiental'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Movimientos: $_movimientos'),
                Text('Nivel $_nivel · ${_parejas.length ~/ 2}/${_iconos.length ~/ 2} parejas'),
                IconButton(
                  onPressed: () => setState(_reiniciar),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _baraja.length,
              itemBuilder: (_, posicion) {
                final visible =
                    _descubiertas.contains(posicion) ||
                    _parejas.contains(posicion);
                return InkWell(
                  onTap: () => _tocarCarta(posicion),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: visible ? Colors.green[100] : Colors.green[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      visible
                          ? _iconos[_baraja[posicion]]
                          : Icons.question_mark,
                      color: visible ? Colors.green[800] : Colors.white,
                      size: 34,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SopaCamilistaScreen extends StatefulWidget {
  const SopaCamilistaScreen({super.key});

  @override
  State<SopaCamilistaScreen> createState() => _SopaCamilistaScreenState();
}

class _SopaCamilistaScreenState extends State<SopaCamilistaScreen> {
  final List<List<String>> _nivelesPalabras = [
    ['AGUA', 'VERDE', 'FLORA', 'RECICLA'],
    ['SOLAR', 'BOSQUE', 'ECOTIPO', 'ARBOL'],
    ['AGUA', 'VERDE', 'FLORA', 'RECICLA', 'SOLAR', 'BOSQUE', 'ECOTIPO', 'ARBOL'],
  ];
  int _nivel = 1;
  List<String> get _palabras => _nivelesPalabras[_nivel - 1];
  final List<String> _letras = [
    'A',
    'G',
    'U',
    'A',
    'R',
    'E',
    'C',
    'I',
    'C',
    'L',
    'A',
    'V',
    'E',
    'R',
    'D',
    'E',
    'F',
    'L',
    'O',
    'R',
    'A',
    'S',
    'O',
    'L',
    'A',
    'R',
    'B',
    'O',
    'S',
    'Q',
    'U',
    'E',
    'E',
    'C',
    'O',
    'T',
    'I',
    'P',
    'O',
    'A',
    'G',
    'U',
    'A',
    'M',
    'A',
    'R',
    'E',
    'A',
    'R',
    'B',
    'O',
    'L',
    'V',
    'I',
    'D',
    'A',
    'S',
    'O',
    'L',
    'A',
    'R',
    'V',
    'E',
    'R',
    'D',
    'E',
  ];
  final Set<int> _seleccionadas = {};
  final Set<String> _encontradas = {};

  void _seleccionar(int index) {
    setState(() {
      if (_seleccionadas.contains(index)) {
        _seleccionadas.remove(index);
      } else {
        _seleccionadas.add(index);
      }
      final seleccion = _seleccionadas.toList()..sort();
      final texto = seleccion.map((item) => _letras[item]).join();
      for (final palabra in _palabras) {
        if (texto.contains(palabra)) _encontradas.add(palabra);
      }
    });
    if (_encontradas.length == _palabras.length) {
      if (_nivel < _nivelesPalabras.length) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('¡Nivel $_nivel completado!')));
        setState(() {
          _nivel++;
          _seleccionadas.clear();
          _encontradas.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Encontraste todas las palabras!')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sopa Camilista'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Nivel $_nivel · Encuentra las palabras ambientales.',
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _palabras
                .map(
                  (palabra) => Chip(
                    avatar: Icon(
                      _encontradas.contains(palabra)
                          ? Icons.check
                          : Icons.search,
                      size: 16,
                    ),
                    label: Text(palabra),
                    backgroundColor: _encontradas.contains(palabra)
                        ? Colors.green[100]
                        : null,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: _letras.length,
            itemBuilder: (_, index) => InkWell(
              onTap: () => _seleccionar(index),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _seleccionadas.contains(index)
                      ? Colors.green[700]
                      : Colors.green[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _letras[index],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _seleccionadas.contains(index)
                        ? Colors.white
                        : Colors.green[900],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => setState(() {
              _seleccionadas.clear();
              _encontradas.clear();
            }),
            icon: const Icon(Icons.refresh),
            label: const Text('Reiniciar sopa'),
          ),
        ],
      ),
    );
  }
}

class TriviaVerdeScreen extends StatefulWidget {
  const TriviaVerdeScreen({super.key});

  @override
  State<TriviaVerdeScreen> createState() => _TriviaVerdeScreenState();
}

class _Pregunta {
  final String texto;
  final List<String> opciones;
  final int correcta;

  const _Pregunta(this.texto, this.opciones, this.correcta);
}

class _TriviaVerdeScreenState extends State<TriviaVerdeScreen> {
  final List<_Pregunta> _preguntas = const [
    _Pregunta('¿En qué contenedor va una botella de plástico?', [
      'Verde',
      'Blanco',
      'Negro',
    ], 1),
    _Pregunta('¿Qué recurso debemos ahorrar al cerrar la llave?', [
      'Agua',
      'Papel',
      'Metal',
    ], 0),
    _Pregunta('¿Qué acción ayuda más al planeta?', [
      'Reutilizar',
      'Desperdiciar',
      'Quemar residuos',
    ], 0),
    _Pregunta('¿Qué podemos hacer con una botella reutilizable?', [
      'Usarla varias veces',
      'Botarla siempre',
      'Quemarla',
    ], 0),
    _Pregunta('¿Qué residuo debe ir al contenedor negro?', [
      'Residuos no aprovechables',
      'Cartón limpio',
      'Botellas de vidrio',
    ], 0),
    _Pregunta('¿Qué fuente produce energía usando el sol?', [
      'Solar',
      'Sonora',
      'Manual',
    ], 0),
    _Pregunta('¿Por qué son importantes los árboles?', [
      'Ayudan a producir oxígeno',
      'Aumentan la basura',
      'Contaminan el agua',
    ], 0),
    _Pregunta('¿Cuál es una buena forma de ahorrar energía?', [
      'Apagar las luces que no usamos',
      'Dejar todo encendido',
      'Abrir el refrigerador sin necesidad',
    ], 0),
    _Pregunta('¿Qué significa reutilizar?', [
      'Usar un objeto nuevamente',
      'Botarlo después de usarlo',
      'Quemarlo',
    ], 0),
    _Pregunta('¿Qué debemos hacer con una llave que gotea?', [
      'Repararla',
      'Dejarla abierta',
      'Ignorarla',
    ], 0),
  ];
  int _indice = 0;
  int _puntos = 0;
  int? _respuesta;

  void _responder(int opcion) {
    if (_respuesta != null) return;
    setState(() {
      _respuesta = opcion;
      if (opcion == _preguntas[_indice].correcta) _puntos++;
    });
  }

  void _siguiente() {
    if (_indice == _preguntas.length - 1) {
      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Trivia terminada'),
          content: Text('Obtuviste $_puntos de ${_preguntas.length} puntos.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _indice = 0;
                  _puntos = 0;
                  _respuesta = null;
                });
              },
              child: const Text('Jugar de nuevo'),
            ),
          ],
        ),
      );
      return;
    }
    setState(() {
      _indice++;
      _respuesta = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pregunta = _preguntas[_indice];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trivia Verde'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Pregunta ${_indice + 1} de ${_preguntas.length}',
            style: TextStyle(
              color: Colors.green[800],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            pregunta.texto,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ...pregunta.opciones.asMap().entries.map((entry) {
            final opcion = entry.key;
            final seleccionada = _respuesta == opcion;
            final correcta = _respuesta != null && opcion == pregunta.correcta;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _responder(opcion),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: correcta
                        ? Colors.green[100]
                        : seleccionada
                        ? Colors.red[100]
                        : null,
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.centerLeft,
                  ),
                  child: Text(entry.value),
                ),
              ),
            );
          }),
          if (_respuesta != null) ...[
            const SizedBox(height: 12),
            Text(
              _respuesta == pregunta.correcta
                  ? '¡Correcto!'
                  : 'Respuesta incorrecta',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _respuesta == pregunta.correcta
                    ? Colors.green[800]
                    : Colors.red[700],
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _siguiente,
              icon: const Icon(Icons.arrow_forward),
              label: Text(
                _indice == _preguntas.length - 1
                    ? 'Ver resultado'
                    : 'Siguiente',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
