
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AsistenciasPage extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const AsistenciasPage({
    super.key,
    required this.usuario,
  });

  @override
  State<AsistenciasPage> createState() => _AsistenciasPageState();
}

class _AsistenciasPageState extends State<AsistenciasPage> {
  static const Color vino = Color(0xFF7B1735);
  static const Color vinoOscuro = Color(0xFF4A0D1F);
  static const Color vinoClaro = Color(0xFF9A3A5B);
  static const Color verde = Color(0xFF55A630);
  static const Color fondo = Color(0xFFF6F7F9);

  static const String endpoint =
      'http://10.35.16.16/saesc/android/android.php';

  bool cargando = true;
  String? error;
  int total = 0;

  List<Map<String, dynamic>> registros = [];

  late DateTime desde;
  late DateTime hasta;

  @override
  void initState() {
    super.initState();

    final ahora = DateTime.now();

    desde = DateTime(ahora.year, ahora.month, 1);
    hasta = ahora;

    _cargarAsistencias();
  }

  // CONSULTAR ASISTENCIAS

  Future<void> _cargarAsistencias() async {
    if (mounted) {
      setState(() {
        cargando = true;
        error = null;
      });
    }

    try {
      final respuesta = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'accion': 'asistencias',
          'id_alumno': widget.usuario['id_alumno'],
          'desde': _formatearFecha(desde),
          'hasta': _formatearFecha(hasta),
        }),
      );

      if (respuesta.statusCode != 200) {
        throw Exception(
          'El servidor respondió con código ${respuesta.statusCode}.',
        );
      }

      final data = jsonDecode(respuesta.body);

      if (data['status'] != 'success') {
        throw Exception(
          data['mensaje'] ??
              'No fue posible consultar las asistencias.',
        );
      }

      final lista = data['datos'];

      if (!mounted) return;

      setState(() {
        total = data['total'] is int
            ? data['total']
            : int.tryParse('${data['total']}') ?? 0;

        registros = lista is List
            ? lista
                .map(
                  (item) => Map<String, dynamic>.from(item),
                )
                .toList()
            : [];

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

  // FORMATO DE FECHAS Y HORAS
  String _formatearFecha(DateTime fecha) {
    final year = fecha.year.toString().padLeft(4, '0');
    final month = fecha.month.toString().padLeft(2, '0');
    final day = fecha.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  String _formatearFechaBonita(String fecha) {
    if (fecha.isEmpty) {
      return '—';
    }

    try {
      final fechaConvertida = DateTime.parse(
        fecha.replaceFirst(' ', 'T'),
      );

      const meses = [
        'ENE',
        'FEB',
        'MAR',
        'ABR',
        'MAY',
        'JUN',
        'JUL',
        'AGO',
        'SEP',
        'OCT',
        'NOV',
        'DIC',
      ];

      final dia = fechaConvertida.day.toString().padLeft(2, '0');
      final mes = meses[fechaConvertida.month - 1];

      return '$dia $mes ${fechaConvertida.year}';
    } catch (_) {
      return fecha;
    }
  }

  String _formatearHora(String fecha) {
    if (fecha.isEmpty) {
      return '';
    }

    try {
      final fechaConvertida = DateTime.parse(
        fecha.replaceFirst(' ', 'T'),
      );

      final hora = fechaConvertida.hour;
      final minuto = fechaConvertida.minute.toString().padLeft(2, '0');
      final periodo = hora >= 12 ? 'PM' : 'AM';

      final hora12 = hora == 0
          ? 12
          : hora > 12
              ? hora - 12
              : hora;

      return '$hora12:$minuto $periodo';
    } catch (_) {
      return '';
    }
  }

  String _nombreSemestre(dynamic semestre) {
    if (semestre == null || semestre.toString().isEmpty) {
      return 'Semestre no disponible';
    }

    return 'Semestre ${semestre.toString()}';
  }

  // AGRUPAR TODAS LAS ASISTENCIAS POR DÍA

  Map<String, List<Map<String, dynamic>>> _agruparPorDia() {
    final Map<String, List<Map<String, dynamic>>> grupos = {};

    for (final registro in registros) {
      final fecha =
          registro['fecha_registro']?.toString() ?? '';

      if (fecha.isEmpty || fecha.length < 10) {
        continue;
      }

      // Obtiene únicamente el año, mes y día.
      final dia = fecha.substring(0, 10);

      grupos.putIfAbsent(dia, () => []);
      grupos[dia]!.add(registro);
    }

    // Ordenar las asistencias de cada día de la más reciente
    // a la más antigua.
    for (final lista in grupos.values) {
      lista.sort((a, b) {
        final fechaA =
            a['fecha_registro']?.toString() ?? '';
        final fechaB =
            b['fecha_registro']?.toString() ?? '';

        return fechaB.compareTo(fechaA);
      });
    }

    // Ordenar los días del más reciente al más antiguo.
    final diasOrdenados = grupos.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return {
      for (final dia in diasOrdenados)
        dia: grupos[dia]!,
    };
  }

  // SELECCIÓN DEL PERIODO

  Future<void> _seleccionarDesde() async {
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: desde,
      firstDate: DateTime(2020),
      lastDate: hasta.isAfter(DateTime.now())
          ? hasta
          : DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: vino,
            ),
          ),
          child: child!,
        );
      },
    );

    if (seleccionada != null) {
      setState(() {
        desde = seleccionada;
      });

      await _cargarAsistencias();
    }
  }

  Future<void> _seleccionarHasta() async {
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: hasta,
      firstDate: desde,
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: vino,
            ),
          ),
          child: child!,
        );
      },
    );

    if (seleccionada != null) {
      setState(() {
        hasta = seleccionada;
      });

      await _cargarAsistencias();
    }
  }

  // PANTALLA PRINCIPAL

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      body: SafeArea(
        child: Column(
          children: [
            _encabezado(),
            Expanded(
              child: RefreshIndicator(
                color: vino,
                onRefresh: _cargarAsistencias,
                child: _contenido(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _encabezado() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 18, 18),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Asistencias',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Consulta de registros escolares',
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
                      onTap: _cargarAsistencias,
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

  // ============================================================
  // CONTENIDO Y LISTADO AGRUPADO POR DÍA
  // ============================================================

  Widget _contenido() {
    if (cargando && registros.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: vino,
        ),
      );
    }

    if (error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 80),
          _tarjetaError(),
        ],
      );
    }

    final gruposPorDia = _agruparPorDia();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
      children: [
        _animarEntrada(
          0,
          _tarjetaAlumno(),
        ),

        const SizedBox(height: 14),

        _animarEntrada(
          1,
          _tarjetaPeriodo(),
        ),

        const SizedBox(height: 12),

        _animarEntrada(
          2,
          _tarjetaTotal(),
        ),

        const SizedBox(height: 24),

        _animarEntrada(
          3,
          const Text(
            'ASISTENCIAS POR DÍA',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: vino,
            ),
          ),
        ),

        const SizedBox(height: 12),

        if (registros.isEmpty || gruposPorDia.isEmpty)
          _animarEntrada(
            4,
            _sinRegistros(),
          )
        else
          ...gruposPorDia.entries.toList().asMap().entries.map(
            (entrada) {
              final indice = entrada.key;
              final dia = entrada.value.key;
              final asistenciasDelDia = entrada.value.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: _animarEntrada(
                  indice + 4,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Encabezado del día.
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 4,
                          bottom: 10,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: vino.withOpacity(0.09),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: const Icon(
                                Icons.calendar_today_rounded,
                                color: vino,
                                size: 17,
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                _formatearFechaBonita(
                                  '${dia} 00:00:00',
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: vino,
                                ),
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: verde.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${asistenciasDelDia.length} '
                                '${asistenciasDelDia.length == 1 ? 'registro' : 'registros'}',
                                style: const TextStyle(
                                  color: verde,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Todas las asistencias registradas ese día.
                      ...asistenciasDelDia.map(
                        (registro) => Padding(
                          padding: const EdgeInsets.only(bottom: 9),
                          child: _tarjetaAsistencia(registro),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  
  // ANIMACIONES

  Widget _animarEntrada(
    int indice,
    Widget child,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(
        milliseconds: 400 + (indice * 70),
      ),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
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

  // TARJETA DEL ALUMNO

  Widget _tarjetaAlumno() {
    final nombre =
        widget.usuario['nombre']?.toString() ?? 'Alumno';

    final matricula =
        widget.usuario['matricula']?.toString() ?? '—';

    final foto =
        widget.usuario['foto']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _decoracionTarjeta(),
      child: Row(
        children: [
          Hero(
            tag: 'foto-alumno',
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF1F1F1),
                border: Border.all(
                  color: vino.withOpacity(0.16),
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
                            size: 32,
                            color: Colors.black26,
                          );
                        },
                      )
                    : const Icon(
                        Icons.person_rounded,
                        size: 32,
                        color: Colors.black26,
                      ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ALUMNO',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1,
                    color: Colors.black45,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  nombre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF303030),
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
                    Text(
                      matricula,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: verde.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.how_to_reg_rounded,
              color: verde,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  // TARJETA DEL PERIODO

  Widget _tarjetaPeriodo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _decoracionTarjeta(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: vino.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: vino,
                  size: 20,
                ),
              ),

              const SizedBox(width: 11),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Periodo de consulta',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF303030),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Selecciona el rango que deseas consultar',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: _botonFecha(
                  titulo: 'Desde',
                  fecha: desde,
                  onTap: _seleccionarDesde,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _botonFecha(
                  titulo: 'Hasta',
                  fecha: hasta,
                  onTap: _seleccionarHasta,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _botonFecha({
    required String titulo,
    required DateTime fecha,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFF7F7F9),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFE4E4E4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.event_rounded,
                    size: 15,
                    color: vino,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 5),

              Text(
                _formatearFechaBonita(
                  _formatearFecha(fecha),
                ),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TOTAL DE REGISTROS

  Widget _tarjetaTotal() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            vino,
            vinoOscuro,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(19),
        boxShadow: [
          BoxShadow(
            color: vino.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.13),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.fact_check_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Registros encontrados',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'En el periodo seleccionado',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: child,
              );
            },
            child: Text(
              total.toString(),
              key: ValueKey(total),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TARJETA INDIVIDUAL DE ASISTENCIA

  Widget _tarjetaAsistencia(
    Map<String, dynamic> registro,
  ) {
    final fecha =
        registro['fecha_registro']?.toString() ?? '';

    final semestre = registro['semestre'];

    return _PressableCard(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: _decoracionTarjeta(),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: verde.withOpacity(0.11),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: verde,
                size: 27,
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatearFechaBonita(fecha),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF303030),
                    ),
                  ),

                  const SizedBox(height: 5),

                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 14,
                        color: Colors.black45,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatearHora(fecha),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    _nombreSemestre(semestre),
                    style: const TextStyle(
                      fontSize: 11,
                      color: vino,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.verified_rounded,
              color: verde,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ESTADO SIN REGISTROS
  

  Widget _sinRegistros() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 38,
      ),
      decoration: _decoracionTarjeta(),
      child: const Column(
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 48,
            color: Colors.black26,
          ),
          SizedBox(height: 13),
          Text(
            'No hay registros en este periodo',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF444444),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Prueba seleccionando otro rango de fechas.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // TARJETA DE ERROR
  

  Widget _tarjetaError() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _decoracionTarjeta(),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: vino.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_off_rounded,
              color: vino,
              size: 35,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'No fue posible cargar las asistencias',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF333333),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            error ?? 'Ocurrió un error inesperado.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _cargarAsistencias,
              style: FilledButton.styleFrom(
                backgroundColor: vino,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'Intentar nuevamente',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ESTILO DE LAS TARJETAS

  BoxDecoration _decoracionTarjeta() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.045),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

// ANIMACIÓN AL PRESIONAR LAS TARJETAS

class _PressableCard extends StatefulWidget {
  final Widget child;

  const _PressableCard({
    required this.child,
  });

  @override
  State<_PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<_PressableCard> {
  bool presionado = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: presionado ? 0.985 : 1,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            presionado = true;
          });
        },
        onTapUp: (_) {
          setState(() {
            presionado = false;
          });
        },
        onTapCancel: () {
          setState(() {
            presionado = false;
          });
        },
        child: widget.child,
      ),
    );
  }
}
