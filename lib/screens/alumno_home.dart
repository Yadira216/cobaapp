import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../orientacion_notificaciones.dart';
import 'calificaciones_page.dart';
import 'asistencias_page.dart';
import 'codigo_qr_page.dart';
import 'orientacion_page.dart';
import '../orientacion_tarea_fondo.dart';

class AlumnoHome extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const AlumnoHome({
    super.key,
    required this.usuario,
  });

  @override
  State<AlumnoHome> createState() => _AlumnoHomeState();
}

class _AlumnoHomeState extends State<AlumnoHome> {
  Map<String, dynamic> get usuario => widget.usuario;

  static const Color vino = Color(0xFF7B1735);
  static const Color vinoOscuro = Color(0xFF4A0D1F);
  static const Color vinoClaro = Color(0xFF9A3A5B);
  static const Color verde = Color(0xFF55A630);
  static const Color fondo = Color(0xFFF6F7F9);

 
  @override
  void initState() {
    super.initState();

    // Configurar las notificaciones cuando se abre la pantalla.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _configurarOrientacion();
    });
  }

  Future<void> _configurarOrientacion() async {
    final int idAlumno = int.tryParse(
          usuario['id_alumno']?.toString() ?? '',
        ) ??
        0;

    if (idAlumno <= 0) {
      debugPrint(
        'Orientación: no se encontró un id_alumno válido.',
      );
      return;
    }

    // Programar las revisiones en segundo plano.
    try {
      await OrientacionTareasFondo.programar(idAlumno);

      debugPrint(
        'Orientación: tarea en segundo plano programada.',
      );
    } catch (e) {
      debugPrint(
        'No se pudo programar la tarea de Orientación: $e',
      );
    }

    // Consultar inmediatamente las actividades existentes.
    try {
      await OrientacionNotificaciones.revisar(idAlumno);
    } catch (e) {
      debugPrint(
        'No se pudieron revisar las novedades de Orientación: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String nombre =
        usuario['nombre']?.toString().trim().isNotEmpty == true
            ? usuario['nombre'].toString()
            : 'Alumno';

    final String matricula =
        usuario['matricula']?.toString() ?? 'No disponible';

    final String grupo =
        usuario['grupo']?.toString().trim().isNotEmpty == true
            ? usuario['grupo'].toString()
            : '—';

    final String semestre =
        usuario['semestre']?.toString().trim().isNotEmpty == true
            ? usuario['semestre'].toString()
            : '—';

    final String turno =
        usuario['turno']?.toString().trim().isNotEmpty == true
            ? usuario['turno'].toString()
            : '—';

    final bool activo = usuario['activo']?.toString() == '1';

    return Scaffold(
      backgroundColor: fondo,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // HEADER
          SliverToBoxAdapter(
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              tween: Tween(begin: -30, end: 0),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, value),
                  child: Opacity(
                    opacity: ((30 + value) / 30).clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(34),
                    bottomRight: Radius.circular(34),
                  ),
                ),
                child: Column(
                  children: [
                    // ZONA DE LOGOS
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(
                        20,
                        MediaQuery.of(context).padding.top + 10,
                        20,
                        12,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/logoedu.png',
                            height: 48,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 10),
                          Image.asset(
                            'assets/cobalogo.png',
                            height: 40,
                            fit: BoxFit.contain,
                          ),
                          const Spacer(),
                          _botonHeader(
                            Icons.exit_to_app_rounded,
                            () async {
                              
                            final preferencias = await SharedPreferences.getInstance();

                            // Cancelar las revisiones asociadas a la sesión del alumno.
                            try {
                              await OrientacionTareasFondo.cancelar();
                            } catch (e) {
                              debugPrint(
                                'No se pudo cancelar la tarea de Orientación: $e',
                              );
                            }

                            // Eliminar los datos de la sesión.
                            await preferencias.remove('sesion_activa');
                            await preferencias.remove('tipo_usuario');
                            await preferencias.remove('usuario_sesion');


                              if (!context.mounted) return;

                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => const InicioPage(),
                                ),
                                (route) => false,
                              );
                            },
                            fondoBlanco: true,
                          ),
                        ],
                      ),
                    ),

                    // ZONA DEL PERFIL
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        22,
                        20,
                        25,
                      ),
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
                          bottomLeft: Radius.circular(34),
                          bottomRight: Radius.circular(34),
                        ),
                      ),
                      child: Column(
                        children: [
                          // PERFIL
                          Row(
                            children: [
                              _fotoAlumno(),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bienvenido',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(.65),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      nombre,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 21,
                                        fontWeight: FontWeight.w900,
                                        height: 1.1,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(.12),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(.08),
                                        ),
                                      ),
                                      child: Text(
                                        'Matrícula  $matricula',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          // DATOS ACADÉMICOS
                          Row(
                            children: [
                              Expanded(
                                child: _datoHeader(
                                  Icons.groups_rounded,
                                  'Grupo',
                                  grupo,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _datoHeader(
                                  Icons.school_rounded,
                                  'Semestre',
                                  semestre,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _datoHeader(
                                  Icons.schedule_rounded,
                                  'Turno',
                                  turno,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // CONTENIDO
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 35),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  // ESTADO
                  _entrada(
                    delay: 100,
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: activo ? verde : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          activo ? 'Alumno activo' : 'Alumno inactivo',
                          style: TextStyle(
                            color: activo ? verde : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // QR
                  _entrada(
                    delay: 150,
                    child: _tarjetaQR(context),
                  ),

                  const SizedBox(height: 20),
                  const SizedBox(height: 10),

                  // SERVICIOS
                  _entrada(
                    delay: 250,
                    child: Row(
                      children: [
                        Expanded(
                          child: _servicio(
                            Icons.school_rounded,
                            'Calificaciones',
                            verde,
                            () {
                              Navigator.push(
                                context,
                                _transicion(
                                  CalificacionesPage(usuario: usuario),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _servicio(
                            Icons.fact_check_rounded,
                            'Asistencias',
                            const Color.fromARGB(255, 0, 211, 248),
                            () {
                              Navigator.push(
                                context,
                                _transicion(
                                  AsistenciasPage(usuario: usuario),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ORIENTACIÓN
                  _entrada(
                    delay: 300,
                    child: _servicioGrande(
                      Icons.support_agent_rounded,
                      'Orientación',
                      '',
                      const Color.fromARGB(255, 255, 102, 229),
                      () {
                        Navigator.push(
                          context,
                          _transicion(
                            OrientacionPage(usuario: usuario),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 5),
                  const SizedBox(height: 7),

                  // INFORMACIÓN
                  _entrada(
                    delay: 400,
                    child: _informacionCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ANIMACIÓN DE ENTRADA
  Widget _entrada({
    required int delay,
    required Widget child,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 550 + delay),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 20, end: 0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value),
          child: Opacity(
            opacity: ((20 - value) / 20).clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // TRANSICIÓN ENTRE PANTALLAS
  PageRouteBuilder _transicion(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 450),
      reverseTransitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, animation, __) => page,
      transitionsBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(.04, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  // TÍTULO DE SECCIÓN
  Widget _tituloSeccion(String titulo, String subtitulo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w900,
            color: Color(0xFF202124),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitulo,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // BOTÓN HEADER
  Widget _botonHeader(
    IconData icono,
    VoidCallback onTap, {
    bool fondoBlanco = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: fondoBlanco
                ? vino.withOpacity(.08)
                : Colors.white.withOpacity(.13),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: fondoBlanco
                  ? vino.withOpacity(.10)
                  : Colors.white.withOpacity(.08),
            ),
          ),
          child: Icon(
            icono,
            color: fondoBlanco ? vino : Colors.white,
            size: 21,
          ),
        ),
      ),
    );
  }

  // FOTO DEL ALUMNO
  Widget _fotoAlumno() {
    final foto = usuario['foto']?.toString();

    if (foto != null &&
        foto.isNotEmpty &&
        foto.startsWith('data:image')) {
      try {
        final base64String = foto.split(',').last;

        return Container(
          width: 78,
          height: 78,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.20),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.memory(
              base64Decode(base64String),
              fit: BoxFit.cover,
            ),
          ),
        );
      } catch (_) {}
    }

    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.18),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(
        Icons.person_rounded,
        color: vino,
        size: 40,
      ),
    );
  }

  // DATO ACADÉMICO
  Widget _datoHeader(
    IconData icono,
    String titulo,
    String valor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.11),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(.07),
        ),
      ),
      child: Column(
        children: [
          Icon(icono, color: Colors.white, size: 18),
          const SizedBox(height: 5),
          Text(
            titulo,
            style: TextStyle(
              color: Colors.white.withOpacity(.58),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            valor,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  // TARJETA QR
  Widget _tarjetaQR(BuildContext context) {
    return _PressableCard(
      onTap: () {
        Navigator.push(
          context,
          _transicion(
            CodigoQrPage(usuario: usuario),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF9A3A5B),
              vino,
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: vino.withOpacity(.22),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.14),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.qr_code_2_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
            const SizedBox(width: 15),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mi código QR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tu identificación digital',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SERVICIO PEQUEÑO
  Widget _servicio(
    IconData icono,
    String titulo,
    Color color,
    VoidCallback onTap,
  ) {
    return _PressableCard(
      onTap: onTap,
      child: Container(
        height: 115,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.black.withOpacity(.035),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(.10),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: color.withOpacity(.11),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icono, color: color, size: 22),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: color.withOpacity(.45),
                  size: 12,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // SERVICIO GRANDE
  Widget _servicioGrande(
    IconData icono,
    String titulo,
    String subtitulo,
    Color color,
    VoidCallback onTap,
  ) {
    return _PressableCard(
      onTap: onTap,
      child: Container(
        height: 78,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.black.withOpacity(.035),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(.09),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withOpacity(.11),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icono, color: color, size: 23),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitulo,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Colors.black45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color.withOpacity(.45),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  // INFORMACIÓN
  Widget _informacionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: Colors.black.withOpacity(.035),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.035),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          _filaDato(
            Icons.account_balance_rounded,
            'Plantel',
            usuario['plantel'],
          ),
          _separador(),
          _filaDato(
            Icons.badge_outlined,
            'CURP',
            usuario['curp'],
          ),
          _separador(),
          _filaDato(
            Icons.phone_rounded,
            'Teléfono',
            usuario['telefono'],
          ),
          _separador(),
          _filaDato(
            Icons.auto_awesome_rounded,
            'Generación',
            usuario['generacion'],
          ),
        ],
      ),
    );
  }

  // FILA INFORMACIÓN
  Widget _filaDato(
    IconData icono,
    String titulo,
    dynamic valor,
  ) {
    final String texto =
        valor?.toString().trim().isNotEmpty == true
            ? valor.toString()
            : 'No disponible';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 41,
            height: 41,
            decoration: BoxDecoration(
              color: vino.withOpacity(.08),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icono, color: vino, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  texto,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
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

  // SEPARADOR
  Widget _separador() {
    return Divider(
      height: 1,
      color: Colors.grey.shade100,
    );
  }
}

// TARJETA CON ANIMACIÓN AL PRESIONAR
class _PressableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressableCard({
    required this.child,
    required this.onTap,
  });

  @override
  State<_PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<_PressableCard> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          pressed = true;
        });
      },
      onTapCancel: () {
        setState(() {
          pressed = false;
        });
      },
      onTapUp: (_) {
        setState(() {
          pressed = false;
        });

        widget.onTap();
      },
      child: AnimatedScale(
        scale: pressed ? .97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
