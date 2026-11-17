
import 'package:flutter/material.dart';
import '../planteles_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../posiciones_planteles.dart';
class PlantelesValleTolucaPage extends StatefulWidget {
  const PlantelesValleTolucaPage({super.key});

  @override
  State<PlantelesValleTolucaPage> createState() =>
      _PlantelesValleTolucaPageState();
}

class _PlantelesValleTolucaPageState
    extends State<PlantelesValleTolucaPage> {

  static const Color vino = Color(0xFF7B1735);
  static const Color vinoOscuro = Color(0xFF4A0D1F);
  static const Color fondo = Color(0xFFF7F7F7);
// DIMENSIONES DE LA IMAGEN ORIGINAL
static const double anchoOriginal = 2048;
static const double altoOriginal = 1949;

  final TransformationController _transformController =
      TransformationController();

  List<Plantel> _planteles = [];

  Plantel? _plantelSeleccionado;

  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarPlanteles();
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  // CONSULTAR PLANTELES DESDE PHP
  Future<void> _cargarPlanteles() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final respuesta =
          await PlantelesService.obtenerPlanteles('valle_toluca');

      final lista = respuesta['planteles'];

      if (lista is! List) {
        throw Exception(
          'La respuesta no contiene una lista de planteles.',
        );
      }

      final planteles = lista
    .whereType<Map>()
    .map((p) => Plantel.fromJson(
          Map<String, dynamic>.from(p),
          PosicionesPlanteles.valleToluca,
        ))
          .toList();

      if (!mounted) return;

      setState(() {
        _planteles = planteles;
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

  // RESTABLECER ZOOM
  void _reiniciarZoom() {
    _transformController.value = Matrix4.identity();
  }

  // CONVERTIR COORDENADAS NORMALIZADAS A LA ESCALA VISUAL
double _convertirX(double x, double ancho) {
  return x * ancho;
}

double _convertirY(double y, double alto) {
  return y * alto;
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
          'Valle de Toluca',
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

          // ENCABEZADO
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
                    fontSize: 11,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Zona Valle de Toluca',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
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

          // MAPA
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

          // INFORMACIÓN DEL PLANTEL
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),

            child: _plantelSeleccionado == null
                ? _crearInstruccion()
                : _crearTarjeta(_plantelSeleccionado!),
          ),
        ],
      ),
    );
  }

  // MENSAJE DE ERROR
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
              'No fue posible cargar los planteles.',
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
              onPressed: _cargarPlanteles,
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

  // CONSTRUIR MAPA Y MARCADORES
  Widget _crearMapa() {
    return LayoutBuilder(
      builder: (context, constraints) {

        // SE CONSERVA LA PROPORCIÓN ORIGINAL 1440 x 1305
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

                // IMAGEN ORIGINAL DEL MAPA
                CachedNetworkImage(
                imageUrl:
                    'http://10.35.16.16/saesc/media/images/craftmap/mapa_valle_toluca.jpg',
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
                      'No se pudo cargar el  mapa del servidor.',
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),

                // MARCADORES DINÁMICOS
                for (final plantel in _planteles)
                  if (plantel.x != null && plantel.y != null)
                    Positioned(
                      left: _convertirX(plantel.x!, ancho) - 9,
                      top: _convertirY(plantel.y!, alto) - 9,

                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _plantelSeleccionado = plantel;
                          });
                        },

                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 7,
                          height: 7,

                          decoration: BoxDecoration(
                            color: _plantelSeleccionado?.clave ==
                                    plantel.clave
                                ? const Color(0xFFB89059)
                                : const Color(0xFF7AAB40),

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

                          alignment: Alignment.center,

                          
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

  // INSTRUCCIONES DEL MAPA
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
              'Planteles cargados: ${_planteles.length}.',
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // TARJETA DE INFORMACIÓN DEL PLANTEL
  
Widget _crearTarjeta(Plantel plantel) {
  return Container(
    key: ValueKey(plantel.clave),
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
            Icons.location_on,
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
                'Plantel ${plantel.clave}',
                style: const TextStyle(
                  color: vino,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                plantel.nombre,
                style: const TextStyle(
                  color: Color(0xFF29252A),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // MUNICIPIO
              if (plantel.nombreMunicipio.isNotEmpty) ...[
                const SizedBox(height: 8),
              
                _crearDato(
                  Icons.location_city,
                  'Municipio',
                  plantel.nombreMunicipio,
                ),
              ],

              // LOCALIDAD
              if (plantel.nombreLocalidad.isNotEmpty)
                _crearDato(
                  Icons.place_outlined,
                  'Localidad',
                  plantel.nombreLocalidad,
                ),

              // DIRECCIÓN
              if (plantel.direccion.isNotEmpty)
                _crearDato(
                  Icons.map_outlined,
                  'Dirección',
                  plantel.direccion,
                ),

              // TELÉFONO
              if (plantel.telefono.isNotEmpty)
                _crearDato(
                  Icons.phone_outlined,
                  'Teléfono',
                  plantel.telefono,
                ),

              // CORREO
              if (plantel.correo.isNotEmpty)
                _crearDato(
                  Icons.email_outlined,
                  'Correo electrónico',
                  plantel.correo,
                ),
            ],
          ),
        ),

        IconButton(
          tooltip: 'Cerrar información',

          onPressed: () {
            setState(() {
              _plantelSeleccionado = null;
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


class Plantel {
  final String clave;
  final String nombre;

  // Claves originales
  final String municipio;
  final String localidad;

  // Nombres descriptivos
  final String nombreMunicipio;
  final String nombreLocalidad;

  final String direccion;
  final String telefono;
  final String correo;

  final double? x;
  final double? y;

  const Plantel({
    required this.clave,
    required this.nombre,
    required this.municipio,
    required this.localidad,
    required this.nombreMunicipio,
    required this.nombreLocalidad,
    required this.direccion,
    required this.telefono,
    required this.correo,
    this.x,
    this.y,
  });

  factory Plantel.fromJson(
    Map<String, dynamic> json,
    Map<String, Offset> posiciones,
  ) {
    final clave = json['clave']?.toString() ?? '';

    final posicion = posiciones[clave];

    return Plantel(
      clave: clave,
      nombre: json['plantel']?.toString() ?? '',

      municipio: json['municipio']?.toString() ?? '',
      localidad: json['localidad']?.toString() ?? '',

      nombreMunicipio:
          json['nombre_municipio']?.toString() ?? '',

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

