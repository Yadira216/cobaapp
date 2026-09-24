import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/web_page.dart';
import 'screens/calendario_page.dart';

void main() {
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
      ),
      home: const InicioPage(),
    );
  }
}

class InicioPage extends StatelessWidget {
  const InicioPage({super.key});

  static const Color vino = Color(0xFF7B1735);
  static const Color verde = Color(0xFF55A630);
  static const Color fondo = Color(0xFFF7F7F7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              
              // ENCABEZADO
             
              Row(
                children: [
                  Image.asset(
                    'assets/logoedu.png',
                    height: 34,
                  ),
                  const SizedBox(width: 10),
                  Image.asset(
                    'assets/cobalogo.png',
                    height: 40,
                  ),
                  const Spacer(),
                  _IconButtonCard(
                    icon: Icons.notifications_none_rounded,
                    onTap: () => _mostrarAvisos(context),
                  ),
                ],
              ),

              const SizedBox(height: 18),

            
              // TITULO CENTRADO CON WIDGET CENTER)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'COBA',
                            style: TextStyle(
                              color: vino,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          TextSpan(
                            text: 'app',
                            style: TextStyle(
                              color: verde,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 4), 
                    const Text(
                      'Colegio de Bachilleres del Estado de México',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color.fromARGB(255, 107, 105, 105),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),


            
              // MENU
              

              Expanded(
                child: Column(
                  children: [

                    Expanded(
                      child: GridView.count(
                        physics:
                            const NeverScrollableScrollPhysics(),

                        crossAxisCount: 2,

                        crossAxisSpacing: 14,

                        mainAxisSpacing: 14,

                        childAspectRatio: 1.1,

                        children: [

                          // ESTUDIANTE
                          MenuCard(
                            icon: Icons.school_rounded,
                            title: 'Estudiante',
                            color: vino,
                            onTap: () => _abrir(
                              context,
                              const LoginPage(
                                tipoUsuario: 'Estudiante',
                              ),
                            ),
                          ),

                          // CALENDARIO
                          MenuCard(
                            icon: Icons.calendar_month_rounded,
                            title: 'Calendario',
                            color: verde,
                            onTap: () => _abrir(
                              context,
                              const CalendarioPage(),
                            ),
                          ),

                          // DOCUMENTOS
                          MenuCard(
                            icon: Icons.description_rounded,
                            title: 'Documentos',
                            color: vino,
                            onTap: () => _abrir(
                              context,
                              const WebPage(
                                titulo: 'Documentos',
                                url:
                                    'https://saesc.cobaemex.edu.mx/android/documentos.html',
                              ),
                            ),
                          ),

                          // PLANTELES
                          MenuCard(
                            icon: Icons.location_city_rounded,
                            title: 'Planteles',
                            color: verde,
                            onTap: () => _abrir(
                              context,
                              const WebPage(
                                titulo: 'Planteles',
                                url:
                                    'https://saesc.cobaemex.edu.mx/saesc/sisCrafmap/',
                              ),
                            ),
                          ),

                          // PERSONAL
                          MenuCard(
                            icon: Icons.people_alt_rounded,
                            title: 'Personal',
                            color: vino,
                            onTap: () => _abrir(
                              context,
                              const LoginPage(
                                tipoUsuario: 'Personal',
                              ),
                            ),
                          ),

                          // ENLACES
                          MenuCard(
                            icon: Icons.link_rounded,
                            title: 'Enlaces',
                            color: verde,
                            onTap: () => _abrir(
                              context,
                              const WebPage(
                                titulo: 'Enlaces',
                                url:
                                    'https://saesc.cobaemex.edu.mx/android/enlaces.html',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // =========================
                    // BOTON NOSOTROS
                    // =========================

                    _BotonNosotros(
                      onTap: () => _abrir(
                        context,
                        const WebPage(
                          titulo: 'Nosotros',
                          url:
                              'https://saesc.cobaemex.edu.mx/android/acerca.html',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // ABRIR PANTALLA
  // =========================

  void _abrir(
    BuildContext context,
    Widget pantalla,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => pantalla,
      ),
    );
  }

  // =========================
  // AVISOS
  // =========================

  void _mostrarAvisos(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),

      builder: (context) => const Padding(
        padding: EdgeInsets.fromLTRB(
          25,
          10,
          25,
          35,
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [

            Icon(
              Icons.notifications_rounded,
              color: vino,
              size: 40,
            ),

            SizedBox(height: 10),

            Text(
              'Avisos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// BOTON DE AVISOS
// =====================================================

class _IconButtonCard extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButtonCard({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,

      borderRadius: BorderRadius.circular(16),

      elevation: 1,

      child: InkWell(
        borderRadius: BorderRadius.circular(16),

        onTap: onTap,

        child: SizedBox(
          width: 46,
          height: 46,

          child: Icon(
            icon,
            color: InicioPage.vino,
            size: 23,
          ),
        ),
      ),
    );
  }
}
// =====================================================
// BOTON NOSOTROS
// =====================================================

class _BotonNosotros extends StatefulWidget {
  final VoidCallback onTap;

  const _BotonNosotros({
    required this.onTap,
  });

  @override
  State<_BotonNosotros> createState() => _BotonNosotrosState();
}

class _BotonNosotrosState extends State<_BotonNosotros> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _scale = 0.97;
        });
      },

      onTapUp: (_) {
        setState(() {
          _scale = 1.0;
        });
      },

      onTapCancel: () {
        setState(() {
          _scale = 1.0;
        });
      },

      onTap: widget.onTap,

      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),

        child: Container(
          height: 80,
          width: double.infinity,

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),

            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF8B173D),
                Color(0xFF7B1735),
                Color.fromARGB(255, 85, 18, 39),
              ],
            ),

            boxShadow: [
              BoxShadow(
                color: InicioPage.vino.withOpacity(0.22),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),

          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
            ),

            child: Row(
              children: [

                // ICONO
                Container(
                  width: 54,
                  height: 54,

                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(18),
                  ),

                  child: const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),

                const SizedBox(width: 18),

                // TEXTO
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      Text(
                        'Acerca del COBAEM',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: 3),

                      Text(
                        'Nosotros',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),

                // FLECHA
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================
// MENU CARD
// =====================================================

class MenuCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const MenuCard({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  State<MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<MenuCard> {

  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {

    return GestureDetector(

      onTapDown: (_) {
        setState(() {
          _scale = 0.95;
        });
      },

      onTapUp: (_) {
        setState(() {
          _scale = 1.0;
        });
      },

      onTapCancel: () {
        setState(() {
          _scale = 1.0;
        });
      },

      onTap: widget.onTap,

      child: AnimatedScale(
        scale: _scale,

        duration: const Duration(
          milliseconds: 120,
        ),

        child: Container(

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius:
                BorderRadius.circular(24),

            border: Border.all(
              color: widget.color.withOpacity(0.06),
              width: 1,
            ),

            boxShadow: [
              BoxShadow(
                color:
                    widget.color.withOpacity(0.10),

                blurRadius: 16,

                offset: const Offset(0, 6),
              ),
            ],
          ),

          child: Stack(
            children: [

              // ICONO

              Center(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [

                    Container(
                      width: 56,
                      height: 56,

                      decoration: BoxDecoration(
                        color:
                            widget.color.withOpacity(0.10),

                        borderRadius:
                            BorderRadius.circular(18),
                      ),

                      child: Icon(
                        widget.icon,
                        color: widget.color,
                        size: 28,
                      ),
                    ),

                    const SizedBox(height: 11),

                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              
            ],
          ),
        ),
      ),
    );
  }
}