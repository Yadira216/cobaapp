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
      theme: ThemeData(useMaterial3: true, fontFamily: 'Roboto'),
      home: const InicioPage(),
    );
  }
}

class InicioPage extends StatelessWidget {
  const InicioPage({super.key});

  static const Color vino = Color(0xFF7B1735);
  static const Color verde = Color(0xFF55A630);



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset('assets/logoedu.png', height: 34),
                  const SizedBox(width: 10),
                  Image.asset('assets/cobalogo.png', height: 40),
                  const Spacer(),
                  _IconButtonCard(
                    icon: Icons.notifications_none_rounded,
                    onTap: () => _mostrarAvisos(context),
                  ),
                ],
              ),const SizedBox(height: 18),
RichText(
  text: const TextSpan(
    children: [
      TextSpan(
        text: 'COBA',
        style: TextStyle(
          color: vino,
          fontSize: 32,
          fontWeight: FontWeight.w900,
        ),
      ),
      TextSpan(
        text: 'app',
        style: TextStyle(
          color: verde,
          fontSize: 32,
          fontWeight: FontWeight.w900,
        ),
      ),
    ],
  ),
),
const SizedBox(height: 4), // Un pequeño espacio opcional entre "COBAapp" y el subtítulo
const Text(
  'Colegio de Bachilleres del Estado de México',
  textAlign: TextAlign.center, // Por si se centra respecto ai loogp
  style: TextStyle(
    color: verde,
    fontSize: 16,
    fontWeight: FontWeight.w900,
  ),
),
const SizedBox(height: 20),

              Expanded(
  child: Column(
    children: [
      Expanded(
        child: GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.1,
          children: [
            MenuCard(
              icon: Icons.school_rounded,
              title: 'Estudiante',
              color: vino,
              onTap: () => _abrir(
                context,
                const LoginPage(tipoUsuario: 'Estudiante'),
              ),
            ),

            MenuCard(
  icon: Icons.calendar_month_rounded,
  title: 'Calendario',
  color: verde,
  onTap: () => _abrir(context, const CalendarioPage()),
),

            MenuCard(
              icon: Icons.description_rounded,
              title: 'Documentos',
              color: vino,
              onTap: () => _abrir(
                context,
                const WebPage(
                  titulo: 'Documentos',
                  url: 'https://saesc.cobaemex.edu.mx/android/documentos.html',
                ),
              ),
            ), 
          

            MenuCard(
              icon: Icons.location_city_rounded,
              title: 'Planteles',
              color: verde,
              onTap: () => _abrir(
                context,
                const WebPage(
                  titulo: 'Planteles',
                  url: 'https://saesc.cobaemex.edu.mx/saesc/sisCrafmap/',
                ),
              ),
            ),

            MenuCard(
              icon: Icons.people_alt_rounded,
              title: 'Personal',
              color: vino,
              onTap: () => _abrir(
                context,
                const LoginPage(tipoUsuario: 'Personal'),
              ),
            ),

            MenuCard(
              icon: Icons.link_rounded,
              title: 'Enlaces',
              color: verde,
              onTap: () => _abrir(
                context,
                const WebPage(
                  titulo: 'Enlaces',
                  url: 'https://saesc.cobaemex.edu.mx/android/enlaces.html',
                ),
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 14),

      // BOTÓN NOSOTROS
      GestureDetector(
        onTap: () => _abrir(
          context,
          const WebPage(
            titulo: 'Nosotros',
            url: 'https://saesc.cobaemex.edu.mx/android/acerca.html',
          ),
        ),
        child: Container(
          height: 62,
          width: double.infinity,
          decoration: BoxDecoration(
            color: vino,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: vino.withOpacity(0.22),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Nosotros',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
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

  void _abrir(BuildContext context, Widget pantalla) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));
  }

  void _mostrarAvisos(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => const Padding(
        padding: EdgeInsets.fromLTRB(25, 10, 25, 35),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_rounded, color: vino, size: 40),
            SizedBox(height: 10),
            Text('Avisos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _IconButtonCard extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconButtonCard({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: InicioPage.vino, size: 22),
        ),
      ),
    );
  }
}

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
      onTapDown: (_) => setState(() => _scale = 0.94),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.15),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(widget.icon, color: widget.color, size: 26),
              ),
              const SizedBox(height: 10),
              Text(
                widget.title,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}