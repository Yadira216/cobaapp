import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';

class EscanearQrPage extends StatefulWidget {
  const EscanearQrPage({super.key});

  @override
  State<EscanearQrPage> createState() => _EscanearQrPageState();
}

class _EscanearQrPageState extends State<EscanearQrPage> {
  static const Color vino = Color(0xFF7B1735);
  static const Color verde = Color(0xFF55A630);
  static const Color fondo = Color(0xFFF7F7F7);

  static const String endpoint =
      'http://10.35.16.16/saesc/android/android.php';

  final MobileScannerController _scannerController =
      MobileScannerController();

  bool _procesando = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _procesarQR(String codigo) async {
    if (_procesando) {
      return;
    }

    _procesando = true;

    await _scannerController.stop();

    /*
     * Formato esperado:
     *
     * COBAEM:id:idPlantel:matricula
     *
     * Ejemplo:
     *
     * COBAEM:254635:1:202600100022
     */

    final partes = codigo.trim().split(':');

    if (partes.length != 4 ||
        partes[0].trim().toUpperCase() != 'COBAEM') {
      _mostrarResultado(
        exito: false,
        mensaje: 'El código QR no tiene un formato válido.',
      );

      _reiniciarScanner();
      return;
    }

    final idAlumno = partes[1].trim();
    final idPlantel = partes[2].trim();
    final matricula = partes[3].trim();

    if (matricula.isEmpty || idPlantel.isEmpty) {
      _mostrarResultado(
        exito: false,
        mensaje: 'El QR no contiene los datos necesarios.',
      );

      _reiniciarScanner();
      return;
    }

    await _registrarAsistencia(
      idAlumno: idAlumno,
      idPlantel: idPlantel,
      matricula: matricula,
    );
  }

  Future<void> _registrarAsistencia({
    required String idAlumno,
    required String idPlantel,
    required String matricula,
  }) async {
    try {
      final respuesta = await http
          .post(
            Uri.parse(endpoint),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'accion': 'registrar_asistencia_qr',
              'matricula': matricula,
              'plantel': idPlantel,
            }),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      if (respuesta.statusCode != 200) {
        _mostrarResultado(
          exito: false,
          mensaje: 'El servidor respondió con un error.',
        );

        _reiniciarScanner();
        return;
      }

      final datos = jsonDecode(respuesta.body);

      if (datos['status'] == 'success') {
        final bool duplicada =
            datos['duplicada'] == true ||
            datos['ya_registrada'] == true;

        final nombre = datos['nombre']?.toString() ?? '';
        final matriculaRespuesta =
            datos['matricula']?.toString() ?? matricula;
        final hora = datos['hora']?.toString() ?? '';

        _mostrarResultado(
          exito: true,
          mensaje: duplicada
              ? 'La asistencia ya estaba registrada.'
              : 'Asistencia registrada correctamente.',
          nombre: nombre,
          matricula: matriculaRespuesta,
          hora: hora,
          duplicada: duplicada,
        );
      } else {
        _mostrarResultado(
          exito: false,
          mensaje: datos['mensaje']?.toString() ??
              'No fue posible registrar la asistencia.',
        );

        _reiniciarScanner();
      }
    } catch (e) {
      _mostrarResultado(
        exito: false,
        mensaje: 'No fue posible conectar con el servidor.',
      );

      _reiniciarScanner();
    }
  }

  void _mostrarResultado({
    required bool exito,
    required String mensaje,
    String nombre = '',
    String matricula = '',
    String hora = '',
    bool duplicada = false,
  }) {
    if (!mounted) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: (exito ? verde : Colors.red)
                      .withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  exito
                      ? Icons.check_rounded
                      : Icons.close_rounded,
                  color: exito ? verde : Colors.red,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  exito
                      ? 'Asistencia'
                      : 'No se pudo registrar',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mensaje,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                ),
              ),

              if (exito) ...[
                const SizedBox(height: 18),

                if (nombre.isNotEmpty)
                  _datoResultado(
                    Icons.person_outline_rounded,
                    'Alumno',
                    nombre,
                  ),

                _datoResultado(
                  Icons.badge_outlined,
                  'Matrícula',
                  matricula,
                ),

                if (hora.isNotEmpty)
                  _datoResultado(
                    Icons.access_time_rounded,
                    'Hora',
                    hora,
                  ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                if (mounted) {
                  _reiniciarScanner();
                }
              },
              child: Text(
                'Aceptar',
                style: TextStyle(
                  color: vino,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _datoResultado(
    IconData icono,
    String titulo,
    String valor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icono,
            color: vino,
            size: 20,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Color(0xFF252525),
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: '$titulo: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: valor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _reiniciarScanner() {
    if (!mounted) {
      return;
    }

    setState(() {
      _procesando = false;
    });

    _scannerController.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              if (capture.barcodes.isEmpty) {
                return;
              }

              final codigo =
                  capture.barcodes.first.rawValue;

              if (codigo == null || codigo.trim().isEmpty) {
                return;
              }

              _procesarQR(codigo);
            },
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    14,
                    18,
                    0,
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.45),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      const Expanded(
                        child: Text(
                          'Escanear QR',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.45),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: IconButton(
                          onPressed: () {
                            _scannerController.toggleTorch();
                          },
                          icon: const Icon(
                            Icons.flashlight_on_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 30,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.60),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Text(
                    'Coloca el código QR del alumno dentro del recuadro',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),

                const Spacer(),

                const Padding(
                  padding: EdgeInsets.only(bottom: 28),
                  child: Text(
                    'COBAapp',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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
}