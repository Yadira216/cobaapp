import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../planteles_service.dart';
import '../posiciones_planteles.dart';

class PlantelesCemsadPage extends StatefulWidget {
  const PlantelesCemsadPage({super.key});

  @override
  State<PlantelesCemsadPage> createState() =>
      _PlantelesCemsadPageState();
}

class _PlantelesCemsadPageState extends State<PlantelesCemsadPage> {
  static const Color vino = Color(0xFF7B1735);
  static const Color vinoOscuro = Color(0xFF4A0D1F);
  static const Color fondo = Color(0xFFF7F7F7);

  static const double anchoOriginal = 2048;
  static const double altoOriginal = 1949;

  static const String urlMapa =
      'http://10.35.16.16/saesc/media/images/craftmap/mapa_cemsad.jpg';

  final TransformationController _transformController =
      TransformationController();

  List<CentroCemsad> _centros = [];
  CentroCemsad? _centroSeleccionado;

  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarCentros();
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  // CONSULTAR CENTROS CEMSAD DESDE PHP.
  Future<void> _cargarCentros() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final respuesta =
          await PlantelesService.obtenerPlanteles('cemsad');

      final lista = respuesta['planteles'];

      if (lista is! List) {
        throw Exception(
          'La respuesta no contiene una lista de centros CEMSAD.',
        );
      }

      final centros = lista
          .whereType<Map>()
          .map(
            (p) => CentroCemsad.fromJson(
              Map<String, dynamic>.from(p),
              PosicionesPlanteles.cemsadValleToluca,
            ),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        _centros = centros;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  // RESTABLECER ZOOM.
  void _reiniciarZoom() {
    _transformController.value = Matrix4.identity();
  }

  // CONVERTIR COORDENADAS NORMALIZADAS.
  double _convertirX(double x, double ancho) => x * ancho;

  double _convertirY(double y, double alto) => y * alto;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,

      appBar: AppBar(
        backgroundColor: vino,
        foregroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'Centros CEMSAD',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),

        actions: [
          IconButton(
            tooltip: 'Restablecer mapa',
            onPressed: _reiniciarZoom,
            icon: const Icon(Icons.center_focus_strong),
          ),
        ],
      ),

