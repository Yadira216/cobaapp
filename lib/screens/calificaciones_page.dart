
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CalificacionesPage extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const CalificacionesPage({
    super.key,
    required this.usuario,
  });

  @override
  State<CalificacionesPage> createState() => _CalificacionesPageState();
}

class _CalificacionesPageState extends State<CalificacionesPage> {
  static const Color vino = Color(0xFF7B1735);
  static const Color vinoOscuro = Color(0xFF4A0D1F);
  static const Color vinoClaro = Color(0xFF9A3A5B);
  static const Color verde = Color(0xFF55A630);
  static const Color fondo = Color(0xFFF6F7F9);

  static const String endpoint =
      'http://10.35.16.16/saesc/android/android.php';

  bool cargando = true;
  String? error;
  String promedio = '—';

  List<dynamic> materias = [];

  @override
  void initState() {
    super.initState();
    obtenerCalificaciones();
  }

  Future<void> obtenerCalificaciones() async {
    if (mounted) {
      setState(() {
        cargando = true;
        error = null;
      });
    }

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'accion': 'calificaciones',
          'id_alumno': widget.usuario['id_alumno'],
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'El servidor respondió con código ${response.statusCode}.',
        );
      }

      final data = jsonDecode(response.body);

      if (data['status'] != 'success') {
        throw Exception(
          data['mensaje']?.toString() ??
              'No fue posible obtener las calificaciones.',
        );
      }

      if (!mounted) return;

      setState(() {
        promedio = data['promedio']?.toString() ?? '—';

        if (data['materias'] is List) {
          materias = data['materias'];
        } else {
          materias = [];
        }

        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargando = false;
        error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  String texto(dynamic valor) {
    if (valor == null) {
      return '—';
    }

    final texto = valor.toString().trim();

    if (texto.isEmpty || texto.toLowerCase() == 'null') {
      return '—';
    }

    return texto;
  }

  String nombreSemestre(dynamic semestre) {
    final valor = int.tryParse(
      semestre?.toString() ?? '',
    );

    if (valor == null || valor <= 0) {
      return 'Semestre';
    }

    return 'Semestre $valor';
  }

  Map<int, List<dynamic>> agruparPorSemestre() {
    final Map<int, List<dynamic>> grupos = {};

    for (final materia in materias) {
      final semestre = int.tryParse(
            materia['semes']?.toString() ?? '',
          ) ??
          0;

      grupos.putIfAbsent(semestre, () => []);
      grupos[semestre]!.add(materia);
    }

    final ordenados = Map.fromEntries(
      grupos.entries.toList()
        ..sort(
          (a, b) => a.key.compareTo(b.key),
        ),
    );

    return ordenados;
  }

  Color colorFinal(dynamic valor) {
    final nota = double.tryParse(
      valor?.toString() ?? '',
    );

    if (nota == null) {
      return Colors.grey.shade700;
    }

    if (nota < 6) {
      return Colors.red.shade700;
    }

    return verde;
  }

  Color fondoFinal(dynamic valor) {
    final nota = double.tryParse(
      valor?.toString() ?? '',
    );

    if (nota == null) {
      return Colors.grey.shade100;
    }

    if (nota < 6) {
      return Colors.red.shade50;
    }

    return Colors.green.shade50;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      body: SafeArea(
        child: Column(
          children: [
            _encabezado(),
            Expanded(
              child: _contenidoPrincipal(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _encabezado() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        8,
        12,
        18,
        18,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            vinoOscuro,
            vino,
            vinoClaro,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          Material(
            color: Colors.white.withOpacity(0.13),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(14),
              child: const SizedBox(
                width: 46,
                height: 46,
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calificaciones',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Consulta de rendimiento académico',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: cargando
                ? const SizedBox(
                    key: ValueKey('loading'),
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Material(
                    key: const ValueKey('refresh'),
                    color: Colors.white.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: obtenerCalificaciones,
                      borderRadius: BorderRadius.circular(14),
                      child: const SizedBox(
                        width: 46,
                        height: 46,
                        child: Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _contenidoPrincipal() {
    if (cargando && materias.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: vino,
        ),
      );
    }

    if (error != null) {
      return _pantallaError();
    }

    return RefreshIndicator(
      color: vino,
      onRefresh: obtenerCalificaciones,
      child: materias.isEmpty
          ? _sinCalificaciones()
          : _contenido(),
    );
  }

  Widget _contenido() {
    final grupos = agruparPorSemestre();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        30,
      ),
      children: [
        _animarEntrada(
          0,
          _encabezadoAlumno(),
        ),

        const SizedBox(height: 14),

        _animarEntrada(
          1,
          _tarjetaPromedio(),
        ),

        const SizedBox(height: 12),

        _animarEntrada(
          2,
          _tarjetaMateriasMostradas(),
        ),

        const SizedBox(height: 24),

        ...grupos.entries.map(
          (grupo) {
            return Padding(
              padding: const EdgeInsets.only(
                bottom: 25,
              ),
              child: _animarEntrada(
                grupo.key + 3,
                _tablaSemestre(
                  grupo.key,
                  grupo.value,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _animarEntrada(
    int indice,
    Widget child,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(
        begin: 0,
        end: 1,
      ),
      duration: Duration(
        milliseconds: 400 + (indice * 70),
      ),
      curve: Curves.easeOutCubic,
      builder: (
        context,
        value,
        child,
      ) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(
              0,
              18 * (1 - value),
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _encabezadoAlumno() {
    final nombre = texto(
      widget.usuario['nombre'],
    );

    final matricula = texto(
      widget.usuario['matricula'],
    );

    final grupo = texto(
      widget.usuario['grupo'],
    );

    final turno = texto(
      widget.usuario['turno'],
    );

    final foto = widget.usuario['foto']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _decoracionTarjeta(),
      child: Row(
        children: [
          Hero(
            tag: 'foto-alumno',
            child: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF1F1F1),
                border: Border.all(
                  color: vino.withOpacity(0.15),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: foto.isNotEmpty
                    ? Image.memory(
                        base64Decode(
                          foto.contains(',')
                              ? foto.split(',').last
                              : foto,
                        ),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return const Icon(
                            Icons.person_rounded,
                            color: vino,
                            size: 30,
                          );
                        },
                      )
                    : const Icon(
                        Icons.person_rounded,
                        color: vino,
                        size: 30,
                      ),
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF252525),
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.badge_outlined,
                      size: 14,
                      color: vino,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        matricula,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  'Grupo $grupo  •  Turno $turno',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaPromedio() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            vino,
            vinoOscuro,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: vino.withOpacity(0.20),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.auto_graph_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Promedio',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Promedio académico',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(
              begin: 0,
              end: 1,
            ),
            duration: const Duration(
              milliseconds: 700,
            ),
            curve: Curves.easeOutBack,
            builder: (
              context,
              value,
              child,
            ) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: Text(
              promedio,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 31,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaMateriasMostradas() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: _decoracionTarjeta(),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: verde.withOpacity(0.11),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: verde,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Materias mostradas',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF333333),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Total de materias registradas',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(
              milliseconds: 300,
            ),
            transitionBuilder: (
              child,
              animation,
            ) {
              return ScaleTransition(
                scale: animation,
                child: child,
              );
            },
            child: Text(
              materias.length.toString(),
              key: ValueKey(materias.length),
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w900,
                color: vino,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tablaSemestre(
    int semestre,
    List<dynamic> lista,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 5,
              height: 26,
              decoration: BoxDecoration(
                color: vino,
                borderRadius:
                    BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 9),
            Text(
              nombreSemestre(semestre),
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: vino,
              ),
            ),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: vino.withOpacity(0.07),
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: Text(
                '${lista.length} materias',
                style: const TextStyle(
                  fontSize: 10,
                  color: vino,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        Container(
          decoration: _decoracionTarjeta(),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(19),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _construirTabla(lista),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.swipe_rounded,
              size: 15,
              color: Colors.grey.shade500,
            ),
            const SizedBox(width: 5),
            Text(
              'Desliza horizontalmente para ver todas las columnas',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _construirTabla(
    List<dynamic> lista,
  ) {
    const double anchoMateria = 190;
    const double anchoColumna = 58;
    const double anchoPeriodo = 75;

    return Table(
      defaultVerticalAlignment:
          TableCellVerticalAlignment.middle,
      columnWidths: const {
        0: FixedColumnWidth(anchoMateria),
        1: FixedColumnWidth(anchoColumna),
        2: FixedColumnWidth(anchoColumna),
        3: FixedColumnWidth(anchoColumna),
        4: FixedColumnWidth(anchoColumna),
        5: FixedColumnWidth(anchoColumna),
        6: FixedColumnWidth(anchoColumna),
        7: FixedColumnWidth(70),
        8: FixedColumnWidth(anchoColumna),
        9: FixedColumnWidth(anchoColumna),
        10: FixedColumnWidth(anchoColumna),
        11: FixedColumnWidth(anchoColumna),
        12: FixedColumnWidth(anchoPeriodo),
      },
      border: TableBorder(
        horizontalInside: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      children: [
        _filaEncabezados(),
        ...lista.map(
          (materia) => _filaMateria(materia),
        ),
      ],
    );
  }

  TableRow _filaEncabezados() {
    return TableRow(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            vino,
            vinoOscuro,
          ],
        ),
      ),
      children: [
        _celdaEncabezado(
          'MATERIA',
          izquierda: true,
        ),
        _celdaEncabezado('P1'),
        _celdaEncabezado('P2'),
        _celdaEncabezado('P3'),
        _celdaEncabezado('P4'),
        _celdaEncabezado('P5'),
        _celdaEncabezado('TF'),
        _celdaEncabezado('FINAL'),
        _celdaEncabezado('R1'),
        _celdaEncabezado('R2'),
        _celdaEncabezado('R3'),
        _celdaEncabezado('CLAVE'),
        _celdaEncabezado('PERIODO'),
      ],
    );
  }

  Widget _celdaEncabezado(
    String texto, {
    bool izquierda = false,
  }) {
    return Container(
      height: 46,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
      ),
      alignment: izquierda
          ? Alignment.centerLeft
          : Alignment.center,
      child: Text(
        texto,
        textAlign: izquierda
            ? TextAlign.left
            : TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  TableRow _filaMateria(
    dynamic materia,
  ) {
    final finalNota =
        texto(materia['final']);

    return TableRow(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      children: [
        _celdaMateria(
          texto(materia['materia']),
        ),
        _celdaValor(
          texto(materia['p1']),
        ),
        _celdaValor(
          texto(materia['p2']),
        ),
        _celdaValor(
          texto(materia['p3']),
        ),
        _celdaValor(
          texto(materia['p4']),
        ),
        _celdaValor(
          texto(materia['p5']),
        ),
        _celdaValor(
          texto(materia['tf']),
        ),
        _celdaFinal(finalNota),
        _celdaValor(
          texto(materia['r1']),
        ),
        _celdaValor(
          texto(materia['r2']),
        ),
        _celdaValor(
          texto(materia['r3']),
        ),
        _celdaValor(
          texto(materia['clave']),
        ),
        _celdaValor(
          texto(materia['periodo']),
        ),
      ],
    );
  }

  Widget _celdaMateria(
    String materia,
  ) {
    return Container(
      constraints:
          const BoxConstraints(
        minHeight: 58,
      ),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        materia,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF303030),
        ),
      ),
    );
  }

  Widget _celdaValor(
    String valor,
  ) {
    return Container(
      constraints:
          const BoxConstraints(
        minHeight: 58,
      ),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 5,
      ),
      alignment: Alignment.center,
      child: Text(
        valor,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          fontWeight: valor == '—'
              ? FontWeight.w400
              : FontWeight.w700,
          color: valor == '—'
              ? Colors.grey.shade400
              : Colors.grey.shade800,
        ),
      ),
    );
  }

  Widget _celdaFinal(
    String valor,
  ) {
    final color = colorFinal(valor);
    final fondo = fondoFinal(valor);

    return Container(
      constraints:
          const BoxConstraints(
        minHeight: 58,
      ),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 8,
      ),
      alignment: Alignment.center,
      child: TweenAnimationBuilder<double>(
        tween: Tween(
          begin: 0.8,
          end: 1,
        ),
        duration: const Duration(
          milliseconds: 350,
        ),
        curve: Curves.easeOutBack,
        builder: (
          context,
          value,
          child,
        ) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: Container(
          width: 42,
          height: 34,
          decoration: BoxDecoration(
            color: fondo,
            borderRadius:
                BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Text(
            valor,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _pantallaError() {
    return RefreshIndicator(
      color: vino,
      onRefresh: obtenerCalificaciones,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 70),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: _decoracionTarjeta(),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: vino.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cloud_off_rounded,
                    color: vino,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'No se pudieron cargar las calificaciones',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error ??
                      'Ocurrió un error inesperado.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed:
                        obtenerCalificaciones,
                    style:
                        FilledButton.styleFrom(
                      backgroundColor: vino,
                      foregroundColor:
                          Colors.white,
                      padding:
                          const EdgeInsets
                              .symmetric(
                        vertical: 13,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          13,
                        ),
                      ),
                    ),
                    icon: const Icon(
                      Icons.refresh_rounded,
                    ),
                    label: const Text(
                      'Intentar nuevamente',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sinCalificaciones() {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        Container(
          padding: const EdgeInsets.all(25),
          decoration: _decoracionTarjeta(),
          child: Column(
            children: [
              Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  color:
                      Colors.grey.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.school_outlined,
                  size: 40,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Aún no hay calificaciones',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Cuando existan evaluaciones registradas, aparecerán aquí.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed:
                    obtenerCalificaciones,
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
                label: const Text(
                  'Actualizar',
                ),
                style:
                    OutlinedButton.styleFrom(
                  foregroundColor: vino,
                  side: const BorderSide(
                    color: vino,
                  ),
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  BoxDecoration _decoracionTarjeta() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(19),
      boxShadow: [
        BoxShadow(
          color:
              Colors.black.withOpacity(0.045),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

