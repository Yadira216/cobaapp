import 'package:flutter/material.dart';

import 'planteles_valle_toluca_page.dart';
import 'planteles_valle_mexico_page.dart';
import 'planteles_cemsad_page.dart';

class PlantelesPage extends StatelessWidget {
  const PlantelesPage({super.key});

  static const Color vino = Color(0xFF7B1735);
  static const Color vinoOscuro = Color(0xFF4A0D1F);
  static const Color fondo = Color(0xFFF7F7F7);

  void _abrirMapa(BuildContext context, String zona) {
    switch (zona) {
      case 'valle_toluca':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const PlantelesValleTolucaPage(),
          ),
        );
        break;

      case 'valle_mexico':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const PlantelesValleMexicoPage(),
          ),
        );
        break;
      case 'cemsad':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PlantelesCemsadPage(),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,

      appBar: AppBar(
        backgroundColor: vino,
        foregroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'Planteles',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ENCABEZADO.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    vinoOscuro,
                    vino,
                    Color(0xFF922A49),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),

                borderRadius: BorderRadius.circular(20),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Container(
                    padding: const EdgeInsets.all(11),

                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),

                    child: const Icon(
                      Icons.location_on_outlined,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'PLANTELES COBAEM',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 7),

                  const Text(
                    'Consulta de planteles',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Selecciona una zona para visualizar '
                    'la ubicación de sus unidades académicas.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // CENTROS CEMSAD (Color Dorado / Ocre).
            _crearTarjeta(
              context: context,
              titulo: 'Centros CEMSAD',
              descripcion:
                  'Consulta las unidades académicas de modalidad CEMSAD.',
              colorCuadro: const Color(0xFFBA0814),
              cantidad: '15 centros',
              disponible: true,
              onTap: () => _abrirMapa(context, 'cemsad'),
            ),

            const SizedBox(height: 14),

            // VALLE DE MÉXICO (Color Azul Marino).
            _crearTarjeta(
              context: context,
              titulo: 'Valle de México',
              descripcion:
                  'Visualiza la ubicación de los planteles de esta zona.',
              colorCuadro: const Color(0xFF0D7138),
              cantidad: '32 planteles',
              disponible: true,
              onTap: () => _abrirMapa(context, 'valle_mexico'),
            ),

            const SizedBox(height: 14),

            // VALLE DE TOLUCA (Color Vino).
            _crearTarjeta(
              context: context,
              titulo: 'Valle de Toluca',
              descripcion:
                  'Consulta la distribución geográfica de sus planteles.',
              colorCuadro: const Color(0xFF7AAB40),
              cantidad: '36 planteles',
              disponible: true,
              onTap: () => _abrirMapa(context, 'valle_toluca'),
            ),

            const SizedBox(height: 24),

            Center(
              child: Text(
                'COLEGIO DE BACHILLERES DEL ESTADO DE MÉXICO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.45),
                  fontSize: 10,
                  letterSpacing: 0.7,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TARJETA DE CADA ZONA.
  Widget _crearTarjeta({
    required BuildContext context,
    required String titulo,
    required String descripcion,
    required Color colorCuadro,
    required String cantidad,
    required bool disponible,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),

        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFEAE7E9),
            ),
          ),

          child: Row(
            children: [

              // CUADRITO CHIQUITO SÓLIDO
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: colorCuadro,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      titulo,
                      style: const TextStyle(
                        color: Color(0xFF29252A),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      descripcion,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 9),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorCuadro.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        cantidad,
                        style: TextStyle(
                          color: colorCuadro,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.black38,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
