
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/login_page.dart';
import 'screens/alumno_home.dart';
import 'screens/personal_home.dart';
import 'screens/web_page.dart';
import 'screens/calendario_page.dart';
import 'globales.dart' as globales;
import 'package:workmanager/workmanager.dart';
import 'orientacion_tarea_fondo.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Color(0xFF7B1735),
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Color(0xFF7B1735),
      systemNavigationBarContrastEnforced: false,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  await Workmanager().initialize(
    callbackDispatcher,
  );

  runApp(const CobaApp());
}


class CobaApp extends StatelessWidget {
  const CobaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'COBAapp',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: const Color(0xFFF6F7F9),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7B1735),
          primary: const Color(0xFF7B1735),
        ),
      ),
      home: const SesionInicial(),
    );
  }
}

// RECUPERAR LA SESIÓN AL ABRIR LA APLICACIÓN

class SesionInicial extends StatefulWidget {
  const SesionInicial({super.key});

  @override
  State<SesionInicial> createState() => _SesionInicialState();
}

class _SesionInicialState extends State<SesionInicial> {
  late final Future<Widget> _pantallaInicial;

  @override
  void initState() {
    super.initState();
    _pantallaInicial = _recuperarSesion();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _pantallaInicial,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: Color(0xFFF6F7F9),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF7B1735),
              ),
            ),
          );
        }

        return snapshot.data ?? const InicioPage();
      },
    );
  }

  Future<Widget> _recuperarSesion() async {
    final prefs = await SharedPreferences.getInstance();

    final activa = prefs.getBool('sesion_activa') ?? false;
    final tipo = prefs.getString('tipo_usuario');
    final datosGuardados = prefs.getString('usuario_sesion');

    if (!activa || tipo == null || datosGuardados == null) {
      return const InicioPage();
    }

    try {
      final decodificado = jsonDecode(datosGuardados);

      if (decodificado is! Map) {
        throw const FormatException('Datos de usuario inválidos');
      }

      final usuario = Map<String, dynamic>.from(decodificado);

      if (tipo == 'alumno') {
        return AlumnoHome(usuario: usuario);
      }

      if (tipo == 'personal') {
        return PersonalHome(usuario: usuario);
      }
    } catch (_) {
      await prefs.remove('sesion_activa');
      await prefs.remove('tipo_usuario');
      await prefs.remove('usuario_sesion');
    }

    return const InicioPage();
  }
}

