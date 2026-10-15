import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class CodigoQrPage extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const CodigoQrPage({
    super.key,
    required this.usuario,
  });

  @override
  State<CodigoQrPage> createState() => _CodigoQrPageState();
}

class _CodigoQrPageState extends State<CodigoQrPage> {
  static const Color vino = Color(0xFF7B1735);
  static const Color vinoOscuro = Color(0xFF4A0D1F);
  static const Color verde = Color(0xFF55A630);
  static const Color fondo = Color(0xFFF6F7F9);

  String _textoQR() {
    final idAlumno = widget.usuario['id_alumno']?.toString() ?? '';
    final idPlantel = widget.usuario['relid_plantel']?.toString() ?? '';
    final matricula = widget.usuario['matricula']?.toString() ?? '';

    return 'COBAEM:$idAlumno:$idPlantel:$matricula';
  }

  String _nombreAlumno() {
    return widget.usuario['nombre']?.toString() ?? 'Alumno';
  }

  String _matricula() {
    return widget.usuario['matricula']?.toString() ?? '—';
  }

  Future<void> _imprimir(BuildContext context) async {
    final textoQR = _textoQR();
    final nombre = _nombreAlumno();
    final matricula = _matricula();

    await Printing.layoutPdf(
      onLayout: (format) async {
        final documento = pw.Document();

        documento.addPage(
          pw.Page(
            pageFormat: format,
            build: (context) {
              return pw.Center(
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      'Código QR',
                      style: pw.TextStyle(
                        fontSize: 26,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Código de identificación del alumno',
                      style: const pw.TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    pw.SizedBox(height: 25),
                    pw.Text(
                      nombre,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Matrícula: $matricula',
                      style: const pw.TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    pw.SizedBox(height: 25),
                    pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(
                        errorCorrectLevel:
                            pw.BarcodeQRCorrectionLevel.high,
                      ),
                      data: textoQR,
                      width: 230,
                      height: 230,
                    ),
                    pw.SizedBox(height: 20),
                    pw.Text(
                      'Presenta este código QR cuando sea solicitado '
                      'para identificar tu registro como alumno.',
                      textAlign: pw.TextAlign.center,
                      style: const pw.TextStyle(
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );

        return documento.save();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Barra de estado guinda con iconos blancos.
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: vino,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    final textoQR = _textoQR();

    return Scaffold(
      backgroundColor: fondo,

      body: SafeArea(
        top: true,
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ============================================================
            // HEADER
            // ============================================================

            SliverToBoxAdapter(
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 650),
                curve: Curves.easeOutCubic,
                tween: Tween(begin: -25, end: 0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, value),
                    child: Opacity(
                      opacity: ((25 + value) / 25).clamp(0.0, 1.0),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    12,
                    18,
                    28,
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
                  child: Row(
                    children: [
                      _botonHeader(
                        Icons.arrow_back_rounded,
                        () => Navigator.pop(context),
                      ),

                      const SizedBox(width: 14),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mi código QR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Identificación digital',
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
                        width: 43,
                        height: 43,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.qr_code_2_rounded,
                          color: Colors.white,
                          size: 23,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ============================================================
            // CONTENIDO
            // ============================================================

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                18,
                22,
                18,
                35,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    // ======================================================
                    // TARJETA PRINCIPAL
                    // ======================================================

                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutBack,
                      tween: Tween(begin: .88, end: 1),
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: child,
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(
                          18,
                          22,
                          18,
                          22,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.055),
                              blurRadius: 22,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // ESTADO

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: verde.withOpacity(.09),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: verde,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 7),
                                  const Text(
                                    'Identificación digital',
                                    style: TextStyle(
                                      color: verde,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 17),

                            // NOMBRE

                            Text(
                              _nombreAlumno(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF252525),
                                height: 1.15,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: vino.withOpacity(.07),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Text(
                                'Matrícula ${_matricula()}',
                                style: const TextStyle(
                                  color: vino,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),

                            const SizedBox(height: 22),

                            // QR

                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(23),
                                border: Border.all(
                                  color: const Color(0xFFE8E8E8),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(.035),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: QrImageView(
                                data: textoQR,
                                version: QrVersions.auto,
                                size: 255,
                                backgroundColor: Colors.white,
                                errorCorrectionLevel:
                                    QrErrorCorrectLevel.H,
                              ),
                            ),

                            const SizedBox(height: 17),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BOTÓN HEADER
  // ============================================================

  Widget _botonHeader(
    IconData icono,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.13),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withOpacity(.08),
            ),
          ),
          child: Icon(
            icono,
            color: Colors.white,
            size: 21,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BOTONES DE ACCIÓN
  // ============================================================

  Widget _botonAccion({
    required IconData icono,
    required String texto,
    required bool secundario,
    required VoidCallback onTap,
  }) {
    return _BotonAnimado(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: secundario ? Colors.white : vino,
          borderRadius: BorderRadius.circular(17),
          border: secundario
              ? Border.all(
                  color: vino.withOpacity(.22),
                )
              : null,
          boxShadow: [
            if (!secundario)
              BoxShadow(
                color: vino.withOpacity(.18),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icono,
              color: secundario ? vino : Colors.white,
              size: 19,
            ),
            const SizedBox(width: 8),
            Text(
              texto,
              style: TextStyle(
                color: secundario ? vino : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ANIMACIÓN DE BOTONES
// ============================================================

class _BotonAnimado extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _BotonAnimado({
    required this.child,
    required this.onTap,
  });

  @override
  State<_BotonAnimado> createState() => _BotonAnimadoState();
}

class _BotonAnimadoState extends State<_BotonAnimado> {
  bool presionado = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          presionado = true;
        });
      },
      onTapCancel: () {
        setState(() {
          presionado = false;
        });
      },
      onTapUp: (_) {
        setState(() {
          presionado = false;
        });

        widget.onTap();
      },
      child: AnimatedScale(
        scale: presionado ? .96 : 1,
        duration: const Duration(milliseconds: 110),
        child: widget.child,
      ),
    );
  }
}