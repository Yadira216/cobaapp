import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrientacionPage extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const OrientacionPage({
    super.key,
    required this.usuario,
  });

  @override
  State<OrientacionPage> createState() => _OrientacionPageState();
}

class _OrientacionPageState extends State<OrientacionPage> {
  static const Color vino = Color(0xFF7B1735);
  static const Color vinoOscuro = Color(0xFF4A0D1F);
  static const Color verde = Color(0xFF55A630);
  static const Color fondo = Color(0xFFF7F7F9);

  static const String endpoint =
      'http://10.35.16.16/saesc/android/android.php';

  bool cargando = true;
  String? error;
  List<dynamic> registros = [];

  @override
  void initState() {
    super.initState();
    cargarOrientacion();
  }

  Future<void> cargarOrientacion() async {
    setState(() {
      cargando = true;
      error = null;
    });

    try {
      final idAlumno = widget.usuario['id_alumno'];

      final respuesta = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'accion': 'orientacion',
          'id_alumno': idAlumno,
        }),
      );

      if (respuesta.statusCode != 200) {
        throw Exception(
          'El servidor respondió con código ${respuesta.statusCode}',
        );
      }

      final data = jsonDecode(respuesta.body);

      if (data['status'] == 'success') {
        setState(() {
          registros = data['datos'] ?? [];
          cargando = false;
        });
      } else {
        setState(() {
          error =
              data['mensaje'] ?? 'No fue posible consultar orientación.';
          cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'No se pudo conectar con el servidor.';
        cargando = false;
      });
    }
  }

  String texto(dynamic valor) {
    if (valor == null) return '';
    return valor.toString().trim();
  }

  String mostrarFecha(dynamic valor) {
    final fecha = texto(valor);

    if (fecha.isEmpty) return 'Sin fecha';

    if (fecha.contains(' ')) {
      return fecha.split(' ').first;
    }

    return fecha;
  }

  Color colorEstado(String cancel) {
    if (cancel == '1' ||
        cancel.toLowerCase() == 'si' ||
        cancel.toLowerCase() == 'cancelado') {
      return Colors.red;
    }

    return verde;
  }

  String estadoTexto(String cancel) {
    if (cancel == '1' ||
        cancel.toLowerCase() == 'si' ||
        cancel.toLowerCase() == 'cancelado') {
      return 'Cancelada';
    }

    return 'Registrada';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: RefreshIndicator(
                color: vino,
                onRefresh: cargarOrientacion,
                child: _contenido(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            vino,
            vinoOscuro,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          _botonHeader(
            Icons.arrow_back_rounded,
            () => Navigator.pop(context),
          ),

          const SizedBox(width: 14),

          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
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
                  'Orientación',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Registro de atención y seguimiento',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          _botonHeader(
            Icons.refresh_rounded,
            cargarOrientacion,
          ),
        ],
      ),
    );
  }

  Widget _botonHeader(
    IconData icono,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.white.withOpacity(0.13),
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            icono,
            color: Colors.white,
            size: 21,
          ),
        ),
      ),
    );
  }

  // =========================================================
  // CONTENIDO
  // =========================================================

  Widget _contenido() {
    if (cargando) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 180),
          Center(
            child: CircularProgressIndicator(
              color: vino,
            ),
          ),
          SizedBox(height: 18),
          Center(
            child: Text(
              'Cargando orientación...',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    if (error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 100),

          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cloud_off_rounded,
              size: 42,
              color: Colors.red.shade400,
            ),
          ),

          const SizedBox(height: 20),

          const Center(
            child: Text(
              'No fue posible cargar la información',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Center(
            child: Text(
              error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),

          const SizedBox(height: 22),

          Center(
            child: ElevatedButton.icon(
              onPressed: cargarOrientacion,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: vino,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (registros.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 110),

          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: vino.withOpacity(0.07),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.support_agent_rounded,
              size: 48,
              color: vino.withOpacity(0.45),
            ),
          ),

          const SizedBox(height: 20),

          const Center(
            child: Text(
              'Sin registros de orientación',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Center(
            child: Text(
              'No hay información disponible para mostrar.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
      children: [
        _encabezado(),

        const SizedBox(height: 16),

        ...List.generate(
          registros.length,
          (index) {
            final registro =
                Map<String, dynamic>.from(registros[index]);

            return _animarRegistro(
              index,
              _tarjetaOrientacion(registro),
            );
          },
        ),
      ],
    );
  }

  // RESUMEN

  Widget _encabezado() {
    final int canceladas = registros.where((registro) {
      final cancel = texto(registro['cancel']);

      return cancel == '1' ||
          cancel.toLowerCase() == 'si' ||
          cancel.toLowerCase() == 'cancelado';
    }).length;

    final int registradas = registros.length - canceladas;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 15,
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
              color: verde.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.assignment_turned_in_rounded,
              color: verde,
              size: 27,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mis registros',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${registros.length} registro${registros.length == 1 ? '' : 's'} de orientación',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _miniEstado(
                registradas.toString(),
                'Activas',
                verde,
              ),

              if (canceladas > 0) ...[
                const SizedBox(height: 5),
                _miniEstado(
                  canceladas.toString(),
                  'Canceladas',
                  Colors.red,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniEstado(
    String numero,
    String textoEstado,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          '$numero $textoEstado',
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // ANIMACIÓN
  // =========================================================

  Widget _animarRegistro(
    int index,
    Widget child,
  ) {
    return TweenAnimationBuilder<double>(
      duration: Duration(
        milliseconds: 350 + (index * 70),
      ),
      tween: Tween(
        begin: 0,
        end: 1,
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

  // =========================================================
  // TARJETA DE ORIENTACIÓN
  // =========================================================

  Widget _tarjetaOrientacion(
    Map<String, dynamic> registro,
  ) {
    final cancel = texto(registro['cancel']);
    final estadoColor = colorEstado(cancel);

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.black.withOpacity(0.035),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.055),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ESTADO + FECHA
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: estadoColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      cancel == '1'
                          ? Icons.cancel_rounded
                          : Icons.check_circle_rounded,
                      size: 14,
                      color: estadoColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      estadoTexto(cancel),
                      style: TextStyle(
                        color: estadoColor,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 13,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    mostrarFecha(registro['fecha']),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 17),

          // INFORMACIÓN
          if (texto(registro['tipo']).isNotEmpty)
            _dato(
              Icons.category_outlined,
              'Tipo',
              texto(registro['tipo']),
            ),

          if (texto(registro['razon']).isNotEmpty)
            _dato(
              Icons.help_outline_rounded,
              'Razón',
              texto(registro['razon']),
            ),

          if (texto(registro['detalle']).isNotEmpty)
            _dato(
              Icons.notes_rounded,
              'Detalle',
              texto(registro['detalle']),
            ),

          if (texto(registro['solicitante']).isNotEmpty)
            _dato(
              Icons.person_outline_rounded,
              'Solicitante',
              texto(registro['solicitante']),
            ),

          if (texto(registro['paren']).isNotEmpty)
            _dato(
              Icons.people_outline_rounded,
              'Parentesco',
              texto(registro['paren']),
            ),

          if (texto(registro['periodo']).isNotEmpty)
            _dato(
              Icons.calendar_month_outlined,
              'Periodo',
              texto(registro['periodo']),
            ),

          // FOLIOS
          if (texto(registro['folio']).isNotEmpty ||
              texto(registro['foliob']).isNotEmpty)
            _folios(registro),

          // PERIODO DE ATENCIÓN
          if (texto(registro['fechain']).isNotEmpty ||
              texto(registro['fechafin']).isNotEmpty)
            _periodoAtencion(registro),
        ],
      ),
    );
  }

  // =========================================================
  // DATO
  // =========================================================

  Widget _dato(
    IconData icono,
    String titulo,
    String valor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: vino.withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icono,
              size: 18,
              color: vino,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  valor,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // FOLIOS
  // =========================================================

  Widget _folios(
    Map<String, dynamic> registro,
  ) {
    final folio = texto(registro['folio']);
    final foliob = texto(registro['foliob']);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: verde.withOpacity(0.055),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.confirmation_number_outlined,
            color: verde,
            size: 21,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Wrap(
              spacing: 18,
              runSpacing: 8,
              children: [
                if (folio.isNotEmpty)
                  _folioItem(
                    'Folio',
                    folio,
                  ),
                if (foliob.isNotEmpty)
                  _folioItem(
                    'Folio B',
                    foliob,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _folioItem(
    String titulo,
    String valor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          valor,
          style: const TextStyle(
            color: verde,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // PERIODO DE ATENCIÓN
  // =========================================================

  Widget _periodoAtencion(
    Map<String, dynamic> registro,
  ) {
    final inicio = texto(registro['fechain']);
    final fin = texto(registro['fechafin']);

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            vino.withOpacity(0.06),
            vino.withOpacity(0.025),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: vino.withOpacity(0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: vino.withOpacity(0.09),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.date_range_rounded,
              color: vino,
              size: 20,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Periodo de atención',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  '${inicio.isEmpty ? '—' : inicio}'
                  '${fin.isEmpty ? '' : '  →  $fin'}',
                  style: const TextStyle(
                    color: vino,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