      body: Column(
        children: [
          // ENCABEZADO.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            color: vinoOscuro,

            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'COLEGIO DE BACHILLERES DEL ESTADO DE MÉXICO',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Centros de Educación Media Superior a Distancia',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Amplía el mapa y toca un marcador para consultar sus datos.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // MAPA.
          Expanded(
            child: _cargando
                ? const Center(
                    child: CircularProgressIndicator(
                      color: vino,
                    ),
                  )
                : _error != null
                    ? _crearError()
                    : _crearMapa(),
          ),

          // INFORMACIÓN DEL CENTRO.
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),

            child: _centroSeleccionado == null
                ? _crearInstruccion()
                : _crearTarjeta(_centroSeleccionado!),
          ),
        ],
      ),
    );
  }

  // MENSAJE DE ERROR.
  Widget _crearError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off,
              size: 48,
              color: Colors.black38,
            ),

            const SizedBox(height: 12),

            const Text(
              'No fue posible cargar los centros CEMSAD.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _error ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _cargarCentros,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: vino,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CONSTRUIR MAPA Y MARCADORES.
  Widget _crearMapa() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double ancho = constraints.maxWidth;
        final double alto =
            ancho * (altoOriginal / anchoOriginal);

        return InteractiveViewer(
          transformationController: _transformController,
          minScale: 1,
          maxScale: 5,
          boundaryMargin: const EdgeInsets.all(100),
          constrained: false,

          child: SizedBox(
            width: ancho,
            height: alto,

            child: Stack(
              fit: StackFit.expand,
              children: [
                // IMAGEN DEL MAPA DESDE EL SERVIDOR.
                CachedNetworkImage(
                  imageUrl: urlMapa,
                  fit: BoxFit.fill,

                  placeholder: (context, url) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: vino,
                      ),
                    );
                  },

                  errorWidget: (context, url, error) {
                    return const Center(
                      child: Text(
                        'No se pudo cargar el mapa del servidor.',
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),

                // MARCADORES.
                for (final centro in _centros)
                  if (centro.x != null && centro.y != null)
                    Positioned(
                      left: _convertirX(
                            centro.x!,
                            ancho,
                          ) - 3.5,

                      top: _convertirY(
                            centro.y!,
                            alto,
                          ) - 3.5,

                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _centroSeleccionado = centro;
                          });
                        },

                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 7,
                          height: 7,

                          decoration: BoxDecoration(
                            color: _centroSeleccionado?.clave ==
                                    centro.clave
                                ? const Color(0xFFB89059)
                                : const Color(0xFFBA0814),

                            shape: BoxShape.circle,

                            border: Border.all(
                              color: Colors.white,
                              width: 1.5,
                            ),

                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 3,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }

  // INSTRUCCIONES.
  Widget _crearInstruccion() {
    return Container(
      key: const ValueKey('instruccion'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.white,

      child: Row(
        children: [
          const Icon(
            Icons.touch_app,
            color: vino,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              'Selecciona un marcador para ver la información. '
              'Centros cargados: ${_centros.length}.',
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // TARJETA DE INFORMACIÓN.
  
  // TARJETA DE INFORMACIÓN DEL CENTRO

  Widget _crearTarjeta(CentroCemsad centro) {
    return Container(
      key: ValueKey(centro.clave),
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),

      decoration: const BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            width: 48,
            height: 48,

            decoration: BoxDecoration(
              color: vino.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),

            child: const Icon(
              Icons.school_outlined,
              color: vino,
              size: 28,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  'Centro CEMSAD ${centro.clave}',
                  style: const TextStyle(
                    color: vino,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  centro.nombre,
                  style: const TextStyle(
                    color: Color(0xFF29252A),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // MUNICIPIO
                if (centro.nombreMunicipio.isNotEmpty) ...[
                  const SizedBox(height: 8),

                  _crearDato(
                    Icons.location_city,
                    'Municipio',
                    centro.nombreMunicipio,
                  ),
                ],
                // LOCALIDAD
                if (centro.nombreLocalidad.isNotEmpty)
                  _crearDato(
                    Icons.place_outlined,
                    'Localidad',
                    centro.nombreLocalidad,
                  ),

                // DIRECCIÓN
                if (centro.direccion.isNotEmpty)
                  _crearDato(
                    Icons.map_outlined,
                    'Dirección',
                    centro.direccion,
                  ),

                // TELÉFONO
                if (centro.telefono.isNotEmpty)
                  _crearDato(
                    Icons.phone_outlined,
                    'Teléfono',
                    centro.telefono,
                  ),

                // CORREO
                if (centro.correo.isNotEmpty)
                  _crearDato(
                    Icons.email_outlined,
                    'Correo electrónico',
                    centro.correo,
                  ),
              ],
            ),
          ),

          IconButton(
            tooltip: 'Cerrar información',

            onPressed: () {
              setState(() {
                _centroSeleccionado = null;
              });
            },

            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  // COMPONENTE PARA MOSTRAR CADA DATO
  Widget _crearDato(
    IconData icono,
    String titulo,
    String valor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Icon(
            icono,
            size: 15,
            color: vino,
          ),

          const SizedBox(width: 7),

          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),

                children: [
                  TextSpan(
                    text: '$titulo: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF29252A),
                    ),
                  ),

                  TextSpan(text: valor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
// ======================================================
// MODELO DE DATOS
// ======================================================


class CentroCemsad {
  final String clave;
  final String nombre;

  final String municipio;
  final String nombreMunicipio;
  final String localidad;

  final String nombreLocalidad;
  final String direccion;
  final String telefono;
  final String correo;

  final double? x;
  final double? y;

  const CentroCemsad({
    required this.clave,
    required this.nombre,
    required this.municipio,
    required this.nombreMunicipio,
    required this.localidad,
    required this.nombreLocalidad,
    required this.direccion,
    required this.telefono,
    required this.correo,
    this.x,
    this.y,
  });

  factory CentroCemsad.fromJson(
    Map<String, dynamic> json,
    Map<String, Offset> posiciones,
  ) {
    final clave = json['clave']?.toString() ?? '';
    final posicion = posiciones[clave];

    return CentroCemsad(
      clave: clave,
      nombre: json['plantel']?.toString() ?? '',
      municipio: json['municipio']?.toString() ?? '',
      nombreMunicipio:
    json['nombre_municipio']?.toString() ?? '',
      localidad: json['localidad']?.toString() ?? '',
      nombreLocalidad:
          json['nombre_localidad']?.toString() ?? '',
      direccion: json['direccion']?.toString() ?? '',
      telefono: json['telefono']?.toString() ?? '',
      correo: json['correo']?.toString() ?? '',
      x: posicion?.dx,
      y: posicion?.dy,
    );
  }
}