// PANTALLA DE INICIO

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  static const Color vino = Color(0xFF7B1735);
  static const Color vinoOscuro = Color(0xFF4A0D1F);
  static const Color vinoClaro = Color(0xFF9A3A5B);
  static const Color verde = Color(0xFF55A630);
  static const Color fondo = Color(0xFFF6F7F9);
  static const Color texto = Color(0xFF24242A);

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controlador;

  @override
  void initState() {
    super.initState();

    _controlador = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    );

    _controlador.forward();
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  // Animación de entrada
  Widget _entrada({
    required Widget child,
    required double inicio,
    required double fin,
  }) {
    final animacion = CurvedAnimation(
      parent: _controlador,
      curve: Interval(
        inicio,
        fin,
        curve: Curves.easeOutCubic,
      ),
    );

    return AnimatedBuilder(
      animation: animacion,
      child: child,
      builder: (context, contenido) {
        final progreso = animacion.value;

        return Opacity(
          opacity: progreso,
          child: Transform.translate(
            offset: Offset(0, 22 * (1 - progreso)),
            child: contenido,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final accesos = <Widget>[
      MenuCard(
        icon: Icons.login_rounded,
        title: 'Iniciar sesión',
        description: '',
        color: InicioPage.vino,
        onTap: () => _abrir(context, const LoginPage()),
      ),
      MenuCard(
        icon: Icons.calendar_month_rounded,
        title: 'Calendario',
        description: '',
        color: InicioPage.verde,
        onTap: () => _abrir(context, const CalendarioPage()),
      ),
      MenuCard(
        icon: Icons.description_rounded,
        title: 'Documentos',
        description: '',
        color: InicioPage.vino,
        onTap: () => _abrir(
          context,
          const WebPage(
            titulo: 'Documentos',
            url: '${globales.urlApi}/android/documentos.html',
          ),
        ),
      ),
      MenuCard(
        icon: Icons.location_city_rounded,
        title: 'Planteles',
        description: '',
        color: InicioPage.verde,
        onTap: () => _abrir(
          context,
          const WebPage(
            titulo: 'Planteles',
            url: '${globales.urlApi}/sisCrafmap/',
          ),
        ),
      ),
      MenuCard(
        icon: Icons.link_rounded,
        title: 'Enlaces',
        description: '',
        color: InicioPage.vino,
        onTap: () => _abrir(
          context,
          const WebPage(
            titulo: 'Enlaces',
            url: '${globales.urlApi}/android/enlaces.html',
          ),
        ),
      ),
      MenuCard(
        icon: Icons.info_outline_rounded,
        title: 'Nosotros',
        description: 'Conoce COBAEM',
        color: InicioPage.verde,
        onTap: () => _abrir(
          context,
          const WebPage(
            titulo: 'Nosotros',
            url: '${globales.urlApi}/android/acerca.html',
          ),
        ),
      ),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: InicioPage.vino,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: InicioPage.vino,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: InicioPage.fondo,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LOGOS Y AVISOS
                _entrada(
                  inicio: 0,
                  fin: 0.38,
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/logoedu.png',
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 12),
                      Image.asset(
                        'assets/cobalogo.png',
                        height: 36,
                        fit: BoxFit.contain,
                      ),
                      const Spacer(),
                      
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // PRESENTACIÓN
                _entrada(
                  inicio: 0.10,
                  fin: 0.52,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          InicioPage.vinoOscuro,
                          InicioPage.vino,
                          InicioPage.vinoClaro,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: InicioPage.vino.withOpacity(0.18),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                  ),
                                  const SizedBox(width: 3),
                                ],
                              ),
                              const SizedBox(height: 9),
                              const Text(
                                'Bienvenido a',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 1),
                              RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'COBA',
                                      style: TextStyle(
                                        fontSize: 31,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'app',
                                      style: TextStyle(
                                        fontSize: 31,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFFB8EF98),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'Colegio de Bachilleres del Estado de México',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.16),
                            ),
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            size: 39,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // TÍTULO DE ACCESOS 
                _entrada(
                  inicio: 0.18,
                  fin: 0.54,
                  child: Row(
                    children: [
                      Container(
                        width: 2,
                        height: 25,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 1),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 1),

                // MENÚ PRINCIPAL
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const separacion = 12.0;
                      final altoTarjeta =
                          (constraints.maxHeight - separacion * 2) / 3;

                      return GridView.builder(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: accesos.length,
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 13,
                          mainAxisSpacing: separacion,
                          mainAxisExtent: altoTarjeta,
                        ),
                        itemBuilder: (context, index) {
                          final inicio = 0.20 + (index * 0.075);
                          final fin =
                              (inicio + 0.38).clamp(0.0, 1.0);

                          return _entrada(
                            inicio: inicio,
                            fin: fin,
                            child: accesos[index],
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // REDES SOCIALES
                
                // REDES SOCIALES
                _entrada(
                  inicio: 0.66,
                  fin: 1,
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Mantente conectado',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: InicioPage.texto,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _BotonRedSocial(
                              imagen: 'assets/tiktok.png',
                              onTap: () => _abrir(
                                context,
                                const WebPage(
                                  titulo: 'TikTok',
                                  url: 'https://www.tiktok.com/',
                                ),
                              ),
                            ),
                            const SizedBox(width: 25),
                            _BotonRedSocial(
                              imagen: 'assets/logofacebook.png',
                              onTap: () => _abrir(
                                context,
                                const WebPage(
                                  titulo: 'Facebook',
                                  url:
                                      'https://web.facebook.com/COBA.EDOMEX/?locale=es',
                                ),
                              ),
                            ),
                            const SizedBox(width: 25),
                            _BotonRedSocial(
                              imagen: 'assets/logox.jpg',
                              onTap: () => _abrir(
                                context,
                                const WebPage(
                                  titulo: 'X',
                                  url: 'https://x.com/COBAEMex?lang=es',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ABRIR OTRA PANTALLA
  void _abrir(BuildContext context, Widget pantalla) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => pantalla),
    );
  }

  // PANEL DE AVISOS
  void _mostrarAvisos(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) => const Padding(
        padding: EdgeInsets.fromLTRB(25, 10, 25, 35),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            
            SizedBox(height: 12),
            
            SizedBox(height: 8),
            
          ],
        ),
      ),
    );
  }
}


// TARJETAS DEL MENÚ
class MenuCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const MenuCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  State<MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<MenuCard> {
  bool _presionado = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _presionado ? 0.97 : 1,
      duration: const Duration(milliseconds: 140),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (value) {
            setState(() => _presionado = value);
          },
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: widget.color.withOpacity(0.09),
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.055),
                  blurRadius: 13,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 49,
                  height: 49,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.09),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.color,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: InicioPage.texto,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.description,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF85858D),
                    fontSize: 12,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

 // REDES SOCIALES

class _BotonRedSocial extends StatefulWidget {
  final String imagen;
  final VoidCallback onTap;

  const _BotonRedSocial({
    required this.imagen,
    required this.onTap,
  });

  @override
  State<_BotonRedSocial> createState() => _BotonRedSocialState();
}

class _BotonRedSocialState extends State<_BotonRedSocial> {
  bool _presionado = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _presionado ? 0.92 : 1,
      duration: const Duration(milliseconds: 140),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (value) {
            setState(() => _presionado = value);
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: 54,
            height: 54,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFEAEAF0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Image.asset(
              widget.imagen,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.image_not_supported_outlined,
                  color: InicioPage.vino,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
